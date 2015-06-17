#include "vip_imp.h"
#include "coin_imp.h"
#include "resource/r_levelext.h"
#include "proto/coin.h"
#include "proto/vip.h"
#include "vip_event.h"

namespace vip
{

void level_up( SUser* user )
{
    uint32 old_level = user->data.simple.vip_level;
    CLevelData::SData* level = theLevelExt.Find( user->data.simple.vip_level );
    if ( level == NULL )
        return;

    //扣取经验
    S3UInt32 coin_xp = coin::create( kCoinVipXp, 0, level->vip_xp );

    //增加等级
    S3UInt32 coin_lv = coin::create( kCoinVipLevel, 0, 1 );

    if ( coin::check_take( user, coin_xp ) != 0 )
        return;

    if ( coin::check_give( user, coin_lv ) != 0 )
        return;

    coin::take( user, coin_xp, kPathVipLevelUp );
    coin::give( user, coin_lv, kPathVipLevelUp );

    //升级事件
    event::dispatch( SEventVipLevelUp( user, kPathVipLevelUp, old_level ) );
}

} // namespace vip

