#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGSPEEDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGSPEEDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBuildingSpeedData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  level;
        uint32                                  speed2;
        uint32                                  speed6;
    };

	typedef std::map<uint32, SData*> UInt32BuildingSpeedMap;

	CBuildingSpeedData();
	virtual ~CBuildingSpeedData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 level );
protected:
	UInt32BuildingSpeedMap id_buildingspeed_map;
	void Add(SData* buildingspeed);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BUILDINGSPEEDMGR_H_
