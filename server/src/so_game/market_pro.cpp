#include "pro.h"
#include "proto/constant.h"
#include "proto/market.h"
#include "local.h"
#include "user_dc.h"
#include "remote.h"
#include "proto/coin.h"
#include "resource/r_marketext.h"
#include "item_imp.h"
#include "coin_imp.h"
#include "server.h"
#include "mail_imp.h"
#include "market_imp.h"
#include "market_event.h"

MSG_FUNC( PQMarketBuyList )
{
    QU_ON( user , msg.role_id );

    msg.sid     = market::get_social_sid();
    msg.level   = user->data.simple.team_level;

    remote::write( local::social, msg );
}
MSG_FUNC( PQMarketCustomBuyList )
{
    QU_ON( user , msg.role_id );

    msg.sid     = market::get_social_sid();

    remote::write( local::social, msg );
}

MSG_FUNC( PRMarketCustomBuyList )
{
    QU_ON( user , msg.role_id );
    bccopy( msg, user->ext );

    local::write( local::access, msg );
}

MSG_FUNC( PRMarketBuyList )
{
    QU_ON( user , msg.role_id );
    bccopy( msg, user->ext );

    local::write( local::access, msg );
}

MSG_FUNC( PQMarketSellList )
{
    QU_ON( user, msg.role_id );

    msg.sid     = market::get_social_sid();

    remote::write( local::social, msg );
}
MSG_FUNC( PRMarketSellList )
{
    QU_ON( user, msg.role_id );
    bccopy( msg, user->ext );

    local::write( local::access, msg );
}

MSG_FUNC( PRMarketSellData )
{
    QU_ON( user, msg.role_id );
    bccopy( msg, user->ext );

    local::write( local::access, msg );
}

MSG_FUNC( PRMarketCargoDown )
{
    QU_OFF( user, msg.role_id );

    S3UInt32 &coin = msg.data.coin;

    uint32 time_now = server::local_time();

    mail::send(
        kMailFlagSystem,
        msg.role_id,
        "拍卖行",
        "你上架的物品已下架",
        strprintf( "你于{date:%u} {time:%u}下架物品:{coin:%u%%%u%%%u}",
            time_now, time_now,
            coin.cate, coin.objid, coin.val ),
        coin,
        kPathMarketCargoDown);
}

MSG_FUNC( PQMarketCargoUp )
{
    QU_ON( user, msg.role_id );

    msg.sid     = market::get_social_sid();

    if ( msg.percent < 80 || msg.percent > 180 )
    {
        HandleErrCode( user, kErrMarketPercentRound, 0 );
        return;
    }

    if ( msg.coin.cate != kCoinItem || msg.coin.val <= 0 )
    {
        HandleErrCode( user, kErrMarketCargoCate, 0 );
        return;
    }

    CMarketData::SData* market = theMarketExt.Find( msg.coin.objid );
    if ( market == NULL )
    {
        HandleErrCode( user, kErrMarketCargoCate, msg.coin.objid );
        return;
    }

    uint32 unbind_count = item::GetItemCountNotFlag( user, msg.coin.objid, kCoinFlagBind );
    if ( unbind_count < msg.coin.val )
    {
        HandleErrCode( user, kErrMarketCargoNotEnough, 0 );
        return;
    }

    //扣除货物
    item::DelItemByIdNotFlag( user, msg.coin.objid, msg.coin.val, kCoinFlagBind, kPathMarketCargoUp );

    remote::write( local::social, msg );

    //货物上架事件
    event::dispatch( SEventMarketCargoUp( user, kPathMarketCargoUp ) );
}

MSG_FUNC( PQMarketCargoDown )
{
    QU_ON( user, msg.role_id );

    remote::write( local::social, msg );
}

