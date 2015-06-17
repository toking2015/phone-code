#include "raw.h"

#include "proto/user.h"

//simple
RAW_USER_LOAD( simple )
{
    QuerySql( "select a.channel, s.name, s.gender, s.avatar, s.team_level, s.team_xp, s.vip_level, s.vip_xp, s.strength, s.guild_id, s.fight_value from account a, usersimple s where a.id = %u and s.guid = a.id limit 1;",
        guid );

    if ( sql->empty() )
    {
        //新建用户数据, 读取帐号平台来源信息
        QuerySql( "select channel from account where id = %u limit 1", guid );
        if ( sql->empty() )
            return DB_INVALID;

        data.simple.platform = sql->getString(0);

        return DB_NOT_EXIST;
    }

    int32 i = 0;
    data.simple.platform    = sql->getString( i++ );
    data.simple.name        = sql->getString( i++ );
    data.simple.gender      = sql->getInteger( i++ );
    data.simple.avatar      = sql->getInteger( i++ );
    data.simple.team_level  = sql->getInteger( i++ );
    data.simple.team_xp     = sql->getInteger( i++ );
    data.simple.vip_level   = sql->getInteger( i++ );
    data.simple.vip_xp      = sql->getInteger( i++ );
    data.simple.strength    = sql->getInteger( i++ );
    data.simple.guild_id    = sql->getInteger( i++ );
    data.simple.fight_value = sql->getInteger( i++ );

    return DB_SUCCEED;
}
RAW_USER_SAVE( simple )
{
    stream << strprintf( "delete from usersimple where guid = %u limit 1;", guid ) << std::endl;
    stream << strprintf
    (
        "insert into usersimple( guid, name, gender, avatar, team_level, team_xp, vip_level, vip_xp, strength, guild_id, fight_value ) "
        "values( %u, '%s', %hhu, %hu, %u, %u, %u, %u, %u, %u, %u );",
        guid, escape( data.simple.name ).c_str(), data.simple.gender, data.simple.avatar,
        data.simple.team_level, data.simple.team_xp, data.simple.vip_level, data.simple.vip_xp, data.simple.strength,
        data.simple.guild_id, data.simple.fight_value
    ) << std::endl;
}

//info
RAW_USER_LOAD( info )
{
    QuerySql( "select online_time_all,history_fight_value from userinfo where guid = %u limit 1;", guid );

    if ( sql->empty() )
        return DB_SUCCEED;

    int32 i = 0;
    data.info.online_time_all       = sql->getInteger( i++ );
    data.info.history_fight_value   = sql->getInteger( i++ );

    return DB_SUCCEED;

}
RAW_USER_SAVE( info )
{
    stream << strprintf( "delete from userinfo where guid = %u limit 1;", guid ) << std::endl;
    stream << strprintf
    (
        "insert into userinfo ( guid, online_time_all, history_fight_value ) "
        "values ( %u, %u, %u );",
        guid, data.info.online_time_all, data.info.history_fight_value
    ) << std::endl;
}

