#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENASOLDIERDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENASOLDIERDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSingleArenaSoldierData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  rank;
        uint32                                  count;
    };

	typedef std::map<uint32, SData*> UInt32SingleArenaSoldierMap;

	CSingleArenaSoldierData();
	virtual ~CSingleArenaSoldierData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32SingleArenaSoldierMap id_singlearenasoldier_map;
	void Add(SData* singlearenasoldier);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SINGLEARENASOLDIERMGR_H_
