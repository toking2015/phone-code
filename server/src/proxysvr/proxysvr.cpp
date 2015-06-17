#include "log.h"
#include "netio.h"
#include "parammgr.h"
#include "util.h"

#include "sys/socket.h"

bool g_deamon = false;
int32 g_conn_count = 0;
int32 g_conn_max = 4000;
uint16 g_min_port = 10000;
uint16 g_max_port = 20000;

uint32 g_cool_time = 600;

std::string g_port;

class CInfo
{
public:
    std::vector<char>   send_buff;
    std::string     server_addr;
    int32           client_sock;
    int32           server_sock;

    uint64          id;
    bool            is_auth;

    CInfo()
    {
        static uint64 global_id = 0;

        id = ++global_id;

        client_sock = -1;
        server_sock = -1;

        is_auth = false;
    }
};

//释放冷却队列
std::map< uint64, uint32 > release_info_map;
std::map< uint64, CInfo* > info_map;

CInfo* FindInfo( uint64 id )
{
    std::map< uint64, CInfo* >::iterator iter = info_map.find( id );
    if ( iter != info_map.end() )
        return iter->second;

    return NULL;
}

CInfo* CreateInfo(void)
{
    CInfo* info = new CInfo;

    info_map[ info->id ] = info;

    return info;
}

void ReleaseInfo( uint64 id )
{
    std::map< uint64, CInfo* >::iterator iter = info_map.find( id );
    if ( iter == info_map.end() )
        return;

    delete iter->second;
    info_map.erase( iter );
}

void ClearNet( CInfo* info )
{
    if ( info->server_sock != -1 )
        theNet.Clear( info->server_sock );

    if ( info->client_sock != -1 )
        theNet.Clear( info->client_sock );

    release_info_map[ info->id ] = time(NULL) + g_cool_time;
}

void OnTransFromServer( void* p, int32 sock, char* buff, int32 size )
{
    CInfo* info = FindInfo( (uint64)p );
    if ( info == NULL )
    {
        theNet.Clear( sock );
        close( sock );
        return;
    }

    //连接断开处理
    if ( size <= 0 )
    {
        if ( release_info_map.find( info->id ) == release_info_map.end() )
        {
            g_conn_count--;

            ClearNet( info );

            LOG_DEBUG( "CloseFromServer: %s client[%d] server[%d]",
                info->server_addr.c_str(), info->client_sock, info->server_sock );
        }
        return;
    }

    //相互转发数据
    theNet.Write( info->client_sock, buff, size );
}

void OnTransFromClient( void* p, int32 sock, char* buff, int32 size )
{
    CInfo* info = FindInfo( (uint64)p );
    if ( info == NULL )
    {
        theNet.Clear( sock );
        close( sock );
    }

    //连接断开处理
    if ( size <= 0 )
    {
        if ( release_info_map.find( info->id ) == release_info_map.end() )
        {
            g_conn_count--;

            ClearNet( info );

            LOG_DEBUG( "CloseFromClient: %s client[%d] server[%d]",
                info->server_addr.c_str(), info->client_sock, info->server_sock );
        }
        return;
    }

    //相互转发数据
    theNet.Write( info->server_sock, buff, size );
}

void OnAccessConnect( void* p, int32 sock )
{
    CInfo* info = FindInfo( (uint64)p );
    if ( info == NULL )
    {
        theNet.Clear( sock );
        close( sock );
    }

    //连接失败容错处理
    if ( sock <= 0 )
    {
        LOG_DEBUG( "ConnectError: %s client[%d]",
            info->server_addr.c_str(), info->client_sock );

        ClearNet( info );
        return;
    }
    info->server_sock = sock;

    //获取剩以数据
    char buff[1024];
    int32 size = recv( info->client_sock, buff, sizeof( buff ), MSG_DONTWAIT );
    switch ( size )
    {
    case -1:
        {
            if ( errno != EAGAIN )
            {
                LOG_DEBUG( "ConnectError: sock reset %s client[%d] server[%d]",
                    info->server_addr.c_str(), info->client_sock, info->server_sock );

                //客户在连接主要服务期间已断开
                ClearNet( info );
                return;
            }
        }
        break;
    case 0:
        {
            LOG_DEBUG( "ConnectError: sock reset %s client[%d] server[%d]",
                info->server_addr.c_str(), info->client_sock, info->server_sock );

            //客户在连接主要服务期间已断开
            ClearNet( info );
            return;
        }
        break;
    default:
        //拼接临时缓存数据
        info->send_buff.insert( info->send_buff.end(), buff, buff + size );
        break;
    }

    //发送临时缓存数据
    theNet.Write( info->server_sock, &info->send_buff[0], info->send_buff.size() );
    info->send_buff.clear();

    //建立双方监听
    theNet.Read( info->server_sock, OnTransFromServer, (void*)info->id );
    theNet.Read( info->client_sock, OnTransFromClient, (void*)info->id );

    g_conn_count++;

    LOG_DEBUG( "TransTo: %s client[%d] server[%d]",
        info->server_addr.c_str(), info->client_sock, info->server_sock );
}

