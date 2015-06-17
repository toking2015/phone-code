#ifndef _CPACK_H_
#define _CPACK_H_

#include "common.h"

#include "coder.h"
#include "log.h"

#define MAX_PACKET_SIZE     ( 1024 * 256 )   //256k协议包长度限制

class CPack : public wd::CThread
{
public:
    typedef void ( *FMsgError )( uint32 link, int32 key, uint32 size, uint32 cmd, int32 error );
    typedef void ( *FMsgStream )( uint32 link, int32 key, void* data, uint32 size );

    typedef void ( *FIdle )(void);

    struct TKeyStream
    {
        int32       key;            //数据流来源标识
        wd::CStream* stream;         //数据流缓冲
        uint32       code;           //数据加密密钥
        uint32       packnum;       //累积包数量
        TKeyStream() : key(0), stream(NULL), code(0),packnum(0)
        {
        }
    };

    enum
    {
        EStop = 1,
    };

    struct SParseData
    {
        enum
        {
            eNoError = 0,           //没有错误
            ePacketSize = 1,        //数据包长度不合法
            eHeadSize = 2,          //数据包包头长度不足
            eCheckSum = 3,          //检查值错误
            eNoHandler = 4,         //缺少解包结构句柄
            eHeadFlag = 5,          //包头标识码错误
            eContent = 6,           //协议包内容解释错误
            eWarnSize = 7,          //协议包过长警告

            eStream = 200,          //没有序列化带SPackHead的二进制流
        };
        uint32 link;
        uint32 size;
        int32 error;
        void* msg;                  //当前协议包, 解包成功时有效
        int32 key;                  //包相关key参数
        uint32 cmd;
    };
    std::map< uint32, TKeyStream > data_map;
private:

    wd::CMutex mutex;

    std::map< uint32, int32 > queue;

    std::list< char* > stream_buffer;

    FMsgError fn_error;
    FMsgStream fn_stream;

    FIdle fn_idle;

    //用作解包错误返回包数据的长驻缓存
    wd::CStream error_buffer;

    uint32 thread_status;
public:
    CPack();
    ~CPack();

    uint32 Run();
    void EndThread();

    void Clear( uint32 link );

    void SetErrorHandler( FMsgError fn );
    void SetStreamHandler( FMsgStream fn );

    void SetIdleHandler( FIdle fn );

    //code 为解码密钥, code == 0x00 为不用解密, 一般只用于 客户端 -> 服务器需要进行解密
    void PushData( int32 key, uint32 link, const void* buff, int32 size, uint8 code = 0x00 );

    //返回加密算子结果
    std::pair< uint32, uint32 > ReplaceCrypt(int32 old_link, int32 new_link);
private:
    void parse_stream( uint32 link, TKeyStream& key_stream, std::list< SParseData > &msgList );

    char* alloc_buffer(void);
    void free_buffer( char* buffer );

public:
    static void fill_pack_head( tag_pack_head* head, const void* buff, uint32 size );
};

#define thePack TSignleton<CPack>::Ref()

#endif

