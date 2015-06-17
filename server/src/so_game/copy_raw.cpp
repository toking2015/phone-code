#include "raw.h"

#include "proto/copy.h"

//copy
RAW_USER_LOAD( copy )
{
    QuerySql( "select copy_id, posi, `index`, status from copy_user where role_id = %u", guid );
    if ( !sql->empty() )
    {
        int32 i = 0;

        data.copy.copy_id       = sql->getInteger(i++);
        data.copy.posi          = sql->getInteger(i++);
        data.copy.index         = sql->getInteger(i++);
        data.copy.status        = sql->getInteger(i++);
    }

    QuerySql( "select `key`, `index`, event_type, event_tid, event_eid from copy_event where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        S3UInt32 s3;

        uint32 key      = sql->getInteger(0);
        uint32 index    = sql->getInteger(1);

        s3.cate       = sql->getInteger(2);
        s3.objid      = sql->getInteger(3);
        s3.val        = sql->getInteger(4);

        std::vector< S3UInt32 >* array = &data.copy.chunk;

        SGutInfo* gut_info = NULL;
        if ( key != 0 )
        {
            gut_info = &data.copy.gut[key];
            gut_info->gut_id = key;

            array = &gut_info->event;
        }

        if ( index >= array->size() )
            array->resize( index + 1 );

        (*array)[ index ] = s3;
    }

    QuerySql( "select `index`, reward_cate, reward_id, reward_guage from copy_reward where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        S3UInt32 s3;

        uint32 index    = sql->getInteger(0);

        s3.cate         = sql->getInteger(1);
        s3.objid        = sql->getInteger(2);
        s3.val          = sql->getInteger(3);

        if ( index >= data.copy.reward.size() )
            data.copy.reward.resize( index + 1 );

        data.copy.reward[ index ] = s3;
    }

    QuerySql( "select index_1, index_2, cate, objid, val from copy_coins where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        S3UInt32 s3;

        uint32 index_1  = sql->getInteger(0);
        uint32 index_2  = sql->getInteger(1);

        s3.cate         = sql->getInteger(2);
        s3.objid        = sql->getInteger(3);
        s3.val          = sql->getInteger(4);

        if ( index_1 >= data.copy.coins.size() )
            data.copy.coins.resize( index_1 + 1 );
        if ( index_2 >= data.copy.coins[ index_1 ].size() )
            data.copy.coins[ index_1 ].resize( index_2 + 1 );

        data.copy.coins[ index_1 ][ index_2 ] = s3;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( copy )
{
    //数据清除
    stream << strprintf( "delete from copy_user where role_id = %u;", guid ) << std::endl;
    stream << strprintf( "delete from copy_event where role_id = %u;", guid ) << std::endl;
    stream << strprintf( "delete from copy_reward where role_id = %u;", guid ) << std::endl;
    stream << strprintf( "delete from copy_coins where role_id = %u;", guid ) << std::endl;

    //copy_user
    stream << strprintf( "insert into copy_user values( %u, %u, %d, %d, %u );",
        guid, data.copy.copy_id, data.copy.posi, data.copy.index, data.copy.status ) << std::endl;

    //copy_event
    if ( !data.copy.chunk.empty() )
    {
        stream << "insert into copy_event values";
        for ( int32 i = 0; i < (int32)data.copy.chunk.size(); ++i )
        {
            if ( i > 0 )
                stream << ", ";

            S3UInt32& s3 = data.copy.chunk[i];
            stream << strprintf( "( %u, 0, %d, %u, %u, %u )", guid, i, s3.cate, s3.objid, s3.val );
        }
        stream << ";" << std::endl;
    }

    if ( !data.copy.gut.empty() )
    {
        for ( std::map< uint32, SGutInfo >::iterator iter = data.copy.gut.begin();
            iter != data.copy.gut.end();
            ++iter )
        {
            uint32 key = iter->first;
            std::vector< S3UInt32 >& list = iter->second.event;

            if ( !list.empty() )
            {
                stream << "insert into copy_event values";
                for ( int32 i = 0; i < (int32)list.size(); ++i )
                {
                    if ( i > 0 )
                        stream << ", ";

                    S3UInt32& s3 = list[i];
                    stream << strprintf( "( %u, %u, %d, %u, %u, %u )", guid, key, i, s3.cate, s3.objid, s3.val );
                }
                stream << ";" << std::endl;
            }
        }
    }

    //copy_reward
    if ( !data.copy.reward.empty() )
    {
        stream << "insert into copy_reward values";
        for ( int32 i = 0; i < (int32)data.copy.reward.size(); ++i )
        {
            if ( i > 0 )
                stream << ", ";

            S3UInt32& s3 = data.copy.reward[i];
            stream << strprintf( "( %u, %d, %u, %u, %u )", guid, i, s3.cate, s3.objid, s3.val );
        }
        stream << ";" << std::endl;
    }

    //copy_coins
    if ( !data.copy.coins.empty() )
    {
        bool is_first = true;
        for ( int32 i = 0; i < (int32)data.copy.coins.size(); ++i )
        {
            for ( int32 j = 0; j < (int32)data.copy.coins[i].size(); ++j )
            {
                if ( is_first )
                {
                    is_first = false;
                    stream << "insert into copy_coins values";
                }
                else
                    stream << ", ";

                S3UInt32& s3 = data.copy.coins[i][j];
                stream << strprintf( "( %u, %d, %d, %u, %u, %u )", guid, i, j, s3.cate, s3.objid, s3.val );
            }
        }

        if ( !is_first )
            stream << ";" << std::endl;
    }
}

//copy_log
RAW_USER_LOAD( copy_log_map )
{
    QuerySql( "select copy_id, time from copy_log where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        SCopyLog copy_log;
        copy_log.copy_id        = sql->getInteger(0);
        copy_log.time           = sql->getInteger(1);

        data.copy_log_map[ copy_log.copy_id ] = copy_log;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( copy_log_map )
{
    stream << strprintf( "delete from copy_log where role_id = %u;", guid ) << std::endl;

    if ( !data.copy_log_map.empty() )
    {
        stream << "insert into copy_log values";

        for ( std::map< uint32, SCopyLog >::iterator iter = data.copy_log_map.begin();
            iter != data.copy_log_map.end();
            ++iter )
        {
            if ( iter != data.copy_log_map.begin() )
                stream << ", ";

            stream << strprintf( "( %u, %u, %u )", guid, iter->first, iter->second.time );
        }

        stream << ";" << std::endl;
    }
}

//mopup_times
RAW_USER_LOAD( mopup )
{
    QuerySql( "select type, attr, boss_id, `value` from copy_mopup where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        uint32 mopup_type       = sql->getInteger(i++);
        uint32 mopup_attr       = sql->getInteger(i++);
        uint32 boss_id          = sql->getInteger(i++);
        uint32 value            = sql->getInteger(i++);

        std::map< uint32, uint32 >* map = NULL;

        switch ( mopup_type )
        {
        case kCopyMopupTypeNormal:
            {
                switch ( mopup_attr )
                {
                case kCopyMopupAttrRound:
                    map = &data.mopup.normal_round;
                    break;
                case kCopyMopupAttrTimes:
                    map = &data.mopup.normal_times;
                    break;
                case kCopyMopupAttrReset:
                    map = &data.mopup.normal_reset;
                    break;
                }
            }
            break;
        case kCopyMopupTypeElite:
            {
                switch ( mopup_attr )
                {
                case kCopyMopupAttrRound:
                    map = &data.mopup.elite_round;
                    break;
                case kCopyMopupAttrTimes:
                    map = &data.mopup.elite_times;
                    break;
                case kCopyMopupAttrReset:
                    map = &data.mopup.elite_reset;
                    break;
                }
            }
            break;
        }

        if ( map == NULL )
            continue;

        (*map)[ boss_id ] = value;
    }

    return 0;
}

RAW_USER_SAVE( mopup )
{
    stream << strprintf( "delete from copy_mopup where role_id = %u;", guid ) << std::endl;

    if ( !data.mopup.normal_round.empty() || !data.mopup.elite_round.empty() ||
        !data.mopup.normal_times.empty() || !data.mopup.elite_times.empty() )
    {
        bool is_first = true;

        stream << "insert into copy_mopup values";

        //普通副本阵亡数
        for ( std::map< uint32, uint32 >::iterator iter = data.mopup.normal_round.begin();
            iter != data.mopup.normal_round.end();
            ++iter )
        {
            if ( is_first )
                is_first = false;
            else
                stream << ',';

            stream << strprintf( "( %u, %u, %u, %u, %u )",
                guid, kCopyMopupTypeNormal, kCopyMopupAttrRound, iter->first, iter->second );
        }

        //精英副本阵亡数
        for ( std::map< uint32, uint32 >::iterator iter = data.mopup.elite_round.begin();
            iter != data.mopup.elite_round.end();
            ++iter )
        {
            if ( is_first )
                is_first = false;
            else
                stream << ',';

            stream << strprintf( "( %u, %u, %u, %u, %u )",
                guid, kCopyMopupTypeElite, kCopyMopupAttrRound, iter->first, iter->second );
        }

        //普通副本扫荡数
        for ( std::map< uint32, uint32 >::iterator iter = data.mopup.normal_times.begin();
            iter != data.mopup.normal_times.end();
            ++iter )
        {
            if ( is_first )
                is_first = false;
            else
                stream << ',';

            stream << strprintf( "( %u, %u, %u, %u, %u )",
                guid, kCopyMopupTypeNormal, kCopyMopupAttrTimes, iter->first, iter->second );
        }

        //精英副本扫荡数
        for ( std::map< uint32, uint32 >::iterator iter = data.mopup.elite_times.begin();
            iter != data.mopup.elite_times.end();
            ++iter )
        {
            if ( is_first )
                is_first = false;
            else
                stream << ',';

            stream << strprintf( "( %u, %u, %u, %u, %u )",
                guid, kCopyMopupTypeElite, kCopyMopupAttrTimes, iter->first, iter->second );
        }

        //普通副本重置数
        for ( std::map< uint32, uint32 >::iterator iter = data.mopup.normal_reset.begin();
            iter != data.mopup.normal_reset.end();
            ++iter )
        {
            if ( is_first )
                is_first = false;
            else
                stream << ',';

            stream << strprintf( "( %u, %u, %u, %u, %u )",
                guid, kCopyMopupTypeNormal, kCopyMopupAttrReset, iter->first, iter->second );
        }

        //精英副本重置数
        for ( std::map< uint32, uint32 >::iterator iter = data.mopup.elite_reset.begin();
            iter != data.mopup.elite_reset.end();
            ++iter )
        {
            if ( is_first )
                is_first = false;
            else
                stream << ',';

            stream << strprintf( "( %u, %u, %u, %u, %u )",
                guid, kCopyMopupTypeElite, kCopyMopupAttrReset, iter->first, iter->second );
        }
        stream << ";" << std::endl;
    }
}

//area_log
RAW_USER_LOAD( area_log_map )
{
    QuerySql( "select area_id, normal_full_take_time, elite_full_take_time, normal_pass_take_time, elite_pass_take_time from area_log where role_id = %u", guid );
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        SAreaLog area_log;

        area_log.area_id        = sql->getInteger(0);
        area_log.normal_full_take_time   = sql->getInteger(1);
        area_log.elite_full_take_time    = sql->getInteger(2);
        area_log.normal_pass_take_time   = sql->getInteger(3);
        area_log.elite_pass_take_time    = sql->getInteger(4);

        data.area_log_map[ area_log.area_id ] = area_log;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( area_log_map )
{
    stream << strprintf( "delete from area_log where role_id = %u;", guid ) << std::endl;

    if ( !data.area_log_map.empty() )
    {
        stream << "insert into area_log values";

        for ( std::map< uint32, SAreaLog >::iterator iter = data.area_log_map.begin();
            iter != data.area_log_map.end();
            ++iter )
        {
            if ( iter != data.area_log_map.begin() )
                stream << ", ";

            stream << strprintf( "( %u, %u, %u, %u, %u, %u )",
                guid, iter->first,
                iter->second.normal_full_take_time, iter->second.elite_full_take_time,
                iter->second.normal_pass_take_time, iter->second.elite_pass_take_time );
        }

        stream << ";" << std::endl;
    }
}