void OnAuthRead( void* p, int32 sock, char* buff, int32 size )
{
    //查找基本数据
    CInfo* info = FindInfo( (uint64)p );
    if ( info == NULL )
    {
        theNet.Clear( sock );
        close( sock );
    }

    //基本容错
    if ( release_info_map.find( info->id ) != release_info_map.end() )
        return;

    //数据包过小容错, 底层不可能会发一个小于基本认证结构的数据包
    if ( size <= 0 )
    {
        LOG_DEBUG( "AuthError: sock[%d] size[%d]", sock, size );

        ClearNet( info );
        return;
    }

    //数据包拼接
    if ( info->is_auth )
    {
        info->send_buff.insert( info->send_buff.end(), buff, buff + size );
        return;
    }

    //代理数据外处理
    if ( size >= 7 )
    {
        if ( memcmp( buff, "PROXY\r\n", 7 ) != 0 )
            return;
    }

    //copy数据并增加结束'\0', 防止恶意溢出攻击
    std::vector< char > data( size + 1 );
    memcpy( &data[0], buff, size );
    data[ size ] = '\0';

    //拷贝 host, port
    std::string host( size, '\0' );
    uint16 port = 0;
    sscanf( buff, "PROXY\r\nHost:%[^:]\r\n:%hu\r\n\r\n", &host[0], &port );

    //端口限制检查
    if ( port < g_min_port || port > g_max_port )
    {
        LOG_ERROR( "AuthError: sock[%d] port[%hu]", sock, port );

        ClearNet( info );
        return;
    }

    //代理目标地址转换( host可能存在很多'\0' )
    std::string addr = host.c_str();

    //内联地址基本容错
    if ( addr.empty() || addr == "localhost" || addr == "127.0.0.1" )
    {
        LOG_ERROR( "ERR_AUTH: %s sock[%d]", addr.c_str(), sock );

        ClearNet( info );
        return;
    }

    //解除认证数据包监听
    theNet.Read( sock, NULL, NULL );

    //拼接数据对象
    info->is_auth = true;
    info->server_addr = strprintf( "%s:%hu", addr.c_str(), port );

    //连接到远程服务器
    LOG_DEBUG( "AuthConnect: %s", info->server_addr.c_str() );
    theNet.Connect( info->server_addr.c_str(), OnAccessConnect, (void*)info->id );
}

void OnAuthTimeout( void* p )
{
    CInfo* info = FindInfo( (uint64)p );
    if ( info == NULL )
        return;

    if ( info->is_auth )
        return;

    ClearNet( info );
}

void OnProxyAccept( void* p, int32 sock )
{
    if ( sock <= 0 )
        return;

    //最大接入数限制判断
    if ( g_conn_count >= g_conn_max )
    {
        close( sock );
        return;
    }

    //拼接数据对象
    CInfo* info = CreateInfo();
    info->client_sock = sock;

    //加入到认证数据读取
    theNet.Timeout( 3, OnAuthTimeout, (void*)info->id );
    theNet.Read( sock, OnAuthRead, (void*)info->id );
}

