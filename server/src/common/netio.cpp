#include "netio.h"

#include <sys/epoll.h>

#include "log.h"
#include "misc.h"

#define SET_NON_BLOCK(s)\
    {\
        int32 flags;\
        flags = fcntl(s, F_GETFL);\
        flags |= O_NONBLOCK;\
        fcntl(s, F_SETFL, flags );\
    }
#define CLEAR_CONFIG(c)\
    {\
        for ( std::map< int32, CNetConfig* >::iterator iter = c.begin();\
            iter != c.end();\
            ++iter )\
        {\
            delete iter->second;\
        }\
        c.clear();\
    }

uint32 netio_seed = (uint32)time(NULL);

CNetIO::CNetIO()
{
    looper = epoll_create( 8192 );

    thread_status = 0;
}

CNetIO::~CNetIO()
{
    for ( std::map< int32, CNetConfig* >::iterator iter = sock_cnf.begin();
        iter != sock_cnf.end();
        ++iter )
    {
        delete iter->second;
    }

    close( looper );
}

uint32 CNetIO::Run()
{
    epoll_event events[64];

    while ( state_not( thread_status, CNetIO::EStop ) )
    {
        if ( state_is( thread_status, CNetIO::EPause ) )
        {
            state_add( thread_status, CNetIO::EPaused );
            state_del( thread_status, CNetIO::EPause );
            continue;
        }

        if ( state_is( thread_status, CNetIO::EPaused ) )
        {
            wd::thread_sleep(100);
            continue;
        }

        int32 count = epoll_wait( looper, events, sizeof( events ) / sizeof ( epoll_event ), 100 );
        if ( count == 0 )
        {
            idle();
            continue;
        }

        if ( count == -1 )
        {
            if ( errno == EINTR )
                continue;

            LOG_DEBUG( "epoll_wait error[%d]:%s", errno, strerror( errno ) );
            break;
        }

        for ( int i=0; i<count; ++i )
        {
            int32 sock = events[i].data.fd;
            int32 revents = 0;

            //关闭事件处理
            if ( BASE_EPOLL_IS_CLOSE_EVENT( events[i].events ) )
            {
                CNetIO::TOnRead cb = NULL;
                void* param = NULL;
                {
                    wd::CGuard<wd::CMutex> safe( &mutex );

                    //取消事件监听
                    control_epoll_mode( sock, NULL );

                    CNetConfig* config = get_config( sock );
                    if ( config == NULL )
                        continue;

                    //读事件监听回调通知
                    if ( config->has_mode( ERead ) )
                    {
                        cb = (CNetIO::TOnRead)config->cb;
                        param = config->param;
                    }

                    remove_config( sock );
                    delete config;
                }

                //回调读数据错误
                if ( cb != NULL )
                    cb( param, sock, NULL, 0 );
                continue;
            }

            //读写事件处理
            if ( BASE_EPOLL_IS_INPUT_EVENT( events[i].events ) )
                revents |= ERead;
            if ( BASE_EPOLL_IS_OUTPUT_EVENT( events[i].events ) )
                revents |= EWrite;

            cb_switch( sock, revents );
        }

        idle();
    }

    return 0;
}

void CNetIO::EndThread()
{
    state_add( thread_status, CNetIO::EStop );

    wd::thread_wait_exit( GetHandle() );
}

