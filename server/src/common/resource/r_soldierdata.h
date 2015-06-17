#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  locale_id;
        std::string                             name;
        uint32                                  star;
        uint32                                  quality;
        uint32                                  gender;
        uint32                                  equip_type;
        std::string                             animation_name;
        uint32                                  avatar;
        uint32                                  occupation;
        uint32                                  formation;
        uint32                                  race;
        uint32                                  source;
        S3UInt32                                star_cost;
        S3UInt32                                exist_give;
        std::vector<S2UInt32>                   get_attr;
        uint32                                  get_score;
        std::vector<S2UInt32>                   skills;
        std::vector<S2UInt32>                   odds;
        std::vector<std::string>                sounds;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32SoldierMap;

	CSoldierData();
	virtual ~CSoldierData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SoldierMap id_soldier_map;
	void Add(SData* soldier);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIERMGR_H_
