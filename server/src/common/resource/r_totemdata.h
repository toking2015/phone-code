#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTotemData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        uint32                                  type;
        std::string                             ready;
        uint32                                  init_lv;
        uint32                                  init_attr_lv;
        uint32                                  max_lv;
        std::vector<S2UInt32>                   get_attr;
        uint32                                  get_score;
        std::vector<S3UInt32>                   activate_conds;
        std::string                             animation_name;
        std::string                             ready_animation;
        std::string                             passive_act;
        uint32                                  avatar;
        uint32                                  quality;
        std::string                             desc;
        std::string                             path;
    };

	typedef std::map<uint32, SData*> UInt32TotemMap;

	CTotemData();
	virtual ~CTotemData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TotemMap id_totem_map;
	void Add(SData* totem);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOTEMMGR_H_
