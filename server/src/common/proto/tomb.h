#ifndef _tomb_H_
#define _tomb_H_

#include "proto/common.h"

const uint32 kTombFront = 50;
const uint32 kTombBack = 2000;
const uint32 kTombPart = 5;
const uint32 kTombPartCount = 4;
const uint32 kPathTombRewardGet = 1394672885;
const uint32 kPathTombPlayerReset = 2087704392;
const uint32 kPathTombFight = 878590869;
const uint32 kPathTombMopUp = 1310537727;
const uint32 kErrTombPlayerData = 1170054082;
const uint32 kErrTombRewardDataNoExitLevel = 1698394481;
const uint32 kErrTombRewardDataNoExit = 267636965;
const uint32 kErrTombRewardNotGet = 905129988;
const uint32 kErrTombNotOpen = 105739333;

#include "proto/tomb/STombTarget.h"
#include "proto/tomb/SUserKillInfo.h"
#include "proto/tomb/SUserTomb.h"
#include "proto/tomb/PQTombFight.h"
#include "proto/tomb/PQTombRewardGet.h"
#include "proto/tomb/PRTombRewardGet.h"
#include "proto/tomb/PQTombPlayerReset.h"
#include "proto/tomb/PRTombPlayerReset.h"
#include "proto/tomb/PQTombReset.h"
#include "proto/tomb/PRTombReset.h"
#include "proto/tomb/PQTombMopUp.h"
#include "proto/tomb/PRTombMopUp.h"
#include "proto/tomb/PQTombInfo.h"
#include "proto/tomb/PRTombInfo.h"
#include "proto/tomb/PQTombTargetList.h"
#include "proto/tomb/PRTombTargetList.h"

#endif
