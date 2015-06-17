#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHATTRDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHATTRDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTempleGlyphAttrData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        uint32                                  exp;
        std::vector<S2UInt32>                   attrs;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32TempleGlyphAttrMap;

	CTempleGlyphAttrData();
	virtual ~CTempleGlyphAttrData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 level );

protected:
	UInt32TempleGlyphAttrMap id_templeglyphattr_map;
	void Add(SData* templeglyphattr);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHATTRMGR_H_
