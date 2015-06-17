#include "task_event.h"
#include "user_event.h"
#include "team_event.h"
#include "fight_event.h"
#include "copy_event.h"
#include "coin_event.h"
#include "gut_event.h"
#include "activity_event.h"
#include "altar_event.h"
#include "building_event.h"
#include "altar_event.h"
#include "singlearena_event.h"
#include "market_event.h"
#include "building_event.h"
#include "totem_event.h"
#include "trial_event.h"
#include "item_event.h"
#include "vip_event.h"
#include "pay_event.h"
#include "soldier_event.h"
#include "shop_event.h"
#include "tomb_event.h"
#include "chat_event.h"
#include "friend_event.h"
#include "task_imp.h"
#include "copy_imp.h"
#include "coin_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "dc.h"
#include "proto/constant.h"
#include "proto/coin.h"
#include "proto/soldier.h"
#include "proto/item.h"
#include "resource/r_monsterfightconfext.h"
#include "resource/r_monsterext.h"
#include "resource/r_levelext.h"
#include "resource/r_taskext.h"
#include "server.h"

EVENT_FUNC( task, SEventUserInit )
{
    //task::match( ev.user );
}

EVENT_FUNC( task, SEventTaskFinished )
{
    //task::match( ev.user );

    switch ( ev.task_id )
    {
    case 30001:
        {
            //扫荡券奖励
            CLevelData::SData* level = theLevelExt.Find( ev.user->data.simple.vip_level );
            if ( level == NULL )
                break;

            coin::give( ev.user, level->task_30001, ev.path );
        }
        break;

    case 30002:
        {
            //月卡奖励
            CLevelData::SData* level = theLevelExt.Find( ev.user->data.simple.vip_level );
            if ( level == NULL )
                break;

            coin::give( ev.user, level->task_30002, ev.path );
        }
        break;
    }
}

EVENT_FUNC( task, SEventTeamLevelUp )
{
    task::max_cond_value( ev.user, coin::create( kTaskCondTeamLevel, 0, ev.user->data.simple.team_level ) );

    //task::match( ev.user );
}

void task_data_update( SUser* user, CTaskData::SData* task, SUserTask& data )
{
    switch ( task->cond.cate )
    {
        //副本通关
    case kTaskCondCopyFinished:
        {
            SCopyLog copy_log = copy::get_copy_log( user, task->cond.objid );
            if ( copy_log.copy_id == 0 )
                break;

            task::add_cond_value( user, coin::create( kTaskCondCopyFinished, task->cond.objid, 1 ), data );
        }
        break;

        //扫荡券奖励
    case kTaskCondVipLevel:
        {
            task::max_cond_value( user, coin::create( kTaskCondVipLevel, 0, user->data.simple.vip_level ), data );
        }
        break;

        //月卡奖励
    case kTaskCondMonthCard:
        {
            uint32 time_now = server::local_time();
            uint32 day = 0;

            //月卡剩余天数计算
            if ( user->data.pay_info.month_time > time_now )
                day = 1 + ( user->data.pay_info.month_time - time_now ) / 86400;

            if ( day <= 0 )
                break;

            task::max_cond_value( user, coin::create( kTaskCondMonthCard, 0, day ), data );
        }
        break;

        //战队等级
    case kTaskCondTeamLevel:
        {
            task::max_cond_value( user, coin::create( kTaskCondTeamLevel, 0, user->data.simple.team_level ), data );
        }
        break;

    case kTaskCondSoldierCollect:
        {
            uint32 count = user->data.soldier_map[ kSoldierTypeCommon ].size();

            task::max_cond_value( user, coin::create( kTaskCondSoldierCollect, 0, count ), data );
        }
        break;

    case kTaskCondSoldierQuality:
        {
            uint32 count = soldier::GetSoldierCountByQuality( user, task->cond.objid );

            task::max_cond_value( user, coin::create( kTaskCondSoldierQuality, task->cond.objid, count ), data );
        }
        break;

    case kTaskCondTotemLevel:
        {
            uint32 count = totem::GetTotemLevelCount( user, task->cond.objid );

            task::max_cond_value( user, coin::create( kTaskCondTotemLevel, task->cond.objid, count ), data );
        }
        break;

    case kTaskCondBossKillId:
        {
            //精英副本击杀检查
            {
                std::map< uint32, uint32 >::iterator iter = user->data.mopup.elite_round.find( task->cond.objid );
                if ( iter != user->data.mopup.elite_round.end() && iter->second < 0xFF )
                {
                    task::max_cond_value( user, task->cond, data );
                    break;
                }
            }

            //普通副本击杀检查
            {
                std::map< uint32, uint32 >::iterator iter = user->data.mopup.normal_round.find( task->cond.objid );
                if ( iter != user->data.mopup.normal_round.end() && iter->second < 0xFF )
                {
                    task::max_cond_value( user, task->cond, data );
                    break;
                }
            }
        }
        break;

    case kTaskCondTotem:
        {
            S3UInt32 coin = coin::create( kCoinTotem, task->cond.objid, 1 );
            uint32 count = coin::count( user, coin );

            if ( count > 0 )
                task::max_cond_value( user, coin::create( kTaskCondTotem, task->cond.objid, 1 ) );
        }
        break;
    }

}
EVENT_FUNC( task, SEventTaskAccept )
{
    task_data_update( ev.user, ev.task, ev.data );
}
EVENT_FUNC( task, SEventUserLogined )
{
    for ( std::map< uint32, SUserTask >::iterator iter = ev.user->data.task_map.begin();
        iter != ev.user->data.task_map.end();
        ++iter )
    {
        CTaskData::SData* task = theTaskExt.Find( iter->second.task_id );
        if ( task == NULL )
            continue;

        task_data_update( ev.user, task, iter->second );
    }
}

