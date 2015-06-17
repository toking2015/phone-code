#include "activity_imp.h"
#include "altar_imp.h"
#include "var_imp.h"
#include "coin_imp.h"
#include "coin_event.h"
#include "activity_dc.h"
#include "user_event.h"
#include "coin_event.h"
#include "link_event.h"
#include "altar_event.h"
#include "pay_event.h"
#include "local.h"
#include "util.h"
#include "common.h"
#include "server.h"
#include "proto/constant.h"

EVENT_FUNC( activity, SEventNetRealDB )
{
    theActivityDC.clear_reward();
    theActivityDC.clear_factor();
    theActivityDC.clear_open();
    theActivityDC.clear_data();

    //发送数据加载请求
    PQActivityRewardLoad rep1;
    local::write( local::realdb, rep1 );

    PQActivityFactorLoad rep2;
    local::write( local::realdb, rep2 );

    PQActivityDataLoad rep3;
    local::write( local::realdb, rep3 );

    PQActivityOpenLoad rep4;
    local::write( local::realdb, rep4 );
}

EVENT_FUNC( activity, SEventUserLogined )
{
    activity::Process( ev.user );
}

EVENT_FUNC( activity, SEventUserTimeLimit )
{
    activity::Process( ev.user );
}

EVENT_FUNC( activity, SEventPay )
{
    activity::ActivityCheak( ev.user, ev.price, kActivityFactorTypeAddPay );

    //每日单笔充
    uint32 limittime = server::local_6_time( 0, 1);
    std::string buff = strprintf( "activity_day_times_pay_times_gold_%d", ev.price);
    uint32 value = var::get( ev.user, buff );
    var::setOnActivity( ev.user, buff, value + 1, limittime );
}

EVENT_FUNC( activity, SEventLotteryCard )
{
    uint32 limittime = server::local_6_time( 0, 1);
    uint32 value = 0;
    if( ev.type == kAltarLotteryByGold )
    {
        value = var::get( ev.user, "day_bet_gold" );
        var::set( ev.user, "day_bet_gold", value + ev.count, limittime );
        activity::ActivityCheak( ev.user, ev.count, kActivityFactorTypeTimeTatalBetGold );
    }
    else if ( ev.type == kAltarLotteryByMoney )
    {
        value = var::get( ev.user, "day_bet_money" );
        var::set( ev.user, "day_bet_money", value + ev.count, limittime );
        activity::ActivityCheak( ev.user, ev.count, kActivityFactorTypeTimeTatalBetMoney );
    }
}

EVENT_FUNC( activity, SEventCoin )
{
    if( ev.set_type == kObjectDel )
    {
        uint32 limittime = server::local_6_time( 0, 1);
        uint32 value = 0;
        if( ev.coin.cate == kCoinGold )
        {
            value = var::get( ev.user, "day_cost_gold" );
            var::set( ev.user, "day_cost_gold", value + ev.coin.val, limittime );
            activity::ActivityCheak( ev.user, ev.coin.val, kActivityFactorTypeTimeTatalGold );
        }
        else if( ev.coin.cate == kCoinMoney )
        {
            value = var::get( ev.user, "day_cost_money" );
            var::set( ev.user, "day_cost_money", value + ev.coin.val, limittime );
            activity::ActivityCheak( ev.user, ev.coin.val, kActivityFactorTypeTimeTatalMoney );
        }
    }
}

