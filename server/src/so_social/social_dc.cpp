#include "social_dc.h"

void CSocialDC::init_data( std::vector< SSocialRole >& list )
{
    for ( std::vector< SSocialRole >::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
        db().user_map[ iter->role_id ] = *iter;
    }
}
