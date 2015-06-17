#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOINDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOINDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBuildingCoinData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  building;
        std::vector<S3UInt32>                   value;
    };

	typedef std::map<uint32, SData*> UInt32BuildingCoinMap;

	CBuildingCoinData();
	virtual ~CBuildingCoinData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 building );
protected:
	UInt32BuildingCoinMap id_buildingcoin_map;
	void Add(SData* buildingcoin);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOINMGR_H_
