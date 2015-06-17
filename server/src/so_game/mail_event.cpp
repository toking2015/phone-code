#include "event.h"
#include "link_event.h"
#include "user_event.h"
#include "proto/mail.h"
#include "misc.h"
#include "var_imp.h"
#include "local.h"
#include "mail_dc.h"

EVENT_FUNC( mail, SEventNetRealDB )
{
    PQMailGetSystemId msg;

    local::write( local::realdb, msg );
}

EVENT_FUNC( mail, SEventUserInit )
{
    //新创号系统邮件标识
    ev.user->data.var_map[ "mail_auto_id" ].value = theMailDC.db().system_mail_id;
}

EVENT_FUNC( mail, SEventUserLogined )
{
    PQMailSystemTake msg;
    bccopy( msg, ev.user->ext );

    msg.auto_id = var::get( ev.user, "mail_auto_id" );

    local::write( local::realdb, msg );
}
