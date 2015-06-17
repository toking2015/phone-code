#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGCRITTIMESDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGCRITTIMESDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBuildingCritTimesData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  building_type;
        std::vector<S2UInt32>                   times;
    };

	typedef std::map<uint32, SData*> UInt32BuildingCritTimesMap;

	CBuildingCritTimesData();
	virtual ~CBuildingCritTimesData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 building_type );
protected:
	UInt32BuildingCritTimesMap id_buildingcrittimes_map;
	void Add(SData* buildingcrittimes);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BUILDINGCRITTIMESMGR_H_
