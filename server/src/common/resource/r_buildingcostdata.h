#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOSTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOSTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBuildingCostData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  times;
        S3UInt32                                cost2;
        S3UInt32                                cost6;
    };

	typedef std::map<uint32, SData*> UInt32BuildingCostMap;

	CBuildingCostData();
	virtual ~CBuildingCostData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 times );
protected:
	UInt32BuildingCostMap id_buildingcost_map;
	void Add(SData* buildingcost);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOSTMGR_H_
