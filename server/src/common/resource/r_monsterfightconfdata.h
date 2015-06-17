#ifndef IMMORTAL_COMMON_RESOURCE_R_MONSTERFIGHTCONFDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_MONSTERFIGHTCONFDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CMonsterFightConfData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  index;
        std::vector<S2UInt32>                   add;
        std::vector<S2UInt32>                   totemadd;
    };

	typedef std::map<uint32, SData*> UInt32MonsterFightConfMap;

	CMonsterFightConfData();
	virtual ~CMonsterFightConfData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 index );
protected:
	UInt32MonsterFightConfMap id_monsterfightconf_map;
	void Add(SData* monsterfightconf);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_MONSTERFIGHTCONFMGR_H_
