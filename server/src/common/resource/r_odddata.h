#ifndef IMMORTAL_COMMON_RESOURCE_R_ODDDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ODDDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class COddData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        std::string                             name;
        uint32                                  max_count;
        uint32                                  condition;
        uint32                                  immediately;
        uint32                                  percent;
        uint32                                  icon;
        uint32                                  type;
        uint32                                  attr;
        uint32                                  delay_round;
        uint32                                  keep_round;
        S3UInt32                                status;
        S3UInt32                                effect;
        uint32                                  effect_count;
        std::string                             description;
        uint32                                  target_type_skill;
        uint32                                  target_type_special;
        uint32                                  target_type;
        uint32                                  target_range_count;
        uint32                                  target_range_cond;
        S2UInt32                                addodd;
        S2UInt32                                changeodd;
        uint32                                  limit_count;
        uint32                                  limit_count_all;
        std::string                             onceeffect;
        std::string                             buffeffect;
        std::string                             buffname;
        uint32                                  buff_offset;
        uint32                                  buff_only;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32OddMap;

	COddData();
	virtual ~COddData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 level );

protected:
	UInt32OddMap id_odd_map;
	void Add(SData* odd);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ODDMGR_H_
