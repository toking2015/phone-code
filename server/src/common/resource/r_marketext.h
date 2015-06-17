#ifndef IMMORTAL_COMMON_RESOURCE_R_MARKETEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_MARKETEXT_H_

#include "r_marketdata.h"

class CMarketExt : public CMarketData
{
public:
    typedef std::map< uint32, std::vector< CMarketData::SData* > > TGroup;
    typedef std::map< uint32, TGroup > TLevel;
    typedef std::map< uint32, TLevel > TEquip;

private:
    TEquip indices;

public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32MarketMap::iterator iter = id_market_map.begin();
            iter != id_market_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    ~CMarketExt();

    TEquip& GetIndices(void);

    std::vector< CMarketData::SData* > find_custom( uint32 type, uint32 level, uint32 group );
};

#define theMarketExt TSignleton<CMarketExt>::Ref()
#endif
