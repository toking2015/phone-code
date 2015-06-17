#ifndef IMMORTAL_COMMON_RESOURCE_R_LEVELDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_LEVELDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CLevelData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  level;
        uint32                                  team_xp;
        uint32                                  vip_xp;
        uint32                                  strength;
        uint32                                  strength_buy;
        uint32                                  strength_price;
        uint32                                  strength_give;
        uint32                                  formation_count;
        uint32                                  formation_totem_count;
        uint32                                  soldier_lv;
        uint32                                  active_score_max;
        uint32                                  building_gold_times;
        uint32                                  building_water_times;
        uint32                                  singlearena_times;
        uint32                                  singlearena_price;
        S3UInt32                                task_30001;
        S3UInt32                                task_30002;
        uint32                                  copy_normal_reset_times;
        uint32                                  copy_elite_reset_times;
        uint32                                  copy_normal_reset_price;
        uint32                                  copy_elite_reset_price;
        std::string                             open_desc;
        uint32                                  tomb_ratio;
        std::string                             vip_rights_desc;
        uint32                                  glyph_lv;
    };

	typedef std::map<uint32, SData*> UInt32LevelMap;

	CLevelData();
	virtual ~CLevelData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 level );
protected:
	UInt32LevelMap id_level_map;
	void Add(SData* level);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_LEVELMGR_H_
