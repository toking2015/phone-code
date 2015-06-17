#include "user_imp.h"
#include "soldier_imp.h"
#include "misc.h"
#include "local.h"
#include "netsingle.h"
#include "proto/user.h"
#include "proto/constant.h"
#include "pro.h"
#include "item_imp.h"
#include "building_imp.h"
#include "resource/r_levelext.h"
#include "log.h"
#include "user_event.h"
#include "server.h"

/*****************BEGIN-Functor********************/
namespace user
{

bool is_online( SUser* user )
{
    //3 分钟没有操作记录视为 offline
    return ( server::local_time() < user->ext.operate_time + 3 * 60 );
}

bool TryLock( SUser* user )
{
    uint32 time_now = (uint32)server::local_time();
    if ( user->data.protect.lock_time >= time_now )
        return false;

    return true;
}

bool Lock( SUser* user, uint32 seconds )
{
    uint32 time_now = (uint32)server::local_time();
    if ( user->data.protect.lock_time >= time_now )
        return false;

    user->data.protect.lock_time = time_now + seconds;
    return true;
}

void Unlock( SUser* user )
{
    user->data.protect.lock_time = 0;
}

void SetFightId( SUser *puser, uint32 id )
{
    puser->ext.fight_id = id;
}

void DelFightId( SUser *puser )
{
    puser->ext.fight_id = 0;
}

uint32 GetFightId( SUser *puser )
{
    return puser->ext.fight_id;
}

void ReplyUserSimple( SUser *puser, SUser *ptarget )
{
    PRUserSimple rep;
    bccopy( rep, puser->ext );

    rep.target_id = ptarget->guid;
    rep.data = ptarget->data.simple;

    local::write(local::access, rep);
}

void ReplyUserOther( SUser *puser )
{
    PRUserOther rep;
    bccopy( rep, puser->ext );

    rep.other = puser->data.other;

    local::write(local::access, rep);
}

void reply_data( SUser* user )
{
    PRUserData rep;
    bccopy( rep, user->ext );

    rep.data.size = CompressData( user->data, rep.data.data );

    local::write( local::access, rep );
}

}// namespace user

