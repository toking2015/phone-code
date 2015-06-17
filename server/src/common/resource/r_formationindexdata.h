#ifndef IMMORTAL_COMMON_RESOURCE_R_FORMATIONINDEXDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_FORMATIONINDEXDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CFormationIndexData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  index;
        uint32                                  level;
    };

	typedef std::map<uint32, SData*> UInt32FormationIndexMap;

	CFormationIndexData();
	virtual ~CFormationIndexData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 index );
protected:
	UInt32FormationIndexMap id_formationindex_map;
	void Add(SData* formationindex);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_FORMATIONINDEXMGR_H_
