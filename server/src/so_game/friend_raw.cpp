#include "raw.h"

#include "proto/friend.h"

RAW_USER_LOAD( friend_map )
{
    QuerySql( "select friend_id, friend_favor, friend_group, friend_avatar, friend_level, `friend_name`, `friend_gname` from friend where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        SUserFriend user_friend;

        user_friend.friend_id       = sql->getInteger( i++ );
        user_friend.friend_favor    = sql->getInteger( i++ );
        user_friend.friend_group    = sql->getInteger( i++ );
        user_friend.friend_avatar   = sql->getInteger( i++ );
        user_friend.friend_level    = sql->getInteger( i++ );
        user_friend.friend_name     = sql->getString( i++ );
        user_friend.friend_gname    = sql->getString( i++ );

        data.friend_map[ user_friend.friend_id ] = user_friend;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( friend_map )
{
    stream << strprintf( "delete from friend where role_id = %u;", guid ) << std::endl;

    for ( std::map< uint32, SUserFriend >::iterator iter = data.friend_map.begin();
        iter != data.friend_map.end();
        ++iter )
    {
        stream << strprintf( "insert into friend( role_id, friend_id, friend_favor, friend_group, friend_avatar, friend_level,`friend_name`, `friend_gname` ) values( %u, %u, %u, %hhu, %hu, %u, '%s', '%s' );",
            guid, iter->second.friend_id, iter->second.friend_favor, iter->second.friend_group, iter->second.friend_avatar, iter->second.friend_level,
            escape(iter->second.friend_name).c_str(), escape(iter->second.friend_gname).c_str() ) << std::endl;
    }
}

RAW_USER_LOAD( friend_limit_map )
{
    QuerySql( "select friend_id, time_limit, type_limit, num_limit from friend_limit where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        SFriendLimit friend_limit;

        friend_limit.friend_id       = sql->getInteger( i++ );
        friend_limit.time_limit      = sql->getInteger( i++ );
        friend_limit.type_limit      = sql->getInteger( i++ );
        friend_limit.num_limit       = sql->getInteger( i++ );

        data.friend_limit_map[ friend_limit.friend_id ] = friend_limit;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( friend_limit_map )
{
    stream << strprintf( "delete from friend_limit where role_id = %u;", guid ) << std::endl;

    for ( std::map< uint32, SFriendLimit >::iterator iter = data.friend_limit_map.begin();
        iter != data.friend_limit_map.end();
        ++iter )
    {
        stream << strprintf( "insert into friend_limit( role_id, friend_id, time_limit, type_limit, num_limit ) values( %u, %u, %u, %u, %u );",
            guid, iter->second.friend_id, iter->second.time_limit, iter->second.type_limit, iter->second.num_limit ) << std::endl;
    }
}