MSG_FUNC( PQMarketCargoChange )
{
    QU_ON( user, msg.role_id );

    if ( msg.cargo_id == 0 )
    {
        HandleErrCode( user, kErrMarketCargoNoExist, 0 );
        return;
    }

    if ( msg.percent < 80 || msg.percent > 180 )
    {
        HandleErrCode( user, kErrMarketPercentRound, 0 );
        return;
    }

    remote::write( local::social, msg );
}

MSG_FUNC( PQMarketBuy )
{
    QU_ON( user, msg.role_id );

    if ( msg.count <= 0 )
    {
        HandleErrCode( user, kErrMarketParam, 0 );
        return;
    }

    //系统购买
    if ( msg.guid == 0 )
    {
        CMarketData::SData* market = theMarketExt.Find( msg.value );
        if ( market == NULL )
        {
            HandleErrCode( user, kErrMarketCargoNoExchange, msg.value );
            return;
        }

        S3UInt32 coin = coin::create( kCoinMoney, 0, msg.count * market->value * 250 / 100 );
        int32 result = coin::check_take( user, coin );
        if ( result != 0 )
        {
            HandleErrCode( user, kErrCoinLack, result );
            return;
        }

        //扣取货币
        coin::take( user, coin, kPathMarketBuy );

        coin = coin::create( kCoinItem, market->item_id, msg.count );

        //给予货物
        coin::give( user, coin, kPathMarketBuy, kCoinFlagBind );
        return;
    }

    if ( msg.value <= 0 || msg.value > user->data.coin.money )
    {
        HandleErrCode( user, kErrCoinLack, kCoinMoney );
        return;
    }

    //先预扣除货币, 但不通知用户货币变更
    user->data.coin.money -= msg.value;

    remote::write( local::social, msg );
}
MSG_FUNC( PRMarketBuy )
{
    QU_OFF( user, msg.role_id );
    bccopy( msg, user->ext );

    //回补用户货币
    user->data.coin.money += msg.value;

    if ( msg.result == 0 )
    {
        //扣除用户货币
        S3UInt32 coin = coin::create( kCoinMoney, 0, msg.value );
        coin::take( user, coin, kPathMarketBuy );

        //增加用户物品
        coin::give( user, msg.coin, kPathMarketBuy, kCoinFlagBind );
    }

    local::write( local::access, msg );
}

MSG_FUNC( PQMarketBatchMatch )
{
    QU_ON( user, msg.role_id );

    msg.sid = market::get_social_sid();

    remote::write( local::social, msg );
}
MSG_FUNC( PRMarketBatchMatch )
{
    QU_ON( user, msg.role_id );

    local::write( local::access, msg );
}

struct coin_type_objid_equal
{
    S3UInt32& coin;
    coin_type_objid_equal( S3UInt32& c ) : coin(c){}

    bool operator()( S3UInt32& data )
    {
        return ( coin.cate == data.cate && coin.objid == data.objid );
    }
};
MSG_FUNC( PQMarketBatchBuy )
{
    QU_ON( user, msg.role_id );

    msg.sid     = market::get_social_sid();
    msg.value = 0;

    PRMarketBatchBuy rep;
    bccopy( rep, user->ext );

    for ( std::vector< SMarketMatch >::iterator iter = msg.cargos.begin();
        iter != msg.cargos.end();
        ++iter )
    {
        if ( iter->coin.val <= 0 )
        {
            /*
            rep.result = kErrMarketCargoNoExist;
            local::write( local::access, rep );
            return;
            */
            continue;
        }

        if ( iter->coin.cate != kCoinItem )
        {
            rep.result = kErrMarketCargoNoExchange;
            local::write( local::access, rep );
            return;
        }

        CMarketData::SData* market = theMarketExt.Find( iter->coin.objid );
        if ( market == NULL )
        {
            rep.result = kErrMarketCargoNoExchange;
            local::write( local::access, rep );
            return;
        }

        //累计购买品最大价值
        msg.value += market->value * iter->coin.val * iter->percent / 100;
    }

    if ( msg.value > user->data.coin.money )
    {
        rep.result = kErrCoinLack;
        local::write( local::access, rep );
        return;
    }

    //先预扣除货币, 但不通知用户货币变更
    user->data.coin.money -= msg.value;

    remote::write( local::social, msg );
}
MSG_FUNC( PRMarketBatchBuy )
{
    QU_OFF( user, msg.role_id );
    bccopy( msg, user->ext );

    //返还用户预扣除货币值
    user->data.coin.money += msg.value;

    uint32 path = msg.path ? msg.path : kPathMarketBuy;
    if ( msg.result == 0 )
    {
        //扣除购买所需货币
        S3UInt32 money = coin::create( kCoinMoney, 0, msg.value );
        coin::take( user, money, path );

        //增加货币
        coin::give( user, msg.coins, path, kCoinFlagBind );
    }

    //通知客户端
    local::write( local::access, msg );
}

