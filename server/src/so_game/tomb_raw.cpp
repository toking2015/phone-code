#include "raw.h"

#include "proto/tomb.h"

RAW_USER_LOAD( tomb_info )
{
    QuerySql( "select try_count, try_count_now, win_count, max_win_count, reward_count, totem_value_self, totem_value_target, history_win_count, history_reset_count, history_pass_count, history_kill_monster1, history_kill_count1, history_kill_monster2, history_kill_count2, history_kill_monster3, history_kill_count3, history_kill_monster4, history_kill_count4, history_kill_monster5, history_kill_count5 from tomb where role_id = %u", guid );

    if( sql->empty() )
        return DB_SUCCEED;
    int32 i = 0;
    SUserTomb user_tomb;

    data.tomb_info.try_count = sql->getInteger( i++ );
    data.tomb_info.try_count_now = sql->getInteger( i++ );
    data.tomb_info.win_count = sql->getInteger( i++ );
    data.tomb_info.max_win_count = sql->getInteger( i++ );
    data.tomb_info.reward_count = sql->getInteger( i++ );
    data.tomb_info.totem_value_self = sql->getInteger( i++ );
    data.tomb_info.totem_value_target = sql->getInteger( i++ );
    data.tomb_info.history_win_count = sql->getInteger( i++ );
    data.tomb_info.history_reset_count = sql->getInteger( i++ );
    data.tomb_info.history_pass_count = sql->getInteger( i++ );

    for( uint32 i = 0; i < 5; ++i )
    {
        SUserKillInfo info;
        info.monster_id = sql->getInteger( i++ );
        info.count = sql->getInteger( i++ );
        if ( 0 != info.monster_id )
            data.tomb_info.history_kill_count.push_back(info);
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( tomb_info )
{
    stream << strprintf( "delete from tomb where role_id = %u;", guid ) << std::endl;

    stream << "insert into tomb( role_id, try_count, try_count_now, win_count, max_win_count, reward_count, totem_value_self, totem_value_target, history_win_count, history_reset_count, history_pass_count, history_kill_monster1, history_kill_count1, history_kill_monster2, history_kill_count2, history_kill_monster3, history_kill_count3, history_kill_monster4, history_kill_count4, history_kill_monster5, history_kill_count5 ) values";

    stream << "(" << guid << "," << data.tomb_info.try_count << "," << data.tomb_info.try_count_now << "," << data.tomb_info.win_count << "," << data.tomb_info.max_win_count << "," << data.tomb_info.reward_count << "," << data.tomb_info.totem_value_self << "," << data.tomb_info.totem_value_target << "," << data.tomb_info.history_win_count << "," << data.tomb_info.history_reset_count << "," << data.tomb_info.history_pass_count;
    for ( uint32 i = 0; i < 5; ++i )
    {
        if ( i >= data.tomb_info.history_kill_count.size() )
            stream << ",0,0";
        else
            stream << "," << data.tomb_info.history_kill_count[i].monster_id << "," << data.tomb_info.history_kill_count[i].count;
    }

    stream << ");" << std::endl;
}

RAW_USER_LOAD( tomb_target_list )
{
    QuerySql( "select attr, target_id, reward from tomb_target where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        STombTarget tomb_target;

        tomb_target.attr = sql->getInteger( i++ );
        tomb_target.target_id = sql->getInteger( i++ );
        tomb_target.reward = sql->getInteger( i++ );

        data.tomb_target_list.push_back(tomb_target);
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( tomb_target_list )
{
    stream << strprintf( "delete from tomb_target where role_id = %u;", guid ) << std::endl;

    for ( std::vector<STombTarget>::iterator iter = data.tomb_target_list.begin();
        iter != data.tomb_target_list.end();
        ++iter )
    {
        stream << strprintf( "insert into tomb_target( role_id, attr, target_id, reward) values( %u, %u, %u, %u );",
            guid, iter->attr, iter->target_id, iter->reward ) << std::endl;
    }
}

