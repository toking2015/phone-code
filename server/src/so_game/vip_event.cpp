#include "vip_event.h"
#include "pay_event.h"
#include "user_event.h"
#include "coin_event.h"
#include "coin_imp.h"
#include "vip_imp.h"
#include "resource/r_levelext.h"
#include "proto/constant.h"
#include "proto/coin.h"
#include "proto/vip.h"
#include "proto/user.h"
#include "server.h"

EVENT_FUNC( vip, SEventUserTimeLimit )
{
    if ( ev.user->data.simple.vip_level <= 11 )
    {
        S3UInt32 coin = coin::create( kCoinVipXp, 0, 100 );
        coin::give( ev.user, coin, ev.path );
    }
}

EVENT_FUNC( vip, SEventCoin )
{
    switch ( ev.set_type )
    {
    case kObjectAdd:
        {
            switch ( ev.coin.cate )
            {
            case kCoinVipXp:
                {
                    for(;;)
                    {
                        CLevelData::SData* level = theLevelExt.Find( ev.user->data.simple.vip_level );
                        if ( level == NULL )
                            break;

                        if ( level->vip_xp == 0 )
                            break;

                        if ( ev.user->data.simple.vip_xp < level->vip_xp )
                            break;

                        vip::level_up( ev.user );
                    }
                }
                break;
            }
        }
        break;
    }
}

