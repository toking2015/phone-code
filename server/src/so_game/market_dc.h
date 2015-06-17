#ifndef _GAMESVR_MARKET_DC_H_
#define _GAMESVR_MARKET_DC_H_

#include "dc.h"
#include "proto/market.h"
#include "resource/r_marketext.h"

class CMarketDC : public TDC< CMarket >
{
public:
    CMarketDC() : TDC< CMarket >( "market" )
    {
    }
};
#define theMarketDC TSignleton< CMarketDC >::Ref()

#endif

