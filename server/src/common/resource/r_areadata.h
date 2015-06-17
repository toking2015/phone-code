#ifndef IMMORTAL_COMMON_RESOURCE_R_AREADATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_AREADATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CAreaData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        uint32                                  normal_pass_reward;
        uint32                                  elite_pass_reward;
        uint32                                  normal_full_reward;
        uint32                                  elite_full_reward;
        std::vector<uint32>                     copy;
        uint32                                  icon;
        uint32                                  level;
    };

	typedef std::map<uint32, SData*> UInt32AreaMap;

	CAreaData();
	virtual ~CAreaData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32AreaMap id_area_map;
	void Add(SData* area);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_AREAMGR_H_
