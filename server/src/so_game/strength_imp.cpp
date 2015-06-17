#include "strength_imp.h"
#include "var_imp.h"
#include "coin_imp.h"
#include "proto/strength.h"
#include "resource/r_levelext.h"
#include "resource/r_globalext.h"
#include "local.h"
#include "pro.h"

namespace strength
{

uint32 GetSpace( SUser* user )
{
    CLevelData::SData* level = theLevelExt.Find( user->data.simple.team_level );
    if ( level == NULL )
        return 0;

    if ( user->data.simple.strength >= level->strength )
        return 0;

    return ~0;
}

void buy( SUser* user )
{
    uint32 space_value = coin::space( user, kCoinStrength );
    if ( space_value <= 0 )
    {
        HandleErrCode( user, kErrStrengthFull, 0 );
        return;
    }

    CLevelData::SData* level = theLevelExt.Find( user->data.simple.vip_level );
    if ( level == NULL )
        return;

    //购买次数检查
    uint32 buy_count = level->strength_buy;
    uint32 strength_day_buy_count = var::get( user, "strength_day_buy_count" );
    if ( strength_day_buy_count >= buy_count )
    {
        HandleErrCode( user, kErrStrengthBuyTimesMax, 0 );
        return;
    }

    //根据购买次数获得等级表
    level = theLevelExt.Find( strength_day_buy_count );

    //基本容错
    if ( level == NULL || level->strength_price <= 0 )
        return;

    //货币检查
    S3UInt32 take_coin = coin::create( kCoinGold, 0, level->strength_price );
    if ( coin::check_take( user, take_coin ) != 0 )
    {
        coin::reply_lack( user, kCoinGold );
        return;
    }

    //基本容错
    uint32 value = theGlobalExt.get<uint32>( "strength_buy" );
    if ( value <= 0 || value > 1000 )
    {
        HandleErrCode( user, kErrStrengthBuyTimesMax, 0 );
        return;
    }

    //扣取货币
    coin::take( user, take_coin, kPathStrengthBuy );

    //设置购买次数
    var::set( user, "strength_day_buy_count", strength_day_buy_count + 1 );

    //给予体力
    S3UInt32 coin = coin::create( kCoinStrength, 0, value );
    coin::give( user, coin, kPathStrengthBuy, kCoinFlagOverflow );

    PRStrengthBuy rep;
    bccopy( rep, user->ext );

    rep.value = value;

    local::write( local::access, rep );
}

} // namespace strength

