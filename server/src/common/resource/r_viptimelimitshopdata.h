#ifndef IMMORTAL_COMMON_RESOURCE_R_VIPTIMELIMITSHOPDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_VIPTIMELIMITSHOPDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CVipTimeLimitShopData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  level;
        std::vector<S3UInt32>                   item;
        S3UInt32                                discount_price;
        S3UInt32                                real_price;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32VipTimeLimitShopMap;

	CVipTimeLimitShopData();
	virtual ~CVipTimeLimitShopData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 level );

protected:
	UInt32VipTimeLimitShopMap id_viptimelimitshop_map;
	void Add(SData* viptimelimitshop);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_VIPTIMELIMITSHOPMGR_H_
