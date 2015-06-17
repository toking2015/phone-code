#ifndef _MISC_H_
#define _MISC_H_

#include "msg.h"
#include "signalmgr.h"
#include "zlib/zlib.h"

#define ENCODE_KEY      0xD2
#define MSG_CMD(s) ( (s).msg_cmd )

//加载宏
#define SO_LOAD(n)\
void fn_so_load_##n(void);\
void* ptr_so_load_##n = proxy_cb( fn_so_load_##n );\
void fn_so_load_##n(void)

void* proxy_cb( void(*call)(void) );

//御载宏
class CProxyUnload
{
private:
    void(*foo)(void);
public:
    CProxyUnload( void(*f)(void) ) : foo(f){}
    ~CProxyUnload(){ foo(); }
};
#define SO_UNLOAD(n)\
void fn_so_unload_##n(void);\
CProxyUnload ref_so_unload_##n( fn_so_unload_##n );\
void fn_so_unload_##n(void)

//消息绑定
template<typename T>
void msg_cb( void* pMsg, void* func, int32 sock, int32 key )
{
    TRY_MACRO
    {
        ( (void(*)( T&, int32, int32 ))func )( *(T*)pMsg, sock, key );
    }
    CATCH_MACRO //这个宏和 TRY_MACRO 必顸配合使用, 不然会导致栈溢出
    {
        if ( theMsg.OnListenError != NULL )
            theMsg.OnListenError( (SMsgHead*)pMsg );
    }
    END_MACRO
}

template<typename T>
class CMsgListen
{
public:
    CMsgListen( void(&func)( T&, int32, int32 ) )
    {
        uint32 cmd = MSG_CMD( T() );
        theMsg.AddMsgListen( cmd, &msg_cb<T>, (void*)&func );
    }
};

#define MSG_FUNC( s )\
    void _msg_on_##s(s&, int32, int32);\
    CMsgListen< s > *_msg_reg_ptr_##s = new ((void*)~0)CMsgListen< s >( _msg_on_##s );\
    void _msg_on_##s(s& msg, int32 sock, int32 key)

#define SERVER_ID( role_id ) ( role_id / 1000000 )

//0xC0AB 就是 192.168
#define debug_ip(ip)\
    ( ( (ip) >> 16 ) == 0xC0A8 )

#define state_is( status, v )\
    ( ( status & (v) ) == (v) )
#define state_not( status, v )\
    ( !state_is( status, v ) )
#define state_add( status, v )\
    status |= (v)
#define state_del( status, v )\
    status &= ~(v)

//全局时间点(秒), 只要用来支持msg debug
extern uint32 global_debug_time;

//全局行为记录号
extern uint32 global_action;
#define bccopy( des, src )\
    (des).role_id = (src).role_id;\
    (des).session = (src).session;\
    (des).action = global_action;

//执行本地命令
std::vector< std::string > local_execute( const char* format, ... );

//数据库连接配置信息
struct SSqlConfig
{
    uint16          id;     //服务组id

    std::string     host;
    uint16          port;
    std::string     db;
    std::string     user;
    std::string     pwd;
};

struct SMd5Value
{
    union
    {
        uint8 digest[16];
        int32 values[4];
    };
    SMd5Value()
    {
        values[0] = 0;
        values[1] = 0;
        values[2] = 0;
        values[3] = 0;
    }
    SMd5Value( const SMd5Value& r )
    {
        values[0] = r.values[0];
        values[1] = r.values[1];
        values[2] = r.values[2];
        values[3] = r.values[3];
    }
    bool equal( const SMd5Value& value )
    {
        return values[0] == value.values[0]
            && values[1] == value.values[1]
            && values[2] == value.values[2]
            && values[3] == value.values[3];
    }
    bool operator == ( const SMd5Value& r )
    {
        return equal( r );
    }
    bool operator != ( const SMd5Value& r )
    {
        return !equal( r );
    }
};
SMd5Value md5_value( uint8* data, uint32 len );
std::string md5_string( uint8* data, uint32 len );

void timer_progress( uint32 LoopId, std::string& key, std::string& param, uint32 time_sec );

std::string escape( const void *ptr, const int32 size );
std::string escape( std::string str );

template<class T>
uint32 CompressData( T& object, wd::CStream& data )
{
    wd::CStream stream;
    stream << object;

    uint32 ret = stream.length();

    uLongf dst_size = compressBound( stream.length() );
    data.resize( dst_size );
    compress( &data[0], &dst_size, &stream[0], stream.length() );
    data.resize( dst_size );

    return ret;
}

#endif

