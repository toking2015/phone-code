#ifndef _rank_H_
#define _rank_H_

#include "proto/common.h"

const uint32 kRankingObjectAdd = 0;
const uint32 kRankingObjectDel = 1;
const uint32 kRankingObjectUpdate = 2;
const uint32 kRankAttrReal = 1;
const uint32 kRankAttrCopy = 2;
const uint32 kRankCycDay = 1;
const uint32 kRankCycWeek = 2;
const uint32 kRankCycMonth = 3;
const uint32 kRankingTypeSingleArena = 1;
const uint32 kRankingTypeSoldier = 2;
const uint32 kRankingTypeTotem = 3;
const uint32 kRankingTypeCopy = 4;
const uint32 kRankingTypeMarket = 5;
const uint32 kRankingTypeEquip = 6;
const uint32 kRankingTypeTeamLevel = 7;
const uint32 kRankingTypeTemple = 8;

#include "proto/rank/SRankInfo.h"
#include "proto/rank/SRankData.h"
#include "proto/rank/CRank.h"
#include "proto/rank/CRankCenter.h"
#include "proto/rank/PQRankCopySave.h"
#include "proto/rank/PQRankLoad.h"
#include "proto/rank/PRRankLoad.h"
#include "proto/rank/PQRankIndex.h"
#include "proto/rank/PRRankIndex.h"
#include "proto/rank/PQRankList.h"
#include "proto/rank/PQRankListType.h"
#include "proto/rank/PRRankList.h"
#include "proto/rank/PRRankClearData.h"

#endif
