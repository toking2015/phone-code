#ifndef IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDEXT_H_

#include "r_tombrewarddata.h"

class CTombRewardExt : public CTombRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TombRewardMap::iterator iter = id_tombreward_map.begin();
            iter != id_tombreward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
    std::vector<CTombRewardData::SData*> GetRandomList( uint32 quality, uint32 level);
};

#define theTombRewardExt TSignleton<CTombRewardExt>::Ref()
#endif
