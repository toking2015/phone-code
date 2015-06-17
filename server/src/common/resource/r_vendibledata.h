#ifndef IMMORTAL_COMMON_RESOURCE_R_VENDIBLEDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_VENDIBLEDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CVendibleData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        S3UInt32                                goods;
        uint32                                  item_id;
        uint32                                  count;
        uint32                                  shop_type;
        S3UInt32                                fake_price;
        S3UInt32                                price;
        uint32                                  history_limit_count;
        uint32                                  daily_limit_count;
        uint32                                  server_limit_count;
        uint32                                  win_times_limit;
    };

	typedef std::map<uint32, SData*> UInt32VendibleMap;

	CVendibleData();
	virtual ~CVendibleData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id );
protected:
	UInt32VendibleMap id_vendible_map;
	void Add(SData* vendible);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_VENDIBLEMGR_H_
