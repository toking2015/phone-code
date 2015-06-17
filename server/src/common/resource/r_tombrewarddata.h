#ifndef IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTombRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  quality;
        uint32                                  reward;
        S2UInt32                                level_rand;
        uint32                                  percent;
        uint32                                  extra_reward;
        uint32                                  extra_percent;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32TombRewardMap;

	CTombRewardData();
	virtual ~CTombRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TombRewardMap id_tombreward_map;
	void Add(SData* tombreward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDMGR_H_
