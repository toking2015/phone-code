#ifndef _activity_H_
#define _activity_H_

#include "proto/common.h"

const uint32 kPathActivityClose = 1417400276;
const uint32 kPathActivityOpen = 677971819;
const uint32 kPathActivityReward = 1700752458;
const uint32 kActivityTimeTypeBound = 1;
const uint32 kActivityTimeTypeOpen = 2;
const uint32 kActivityTimeTypeUnite = 3;
const uint32 kActivityTimeTypeLevel = 4;
const uint32 kActivityTimeTypePersonal = 5;
const uint32 kActivityTimeTypeLimitOpen = 12;
const uint32 kActivityTimeTypeLimitUnite = 13;
const uint32 kActivityDataTypeMax = 30;
const uint32 kActivityFactorTypeFirstPay = 1;
const uint32 kActivityFactorTypeAddPay = 2;
const uint32 kActivityFactorTypeLevel = 3;
const uint32 kActivityFactorTypeSerialLogin = 4;
const uint32 kActivityFactorTypeGetSoldier = 5;
const uint32 kActivityFactorTypeUpSoldier = 6;
const uint32 kActivityFactorTypeGetTotem = 7;
const uint32 kActivityFactorTypeMaxStartTotem = 8;
const uint32 kActivityFactorTypePassTomb = 9;
const uint32 kActivityFactorTypeVipLevel = 10;
const uint32 kActivityFactorTypeTimeTatalGold = 11;
const uint32 kActivityFactorTypeDayTatalGold = 12;
const uint32 kActivityFactorTypeTimeTatalMoney = 13;
const uint32 kActivityFactorTypeDayTatalMoney = 14;
const uint32 kActivityFactorTypeTimeTatalBetGold = 15;
const uint32 kActivityFactorTypeDayTatalBetGold = 16;
const uint32 kActivityFactorTypeTimeTatalBetMoney = 17;
const uint32 kActivityFactorTypeDayTatalBetMoney = 18;
const uint32 kActivityFactorTypeDayTimesPayTimesGold = 19;
const uint32 kActivityFactorTypeMax = 20;
const uint32 kErrActivitySqlInvaild = 2085082349;

#include "proto/activity/SActivityOpen.h"
#include "proto/activity/SActivityData.h"
#include "proto/activity/SActivityFactor.h"
#include "proto/activity/SActivityReward.h"
#include "proto/activity/SActivityInfo.h"
#include "proto/activity/CActivity.h"
#include "proto/activity/PQActivityOpenLoad.h"
#include "proto/activity/PRActivityOpenLoad.h"
#include "proto/activity/PQActivityDataLoad.h"
#include "proto/activity/PRActivityDataLoad.h"
#include "proto/activity/PQActivityFactorLoad.h"
#include "proto/activity/PRActivityFactorLoad.h"
#include "proto/activity/PQActivityRewardLoad.h"
#include "proto/activity/PRActivityRewardLoad.h"
#include "proto/activity/PQActivityList.h"
#include "proto/activity/PRActivityList.h"
#include "proto/activity/PQActivityInfoList.h"
#include "proto/activity/PRActivityInfoList.h"
#include "proto/activity/PQActivityTakeReward.h"
#include "proto/activity/PRActivityTakeReward.h"

#endif
