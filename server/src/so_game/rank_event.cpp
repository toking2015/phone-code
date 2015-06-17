#include "rank_event.h"
#include "rank_imp.h"
#include "link_event.h"
#include "system_event.h"
#include "proto/rank.h"
#include "local.h"
#include "dc.h"
#include "resource/r_rankcopyext.h"
#include "server.h"
#include "util.h"
#include "jsonconfig.h"
#include "systimemgr.h"
#include "log.h"
#include "coin_imp.h"
#include "var_imp.h"
#include "link_event.h"
#include "server_event.h"
#include "coin_event.h"
#include "totem_event.h"
#include "soldier_event.h"
#include "copy_event.h"
#include "equip_event.h"
#include "team_event.h"
#include "temple_event.h"
#include "proto/market.h"
#include "proto/constant.h"

void rank_each_load( std::pair< const uint32, rank::FRankCompare >& pair )
{
    PQRankLoad msg;
    msg.rank_type = pair.first;

    //先发送即时数据加载, 顺序不能变
    msg.rank_attr = kRankAttrReal;
    local::write( local::realdb, msg );

    //再发送记录数据加载, 顺序不能变
    msg.rank_attr = kRankAttrCopy;
    local::write( local::realdb, msg );
}

struct rank_copy_each_reg_timer
{
    uint32 open_time;
    rank_copy_each_reg_timer() : open_time( server::get<uint32>( "open_time" ) ){}
    bool operator()( std::pair< const uint32, CRankCopyData::SData* >& pair )
    {
        CRankCopyData::SData* pData = pair.second;

        time_t t_time = open_time;
        struct tm t_tm = {0};

        std::string key = strprintf( "rank_copy_time_%u", pData->rank );

        localtime_r( &t_time, &t_tm );

        Json::Value json;
        json[ "rank_type" ] = pData->rank;

        int32 delay_type = 0;
        int32 delay_value = 0;
        switch( pData->cyc )
        {
        case kRankCycDay:
            {
                delay_type = CSysTimeMgr::Day;
                delay_value = pData->delay;
            }
            break;
        case kRankCycWeek:
            {
                t_time = open_time + ( pData->delay - t_tm.tm_wday ) * 86400;
                localtime_r( &t_time, &t_tm );

                delay_type = CSysTimeMgr::Day;
                delay_value = 7;
            }
            break;
        case kRankCycMonth:
            {
                delay_type = CSysTimeMgr::Month;
                delay_value = 1;

            }
            break;
        }

        std::string timeset =
            strprintf( "%u/%u/%u %s", t_tm.tm_year + 1900, t_tm.tm_mon + 1, t_tm.tm_mday, pData->time.c_str() );

        //LOG_ERROR("rank_copy_rule delay_type:%u,delay_value:%u,timeset:%s",delay_type,delay_value,timeset.c_str());
        theSysTimeMgr.AddLoop( "#rank_copy_rule", CJson::Write( json ), timeset.c_str(), NULL, delay_type, delay_value, 0 );

        return true;
    }
};

EVENT_FUNC( rank, SEventNetRealDB )
{
    //发送数据加载请求
    dc::safe_each( rank::rank_compare_map(), rank_each_load );
}

EVENT_FUNC( rank, SEventServerInfo )
{
    //开服，open_time=0,可忽略
    theSysTimeMgr.RemoveLoop( "#rank_copy_rule" );
    theRankCopyExt.Each( rank_copy_each_reg_timer() );
}


EVENT_FUNC( rank, SEventCoin )
{
    if( ev.coin.cate == kCoinSoldier )
    {
        rank::UpdateSoldier( ev.user );
    }
    else if( ev.coin.cate == kCoinTotem )
    {
        rank::UpdateTotem( ev.user );
    }
    else if( ev.path == kPathMarketBuy || ev.path == kPathMarketSell || ev.path == kPathMarketAutoBuy )
    {
        if( ev.coin.cate != kCoinMoney )
            return;

        uint32 limittime = server::local_6_time( 0, 1);
        if( ev.user->data.other.market_day_time < limittime )
        {
            ev.user->data.other.market_day_get  = 0;
            ev.user->data.other.market_day_cost = 0;
            ev.user->data.other.market_day_time = limittime;
        }

        if( ev.set_type == kObjectAdd )
        {
            ev.user->data.other.market_day_get += ev.coin.val;
        }
        else if( ev.set_type == kObjectDel )
        {
            ev.user->data.other.market_day_cost += ev.coin.val;
        }
        rank::UpdateMarket( ev.user );
    }
    else if( ev.coin.cate == kCoinStar )
    {
        rank::UpdateCopy( ev.user );
    }
}

EVENT_FUNC( rank, SEventSoldierStarUp )
{
    rank::UpdateSoldier( ev.user );
}

EVENT_FUNC( rank, SEventTotemLevelUp )
{
    rank::UpdateTotem( ev.user );
}

EVENT_FUNC( rank, SEventCopyFinished )
{
    rank::UpdateCopy( ev.user );
    rank::UpdateTeamLevel( ev.user );
}

EVENT_FUNC( rank, SEventEquipGradeUpdate )
{
    rank::UpdateEquip( ev.user );
}

EVENT_FUNC( rank, SEventTempleScoreChanged )
{
    rank::UpdateTemple( ev.user );
}

EVENT_FUNC( rank, SEventTeamLevelUp )
{
    rank::UpdateSoldier( ev.user );
    rank::UpdateTotem( ev.user );
    rank::UpdateCopy( ev.user );
    rank::UpdateEquip( ev.user );
    rank::UpdateMarket( ev.user );
    rank::UpdateTeamLevel( ev.user );
    rank::UpdateTemple( ev.user );
}
