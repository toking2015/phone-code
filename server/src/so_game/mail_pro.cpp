#include "pro.h"
#include "proto/constant.h"
#include "proto/mail.h"
#include "proto/system.h"
#include "netsingle.h"
#include "local.h"
#include "user_dc.h"
#include "misc.h"
#include "mail_imp.h"
#include "var_imp.h"
#include "user_imp.h"
#include "mail_dc.h"

MSG_FUNC( PRMailGetSystemId )
{
    theMailDC.db().system_mail_id = msg.system_mail_id;
}

MSG_FUNC( PQMailReaded )
{
    QU_ON( user, msg.role_id );

    uint32 result = mail::readed( user, msg.mail_id );
    if ( result != 0 )
    {
        HandleErrCode( user, result, msg.mail_id );
        return;
    }
}

struct mail_online_send_process
{
    std::string& subject;
    std::string& body;
    std::vector< S3UInt32 >& coins;

    mail_online_send_process( std::string& s, std::string& b, std::vector< S3UInt32 >& c ) :
        subject(s), body(b), coins(c) {}

    void operator()( std::pair< const uint32, SUser >& pair )
    {
        SUser* user = &pair.second;

        if ( !user::is_online( user ) )
            return;

        mail::send( kMailFlagSystem, user->guid, "系统邮件", subject, body, coins, kPathSystemAuto );
    }
};
MSG_FUNC( PQMailWrite )
{
    /*
       内部测试, 测完后需需要去除注释
    if ( key != local::auth )
        return;
    */

    do
    {
        if ( msg.subject.empty() )
            break;

        if ( msg.body.empty() )
            break;

        if ( msg.target_id != 0 )
        {
            //个人邮件
            mail::send( kMailFlagSystem, msg.target_id, "系统邮件", msg.subject, msg.body, msg.coins, kPathSystemAuto );
        }
        else
        {
            //在线用户邮件
            dc::safe_each( theUserDC.db().user_map, mail_online_send_process( msg.subject, msg.body, msg.coins ) );
        }
    }
    while(0);
}

MSG_FUNC( PQMailTake )
{
    QU_ON( user, msg.role_id );

    uint32 result = mail::take( user, msg.mail_id );
    if ( result != 0 )
    {
        HandleErrCode( user, result, msg.mail_id );
        return;
    }
}

MSG_FUNC( PQMailDel )
{
    QU_ON( user, msg.role_id );

    mail::del( user, msg.mail_id );
}

void mail_system_query_process( std::pair< const uint32, SUser >& pair )
{
    SUser* user = &pair.second;

    PQMailSystemTake msg;
    bccopy( msg, user->ext );

    msg.auto_id = var::get( user, "mail_auto_id" );

    local::write( local::realdb, msg );
}
MSG_FUNC( PRMailSave )
{
    if ( key != local::realdb )
        return;

    theMailDC.db().system_mail_id = std::max( theMailDC.db().system_mail_id, msg.mail_id );

    dc::safe_each( theUserDC.db().user_map, mail_system_query_process );
}

MSG_FUNC( PRMailSystemTake )
{
    if ( key != local::realdb )
        return;

    QU_ON( user, msg.role_id );

    uint32 mail_auto_id = var::get( user, "mail_auto_id" );
    uint32 max_auto_id = mail_auto_id;

    for ( std::map< uint32, SUserMail >::iterator iter = msg.data.begin();
        iter != msg.data.end();
        ++iter )
    {
        SUserMail& mail = iter->second;

        //个人邮件 mail_id 从 1000001 起, 1-100w 为全服邮件id
        if ( mail.mail_id > 1000000 || mail.mail_id <= mail_auto_id )
            continue;

        max_auto_id = std::max( max_auto_id, mail.mail_id );

        //基本容错
        if ( user->data.mail_map.find( mail.mail_id ) != user->data.mail_map.end() )
            continue;

        user->data.mail_map[ mail.mail_id ] = mail;

        mail::reply_data( user, kObjectAdd, mail );
    }

    var::set( user, "mail_auto_id", max_auto_id );
}

MSG_FUNC( PRMailWriteLocal )
{
    if ( key != local::self )
        return;

    QU_OFF( user, msg.target_id );

    msg.data.mail_id = mail::alloc_id( user );

    user->data.mail_map[ msg.data.mail_id ] = msg.data;

    mail::reply_data( user, kObjectAdd, msg.data );
}

