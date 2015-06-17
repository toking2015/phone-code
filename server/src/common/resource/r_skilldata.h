#ifndef IMMORTAL_COMMON_RESOURCE_R_SKILLDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SKILLDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSkillData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        uint32                                  locale_id;
        uint32                                  disillusion;
        uint32                                  type;
        uint32                                  distance;
        std::string                             name;
        uint32                                  condition;
        uint32                                  attr;
        uint32                                  occupation;
        uint32                                  icon;
        uint32                                  icon_type;
        uint32                                  buckle_blood;
        std::string                             vibrate;
        std::string                             flash;
        std::vector<S2UInt32>                   mights;
        uint32                                  hurt_add;
        uint32                                  break_per;
        uint32                                  can_break;
        uint32                                  self_addrage;
        uint32                                  self_costrage;
        uint32                                  def_addrage;
        uint32                                  def_delrage;
        uint32                                  self_addtotem;
        uint32                                  self_costtotem;
        uint32                                  def_addtotem;
        uint32                                  clear_rage;
        uint32                                  clear_odd;
        uint32                                  suck_hp;
        uint32                                  pattern;
        uint32                                  target_type;
        uint32                                  target_range_count;
        uint32                                  target_range_cond;
        std::vector<S2UInt32>                   odds;
        uint32                                  cooldown;
        uint32                                  start_round;
        std::string                             action_flag;
        uint32                                  effect_index;
        std::string                             skillname;
        uint32                                  interval;
        std::string                             desc;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32SkillMap;

	CSkillData();
	virtual ~CSkillData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 level );

protected:
	UInt32SkillMap id_skill_map;
	void Add(SData* skill);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SKILLMGR_H_
