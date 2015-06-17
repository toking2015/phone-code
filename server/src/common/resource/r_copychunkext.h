#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYCHUNKEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYCHUNKEXT_H_

#include "r_copychunkdata.h"

class CCopyChunkExt : public CCopyChunkData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32CopyChunkMap::iterator iter = id_copychunk_map.begin();
            iter != id_copychunk_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    S3UInt32 Random( CCopyChunkData::SData* data );
};

#define theCopyChunkExt TSignleton<CCopyChunkExt>::Ref()
#endif
