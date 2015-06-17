#ifndef _trial_H_
#define _trial_H_

#include "proto/common.h"

const uint32 kTrialSurvival = 1;
const uint32 kTrialStrength = 2;
const uint32 kTrialAgile = 3;
const uint32 kTrialIntelligence = 4;
const uint32 kPathTrialSurvival = 374239832;
const uint32 kPathTrialStrength = 2132077111;
const uint32 kPathTrialAgile = 537836721;
const uint32 kPathTrialIntelligence = 306505229;
const uint32 kPathTrialFinish = 1253727759;
const uint32 kPathTrialRewardGet = 231757346;
const uint32 kErrTrialRewardDataNoExit = 494174446;
const uint32 kErrTrialRewardHave = 749815519;
const uint32 kErrTrialRewardDataNoExitLevel = 564084311;
const uint32 kErrTrialDataNoExit = 1661989178;
const uint32 kErrTrialNotOpen = 1726924814;
const uint32 kErrTrialTryCount = 768444096;
const uint32 kErrTrialRewardValNot = 831131258;

#include "proto/trial/SUserTrialReward.h"
#include "proto/trial/SUserTrial.h"
#include "proto/trial/PQTrialEnter.h"
#include "proto/trial/PQTrialRewardList.h"
#include "proto/trial/PRTrialRewardList.h"
#include "proto/trial/PQTrialRewardGet.h"
#include "proto/trial/PRTrialRewardGet.h"
#include "proto/trial/PQTrialRewardEnd.h"
#include "proto/trial/PRTrialRewardEnd.h"
#include "proto/trial/PQTrialUpdate.h"
#include "proto/trial/PRTrialUpdate.h"
#include "proto/trial/PQTrialMopUp.h"
#include "proto/trial/PRTrialMopUp.h"

#endif