MSG_FUNC( PQMarketBuyAll )
{
    QU_ON( user, msg.role_id );

    PRMarketBuyAll rep;
    bccopy( rep, msg );

    if ( msg.coins.empty() )
    {
        rep.result = kErrMarketCargoNoExist;
        local::write( local::access, rep );
        return;
    }

    msg.value = 0;
    for ( std::vector< S3UInt32 >::iterator iter = msg.coins.begin();
        iter != msg.coins.end();
        ++iter )
    {
        if ( iter->val <= 0 )
        {
            rep.result = kErrMarketCargoNoExist;
            local::write( local::access, rep );
            return;
        }

        msg.value += iter->val;
    }

    if ( msg.value > user->data.coin.money )
    {
        rep.result = kErrCoinLack;
        local::write( local::access, rep );
        return;
    }

    //先预扣除货币, 但不通知用户货币变更
    user->data.coin.money -= msg.value;

    remote::write( local::social, msg );

}

MSG_FUNC( PRMarketBuyAll )
{
    QU_OFF( user, msg.role_id );
    bccopy( msg, user->ext );

    //返还用户预扣除货币值
    user->data.coin.money += msg.value;

    if ( msg.result == 0 )
    {
        //扣除购买所需货币
        S3UInt32 money = coin::create( kCoinMoney, 0, msg.value );
        coin::take( user, money, kPathMarketBuy );

        //增加货币
        coin::give( user, msg.coin, kPathMarketBuy, kCoinFlagBind );
    }

    //通知客户端
    local::write( local::access, msg );
}


MSG_FUNC( PRMarketSell )
{
    if ( msg.role_id == 0 )
    {
        LOG_ERROR( "PRMarketSell.role_id must not be 0!" );
        return;
    }

    QU_OFF( user, msg.role_id );

    //10% 税收
    S3UInt32 seller_give_coin = coin::create( kCoinMoney, 0, msg.value * 90 / 100 );

    uint32 time_now = server::local_time();

    mail::send(
        kMailFlagSystem,
        msg.role_id,
        "拍卖行",
        "你上架的物品已售出",
        strprintf( "你于{date:%u} {time:%u}售出物品:{coin:%u%%%u%%%u}, 获得{coin:%u%%%u%%%u}",
            time_now, time_now,
            msg.coin.cate, msg.coin.objid, msg.coin.val,
            seller_give_coin.cate, seller_give_coin.objid, seller_give_coin.val ),
        seller_give_coin,
        kPathMarketSell );

    SMarketLog data;
    data.name     = msg.name;
    data.coin     = msg.coin;
    data.time     = time_now;
    data.price    = msg.value;
    market::reply_log_data( user, data );

    if ( user->data.market_log.size() > 20 )
        user->data.market_log.erase( user->data.market_log.begin() );

    user->data.market_log.push_back( data );

    //确认已经收到钱可以更新
    PQMarketSell req;
    req.role_id = msg.role_id;
    req.cargo_id = msg.cargo_id;
    remote::write(local::social, req);
}

