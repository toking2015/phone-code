#include "pro.h"
#include "proto/back.h"
#include "output.h"

MSG_FUNC( PQBackLog )
{
    output::write( msg.log_title, msg.log_text, msg.log_time );
}