struct SConnectInfo
{
    int32 sock;
    int32 port;
    void* param;
    CNetIO::TOnConnect cb;
};
void CNetIO::OnHostName( void* p, uint32 hostname )
{
    SConnectInfo info = *(SConnectInfo*)p;
    delete (SConnectInfo*)p;

    //设置连接地址
    struct sockaddr_in remote;
    remote.sin_family = AF_INET;
    remote.sin_addr.s_addr = hostname;
    remote.sin_port = htons( info.port );

    int32 ret = connect( info.sock, (struct sockaddr*)&remote, sizeof(remote) );
    if ( 0 == ret && 0 )
    {
        if ( NULL != info.cb )
            info.cb( info.param, info.sock );
        return;
    }

    if ( 0 != ret && EINPROGRESS != errno )
    {
        if ( NULL != info.cb )
            info.cb( info.param, -1 );
        close( info.sock );
        return;
    }

    wd::CGuard<wd::CMutex> safe( &theNet.mutex );

    CNetConfig *config = new CNetIO::CNetConfig( EConnect, info.sock, (void*)info.cb, info.param );
    config->end_time = time(NULL) + 5;
    config->connect_remote = remote;

    theNet.add_config( config );
    theNet.control_epoll_mode( info.sock, config );
}
bool CNetIO::Connect( const char* addr, CNetIO::TOnConnect cb, void* param )
{
    char host[256];
    int32 port;
    if ( 2 != sscanf( addr, "%[^:]:%d", host, &port ) || port == 0 )
    {
        if ( NULL != cb )
            cb( param, -1 );
        return false;
    }

    int32 sock = socket( PF_INET, SOCK_STREAM, 0 );
    if ( sock < 0 )
    {
        if ( NULL != cb )
            cb( param, -1 );
        return false;
    }

    SET_NON_BLOCK(sock);

    //分配参数
    SConnectInfo* pInfo = new SConnectInfo;
    pInfo->sock = sock;
    pInfo->port = port;
    pInfo->param = param;
    pInfo->cb = cb;

    if ( !get_host_by_name( host, OnHostName, pInfo ) )
    {
        delete pInfo;
        if ( NULL != cb )
            cb( param, -1 );
        return false;
    }
    return true;
}

int32 CNetIO::accept_init_sock(void)
{
    int32 sock = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP );
    if ( sock < 0 )
    {
        LOG_ERROR( "accept sock create error[%d]: %s", errno, strerror( errno ) );
        return 0;
    }

    SET_NON_BLOCK(sock);

    //地址重用
    int32 reuse = 1;
    if ( 0 != setsockopt( sock, SOL_SOCKET, SO_REUSEADDR, (const char*)&reuse, sizeof(reuse) ) )
    {
        LOG_ERROR( "accept setsockopt error[%d]: %s", errno, strerror( errno ) );
        close( sock );
        return 0;
    }

    return sock;

}
uint16 CNetIO::Accept( const char* addr, CNetIO::TOnAccept cb, void* param )
{
    char host[256] = {0};
    char port[64] = {0};
    if ( 2 != sscanf( addr, "%[^:]:%s", host, port ) )
    {
        host[0] = '\0';
        if ( 1 != sscanf( addr, "%s", port ) )
        {
            LOG_ERROR( "parse addr error: %s", addr );
            return 0;
        }
    }
    if ( port[0] == '\0' )
    {
        LOG_ERROR( "parse port error" );
        return 0;
    }

    uint16 min = 0, max = 0;
    uint32 nargs = sscanf( port, "%hu-%hu", &min, &max );

    if ( nargs == 0 )
    {
        LOG_ERROR( "parse port args error: count[%d]", nargs );
        return 0;
    }


    int32 sock = 0;
    uint16 accept_port = 0;

    //端口绑定
    switch ( nargs )
    {
    case 1:
        {
            //创建sock
            sock = accept_init_sock();
            if ( sock == 0 )
                return 0;

            accept_port = min;

            //初始化绑定数据
            struct sockaddr_in local;
            local.sin_family = AF_INET;

            if ( host[0] == '\0' )
                local.sin_addr.s_addr = htonl( INADDR_ANY );
            else
                local.sin_addr.s_addr = get_host_by_name( host );

            local.sin_port = htons( accept_port );

            //绑定地址
            if ( 0 != bind( sock, (struct sockaddr*)&local, sizeof( sockaddr_in ) ) )
            {
                LOG_ERROR( "accept bind port[%d] error[%d]: %s", accept_port, errno, strerror( errno ) );
                close( sock );
                return 0;
            }

            //开始监听
            if ( 0 != listen( sock, 5 ) )
            {
                LOG_ERROR( "accept listen port[%d] error[%d]: %s", accept_port, errno, strerror( errno ) );
                close( sock );
                return 0;
            }
        }
        break;
    case 2:
        {
            for (;;)
            {
                //关闭sock
                if ( sock != 0 )
                    close( sock );

                //重建sock
                sock = accept_init_sock();
                if ( sock == 0 )
                    return 0;

                accept_port = (uint16)( min + rand_r( &netio_seed ) / (RAND_MAX + 1.0f) * (max - min) );

                //初始化绑定数据
                struct sockaddr_in local;
                local.sin_family = AF_INET;

                if ( host[0] == '\0' )
                    local.sin_addr.s_addr = htonl( INADDR_ANY );
                else
                    local.sin_addr.s_addr = get_host_by_name( host );

                local.sin_port = htons( accept_port );

                //可能会存在多个线程同时 bind 同一个端口成功, 但在 listen 时出错的现象
                //但 listen 出错后, 由于 bind 是成功的, 再次 bind 其它端口会继续报错
                //所以只有 close sock, 再次重建全新 sock 来进行 bind,listen 重试
                if ( 0 != bind( sock, (struct sockaddr*)&local, sizeof( sockaddr_in ) ) )
                {
                    LOG_ERROR( "accept bind port[%d] continue[%d]: %s", accept_port, errno, strerror( errno ) );
                    wd::thread_sleep(100);
                    continue;
                }

                //开始监听
                if ( 0 != listen( sock, 5 ) )
                {
                    if ( errno != 98 )
                    {
                        LOG_ERROR( "accept listen error[%d]: %s", errno, strerror( errno ) );
                        return 0;
                    }

                    LOG_ERROR( "accept listen port[%d] continue[%d]: %s", accept_port, errno, strerror( errno ) );
                    wd::thread_sleep(100);
                    continue;
                }

                break;
            }
        }
        break;
    default:
        LOG_ERROR( "accept unknow case[%d] addr: %s", nargs, addr );
        close( sock );
        return 0;
    }

    wd::CGuard<wd::CMutex> safe( &mutex );

    CNetConfig *config = new CNetIO::CNetConfig( EAccept, sock, (void*)cb, param );
    add_config( config );
    control_epoll_mode( sock, config );

    return accept_port;
}

