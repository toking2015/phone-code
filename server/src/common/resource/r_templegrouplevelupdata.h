#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPLEVELUPDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPLEVELUPDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTempleGroupLevelUpData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        uint32                                  star;
        uint32                                  score;
        std::vector<S2UInt32>                   attrs;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32TempleGroupLevelUpMap;

	CTempleGroupLevelUpData();
	virtual ~CTempleGroupLevelUpData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 level );

protected:
	UInt32TempleGroupLevelUpMap id_templegrouplevelup_map;
	void Add(SData* templegrouplevelup);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPLEVELUPMGR_H_
