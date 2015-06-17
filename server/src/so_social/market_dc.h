#ifndef _GAMESVR_MARKET_DC_H_
#define _GAMESVR_MARKET_DC_H_

#include "dc.h"
#include "proto/market.h"
#include "resource/r_marketext.h"

class CMarketDC : public TDC< CMarket >
{
public:
    CMarketDC();

    uint32 alloc_id(void);

    void init_data( std::vector< SMarketSellCargo >& list );
    void down_data();
};
#define theMarketDC TSignleton< CMarketDC >::Ref()
#define TIMETOMIN(n) ((n/100+1)*100)

#endif

