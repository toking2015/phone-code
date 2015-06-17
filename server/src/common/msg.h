#ifndef _CMSG_H_
#define _CMSG_H_

#include "common.h"

#include <weedong/core/dispatch/disp.h>

class SMsgHead;
class CMsg : public wd::CThread
{
public:
    typedef void (*FMsg)(void* msg, void* func, int32 sock, int32 key);
    typedef std::pair< FMsg, void* > FMsgPro;
    typedef SMsgHead*(* FMsgTrans)(wd::CStream&);

    struct TMsgData
    {
        int32 sock;
        int32 key;
        wd::CStream* stream;

        TMsgData() : sock(0), key(0), stream(NULL)
        {
        }

        TMsgData( int32 s, int32 k, wd::CStream* str ) : sock(s), key(k), stream(str)
        {
        }
    };

private:
    enum
    {
        EStop = 1,
    };

    //协议记录文件
    FILE* msg_read_file;
    int32 msg_write_file;

    wd::CMutex m_mutex;

    //用于记录协议过程数据
    std::vector<char> msg_buffer;

    //保存对应协议函数回调接口
    std::map< uint32, FMsgPro > msg_pro_map;

    //屏弊处理
    std::set< uint32 > msg_block_set;

    //消息队列
    std::list< TMsgData > msg_list;

    //中断事件
    std::string intermit_event;

    //累计消息处理数
    uint64 msg_count;

    //线程标志
    uint32 thread_flags;

public:
    //保存对应协议的解释回调接口
    std::map< uint32, std::pair< std::string, FMsgTrans > > msg_trans_map;

    void (*OnIdle)(void);

    void (*OnListenDefault)( int32, int32, wd::CStream& );
    void (*OnListenPre)(SMsgHead*);
    void (*OnListenSith)(SMsgHead*);
    void (*OnListenError)(SMsgHead*);
    void (*OnListenBlock)(SMsgHead*);

    //协议 delete 接口
    void (*OnMsgRelease)(SMsgHead*);

    void (*OnIntermitEvent)(std::string);

public:
    CMsg();
    ~CMsg();

    uint32 Run(void);
    void EndThread(void);

    void SetIdleListen( void(*func)(void) );
    void SetDefaultListen( void(*func)(SMsgHead*,void*) );

    bool ExistMsgListen( uint32 cmd );

    void AddMsgListen( uint32 cmd, CMsg::FMsg func, void* param );

    //将消息数据压入队列列尾
    void Post( int32 sock, int32 key, void* data, uint32 size );

    //将消息压入队列列首
    void Send( int32 sock, int32 key, void* data, uint32 size );

    //直接执行消息
    void Run( int32 sock, int32 key, void* data, uint32 size );

    //设置屏弊
    void Block( uint32 cmd, uint32 block );

    //判断环境是否为协议重播环境
    bool IsReplay(void);

    //设置中断事件
    void Intermit( std::string event );

    //获取当前消息处理总数
    uint64 GetMsgCount(void);

public:
    bool SaveMsgLog( const char* filename );
    uint32 LoadMsgLog( const char* filename, bool real_time );
    void FlushMsg(void);

private:
    void run_msg( CMsg::TMsgData& data );
    void push_msg( CMsg::TMsgData& data );
    void flush_msg(void);

public:
    void msg_idle(void);
    void msg_busy(void);
};

bool debug_msg( const char* name, bool real_time );

#define theMsg TSignleton<CMsg>::Ref()

#endif

