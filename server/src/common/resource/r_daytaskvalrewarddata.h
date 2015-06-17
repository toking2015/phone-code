#ifndef IMMORTAL_COMMON_RESOURCE_R_DAYTASKVALREWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_DAYTASKVALREWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CDayTaskValRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  need_val;
        std::vector<S3UInt32>                   reward;
    };

	typedef std::map<uint32, SData*> UInt32DayTaskValRewardMap;

	CDayTaskValRewardData();
	virtual ~CDayTaskValRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32DayTaskValRewardMap id_daytaskvalreward_map;
	void Add(SData* daytaskvalreward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_DAYTASKVALREWARDMGR_H_