//关联活动任务匹配接受
struct task_activity_open_each_accept
{
    SUser* user;
    std::string activity_name;

    task_activity_open_each_accept( SUser* u, std::string n ) : user(u), activity_name(n){}

    void operator()( CTaskData::SData* task )
    {
        if ( task->type != kTaskTypeActivity || task->activity != activity_name )
            return;

        //task_accept 内部包含 task_accept_check
        task::task_accept( user, task->task_id );
    }
};
EVENT_FUNC( task, SEventActivityUserOpen )
{
    std::vector< CTaskData::SData* >& list = theTaskExt.FindLevel( ev.user->data.simple.team_level );

    dc::safe_each( list, task_activity_open_each_accept( ev.user, ev.activity_name ) );
}

//关联活动任务放弃
struct task_activity_close_each_cancel
{
    SUser* user;
    std::string activity_name;

    task_activity_close_each_cancel( SUser* u, std::string n ) : user(u), activity_name(n){}

    void operator()( std::pair< const uint32, SUserTask >& pair )
    {
        CTaskData::SData* task = theTaskExt.Find( pair.first );
        if ( task == NULL )
            return;

        if ( task->activity != activity_name )
            return;

        //返回客户端任务删除
        task::reply_task_set( user, kObjectDel, pair.second );

        //移除用户数据
        user->data.task_map.erase( pair.first );
    }
};
EVENT_FUNC( task, SEventActivityUserClose )
{
    dc::safe_each( ev.user->data.task_map, task_activity_close_each_cancel( ev.user, ev.activity_name ) );
}

EVENT_FUNC( task, SEventGutFinished )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondGut, ev.gut_id, 1 ) );
}

EVENT_FUNC( task, SEventFightKillMonster )
{
    if ( ev.user->data.task_map.empty() )
        return;

    task::add_cond_value( ev.user, coin::create( kTaskCondMonsterTeam, ev.monster_id, 1 ) );

    CMonsterFightConfData::SData* data = theMonsterFightConfExt.Find( ev.monster_id );
    if ( data == NULL )
        return;

    std::map< uint32, uint32 > map;
    for ( std::vector<S2UInt32>::iterator iter = data->add.begin();
        iter != data->add.end();
        ++iter )
    {
        uint32 monster_id = iter->first;

        CMonsterData::SData* monster = theMonsterExt.Find( monster_id );
        if ( monster == NULL )
            continue;

        uint32 class_id = monster->class_id;
        if ( class_id == 0 )
            continue;

        map[ class_id ]++;
    }

    for ( std::map< uint32, uint32 >::iterator iter = map.begin();
        iter != map.end();
        ++iter )
    {
        task::add_cond_value( ev.user, coin::create( kTaskCondMonster, iter->first, iter->second ) );
    }
}

