#include "pro.h"
#include "proto/activity.h"
#include "proto/constant.h"
#include "log.h"

MSG_FUNC( PQActivityRewardLoad )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
    {
        return;
    }

    PRActivityRewardLoad rep;
    bccopy( rep, msg );

    //请求中心数据
    QuerySql( "select guid, `group`, value_1, value_2, value_3 from activity_reward");


    SActivityReward reward;
    std::string str;
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        reward.guid          = sql->getInteger(i++);
        reward.group         = sql->getString(i++);

        reward.value_list.clear();
        for( uint32 j = 0; j < 3; ++j )
        {
            str                 = sql->getString(i++);
            if( !str.empty() )
                reward.value_list.push_back( str );
        }


        rep.list.push_back( reward );

        //发送数据
        if( rep.list.size() >= 512 )
        {
            local::write( local::game, rep );
            rep.list.clear();
        }
    }

    //发送剩余数据
    if ( !rep.list.empty() )
    {
        local::write( local::game, rep );

        rep.list.clear();
    }
}

MSG_FUNC( PQActivityFactorLoad )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
    {
        return;
    }

    PRActivityFactorLoad rep;
    bccopy( rep, msg );

    //请求中心数据
    QuerySql( "select guid, `group`, `desc`, type, value, value_1 from activity_factor");


    SActivityFactor factor;
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        factor.guid          = sql->getInteger(i++);
        factor.group         = sql->getString(i++);
        factor.desc          = sql->getString(i++);
        factor.type          = sql->getInteger(i++);
        factor.value         = sql->getInteger(i++);
        factor.value1        = sql->getInteger(i++);


        rep.list.push_back( factor);

        //发送数据
        if( rep.list.size() >= 512 )
        {
            local::write( local::game, rep );
            rep.list.clear();
        }
    }

    //发送剩余数据
    if ( !rep.list.empty() )
    {
        local::write( local::game, rep );

        rep.list.clear();
    }
}

MSG_FUNC( PQActivityOpenLoad )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
    {
        return;
    }

    PRActivityOpenLoad rep;
    bccopy( rep, msg );

    //请求中心数据
    QuerySql( "select guid, name, data_id, type, first_time, second_time, show_time, hide_time, `group` from activity_open");


    SActivityOpen open;
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        open.guid          = sql->getInteger(i++);
        open.name          = sql->getString(i++);
        open.data_id       = sql->getInteger(i++);
        open.type          = sql->getInteger(i++);
        open.first_time    = sql->getString(i++);
        open.second_time   = sql->getString(i++);
        open.show_time     = sql->getInteger(i++);
        open.hide_time     = sql->getInteger(i++);
        open.group         = sql->getString(i++);


        rep.list.push_back( open );

        //发送数据
        if( rep.list.size() >= 512 )
        {
            local::write( local::game, rep );
            rep.list.clear();
        }
    }

    //发送剩余数据
    if ( !rep.list.empty() )
    {
        local::write( local::game, rep );

        rep.list.clear();
    }
}

MSG_FUNC( PQActivityDataLoad )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
    {
        return;
    }

    PRActivityDataLoad rep;
    bccopy( rep, msg );

    //请求中心数据
    QuerySql( "select guid, `group`, type, cycle, name, `desc`, value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10 from activity_data");

    SActivityData data;
    std::string str;
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        data.guid          = sql->getInteger(i++);
        data.group         = sql->getString(i++);
        data.type          = sql->getInteger(i++);
        data.cycle         = sql->getInteger(i++);
        data.name          = sql->getString(i++);
        data.desc          = sql->getString(i++);

        data.value_list.clear();
        for( uint32 j = 0; j < 10; ++j )
        {
            str                 = sql->getString(i++);
            if( !str.empty() )
                data.value_list.push_back( str );
        }


        rep.list.push_back( data );

        //发送数据
        if( rep.list.size() >= 512 )
        {
            local::write( local::game, rep );
            rep.list.clear();
        }
    }

    //发送剩余数据
    if ( !rep.list.empty() )
    {
        local::write( local::game, rep );

        rep.list.clear();
    }
}


/**
MSG_FUNC( PQActivityOpenSet )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
    {
        return;
    }

    switch( msg.type )
    {
    case kObjectAdd:
        {
            PRActivityOpenSet rep;
            bccopy( rep, msg );

            SActivityOpen open  = msg.open;

            sql->query( "select max(guid) from activity_open" );
            if ( !sql->empty() )
            {
                open.guid = sql->getInteger( 0 ) + 1;
            }

            if( open.guid > 0 )
            {
                sql->execute( "insert into activity_open(`name`,data_id,`type`,`first_time`,`second_time`,show_time,hide_time,`group`) values( '%s', %u, %u, '%s', '%s', %u, %u )", sql->escape( open.name.c_str() ).c_str(), open.data_id, open.type, sql->escape( open.first_time.c_str() ).c_str(), sql->escape( open.second_time.c_str() ).c_str(), open.show_time, open.hide_time, sql->escape( open.group.c_str() ).c_str() );

                rep.type = kObjectAdd;
                rep.open = open;
                local::write( local::game, rep );
            }
        }
        break;
    case kObjectDel:
        {
            sql->execute( "delete from activity_open where guid = %u", msg.guid );
        }
        break;
    }
}

MSG_FUNC( PQActivityDataSet )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
    {
        return;
    }

    switch( msg.type )
    {
    case kObjectAdd:
        {
            PRActivityDataSet rep;
            bccopy( rep, msg );

            SActivityData data  = msg.data;
            sql->query( "select max(guid) from activity_data" );
            if ( !sql->empty() )
            {
                data.guid = sql->getInteger( 0 ) + 1;
            }

            if( data.guid > 0 )
            {
                sql->execute( "insert into activity_data(`type`,cycle,`name`,`value_list`,`reward_list`,`desc`,`group`) values( '%s', %u, %u, '%s', '%s', '%s', '%s' )", sql->escape( data.name.c_str() ).c_str(), data.type, data.cycle, sql->escape( data.value_list.c_str() ).c_str(), sql->escape( data.reward_list.c_str() ).c_str(), sql->escape( data.desc.c_str() ).c_str(), sql->escape( data.group.c_str() ).c_str() );

                rep.type = kObjectAdd;
                rep.data = data;
                local::write( local::game, rep );
            }
        }
        break;
    case kObjectDel:
        {
            sql->execute( "delete from activity_data where guid = %u", msg.guid );
        }
        break;
    }
}
**/

