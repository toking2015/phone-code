#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYMATERIALDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYMATERIALDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CCopyMaterialData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  collect_level;
        uint32                                  active_score;
        std::vector<uint32>                     materials;
        uint32                                  min_num;
        uint32                                  max_num;
    };

	typedef std::map<uint32, SData*> UInt32CopyMaterialMap;

	CCopyMaterialData();
	virtual ~CCopyMaterialData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 collect_level );
protected:
	UInt32CopyMaterialMap id_copymaterial_map;
	void Add(SData* copymaterial);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_COPYMATERIALMGR_H_
