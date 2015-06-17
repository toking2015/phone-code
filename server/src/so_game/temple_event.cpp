#include "event.h"
#include "user_event.h"
#include "coin_event.h"
#include "coin_imp.h"
#include "proto/constant.h"
#include "totem_event.h"
#include "soldier_event.h"
#include "temple_event.h"
#include "temple_imp.h"

EVENT_FUNC(temple, SEventUserLogined)
{
    temple::OnLogin(ev.user);
}

EVENT_FUNC(temple, SEventUserTimeLimit)
{
    temple::TimeLimit(ev.user);
}

// 神殿组合升级
EVENT_FUNC(temple, SEventTempleGroupLevelUp)
{
    temple::CalTempleScore(ev.user);
}

EVENT_FUNC(temple, SEventTotemSkillLevelUp)
{
    temple::CalTempleScore(ev.user);
}

EVENT_FUNC(temple, SEventTotemLevelUp)
{
    temple::CalTempleScore(ev.user);
}

// 英雄/图腾获得
EVENT_FUNC(temple, SEventCoin)
{
    if(ev.set_type == kObjectAdd)
    {
        if((ev.coin.cate == kCoinTotem) || (ev.coin.cate == kCoinSoldier))
        {
            temple::CheckAddGroup(ev.user);
        }
    }
}

// 英雄进阶
EVENT_FUNC(temple, SEventSoldierQualityUp)
{
    temple::CalTempleScore(ev.user);
}

// 英雄升星
EVENT_FUNC(temple, SEventSoldierStarUp)
{
    temple::CalTempleScore(ev.user);
}

// 英雄升级
EVENT_FUNC(temple, SEventSoldierLvUp)
{
    temple::CalTempleScore(ev.user);
}
