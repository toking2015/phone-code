#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTempleGroupData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  init_lv;
        uint32                                  get_score;
        std::vector<S2UInt32>                   members;
    };

	typedef std::map<uint32, SData*> UInt32TempleGroupMap;

	CTempleGroupData();
	virtual ~CTempleGroupData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TempleGroupMap id_templegroup_map;
	void Add(SData* templegroup);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPMGR_H_
