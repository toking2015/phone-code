#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGVIEWDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGVIEWDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBuildingViewData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        uint32                                  page;
        uint32                                  x;
        uint32                                  y;
        std::string                             command;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32BuildingViewMap;

	CBuildingViewData();
	virtual ~CBuildingViewData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32BuildingViewMap id_buildingview_map;
	void Add(SData* buildingview);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BUILDINGVIEWMGR_H_