void loot_read( int32 sock, CNetIO::TOnRead cb, void* param )
{
    char buff[1024];
    int32 size = 0;

    do
    {
        size = recv( sock, buff, sizeof( buff ), MSG_DONTWAIT );
        if ( size != -1 || errno != EAGAIN )
        {
            cb( param, sock, buff, size );
        }
    }
    while( size > 0 );
}
bool CNetIO::Read( int32 sock, CNetIO::TOnRead cb, void* param )
{
    wd::CGuard<wd::CMutex> safe( &mutex );

    CNetConfig* config = get_config( sock );

    //remove read event
    if ( NULL == cb )
    {
        if ( config != NULL )
        {
            config->clr_mode( ERead );
            control_epoll_mode( sock, config );
            if ( !config->has_mode( EWrite ) )
            {
                remove_config( sock );
                delete config;
            }
        }
        return true;
    }

    if ( config == NULL )
        add_config( config = new CNetIO::CNetConfig( ERead, sock, (void*)cb, param ) );
    else
    {
        config->add_mode( ERead );

        config->cb = (void*)cb;
        config->param = param;
    }

    control_epoll_mode( sock, config );
    //尝试直接读取当前缓存数据
    //loot_read( sock, cb, param );

    return true;
}

bool CNetIO::Write( int32 sock, const void* data, int32 size, uint32 limit_size )
{
    if (-1 == sock)
        return false;

    //if ( !check_connected( sock ) )
    //    return false;

    wd::CGuard<wd::CMutex> safe( &mutex );

    CNetConfig *config = get_config( sock );

    /*
       Write 和 Epoll 接口可能存在线程安全问题, 完全加锁得不偿失
    //尝试直接 send, 不通过 buff copy
    if ( config == NULL || !config->has_mode( EWrite ) )
    {
        int32 sendlen = send( sock, data, size, MSG_DONTWAIT );
        if ( sendlen == size )
            return true;

        if ( sendlen <= 0 )
            return false;

        if ( sendlen > 0 )
        {
            size -= sendlen;
            (char*&)data += sendlen;
        }
    }
    */

    if ( config == NULL )
        add_config( config = new CNetConfig( EWrite, sock, NULL, NULL ) );
    else
        config->add_mode( EWrite );

    if ( 0 != limit_size && config->buff.length() > limit_size )
        return false;

    config->buff.position( config->buff.length() );
    config->buff.write( data, size );

    control_epoll_mode( sock, config );

    return true;
}

