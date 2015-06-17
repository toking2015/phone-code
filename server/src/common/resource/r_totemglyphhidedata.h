#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHHIDEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHHIDEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTotemGlyphHideData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        S2UInt32                                attr;
    };

	typedef std::map<uint32, SData*> UInt32TotemGlyphHideMap;

	CTotemGlyphHideData();
	virtual ~CTotemGlyphHideData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TotemGlyphHideMap id_totemglyphhide_map;
	void Add(SData* totemglyphhide);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHHIDEMGR_H_
