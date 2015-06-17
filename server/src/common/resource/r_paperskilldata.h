#ifndef IMMORTAL_COMMON_RESOURCE_R_PAPERSKILLDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_PAPERSKILLDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CPaperSkillData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  skill_type;
        uint32                                  level;
        uint32                                  paper_level_limit;
        uint32                                  collect_skill_level;
        uint32                                  active_score_limit;
        uint32                                  active_score_add;
        uint32                                  create_cost_reduce;
        uint32                                  level_up_star;
        uint32                                  level_up_money;
    };

	typedef std::map<uint32, SData*> UInt32PaperSkillMap;

	CPaperSkillData();
	virtual ~CPaperSkillData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32PaperSkillMap id_paperskill_map;
	void Add(SData* paperskill);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_PAPERSKILLMGR_H_
