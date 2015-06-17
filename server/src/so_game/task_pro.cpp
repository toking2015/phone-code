#include "pro.h"
#include "local.h"
#include "task_imp.h"
#include "user_imp.h"
#include "user_dc.h"

MSG_FUNC( PQTaskList )
{
    QU_ON( user, msg.role_id );

    PRTaskList rep;
    bccopy( rep, msg );

    rep.list = user->data.task_map;

    local::write( local::access, rep );
}

MSG_FUNC( PQTaskLogList )
{
    QU_ON( user, msg.role_id );

    PRTaskLogList rep;
    bccopy( rep, msg );

    rep.list = user->data.task_log_map;

    local::write( local::access, rep );
}

MSG_FUNC( PQTaskAccept )
{
    QU_ON( user, msg.role_id );

    uint32 result = task::task_accept( user, msg.task_id );
    if ( result != 0 )
    {
        HandleErrCode( user, result, msg.task_id );
        return;
    }
}

MSG_FUNC( PQTaskFinish )
{
    QU_ON( user, msg.role_id );

    int32 result = task::task_finish( user, msg.task_id, false );
    if ( result != 0 )
    {
        HandleErrCode( user, result, msg.task_id );
        return;
    }
}

MSG_FUNC( PQTaskAutoFinish )
{
    QU_ON( user, msg.role_id );

    int32 result = task::task_finish( user, msg.task_id, true );
    if ( result != 0 )
    {
        HandleErrCode( user, result, msg.task_id );
        return;
    }
}

MSG_FUNC( PQTaskSet )
{
    QU_ON( user, msg.role_id );

    SUserTask data;
    data.task_id    = msg.task_id;
    data.cond       = msg.cond;

    int32 result = task::task_set( user, data );
    if ( result != 0 )
    {
        HandleErrCode( user, result, msg.task_id );
        return;
    }
}

MSG_FUNC( PQTaskDayValReward )
{
    QU_ON( user, msg.role_id );
    uint32 err = task::day_val_reward(user, msg.id);
    PRTaskDayValReward rep;
    rep.id = msg.id;
    rep.err = err;
    bccopy(rep, msg);
    local::write(local::access, rep);
}
