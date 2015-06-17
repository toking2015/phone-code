#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTotemGlyphData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        uint32                                  type;
        uint32                                  quality;
        std::vector<S2UInt32>                   attrs;
    };

	typedef std::map<uint32, SData*> UInt32TotemGlyphMap;

	CTotemGlyphData();
	virtual ~CTotemGlyphData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TotemGlyphMap id_totemglyph_map;
	void Add(SData* totemglyph);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHMGR_H_
