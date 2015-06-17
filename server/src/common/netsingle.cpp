#include "netsingle.h"

#include <fcntl.h>
#include <sys/file.h>

#include "systimemgr.h"
#include "netio.h"
#include "pack.h"
#include "log.h"

#define ERROR_ASSERT(e, msg)\
    if ( !(e) )\
    {\
        LOG_ERROR( "%s: %s", msg, strerror( errno ) );\
        exit(0);\
    }

//static var
net::TErrorHandler net::error_handler = NULL;

bool net::do_not_send_everything = false;
std::map< uint32, net* > net::single_map;
int32 __local_listen_sock = -1;
std::string __local_name;
std::string __net_hosts_file;

net::net()
{
    try_connect = false;

    read_sock = -1;
    write_sock = -1;

    OnRead = NULL;
    OnConnect = NULL;
}

net::~net()
{
    if ( read_sock > 0 )
    {
        theNet.Clear( read_sock );
        thePack.Clear( read_sock );
        close( read_sock );
    }
    if ( write_sock > 0 )
    {
        theNet.Clear( write_sock );
        close( write_sock );
    }
}

bool net::update_read_sock( int32 sock, int32 old_sock )
{
    wd::CGuard< wd::CMutex > safe( &mutex );
    if ( read_sock != old_sock )
    {
        LOG_ERROR( "update_read_sock_error[%s]: cur[%d] new[%d] old[%d]", bind_addr.c_str(), read_sock, sock, old_sock );
        return false;
    }
    else
        LOG_INFO( "update_read_sock[%s]: cur[%d] new[%d] old[%d]", bind_addr.c_str(), read_sock, sock, old_sock );

    read_sock = sock;
    return true;
}

bool net::update_write_sock( int32 sock, int32 old_sock )
{
    wd::CGuard< wd::CMutex > safe( &mutex );
    if ( write_sock != old_sock )
    {
        LOG_ERROR( "update_write_sock_error[%s]: cur[%d] new[%d] old[%d]", bind_addr.c_str(), write_sock, sock, old_sock );
        return false;
    }
    else
        LOG_INFO( "update_write_sock[%s]: cur[%d] new[%d] old[%d]", bind_addr.c_str(), write_sock, sock, old_sock );


    write_sock = sock;
    return true;
}

bool net::IsConnected(void)
{
    return ( write_sock > 0 && read_sock > 0);
}

std::string net::GetName(void)
{
    return bind_addr;
}

void net::Write( void* data, uint32 size )
{
    if ( do_not_send_everything )
        return;

    if ( write_sock <= 0 )
    {
        LOG_ERROR( "Write[%d]: %s", write_sock, bind_addr.c_str() );
        return;
    }

    theNet.Write( write_sock, data, size );
}

//static
void net::start( std::string net_hosts_file, std::string local_name, net::TErrorHandler handler )
{
    __net_hosts_file = net_hosts_file;
    __local_name = local_name;
    net::error_handler = handler;
    LOG_INFO( "local single: %s", __local_name.c_str() );

    //随机端口绑定
    local_port() = theNet.Accept( "localhost:13000-17000", cb_accept, NULL );
    if ( local_port() == 0 )
        THROW( "bind port error: %s", "13000-17000" );

    //写配置文件(阻塞)
    write_local_port( __local_name.c_str(), local_port() );

    //listen成功后开始连出
    for ( std::map< uint32, net* >::iterator iter = single_map.begin();
        iter != single_map.end();
        ++iter )
    {
        net* single = iter->second;
        single->try_connect = true;

        connect_addr( single->bind_addr.c_str(), single );
    }
}

//static
void net::stop(void)
{
    net::error_handler = NULL;

    theNet.Clear( __local_listen_sock );
    close( __local_listen_sock );

    __local_name.clear();
}

void net::write( uint32 local_id, void* data, uint32 size )
{
    std::map< uint32, net* >::iterator iter = single_map.find( local_id );
    if ( iter == single_map.end() )
        return;

    net* single = iter->second;

    single->Write( (char*)data, size );
}

void net::broadcast( void* data, uint32 size )
{
    for ( std::map< uint32, net* >::iterator iter = single_map.begin();
        iter != single_map.end();
        ++iter )
    {
        net* single = iter->second;

        single->Write( (char*)data, size );
    }
}

void net::set_net_read( std::string name, uint32 local_id, void(*call)(int32, char*, int32) )
{
    net* single = NULL;

    std::map< uint32, net* >::iterator iter = single_map.find( local_id );
    if ( iter == single_map.end() )
        single_map.insert( std::make_pair( local_id, ( single = new net ) ) );
    else
        single = iter->second;

    single->bind_addr = name;
    single->OnRead = call;

    if ( ( local_port() != 0 ) && !single->try_connect )
    {
        single->try_connect = true;
        connect_addr( single->bind_addr.c_str(), single );
    }
}

