#include "var_imp.h"
#include "proto/var.h"
#include "proto/constant.h"
#include "misc.h"
#include "local.h"
#include "resource/r_varext.h"
#include "server.h"
#include "log.h"

namespace var
{

uint32 get( SUser* user, std::string key )
{
    std::map< std::string, SUserVar >::iterator iter = user->data.var_map.find( key );
    if ( iter == user->data.var_map.end() )
        return 0;

    //有效期判断
    if ( iter->second.timelimit != 0 )
    {
        uint32 time_now = (uint32)server::local_time();
        if ( time_now >= iter->second.timelimit )
        {
            user->data.var_map.erase( iter );
            return 0;
        }
    }

    return iter->second.value;
}
void var_reply_set( SUser* user, uint8 set_type, std::string key, uint32 value, uint32 timelimit )
{
    PRVarSet rep;
    bccopy( rep, user->ext );

    rep.set_type = set_type;
    rep.var_key = key;
    rep.var_value = value;
    rep.timelimit = timelimit;

    local::write( local::access, rep );
}
void set( SUser* user, std::string key, uint32 value, uint32 timelimit )
{
    CVarData::SData* pData = theVarExt.Find( key );
    if ( pData == NULL )
        return;

    SUserVar& var = user->data.var_map[ key ];
    var.value = value;
    var.timelimit = timelimit;

    var_reply_set( user, kObjectUpdate, key, value, timelimit );
}

void del( SUser* user, std::string key )
{
    CVarData::SData* pData = theVarExt.Find( key );
    if ( pData == NULL )
        return;

    user->data.var_map.erase( key );

    var_reply_set( user, kObjectDel, key, 0, 0 );
}

void setOnActivity( SUser* user, std::string key, uint32 value, uint32 timelimit )
{
    SUserVar& var = user->data.var_map[ key ];
    var.value = value;
    var.timelimit = timelimit;

    var_reply_set( user, kObjectUpdate, key, value, timelimit );
}

void delOnActivity( SUser* user, std::string key )
{
    user->data.var_map.erase( key );

    var_reply_set( user, kObjectDel, key, 0, 0 );
}

}// namespace var

