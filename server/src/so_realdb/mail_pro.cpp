#include "pro.h"
#include "proto/mail.h"

MSG_FUNC( PQMailGetSystemId )
{
    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    QuerySql( "select ifnull( max(mail_id), 0 ) from mailinfo where role_id = 0" );
    if ( sql->empty() )
        return;

    PRMailGetSystemId rep;
    rep.system_mail_id = sql->getInteger(0);

    local::write( local::game, rep );
}

MSG_FUNC( PQMailSave )
{
    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    QuerySql( "select ifnull( max( mail_id ), 0 ) + 1 from mailinfo where role_id = 0" );
    if ( sql->empty() )
        return;

    uint32 mail_id = sql->getInteger(0);

    ExecuteSql( "insert into mailinfo values( %u, %u, %u, %u, %u, '%s', '%s', '%s', %u )",
        0, mail_id, msg.data.flag, msg.data.path, msg.data.deliver_time,
        sql->escape( msg.data.sender_name.c_str() ).c_str(),
        sql->escape( msg.data.subject.c_str() ).c_str(),
        sql->escape( msg.data.body.c_str() ).c_str(),
        msg.data.coin_flag );

    for ( int32 i = 0; i < (int32)msg.data.coins.size(); ++i )
    {
        S3UInt32& s3 = msg.data.coins[i];
        ExecuteSql( "insert into attachment values( %u, %u, %u, %u, %u, %u )",
            0, mail_id, i, s3.cate, s3.objid, s3.val );
    }

    PRMailSave rep;
    rep.mail_id = mail_id;

    local::write( local::game, rep );
}

MSG_FUNC( PQMailSystemTake )
{
    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    PRMailSystemTake rep;
    bccopy( rep, msg );

    QuerySql( "select mail_id, flag, path, deliver_time, sender_name, subject, body, coin_flag from mailinfo "
        "where role_id = 0 and mail_id > %u",
        msg.auto_id );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        uint32 mail_id          = sql->getInteger( i++ );

        SUserMail& mail = rep.data[ mail_id ];

        mail.mail_id        = mail_id;
        mail.flag           = sql->getInteger( i++ );
        mail.path           = sql->getInteger( i++ );
        mail.deliver_time   = sql->getInteger( i++ );
        mail.sender_name    = sql->getString( i++ );
        mail.subject        = sql->getString( i++ );
        mail.body           = sql->getString( i++ );
        mail.coin_flag      = sql->getInteger( i++ );
    }

    //空邮件直接退出
    if ( rep.data.empty() )
        return;

    for ( std::map< uint32, SUserMail >::iterator iter = rep.data.begin();
        iter != rep.data.end();
        ++iter )
    {
        SUserMail& mail = iter->second;

        QuerySql( "select mail_id, `index`, cate, objid, val from attachment where role_id = 0 and mail_id = %u",
            mail.mail_id );
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;

            uint32 mail_id      = sql->getInteger( i++ );
            uint32 index        = sql->getInteger( i++ );

            std::map< uint32, SUserMail >::iterator iter = rep.data.find( mail_id );
            if ( iter == rep.data.end() )
                continue;

            if ( index >= iter->second.coins.size() )
                iter->second.coins.resize( index + 1 );

            S3UInt32& s3 = iter->second.coins[ index ];
            s3.cate             = sql->getInteger( i++ );
            s3.objid            = sql->getInteger( i++ );
            s3.val              = sql->getInteger( i++ );
        }
    }

    local::write( local::game, rep );
}

