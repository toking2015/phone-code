#ifndef _soldier_H_
#define _soldier_H_

#include "proto/common.h"

const uint32 kSoldierTypeCommon = 1;
const uint32 kSoldierTypeYesterday = 2;
const uint32 kSoldierTypeTombSelf = 3;
const uint32 kSoldierTypeTombTarget = 4;
const uint32 kPathSoldierQualityUp = 1768905208;
const uint32 kPathSoldierLvUp = 1029450723;
const uint32 kPathSoldierStarUp = 1854145592;
const uint32 kPathSoldierAdd = 1147998484;
const uint32 kPathSoldierDel = 616304367;
const uint32 kPathSoldierMove = 1631393222;
const uint32 kPathSoldierRecruit = 1266828872;
const uint32 kPathSoldierEquip = 382737524;
const uint32 kPathSoldierSkillReset = 1272384774;
const uint32 kPathSoldierSkillLvUp = 1043530847;
const uint32 kPathSoldierQualityXpAdd = 534240037;
const uint32 kPathSoldierEquipSkill = 257383971;
const uint32 kSoldierSkillMax = 4;
const uint32 kSoldierOccuPaladin = 1;
const uint32 kSoldierOccuDeathKnight = 2;
const uint32 kSoldierOccuWorrier = 3;
const uint32 kSoldierOccuHunter = 4;
const uint32 kSoldierOccuShaman = 5;
const uint32 kSoldierOccuDruid = 6;
const uint32 kSoldierOccuRogue = 7;
const uint32 kSoldierOccuMonk = 8;
const uint32 kSoldierOccuMage = 9;
const uint32 kSoldierOccuWarlock = 10;
const uint32 kSoldierOccuPriest = 11;
const uint32 kSoldierQualityInitLv = 1;
const uint32 kErrSoldierGuidNotExist = 903005699;
const uint32 kErrSoldierDataNotExist = 1086935047;
const uint32 kErrSoldierQualityNotExist = 411098803;
const uint32 kErrSoldierQualityLvLimit = 901151154;
const uint32 kErrSoldierLvNotExist = 2107585344;
const uint32 kErrSoldierStarNotExist = 759754821;
const uint32 kErrSoldierHave = 1430609125;
const uint32 kErrSoldierTeamLevel = 777163145;
const uint32 kErrSoldierQualityLevel = 365779413;
const uint32 kErrSoldierEquipHave = 1036776371;
const uint32 kErrSoldierEquipMismatch = 1959484393;
const uint32 kErrSoldierNoSkillPoint = 307615193;
const uint32 kErrSoldierSkillLvLimit = 1923412656;
const uint32 kErrSoldierQualityXpCoinNoExist = 785050053;
const uint32 kErrSoldierQualityXpCoinWrong = 1906325959;
const uint32 kErrSoldierLvNotXp = 1899931062;
const uint32 kErrSoldierQualityXpNotEqual = 2135125154;
const uint32 kErrSoldierQualityXpLimit = 2072921884;

#include "proto/soldier/SSoldierSkill.h"
#include "proto/soldier/SUserSoldier.h"
#include "proto/soldier/PQSoldierList.h"
#include "proto/soldier/PRSoldierList.h"
#include "proto/soldier/PQSoldierAdd.h"
#include "proto/soldier/PRSoldierSet.h"
#include "proto/soldier/PQSoldierDel.h"
#include "proto/soldier/PQSoldierMove.h"
#include "proto/soldier/PQSoldierQualityAddXp.h"
#include "proto/soldier/PQSoldierQualityUp.h"
#include "proto/soldier/PQSoldierLvUp.h"
#include "proto/soldier/PQSoldierStarUp.h"
#include "proto/soldier/PQSoldierRecruit.h"
#include "proto/soldier/PRSoldierRecruit.h"
#include "proto/soldier/PQSoldierEquip.h"
#include "proto/soldier/PQSoldierSkillReset.h"
#include "proto/soldier/PQSoldierSkillLvUp.h"
#include "proto/soldier/PQSoldierEquipExt.h"
#include "proto/soldier/PRSoldierEquipExt.h"

#endif
