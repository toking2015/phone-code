#ifndef IMMORTAL_COMMON_RESOURCE_R_AVATAREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_AVATAREXT_H_

#include "r_avatardata.h"

class CAvatarExt : public CAvatarData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32AvatarMap::iterator iter = id_avatar_map.begin();
            iter != id_avatar_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

public:
    uint32  RandNum();
};

#define theAvatarExt TSignleton<CAvatarExt>::Ref()
#endif
