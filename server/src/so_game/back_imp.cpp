#include "back_imp.h"
#include "local.h"
#include "server.h"
#include "proto/back.h"

#include <stdarg.h>

namespace back
{

void write( const char* title, const char* format, ... )
{
    int32 length = 0;
    {
        va_list argp;
        va_start( argp, format );
        length = vsnprintf( NULL, 0, format, argp );
        va_end( argp );
    }

    PQBackLog msg;

    msg.log_title = title;
    msg.log_text.resize( length );
    msg.log_time = server::local_time();

    va_list argp;
    va_start( argp, format );
    vsprintf( &msg.log_text[0], format, argp );
    va_end( argp );

    local::write( local::auth, msg );
}

}// namespace back
