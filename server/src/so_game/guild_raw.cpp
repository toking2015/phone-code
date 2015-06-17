#include "raw.h"

#include "proto/guild.h"

//simple
RAW_GUILD_LOAD( simple )
{
    QuerySql( "select name, level, creator_id from guildsimple where guid = %u limit 1;", guid );

    if ( sql->empty() )
        return DB_NOT_EXIST;

    int32 i = 0;
    data.simple.guid        = guid;
    data.simple.name        = sql->getString( i++ );
    data.simple.level       = sql->getInteger( i++ );
    data.simple.creator_id  = sql->getInteger( i++ );

    return DB_SUCCEED;

}
RAW_GUILD_SAVE( simple )
{
    stream << strprintf( "update guildsimple set name = '%s', level = %hu, creator_id = %u where guid = %u limit 1;",
        escape( data.simple.name ).c_str(),
        data.simple.level,
        data.simple.creator_id,
        guid ) << std::endl;
}

//info
RAW_GUILD_LOAD( info )
{
    QuerySql( "select xp, create_time, post_msg from guildinfo where guid = %u limit 1;", guid );

    if ( sql->empty() )
        return DB_SUCCEED;

    int32 i = 0;
    data.info.xp                = sql->getInteger( i++ );
    data.info.create_time       = sql->getInteger( i++ );
    data.info.post_msg          = sql->getString( i++ );

    return DB_SUCCEED;

}
RAW_GUILD_SAVE( info )
{
    stream << strprintf( "update guildinfo set xp = %u, create_time = %u, post_msg = '%s' where guid = %u limit 1;",
        data.info.xp,
        data.info.create_time,
        escape(data.info.post_msg).c_str(),
        guid ) << std::endl;
}

//log_list
RAW_GUILD_LOAD( log_list )
{
    SGuildLog log;
    QuerySql( "select type, time, params from guildlog where guid = %u;", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        log.type = sql->getInteger(i++);
        log.time = sql->getInteger(i++);
        log.params = sql->getString(i++);

        data.log_list.push_back(log);
    }
    return DB_SUCCEED;
}
RAW_GUILD_SAVE( log_list )
{
    stream << strprintf( "delete from guildlog where guid = %u;", guid ) << std::endl;
    stream << "insert into guildlog(guid, type, time, params) values";
    int32 count = 0;
    for (std::vector<SGuildLog>::iterator iter = data.log_list.begin();
        iter != data.log_list.end();
        ++iter)
    {
        if (0 != count)
            stream << ",";
        stream << "(" << guid << "," << iter->type << "," << iter->time << ",'" << escape(iter->params).c_str() << "')";
    }
    stream << ";" << std::endl;
}

//member_list
RAW_GUILD_LOAD( member_list )
{
    SGuildMember member;
    QuerySql( "select role_id, job, join_time from guildmember where guid = %u;", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        member.role_id = sql->getInteger(i++);
        member.job = sql->getInteger(i++);
        member.join_time = sql->getInteger(i++);

        data.member_list.push_back(member);
    }
    return DB_SUCCEED;
}
RAW_GUILD_SAVE( member_list )
{
    stream << strprintf( "delete from guildmember where guid = %u;", guid ) << std::endl;
    stream << "insert into guildmember(guid, role_id, job, join_time) values";
    int32 count = 0;
    for (std::vector<SGuildMember>::iterator iter = data.member_list.begin();
        iter != data.member_list.end();
        ++iter)
    {
        if (0 != count)
            stream << ",";
        stream << "(" << guid << "," << iter->role_id << "," << iter->job << "," << iter->join_time << ")";
    }
    stream << ";" << std::endl;
}