void CNetIO::WriteNoWait( int32 sock, const void* data, int32 size )
{
    if (-1 == sock)
        return;

    if ( !check_connected( sock ) )
        return;

    send( sock, data, size, MSG_DONTWAIT );

    return;
}

void CNetIO::Timeout( uint32 seconds, CNetIO::TOnTimeout cb, void* p )
{
    CNetTimeout timeout = { time(NULL) + seconds, cb, p };

    wd::CGuard<wd::CMutex> safe( &mutex );
    timeout_list.push_back( timeout );
}

void CNetIO::Clear( int32 sock )
{
    wd::CGuard<wd::CMutex> safe( &mutex );

    CNetConfig *config = get_config( sock );
    if ( config == NULL )
        return;

    remove_config( sock );
    control_epoll_mode( sock, NULL );

    delete config;
}

void CNetIO::SendAndClose( uint32 seconds )
{
    uint32 end_time = time(NULL) + seconds;

    //等待逻辑发送缓冲清空 或者 超时
    while ( GetSendBuffLength() > 0 && ( seconds == 0 || time(NULL) < end_time ) )
        sleep(1);

    //带有超时关闭的服务不保证所有数据都发送成功(目前只有access使用超时限制)
    if ( seconds > 0 )
        return;

    //移除所有sock连接
    std::list< int32 > socket_list;
    {
        wd::CGuard<wd::CMutex> safe( &mutex );
        for ( std::map< int32, CNetConfig* >::iterator iter = sock_cnf.begin();
            iter != sock_cnf.end();
            ++iter )
        {
            int32 sock = iter->first;
            CNetConfig* config = iter->second;

            control_epoll_mode( sock, NULL );
            delete config;

            socket_list.push_back( sock );
        }
        sock_cnf.clear();
    }

    sleep(1);

    //关闭所有sock
    for ( std::list< int32 >::iterator iter = socket_list.begin();
        iter != socket_list.end();
        ++iter )
    {
        int32 sock = (*iter);

        //设置发送完成后才会阻塞关闭
        struct linger so_linger = {0};
        so_linger.l_onoff = 1;
        so_linger.l_linger = 5;

        if ( setsockopt( sock, SOL_SOCKET, SO_LINGER, &so_linger, sizeof( so_linger ) ) )
            LOG_ERROR( strerror( errno ) );

        close( sock );
    }

    sleep(1);
}

uint32 CNetIO::GetSendBuffLength( int32 sock/* = 0*/ )
{
    wd::CGuard<wd::CMutex> safe( &mutex );

    uint32 length = 0;
    if ( sock == 0 )
    {
        for ( std::map< int32, CNetConfig* >::iterator iter = sock_cnf.begin();
            iter != sock_cnf.end();
            ++iter )
        {
            if ( !check_connected( iter->first ) )
                continue;

            CNetConfig* config = iter->second;
            if ( config != NULL )
                length += config->buff.length();
        }
    }
    else
    {
        std::map< int32, CNetConfig* >::iterator iter = sock_cnf.find( sock );
        if ( iter == sock_cnf.end() )
            return 0;

        CNetConfig* config = iter->second;
        if ( config != NULL )
            length = config->buff.length();
    }

    return length;
}

void CNetIO::Pause(void)
{
    state_add( thread_status, EPause );
    while ( state_not( thread_status, EPaused ) )
        wd::thread_sleep(100);
}
void CNetIO::Resume(void)
{
    state_del( thread_status, EPaused );
}

void CNetIO::cb_accept( int32 sock, int32 revents )
{
    CNetIO::TOnAccept cb = NULL;
    void* param = NULL;
    {
        wd::CGuard<wd::CMutex> safe( &mutex );

        CNetConfig *config = get_config( sock );

        cb = (CNetIO::TOnAccept)config->cb;
        param = config->param;
    }

    if ( revents & ERead )
    {
        int32 link = -1;

        do
        {
            link = accept( sock, NULL, NULL );
            if ( link > 0 )
            {
                SET_NON_BLOCK( link );
                cb( param, link );
            }
        }
        while( link > 0 );
    }
}

