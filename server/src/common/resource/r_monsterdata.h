#ifndef IMMORTAL_COMMON_RESOURCE_R_MONSTERDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_MONSTERDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CMonsterData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  local_id;
        uint32                                  class_id;
        std::string                             name;
        uint32                                  type;
        uint32                                  equip_type;
        uint32                                  level;
        std::string                             animation_name;
        std::string                             music;
        uint32                                  avatar;
        uint32                                  occupation;
        uint32                                  quality;
        std::vector<uint32>                     packets;
        uint32                                  fight_value;
        uint32                                  initial_rage;
        uint32                                  hp;
        uint32                                  physical_ack;
        uint32                                  physical_def;
        uint32                                  magic_ack;
        uint32                                  magic_def;
        uint32                                  speed;
        uint32                                  critper;
        uint32                                  crithurt;
        uint32                                  critper_def;
        uint32                                  crithurt_def;
        uint32                                  hitper;
        uint32                                  dodgeper;
        uint32                                  parryper;
        uint32                                  parryper_dec;
        uint32                                  stun_def;
        uint32                                  silent_def;
        uint32                                  weak_def;
        uint32                                  fire_def;
        uint32                                  rebound_physical_ack;
        uint32                                  rebound_magic_ack;
        std::vector<S2UInt32>                   odds;
        std::vector<S2UInt32>                   skills;
        uint32                                  money;
        uint32                                  exp;
        std::string                             desc;
        uint32                                  hp_layer;
        std::vector<uint32>                     fight_monster;
        uint32                                  help_monster;
        uint32                                  strength;
        uint32                                  recover_critper;
        uint32                                  recover_critper_def;
        uint32                                  recover_add_fix;
        uint32                                  recover_del_fix;
        uint32                                  recover_add_per;
        uint32                                  recover_del_per;
        uint32                                  rage_add_fix;
        uint32                                  rage_del_fix;
        uint32                                  rage_add_per;
        uint32                                  rage_del_per;
    };

	typedef std::map<uint32, SData*> UInt32MonsterMap;

	CMonsterData();
	virtual ~CMonsterData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32MonsterMap id_monster_map;
	void Add(SData* monster);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_MONSTERMGR_H_
