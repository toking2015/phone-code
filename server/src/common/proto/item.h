#ifndef _item_H_
#define _item_H_

#include "proto/common.h"

const uint32 kPathItemDice = 1324150315;
const uint32 kPathItemMove = 1142902209;
const uint32 kPathItemAdd = 2027073428;
const uint32 kPathSell = 1010394484;
const uint32 kPathRedeem = 1351704370;
const uint32 kPathMerge = 265266382;
const uint32 kPathItemUse = 1028625609;
const uint32 kPathMergeEquip = 2025500073;
const uint32 kPathMergeBook = 1554365024;
const uint32 kItemRandMax = 6;
const uint32 kItemSlotMax = 3;
const uint32 kBagFuncCommon = 1;
const uint32 kBagFuncBank = 2;
const uint32 kBagFuncRedeem = 3;
const uint32 kBagFuncSoldierEquip = 4;
const uint32 kBagFuncSoldierEquipSkill = 5;
const uint32 kBagFuncSoldierEquipTemp = 6;
const uint32 kItemEquipTypeHead = 1;
const uint32 kItemEquipTypeChest = 2;
const uint32 kItemEquipTypeLegs = 3;
const uint32 kItemEquipTypeShoulders = 4;
const uint32 kItemEquipTypeHands = 5;
const uint32 kItemEquipTypeFeet = 6;
const uint32 kItemTypeEquip = 1;
const uint32 kItemTypeGift = 2;
const uint32 kItemTypeMaterial = 3;
const uint32 kItemTypeSoulStone = 4;
const uint32 kItemClientTypeConsume = 1;
const uint32 kItemClientTypeSoulStone = 2;
const uint32 kItemClientTypeMaterial = 3;
const uint32 kItemUseAddRewardRandom = 1;
const uint32 kItemUseAddRewardIndex = 2;
const uint32 kItemMergeTypeEquip = 1;
const uint32 kItemMergeTypeSkillBook = 2;
const uint32 kErrItemDataNotExist = 1155188034;
const uint32 kErrItemGuidNotExist = 541242787;
const uint32 kErrItemMoveIllegalBag = 1360543255;
const uint32 kErrItemDiceCount = 944967853;
const uint32 kErrItemNoSell = 1088693056;
const uint32 kErrItemSpaceFull = 256824735;
const uint32 kErrItemMergeLevel = 159035261;
const uint32 kErrItemOpenRewardDataNoExitLevel = 152412089;
const uint32 kErrItemUseLimitLevel = 412854821;

#include "proto/item/SWildItem.h"
#include "proto/item/SUserItem.h"
#include "proto/item/CUserItem.h"
#include "proto/item/PQItemList.h"
#include "proto/item/PRItemList.h"
#include "proto/item/PRItemSet.h"
#include "proto/item/PQItemAdd.h"
#include "proto/item/PQItemSort.h"
#include "proto/item/PQItemSell.h"
#include "proto/item/PQItemRedeem.h"
#include "proto/item/PQItemMerge.h"
#include "proto/item/PRItemMerge.h"
#include "proto/item/PQItemEquip.h"
#include "proto/item/PQItemEquipSkill.h"
#include "proto/item/PRItemEquipSkill.h"
#include "proto/item/PQItemUse.h"
#include "proto/item/PRItemUse.h"

#endif
