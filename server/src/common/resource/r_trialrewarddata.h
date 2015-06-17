#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTrialRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  trial_id;
        uint32                                  reward;
        S2UInt32                                level_rand;
        uint32                                  percent;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32TrialRewardMap;

	CTrialRewardData();
	virtual ~CTrialRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TrialRewardMap id_trialreward_map;
	void Add(SData* trialreward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDMGR_H_
