#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMOPENDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMOPENDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CItemOpenData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  open_id;
        uint32                                  reward;
        S2UInt32                                level_rand;
        uint32                                  percent;
        std::string                             desc;
    };

	typedef std::map<uint32, SData*> UInt32ItemOpenMap;

	CItemOpenData();
	virtual ~CItemOpenData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32ItemOpenMap id_itemopen_map;
	void Add(SData* itemopen);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_ITEMOPENMGR_H_