void CNetIO::cb_rw( int32 sock, int32 revents )
{
    CNetIO::TOnRead cb = NULL;
    void* param = NULL;
    {
        wd::CGuard<wd::CMutex> safe( &mutex );

        CNetConfig* config = get_config( sock );
        if ( config == NULL )
            return;

        if ( revents & EWrite )
        {
            if ( config->buff.length() > 0 )
            {
                int32 size = 0;

                for (;;)
                {
                    size = send( sock, &config->buff[0], config->buff.length(), MSG_DONTWAIT );

                    if ( size <= 0 )
                    {
                        if ( errno != EAGAIN && errno != ENOBUFS )
                            config->buff.clear();

                        break;
                    }
                    else
                    {
                        config->buff.position( size );
                        config->buff.erase();
                    }
                }
            }

            if ( config->buff.length() <= 0 )
            {
                config->clr_mode( EWrite );
                control_epoll_mode( sock, config );

                if ( !config->mode )
                {
                    remove_config( sock );
                    delete config;

                    return;
                }
            }
        }

        if ( revents & ERead )
        {
            cb = (CNetIO::TOnRead)config->cb;
            param = config->param;
        }

    }

    if ( NULL != cb )
        loot_read( sock, cb, param );
}

void CNetIO::cb_switch( int32 sock, int32 revents )
{
    void (CNetIO::*cb)( int32, int32 );
    {
        wd::CGuard<wd::CMutex> safe( &mutex );

        CNetConfig* config = get_config( sock );
        if ( config == NULL )
        {
            control_epoll_mode( sock, NULL );
            return;
        }

        if ( config->has_mode( EAccept ) )
            cb = &CNetIO::cb_accept;
        else if ( config->has_mode( ERead ) || config->has_mode( EWrite ) )
            cb = &CNetIO::cb_rw;
        else
            cb = &CNetIO::cb_rw;
    }

    ( this->*cb )( sock, revents );
}

void CNetIO::control_epoll_mode( int32 sock, CNetConfig* config )
{
    struct epoll_event ev = {0};
    ev.data.fd = sock;

    if ( config == NULL )
    {
        epoll_ctl( looper, EPOLL_CTL_DEL, sock, &ev );
        return;
    }

    if ( config->has_mode( EAccept ) )
        ev.events = EPOLLIN;
    if ( config->has_mode( ERead ) )
        ev.events |= EPOLLIN;
    if ( config->has_mode( EWrite ) )
        ev.events |= EPOLLOUT;

    if ( !ev.events )
    {
        epoll_ctl( looper, EPOLL_CTL_DEL, sock, &ev );
        return;
    }

    if ( epoll_ctl( looper, EPOLL_CTL_MOD, sock, &ev ) == 0 )
        return;

    epoll_ctl( looper, EPOLL_CTL_ADD, sock, &ev );
}

void CNetIO::add_config( CNetConfig *config )
{
    std::map< int32, CNetConfig* >::iterator iter = sock_cnf.find( config->sock );
    if ( iter != sock_cnf.end() )
        LOG_DEBUG( "add_config sock[%d] exist!", config->sock );

    sock_cnf[ config->sock ] = config;
    LOG_DEBUG( "add_config sock[%d]!", config->sock );
}

void CNetIO::remove_config( int32 sock )
{
    std::map< int32, CNetConfig* >::iterator iter = sock_cnf.find( sock );
    if ( iter != sock_cnf.end() )
    {
        LOG_DEBUG( "remove_config sock[%d]!", iter->second->sock );
        sock_cnf.erase( iter );
    }
}

CNetIO::CNetConfig* CNetIO::get_config( int32 sock )
{
    std::map< int32, CNetConfig* >::iterator iter = sock_cnf.find( sock );
    if ( iter != sock_cnf.end() )
        return iter->second;

    return NULL;
}

void CNetIO::timeout_connect( int32 sock )
{
    CNetIO::TOnConnect cb = NULL;
    void* param = NULL;
    {
        wd::CGuard< wd::CMutex > safe( &mutex );

        CNetConfig *config = get_config( sock );
        if ( config == NULL )
            return;

        cb = ( CNetIO::TOnConnect )config->cb;
        param = config->param;

        remove_config( sock );
        control_epoll_mode( sock, NULL );
        delete config;
    }

    close( sock );
    cb( param, -1 );
}

