#include "raw.h"

#include "proto/pay.h"

//simple
RAW_USER_LOAD( pay_list )
{
    QuerySql( "select uid, price, time, type, flag from pay where rid = %u;",
        guid );

    if ( sql->empty() )
        return DB_SUCCEED;

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserPay pay;
        pay.uid         = sql->getInteger(i++);
        pay.price       = sql->getInteger(i++);
        pay.time        = sql->getInteger(i++);
        pay.type        = sql->getInteger(i++);
        pay.flag        = sql->getInteger(i++);

        data.pay_list.push_back( pay );
    }

    return DB_SUCCEED;

}

RAW_USER_SAVE( pay_list )
{
    if ( data.pay_list.empty() )
        return;

    for( std::vector<SUserPay>::iterator iter = data.pay_list.begin();
        iter != data.pay_list.end();
        ++iter )
    {
        if ( iter->flag == kPayFlagTake )
            stream << strprintf( "update pay set flag = %hhu where uid = %u limit 1;", iter->flag, iter->uid ) << std::endl;
    }
}

//simple
RAW_USER_LOAD( pay_info )
{
    QuerySql( "select pay_sum, pay_count, month_time,month_reward from userpay where guid = %u limit 1;",
        guid );

    if ( sql->empty() )
        return DB_SUCCEED;

    int32 i = 0;
    data.pay_info.pay_sum       = sql->getInteger( i++ );
    data.pay_info.pay_count     = sql->getInteger( i++ );
    data.pay_info.month_time    = sql->getInteger( i++ );
    data.pay_info.month_reward  = sql->getInteger( i++ );

    return DB_SUCCEED;

}

RAW_USER_SAVE( pay_info )
{
    stream << strprintf( "delete from userpay where guid = %u limit 1;", guid ) << std::endl;
    stream << strprintf
    (
        "insert into userpay( guid, pay_sum, pay_count, month_time, month_reward ) "
        "values( %u, %u, %u, %u, %u );",
        guid, data.pay_info.pay_sum, data.pay_info.pay_count, data.pay_info.month_time, data.pay_info.month_reward
    ) << std::endl;
}

