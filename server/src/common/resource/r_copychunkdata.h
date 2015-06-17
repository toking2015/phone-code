#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYCHUNKDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYCHUNKDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CCopyChunkData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        std::vector<S3UInt32>                   event;
    };

	typedef std::map<uint32, SData*> UInt32CopyChunkMap;

	CCopyChunkData();
	virtual ~CCopyChunkData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32CopyChunkMap id_copychunk_map;
	void Add(SData* copychunk);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_COPYCHUNKMGR_H_