EVENT_FUNC( task, SEventCopyFinished )
{
    task::max_cond_value( ev.user, coin::create( kTaskCondCopyFinished, ev.copy_id, 1 ) );
}

EVENT_FUNC( task, SEventCopyGroupFinished )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondCopyGroup, ev.gid, 1 ) );
}

EVENT_FUNC( task, SEventCoin )
{
    switch ( ev.set_type )
    {
        //增加货币
    case kObjectAdd:
        {
            switch ( ev.coin.cate )
            {
                //增加物品
            case kCoinItem:
                {
                    task::add_cond_value( ev.user, coin::create( kTaskCondItem, ev.coin.objid, ev.coin.val ) );
                }
                break;

            case kCoinSoldier:
                {
                    uint32 count = ev.user->data.soldier_map[ kSoldierTypeCommon ].size();

                    task::max_cond_value( ev.user, coin::create( kTaskCondSoldierCollect, 0, count ) );
                }
                break;

            case kCoinTotem:
                {
                    task::max_cond_value( ev.user, coin::create( kTaskCondTotem, ev.coin.objid, 1 ) );
                }
                break;
            } // switch ( ev.coin.cate )
        }
        break;
    } // switch ( ev.set_type )
}

EVENT_FUNC( task, SEventLotteryCard )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondLotteryCard, ev.type, ev.count ) );
    task::add_cond_value( ev.user, coin::create( kTaskCondLotteryCard, 0, ev.count ) );
}

EVENT_FUNC( task, SEventBuildingResourceTake )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondBuildingTake, ev.type, ev.value ) );
}

EVENT_FUNC( task, SEventUserTimeLimit )
{
    std::vector< uint32 > remove_list;

    for ( std::map< uint32, SUserTaskDay >::iterator iter = ev.user->data.task_day_map.begin();
        iter != ev.user->data.task_day_map.end();
        ++iter )
    {
        //需要移除已完成的日常任务
        if ( iter->second.finish_time != 0 )
            remove_list.push_back( iter->first );
    }

    for ( std::vector< uint32 >::iterator iter = remove_list.begin();
        iter != remove_list.end();
        ++iter )
    {
        ev.user->data.task_day_map.erase( *iter );
    }

    //返回数据列表
    task::reply_task_day_list( ev.user );

    {
        //日常活动积分重置
        S3UInt32 tmp = coin::create(kCoinDayTaskVal, 0, 0);
        uint32 left_val = coin::count(ev.user, tmp);
        if (left_val > 0)
        {
            tmp.val = left_val;
            coin::take(ev.user, tmp, kPathDayTaskValReset);
        }

        //日常活动领奖标识重置
        ev.user->data.day_task_reward_list.clear();
        task::ReplyDayTaskValRewardList(ev.user);
    }
}

EVENT_FUNC( task, SEventCopyBossKill )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondBossKillCount, ev.mopup_type, 1 ) );
    task::add_cond_value( ev.user, coin::create( kTaskCondBossKillId, ev.boss_id, 1 ) );
}

EVENT_FUNC( task, SEventSingleArenaBattle )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondSingleArenaBattle, 0, 1 ) );
}

EVENT_FUNC( task, SEventTrialFinished )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondTrialFinished, 0, 1 ) );
}

EVENT_FUNC( task, SEventItemMerge )
{
    if ( ev.path == kPathMergeEquip )
        task::add_cond_value( ev.user, coin::create( kTaskCondItemMerge, 0, 1 ) );
}

