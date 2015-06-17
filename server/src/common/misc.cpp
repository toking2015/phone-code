#include "misc.h"
#include "log.h"
#include "md5.h"
#include <iconv.h>

#include <sys/time.h>
#include <stdarg.h>

//全局行为记录号
uint32 global_action = 0;

//全局时间点(秒), 主要用来支持msg debug
uint32 global_debug_time = 0;

void* proxy_cb( void(*call)(void) )
{
    call();
    return (void*)(~0);
}

std::vector< std::string > local_execute( const char* format, ... )
{
    char* string = NULL;

    va_list args;
    va_start(args, format);
    vasprintf( &string, format, args );
    va_end(args);

    std::vector< std::string > string_list;

    if ( string == NULL )
        return string_list;

    FILE* file = popen( string, "r" );
    if ( file != NULL )
    {
        char buff[1024];

        while( fgets( buff, sizeof( buff ) - 1, file ) != NULL )
        {
            string_list.push_back( buff );
        }

        pclose( file );
    }

    free( string );

    return string_list;
}

bool code_convert(const char* from_charset, const char* to_charset, char* inbuf, int32 inlen, char* outbuf, int32 outlen )
{
    iconv_t cd;
    char** pin = &inbuf;
    char** pout = &outbuf;

    cd = iconv_open(to_charset,from_charset);
    if ( 0 == cd )
        return false;

    size_t t_inlen = inlen;
    size_t t_outlen = outlen;

    memset( outbuf, 0, outlen );
    size_t t_result = iconv( cd, pin, &t_inlen, pout, &t_outlen );
    if ( t_result == (size_t)-1 )
        return false;

    iconv_close(cd);
    return true;
}

bool u2g(char *inbuf, int32 inlen, char* outbuf, int32 outlen )
{
    return code_convert("utf-8","gb2312",inbuf,inlen,outbuf,outlen);
}

bool g2u(char *inbuf, int32 inlen, char* outbuf, int32 outlen )
{
    return code_convert("gb2312","utf-8",inbuf,inlen,outbuf,outlen);
}

char chr_p[] = "0123456789abcdef";
SMd5Value md5_value( uint8* data, uint32 len )
{
    SMd5Value md5_value;

    md5_state_t state;

    md5_init( &state );
    md5_append( &state, data, len );
    md5_finish( &state, md5_value.digest );

    return md5_value;
}

std::string md5_string( uint8* data, uint32 len )
{
    SMd5Value value = md5_value( data, len );

    char buffer[33] = {0};
    char *p = buffer;
    for ( int i = 0; i < 16; ++i )
    {
        *(p++) = chr_p[ ( value.digest[i] >> 4 ) & 0xF ];
        *(p++) = chr_p[ value.digest[i] & 0xF ];
    }

    return std::string( buffer );
}

void timer_progress( uint32 LoopId, std::string& key, std::string& param, uint32 time_sec )
{
    uint16 len_key = key.size();
    uint16 len_param = param.size();

    //4 + sizeof( tag_msg_head ) + 4 + 2 + key.size() + 2 + param.size();

    //拼装 SMsgTimeout 结构
    tag_msg_head msg;
    msg.msg_cmd = 113037829;
    /*
     PQTimerEvent
     {
        time_id     : uint32;
        time_key    : string;
        time_param  : string;
        time_sec    : uint32;
    }
    */

    wd::CStream stream;

    //写入 SMsgHead
    uint32 size = sizeof( tag_msg_head );
    stream << size;
    stream.write( &msg, sizeof( tag_msg_head ) );

    //写入 PQTimerEvent
    size = sizeof( uint32 ) + 2 + len_key + 2 + len_param + sizeof( uint32 );
    stream << size;
    stream << LoopId << len_key << key << len_param << param << time_sec;

    theMsg.Run( 0, 0, &stream[0], stream.length() );
}

std::string escape( const void *ptr, const int32 size )
{
    if ( ptr == NULL || size <= 0 )
        return std::string();

    std::string ret( size * 4 + 1, '\0' );

    char* source = (char*)ptr;
    char* end = source + size;

    char* target = &ret[0];

    while (source < end)
    {
        switch (*source)
        {
        case '\0':
            *target++ = '\\';
            *target++ = '0';
            break;
        case '\r':
            *target++ = '\\';
            *target++ = 'r';
            break;
        case '\n':
            *target++ = '\\';
            *target++ = 'n';
            break;

        case '\'':
        case '\"':
        case '\\':
            *target++ = '\\';
        default:
            *target++ = *source;
            break;
        }

        source++;
    }

    *target = 0;

    uint32 length = target - &ret[0];
    ret.resize( length );

    return ret;
}
std::string escape( std::string str )
{
    return escape( str.c_str(), str.size() );
}

