#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYXPDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYXPDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierQualityXpData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        S3UInt32                                coin;
        S2UInt32                                quality_lv;
        uint32                                  quality_xp;
    };

	typedef std::map<uint32, SData*> UInt32SoldierQualityXpMap;

	CSoldierQualityXpData();
	virtual ~CSoldierQualityXpData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SoldierQualityXpMap id_soldierqualityxp_map;
	void Add(SData* soldierqualityxp);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYXPMGR_H_
