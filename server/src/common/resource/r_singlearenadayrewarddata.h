#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENADAYREWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENADAYREWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSingleArenaDayRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        S2UInt32                                rank;
        std::vector<S3UInt32>                   reward_;
    };

	typedef std::map<uint32, SData*> UInt32SingleArenaDayRewardMap;

	CSingleArenaDayRewardData();
	virtual ~CSingleArenaDayRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SingleArenaDayRewardMap id_singlearenadayreward_map;
	void Add(SData* singlearenadayreward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SINGLEARENADAYREWARDMGR_H_
