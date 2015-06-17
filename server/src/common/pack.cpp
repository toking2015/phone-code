#include "pack.h"

#include "misc.h"
#include "log.h"

CPack::CPack()
{
    fn_error = NULL;
    fn_stream = NULL;

    fn_idle = NULL;

    thread_status = 0;
}

CPack::~CPack()
{

}

int32 copy_stream_memory( wd::CStream& stream, wd::CStream& buffer, uint32 length )
{
    uint32 position = buffer.position();

    buffer.write( &stream[ stream.position() ], length );

    return position;
}

char* CPack::alloc_buffer(void)
{
    char* buffer = NULL;
    if ( stream_buffer.empty() )
        buffer = new char[ MAX_PACKET_SIZE ];
    else
    {
        buffer = stream_buffer.back();
        stream_buffer.pop_back();
    }

    return buffer;
}

void CPack::free_buffer( char* buffer )
{
    stream_buffer.push_back( buffer );
}

void CPack::parse_stream( uint32 link, TKeyStream& key_stream, std::list< SParseData > &msgList )
{
    wd::CStream& stream = *key_stream.stream;

    //初始化读取指针位置
    stream.position(0);

    bool head_flag_error = false;
    for (;;)
    {
        //取得协议头
        if ( stream.available() < sizeof( tag_pack_head ) + 4 + sizeof( tag_msg_head ) )
        {
            //解包错误认定为数据不足
            break;
        }

        //位置记录
        int32 position = stream.position();
        char* begin = (char*)&stream[ position ];

        //取得基本包数据结构
        tag_pack_head* pPacketHead = ( tag_pack_head* )begin;

        //问题1
        SParseData data = { link, sizeof( tag_pack_head ), CPack::SParseData::eNoError, NULL, key_stream.key, 0 };

        //数据包头标识错误
        if ( pPacketHead->pack_flag != 0xe1c7 )
        {
            if ( !head_flag_error )
            {
                data.error = CPack::SParseData::eHeadFlag;
                msgList.push_back( data );

                head_flag_error = true;
            }

            stream.position( position + 1 );
            continue;
        }

        key_stream.packnum++;

        //协议包包头( 偏移4个字节协议兼容结构大小 )
        tag_msg_head* pMsgHead = (tag_msg_head*)( begin + sizeof( tag_pack_head ) + 4 );

        //256k协议包长度限制
        if ( pPacketHead->pack_length <= 0 || pPacketHead->pack_length > ( MAX_PACKET_SIZE ) )
        {
            if ( !head_flag_error )
            {
                tag_msg_head msg_head;

                //copy协议包头
                memcpy( &msg_head, pMsgHead, sizeof( msg_head ) );

                data.error = CPack::SParseData::ePacketSize;
                data.size = pPacketHead->pack_length;
                data.cmd = msg_head.msg_cmd;

                msgList.push_back( data );

                head_flag_error = true;
            }

            stream.position( position + 1 );
            continue;
        }

        head_flag_error = false;

        //包长度不足判断
        if ( stream.available() - sizeof( tag_pack_head ) < pPacketHead->pack_length )
            break;

        //128k协议包长度警告
        if ( pPacketHead->pack_length > ( MAX_PACKET_SIZE >> 1 ) )
        {
            LOG_ERROR( "sock[%d] key[%d] data warn! size[%d]! role[%u] cmd[%u] err[%d]",
                data.link, data.key, pPacketHead->pack_length, pMsgHead->role_id,
                pMsgHead->msg_cmd, CPack::SParseData::eWarnSize );
        }

        //校验和判断
        uint32 checksum = checksum_bytes( begin + sizeof( tag_pack_head ), 0, pPacketHead->pack_length );
        if ( pPacketHead->pack_checksum != checksum )
        {
            data.error = CPack::SParseData::eCheckSum;
            data.size = pPacketHead->pack_length;
            data.cmd = pMsgHead->msg_cmd;

            msgList.push_back( data );

            stream.position( position + sizeof( tag_pack_head ) + pPacketHead->pack_length );
            continue;
        }

        //直接返回数据流
        data.error = CPack::SParseData::eStream;
        data.size = pPacketHead->pack_length;
        data.msg = alloc_buffer();
        memcpy( data.msg, begin + sizeof( tag_pack_head ), pPacketHead->pack_length );

        msgList.push_back( data );

        stream.position( position + sizeof( tag_pack_head ) + pPacketHead->pack_length );
    }
    stream.erase();
}

uint32 CPack::Run()
{
    thread_status = 0;

    while ( state_not( thread_status, EStop ) )
    {
        if ( queue.empty() )
        {
            if ( fn_idle != NULL )
                fn_idle();

            wd::thread_sleep( 10 );
            continue;
        }

        //重置buff指针
        error_buffer.position(0);

        std::list< SParseData > msgList;
        {
            wd::CGuard<wd::CMutex> safe( &mutex );

            //遍历对所有可能存在完整协议的 link 进来解包
            for ( std::map< uint32, int32 >::iterator i = queue.begin();
                i != queue.end();
                ++i )
            {
                std::map< uint32, TKeyStream >::iterator iter = data_map.find( i->first );
                if ( iter == data_map.end() )
                    continue;

                //详试解包
                parse_stream( iter->first, iter->second, msgList );

                //清除数据
                //if ( iter->second.stream.length() <= 0 )
                //    data_map.erase( iter );
            }

            queue.clear();
        }

        //安全回调所有拆解好的协议包
        for ( std::list< SParseData >::iterator i = msgList.begin();
            i != msgList.end();
            ++i )
        {
            switch ( i->error )
            {
            case CPack::SParseData::eStream:
                {
                    fn_stream( i->link, i->key, i->msg, i->size );
                    free_buffer( (char*)i->msg );
                }
                break;
            default:
                {
                    if ( fn_error != NULL )
                        fn_error( i->link, i->key, i->size, i->cmd, i->error );
                }
            }
        }

        if ( fn_idle != NULL )
            fn_idle();
    }

    return 0;
}

void CPack::EndThread()
{
    state_add( thread_status, EStop );

    wd::thread_wait_exit( GetHandle() );
}

void CPack::Clear( uint32 link )
{
    wd::CGuard<wd::CMutex> safe( &mutex );

    std::map< uint32, TKeyStream >::iterator iter = data_map.find( link );
    if ( iter != data_map.end() )
    {
        delete iter->second.stream;
        data_map.erase( iter );
    }
}

void CPack::SetErrorHandler( FMsgError fn )
{
    fn_error = fn;
}

void CPack::SetStreamHandler( FMsgStream fn )
{
    fn_stream = fn;
}

void CPack::SetIdleHandler( FIdle fn )
{
    fn_idle = fn;
}

void CPack::PushData( int32 key, uint32 link, const void* buff, int32 size, uint8 code/* = 0x00 */ )
{
    wd::CGuard<wd::CMutex> safe( &mutex );

    TKeyStream &key_stream = data_map[ link ];
    if ( key_stream.stream == NULL )
        key_stream.stream = new wd::CStream();

    wd::CStream &stream = *key_stream.stream;

    key_stream.code = code;

    //更新key值
    key_stream.key = key;
    stream.position( stream.length() );

    stream.write( buff, size );

    queue[link]++;
}

void CPack::fill_pack_head( tag_pack_head* head, const void* buff, uint32 size )
{
    head->pack_flag = 0xe1c7;
    head->pack_status = 0;
    head->pack_code = 0;
    head->pack_length = size;
    head->pack_checksum = checksum_bytes( (void*)buff, 0, size );
}

