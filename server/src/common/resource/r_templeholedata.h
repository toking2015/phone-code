#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEHOLEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEHOLEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CTempleHoleData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        std::vector<S3UInt32>                   cost_item;
        std::vector<S3UInt32>                   cost_coin;
    };

	typedef std::map<uint32, SData*> UInt32TempleHoleMap;

	CTempleHoleData();
	virtual ~CTempleHoleData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32TempleHoleMap id_templehole_map;
	void Add(SData* templehole);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_TEMPLEHOLEMGR_H_
