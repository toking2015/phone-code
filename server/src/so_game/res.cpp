#include "misc.h"
#include "jsonconfig.h"
#include "settings.h"
#include "master.h"
#include "system_event.h"
#include "resource/r_itemext.h"
#include "resource/r_itemmergeext.h"
#include "resource/r_itemtypeext.h"
#include "resource/r_varext.h"
#include "resource/r_globalext.h"
#include "resource/r_basedata.h"
#include "resource/r_bagcountext.h"
#include "resource/r_soldierext.h"
#include "resource/r_soldierextext.h"
#include "resource/r_soldierbaseext.h"
#include "resource/r_monsterext.h"
#include "resource/r_monsterfightconfext.h"
#include "resource/r_soldierqualityext.h"
#include "resource/r_soldierqualityxpext.h"
#include "resource/r_soldierqualityoccuext.h"
#include "resource/r_soldierlvext.h"
#include "resource/r_soldierstarext.h"
#include "resource/r_soldierrecruitext.h"
#include "resource/r_soldierequipmgr.h"
#include "resource/r_buildingext.h"
#include "resource/r_buildingupgradeext.h"
#include "resource/r_areaext.h"
#include "resource/r_copyext.h"
#include "resource/r_copychunkext.h"
#include "resource/r_gutext.h"
#include "resource/r_packetext.h"
#include "resource/r_rewardext.h"
#include "resource/r_totemext.h"
#include "resource/r_totemattrext.h"
#include "resource/r_totemextext.h"
#include "resource/r_totemglyphext.h"
#include "resource/r_totemglyphhideext.h"
#include "resource/r_oddext.h"
#include "resource/r_taskext.h"
#include "resource/r_levelext.h"
#include "resource/r_activityext.h"
#include "resource/r_activityopenext.h"
#include "resource/r_rankcopyext.h"
#include "resource/r_signdayext.h"
#include "resource/r_signsumext.h"
#include "resource/r_signadditionalcostext.h"
#include "resource/r_buildingspeedext.h"
#include "resource/r_buildingcostext.h"
#include "resource/r_buildingcoinext.h"
#include "resource/r_buildingcrittimesext.h"
#include "resource/r_altarext.h"
#include "resource/r_formationindexext.h"
#include "resource/r_effectext.h"
#include "resource/r_payext.h"
#include "resource/r_vipprivilegeext.h"
#include "resource/r_avatarext.h"
#include "resource/r_singlearenasoldierext.h"
#include "resource/r_singlearenatotemext.h"
#include "resource/r_equipqualityext.h"
#include "resource/r_equipsuitmgr.h"
#include "resource/r_paperskillext.h"
#include "resource/r_papercreateext.h"
#include "resource/r_copymaterialext.h"
#include "resource/r_singlearenabattlerewardext.h"
#include "resource/r_singlearenadayrewardext.h"
#include "resource/r_marketext.h"
#include "resource/r_vendibleext.h"
#include "resource/r_mysteryshopext.h"
#include "resource/r_mysteryshopext.h"
#include "resource/r_trialext.h"
#include "resource/r_trialrewardext.h"
#include "resource/r_trialrewardcountext.h"
#include "resource/r_trialmonsterlvext.h"
#include "resource/r_itemopenext.h"
#include "resource/r_tombext.h"
#include "resource/r_tombrewardext.h"
#include "resource/r_tombrewardbaseext.h"
#include "resource/r_tombmonsterlvext.h"
#include "resource/r_templegroupext.h"
#include "resource/r_templegrouplevelupext.h"
#include "resource/r_templeglyphext.h"
#include "resource/r_templeglyphattrext.h"
#include "resource/r_templescorerewardext.h"
#include "resource/r_templeholeext.h"
#include "resource/r_templesuitattrext.h"
#include "resource/r_viptimelimitshopext.h"
#include "resource/r_opentargetext.h"
#include "resource/r_biasext.h"
#include "resource/r_fixedequipext.h"
#include "resource/r_achievementgoodsext.h"
#include "resource/r_daytaskvalrewardext.h"

