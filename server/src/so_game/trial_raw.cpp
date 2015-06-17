#include "raw.h"

#include "proto/trial.h"

RAW_USER_LOAD( trial_map )
{
    QuerySql( "select trial_id, trial_val, try_count, reward_count,max_single_val from trial where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        SUserTrial user_trial;

        user_trial.trial_id = sql->getInteger( i++ );
        user_trial.trial_val = sql->getInteger( i++ );
        user_trial.try_count = sql->getInteger( i++ );
        user_trial.reward_count = sql->getInteger( i++ );
        user_trial.max_single_val = sql->getInteger( i++ );

        data.trial_map[ user_trial.trial_id ] = user_trial;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( trial_map )
{
    stream << strprintf( "delete from trial where role_id = %u;", guid ) << std::endl;

    for ( std::map< uint32, SUserTrial >::iterator iter = data.trial_map.begin();
        iter != data.trial_map.end();
        ++iter )
    {
        if ( 0 == iter->second.trial_id )
            continue;
        stream << strprintf( "insert into trial( role_id, trial_id, trial_val, try_count, reward_count, max_single_val) values( %u, %u, %u, %u, %u, %u );",
            guid, iter->second.trial_id, iter->second.trial_val, iter->second.try_count, iter->second.reward_count, iter->second.max_single_val ) << std::endl;
    }
}

RAW_USER_LOAD( trial_reward_map )
{
    QuerySql( "select trial_id, reward, flag from trial_reward where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        SUserTrialReward user_trial_reward;

        user_trial_reward.trial_id  = sql->getInteger( i++ );
        user_trial_reward.reward = sql->getInteger( i++ );
        user_trial_reward.flag = sql->getInteger( i++ );

        data.trial_reward_map[user_trial_reward.trial_id].push_back( user_trial_reward );
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( trial_reward_map )
{
    stream << strprintf( "delete from trial_reward where role_id = %u;", guid ) << std::endl;

    for ( std::map< uint32, std::vector<SUserTrialReward> >::iterator iter = data.trial_reward_map.begin();
        iter != data.trial_reward_map.end();
        ++iter )
    {
        for( std::vector<SUserTrialReward>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            stream << strprintf( "insert into trial_reward( role_id, trial_id, reward, flag ) values( %u, %u, %u, %u );",
                guid, jter->trial_id, jter->reward, jter->flag ) << std::endl;
        }
    }
}

