#ifndef _task_H_
#define _task_H_

#include "proto/common.h"

const uint32 kPathTaskAccept = 94118515;
const uint32 kPathTaskFinished = 1563095759;
const uint32 kPathTaskAutoFinished = 339870132;
const uint32 kPathDayTaskValReward = 1750380674;
const uint32 kPathDayTaskValReset = 1110794590;
const uint32 kTaskTypeMain = 1;
const uint32 kTaskTypeBranch = 2;
const uint32 kTaskTypeDayRepeat = 3;
const uint32 kTaskTypeActivity = 4;
const uint32 kTaskCondGut = 1;
const uint32 kTaskCondMonster = 2;
const uint32 kTaskCondCopyFinished = 3;
const uint32 kTaskCondCopyGroup = 4;
const uint32 kTaskCondItem = 5;
const uint32 kTaskCondLotteryCard = 6;
const uint32 kTaskCondBuildingTake = 7;
const uint32 kTaskCondVipLevel = 8;
const uint32 kTaskCondMonthCard = 9;
const uint32 kTaskCondTime = 10;
const uint32 kTaskCondBossKillCount = 11;
const uint32 kTaskCondSingleArenaBattle = 12;
const uint32 kTaskCondTrialFinished = 13;
const uint32 kTaskCondItemMerge = 14;
const uint32 kTaskCondMarketCargoUp = 15;
const uint32 kTaskCondBuildingSpeed = 16;
const uint32 kTaskCondTotemGlyphMerge = 17;
const uint32 kTaskCondTeamLevel = 18;
const uint32 kTaskCondSoldierCollect = 19;
const uint32 kTaskCondTotemLevel = 20;
const uint32 kTaskCondSoldierQuality = 21;
const uint32 kTaskCondVendibleBuy = 22;
const uint32 kTaskCondTotemSkillLevelUp = 23;
const uint32 kTaskCondSoldierLevelUp = 24;
const uint32 kTaskCondBossKillId = 25;
const uint32 kTaskCondMonsterTeam = 26;
const uint32 kTaskCondTotem = 27;
const uint32 kTaskCondTomb = 28;
const uint32 kTaskCondWeiXinShared = 29;
const uint32 kTaskCondChat = 30;
const uint32 kTaskCondFriendGiveActiveScoreTimes = 31;
const uint32 kErrTaskLevelLimit = 1027262878;
const uint32 kErrTaskExist = 1499676256;
const uint32 kErrTaskFrontLog = 1762712797;
const uint32 kErrTaskFrontCopy = 646451468;
const uint32 kErrTaskLogExist = 1125439091;
const uint32 kErrTaskDayRepeatMax = 891902097;
const uint32 kErrTaskNotExist = 895190570;
const uint32 kErrTaskCondUnfinished = 1353496591;
const uint32 kErrTaskCondReject = 1693029574;
const uint32 kErrTaskActivityClose = 690805510;
const uint32 kErrTaskDayRewardNotExist = 500602654;
const uint32 kErrTaskDayRewardNotEnough = 357462144;
const uint32 kErrTaskDayRewardAlreadyGot = 248704276;

#include "proto/task/SUserTask.h"
#include "proto/task/SUserTaskLog.h"
#include "proto/task/SUserTaskDay.h"
#include "proto/task/PQTaskList.h"
#include "proto/task/PRTaskList.h"
#include "proto/task/PQTaskLogList.h"
#include "proto/task/PRTaskLogList.h"
#include "proto/task/PQTaskAccept.h"
#include "proto/task/PQTaskFinish.h"
#include "proto/task/PQTaskAutoFinish.h"
#include "proto/task/PQTaskSet.h"
#include "proto/task/PRTaskSet.h"
#include "proto/task/PRTaskLog.h"
#include "proto/task/PRTaskDay.h"
#include "proto/task/PRTaskDayList.h"
#include "proto/task/PQTaskDayValReward.h"
#include "proto/task/PRTaskDayValReward.h"
#include "proto/task/PRTaskDayValRewardList.h"

#endif
