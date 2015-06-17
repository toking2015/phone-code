#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERRECRUITDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERRECRUITDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierRecruitData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  soldier_id;
        std::vector<S3UInt32>                   cost_;
    };

	typedef std::map<uint32, SData*> UInt32SoldierRecruitMap;

	CSoldierRecruitData();
	virtual ~CSoldierRecruitData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SoldierRecruitMap id_soldierrecruit_map;
	void Add(SData* soldierrecruit);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIERRECRUITMGR_H_
