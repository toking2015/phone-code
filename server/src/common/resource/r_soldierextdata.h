#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIEREXTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIEREXTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierExtData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  soldier_id;
        uint32                                  level;
        uint32                                  fighting;
        uint32                                  star;
        uint32                                  quality;
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

	typedef std::map<uint32, SData*> UInt32SoldierExtMap;

	CSoldierExtData();
	virtual ~CSoldierExtData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SoldierExtMap id_soldierext_map;
	void Add(SData* soldierext);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIEREXTMGR_H_
