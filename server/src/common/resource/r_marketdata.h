#ifndef IMMORTAL_COMMON_RESOURCE_R_MARKETDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_MARKETDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CMarketData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  item_id;
        uint32                                  type;
        uint32                                  level;
        uint32                                  group;
        uint32                                  value;
    };

	typedef std::map<uint32, SData*> UInt32MarketMap;

	CMarketData();
	virtual ~CMarketData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 item_id );
protected:
	UInt32MarketMap id_market_map;
	void Add(SData* market);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_MARKETMGR_H_
