#include "pay_imp.h"
#include "var_imp.h"
#include "coin_imp.h"
#include "resource/r_payext.h"
#include "proto/pay.h"
#include "proto/var.h"
#include "proto/constant.h"
#include "user_dc.h"
#include "pro.h"
#include "local.h"
#include "pay_event.h"
#include "server.h"
#include "resource/r_rewardext.h"
#include "resource/r_globalext.h"

namespace pay
{

void AddPay( SUser* user, std::vector<SUserPay> &list )
{
    for( std::vector<SUserPay>::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
        if ( iter->uid == 0 || iter->price == 0 || iter->time == 0 )
            continue;

        bool in_pay_list = false;
        for( std::vector<SUserPay>::iterator jter = user->data.pay_list.begin();
            jter != user->data.pay_list.end();
            ++jter )
        {
            if ( iter->uid == jter->uid )
            {
                in_pay_list = true;
                break;
            }
        }
        if( !in_pay_list )
            user->data.pay_list.push_back( *iter );
    }

    Process( user );
}

void pay_normal( SUser* user, uint32 value )
{
    //增加货币
    std::vector< S3UInt32 > coins;
    coins.push_back( coin::create( kCoinGold, 0, value * 10 ) );
    coins.push_back( coin::create( kCoinVipXp, 0, value * 10 ) );

    //增加货币
    coin::give( user, coins, kPathPay );
}

void Process( SUser *puser )
{
    std::map< uint32, uint32 > id_count;

    //统计已领取充值
    for ( std::vector< SUserPay >::iterator iter = puser->data.pay_list.begin();
        iter != puser->data.pay_list.end();
        ++iter )
    {
        if ( !state_is( iter->flag, kPayFlagTake ) )
            continue;

        id_count[ iter->price ] += 1;
    }

    for ( std::vector< SUserPay >::iterator iter = puser->data.pay_list.begin();
        iter != puser->data.pay_list.end();
        ++iter )
    {
        if ( state_is( iter->flag, kPayFlagTake ) )
            continue;

        //修改领取标志
        state_add( iter->flag, kPayFlagTake );

        //统计未领取充值
        uint32& count = id_count[ iter->price ];
        count++;

        //普通充值
        pay_normal( puser, iter->price );

        if ( 25 == iter->price )
        {
            //增加一个月的月卡时限
            AddMonthTime( puser, 30 * 24 * 3600, kPathPay );
        }

        //获取赠送数据表
        CPayData::SData* data = thePayExt.Find( iter->price );
        if ( data != NULL )
        {
            int32 index = count - 1;
            if ( index >= 0 && index < (int32)data->present.size() )
            {
                S3UInt32 coin = coin::create( kCoinGold, 0, data->present[ index ] );

                //额外赠送
                coin::give( puser, coin, kPathPayPresent );
            }
        }

        PRPayNotice rep;
        bccopy( rep, puser->ext );

        rep.coin = iter->price ;
        rep.uid  = iter->uid;

        local::write( local::access, rep );

        //支付事件回调
        event::dispatch( SEventPay( puser, kPathPay, iter->uid, iter->price , iter->type ) );
    }
}

void AddMonthTime( SUser* user, uint32 time, uint32 path )
{
    if ( 0 == time )
        return;

    uint32 time_now = server::local_time();

    //当 month_time == 0 或已经超过有效期时, 初始化为 time_now
    if ( user->data.pay_info.month_time < time_now )
        user->data.pay_info.month_time = time_now;

    uint32 old_val = user->data.pay_info.month_time;

    user->data.pay_info.month_time += time;

    ReplyData( user );

    event::dispatch( SEventPayMonthCard( user, path, old_val ) );
}

void ReplyData( SUser* user )
{
    PRPayInfo rep;
    bccopy( rep, user->ext );
    rep.data = user->data.pay_info;
    local::write( local::access, rep );
}

void TimeLimit( SUser* user )
{
    user->data.pay_info.month_reward = 0;

    ReplyData( user );
}

void MonthReward( SUser *user )
{
    uint32 time_now = server::local_time();
    if ( user->data.pay_info.month_time < time_now )
    {
        HandleErrCode(user, kErrPayMonthTimeLack, 0 );
        return;
    }

    if ( 0 != user->data.pay_info.month_reward )
    {
        HandleErrCode(user, kErrPayMonthRewardHaveGet, 0 );
        return;
    }

    S3UInt32 coins;
    coins.cate = kCoinGold;
    coins.val = theGlobalExt.get<uint32>("pay_month_coin");

    coin::give( user, coins, kPathMonthReward );

    PRPayMonthReward rep;
    bccopy( rep, user->ext );
    local::write( local::access, rep );
}

void GetFristPayReward( SUser *user )
{
    uint32 flag = var::get( user, "frist_pay_reward_flag" );
    if( flag == 1 )
    {
        HandleErrCode(user, kErrPayMonthTimeLack, 0 );
        return;
    }

    //首充奖励
    if ( 1 <= user->data.pay_info.pay_count )
    {
        uint32 first_pay_coin = theGlobalExt.get<uint32>( "first_pay_coin" );
        CRewardData::SData *preward = theRewardExt.Find( first_pay_coin );
        if ( NULL != preward )
            coin::give( user, preward->coins, kPathFirstPay );
        var::set( user, "frist_pay_reward_flag", 1);
    }

}


} // namespace pay

