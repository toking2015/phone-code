#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMEXTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMEXTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTotemExtData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  totem_id;
        uint32                                  level;
        uint32                                  wake_lv;
        uint32                                  formation_lv;
        uint32                                  speed_lv;
    };

	typedef std::map<uint32, SData*> UInt32TotemExtMap;

	CTotemExtData();
	virtual ~CTotemExtData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TotemExtMap id_totemext_map;
	void Add(SData* totemext);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOTEMEXTMGR_H_
