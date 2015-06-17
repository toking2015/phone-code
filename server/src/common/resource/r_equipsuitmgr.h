#ifndef IMMORTAL_COMMON_RESOURCE_R_EQUIPSUITDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_EQUIPSUITDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CEquipSuitData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  level;
        uint32                                  quality;
        uint32                                  equip_type;
        uint32                                  limit_level;
        std::vector<S2UInt32>                   odds;
    };

	typedef std::vector<SData*> UInt32EquipSuitVec;
    typedef std::map<uint32, UInt32EquipSuitVec> UInt32EquipSuitMap;

	CEquipSuitData();
	virtual ~CEquipSuitData();
	virtual void LoadData(void);
	void ClearData(void);

    // 找到类型为equip_type并且limit_level小于level的所有套装
    UInt32EquipSuitVec FindSuits(uint32 equip_type, uint32 soldier_level, uint32 suit_level);
    SData * Find(uint32 equip_type, uint32 level, uint32 quality);
    // 获取套装等级列表
    std::vector<uint32> GetSuitLevels();

protected:
	UInt32EquipSuitMap id_equipsuit_map;
    std::set<uint32> suit_levels;
	void Add(SData* equipsuit);
};

#define theEquipSuitMgr TSignleton<CEquipSuitData>::Ref()
#endif  //IMMORTAL_COMMON_RESOURCE_R_EQUIPSUITMGR_H_
