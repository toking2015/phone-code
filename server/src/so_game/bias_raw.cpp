#include "raw.h"

#include "proto/bias.h"
#include "proto/constant.h"

RAW_USER_LOAD( bias_map )
{
    QuerySql( "select bias_id, use_count, day_count from bias where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserBias user_bias;
        user_bias.bias_id       = sql->getInteger( i++ );
        user_bias.use_count     = sql->getInteger( i++ );
        user_bias.day_count     = sql->getInteger( i++ );
        data.bias_map[user_bias.bias_id] = user_bias;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( bias_map )
{
    stream << strprintf( "delete from bias where role_id = %u;", guid ) << std::endl;

    if ( data.bias_map.empty() )
        return;
    int32 count = 0;
    stream << "insert into bias (role_id, bias_id, use_count, day_count ) values";
    for ( std::map< uint32, SUserBias >::iterator iter = data.bias_map.begin();
        iter != data.bias_map.end();
        ++iter )
    {
        if ( 0 != count )
            stream << ",";
        SUserBias& bias = iter->second;
        stream << "(" << guid << ", " << bias.bias_id << ", " <<  bias.use_count << ", " << bias.day_count << ")";
        ++count;
    }
    stream << ";" << std::endl;;
}
