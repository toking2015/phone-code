#ifndef IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDBASEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDBASEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTombRewardBaseData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  reward;
        uint32                                  tomb_coin;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32TombRewardBaseMap;

	CTombRewardBaseData();
	virtual ~CTombRewardBaseData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TombRewardBaseMap id_tombrewardbase_map;
	void Add(SData* tombrewardbase);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDBASEMGR_H_