SO_LOAD( res_interface_register )
{
    //dir目录赋值
    CJson::dir = settings::json()[ "extras_dir" ].asString() + "/xls/";

    //设置theRes的析构函数
    theMaster._resource_reg_free = CResData::data_free;
    theItemExt.LoadData();
    theItemMergeExt.LoadData();
    theItemTypeExt.LoadData();
    theItemOpenExt.LoadData();
    theBagCountExt.LoadData();
    theGlobalExt.LoadData();
    theVarExt.LoadData();
    theMonsterExt.LoadData();
    theMonsterFightConfExt.LoadData();
    theSoldierExt.LoadData();
    theSoldierExtExt.LoadData();
    theSoldierBaseExt.LoadData();
    theSoldierQualityExt.LoadData();
    theSoldierQualityXpExt.LoadData();
    theSoldierQualityOccuExt.LoadData();
    theSoldierLvExt.LoadData();
    theSoldierStarExt.LoadData();
    theSoldierRecruitExt.LoadData();
    theSoldierEquipMgr.LoadData();
    theBuildingExt.LoadData();
    theBuildingUpgradeExt.LoadData();
    theOddExt.LoadData();
    theEffectExt.LoadData();

    theRewardExt.LoadData();
    thePacketExt.LoadData();
    theGutExt.LoadData();
    theCopyChunkExt.LoadData();
    theCopyExt.LoadData();
    theAreaExt.LoadData();
    theTotemExt.LoadData();
    theTotemAttrExt.LoadData();
    theTotemExtExt.LoadData();
    theTotemGlyphExt.LoadData();
    theTotemGlyphHideExt.LoadData();
    theTaskExt.LoadData();
    theLevelExt.LoadData();
    theActivityExt.LoadData();
    theActivityOpenExt.LoadData();
    theRankCopyExt.LoadData();
    theSignDayExt.LoadData();
    theSignSumExt.LoadData();
    theSignAdditionalCostExt.LoadData();
    theBuildingSpeedExt.LoadData();
    theBuildingCostExt.LoadData();
    theBuildingCoinExt.LoadData();
    theBuildingCritTimesExt.LoadData();
    theAltarExt.LoadData();
    theFormationIndexExt.LoadData();
    thePayExt.LoadData();
    theVipPrivilegeExt.LoadData();
    theAvatarExt.LoadData();
    theSingleArenaSoldierExt.LoadData();
    theSingleArenaTotemExt.LoadData();
    theEquipQualityExt.LoadData();
    theEquipSuitMgr.LoadData();
    thePaperSkillExt.LoadData();
    thePaperCreateExt.LoadData();
    theCopyMaterialExt.LoadData();
    theSingleArenaDayRewardExt.LoadData();
    theSingleArenaBattleRewardExt.LoadData();
    theMarketExt.LoadData();
    theVendibleExt.LoadData();
    theMysteryShopExt.LoadData();
    theTrialExt.LoadData();
    theTrialRewardExt.LoadData();
    theTrialRewardCountExt.LoadData();
    theTrialMonsterLvExt.LoadData();
    theTombExt.LoadData();
    theTombRewardExt.LoadData();
    theTombRewardBaseExt.LoadData();
    theTombMonsterLvExt.LoadData();
    theTempleGroupExt.LoadData();
    theTempleGroupLevelUpExt.LoadData();
    theTempleGlyphExt.LoadData();
    theTempleGlyphAttrExt.LoadData();
    theTempleScoreRewardExt.LoadData();
    theTempleHoleExt.LoadData();
    theTempleSuitAttrExt.LoadData();
    theVipTimeLimitShopExt.LoadData();
    theOpenTargetExt.LoadData();
    theBiasExt.LoadData();
    theFixedEquipExt.LoadData();
    theAchievementGoodsExt.LoadData();
    theDayTaskValRewardExt.LoadData();

    //event::dispatch( SEventJsonLoaded() );
}


