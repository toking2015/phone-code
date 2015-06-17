#include "auth_dc.h"

CAuthDC::CAuthDC() : TDC< CAuth >( "auth" )
{
}

void CAuthDC::online( uint32 rid )
{
    db().online_data[ rid ] += 60;
}

