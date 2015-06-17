#include "task_imp.h"
#include "var_imp.h"
#include "coin_imp.h"
#include "server.h"
#include "user_imp.h"
#include "copy_imp.h"
#include "proto/task.h"
#include "proto/constant.h"
#include "proto/item.h"
#include "resource/r_daytaskvalrewardext.h"
#include "local.h"
#include "dc.h"
#include "misc.h"
#include "task_event.h"
#include "activity_imp.h"

namespace task
{

uint32 task_accept_check( SUser* user, uint32 task_id )
{
    if ( task_id <= 0 )
        return kErrTaskNotExist;

    CTaskData::SData* task = theTaskExt.Find( task_id );
    if ( task == NULL )
        return kErrTaskNotExist;

    //检查等级限制
    if ( user->data.simple.team_level < task->team_level_min || user->data.simple.team_level > task->team_level_max )
        return kErrTaskLevelLimit;

    //检查已存在任务
    if ( dc::map_has_key( user->data.task_map, task->task_id ) )
        return kErrTaskExist;

    //前置任务检查
    if ( task->front_id != 0 && !dc::map_has_key( user->data.task_log_map, task->front_id ) )
        return kErrTaskFrontLog;

    //前置副本检查
    if ( task->copy_id != 0 && copy::get_copy_log( user, task->copy_id ).time == 0 )
        return kErrTaskFrontCopy;

    //重复任务检查
    if ( dc::map_has_key( user->data.task_log_map, task->task_id ) )
        return kErrTaskLogExist;

    switch ( task->type )
    {
    case kTaskTypeDayRepeat:
        {
            if ( user->data.task_day_map.find( task_id ) != user->data.task_day_map.end() )
                return kErrTaskExist;
        }
        break;
    case kTaskTypeActivity:
        {
            if ( !activity::IsActivityOpen( user, task->activity ) )
                return kErrTaskActivityClose;
        }
        break;
    }

    return 0;
}

uint32 task_accept( SUser* user, uint32 task_id )
{
    if ( task_id <= 0 )
        return kErrTaskNotExist;

    int32 result = task_accept_check( user, task_id );
    if ( result != 0 )
        return result;

    CTaskData::SData* task = theTaskExt.Find( task_id );
    if ( task == NULL )
        return kErrTaskNotExist;

    switch ( task->type )
    {
    case kTaskTypeDayRepeat:
        {
            SUserTaskDay& task_day  = user->data.task_day_map[ task_id ];
            task_day.task_id        = task_id;
            task_day.create_time    = server::local_time();

            reply_task_day( user, task_day );
        }
        break;
    }

    //增加新任务数据
    SUserTask& data = user->data.task_map[ task->task_id ];
    data.task_id       = task->task_id;
    data.create_time   = server::local_time();

    reply_task_set( user, kObjectAdd, data );

    //回调任务事件
    event::dispatch( SEventTaskAccept( user, kPathTaskAccept, task_id, task, data ) );

    return 0;
}

uint32 task_finish_check( SUser* user, uint32 task_id )
{
    if ( task_id <= 0 )
        return kErrTaskNotExist;

    CTaskData::SData* task = theTaskExt.Find( task_id );
    if ( task == NULL )
        return kErrTaskNotExist;

    std::map< uint32, SUserTask >::iterator iter = user->data.task_map.find( task->task_id );
    if ( iter == user->data.task_map.end() )
        return kErrTaskNotExist;

    switch ( task->cond.cate )
    {
    case kTaskCondTime:
        {
            struct tm __tm = {0};
            time_t _t_time = server::local_time();

            localtime_r( &_t_time, &__tm );

            if ( __tm.tm_hour >= (int32)task->cond.objid && __tm.tm_hour <= (int32)task->cond.val )
            {
                break;
            }

            return kErrTaskCondUnfinished;
        }
        break;
    default:
        {
            SUserTask& data = iter->second;
            if ( data.cond < task->cond.val )
                return kErrTaskCondUnfinished;
        }
        break;
    }

    return 0;
}
uint32 task_finish( SUser* user, uint32 task_id, bool auto_finish, bool debug )
{
    if ( task_id <= 0 )
        return kErrTaskNotExist;

    if ( !debug )
    {
        int32 result = task_finish_check( user, task_id );

        if ( result != 0 )
            return result;
    }

    CTaskData::SData* task = theTaskExt.Find( task_id );
    if ( task == NULL )
        return kErrTaskNotExist;

    //任务数据
    SUserTask task_data;
    {
        std::map< uint32, SUserTask >::iterator iter = user->data.task_map.find( task->task_id );
        task_data = iter->second;

        //移除用户数据
        user->data.task_map.erase( iter );
    }

    //增加任务奖励
    uint32 path = kPathTaskFinished;
    if ( auto_finish )
        path = kPathTaskAutoFinished;
    coin::give( user, task->coins, path, kCoinFlagOverflow );

    //先返回数据删除协议, 因为 iter->second 会在后面移除数据
    reply_task_set( user, kObjectDel, task_data );

    switch ( task->type )
    {
    case kTaskTypeDayRepeat:
        {
            //日常任务记录
            SUserTaskDay& task_day  = user->data.task_day_map[ task->task_id ];
            task_day.task_id        = task->task_id;
            task_day.finish_time    = server::local_time();

            //返回数据到用户
            reply_task_day( user, task_day );
        }
        break;
    default:
        {
            //任务完成记录
            SUserTaskLog& task_log  = user->data.task_log_map[ task->task_id ];
            task_log.task_id        = task_data.task_id;
            task_log.create_time    = task_data.create_time;
            task_log.finish_time    = server::local_time();

            //返回数据到用户
            reply_task_log( user, task_log );
        }
        break;
    }

    //回调任务事件
    event::dispatch( SEventTaskFinished( user, kPathTaskFinished, task_id, task ) );

    return 0;
}

uint32 task_set_check( SUser* user, uint32 task_id )
{
    if ( task_id <= 0 )
        return kErrTaskNotExist;

    CTaskData::SData* task = theTaskExt.Find( task_id );
    if ( task == NULL )
        return kErrTaskNotExist;

    std::map< uint32, SUserTask >::iterator iter = user->data.task_map.find( task->task_id );
    if ( iter == user->data.task_map.end() )
        return kErrTaskNotExist;

    switch ( task->cond.cate )
    {
        /*
           剧情统一由服务器完成
    case kTaskCondGut:
        break;
        */

        //微信分享由客户端提交完成条件
    case kTaskCondWeiXinShared:
        break;
    default:
        return kErrTaskCondReject;
    }

    return 0;
}
uint32 task_set( SUser* user, SUserTask& data )
{
    CTaskData::SData* task = theTaskExt.Find( data.task_id );
    if ( task == NULL )
        return kErrTaskNotExist;

    uint32 result = task_set_check( user, data.task_id );
    if ( result != 0 )
        return result;

    SUserTask& task_data = user->data.task_map[ task->task_id ];
    task_data.cond = data.cond;

    reply_task_set( user, kObjectUpdate, task_data );

    return 0;
}

struct task_match_safe_each
{
    SUser* user;
    task_match_safe_each( SUser* u ) : user(u){}

