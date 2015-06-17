#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDCOUNTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDCOUNTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTrialRewardCountData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  trial_id;
        uint32                                  reward_count;
        uint32                                  trial_val;
        S3UInt32                                reward_cost;
        std::string                             desc;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32TrialRewardCountMap;

	CTrialRewardCountData();
	virtual ~CTrialRewardCountData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 trial_id, uint32 reward_count );

protected:
	UInt32TrialRewardCountMap id_trialrewardcount_map;
	void Add(SData* trialrewardcount);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDCOUNTMGR_H_
