#ifndef IMMORTAL_COMMON_RESOURCE_R_RANKCOPYDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_RANKCOPYDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CRankCopyData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  rank;
        uint32                                  cyc;
        uint32                                  delay;
        std::string                             time;
    };

	typedef std::map<uint32, SData*> UInt32RankCopyMap;

	CRankCopyData();
	virtual ~CRankCopyData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 rank );
protected:
	UInt32RankCopyMap id_rankcopy_map;
	void Add(SData* rankcopy);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_RANKCOPYMGR_H_
