#ifndef IMMORTAL_COMMON_RESOURCE_R_MYSTERYSHOPEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_MYSTERYSHOPEXT_H_

#include "r_mysteryshopdata.h"

class CMysteryShopExt : public CMysteryShopData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32MysteryShopMap::iterator iter = id_mysteryshop_map.begin();
            iter != id_mysteryshop_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    std::vector<uint16> GetGoodsList(uint32 level, uint32 count);
};

#define theMysteryShopExt TSignleton<CMysteryShopExt>::Ref()
#endif
