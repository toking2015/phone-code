#include "mail_imp.h"
#include "user_dc.h"
#include "proto/constant.h"
#include "proto/item.h"
#include "proto/mail.h"
#include "coin_imp.h"
#include "server.h"
#include "misc.h"
#include "local.h"

namespace mail
{

uint32 alloc_id( SUser* user )
{
    //个人邮件 mail_id 从 1000001 起, 1-100w 为全服邮件id
    uint32 mail_id = 1000000;

    for ( std::map< uint32, SUserMail >::iterator iter = user->data.mail_map.begin();
        iter != user->data.mail_map.end();
        ++iter )
    {
        mail_id = std::max( mail_id, iter->first );
    }

    return mail_id + 1;
}

//发送邮件
void send( uint32 flag, uint32 role_id, std::string sender_name, std::string subject, std::string body )
{
    send( flag, role_id, sender_name, subject, body, std::vector< S3UInt32 >(), 0, 0 );
}
void send( uint32 flag, uint32 role_id, std::string sender_name, std::string subject, std::string body,
    S3UInt32 coin, uint32 path, uint32 coin_flag/* = 0 */ )
{
    send( flag, role_id, sender_name, subject, body, std::vector< S3UInt32 >( &coin, &coin + 1 ), path, coin_flag );
}
void send( uint32 flag, uint32 role_id, std::string sender_name,
    std::string subject, std::string body, std::vector< S3UInt32 > coins, uint32 path, uint32 coin_flag/* = 0 */ )
{
    //获取邮件数据
    SUserMail mail;

    //填充邮件数据
    mail.flag           = flag;
    mail.path           = path;

    mail.deliver_time   = server::local_time();
    mail.sender_name    = sender_name;

    mail.subject        = subject;
    mail.body           = body;

    mail.coins          = coins;
    mail.coin_flag      = coin_flag;

    if ( role_id != 0 )
    {
        PRMailWriteLocal msg;

        msg.target_id = role_id;
        msg.data = mail;

        local::post( local::self, msg );
    }
    else
    {
        PQMailSave msg;

        msg.data = mail;

        local::write( local::realdb, msg );
    }
}

uint32 readed( SUser* user, uint32 mail_id )
{
    std::map< uint32, SUserMail >::iterator iter = user->data.mail_map.find( mail_id );
    if ( iter == user->data.mail_map.end() )
        return kErrMailNotExist;

    SUserMail& mail = iter->second;

    if ( !state_is( mail.flag, kMailFlagReaded ) )
    {
        state_add( mail.flag, kMailFlagReaded );

        reply_data( user, kObjectUpdate, mail );
    }

    return 0;
}

//领取附件
uint32 take( SUser* user, uint32 mail_id )
{
    //指定邮件领取
    if ( mail_id != 0 )
    {
        std::map< uint32, SUserMail >::iterator iter = user->data.mail_map.find( mail_id );
        if ( iter == user->data.mail_map.end() )
            return kErrMailNotExist;

        SUserMail& mail = iter->second;

        if ( mail.coins.empty() || state_is( mail.flag, kMailFlagTake ) )
            return kErrMailAttachmentEmpty;

        //货币背包检查
        uint32 coin_type = coin::check_give( user, mail.coins );
        if ( coin_type != 0 )
        {
            coin::reply_lack( user, coin_type );
            return kErrItemSpaceFull;
        }

        //增加已获取标志
        state_add( mail.flag, kMailFlagTake );

        //分发货币
        coin::give( user, mail.coins, mail.path, mail.coin_flag );

        reply_data( user, kObjectUpdate, mail );

        return 0;
    }

    //所有邮件领取
    PRMailDataList rep;
    bccopy( rep, user->ext );

    rep.set_type = kObjectUpdate;

    for ( std::map< uint32, SUserMail >::iterator iter = user->data.mail_map.begin();
        iter != user->data.mail_map.end();
        ++iter )
    {
        SUserMail& mail = iter->second;

        if ( mail.coins.empty() || state_is( mail.flag, kMailFlagTake ) )
            continue;

        uint32 coin_type = coin::check_give( user, mail.coins );
        if ( coin_type != 0 )
            continue;

        //增加已获取标志
        state_add( mail.flag, kMailFlagTake );

        //分发货币
        coin::give( user, mail.coins, mail.path, mail.coin_flag );

        rep.list.push_back( mail );
    }

    local::write( local::access, rep );

    return 0;
}

//删除邮件
void del( SUser* user, uint32 mail_id )
{
    //指定邮件删除
    if ( mail_id != 0 )
    {
        std::map< uint32, SUserMail >::iterator iter = user->data.mail_map.find( mail_id );
        if ( iter == user->data.mail_map.end() )
            return;

        SUserMail& mail = iter->second;
        mail.subject.clear();
        mail.body.clear();
        mail.sender_name.clear();
        mail.coins.clear();
        reply_data( user, kObjectDel, mail );

        user->data.mail_map.erase( iter );

        return;
    }

    //所有邮件领取
    PRMailDataList rep;
    bccopy( rep, user->ext );

    rep.set_type = kObjectDel;

    for ( std::map< uint32, SUserMail >::iterator iter = user->data.mail_map.begin();
        iter != user->data.mail_map.end();
        ++iter )
    {
        SUserMail& mail = iter->second;

        //如果存在未领取附件, 即跳过
        if ( !mail.coins.empty() && state_not( mail.flag, kMailFlagTake ) )
            continue;

        mail.subject.clear();
        mail.body.clear();
        mail.sender_name.clear();
        mail.coins.clear();

        rep.list.push_back( mail );
    }

    for ( std::vector< SUserMail >::iterator iter = rep.list.begin();
        iter != rep.list.end();
        ++iter )
    {
        user->data.mail_map.erase( iter->mail_id );
    }

    local::write( local::access, rep );
}

void reply_data( SUser* user, uint32 set_type, SUserMail& mail )
{
    PRMailData rep;
    bccopy( rep, user->ext );

    rep.set_type = set_type;
    rep.data = mail;

    local::write( local::access, rep );
}

} // namespace mail

