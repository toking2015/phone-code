#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENATOTEMDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENATOTEMDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSingleArenaTotemData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  rank;
        uint32                                  count;
    };

	typedef std::map<uint32, SData*> UInt32SingleArenaTotemMap;

	CSingleArenaTotemData();
	virtual ~CSingleArenaTotemData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SingleArenaTotemMap id_singlearenatotem_map;
	void Add(SData* singlearenatotem);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SINGLEARENATOTEMMGR_H_
