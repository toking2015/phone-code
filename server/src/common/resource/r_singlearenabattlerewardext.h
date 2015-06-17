#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENABATTLEREWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENABATTLEREWARDEXT_H_

#include "r_singlearenabattlerewarddata.h"

class CSingleArenaBattleRewardExt : public CSingleArenaBattleRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SingleArenaBattleRewardMap::iterator iter = id_singlearenabattlereward_map.begin();
            iter != id_singlearenabattlereward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
public:
    uint32 GetReward( uint32 first, uint32 second );
};

#define theSingleArenaBattleRewardExt TSignleton<CSingleArenaBattleRewardExt>::Ref()
#endif
