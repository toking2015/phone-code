#ifndef _CNETIO_H_
#define _CNETIO_H_

#include "common.h"

#include <weedong/core/bstream/bstream.h>

#include "sys/socket.h"
#include "sys/types.h"
#include "arpa/inet.h"
#include "fcntl.h"
#include <netdb.h>

#define BASE_EPOLL_IS_INPUT_EVENT(event) ((event & EPOLLIN) != 0)
#define BASE_EPOLL_IS_OUTPUT_EVENT(event) ((event & EPOLLOUT) != 0)
#define BASE_EPOLL_IS_CLOSE_EVENT(event) ((event & (EPOLLHUP|EPOLLERR)) != 0)

class CNetIO : public wd::CThread
{
public:
    typedef void (*TCallback)(void*);
    typedef void (*TOnHostName)(void* p, uint32 hostname);
    typedef void (*TOnConnect)(void* p, int32 sock);
    typedef void (*TOnAccept)(void* p, int32 sock);
    typedef void (*TOnRead)(void* p, int32 sock, char* buff, int32 size);
    typedef void (*TOnTimeout)(void* p);

    enum
    {
        EUnknow = 0,
        EAccept = 1,
        EConnect = 2,
        ERead = 4,
        EWrite = 8,
    };

    enum
    {
        EPause = 1,     //暂停信号
        EPaused = 2,    //正在暂停
        EStop = 4,      //需要停止
        EStoped = 8,    //已经停止
    };

    class CNetConfig
    {
    public:
        int32 mode;
        int32 sock;

        void* cb;
        void* param;

        uint32 end_time;
        wd::CStream buff;

        sockaddr_in connect_remote;

        CNetConfig( int32 m, int32 s, void* c, void* p ) : mode(m), sock(s), cb(c), param(p)
        {
        }

        void add_mode( int32 m ){ mode |= m; }
        void clr_mode( int32 m ){ mode &= ~m; }
        bool has_mode( int32 m ){ return ( ( mode & m ) == m ); }
    };

    class CHostInfo
    {
    public:
        wd::thread_t thread;

        std::string host;
        CNetIO::TOnHostName cb;
        void* p;

        uint32 hostname;

        CHostInfo()
        {
            thread = 0;

            cb = NULL;
            p = NULL;
            hostname = 0;
        }
    };

    struct CNetTimeout
    {
        uint32 end_time;
        TOnTimeout timeout;
        void* param;
    };

private:
    int32 looper;
    uint32 thread_status;

    std::map< int32, CNetConfig* > sock_cnf;

    std::list< CHostInfo > host_list;
    std::list< CNetTimeout > timeout_list;

    wd::CMutex mutex;

public:
    CNetIO();
    ~CNetIO();

    uint32 Run();
    void EndThread();

    //addr "host:port"
    bool Connect( const char* addr, CNetIO::TOnConnect cb, void* p );
    uint16 Accept( const char* addr, CNetIO::TOnAccept cb, void* p );     //成功返回端口号, 错误返回0
    bool Read( int32 sock, CNetIO::TOnRead cb, void* p );
    bool Write( int32 sock, const void* data, int32 size, uint32 limit_size = 0 );
    void WriteNoWait( int32 sock, const void* data, int32 size );   //不压缓存, 直接发送, 不理会是否真正发送成功

    void Timeout( uint32 seconds, CNetIO::TOnTimeout cb, void* p );

    void Clear( int32 sock );

    void SendAndClose( uint32 seconds );    //等待发送完成并且关闭连接(用于退出进程)
    uint32 GetSendBuffLength( int32 sock = 0 );     //获取发送缓冲内容长度, sock == 0 为所有发送缓冲内容总长

    void Pause(void);   //暂停操作
    void Resume(void);  //恢复操作

private:
    void cb_connect( int32 sock, int32 revents );
    void cb_accept( int32 sock, int32 revents );
    void cb_rw( int32 sock, int32 revents );

    void cb_switch( int32 sock, int32 revents );

private:
    void control_epoll_mode( int32 sock, CNetConfig* config );

private:
    void add_config( CNetConfig *config );
    void remove_config( int32 sock );
    CNetConfig* get_config( int32 sock );

    void timeout_connect( int32 sock );

    void idle(void);

    int32 accept_init_sock(void);

public:
    static uint32 get_sock_addr( int32 sock );  //获取连接的IP地址
    static bool check_connected( int32 sock );       //检查连接是否正常
    static bool get_host_by_name( const char* host, CNetIO::TOnHostName cb, void* p );  //异步取出hostname

private:
    static uint32 get_host_by_name( const char* host );   //安全取出hostname
    static uint32 thread_get_host(void* p);             //线程取出hostname
    static void OnHostName( void* p, uint32 hostname );          //异步hostname回调
};

#define theNet TSignleton<CNetIO>::Ref()

#endif

