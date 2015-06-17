#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALMONSTERLVDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALMONSTERLVDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTrialMonsterLvData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  lv;
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

	typedef std::map<uint32, SData*> UInt32TrialMonsterLvMap;

	CTrialMonsterLvData();
	virtual ~CTrialMonsterLvData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 lv );
protected:
	UInt32TrialMonsterLvMap id_trialmonsterlv_map;
	void Add(SData* trialmonsterlv);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TRIALMONSTERLVMGR_H_
