#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_globalext.h"

bool CGlobalExt::HasEspecial( std::string& text )
{
    std::string especial_filter = theGlobalExt.get<std::string>( "especial_filter" );

    for ( uint32 i = 0; i < text.length(); ++i )
    {
        int32 index = especial_filter.find_first_of( text[i] );
        if ( index >= 0 )
            return true;
    }

    return false;
}
