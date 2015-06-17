#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_avatarext.h"

uint32 CAvatarExt::RandNum()
{
    uint32 min_count = 1;
    uint32  max_count = (uint32)id_avatar_map.size();

    if( max_count <= min_count )
        return min_count;

    uint32  rand_count = TRand( min_count, max_count );

    if( Find( rand_count ) )
        return rand_count;

    return min_count;
}

