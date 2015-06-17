#ifndef IMMORTAL_COMMON_RESOURCE_R_EFFECTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_EFFECTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CEffectData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  mode;
        uint32                                  local_id;
        std::string                             desc;
        uint32                                  PercenValue;
        uint32                                  icon;
    };

	typedef std::map<uint32, SData*> UInt32EffectMap;

	CEffectData();
	virtual ~CEffectData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32EffectMap id_effect_map;
	void Add(SData* effect);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_EFFECTMGR_H_
