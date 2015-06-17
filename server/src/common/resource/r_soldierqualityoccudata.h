#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYOCCUDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYOCCUDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierQualityOccuData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  quality_id;
        uint32                                  occu_id;
        S3UInt32                                cost;
        uint32                                  limit_lv;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32SoldierQualityOccuMap;

	CSoldierQualityOccuData();
	virtual ~CSoldierQualityOccuData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 quality_id, uint32 occu_id );

protected:
	UInt32SoldierQualityOccuMap id_soldierqualityoccu_map;
	void Add(SData* soldierqualityoccu);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYOCCUMGR_H_
