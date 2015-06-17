#include "msg.h"
#include "misc.h"
#include "pack.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

CMsg::CMsg()
{
    msg_read_file = NULL;
    msg_write_file = 0;

    OnIdle = NULL;

    OnListenDefault = NULL;
    OnListenPre = NULL;
    OnListenSith = NULL;
    OnListenError = NULL;
    OnListenBlock = NULL;

    OnMsgRelease = NULL;

    OnIntermitEvent = NULL;

    msg_count = 0;

    *thread_rand_seed() = time(NULL);

    thread_flags = 0;
}

CMsg::~CMsg()
{
    if ( msg_read_file != NULL )
    {
        fclose( msg_read_file );
        msg_read_file = NULL;
    }

    if ( msg_write_file != 0 );
    {
        close( msg_write_file );
        msg_write_file = 0;
    }
}

uint32 CMsg::Run(void)
{
    thread_flags = 0;

    for(;;)
    {
        if ( OnIntermitEvent != NULL && !intermit_event.empty() )
        {
            std::string event;
            {
                wd::CGuard< wd::CMutex > safe( &m_mutex );

                event.swap( intermit_event );
            }
            if ( !event.empty() )
                OnIntermitEvent( event );
            continue;
        }
        if ( msg_list.empty() )
        {
            if ( state_is( thread_flags, CMsg::EStop ) )
                break;

            msg_idle();
            continue;
        }

        std::list< TMsgData > list;
        {
            wd::CGuard< wd::CMutex > safe( &m_mutex );

            list.swap( msg_list );
        }

        for ( std::list< TMsgData >::iterator iter = list.begin();
            iter != list.end();
            ++iter )
        {
            run_msg( *iter );
            push_msg( *iter );
            delete iter->stream;
        }

        msg_busy();
    }

    return 0;
}

void CMsg::run_msg( CMsg::TMsgData& data )
{
    int32 sock = data.sock;
    int32 key = data.key;
    wd::CStream& stream = *data.stream;

    //数据包过小容错处理
    if ( stream.length() < 4 + sizeof( tag_msg_head ) )
        return;

    tag_msg_head* pMsgHead = (tag_msg_head*)&stream[4];

    uint32 cmd = MSG_CMD( *pMsgHead );

    std::set< uint32 >::iterator iter = msg_block_set.find( cmd );
    if ( iter != msg_block_set.end() )
    {
        LOG_INFO( "CMsg::run_msg cmd[ %u ] is block!", cmd );
        return;
    }

    std::map< uint32, std::pair< std::string, FMsgTrans > >::iterator i = msg_trans_map.find( cmd );
    if ( i == msg_trans_map.end() )
    {
        LOG_ERROR( "CMsg::run_msg cmd[ %u ] handler not found!", cmd );
        return;
    }

    //累计消息处理数
    ++msg_count;


    std::map< uint32, FMsgPro >::iterator j = msg_pro_map.find( cmd );
    if ( j != msg_pro_map.end() )
    {
        FMsgTrans trans = i->second.second;

        stream.position(0);
        SMsgHead* msg = trans( stream );
        if ( msg == NULL )
        {
            LOG_ERROR( "CMsg::run_msg cmd[ %s ] trans failure!", i->second.first.c_str() );
            return;
        }

        if ( OnListenPre != NULL )
            OnListenPre( msg );

        j->second.first( msg, j->second.second, sock, key );

        if ( OnListenSith != NULL )
            OnListenSith( msg );

        OnMsgRelease( msg );
    }
    else if ( OnListenDefault != NULL )
    {
        OnListenDefault( sock, key, stream );
    }
}

void CMsg::Block( uint32 cmd, uint32 block )
{
    std::set< uint32 >::iterator iter = msg_block_set.find( cmd );

    if ( block && iter == msg_block_set.end() )
        msg_block_set.insert( cmd );

    if ( !block && iter != msg_block_set.end() )
        msg_block_set.erase( iter );
}

void CMsg::EndThread(void)
{
    state_add( thread_flags, CMsg::EStop );

    wd::thread_wait_exit( GetHandle() );
}

bool CMsg::ExistMsgListen( uint32 cmd )
{
    return msg_pro_map.find( cmd ) != msg_pro_map.end();
}

void CMsg::AddMsgListen( uint32 cmd, CMsg::FMsg func, void* param )
{
    msg_pro_map[ cmd ] = FMsgPro( func, param );
}

void CMsg::Post( int32 sock, int32 key, void* data, uint32 size )
{
    wd::CGuard< wd::CMutex > safe( &m_mutex );

    msg_list.push_back( CMsg::TMsgData( sock, key, new wd::CStream( data, size ) ) );
}

//因为使用了 SendCmd, 这里会导致 push 的 msg 记录顺序是非执行顺序, 尽量不使用
void CMsg::Send( int32 sock, int32 key, void* data, uint32 size )
{
    wd::CGuard< wd::CMutex > safe( &m_mutex );

    msg_list.push_front( CMsg::TMsgData( sock, key, new wd::CStream( data, size ) ) );
}

