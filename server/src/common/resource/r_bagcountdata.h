#ifndef IMMORTAL_COMMON_RESOURCE_R_BAGCOUNTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_BAGCOUNTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CBagCountData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  bag_type;
        uint32                                  bag_init;
    };

	typedef std::map<uint32, SData*> UInt32BagCountMap;

	CBagCountData();
	virtual ~CBagCountData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 bag_type );
protected:
	UInt32BagCountMap id_bagcount_map;
	void Add(SData* bagcount);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_BAGCOUNTMGR_H_
