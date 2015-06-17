#ifndef IMMORTAL_COMMON_RESOURCE_R_ACHIEVEMENTGOODSEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ACHIEVEMENTGOODSEXT_H_

#include "r_achievementgoodsdata.h"

class CAchievementGoodsExt : public CAchievementGoodsData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32AchievementGoodsMap::iterator iter = id_achievementgoods_map.begin();
            iter != id_achievementgoods_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theAchievementGoodsExt TSignleton<CAchievementGoodsExt>::Ref()
#endif
