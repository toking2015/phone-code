#include "system_dc.h"

CSystemDC::CSystemDC() : TDC< CSystem >( "system" )
{
}

uint32 CSystemDC::create( uint32 role_id )
{
    uint32 session = 0;

    while( session == 0 )
        session = random() & 0x7FFFFFFF;

    db().sessions[ role_id ] = session;

    return session;
}

uint32 CSystemDC::get_session( uint32 role_id )
{
    std::map< uint32, uint32 >::iterator iter = db().sessions.find( role_id );

    if ( iter != db().sessions.end() )
        return iter->second;

    return 0;
}