void CNetIO::idle(void)
{
    uint32 time_now = time(NULL);

    //异步 hostname 处理
    std::list< CHostInfo > host_progress_list;
    {
        wd::CGuard<wd::CMutex> safe( &mutex );
        host_progress_list.swap( host_list );
    }
    for ( std::list< CHostInfo >::iterator iter = host_progress_list.begin();
        iter != host_progress_list.end();
        ++iter )
    {
        iter->cb( iter->p, iter->hostname );
    }

    //其它处理
    std::list< int32 > timeout_connnect_list;
    std::list< CNetTimeout > remove_timeout_list;
    std::list< CNetConfig* > connected_list;
    {
        wd::CGuard<wd::CMutex> safe( &mutex );

        for ( std::map< int32, CNetConfig* >::iterator iter = sock_cnf.begin();
            iter != sock_cnf.end();
            ++iter )
        {
            CNetConfig* config = iter->second;
            if ( !config->has_mode( EConnect ) )
                continue;

            if ( check_connected( config->sock ) )
            {
                if ( 0 == connect( config->sock, (struct sockaddr*)&config->connect_remote, sizeof(config->connect_remote) ) )
                    connected_list.push_back( config );

                continue;
            }

            if ( time_now > config->end_time )
                timeout_connnect_list.push_back( iter->first );
        }

        for ( std::list< CNetTimeout >::iterator iter = timeout_list.begin();
            iter != timeout_list.end(); )
        {
            if ( time_now > iter->end_time )
            {
                remove_timeout_list.push_back( *iter );
                iter = timeout_list.erase( iter );
            }
            else
                ++iter;
        }
    }

    for ( std::list< CNetConfig* >::iterator iter = connected_list.begin();
        iter != connected_list.end();
        ++iter )
    {
        CNetConfig *config = (*iter);

        control_epoll_mode( config->sock, NULL );
        remove_config( config->sock );

        ( (CNetIO::TOnConnect)config->cb )( config->param, config->sock );

        delete config;
    }

    for ( std::list< int32 >::iterator iter = timeout_connnect_list.begin();
        iter != timeout_connnect_list.end();
        ++iter )
    {
        timeout_connect( *iter );
    }

    for ( std::list< CNetTimeout >::iterator iter = remove_timeout_list.begin();
        iter != remove_timeout_list.end();
        ++iter )
    {
        iter->timeout( iter->param );
    }
}

//static
uint32 CNetIO::get_sock_addr( int32 sock )
{
    sockaddr_in sockaddr = {0};
    socklen_t socklen = sizeof( sockaddr );
    getpeername( sock, (struct sockaddr*)&sockaddr, &socklen );
    return ntohl( sockaddr.sin_addr.s_addr );
}

bool CNetIO::check_connected( int32 sock )
{
    int optval = -1;
    socklen_t optlen = sizeof( optval );

    getsockopt( sock, SOL_SOCKET, SO_ERROR, (char*)&optval, &optlen );

    return ( optval == 0 );
}

uint32 CNetIO::thread_get_host(void* p)
{
    pthread_detach(pthread_self());

    CNetIO::CHostInfo* pInfo = (CHostInfo*)p;

    pInfo->hostname = CNetIO::get_host_by_name( pInfo->host.c_str() );
    {
        wd::CGuard<wd::CMutex> safe( &theNet.mutex );
        theNet.host_list.push_back( *pInfo );
    }
    delete pInfo;

    return 0;
}
bool CNetIO::get_host_by_name( const char* host, CNetIO::TOnHostName cb, void* p )
{
    CNetIO::CHostInfo* pInfo = new CNetIO::CHostInfo;
    pInfo->host = host;
    pInfo->cb = cb;
    pInfo->p = p;

    if ( wd::thread_create( &pInfo->thread, CNetIO::thread_get_host, pInfo ) != 0 )
    {
        delete pInfo;
        return false;
    }

    return true;
}

uint32 CNetIO::get_host_by_name( const char* host )
{
    struct hostent content, *result = NULL;
    int errcode = 0;

    char buff[512];
    if ( 0 != gethostbyname_r( host, &content, buff, sizeof( buff ) - 1, &result, &errcode ) )
        return 0;

    if ( result == NULL )
        return 0;

    return *(uint32 *)result->h_addr;
}

#undef CLEAR_CONFIG
#undef SET_NON_BLOCK

