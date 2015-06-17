#ifndef IMMORTAL_COMMON_RESOURCE_R_MYSTERYSHOPDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_MYSTERYSHOPDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CMysteryShopData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  min_level;
        uint32                                  max_level;
        uint32                                  rate;
    };

	typedef std::map<uint32, SData*> UInt32MysteryShopMap;

	CMysteryShopData();
	virtual ~CMysteryShopData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32MysteryShopMap id_mysteryshop_map;
	void Add(SData* mysteryshop);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_MYSTERYSHOPMGR_H_
