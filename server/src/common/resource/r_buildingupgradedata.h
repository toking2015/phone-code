#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGUPGRADEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGUPGRADEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBuildingUpgradeData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        uint32                                  u_level;
        uint32                                  f_level;
        uint32                                  w_level;
        uint32                                  s_level;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32BuildingUpgradeMap;

	CBuildingUpgradeData();
	virtual ~CBuildingUpgradeData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 level );

protected:
	UInt32BuildingUpgradeMap id_buildingupgrade_map;
	void Add(SData* buildingupgrade);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BUILDINGUPGRADEMGR_H_
