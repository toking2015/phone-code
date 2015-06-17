#ifndef _copy_H_
#define _copy_H_

#include "proto/common.h"

const uint32 kPathCopyPass = 487341379;
const uint32 kPathCopyPassEquip = 1603270542;
const uint32 kPathCopyGroupPass = 1668870455;
const uint32 kPathCopyBossFight = 331226124;
const uint32 kPathCopySearch = 44267644;
const uint32 kPathCopyFightMeet = 636723069;
const uint32 kPathCopyBossMopup = 1955292224;
const uint32 kPathCopyCommit = 1577068634;
const uint32 kPathCopyMopupReset = 541069187;
const uint32 kPathCopyAreaPass = 784566122;
const uint32 kPathCopyAreaPresentTake = 731592263;
const uint32 kCopyEventTypeRandom = 1;
const uint32 kCopyEventTypeBox = 2;
const uint32 kCopyEventTypeReward = 3;
const uint32 kCopyEventTypeGut = 4;
const uint32 kCopyEventTypeShop = 5;
const uint32 kCopyEventTypeFight = 6;
const uint32 kCopyEventTypeFightMeet = 7;
const uint32 kCopyFightLogMaxCount = 5;
const uint32 kCopyStateBossCol = 1;
const uint32 kCopyStateEventEnd = 2;
const uint32 kCopyTypeGeneral = 0;
const uint32 kCopyTypeBoss = 1;
const uint32 kCopyMopupTypeNormal = 1;
const uint32 kCopyMopupTypeElite = 2;
const uint32 kCopyMaterial = 3;
const uint32 kCopyMopupAttrRound = 1;
const uint32 kCopyMopupAttrTimes = 2;
const uint32 kCopyMopupAttrReset = 3;
const uint32 kCopyAreaAttrPass = 1;
const uint32 kCopyAreaAttrFullStar = 2;
const uint32 kErrCopyParam = 1179085069;
const uint32 kErrCopyData = 1235614006;
const uint32 kErrCopyExist = 562277816;
const uint32 kErrCopyMopupNotExist = 231064026;
const uint32 kErrCopyNotExist = 1727485652;
const uint32 kErrCopyEnded = 328303350;
const uint32 kErrCopyNotPass = 1831653469;
const uint32 kErrCopyFront = 1502938991;
const uint32 kErrCopyUndone = 739119366;
const uint32 kErrCopyNotEnd = 923922869;
const uint32 kErrCopyEventOrder = 1393005650;
const uint32 kErrCopyEventIndex = 1796537224;
const uint32 kErrCopyRewardNotExist = 66067667;
const uint32 kErrCopyBossNotExist = 1932494041;
const uint32 kErrCopyStrengthNotEnought = 1403771026;
const uint32 kErrCopyBossMopupScore = 1388140752;
const uint32 kErrCopyChunkIndexExsit = 508069909;
const uint32 kErrCopyChunkCateNull = 859452038;
const uint32 kErrCopyMopupRefTimesNotEnough = 1518472622;
const uint32 kErrCopyMopupTimesFull = 802418475;
const uint32 kErrCopyMopupTimesNotEnough = 7497487;
const uint32 kErrCopyAreaNotExist = 36091843;
const uint32 kErrCopyAreaPresentTaked = 1689716357;
const uint32 kErrCopyAreaNoPass = 774445435;
const uint32 kErrCopyAreaNoFullStar = 1718634511;
const uint32 kErrCopyBossExist = 1222807567;
const uint32 kErrCopyFightIdNotEqual = 561122740;

#include "proto/copy/SUserCopy.h"
#include "proto/copy/SCopyLog.h"
#include "proto/copy/SCopyFightLog.h"
#include "proto/copy/SAreaLog.h"
#include "proto/copy/SCopyMopup.h"
#include "proto/copy/SCopyBossFight.h"
#include "proto/copy/CCopy.h"
#include "proto/copy/PQCopyOpen.h"
#include "proto/copy/PRCopyOpen.h"
#include "proto/copy/PRCopyData.h"
#include "proto/copy/PQCopyClose.h"
#include "proto/copy/PRCopyClose.h"
#include "proto/copy/PQCopyCommitEvent.h"
#include "proto/copy/PRCopyCommitEvent.h"
#include "proto/copy/PQCopyCommitEventFight.h"
#include "proto/copy/PRCopyCommitEventFight.h"
#include "proto/copy/PQCopyRefurbish.h"
#include "proto/copy/PRCopyRefurbish.h"
#include "proto/copy/PQCopyLog.h"
#include "proto/copy/PRCopyLog.h"
#include "proto/copy/PQCopyLogList.h"
#include "proto/copy/PRCopyLogList.h"
#include "proto/copy/PQCopyBossFight.h"
#include "proto/copy/PRCopyBossFight.h"
#include "proto/copy/PQCopyBossFightCommit.h"
#include "proto/copy/PRCopyAreaData.h"
#include "proto/copy/PQCopyAreaPresentTake.h"
#include "proto/copy/PRCopyAreaPresentTake.h"
#include "proto/copy/PQCopyBossMopup.h"
#include "proto/copy/PRCopyBossMopup.h"
#include "proto/copy/PQCopyMopupReset.h"
#include "proto/copy/PRCopyMopupData.h"
#include "proto/copy/PQCopyFightLog.h"
#include "proto/copy/PRCopyFightLog.h"
#include "proto/copy/PQCopyFightLogLoad.h"
#include "proto/copy/PRCopyFightLogLoad.h"
#include "proto/copy/PQCopyFightLogSave.h"

#endif
