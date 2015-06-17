#include "proto/copy.h"
#include "netsingle.h"
#include "user_dc.h"
#include "local.h"
#include "log.h"
#include "copy_imp.h"
#include "copy_dc.h"
#include "pro.h"

MSG_FUNC( PQCopyOpen )
{
    QU_ON( user, msg.role_id );

    PRCopyOpen rep;
    bccopy( rep, user->ext );

    rep.result = copy::open( user/*, msg.copy_id*/ );
    rep.data.size = CompressData( user->data.copy, rep.data.data );

    local::write( local::access, rep );
}

MSG_FUNC( PQCopyClose )
{
    QU_ON( user, msg.role_id );

    PRCopyClose rep;
    bccopy( rep, user->ext );

    rep.result = copy::close( user );

    if ( rep.result == 0 )
    {
        copy::reply_copy_data( user );
        copy::reply_copy_log_list( user );
    }

    local::write( local::access, rep );
}

MSG_FUNC( PQCopyCommitEvent )
{
    QU_ON( user, msg.role_id );

    uint32 result = 0;

    do
    {
        if ( msg.posi != user->data.copy.posi || msg.index != user->data.copy.index )
        {
            //整合协议完成之前的所有非战斗事件
            result = copy::commit_event_to( user, msg.posi, msg.index );
            if ( result != 0 )
                break;
        }

        result = copy::commit_event_normal( user, msg.posi, msg.index );
    }
    while(0);

    PRCopyCommitEvent rep;
    bccopy( rep, msg );

    rep.result = result;
    rep.posi = msg.posi;
    rep.index = msg.index;

    local::write( local::access, rep );
}

MSG_FUNC( PQCopyCommitEventFight )
{
    QU_ON( user, msg.role_id );

    uint32 result = 0;

    do
    {
        if ( msg.posi != user->data.copy.posi || msg.index != user->data.copy.index )
        {
            //整合协议完成之前的所有非战斗事件
            result = copy::commit_event_to( user, msg.posi, msg.index );
            if ( result != 0 )
                break;
        }

        result = copy::commit_event_fight( user, msg.posi, msg.index, msg.fight_id, msg.order_list, msg.fight_info_list );
    }
    while(0);

    PRCopyCommitEventFight rep;
    bccopy( rep, msg );

    rep.result = result;
    rep.posi = msg.posi;
    rep.index = msg.index;

    //如果不是战斗失败, 不需要返回战斗相关记录(浪费带宽)
    if ( result == kErrFightFailure )
    {
        rep.order_list = msg.order_list;
        rep.fight_info_list = msg.fight_info_list;
    }

    local::write( local::access, rep );
}

MSG_FUNC( PQCopyRefurbish )
{
    QU_ON( user, msg.role_id );

    copy::refurbish( user );

    PRCopyRefurbish rep;
    bccopy( rep, msg );

    rep.data.size = CompressData( user->data.copy, rep.data.data );

    local::write( local::access, rep );
}

MSG_FUNC( PQCopyLogList )
{
    QU_ON( user, msg.role_id );

    copy::reply_copy_log_list( user );
}

MSG_FUNC( PQCopyBossFight )
{
    QU_ON( user, msg.role_id );

    uint32 result = copy::boss_fight( user, msg.mopup_type, msg.boss_id );
    if ( result != 0 )
    {
        HandleErrCode( user, result, 0 );
        return;
    }
}

MSG_FUNC( PQCopyBossFightCommit )
{
    QU_ON( user, msg.role_id );

    uint32 result = copy::boss_fight_commit( user, msg.fight_id, msg.order_list, msg.fight_info_list );
    if ( result != 0 )
    {
        HandleErrCode( user, result, 0 );
        return;
    }
}

MSG_FUNC( PQCopyAreaPresentTake )
{
    QU_ON( user, msg.role_id );

    uint32 result = copy::area_present_take( user, msg.area_id, msg.mopup_type, msg.area_attr );
    if ( result != 0 )
    {
        HandleErrCode( user, result, 0 );
        return;
    }

    PRCopyAreaPresentTake rep;
    bccopy( rep, msg );

    rep.mopup_type  = msg.mopup_type;
    rep.area_id     = msg.area_id;
    rep.area_attr   = msg.area_attr;

    local::write( local::access, rep );
}

MSG_FUNC( PQCopyBossMopup )
{
    QU_ON( user, msg.role_id );

    uint32 result = copy::boss_mopup( user, msg.mopup_type, msg.boss_id, msg.count );
    if ( result != 0 )
    {
        HandleErrCode( user, result, 0 );
        return;
    }
}

MSG_FUNC( PQCopyMopupReset )
{
    QU_ON( user, msg.role_id );

    uint32 result = copy::mopup_reset( user, msg.mopup_type, msg.boss_id );
    if ( result != 0 )
    {
        HandleErrCode( user, result, 0 );
        return;
    }
}

MSG_FUNC( PQCopyFightLogLoad )
{
    QU_ON( user, msg.role_id );
    PRCopyFightLogLoad rep;
    rep.copy_id = msg.copy_id;
    bccopy( rep, user->ext );
    theCopyDC.get_copyfight_log( msg.copy_id, rep.list );
    local::write( local::access, rep );
}

MSG_FUNC( PRCopyFightLog )
{
    if ( key != local::realdb )
        return;

    theCopyDC.set_copyfight_log( msg.fightlog_list);
}
