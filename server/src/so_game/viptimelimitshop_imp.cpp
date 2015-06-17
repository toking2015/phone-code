#include "local.h"
#include "pro.h"
#include "misc.h"
#include "util.h"
#include "viptimelimitshop_imp.h"
#include "user_imp.h"
#include "server.h"
#include "resource/r_globalext.h"
#include "resource/r_viptimelimitshopext.h"
#include "proto/viptimelimitshop.h"
#include "proto/constant.h"
#include <math.h>
#include "coin_imp.h"

namespace viptimelimit_shop
{

struct EqualVipTimeLimitGoods
{
    uint32 vip_package_id;
    EqualVipTimeLimitGoods(uint32 _vip_package_id) : vip_package_id(_vip_package_id) {}
    bool operator()(const SUserVipTimeLimitGoods &goods)
    {
        return goods.vip_package_id == vip_package_id;
    }
};

//购买礼包
void Buy(SUser *p_user, uint32 vip_level, uint32 count)
{
    PRVipTimeLimitShopBuy rep;
    SUserVipTimeLimitGoods obj;
    //获取玩家的vip等级
    uint32 now_vip_level = 0;
    now_vip_level = p_user->data.simple.vip_level;
    if( now_vip_level < vip_level )
        HandleErrCode(p_user, kErrVipTimeLimitShopLevelLimit,0);
    uint32 buy_limit_count = theGlobalExt.get<uint32>("vip_timelimitshop_buy_limit");
    //获取当前时间和是星期几
    uint32 now_time = time(NULL);

    //检查玩家是否能够进行购买或者购买数量是否超出了限制
    VipTimeLimitGoodsList::iterator iter = std::find_if(p_user->data.viptimelimit_goods_list.begin(), p_user->data.viptimelimit_goods_list.end(), EqualVipTimeLimitGoods(vip_level));
    if( iter !=  p_user->data.viptimelimit_goods_list.end() )
    {
        if( iter->next_buy_time > now_time && iter->buyed_count == buy_limit_count )
        {
            HandleErrCode(p_user, kErrVipTimeLimitShopBuyLimit, 0);
            return;
        }

        else if( now_time > iter->next_buy_time )
            iter->buyed_count = 0;
    }
    uint32 next_buy_time = GetNextBuyTime( p_user );
    //获取当前周数
    uint32 now_week = GetWeeks( p_user );
    //找出vip礼包限时表最后一周的周数
    uint32 max_weeks = theGlobalExt.get<uint32>("vip_timelimitshop_max_week");
    if( now_week > max_weeks )
        now_week = max_weeks;

    CVipTimeLimitShopData::SData *pvip = theVipTimeLimitShopExt.Find( now_week, vip_level );
    if( NULL == pvip )
        return;

    //检查是否够钱
    S3UInt32 coin;
    coin.cate = pvip->discount_price.cate;
    coin.objid = pvip->discount_price.objid;
    coin.val = pvip->discount_price.val;
    if ( coin::check_take(p_user, coin)  != 0 )
    {
        HandleErrCode(p_user, kErrCoinLack, 0);
        return;
    }

    //判断空间是否足够
    uint32 ret = coin::check_give(p_user, pvip->item );
    // 发放奖励
    if(ret == 0)
    {
        //扣钱
        coin::take(p_user, coin, kPathVipTimeLimitShop);
        //加物品
        coin::give(p_user, pvip->item, kPathVipTimeLimitShop);
    }
    else
        return;

    if( iter == p_user->data.viptimelimit_goods_list.end() )
    {
        obj.vip_package_id = vip_level;
        obj.next_buy_time = next_buy_time;
        obj.buyed_count = 1;
        rep.set_type = kObjectAdd;
        p_user->data.viptimelimit_goods_list.push_back(obj);
    }
    else
    {
        iter->buyed_count += 1;
        iter->next_buy_time = next_buy_time;
        obj.vip_package_id = vip_level;
        obj.next_buy_time = next_buy_time;
        obj.buyed_count = iter->buyed_count;
        rep.set_type = kObjectUpdate;
    }
    rep.buyed_info = obj;
    bccopy(rep, p_user->ext);
    local::write( local::access, rep );

}
//返回当前周数
void ReplyWeek(SUser *p_user)
{
    PRVipTimeLimitShopWeek rep;
    uint32 week = GetWeeks( p_user );
    uint32 next_buy_time = GetNextBuyTime( p_user );
    //找出vip礼包限时表最后一周的周数
    uint32 max_weeks = theGlobalExt.get<uint32>("vip_timelimitshop_max_week");
    if( week > max_weeks )
        week = max_weeks;
    rep.now_week = week;
    rep.buyed_list = p_user->data.viptimelimit_goods_list;
    rep.next_refresh_time = next_buy_time;
    bccopy(rep, p_user->ext);
    local::write( local::access, rep );

}
//计算下次可以购买的时间
uint32 GetNextBuyTime(SUser *p_user)
{
    //开服当天是星期几
    uint32 server_open_time = server::get<uint32>("open_time");
    int32  server_open_weekday = GetWeekday( server_open_time );
    if( server_open_weekday == 0 )
        server_open_weekday = 7;
    //获取当前周数
    uint32 now_week = GetWeeks( p_user);
    //获取当前时间和是星期几
    uint32 now_time = time(NULL);
    uint32  weekday = GetWeekday( now_time );
    if( weekday == 0 )
        weekday = 7;
    uint32 sub_day = GetSubDay( server_open_time, now_time );
    uint32 next_buy_time = 0;
    uint32 now_monday_zerotime = GetWeekZeroTime( now_time );
    uint32 next_monday_zerotime = 0;
    //计算下次可以购买的时间戳
    if( now_week == 1 )
    {
        if(  6 <= server_open_weekday )
        {
            if( weekday == 1 )
                next_monday_zerotime = now_monday_zerotime + 7 * 86400;
            else if ( sub_day < 2 )
                next_monday_zerotime = now_monday_zerotime + 14 * 86400;
            else if ( sub_day > 2 )
                next_monday_zerotime = now_monday_zerotime + 7 * 86400;
        }
        else
            next_monday_zerotime = now_monday_zerotime + 7 * 86400;

        next_buy_time = next_monday_zerotime + 6 * 3600;
    }
    else if( now_week > 1 )
    {
        next_monday_zerotime = now_monday_zerotime + 7 * 86400 ;
        next_buy_time = next_monday_zerotime + 6 * 3600;
    }
    uint32 refresh_time = now_monday_zerotime + 6 * 3600;
    if( now_time < refresh_time )
        next_buy_time -= 7 * 86400;

    return next_buy_time;

}
//计算现在是开服第几周
uint32 GetWeeks(SUser *p_user)
{
    uint32 server_open_time = server::get<uint32>("open_time");
    uint32 now_time = time(NULL);
    uint32 sub_day = GetSubDay( server_open_time, now_time );
    //今天是星期几
    int32  weekday = GetWeekday( now_time );
    if( weekday == 0 )
        weekday = 7;
    //开服当天是星期几
    int32  server_open_weekday = GetWeekday( server_open_time );
    if( server_open_weekday == 0 )
        server_open_weekday = 7;

    //当天距离当前周末相差几天
    int32 now_lack_day = 7 - weekday;
    //开服那天距离周末相差几天
    int32 server_lack_day = 7 - server_open_weekday;
    uint32 sub1 = server_lack_day + 7 + 1;
    uint32 sub2 = server_lack_day + 1;
    uint32 weeks = 0;
    if( 6 <= server_open_weekday )
    {
        if( sub_day < sub1 )
            weeks = 1;
        else
            weeks = (( sub_day + now_lack_day - server_lack_day ) / 7);
    }
    else if( server_open_weekday < 6 )
    {
        if( sub_day < sub2 )
            weeks = 1;
        else
            weeks = (( sub_day + now_lack_day - server_lack_day ) / 7 + 1);
    }

    return weeks;
}

//玩家登陆后判断是否重置商店数据
void CheckRefresh(SUser *p_user)
{
    uint32 now_time = time(NULL);
    int32  weekday = GetWeekday( now_time );
    uint32 now_monday_zerotime = GetWeekZeroTime( now_time );
    uint32 refresh_time = now_monday_zerotime + 6 * 3600;
    if( weekday == 0 )
        weekday = 7;
    if( 1 <= weekday && refresh_time <= now_time )
    {
        for( std::vector<SUserVipTimeLimitGoods>::iterator iter = p_user->data.viptimelimit_goods_list.begin(); iter != p_user->data.viptimelimit_goods_list.end(); ++iter)
        {
            if( iter != p_user->data.viptimelimit_goods_list.end() )
            {
                if( iter->next_buy_time < now_time )
                {
                    iter->next_buy_time = 0;
                    iter->buyed_count = 0;
                }
            }
        }
    }
}

//每天6点判断一次
void TimeLimit(SUser *p_user)
{
    //获取当前星期几和当前周数
    uint32 now_week = GetWeeks( p_user );
    uint32 now_time = time(NULL);
    int32  weekday = GetWeekday( now_time );
    if( weekday == 0 )
        weekday = 7;
    if( weekday == 1  && now_week > 1)
    {
        for( std::vector<SUserVipTimeLimitGoods>::iterator iter = p_user->data.viptimelimit_goods_list.begin(); iter != p_user->data.viptimelimit_goods_list.end(); ++iter)
        {
            if( iter != p_user->data.viptimelimit_goods_list.end() )
            {
                iter->next_buy_time = 0;
                iter->buyed_count = 0;
            }
        }
    }

}
} // namespace viptimelimit_shop




