#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierQualityData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  lv;
        S2UInt32                                quality_effect;
        uint32                                  xp;
        uint32                                  skill_active;
        uint32                                  disillusion_skill_level;
        uint32                                  lv_limit;
        uint32                                  skill_point;
        std::vector<S3UInt32>                   costs;
        uint32                                  hp;
        uint32                                  physical_ack;
        uint32                                  physical_def;
        uint32                                  magic_ack;
        uint32                                  magic_def;
        uint32                                  speed;
    };

	typedef std::map<uint32, SData*> UInt32SoldierQualityMap;

	CSoldierQualityData();
	virtual ~CSoldierQualityData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 lv );
protected:
	UInt32SoldierQualityMap id_soldierquality_map;
	void Add(SData* soldierquality);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYMGR_H_
