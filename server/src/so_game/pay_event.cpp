#include "pay_event.h"
#include "pay_imp.h"
#include "user_event.h"
#include "resource/r_globalext.h"
#include "resource/r_rewardext.h"
#include "coin_imp.h"
#include "activity_imp.h"

EVENT_FUNC( pay, SEventPay )
{
    //累加充值次数
    ev.user->data.pay_info.pay_count += 1;

    //首充奖励
    /*if ( ev.user->data.pay_info.pay_count == 1 )
    {
        uint32 first_pay_coin = theGlobalExt.get<uint32>( "first_pay_coin" );
        CRewardData::SData *preward = theRewardExt.Find( first_pay_coin );
        if ( NULL != preward )
            coin::give( ev.user, preward->coins, kPathFirstPay );
    }
    */

    //累计充值额
    ev.user->data.pay_info.pay_sum += ev.price;

    //首充
    if( ev.user->data.pay_info.pay_count == 1 )
        activity::ActivityCheak( ev.user, ev.price, kActivityFactorTypeFirstPay );


    pay::ReplyData(ev.user);
}

EVENT_FUNC( pay, SEventUserLogined )
{
    pay::Process(ev.user);
}

EVENT_FUNC( pay, SEventUserTimeLimit )
{
    pay::TimeLimit(ev.user);
}

