#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENABATTLEREWARDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENABATTLEREWARDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSingleArenaBattleRewardData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  field_b;
        uint32                                  field_e;
        uint32                                  field_r;
        uint32                                  field_y;
    };

	typedef std::map<uint32, SData*> UInt32SingleArenaBattleRewardMap;

	CSingleArenaBattleRewardData();
	virtual ~CSingleArenaBattleRewardData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SingleArenaBattleRewardMap id_singlearenabattlereward_map;
	void Add(SData* singlearenabattlereward);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SINGLEARENABATTLEREWARDMGR_H_
