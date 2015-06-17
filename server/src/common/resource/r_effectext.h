#ifndef IMMORTAL_COMMON_RESOURCE_R_EFFECTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_EFFECTEXT_H_

#include "r_effectdata.h"
#include "proto/fight.h"

class CEffectExt : public CEffectData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32EffectMap::iterator iter = id_effect_map.begin();
            iter != id_effect_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
    uint32 GetValue( uint32 value, uint32 mode, uint32 base );
    SFightExtAble ToFightExtAble( uint32 id, SFightExtAble base, uint32 value );
    SFightExtAble AddFightExtAble( SFightExtAble first, SFightExtAble second );
    SFightExtAble SubFightExtAble( SFightExtAble first, SFightExtAble second );
};


#define theEffectExt TSignleton<CEffectExt>::Ref()
#endif