//直接执行
void CMsg::Run( int32 sock, int32 key, void* data, uint32 size )
{
    wd::CStream stream( data, size );
    CMsg::TMsgData msg_data( sock, key, &stream );

    run_msg( msg_data );
    push_msg( msg_data );
}

bool CMsg::IsReplay(void)
{
    return ( msg_read_file != NULL );
}

void CMsg::Intermit( std::string event )
{
    wd::CGuard< wd::CMutex > safe( &m_mutex );

    intermit_event = event;
}

uint64 CMsg::GetMsgCount(void)
{
    return msg_count;
}

bool CMsg::SaveMsgLog( const char* filename )
{
    msg_write_file = open( filename, O_CREAT | O_WRONLY | O_LARGEFILE | O_NONBLOCK );

    if( msg_write_file != 0 )
    {
        write( msg_write_file, thread_rand_seed(), sizeof( *thread_rand_seed() ) );

        return true;
    }

    return false;
}

void CMsg::msg_idle(void)
{
    flush_msg();

    if ( OnIdle != NULL )
        OnIdle();

    wd::thread_sleep( 10 );
}

void CMsg::msg_busy(void)
{
    if ( OnIdle != NULL )
        OnIdle();
}

void CMsg::push_msg( CMsg::TMsgData& data )
{
    if ( msg_write_file == 0 )
        return;

    int32 key = data.key;
    wd::CStream& stream = *data.stream;

    uint32 length = stream.length();
    time_t cur_time = time(NULL);
    {
        msg_buffer.insert( msg_buffer.end(), (char*)&key, (char*)&key + sizeof( key ) );
        msg_buffer.insert( msg_buffer.end(), (char*)&cur_time, (char*)&cur_time + sizeof( cur_time ) );
        msg_buffer.insert( msg_buffer.end(), (char*)&length, (char*)&length + sizeof( length ) );
        msg_buffer.insert( msg_buffer.end(), &stream[0], &stream[0] + length );
    }
}

void CMsg::flush_msg(void)
{
    if ( msg_write_file == 0 || msg_buffer.empty() )
        return;

    int32 write_length = (int32)write( msg_write_file, &msg_buffer[0], msg_buffer.size() );
    if ( write_length > 0 )
    {
        if ( write_length >= (int32)msg_buffer.size() )
            msg_buffer.clear();
        else
            msg_buffer.erase( msg_buffer.begin(), msg_buffer.begin() + write_length );
        return;
    }

    switch ( errno )
    {
    case EAGAIN:
        break;
    default:
        {
            close( msg_write_file );
            msg_write_file = 0;

            LOG_ERROR( "protocol msg log error[%d]: %s", errno, strerror( errno ) );
        }
        break;
    }
}

uint32 CMsg::LoadMsgLog( const char* filename, bool real_time )
{
    OnListenPre = NULL;
    OnListenSith = NULL;
    OnListenError = NULL;

    uint32 loadCount = 0;
    msg_read_file = fopen( filename, "rb" );

    //使用记录下来的随机数种子
    if( msg_read_file == NULL )
        return 0;

    if ( fread( thread_rand_seed(), 1, sizeof( *thread_rand_seed() ), msg_read_file ) != sizeof( *thread_rand_seed() ) )
    {
        printf( "read rand_seed error!\r\n");
        return false;
    }

    uint32 key = 0;
    time_t cur_time = 0;
    uint32 length = 0;
    wd::CStream stream;
    std::vector<char> buff( 1024 * 1024 );
    for (;;)
    {
        int32 size = (int32)fread( &buff[0], 1, buff.size(), msg_read_file );
        if ( size <= 0 )
            break;

        stream.position( stream.length() );
        stream.write( &buff[0], size );
        stream.position(0);

        for (;;)
        {
            if ( stream.available() < sizeof( key ) + sizeof( cur_time ) + sizeof( length ) )
                break;

            stream.posi_clear();
            stream.posi_push();

            stream.read( &key, sizeof( key ) );
            stream.read( &cur_time, sizeof( cur_time ) );
            stream.read( &length, sizeof( length ) );

            if ( length <= 0 )
            {
                printf( "debug head length[%d] error!\r\n", (int32)length );
                break;
            }

            if ( length > stream.available() )
            {
                stream.posi_pop();
                break;
            }

            CMsg::TMsgData data;
            data.key = key;
            data.stream = new wd::CStream();
            data.stream->write( &stream[stream.position()], length );

            stream.position(stream.position() + length );

            global_debug_time = (uint32)cur_time;
            run_msg(data);

            ++loadCount;
        }

        stream.erase();
    }

    wd::thread_sleep(1000);
    return loadCount;
}

void CMsg::FlushMsg(void)
{
    //flush_msg();
}

bool debug_msg( const char* name, bool real_time )
{
    printf( "enter debug mode!\r\nopen msgfile \"%s\"\r\n", name );

    uint32 loadCount = theMsg.LoadMsgLog( name, real_time );

    printf( "leave debug mode!\r\nprocess msg[%d]\r\n", loadCount );

    return true;
}

