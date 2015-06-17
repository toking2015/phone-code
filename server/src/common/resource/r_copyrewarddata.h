#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYREWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYREWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CCopyRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  gid;
        std::vector<S2UInt32>                   coin;
    };

	typedef std::map<uint32, SData*> UInt32CopyRewardMap;

	CCopyRewardData();
	virtual ~CCopyRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 gid );
protected:
	UInt32CopyRewardMap id_copyreward_map;
	void Add(SData* copyreward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_COPYREWARDMGR_H_
