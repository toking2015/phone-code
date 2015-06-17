#ifndef _singlearena_H_
#define _singlearena_H_

#include "proto/common.h"

const uint32 kPathSingleArena = 1865316154;
const uint32 kSingleArenaObjectAdd = 0;
const uint32 kSingleArenaObjectDel = 1;
const uint32 kErrSingleArenaNotExist = 555715440;
const uint32 kErrSingleArenaCD = 904351219;
const uint32 kErrSingleArenaTimes = 271605967;
const uint32 kErrSingleArenaGold = 657319880;
const uint32 kErrSingleArenaNoLoad = 1756011234;

#include "proto/singlearena/SSingleArenaOpponent.h"
#include "proto/singlearena/SSingleArenaLog.h"
#include "proto/singlearena/SSingleArenaInfo.h"
#include "proto/singlearena/CSingleArenaMap.h"
#include "proto/singlearena/PQSingleArenaInfo.h"
#include "proto/singlearena/PRSingleArenaInfo.h"
#include "proto/singlearena/PQSingleArenaRefresh.h"
#include "proto/singlearena/PRSingleArenaRefresh.h"
#include "proto/singlearena/PQSingleArenaReplyCD.h"
#include "proto/singlearena/PRSingleArenaReplyCD.h"
#include "proto/singlearena/PQSingleArenaClearCD.h"
#include "proto/singlearena/PRSingleArenaClearCD.h"
#include "proto/singlearena/PQSingleArenaAddTimes.h"
#include "proto/singlearena/PRSingleArenaAddTimes.h"
#include "proto/singlearena/PQSingleArenaLog.h"
#include "proto/singlearena/PRSingleArenaLog.h"
#include "proto/singlearena/PQSingleArenaRank.h"
#include "proto/singlearena/PRSingleArenaRank.h"
#include "proto/singlearena/PRSingleBattleReply.h"
#include "proto/singlearena/PQSingleArenaMyRank.h"
#include "proto/singlearena/PRSingleArenaMyRank.h"
#include "proto/singlearena/PRSingleArenaBattleed.h"
#include "proto/singlearena/PRSingleArenaBattleEnd.h"
#include "proto/singlearena/PQUserSingleArenaPre.h"
#include "proto/singlearena/PRUserSingleArenaPre.h"
#include "proto/singlearena/PRSingleArenaCheck.h"
#include "proto/singlearena/PQSingleArenaSave.h"
#include "proto/singlearena/PQSingleArenaRankLoad.h"
#include "proto/singlearena/PRSingleArenaRankLoad.h"
#include "proto/singlearena/PQSingleArenaLogLoad.h"
#include "proto/singlearena/PRSingleArenaLogLoad.h"
#include "proto/singlearena/PQSingleArenaLogSave.h"
#include "proto/singlearena/PQSingleArenaGetFirstReward.h"

#endif
