#ifndef _shop_H_
#define _shop_H_

#include "proto/common.h"

const uint32 kShopTypeMedal = 1;
const uint32 kShopTypeCommon = 2;
const uint32 kShopTypeMystery = 3;
const uint32 kShopTypeTomb = 4;
const uint32 kShopTypeGuild = 5;
const uint32 kShopTypeAchievementMedal = 6;
const uint32 kShopTypeAchievementTomb = 7;
const uint32 kPathMedalShop = 170991727;
const uint32 kPathCommonShop = 1271127800;
const uint32 kPathMysteryShop = 1773888049;
const uint32 kPathTombShop = 1977546372;
const uint32 kPathClearMasteryCD = 1082442933;
const uint32 kPathTombShopRefresh = 16753434;
const uint32 kPathGuildShop = 1882356240;
const uint32 kPathAchievementMedalShop = 2119033226;
const uint32 kPathAchievementTombShop = 1536045941;
const uint32 kASCondArenaWinTimes = 1;
const uint32 kASCondArenaRank = 2;
const uint32 kASCondMedalConsume = 3;
const uint32 kASCondTombWinTimes = 4;
const uint32 kASCondTombReset = 5;
const uint32 kASCondTombPass = 6;

#include "proto/shop/SUserShopLog.h"
#include "proto/shop/SUserMysteryGoods.h"
#include "proto/shop/PQShopBuy.h"
#include "proto/shop/PRShopBuy.h"
#include "proto/shop/PQShopRefresh.h"
#include "proto/shop/PQShopLog.h"
#include "proto/shop/PRShopLog.h"
#include "proto/shop/PRShopLogSet.h"
#include "proto/shop/PRShopMysteryGoods.h"
#include "proto/shop/PQShopTombRefresh.h"

#endif
