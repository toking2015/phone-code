#include "proto/constant.h"
#include <map>

namespace constant
{

const char* get_path_name( uint32 val )
{
    static std::map< uint32, const char* > map;
    if ( map.empty() )
    {
        map[ 2119033226 ]		= "kPathAchievementMedalShop";
        map[ 1536045941 ]		= "kPathAchievementTombShop";
        map[ 458473657 ]		= "kPathActiveScoreReset";
        map[ 1417400276 ]		= "kPathActivityClose";
        map[ 677971819 ]		= "kPathActivityOpen";
        map[ 1700752458 ]		= "kPathActivityReward";
        map[ 1583754902 ]		= "kPathAltar";
        map[ 1331875543 ]		= "kPathBuildingGetOutput";
        map[ 459958712 ]		= "kPathBuildingLeveUp";
        map[ 873661828 ]		= "kPathBuildingSpeedOutput";
        map[ 84965152 ]		= "kPathChangeAvatar";
        map[ 1924174318 ]		= "kPathChangeName";
        map[ 1082442933 ]		= "kPathClearMasteryCD";
        map[ 1271127800 ]		= "kPathCommonShop";
        map[ 784566122 ]		= "kPathCopyAreaPass";
        map[ 731592263 ]		= "kPathCopyAreaPresentTake";
        map[ 331226124 ]		= "kPathCopyBossFight";
        map[ 1955292224 ]		= "kPathCopyBossMopup";
        map[ 2979731 ]		= "kPathCopyCollect";
        map[ 1577068634 ]		= "kPathCopyCommit";
        map[ 636723069 ]		= "kPathCopyFightMeet";
        map[ 1668870455 ]		= "kPathCopyGroupPass";
        map[ 541069187 ]		= "kPathCopyMopupReset";
        map[ 487341379 ]		= "kPathCopyPass";
        map[ 1603270542 ]		= "kPathCopyPassEquip";
        map[ 44267644 ]		= "kPathCopySearch";
        map[ 1110794590 ]		= "kPathDayTaskValReset";
        map[ 1750380674 ]		= "kPathDayTaskValReward";
        map[ 659351692 ]		= "kPathDrop";
        map[ 983812305 ]		= "kPathEquipReplace";
        map[ 1 ]		= "kPathEquipSelect";
        map[ 595290871 ]		= "kPathFightNormal";
        map[ 1351766338 ]		= "kPathFirstPay";
        map[ 1268724712 ]		= "kPathFormationSet";
        map[ 281860286 ]		= "kPathFriendSend";
        map[ 25800757 ]		= "kPathGameMasterCommand";
        map[ 94677408 ]		= "kPathGuildContribute";
        map[ 195444527 ]		= "kPathGuildCreate";
        map[ 1927710242 ]		= "kPathGuildExit";
        map[ 440539142 ]		= "kPathGuildInit";
        map[ 810820358 ]		= "kPathGuildJobChange";
        map[ 1603195559 ]		= "kPathGuildJoin";
        map[ 1021453233 ]		= "kPathGuildLevelup";
        map[ 741151118 ]		= "kPathGuildLoad";
        map[ 1882356240 ]		= "kPathGuildShop";
        map[ 1186291935 ]		= "kPathGutCommit";
        map[ 853097368 ]		= "kPathGutFinish";
        map[ 2027073428 ]		= "kPathItemAdd";
        map[ 1324150315 ]		= "kPathItemDice";
        map[ 1142902209 ]		= "kPathItemMove";
        map[ 1028625609 ]		= "kPathItemUse";
        map[ 1831050662 ]		= "kPathMailUserSend";
        map[ 884419040 ]		= "kPathMarketAutoBuy";
        map[ 366073746 ]		= "kPathMarketBuy";
        map[ 357133648 ]		= "kPathMarketCargoDown";
        map[ 2044516102 ]		= "kPathMarketCargoUp";
        map[ 805155233 ]		= "kPathMarketChange";
        map[ 1892309926 ]		= "kPathMarketRef";
        map[ 254524643 ]		= "kPathMarketReturn";
        map[ 930146548 ]		= "kPathMarketSell";
        map[ 170991727 ]		= "kPathMedalShop";
        map[ 265266382 ]		= "kPathMerge";
        map[ 1554365024 ]		= "kPathMergeBook";
        map[ 2025500073 ]		= "kPathMergeEquip";
        map[ 1332934034 ]		= "kPathMonthReward";
        map[ 1773888049 ]		= "kPathMysteryShop";
        map[ 448618963 ]		= "kPathOpenTargetBuy";
        map[ 1789308928 ]		= "kPathOpenTargetTake";
        map[ 1326081307 ]		= "kPathPaperCreate";
        map[ 30404056 ]		= "kPathPaperSkillForget";
        map[ 458509659 ]		= "kPathPaperSkillLevelUp";
        map[ 1647769913 ]		= "kPathPay";
        map[ 1491980783 ]		= "kPathPayPresent";
        map[ 882915109 ]		= "kPathPresentGlobalTake";
        map[ 1351704370 ]		= "kPathRedeem";
        map[ 1010394484 ]		= "kPathSell";
        map[ 947156890 ]		= "kPathSign";
        map[ 1865316154 ]		= "kPathSingleArena";
        map[ 1147998484 ]		= "kPathSoldierAdd";
        map[ 616304367 ]		= "kPathSoldierDel";
        map[ 382737524 ]		= "kPathSoldierEquip";
        map[ 257383971 ]		= "kPathSoldierEquipSkill";
        map[ 1029450723 ]		= "kPathSoldierLvUp";
        map[ 1631393222 ]		= "kPathSoldierMove";
        map[ 1768905208 ]		= "kPathSoldierQualityUp";
        map[ 534240037 ]		= "kPathSoldierQualityXpAdd";
        map[ 1266828872 ]		= "kPathSoldierRecruit";
        map[ 1043530847 ]		= "kPathSoldierSkillLvUp";
        map[ 1272384774 ]		= "kPathSoldierSkillReset";
        map[ 1854145592 ]		= "kPathSoldierStarUp";
        map[ 1248765147 ]		= "kPathStrengthBuy";
        map[ 1617518012 ]		= "kPathStrengthTimer";
        map[ 1447752712 ]		= "kPathSystemAuto";
        map[ 94118515 ]		= "kPathTaskAccept";
        map[ 339870132 ]		= "kPathTaskAutoFinished";
        map[ 1563095759 ]		= "kPathTaskFinished";
        map[ 308776875 ]		= "kPathTeamLevelUp";
        map[ 626346520 ]		= "kPathTemple";
        map[ 1802264557 ]		= "kPathTempleEmbedGlyph";
        map[ 1560376085 ]		= "kPathTempleGroupAdd";
        map[ 83421914 ]		= "kPathTempleGroupLevelUp";
        map[ 563037377 ]		= "kPathTempleOpenHole";
        map[ 486298842 ]		= "kPathTempleScoreReward";
        map[ 31278397 ]		= "kPathTempleTrainGlyph";
        map[ 878590869 ]		= "kPathTombFight";
        map[ 1310537727 ]		= "kPathTombMopUp";
        map[ 2087704392 ]		= "kPathTombPlayerReset";
        map[ 1394672885 ]		= "kPathTombRewardGet";
        map[ 1977546372 ]		= "kPathTombShop";
        map[ 16753434 ]		= "kPathTombShopRefresh";
        map[ 1679177212 ]		= "kPathTotemAccelerate";
        map[ 696632415 ]		= "kPathTotemActivate";
        map[ 345869345 ]		= "kPathTotemGlyphEmbed";
        map[ 818430494 ]		= "kPathTotemGlyphMerge";
        map[ 532779750 ]		= "kPathTotemTrain";
        map[ 556093447 ]		= "kPathTotemUserInit";
        map[ 537836721 ]		= "kPathTrialAgile";
        map[ 1253727759 ]		= "kPathTrialFinish";
        map[ 306505229 ]		= "kPathTrialIntelligence";
        map[ 231757346 ]		= "kPathTrialRewardGet";
        map[ 2132077111 ]		= "kPathTrialStrength";
        map[ 374239832 ]		= "kPathTrialSurvival";
        map[ 1821417889 ]		= "kPathUserEveryDay";
        map[ 26069095 ]		= "kPathUserInit";
        map[ 1764226070 ]		= "kPathUserLoad";
        map[ 367449528 ]		= "kPathUserLogin";
        map[ 777059757 ]		= "kPathUserMeet";
        map[ 1835213494 ]		= "kPathVipLevelUp";
        map[ 1557217052 ]		= "kPathVipTimeLimitShop";
    }

    return map[ val ];
}

}
