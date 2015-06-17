#include "coin_event.h"
#include "star_imp.h"
#include "proto/constant.h"
#include "proto/copy.h"
#include "proto/coin.h"

EVENT_FUNC( star, SEventCoin )
{
    if ( ev.set_type != kObjectAdd )
        return;

    uint32* pointer = NULL;

    switch ( ev.coin.cate )
    {
    case kCoinStar:
        {
            switch ( ev.path )
            {
            case kPathCopySearch:
            case kPathCopyFightMeet:
            case kPathCopyBossFight:
                pointer = &ev.user->data.star.copy;
                break;
            }
        }
        break;
    }

    if ( pointer != NULL )
    {
        *pointer += ev.coin.val;

        star::reply_data( ev.user );
    }
}

