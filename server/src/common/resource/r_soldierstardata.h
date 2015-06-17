#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERSTARDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERSTARDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CSoldierStarData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  lv;
        uint32                                  cost;
        S3UInt32                                need_money;
        uint32                                  grow;
    };

	typedef std::map<uint32, SData*> UInt32SoldierStarMap;

	CSoldierStarData();
	virtual ~CSoldierStarData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 lv );
protected:
	UInt32SoldierStarMap id_soldierstar_map;
	void Add(SData* soldierstar);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_SOLDIERSTARMGR_H_
