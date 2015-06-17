#ifndef _fight_H_
#define _fight_H_

#include "proto/common.h"

const uint32 kPathDrop = 659351692;
const uint32 kPathFightNormal = 595290871;
const uint32 kFightDelayTime = 60;
const uint32 kSkillDoubleAckPhysicalID = 10;
const uint32 kSkillDoubleAckMagicID = 11;
const uint32 kSkillAntiAttackPhysicalID = 12;
const uint32 kSkillAntiAttackMagicID = 13;
const uint32 kSkillPursuitPhysicalID = 14;
const uint32 kSkillPursuitMagicID = 15;
const uint32 kOddBreakID = 101;
const uint32 kOddFireID = 102;
const uint32 kOddDefineID = 103;
const uint32 kFightAttrDoubleHit = 1;
const uint32 kFightAttrAntiAttack = 2;
const uint32 kFightAttrPursuit = 3;
const uint32 kFightAttrAttactReboundPer = 4;
const uint32 kFightAttrRevive = 5;
const uint32 kFightAttrBomb = 6;
const uint32 kFightAttrTripleHit = 7;
const uint32 kFightAttrCall = 8;
const uint32 kFightAttrConfusion = 9;
const uint32 kFightAttrChange = 10;
const uint32 kFightAttrDeadCall = 11;
const uint32 kFightAttrCounter = 12;
const uint32 kFightAttrNoDisillusion = 13;
const uint32 kFightAttrTotemValueShow = 14;
const uint32 kFightAttrRebound = 15;
const uint32 kFightDicHP = 1;
const uint32 kFightAddHP = 2;
const uint32 kFightAddRage = 3;
const uint32 kFightDicRage = 4;
const uint32 kFightNoHurt = 5;
const uint32 kFightChange = 6;
const uint32 kFightMelee = 1;
const uint32 kFightRanged = 2;
const uint32 kFightRoundInit = 1;
const uint32 kFightRoundAuto = 10000;
const uint32 kFightRoundEnd = 3;
const uint32 kFightTargetOpposite = 1;
const uint32 kFightTargetSelf = 2;
const uint32 kFightTypeCommon = 1;
const uint32 kFightTypeCopy = 2;
const uint32 kFightTypeCommonPlayer = 3;
const uint32 kFightTypeFirstShow = 4;
const uint32 kFightTypeSingleArenaMonster = 5;
const uint32 kFightTypeSingleArenaPlayer = 6;
const uint32 kFightTypeTrialSurvival = 7;
const uint32 kFightTypeTrialStrength = 8;
const uint32 kFightTypeTrialAgile = 9;
const uint32 kFightTypeTrialIntelligence = 10;
const uint32 kFightTypeTomb = 11;
const uint32 kFightTypeFriend = 12;
const uint32 kFightTypeCommonAuto = 13;
const uint32 kFightLeft = 1;
const uint32 kFightRight = 2;
const uint32 kFightConditionHit = 0;
const uint32 kFightConditionNothing = 1;
const uint32 kFightCommon = 1;
const uint32 kFightCrit = 2;
const uint32 kFightDodge = 3;
const uint32 kFightParry = 4;
const uint32 kFightPhysical = 1;
const uint32 kFightMagic = 2;
const uint32 kFightHPRecover = 3;
const uint32 kFightAttackHp = 4;
const uint32 kFightBuff = 5;
const uint32 kFightClearOdd = 6;
const uint32 kFightHPRecoverTotem = 7;
const uint32 kFightStateCreateOK = 1;
const uint32 kFightStateDataOK = 2;
const uint32 SKILL_DOUBLEATTACK_PHYSICAL_ID = 1;
const uint32 SKILL_DOUBLEATTACK_MAGIC_ID = 2;
const uint32 SKILL_PURSUIT_PHYSICAL_ID = 3;
const uint32 SKILL_PURSUIT_MAGIC_ID = 4;
const uint32 SKILL_ANTIATTACK_PHYSICAL_ID = 5;
const uint32 SKILL_ANTIATTACK_MAGIC_ID = 6;
const uint32 ODD_COMMON_LEVEL = 1;
const uint32 ODD_DEF_FIXED_ID = 1;
const uint32 ODD_STUN_ID = 2;
const uint32 kEffectHP = 1;
const uint32 kEffectPhysicalAck = 2;
const uint32 kEffectPhysicalDef = 3;
const uint32 kEffectMagicAck = 4;
const uint32 kEffectMagicDef = 5;
const uint32 kEffectSpeed = 6;
const uint32 kEffectCrit = 7;
const uint32 kEffectCritDef = 8;
const uint32 kEffectCritHurt = 9;
const uint32 kEffectCritHurtDef = 10;
const uint32 kEffectHit = 11;
const uint32 kEffectDodge = 12;
const uint32 kEffectParry = 13;
const uint32 kEffectParryDec = 14;
const uint32 kEffectStunDef = 15;
const uint32 kEffectSilentDef = 16;
const uint32 kEffectWeakDef = 17;
const uint32 kEffectFireDef = 18;
const uint32 kEffectRage = 28;
const uint32 kEffectAllAttr = 36;
const uint32 kEffectDef = 37;
const uint32 kEffectAck = 38;
const uint32 kEffectCountryFightBuff = 39;
const uint32 kEffectPhysical = 40;
const uint32 kEffectAckSpeed = 42;
const uint32 kEffectRecoverCrit = 43;
const uint32 kEffectRecoverCritDef = 44;
const uint32 kEffectRecoverAddFix = 45;
const uint32 kEffectRecoverDelFix = 46;
const uint32 kEffectRecoverAddPer = 47;
const uint32 kEffectRecoverDelPer = 48;
const uint32 kEffectRageAddFix = 49;
const uint32 kEffectRageDelFix = 50;
const uint32 kEffectRageAddPer = 51;
const uint32 kEffectRageDelPer = 52;
const uint32 kEffectTrialBuff = 53;
const uint32 kFightIndexFront = 1;
const uint32 kFightIndexMid = 2;
const uint32 kFightIndexBack = 3;
const uint32 kFightIndexFirst = 1;
const uint32 kFightIndexSecond = 2;
const uint32 kFightIndexThird = 3;
const uint32 kFightSkillCommon = 1;
const uint32 kFightSkillAll = 2;
const uint32 kFightSkillHPMin = 3;
const uint32 kFightSkillFront = 4;
const uint32 kFightSkillMid = 5;
const uint32 kFightSkillBack = 6;
const uint32 kFightSkillFrontMid = 7;
const uint32 kFightSkillMidBack = 8;
const uint32 kFightSkillCurrentRow = 9;
const uint32 kFightSkillCurrentRowLast = 10;
const uint32 kFightSkillRandom = 11;
const uint32 kFightSkillRandomN = 12;
const uint32 kFightSkillSelf = 13;
const uint32 kFightSkillOccu = 14;
const uint32 kFightSkillTenRandom = 15;
const uint32 kFightSkillTenSelf = 16;
const uint32 kFightSkillCurrentRowFirst = 17;
const uint32 kFightSkillCurrentRowRandom = 18;
const uint32 kFightSkillRandomNotSelf = 19;
const uint32 kFightSkillEquip = 20;
const uint32 kFightSkillRandom2N = 21;
const uint32 kFightSkillHPMinFix = 22;
const uint32 kFightSkillAttackMax = 23;
const uint32 kFightSkillHPMinNotSelf = 24;
const uint32 kFightSkillStunFirst = 25;
const uint32 kFightSkillCommonTen = 26;
const uint32 kFightSkillRage = 27;
const uint32 kFightSkillSilentFirst = 28;
const uint32 kFightSkillConfusionFirst = 29;
const uint32 kFightSkillCurrentRowLastTen = 30;
const uint32 kFightSkillStatusId = 31;
const uint32 kFightSkillRandom1N = 32;
const uint32 kFightSkillRage1N = 33;
const uint32 kFightEffectTypeBuff = 1;
const uint32 kFightEffectTypeDebuff = 2;
const uint32 kFightOddAttrDebuff = 1;
const uint32 kFightOddAttrBuff = 2;
const uint32 kFightOddAttrCantDel = 3;
const uint32 kFightOddTypeControl = 6;
const uint32 kFightOddAttackAdd = 1;
const uint32 kFightOddAttackMulti = 2;
const uint32 kFightOddAttackFixed = 3;
const uint32 kFightOddDef = 4;
const uint32 kFightOddDefFixed = 5;
const uint32 kFightOddStun = 6;
const uint32 kFightOddWeak = 7;
const uint32 kFightOddFire = 8;
const uint32 kFightOddArmorDec = 9;
const uint32 kFightOddRecoverHPPer = 10;
const uint32 kFightOddHurtAddPer = 11;
const uint32 kFightOddHurtAdd = 12;
const uint32 kFightOddAntiAttack = 13;
const uint32 kFightOddMagicAntiAttack = 14;
const uint32 kFightOddRageClear = 15;
const uint32 kFightOddStunCreate = 16;
const uint32 kFightOddWeakCreate = 17;
const uint32 kFightOddFireCreate = 18;
const uint32 kFightOddArmorDecCreate = 19;
const uint32 kFightOddAttackToHPPer = 20;
const uint32 kFightOddAttackToHP = 21;
const uint32 kFightOddAttactReboundPer = 22;
const uint32 kFightOddAttactRebound = 23;
const uint32 kFightOddClearOddBuff = 24;
const uint32 kFightOddClearOddDebuff = 25;
const uint32 kFightOddWind = 26;
const uint32 kFightOddRain = 27;
const uint32 kFightOddSun = 28;
const uint32 kFightOddCloud = 29;
const uint32 kFightOddSnow = 30;
const uint32 kFightOddPhysicalDoubleHit = 31;
const uint32 kFightOddMagicDoubleHit = 32;
const uint32 kFightOddStunMust = 33;
const uint32 kFightOddBomb = 34;
const uint32 kFightOddSneak = 35;
const uint32 kFightOddHide = 36;
const uint32 kFightOddPerception = 37;
const uint32 kFightOddPursuit = 38;
const uint32 kFightOddShock = 39;
const uint32 kFightOddDeadFalse = 40;
const uint32 kFightOddPenetrate = 41;
const uint32 kFightOddGodBless = 42;
const uint32 kFightOddNaturalEnemy = 43;
const uint32 kFightOddErode = 44;
const uint32 kFightOddSign = 45;
const uint32 kFightOddCleverRoot = 46;
const uint32 kFightOddMagicDef = 47;
const uint32 kFightOddBombSelf = 48;
const uint32 kFightOddTerror = 49;
const uint32 kFightOddLucky = 50;
const uint32 kFightOddWave = 51;
const uint32 kFightOddDefenseZero = 52;
const uint32 kFightOddWarPower = 53;
const uint32 kFightOddRevive = 54;
const uint32 kFightOddInvincible = 55;
const uint32 kFightOddInsensitive = 56;
const uint32 kFightOddDeadly = 57;
const uint32 kFightOddRageAll = 58;
const uint32 kFightOddParryAntiAttack = 59;
const uint32 kFightOddJGNM = 60;
const uint32 kFightOddRMSF = 61;
const uint32 kFightOddYHJM = 62;
const uint32 kFightOddDSSC = 63;
const uint32 kFightOddHSMY = 64;
const uint32 kFightOddHSHL = 65;
const uint32 kFightOddFTDH = 66;
const uint32 kFightOddJTWS = 67;
const uint32 kFightOddJTCL = 68;
const uint32 kFightOddFEMetal = 74;
const uint32 kFightOddFEWood = 71;
const uint32 kFightOddFEWater = 72;
const uint32 kFightOddFEFire = 70;
const uint32 kFightOddFEEarth = 73;
const uint32 kFightOddArmorAdd = 75;
const uint32 kFightOddJGMJ = 76;
const uint32 kFightOddYZQJ = 77;
const uint32 kFightOddCMJB = 78;
const uint32 kFightOddKMFC = 79;
const uint32 kFightOddCDDS = 80;
const uint32 kFightOddFSNS = 81;
const uint32 kFightOddFHLT = 82;
const uint32 kFightOddSFDH = 83;
const uint32 kFightOddCTBZ = 84;
const uint32 kFightOddTBWJ = 85;
const uint32 kFightOddFire2 = 86;
const uint32 kFightOddMY = 87;
const uint32 kFightOddCreateStunNextRound = 88;
const uint32 kFightOddXYHL = 89;
const uint32 kFightOddSilent = 90;
const uint32 kFightOddFriendBuff = 91;
const uint32 kFightOddPhysicalAdd = 92;
const uint32 kFightOddPhysicalDel = 93;
const uint32 kFightOddMagicAdd = 94;
const uint32 kFightOddMagicDel = 95;
const uint32 kFightOddPhysicalDef = 96;
const uint32 kFightOddUnLucky = 97;
const uint32 kFightOddHpRecover = 98;
const uint32 kFightOddXXLH = 99;
const uint32 kFightOddJGHT = 100;
const uint32 kFightOddYYJ = 101;
const uint32 kFightOddSYZ = 102;
const uint32 kFightOddJZJL = 103;
const uint32 kFightOddXYMG = 104;
const uint32 kFightOddJDBH = 105;
const uint32 kFightOddHurtShare = 106;
const uint32 kFightOddFriendAddHp = 107;
const uint32 kFightOddDodge = 108;
const uint32 kFightOddRageUp = 109;
const uint32 kFightOddSuckAttack = 110;
const uint32 kFightOddJZJL1 = 111;
const uint32 kFightOddJZJL2 = 112;
const uint32 kFightOddHSMY2 = 113;
const uint32 kFightOddDefAck = 114;
const uint32 kFightOddBSYZ = 115;
const uint32 kFightOddAttackBuff = 116;
const uint32 kFightOddUnLuckyTwo = 117;
const uint32 kFightOddConfusion = 118;
const uint32 kFightOddRageLimit = 119;
const uint32 kFightOddDefBuff = 121;
const uint32 kFightOddAttackHpBuff = 122;
const uint32 kFightOddStayBuff = 123;
const uint32 kFightOddHpReduceBuff = 124;
const uint32 kFightOddCirtBuff = 125;
const uint32 kFightOddParryBuff = 126;
const uint32 kFightOddSleep = 127;
const uint32 kFightOddDisillusion = 128;
const uint32 kFightOddCall = 129;
const uint32 kFightOddInFire = 130;
const uint32 kFightOddChange = 131;
const uint32 kFightOddEvilShadow = 132;
const uint32 kFightOddTenFire = 133;
const uint32 kFightOddDoubleHit = 134;
const uint32 kFightOddBreak = 135;
const uint32 kFightOddInStunMoreHurt = 136;
const uint32 kFightOddInStunMoreTime = 137;
const uint32 kFightOddHpToHurt = 138;
const uint32 kFightOddDeadToStun = 139;
const uint32 kFightOddAttachToStun = 140;
const uint32 kFightOddMagicHitBuff = 141;
const uint32 kFightOddDeadNow = 142;
const uint32 kFightOddCoil = 143;
const uint32 kFightOddCommonAttackMight = 144;
const uint32 kFightOddSkillBuff = 145;
const uint32 kFightOddStarDown = 146;
const uint32 kFightOddPhyInvincible = 147;
const uint32 kFightOddMagInvincible = 148;
const uint32 kFightOddAttackToHp = 149;
const uint32 kFightOddControlInvincible = 150;
const uint32 kFightOddAttackToSkill = 151;
const uint32 kFightOddAttackToOdd = 152;
const uint32 kFightOddHitBuff = 153;
const uint32 kFightOddRecoberRage = 154;
const uint32 kFightOddNightDance = 155;
const uint32 kFightOddDeadHit = 156;
const uint32 kFightOddGiveRevive = 157;
const uint32 kFightOddRoundBuff = 158;
const uint32 kFightOddDeadHitChange = 159;
const uint32 kFightOddReduceHpBuff = 160;
const uint32 kFightOddFireFix = 161;
const uint32 kFightOddLightning = 162;
const uint32 kFightOddFireCount = 163;
const uint32 kFightOddSkillBuffSelf = 164;
const uint32 kFightOddHitBuffDef = 165;
const uint32 kFightOddHideBuff = 166;
const uint32 kFightOddArmorDecCount = 167;
const uint32 kFightOddDealCall = 168;
const uint32 kFightOddSilentBuff = 169;
const uint32 kFightOddRevive2 = 170;
const uint32 kFightOddPositiveCharge = 171;
const uint32 kFightOddBeCrit = 172;
const uint32 kFightOddDoubleHitBuff = 173;
const uint32 kFightOddFireFlow = 174;
const uint32 kFightOddCounter = 175;
const uint32 kFightOddDisillusionCreate = 176;
const uint32 kFightOddRecoverCirtBuff = 177;
const uint32 kFightOddRecoverSelfAdd = 178;
const uint32 kFightOddRecoverSelfDel = 179;
const uint32 kFightOddRecoverTarAdd = 180;
const uint32 kFightOddRecoverTarDel = 181;
const uint32 kFightOddHpPerRecover = 182;
const uint32 kFightOddRecoverBuff = 183;
const uint32 kFightOddDeadFighting = 184;
const uint32 kFightOddDeadAddBuff = 185;
const uint32 kFightOddRecoverByHP = 186;
const uint32 kFightOddHurtAddFix = 187;
const uint32 kFightOddHurtDelFix = 188;
const uint32 kFightOddDefenseDelPhy = 189;
const uint32 kFightOddDefenseDelMag = 190;
const uint32 kFightOddDefenseDelAll = 191;
const uint32 kFightOddAttackAddTotemValue = 192;
const uint32 kFightOddLightningFix = 193;
const uint32 kFightOddAttackHpRecover = 194;
const uint32 kFightOddChangeSheep = 195;
const uint32 kFightOddChangeFrog = 196;
const uint32 kFightOddDeadRevive = 197;
const uint32 kFightOddDeadHurtRebound = 198;
const uint32 kFightOddPhysicalAttackDel = 199;
const uint32 kFightOddMagicAttackDel = 200;
const uint32 kFightOddStone = 201;
const uint32 kFightOddStorm = 202;
const uint32 kFightOddRageBuff = 203;
const uint32 kFightOddRecoverCount = 204;
const uint32 kFightOddClearOdd = 205;
const uint32 kFightOddKillRageAdd = 206;
const uint32 kFightOddTotemSkillCoolDown = 207;
const uint32 kFightOddTotemSkillCost = 208;
const uint32 kFightOddTotemSkillDel = 209;
const uint32 kFightOddTotemValueInit = 210;
const uint32 kFightOddSkillChange = 211;
const uint32 kFightOddSnakeStick = 212;
const uint32 kFightOddDisease = 213;
const uint32 kFightOddDevour = 214;
const uint32 kFightOddScourge = 215;
const uint32 kFightOddDevourAdd = 216;
const uint32 kFightOddRageAddSave = 217;
const uint32 kFightOddBlood = 218;
const uint32 kFightOddBloodBuff = 219;
const uint32 kFightOddImmune = 220;
const uint32 kFightOddPoison = 221;
const uint32 kFightOddBuffPercent = 222;
const uint32 kFightOddHaveOddCirt = 223;
const uint32 kFightOddBuffPercent2 = 224;
const uint32 kFightOddIceDef = 225;
const uint32 kFightOddBuffHurt = 226;
const uint32 kFightOddHpRage = 227;
const uint32 kFightOddTrueGas = 228;
const uint32 kFightOddRageSave = 229;
const uint32 kFightOddRecoverHPMin = 230;
const uint32 kFightOddDiseaseHurt = 231;
const uint32 kFightOddDiseaseChange = 232;
const uint32 kFightOddTrueGasRecover = 233;
const uint32 kFightOddDisillusionPer = 234;
const uint32 kFightOddDisillusionDouble = 235;
const uint32 kFightOddHideRage = 236;
const uint32 kFightOddbuffA = 237;
const uint32 kFightOddbuffB = 238;
const uint32 kFightOddDefAll = 239;
const uint32 kFightOddSuckExt = 240;
const uint32 kFightHpToExtraHurt = 241;
const uint32 kFightOddHpLessMoreHurt = 242;
const uint32 kFightOddSuperPursuit = 243;
const uint32 kFightOddDefAddRage = 244;
const uint32 kFightOddHurtBuffAdd = 245;
const uint32 kFightOddKillBuffAdd = 246;
const uint32 kFightOddFear = 247;
const uint32 kFightOddDefMagicOrPhy = 248;
const uint32 kFightOddDefMelee = 249;
const uint32 kFightOddDefRanged = 250;
const uint32 kFightOddEquipTypeHurt = 251;
const uint32 kFightOddEquipTypeDef = 252;
const uint32 kErrFightInFight = 859462928;
const uint32 kErrFightLogNotFind = 1115661210;
const uint32 kErrFightLogVersion = 584353244;
const uint32 kErrFightNotExist = 1196542270;
const uint32 kErrFightCheck = 1852386177;
const uint32 kErrFightFailure = 1189816107;

