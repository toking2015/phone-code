#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTrialData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        std::vector<uint32>                     open_day;
        uint32                                  strength_cost;
        uint32                                  try_count;
        uint32                                  monster_id;
        uint32                                  trial_occu;
        std::vector<S2UInt32>                   occu_odd;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32TrialMap;

	CTrialData();
	virtual ~CTrialData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TrialMap id_trial_map;
	void Add(SData* trial);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TRIALMGR_H_
