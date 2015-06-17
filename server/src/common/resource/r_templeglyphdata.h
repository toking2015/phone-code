#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTempleGlyphData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::string                             name;
        uint32                                  type;
        uint32                                  quality;
        uint32                                  init_lv;
        uint32                                  exp;
        std::string                             icon;
        std::string                             icon2;
    };

	typedef std::map<uint32, SData*> UInt32TempleGlyphMap;

	CTempleGlyphData();
	virtual ~CTempleGlyphData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TempleGlyphMap id_templeglyph_map;
	void Add(SData* templeglyph);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHMGR_H_