#include "proto/fight/SFightOrder.h"
#include "proto/fight/SFightSkill.h"
#include "proto/fight/SFightExtAble.h"
#include "proto/fight/SFightOdd.h"
#include "proto/fight/SFightOddSet.h"
#include "proto/fight/SFightOddTriggered.h"
#include "proto/fight/SFightOrderTarget.h"
#include "proto/fight/SFightLog.h"
#include "proto/fight/SFightSkillObject.h"
#include "proto/fight/SFightSoldierSimple.h"
#include "proto/fight/SFightSoldier.h"
#include "proto/fight/SFightPlayerSimple.h"
#include "proto/fight/SFightPlayerInfo.h"
#include "proto/fight/SFightResult.h"
#include "proto/fight/SFightLogList.h"
#include "proto/fight/SFightRecordSimple.h"
#include "proto/fight/SFightRecord.h"
#include "proto/fight/SSoldier.h"
#include "proto/fight/SFightEndInfo.h"
#include "proto/fight/SFight.h"
#include "proto/fight/CFightData.h"
#include "proto/fight/CFightMap.h"
#include "proto/fight/CFightRecordMap.h"
#include "proto/fight/PQCommonFightApply.h"
#include "proto/fight/PRCommonFightInfo.h"
#include "proto/fight/PRCommonFightServerEnd.h"
#include "proto/fight/PQCommonFightClientEnd.h"
#include "proto/fight/PRCommonFightClientEnd.h"
#include "proto/fight/PQPlayerFightApply.h"
#include "proto/fight/PRPlayerFightInfo.h"
#include "proto/fight/PQPlayerFightQuit.h"
#include "proto/fight/PQPlayerFightAck.h"
#include "proto/fight/PRPlayerFightAck.h"
#include "proto/fight/PQPlayerFightSyn.h"
#include "proto/fight/PRFightRoundData.h"
#include "proto/fight/PRFightEnd.h"
#include "proto/fight/PQFightRecordSave.h"
#include "proto/fight/PQFightRecordGet.h"
#include "proto/fight/PRFightRecordGet.h"
#include "proto/fight/PQFightRecordID.h"
#include "proto/fight/PRFightRecordID.h"
#include "proto/fight/PQFightFirstShow.h"
#include "proto/fight/PQFightSingleArenaApply.h"
#include "proto/fight/PQFightErrorLog.h"
#include "proto/fight/PQCommonFightAuto.h"

#endif
