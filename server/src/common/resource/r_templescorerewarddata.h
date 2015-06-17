#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLESCOREREWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLESCOREREWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTempleScoreRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  score;
        std::vector<S3UInt32>                   reward;
    };

	typedef std::map<uint32, SData*> UInt32TempleScoreRewardMap;

	CTempleScoreRewardData();
	virtual ~CTempleScoreRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TempleScoreRewardMap id_templescorereward_map;
	void Add(SData* templescorereward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TEMPLESCOREREWARDMGR_H_