void net::set_net_connect( std::string name, uint32 local_id, void(*call)(void) )
{
    net* single = NULL;

    std::map< uint32, net* >::iterator iter = single_map.find( local_id );
    if ( iter == single_map.end() )
        single_map.insert( std::make_pair( local_id, ( single = new net ) ) );
    else
        single = iter->second;

    single->bind_addr = name;
    single->OnConnect = call;

    if ( ( local_port() != 0 ) && !single->try_connect )
    {
        single->try_connect = true;
        connect_addr( single->bind_addr.c_str(), single );
    }
}

uint16& net::local_port(void)
{
    static uint16 port = 0;

    return port;
}

bool net::AllConnected(void)
{
    for ( std::map< uint32, net* >::iterator iter = single_map.begin();
        iter != single_map.end();
        ++iter )
    {
        if ( !iter->second->IsConnected() )
            return false;
    }

    return true;
}

uint16 net::read_local_port( const char* name )
{
    int file = open( __net_hosts_file.c_str(), O_RDONLY );
    if ( file <= 0 )
        return 0;

    int res = flock( file, LOCK_SH );
    if ( res != 0 )
        return 0;

    off_t offset = lseek( file, 0, SEEK_SET );
    int32 size = (int32)lseek( file, 0, SEEK_END );
    offset = lseek( file, 0, SEEK_SET );

    if ( size <= 0 )
        return 0;

    char* buff = new char[size + 1];
    ERROR_ASSERT( read( file, buff, size ) == size, "read_local_port-read" );

    buff[ size ] = '\0';
    char* saveptr = NULL;
    char* line = strtok_r( buff, "\n", &saveptr );

    SNetAddr addr;
    do
    {
        if ( sscanf( line, "%[^ ] %hu", addr.name, &addr.port ) == 2 )
        {
            if ( strcmp( addr.name, name ) == 0 )
                break;
        }

        addr.port = 0;
        line = strtok_r( NULL, "\n", &saveptr );
    }
    while( line != NULL && line[0] != '\0' );
    delete[] buff;

    ERROR_ASSERT( flock( file, LOCK_UN ) == 0, "write_local_port-flock-LOCK_UN" );

    close( file );

    return addr.port;
}

void net::write_local_port( const char* name, uint16 port )
{
    int file = open( __net_hosts_file.c_str(), O_CREAT | O_RDWR );
    ERROR_ASSERT( file > 0, "write_lock_port-open" );

    int res = flock( file, LOCK_EX );
    ERROR_ASSERT( res == 0, "write_lock_port-flock" );

    off_t offset = lseek( file, 0, SEEK_SET );
    int32 size = (int32)lseek( file, 0, SEEK_END );
    offset = lseek( file, 0, SEEK_SET );

    std::list< SNetAddr > addr_list;
    if ( size > 0 )
    {
        char* buff = new char[size + 1];
        ERROR_ASSERT( read( file, buff, size ) == size, "write_local_port-read" );

        buff[ size ] = '\0';

        char* save_ptr = NULL;
        char* line = strtok_r( buff, "\n", &save_ptr );
        do
        {
            SNetAddr addr;
            if ( sscanf( line, "%[^ ] %hu", addr.name, &addr.port ) == 2 )
            {
                if ( addr.name != __local_name )
                    addr_list.push_back( addr );
            }

            line = strtok_r( NULL, "\n", &save_ptr );
        }
        while( line != NULL && line[0] != '\0' );

        delete[] buff;
    }

    SNetAddr addr;
    snprintf( addr.name, sizeof( addr.name ), "%s", name );
    addr.port = port;

    addr_list.push_back( addr );

    offset = lseek( file, 0, SEEK_SET );

    for ( std::list< SNetAddr >::iterator iter = addr_list.begin();
        iter != addr_list.end();
        ++iter )
    {
        char buff[256];
        size = snprintf( buff, sizeof( buff ) - 1, "%s %hu\n", iter->name, iter->port );
        ::write( file, buff, size );
    }

    ERROR_ASSERT( flock( file, LOCK_UN ) == 0, "write_local_port-flock-LOCK_UN" );

    close( file );

    LOG_INFO( "update %s: %s %hu", __net_hosts_file.c_str(), name, port );
}

void net::connect_addr( const char* addr, net* single )
{
    if ( !single->update_write_sock( 0, -1 ) )
        return;

    uint16 port = read_local_port( addr );

    char buff[64] = {0};
    snprintf( buff, sizeof( buff ) - 1, "localhost:%hu", port );

    LOG_INFO( "try connect to[%hu]: %s", port, addr );
    theNet.Connect( buff, cb_connect, single );
}

void net::reconnect_addr( net* single, int32 old_sock )
{
    if ( __local_name.empty() )
        return;

    if ( single->update_write_sock( -1, old_sock ) )
        theNet.Timeout( 3, cb_connect_timeout, single );
}