EVENT_FUNC( task, SEventMarketCargoUp )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondMarketCargoUp, 0, 1 ) );
}

EVENT_FUNC( task, SEventBuildingSpeedOutput )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondBuildingSpeed, ev.type, 1 ) );
}

EVENT_FUNC( task, SEventTotemGlyphMerge )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondTotemGlyphMerge, 0, 1 ) );
}

EVENT_FUNC( task, SEventVipLevelUp )
{
    task::max_cond_value( ev.user, coin::create( kTaskCondVipLevel, 0, ev.user->data.simple.vip_level ) );
}

EVENT_FUNC( task, SEventPayMonthCard )
{
    uint32 time_now = server::local_time();
    uint32 day = 0;

    //月卡剩余天数计算
    if ( ev.user->data.pay_info.month_time > time_now )
        day = 1 + ( ev.user->data.pay_info.month_time - time_now ) / 86400;

    if ( day <= 0 )
        return;

    task::max_cond_value( ev.user, coin::create( kTaskCondMonthCard, 0, day ) );
}

EVENT_FUNC( task, SEventTotemLevelUp )
{
    for ( std::map< uint32, SUserTask >::iterator iter = ev.user->data.task_map.begin();
        iter != ev.user->data.task_map.end();
        ++iter )
    {
        SUserTask& data = iter->second;
        CTaskData::SData* task = theTaskExt.Find( data.task_id );

        if ( task == NULL )
            continue;

        switch ( task->cond.cate )
        {
        case kTaskCondTotemLevel:
            {
                uint32 count = totem::GetTotemLevelCount( ev.user, task->cond.objid );

                task::max_cond_value( ev.user, coin::create( kTaskCondTotemLevel, task->cond.objid, count ), data );
            }
            break;
        }
    }
}

EVENT_FUNC( task, SEventTotemSkillLevelUp )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondTotemSkillLevelUp, 0, 1 ) );
}

EVENT_FUNC( task, SEventSoldierQualityUp )
{
    for ( std::map< uint32, SUserTask >::iterator iter = ev.user->data.task_map.begin();
        iter != ev.user->data.task_map.end();
        ++iter )
    {
        SUserTask& data = iter->second;
        CTaskData::SData* task = theTaskExt.Find( data.task_id );

        if ( task == NULL || task->cond.cate != kTaskCondSoldierQuality )
            continue;

        uint32 count = soldier::GetSoldierCountByQuality( ev.user, task->cond.objid );

        count = std::max( count, data.cond );
        if ( count > task->cond.val )
            count = task->cond.val;

        if ( count == data.cond )
            continue;

        data.cond = count;
        task::reply_task_set( ev.user, kObjectUpdate, data );
    }
}

EVENT_FUNC( task, SEventVendibleBuy )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondVendibleBuy, ev.vendible_id, ev.count ) );
}

EVENT_FUNC( task, SEventSoldierLvUp )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondSoldierLevelUp, 0, 1 ) );
}

EVENT_FUNC( task, SEventTombFight )
{
    for ( std::map< uint32, SUserTask >::iterator iter = ev.user->data.task_map.begin();
        iter != ev.user->data.task_map.end();
        ++iter )
    {
        SUserTask& data = iter->second;
        CTaskData::SData* task = theTaskExt.Find( data.task_id );

        if ( task == NULL || task->cond.cate != kTaskCondTomb )
            continue;

        if ( task->cond.objid != ev.index && task->cond.objid != 0 )
            continue;

        uint32 count = std::min( task->cond.val, data.cond + 1 );
        if ( count == data.cond )
            continue;

        data.cond = count;
        task::reply_task_set( ev.user, kObjectUpdate, data );
    }
}

EVENT_FUNC( task, SEventChat )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondChat, ev.broad_cast, 1 ) );
}

EVENT_FUNC( task, SEventFrdGiveActiveScore )
{
    task::add_cond_value( ev.user, coin::create( kTaskCondFriendGiveActiveScoreTimes, 0, 1 ) );
}

