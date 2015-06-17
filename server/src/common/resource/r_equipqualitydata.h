#ifndef IMMORTAL_COMMON_RESOURCE_R_EQUIPQUALITYDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_EQUIPQUALITYDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CEquipQualityData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  quality;
        uint32                                  main_min;
        uint32                                  main_max;
        uint32                                  slave_min;
        uint32                                  slave_max;
        uint32                                  slave_attr_num;
    };

	typedef std::map<uint32, SData*> UInt32EquipQualityMap;

	CEquipQualityData();
	virtual ~CEquipQualityData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 quality );
protected:
	UInt32EquipQualityMap id_equipquality_map;
	void Add(SData* equipquality);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_EQUIPQUALITYMGR_H_