//共享连入
void net::cb_accept( void* param, int32 sock )
{
    if ( sock <= 0 )
        return;

    __local_listen_sock = sock;

    //放置待连接区域
    theNet.Read( sock, cb_read_syn, param );

    //发送认证
    theNet.Write( sock, __local_name.c_str(), __local_name.length() );

    LOG_INFO( "syn < %d", sock );
}

//连出
void net::cb_connect_timeout( void* param )
{
    if ( __local_name.empty() )
        return;

    net* single = (net*)param;
    connect_addr( single->bind_addr.c_str(), single );
}
void net::cb_connect( void* param, int32 sock )
{
    net* single = (net*)param;

    if ( sock <= 0 )
    {
        if ( net::error_handler != NULL )
            net::error_handler( "connect " + single->bind_addr + " failed!" );
        reconnect_addr( single, 0 );
        return;
    }

    //设置待连接区域
    LOG_INFO( "synack > %s", single->bind_addr.c_str() );
    theNet.Read( sock, cb_read_synack, single );
}

void net::cb_send_err( void* param, int32 sock, char* buff, int32 size )
{
    theNet.Read( sock, NULL, NULL );

    net* single = (net*)param;

    close( sock );

    if ( net::error_handler != NULL )
        net::error_handler( single->bind_addr + " disconnect!" );
    reconnect_addr( single, sock );

    LOG_INFO( "%s !>> %s", __local_name.c_str(), single->bind_addr.c_str() );
}

struct net_single_find_name
{
    std::string name;
    net_single_find_name( std::string n ) : name(n){}

    bool operator()( std::pair< uint32, net* > pair )
    {
        return ( pair.second->GetName() == name );
    }
};
void net::cb_read_syn( void* param, int32 sock, char* buff, int32 size )
{
    theNet.Read( sock, NULL, NULL );

    if ( buff == NULL || size <= 0 )
    {
        close( sock );
        return;
    }

    std::map< uint32, net* >::iterator iter =
        std::find_if( single_map.begin(), single_map.end(), net_single_find_name( std::string( buff, size ) ) );

    if ( iter == single_map.end() )
    {
        close( sock );
        return;
    }

    net* single = iter->second;

    //更新 read_sock
    if ( !single->update_read_sock( sock, -1 ) )
    {
        close( sock );
        return;
    }

    //放置连接区域
    theNet.Read( sock, cb_read, single );

    //设置端口并重发认证
    theNet.Write( sock, __local_name.c_str(), __local_name.length() );

    LOG_INFO( "%s << %s", __local_name.c_str(), single->bind_addr.c_str() );

    if ( single->read_sock > 0 && single->write_sock > 0 )
        single->OnConnect();
}

void net::cb_read_synack( void* param, int32 sock, char* buff, int32 size )
{
    theNet.Read( sock, NULL, NULL );

    net* single = (net*)param;

    //容错判定
    if ( buff == NULL || size <= 0 || std::string( buff, size ) != single->bind_addr )
    {
        close( sock );

        if ( net::error_handler != NULL )
            net::error_handler( single->bind_addr + " reset at synack!" );
        reconnect_addr( single, 0 );
        return;
    }

    //设置确认区域
    theNet.Read( sock, cb_read_ack, single );

    //发送认证
    theNet.Write( sock, __local_name.c_str(), __local_name.length() );

    //LOG_INFO( "ack > %s %d %u", single->bind_addr.c_str(), sock, *(uint32*)&param );
}

void net::cb_read_ack( void* param, int32 sock, char* buff, int32 size )
{
    theNet.Read( sock, NULL, NULL );

    net* single = (net*)param;

    //容错判定
    if ( buff == NULL || size <= 0 || std::string( buff, size ) != single->bind_addr )
    {
        close( sock );
        if ( net::error_handler != NULL )
            net::error_handler( single->bind_addr + " reset at ack!" );
        reconnect_addr( single, 0 );
        return;
    }

    //已绑定连接判定
    if ( !single->update_write_sock( sock, 0 ) )
    {
        close( sock );
        return;
    }

    //设置错误区域
    theNet.Read( sock, cb_send_err, single );

    LOG_INFO( "%s >> %s", __local_name.c_str(), single->bind_addr.c_str() );

    if ( single->read_sock > 0 && single->write_sock > 0 )
        single->OnConnect();
}

void net::cb_read( void* param, int32 sock, char* buff, int32 size )
{
    net* single = (net*)param;

    if ( buff == NULL || size <= 0 )
    {
        single->update_read_sock( -1, sock );

        theNet.Clear( sock );
        thePack.Clear( sock );

        close( sock );

        LOG_INFO( "%s !<< %s", __local_name.c_str(), single->bind_addr.c_str() );
        return;
    }

    single->OnRead( sock, buff, size );
}