void OnReleaseTimeout( void* p )
{
    theNet.Timeout( 1, OnReleaseTimeout, NULL );

    uint32 time_now = (uint32)time(NULL);

    std::list< uint64 > release_info_list;
    for ( std::map< uint64, uint32 >::iterator iter = release_info_map.begin();
        iter != release_info_map.end();
        ++iter )
    {
        if ( time_now > iter->second )
        {
            release_info_list.push_back( iter->first );
        }
    }

    for ( std::list< uint64 >::iterator iter = release_info_list.begin();
        iter != release_info_list.end();
        ++iter )
    {
        CInfo* info = FindInfo( *iter );
        if ( info == NULL )
        {
            release_info_map.erase( *iter );
            continue;
        }

        if ( info->server_sock > 0 )
        {
            theNet.Clear( info->server_sock );
            close( info->server_sock );
        }

        if ( info->client_sock > 0 )
        {
            theNet.Clear( info->client_sock );
            close( info->client_sock );
        }

        release_info_map.erase( *iter );
        ReleaseInfo( *iter );
    }
}

void init_proxy(void)
{
    //监听代理端口
    theNet.Accept( (char*)g_port.c_str(), OnProxyAccept, NULL );
}

//加载日志配置
void ParamLog( std::vector< std::string > params )
{
    CLog4cxx::read( params[0].c_str() );
}

void ParamPort( std::vector< std::string > params )
{
    g_port = params[0];
}

//最小端口代理限制
void ParamMinPort( std::vector< std::string > params )
{
    sscanf( params[0].c_str(), "%hu", &g_min_port );
}

//最大端口代理限制
void ParamMaxPort( std::vector< std::string > params )
{
    sscanf( params[0].c_str(), "%hu", &g_max_port );
}

//代理最大连接数接入限制
void ParamConnMax( std::vector< std::string > params )
{
    sscanf( params[0].c_str(), "%d", &g_conn_max );
    if ( g_conn_max > 10000 )
        g_conn_max = 10000;
}

//后台运行
void ParamDeamon( std::vector< std::string > params )
{
    g_deamon = true;
}

void help(void)
{
    const char* content =
        "\n"
        "usage: proxysvr [-p port] [-minp port] [-maxp port] [-cm number] [-l file]\n"
        "\n"
        "options:\n"
        "  -p=port, --bind-port=port\n"
        "  -minp=port, --min-proxy-port=port,         default 10000\n"
        "  -maxp=port, --max-proxy-port=port,         default 20000\n"
        "  -cm=NUM, --conn-max=NUM,                   default 4000\n"
        "  -l=file, --log4cxx=file\n"
        "\n"
        "example:\n"
        "  proxysvr --bind-port 8080 --min-proxy-port 10000\n"
        "  proxysvr -p 80 -minp 13000 -maxp 17000 -cm 4000 -l ./log4cxx.cnf\n"
        "\n";

    printf( content );
}

int main(int argc, char **argv)
{
    if ( argc <= 1 )
    {
        help();
        return 0;
    }

    //参数解释绑定
    theParamMgr.bind( "--bind-port", 1, ParamPort );        //绑定端口
    theParamMgr.bind( "-p", 1, ParamPort );

    theParamMgr.bind( "--min-proxy-port", 1, ParamMinPort );      //最小端口代理限制
    theParamMgr.bind( "-minp", 1, ParamMinPort );

    theParamMgr.bind( "--max-proxy-port", 1, ParamMaxPort );      //最大端口代理限制
    theParamMgr.bind( "-maxp", 1, ParamMaxPort );

    theParamMgr.bind( "--conn-max", 1, ParamConnMax );      //代理最大连接数接入限制
    theParamMgr.bind( "-cm", 1, ParamConnMax );

    theParamMgr.bind( "--deamon", 0, ParamDeamon );         //后台运行
    theParamMgr.bind( "-d", 0, ParamDeamon );

    theParamMgr.bind( "--log4cxx", 1, ParamLog );           //log4cxx配置文件
    theParamMgr.bind( "-l", 1, ParamLog );

    std::string param_error;
    if ( !theParamMgr.run( argc, argv, param_error ) )
    {
        LOG_ERROR( param_error.c_str() );
        exit(0);
    }

    if ( g_deamon )
    {
        if (-1 == daemon(1, 0))
            exit(EXIT_FAILURE);
    }

    theNet.StartThread();

    init_proxy();

    theNet.Timeout( 1, OnReleaseTimeout, NULL );

    for(;;)
    {
        LOG_INFO( "proxy connections %u/%u", g_conn_count, g_conn_max );

        sleep(300);
    }

    exit(0);
}

