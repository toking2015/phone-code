#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIEREQUIPDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIEREQUIPDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierEquipData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  soldier_id;
        uint32                                  equip_id;
        std::vector<S2UInt32>                   effects;
    };

    typedef std::map<uint32, SData*> EquipList;
    typedef std::map<uint32, EquipList> SoldierEquipList;

	CSoldierEquipData();
	virtual ~CSoldierEquipData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 soldier_id, uint32 equip_id );

protected:
	SoldierEquipList id_soldierequip_list;
	void Add(SData* soldierequip);
};

#define theSoldierEquipMgr TSignleton<CSoldierEquipData>::Ref()
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIEREQUIPMGR_H_
