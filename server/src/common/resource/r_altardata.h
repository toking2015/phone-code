#ifndef IMMORTAL_COMMON_RESOURCE_R_ALTARDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ALTARDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CAltarData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  type;
        uint32                                  lv;
        S3UInt32                                reward;
        S3UInt32                                extra_reward;
        uint32                                  prob;
        uint32                                  is_rare;
        uint32                                  is_ten;
    };

	typedef std::map<uint32, SData*> UInt32AltarMap;

	CAltarData();
	virtual ~CAltarData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32AltarMap id_altar_map;
	void Add(SData* altar);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ALTARMGR_H_
