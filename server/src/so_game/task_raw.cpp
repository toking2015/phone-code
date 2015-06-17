#include "raw.h"

#include "proto/task.h"

//当前任务
RAW_USER_LOAD( task_map )
{
    QuerySql( "select task_id, cond, create_time from task where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserTask task;

        task.task_id            = sql->getInteger(i++);
        task.cond               = sql->getInteger(i++);
        task.create_time        = sql->getInteger(i++);

        data.task_map[ task.task_id ] = task;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( task_map )
{
    stream << strprintf( "delete from task where role_id = %u;", guid ) << std::endl;

    if ( !data.task_map.empty() )
    {
        stream << "insert into task( role_id, task_id, cond, create_time ) values";
        for ( std::map< uint32, SUserTask >::iterator iter = data.task_map.begin();
            iter != data.task_map.end();
            ++iter )
        {
            SUserTask& task = iter->second;

            if ( iter != data.task_map.begin() )
                stream << ", ";

            stream << "( " << guid << ", " << task.task_id << ", " << task.cond << ", " << task.create_time << " )";
        }
        stream << std::endl;
    }
}

//任务完成记录
RAW_USER_LOAD( task_log_map )
{
    QuerySql( "select task_id, create_time, finish_time from task_log where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserTaskLog task_log;

        task_log.task_id            = sql->getInteger(i++);
        task_log.create_time        = sql->getInteger(i++);
        task_log.finish_time        = sql->getInteger(i++);

        data.task_log_map[ task_log.task_id ] = task_log;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( task_log_map )
{
    stream << strprintf( "delete from task_log where role_id = %u;", guid ) << std::endl;

    if ( !data.task_log_map.empty() )
    {
        stream << "insert into task_log( role_id, task_id, create_time, finish_time ) values";
        for ( std::map< uint32, SUserTaskLog >::iterator iter = data.task_log_map.begin();
            iter != data.task_log_map.end();
            ++iter )
        {
            SUserTaskLog& task_log = iter->second;

            if ( iter != data.task_log_map.begin() )
                stream << ", ";

            stream << "( " << guid << ", " << task_log.task_id << ", " << task_log.create_time << ", " << task_log.finish_time  << " )";
        }
        stream << std::endl;
    }
}

//日常任务列表
RAW_USER_LOAD( task_day_map )
{
    QuerySql( "select task_id, create_time, finish_time from task_day where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserTaskDay task_day;

        task_day.task_id            = sql->getInteger(i++);
        task_day.create_time        = sql->getInteger(i++);
        task_day.finish_time        = sql->getInteger(i++);

        data.task_day_map[ task_day.task_id ] = task_day;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( task_day_map )
{
    stream << strprintf( "delete from task_day where role_id = %u;", guid ) << std::endl;

    if ( !data.task_day_map.empty() )
    {
        stream << "insert into task_day( role_id, task_id, create_time, finish_time ) values";
        for ( std::map< uint32, SUserTaskDay >::iterator iter = data.task_day_map.begin();
            iter != data.task_day_map.end();
            ++iter )
        {
            SUserTaskDay& task_day = iter->second;

            if ( iter != data.task_day_map.begin() )
                stream << ", ";

            stream << "( " << guid << ", " << task_day.task_id << ", " << task_day.create_time << ", " << task_day.finish_time  << " )";
        }
        stream << std::endl;
    }
}

//日常任务积分奖励
RAW_USER_LOAD(day_task_reward_list)
{
    QuerySql("select reward_id from task_day_val_reward where role_id = %u", guid);
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        data.day_task_reward_list.push_back(sql->getInteger(i++));
    }
    return DB_SUCCEED;
}

RAW_USER_SAVE(day_task_reward_list)
{
    stream << strprintf( "delete from task_day_val_reward where role_id = %u;", guid ) << std::endl;
    if ( !data.day_task_reward_list.empty() )
    {
        stream << "insert into task_day_val_reward( role_id, reward_id ) values";
        for (std::vector<uint32>::iterator iter = data.day_task_reward_list.begin();
            iter != data.day_task_reward_list.end();
            ++iter)
        {
            if (iter != data.day_task_reward_list.begin())
                stream << ",";
            stream << "(" << guid << "," << *iter << ")";
        }
        stream << std::endl;
    }
}
