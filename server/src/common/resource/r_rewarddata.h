#ifndef IMMORTAL_COMMON_RESOURCE_R_REWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_REWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::vector<S3UInt32>                   coins;
    };

	typedef std::map<uint32, SData*> UInt32RewardMap;

	CRewardData();
	virtual ~CRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32RewardMap id_reward_map;
	void Add(SData* reward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_REWARDMGR_H_
