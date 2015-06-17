#ifndef _IMMORTAL_COMMON_NETSINGLE_H_
#define _IMMORTAL_COMMON_NETSINGLE_H_

#include "common.h"

//内网服务器双向自动连路基类, 特点如下:
//1) 目前只能作本机服务器间连路
//2) 通过配置 addr(非 host, 非 ip, 只是本机唯一的关键 key)进行自动连路
//3) 端口号均为随机分配, 无固定端口
//4) 只能作内网连接, 不允许外网接入
//5) 每个进程只绑定一个端口提供其它进程连接使用
//*********非线程安全,所有函数均在 netio 线程执行 **********/

struct SNetAddr
{
    char name[30];
    uint16 port;

    SNetAddr()
    {
        name[0] = '\0';
        port = 0;
    }
};
struct netsingle_connect_timeout;
class net
{
public:
    typedef void (*TErrorHandler)(std::string);

private:
    bool try_connect;
    int32 read_sock;        //接收sock
    int32 write_sock;       //发送sock
    std::string bind_addr;
    wd::CMutex mutex;

    //基础校验更新接口
    bool update_read_sock( int32 sock, int32 old_sock );
    bool update_write_sock( int32 sock, int32 old_sock );
public:
    net();
    virtual ~net();

    std::string GetName(void);
    bool IsConnected(void);

    //写数据
    void Write( void* data, uint32 size );

    //派生类接口
    void (*OnRead)( int32 sock, char* buff, int32 size );
    void (*OnConnect)(void);

//static
public:
    //启动内网连路
    //*********必要在所有派生 net Config() 调用之后**********//
    static void start( std::string net_hosts_file, std::string local_name, TErrorHandler handler = NULL );
    static void stop(void);

    //单点发送数据
    static void write( uint32 local_id, void* data, uint32 size );

    //所有服务器广播数据
    static void broadcast( void* data, uint32 size );

    static void set_net_read( std::string name, uint32 local_id, void(*call)(int32, char*, int32) );
    static void set_net_connect( std::string name, uint32 local_id, void(*call)(void) );

    //协议逻辑重现时不作发送处理
    static bool do_not_send_everything;

private:
    static TErrorHandler error_handler;

    static uint16& local_port(void);
    static bool AllConnected(void);

    static uint16 read_local_port( const char* name );                              //读取共享端口
    static void write_local_port( const char* name, uint16 port );                  //写入共享端口
    static void connect_addr( const char* addr, net* single );               //连接本地其它进程addr
    static void reconnect_addr( net* single, int32 old_sock );               //重连接
    static void cb_accept( void* param, int32 sock );                               //NetIO连入回调
    static void cb_connect( void* param, int32 sock );                              //NetIO连出回调
    static void cb_connect_timeout( void* param );                                  //NetIO连出超时
    static void cb_send_err( void* param, int32 sock, char* buff, int32 size );     //仅用于捕获write_sock错误
    static void cb_read_syn( void* param, int32 sock, char* buff, int32 size );     //三次握手
    static void cb_read_synack( void* param, int32 sock, char* buff, int32 size );  //同上
    static void cb_read_ack( void* param, int32 sock, char* buff, int32 size );     //同上
    static void cb_read( void* param, int32 sock, char* buff, int32 size );         //NetIO读数据回调

    static std::map< uint32, net* > single_map;                         //本进程入口地址记录
};

#endif