    void operator()( CTaskData::SData* task )
    {
        //活动任务不作自动匹配
        if ( task->type == kTaskTypeActivity )
            return;

        //task_accept 内部包含 task_accept_check
        task_accept( user, task->task_id );
    }
};
void match( SUser* user )
{
    //只匹朽用户等级可接受的任务列表
    std::vector< CTaskData::SData* >& list = theTaskExt.FindLevel( user->data.simple.team_level );

    //安全循环处理
    dc::safe_each( list, task_match_safe_each( user ) );
}

void add_cond_value( SUser* user, S3UInt32 coin, SUserTask& user_task )
{
    CTaskData::SData* task = theTaskExt.Find( user_task.task_id );
    if ( task == NULL )
        return;

    //任务完成条件类型判断
    if ( task->cond.cate != coin.cate || task->cond.objid != coin.objid )
        return;

    //击杀怪物数值修改
    uint32 value = user_task.cond + coin.val;
    if ( value > task->cond.val )
        value = task->cond.val;

    //数值不用修改
    if ( value == user_task.cond )
        return;

    user_task.cond = value;

    task::reply_task_set( user, kObjectUpdate, user_task );
}
void add_cond_value( SUser* user, S3UInt32 coin )
{
    for ( std::map< uint32, SUserTask >::iterator i = user->data.task_map.begin();
        i != user->data.task_map.end();
        ++i )
    {
        SUserTask& user_task = i->second;

        add_cond_value( user, coin, user_task );
    }
}

void max_cond_value( SUser* user, S3UInt32 coin, SUserTask& user_task )
{
    CTaskData::SData* task = theTaskExt.Find( user_task.task_id );
    if ( task == NULL )
        return;

    //任务完成条件类型判断
    if ( task->cond.cate != coin.cate || task->cond.objid != coin.objid )
        return;

    //击杀怪物数值修改
    uint32 value = std::max( user_task.cond, coin.val );
    if ( value > task->cond.val )
        value = task->cond.val;

    //数值不用修改
    if ( value == user_task.cond )
        return;

    user_task.cond = value;

    task::reply_task_set( user, kObjectUpdate, user_task );
}
void max_cond_value( SUser* user, S3UInt32 coin )
{
    for ( std::map< uint32, SUserTask >::iterator i = user->data.task_map.begin();
        i != user->data.task_map.end();
        ++i )
    {
        SUserTask& user_task = i->second;

        max_cond_value( user, coin, user_task );
    }
}

void reply_task_set( SUser* user, uint8 set_type, SUserTask& data )
{
    PRTaskSet rep;
    bccopy( rep, user->ext );

    rep.set_type = set_type;
    rep.data = data;

    local::write( local::access, rep );
}

void reply_task_log( SUser* user, SUserTaskLog& data )
{
    PRTaskLog rep;
    bccopy( rep, user->ext );

    rep.data = data;

    local::write( local::access, rep );
}

void reply_task_day( SUser* user, SUserTaskDay& data )
{
    PRTaskDay rep;
    bccopy( rep, user->ext );

    rep.data = data;

    local::write( local::access, rep );
}

void reply_task_day_list( SUser* user )
{
    PRTaskDayList rep;
    bccopy( rep, user->ext );

    rep.data = user->data.task_day_map;

    local::write( local::access, rep );
}

uint32 day_val_reward(SUser *user, uint32 id)
{
    CDayTaskValRewardData::SData *p_data = theDayTaskValRewardExt.Find(id);
    if (!p_data)
        return kErrTaskDayRewardNotExist;
    S3UInt32 cost = coin::create(kCoinDayTaskVal, 0, p_data->need_val);
    if (coin::check_take(user, cost) != 0)
        return kErrTaskDayRewardNotEnough;

    uint32 ret = coin::check_give(user, p_data->reward);
    if (ret > 0)
        return kErrItemSpaceFull;

    std::vector<uint32>::iterator iter = std::find(user->data.day_task_reward_list.begin(), user->data.day_task_reward_list.end(), id);
    if (iter != user->data.day_task_reward_list.end())
        return kErrTaskDayRewardAlreadyGot;

    coin::give(user, p_data->reward, kPathDayTaskValReward);
    user->data.day_task_reward_list.push_back(id);
    return 0;
}

void ReplyDayTaskValRewardList(SUser *user)
{
    PRTaskDayValRewardList rep;
    rep.id_list = user->data.day_task_reward_list;
    bccopy(rep, user->ext);
    local::write( local::access, rep );
}

} // namespace task

