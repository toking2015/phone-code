#include "misc.h"
#include "var_imp.h"
#include "proto/var.h"
#include "proto/constant.h"
#include "user_dc.h"
#include "local.h"
#include "resource/r_varext.h"

MSG_FUNC( PQVarMap )
{
    QU_ON( user, msg.role_id );

    PRVarMap rep;
    bccopy( rep, msg );

    rep.var_map = user->data.var_map;

    local::write( local::access, rep );
}

MSG_FUNC( PQVarSet )
{
    QU_ON( user, msg.role_id );

    CVarData::SData* pData = theVarExt.Find( msg.var_key );
    if ( pData == NULL || state_not( pData->flag, kVarFlagClientModifity ) )
        return;

    switch ( msg.set_type )
    {
    case kObjectUpdate:
        var::set( user, msg.var_key, msg.var_value, msg.timelimit );
        break;
    case kObjectDel:
        var::del( user, msg.var_key );
        break;
    }
}

