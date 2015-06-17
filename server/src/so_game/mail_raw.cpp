#include "raw.h"

#include "proto/mail.h"

RAW_USER_LOAD( mail_map )
{
    QuerySql( "select mail_id, flag, path, deliver_time, sender_name, subject, body, coin_flag from mailinfo where role_id=%u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        uint32 mail_id      = sql->getInteger( i++ );

        SUserMail& mail = data.mail_map[ mail_id ];

        mail.mail_id        = mail_id;
        mail.flag           = sql->getInteger( i++ );
        mail.path           = sql->getInteger( i++ );
        mail.deliver_time   = sql->getInteger( i++ );
        mail.sender_name    = sql->getString( i++ );
        mail.subject        = sql->getString( i++ );
        mail.body           = sql->getString( i++ );
        mail.coin_flag      = sql->getInteger( i++ );
    }

    QuerySql( "select mail_id, `index`, cate, objid, val from attachment where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        uint32 mail_id      = sql->getInteger( i++ );
        uint32 index        = sql->getInteger( i++ );

        std::map< uint32, SUserMail >::iterator iter = data.mail_map.find( mail_id );
        if ( iter == data.mail_map.end() )
            continue;

        if ( index >= iter->second.coins.size() )
            iter->second.coins.resize( index + 1 );

        S3UInt32& s3 = iter->second.coins[ index ];
        s3.cate             = sql->getInteger( i++ );
        s3.objid            = sql->getInteger( i++ );
        s3.val              = sql->getInteger( i++ );
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( mail_map )
{
    stream << strprintf( "delete from mailinfo where role_id = %u;", guid ) << std::endl;
    stream << strprintf( "delete from attachment where role_id = %u;", guid ) << std::endl;

    if ( !data.mail_map.empty() )
    {
        bool first_coins = true;
        std::stringstream coins_stream;

        stream << "insert into mailinfo values";
        for ( std::map< uint32, SUserMail >::iterator iter = data.mail_map.begin();
            iter != data.mail_map.end();
            ++iter )
        {
            SUserMail& mail = iter->second;

            if ( iter != data.mail_map.begin() )
                stream << ",";

            stream << strprintf( "( %u, %u, %u, %u, %u, '%s', '%s', '%s', %u )",
                guid, mail.mail_id, mail.flag, mail.path, mail.deliver_time,
                escape( mail.sender_name ).c_str(), escape( mail.subject ).c_str(), escape( mail.body ).c_str(),
                mail.coin_flag );

            if ( !mail.coins.empty() )
            {
                for ( int32 i = 0; i < (int32)mail.coins.size(); ++i )
                {
                    if ( !first_coins )
                        coins_stream << ",";
                    else
                        first_coins = false;

                    S3UInt32& s3 = mail.coins[i];
                    coins_stream << strprintf( "( %u, %u, %u, %u, %u, %u )",
                        guid, mail.mail_id, i, s3.cate, s3.objid, s3.val );
                }
            }
        }
        stream << ";" << std::endl;

        std::string coins_string = coins_stream.str();
        if ( !coins_string.empty() )
            stream << "insert into attachment values" << coins_string << ";" << std::endl;
    }
}

