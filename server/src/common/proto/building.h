#ifndef _building_H_
#define _building_H_

#include "proto/common.h"

const uint32 kPathBuildingLeveUp = 459958712;
const uint32 kPathBuildingGetOutput = 1331875543;
const uint32 kPathBuildingSpeedOutput = 873661828;
const uint32 kBuildingTypeMajor = 1;
const uint32 kBuildingTypeGoldField = 2;
const uint32 kBuildingTypeGoldBank = 3;
const uint32 kBuildingTypeWoodField = 4;
const uint32 kBuildingTypeWoodBank = 5;
const uint32 kBuildingTypeWaterFactory = 6;
const uint32 kBuildingTypeAspersorium = 7;
const uint32 kBuildingTypeCampsite = 8;
const uint32 kBuildingTypeTrainingGround = 9;
const uint32 kBuildingTypeShipField = 10;
const uint32 kBuildingTypeTavern = 11;
const uint32 kBuildingTypePalace = 12;
const uint32 kBuildingTypeTechnology = 13;
const uint32 kBuildingTypeToweringOldTrees = 14;
const uint32 kBuildingTypeBlacksimith = 15;
const uint32 kBuildingTypeAlter = 16;
const uint32 kBuildingTypeLegion = 17;
const uint32 kBuildingTypeDecorate = 18;
const uint32 kBuildingTypeJumping = 19;
const uint32 kBuildingTypeSingleArena = 20;
const uint32 kBuildingTypePVPBattle = 21;
const uint32 kBuildingTypePVEBattle = 22;
const uint32 kBuildingTypeCopyOne = 23;
const uint32 kBuildingTypeCopyFive = 24;
const uint32 kBuildingTypeCopyTen = 25;
const uint32 kBuildingTypeCopyFifteen = 26;
const uint32 kBuildingTypeCopyTwenty = 27;
const uint32 kBuildingTypeCopyTwentyFive = 28;
const uint32 kErrBuildingGuidNotExist = 1440276505;
const uint32 kErrBuildingDataNotExist = 470176097;
const uint32 kErrBuildingCountNotMax = 705846841;
const uint32 kErrBuildingUpgrateNotMaterial = 1021527684;
const uint32 kErrBuildingUpgrateNotLevel = 1922807980;
const uint32 kErrBuildingSpeedError = 44330487;

#include "proto/building/SBuildingBase.h"
#include "proto/building/SBuildingExt.h"
#include "proto/building/SUserBuilding.h"
#include "proto/building/PQBuildingList.h"
#include "proto/building/PQBuildingAdd.h"
#include "proto/building/PQBuildingUpgrade.h"
#include "proto/building/PQBuildingMove.h"
#include "proto/building/PQBuildingQuery.h"
#include "proto/building/PQBuildingGetOutput.h"
#include "proto/building/PQBuildingSpeedOutput.h"
#include "proto/building/PRBuildingList.h"
#include "proto/building/PRBuildingSet.h"
#include "proto/building/PRBuildingQuery.h"
#include "proto/building/PRBuildingSpeedOutput.h"

#endif
