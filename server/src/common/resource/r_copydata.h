#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CCopyData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        uint32                                  type;
        uint32                                  level;
        uint32                                  task;
        uint32                                  guage;
        std::vector<S3UInt32>                   boss_chunk;
        uint32                                  pass_reward;
        std::vector<S3UInt32>                   pass_equip;
        std::vector<S3UInt32>                   chunk;
        std::vector<S2UInt32>                   reward;
        S2UInt32                                mapid;
        std::string                             desc;
        uint32                                  icon;
        S2UInt32                                pos;
        std::string                             foot_sound;
        std::string                             bg_sound;
        uint32                                  drop_item;
        uint32                                  elitedrop_item;
    };

	typedef std::map<uint32, SData*> UInt32CopyMap;

	CCopyData();
	virtual ~CCopyData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32CopyMap id_copy_map;
	void Add(SData* copy);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_COPYMGR_H_
