#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBuildingData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  type;
        uint32                                  common_open;
        uint32                                  copy_open;
        uint32                                  task_open;
        std::string                             name;
        std::string                             description;
        uint32                                  length;
        uint32                                  width;
        uint32                                  upgrade;
        uint32                                  up_if;
        uint32                                  icon;
        uint32                                  isShow;
    };

	typedef std::map<uint32, SData*> UInt32BuildingMap;

	CBuildingData();
	virtual ~CBuildingData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32BuildingMap id_building_map;
	void Add(SData* building);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BUILDINGMGR_H_
