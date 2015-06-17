#include "copy_imp.h"
#include "gut_imp.h"
#include "coin_imp.h"
#include "item_imp.h"
#include "proto/copy.h"
#include "proto/constant.h"
#include "misc.h"
#include "util.h"
#include "local.h"
#include "log.h"
#include "event.h"
#include "resource/r_copyext.h"
#include "resource/r_copychunkext.h"
#include "resource/r_packetext.h"
#include "resource/r_rewardext.h"
#include "resource/r_monsterext.h"
#include "resource/r_levelext.h"
#include "resource/r_areaext.h"
#include "user_imp.h"
#include "fight_dc.h"
#include "fight_imp.h"
#include "fightrecord_imp.h"
#include "fightextable_imp.h"
#include "monster_imp.h"
#include "copy_event.h"
#include "fight_event.h"
#include "var_imp.h"
#include "server.h"
#include "copy_dc.h"
#include "bias_imp.h"
#include "equip_imp.h"

namespace copy
{

uint32 trans_to_group( uint32 copy_id )
{
    return copy_id / 10;
}

uint32 trans_to_area( uint32 copy_id )
{
    return copy_id / 1000;
}

//根据阵亡次数计算获取星数
uint32 boss_fight_star( uint32 times )
{
    //阵亡0: 3星, 阵亡1: 2星, 其它: 1星
    uint32 star = 1;

    switch ( times )
    {
    case 0:
        star = 3;
        break;
    case 1:
        star = 2;
        break;
    case 255:
        star = 0;
        break;
    default:
        star = 1;
        break;
    }

    return star;
}

uint32 copy_event_extend( SUser* user, SUserCopy& data )
{
    //展开事件
    for ( int32 i = 0; i < (int32)data.chunk.size(); ++i )
    {
        S3UInt32& chunk = data.chunk[i];

        //替换随机事件
        if ( chunk.cate == kCopyEventTypeRandom )
        {
            CCopyChunkData::SData* copy_chunk = theCopyChunkExt.Find( chunk.objid );
            if ( copy_chunk == NULL )
            {
                LOG_ERROR( "copy_init: chunk.objid[%d] not found!", chunk.objid );
                continue;
            }

            chunk = theCopyChunkExt.Random( copy_chunk );
        }

        switch ( chunk.cate )
        {
        case kCopyEventTypeBox:
            {
                //展开宝箱
                chunk.val = bias::PacketRandomReward( user, chunk.objid );
            }
            break;

        case kCopyEventTypeFight:
        case kCopyEventTypeFightMeet:
            {
                /*
                   不展开战斗详细数据, 待 ref 请求再展开( 客户端在进入副本前一定会先发 ref 协议 )
                //展开战斗
                SFight* fight = fight::Interface( kFightTypeCopy )->AddFightToMonster( user, chunk.objid );
                if ( fight != NULL )
                {
                    data.fight[ fight->fight_id ] = *fight;
                    data.seed[ fight->fight_id ].value = TRand( 0, 0x7FFFFFFF );
                    chunk.val = fight->fight_id;
                }
                */

                //掉落记录
                data.coins[i] = monster::GetMonsterDrop( user, chunk.objid );
            }
            break;

        case kCopyEventTypeGut:
            {
                uint32 gut_id = chunk.objid;

                data.gut[ gut_id ] = gut::alloc( user, gut_id );
            }
            break;
        }
    }

    return 0;
}
uint32 copy_init( SUser* user, CCopyData::SData* copy, uint32& boss_id )
{
    //初始化数据
    user->data.copy = SUserCopy();
    SUserCopy& data = user->data.copy;

    data.copy_id    = copy->id;

    //获取探索数
    int32 chunk_count = (int32)theCopyExt.GetChunkCount( copy );
    if ( chunk_count > 0 )
    {
        //初始化探索块
        data.chunk.resize( chunk_count );
        data.reward.resize( chunk_count );

        //初始化索引标志位
        std::vector< int32 > indices( chunk_count );
        for ( int32 i = 0; i < chunk_count; ++i )
            indices[i] = i;

        //顺序插入
        for ( int32 i = 0; i < chunk_count; ++i )
        {
            //这个 index 从 1 开始
            uint32 index = copy->chunk[i].val;
            if ( index != 0 )
            {
                if ( index <= (uint32)chunk_count )
                {
                    if ( data.chunk[ index - 1 ].cate != 0 )
                        return kErrCopyChunkIndexExsit;

                    data.chunk[ index - 1 ] = copy->chunk[i];
                    if ( i < (int32)copy->reward.size() )
                    {
                        //需要体力进行探索
                        data.reward[ index - 1 ].cate   = 1;

                        //objid 为 rewardid, val 为 完成度
                        data.reward[ index - 1 ].objid  = copy->reward[i].first;
                        data.reward[ index - 1 ].val    = copy->reward[i].second;
                    }

                    //移除标志
                    std::vector< int32 >::iterator iter = std::find( indices.begin(), indices.end(), i );
                    if ( iter != indices.end() )
                        indices.erase( iter );
                }
            }
        }

        //乱序插入
        for ( int32 i = 0; i < chunk_count && !indices.empty(); ++i )
        {
            //未正确顺序插入的 chunk.cate 必然为 0
            if ( data.chunk[i].cate != 0 )
                continue;

            uint32 j = TRand( (uint32)0, (uint32)indices.size() );
            uint32 index = indices[ j ];

            data.chunk[i] = copy->chunk[ index ];
            if ( index < copy->reward.size() )
            {
                //需要体力进行探索
                data.reward[i].cate     = kTrue;

                //objid 为 rewardid, val 为 完成度
                data.reward[i].objid    = copy->reward[ index ].first;
                data.reward[i].val      = copy->reward[ index ].second;
            }

            indices.erase( indices.begin() + j );
        }
    }

    //BOSS 事件初始化
    do
    {
        S3UInt32 re;
        re.cate = 1;
        for ( int32 i = 0; i < (int32)copy->boss_chunk.size(); ++i )
        {
            //重置完成度
            re.val = copy->boss_chunk[i].val;

            data.chunk.push_back( copy->boss_chunk[i] );
            data.reward.push_back( re );

            //第二次boss_chunk后不需要体力
            re.cate = 0;

            //如果是boss战斗, 需要初始化 round 值
            if ( copy->type == kCopyTypeBoss )
            {
                switch ( copy->boss_chunk[i].cate )
                {
                case kCopyEventTypeFight:
                case kCopyEventTypeFightMeet:
                    {
                        if ( boss_id != 0 )
                            return kErrCopyBossExist;

                        boss_id = copy->boss_chunk[i].objid;
                    }
                    break;
                }
            }
        }

    }while(0);

    //重置掉落数据长度, data.chunk 可能会在 boss 事件初始化时增加长度
    data.coins.resize( data.chunk.size() );

    //服务器专用字段初始化
    for ( int32 i = 0; i < (int32)data.chunk.size(); ++i )
    {
        if ( data.chunk[i].cate == 0 )
            return kErrCopyChunkCateNull;

        data.chunk[i].val = 0;
    }

    //展开事件
    return copy_event_extend( user, data );
}

//打开一个新副本
uint32 open( SUser* user )
{
    //用户副本已经存在
    if ( user->data.copy.copy_id != 0 )
        return kErrCopyExist;

    //获取最后id
    uint32 last_id = get_last_log_id( user );
    uint32 copy_id = 1011;   //初始化id

    //获取下一个副本id
    if ( last_id != 0 )
        copy_id = theCopyExt.GetNextId( last_id );

    if ( copy_id == 0 )
        return kErrCopyNotExist;

    //重复副本过滤
    SCopyLog copy_log = copy::get_copy_log( user, copy_id );
    if ( copy_log.copy_id == copy_id )
        return kErrCopyEnded;

    CCopyData::SData* copy = theCopyExt.Find( copy_id );
    if ( copy == NULL )
        return kErrCopyNotExist;

    //检查前置副本Id
    uint32 front_id = theCopyExt.GetFrontId( copy_id );
    if ( front_id != 0 )
    {
        SCopyLog copy_log = copy::get_copy_log( user, front_id );
        if ( copy_log.copy_id == 0 )
            return kErrCopyFront;
    }

    //等级限制
    if ( copy->level > user->data.simple.team_level )
        return kErrCopyFront;

    //初始化副本
    uint32 boss_id = 0;

    //探索型副本
    uint32 result = copy_init( user, copy, boss_id );
    if ( result != 0 )
    {
        //初始化出错时清空当前副本数据
        user->data.copy = SUserCopy();
        return result;
    }

    //初始化副本成功时, 需要初始化 boss 阵亡记录为 0xFF
    set_mopup( user, kCopyMopupTypeNormal, kCopyMopupAttrRound, boss_id, 0xFF );

    return 0;
}

//关闭当前副本
uint32 close( SUser* user, bool force/* = false*/ )
{
    do
    {
        if ( force )
            break;

        if ( state_not( user->data.copy.status, kCopyStateEventEnd ) )
            return kErrCopyNotEnd;

        set_copy_log( user, user->data.copy.copy_id );

        //通关奖励
        CCopyData::SData* copy = theCopyExt.Find( user->data.copy.copy_id );
        if ( copy != NULL )
        {
            if ( copy->pass_reward != 0 )
            {
                CRewardData::SData* reward = theRewardExt.Find( copy->pass_reward );
                if ( reward != NULL )
                    coin::give( user, reward->coins, kPathCopyPass );
            }

            for ( std::vector< S3UInt32 >::iterator i = copy->pass_equip.begin();
                i != copy->pass_equip.end();
                ++i )
            {
                equip::AddFixed( user, i->cate, i->objid, i->val, kPathCopyPassEquip );
            }
        }

        //副本通关事件
        event::dispatch( SEventCopyFinished( user, kPathCopyPass, user->data.copy.copy_id ) );

        //取得下个副本id
        uint32 next_id = theCopyExt.GetNextId( user->data.copy.copy_id );
        if ( next_id != 0 )
        {
            //不同的副本集群id即为本副本集群完结
            uint32 gid = trans_to_group( user->data.copy.copy_id );
            if ( gid != trans_to_group( next_id ) )
                event::dispatch( SEventCopyGroupFinished( user, kPathCopyGroupPass, gid ) );

            //不同的区域集群id即为区域完结
            uint32 aid = trans_to_area( user->data.copy.copy_id );
            if ( aid != trans_to_area( next_id ) )
                event::dispatch( SEventCopyAreaFinished( user, kPathCopyAreaPass, aid ) );
        }
    }
    while(0);

    user->data.copy = SUserCopy();

    return 0;
}

uint32 get_last_log_id( SUser* user )
{
    if ( user->data.copy_log_map.empty() )
        return 0;

    return user->data.copy_log_map.rbegin()->first;
}

void set_copy_log( SUser* user, uint32 copy_id )
{
    SCopyLog& copy_log = user->data.copy_log_map[ copy_id ];

    copy_log.copy_id = copy_id;

    if ( copy_log.time == 0 )
        copy_log.time = (uint32)server::local_time();
}

SCopyLog get_copy_log( SUser* user, uint32 copy_id )
{
    std::map< uint32, SCopyLog >::iterator iter = user->data.copy_log_map.find( copy_id );
    if ( iter == user->data.copy_log_map.end() )
        return SCopyLog();

    return iter->second;
}

int32 get_boss_round( SUser* user, uint32 copy_id, uint32 mopup_type )
{
    CCopyData::SData* copy = theCopyExt.Find( copy_id );
    if ( copy->type != kCopyTypeBoss )
        return -1;

    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, kCopyMopupAttrRound );
    if ( map == NULL )
        return -1;

    uint32 round = 0xFF;

    std::vector< uint32 >& boss = theCopyExt.GetCopyBossList( copy_id );
    for ( int32 i = 0; i < (int32)boss.size(); ++i )
    {
        uint32 boss_id = boss[i];
        if ( mopup_type == kCopyMopupTypeElite )
            boss_id *= 10;

        std::map< uint32, uint32 >::iterator iter = map->find( boss_id );
        if ( iter == map->end() )
            return -1;

        if ( iter->second >= 0xFF )
            return -1;

        if ( iter->second < round )
            round = iter->second;
    }

    return round;
}

void reply_copy_data( SUser* user )
{
    PRCopyData rep;
    bccopy( rep, user->ext );

    rep.data.size = CompressData( user->data.copy, rep.data.data );

    local::write( local::access, rep );
}

void reply_copy_log( SUser* user, SCopyLog& log )
{
    PRCopyLog rep;
    bccopy( rep, user->ext );

    rep.data = log;

    local::write( local::access, rep );
}

void reply_copy_log_list( SUser* user )
{
    PRCopyLogList rep;
    bccopy( rep, user->ext );

    rep.data = user->data.copy_log_map;

    local::write( local::access, rep );
}

S3UInt32 get_copy_cur_event( SUser* user )
{
    if ( user->data.copy.copy_id == 0 )
        return S3UInt32();

    if ( user->data.copy.posi >= (int32)user->data.copy.chunk.size() )
        return S3UInt32();

    return user->data.copy.chunk[ user->data.copy.posi ];
}

S3UInt32 get_copy_cur_reward( SUser* user )
{
    if ( user->data.copy.copy_id == 0 )
        return S3UInt32();

    if ( user->data.copy.posi >= (int32)user->data.copy.reward.size() )
        return S3UInt32();

    return user->data.copy.reward[ user->data.copy.posi ];
}

std::vector< S3UInt32 > get_copy_cur_coins( SUser* user )
{
    if ( user->data.copy.copy_id == 0 )
        return std::vector< S3UInt32 >();

    if ( user->data.copy.posi >= (int32)user->data.copy.coins.size() )
        return std::vector< S3UInt32 >();

    return user->data.copy.coins[ user->data.copy.posi ];
}

//事件提交最后结算流程
void commit_event_end( SUser* user, S3UInt32& cur_reward,
    std::vector< S3UInt32 >& give_coins,
    std::vector< S3UInt32 >& take_coins,
    uint32 path )
{
    if ( user->data.copy.index == 0 )
    {
        //只有在探索块完全完成后才会获得探索奖励
        std::vector< S3UInt32 > cur_coins = get_copy_cur_coins( user );
        if ( !cur_coins.empty() )
        {
            //插入当前探索掉落
            give_coins.insert( give_coins.end(), cur_coins.begin(), cur_coins.end() );
        }

        //累加探索点索引
        user->data.copy.posi++;

        //探索基本奖励
        if ( cur_reward.objid != 0 )
        {
            CRewardData::SData* reward = theRewardExt.Find( cur_reward.objid );
            if ( reward != NULL )
                give_coins.insert( give_coins.end(), reward->coins.begin(), reward->coins.end() );
        }
    }

    //副本通关
    int32 chunk_count = user->data.copy.chunk.size();
    if ( user->data.copy.posi >= chunk_count )
    {
        //副本事件已完成
        state_add( user->data.copy.status, kCopyStateEventEnd );
    }

    //扣取货币
    coin::take( user, take_coins, path );

    //发送奖励
    coin::give( user, give_coins, path );

    //副本探索提交结束
    event::dispatch( SEventCopyCommit( user, kPathCopyCommit, user->data.copy.copy_id ) );
}

uint32 commit_event_to( SUser* user, int32 posi, int32 index )
{
    //循环提交直到 副本posi, index 与 用户请求参数同步
    while ( posi != user->data.copy.posi || index != user->data.copy.index )
    {
        if ( user->data.copy.posi > posi || ( user->data.copy.posi == posi && user->data.copy.index > index ) )
            return kErrCopyEventOrder;

        uint32 result = commit_event_normal( user, user->data.copy.posi, user->data.copy.index );
        if ( result != 0 )
            return result;
    }

    return 0;
}

//普通事件提交
uint32 commit_event_normal( SUser* user, int32 posi, int32 index )
{
    if ( state_is( user->data.copy.status, kCopyStateEventEnd ) )
        return kErrCopyEnded;

    S3UInt32 cur_event = get_copy_cur_event( user );
    S3UInt32 cur_reward = get_copy_cur_reward( user );

    /*
       普通探索取消体力消耗
    //体力消耗
    S3UInt32 cs;
    cs.cate = kCoinStrength;

    //只有 index 为 0 时才会扣探索体力
    if ( user->data.copy.index == 0 && cur_reward.cate > 0 )
    {
        cs.val = cur_reward.cate;

        //体力检查
        uint32 res = coin::check_take( user, cs );
        if ( res != 0 )
            return kErrCopyStrengthNotEnought;
    }
    */

    //货币增减 coins
    std::vector< S3UInt32 > give_coins;
    std::vector< S3UInt32 > take_coins;
    switch ( cur_event.cate )
    {
    case kCopyEventTypeBox:
        {
            CRewardData::SData* reward = theRewardExt.Find( cur_event.val );
            if ( reward == NULL )
                return kErrCopyRewardNotExist;

            give_coins.insert( give_coins.end(), reward->coins.begin(), reward->coins.end() );

            user->data.copy.index = 0;
        }
        break;
    case kCopyEventTypeReward:
        {
            CRewardData::SData* reward = theRewardExt.Find( cur_event.objid );
            if ( reward == NULL )
                return kErrCopyRewardNotExist;

            give_coins.insert( give_coins.end(), reward->coins.begin(), reward->coins.end() );

            user->data.copy.index = 0;
        }
        break;
    case kCopyEventTypeShop:
        {
            //神秘商店
            user->data.copy.index = 0;
        }
        break;
    case kCopyEventTypeGut:
        {
            SGutInfo& gut = user->data.copy.gut[ cur_event.objid ];
            int32 result = gut::commit_event_normal( gut, user->data.copy.index, give_coins, take_coins );
            if ( result != 0 )
                return result;

            if ( ++user->data.copy.index >= (int32)gut.event.size() )
                user->data.copy.index = 0;
        }
        break;
    case kCopyEventTypeFightMeet:
        {
            if ( user->data.copy.index != 0 )
                return kErrCopyEventOrder;

            user->data.copy.index = 1;
        }
        break;
    default:
        return kErrCopyEventOrder;
    }

    /*
       普通探索取消体力耗
    //扣体力
    if ( cs.val != 0 )
        coin::take( user, cs, kPathCopySearch );
    */

    commit_event_end( user, cur_reward, give_coins, take_coins, kPathCopySearch );

    return 0;
}

//战斗事件提交
uint32 commit_event_fight(
    SUser* user,
    int32 posi,
    int32 index,
    uint32 fight_id,
    std::vector< SFightOrder >& order_list,
    std::vector< SFightPlayerSimple >& fight_info_list )
{
    if ( state_is( user->data.copy.status, kCopyStateEventEnd ) )
        return kErrCopyEnded;

    S3UInt32 cur_event = get_copy_cur_event( user );
    S3UInt32 cur_reward = get_copy_cur_reward( user );

    CMonsterData::SData* monster = NULL;

    //体力消耗
    S3UInt32 cs;
    cs.cate = kCoinStrength;

    uint32 cp = kPathCopySearch;

    switch ( cur_event.cate )
    {
    case kCopyEventTypeFight:
    case kCopyEventTypeFightMeet:
        {
            monster = theMonsterExt.Find( cur_event.objid );
            if ( monster == NULL )
                return kErrCopyData;

            cs.val = monster->strength;

            cp = kPathCopyFightMeet;
        }
        break;
    }

    if ( cs.val != 0 )
    {
        //体力检查
        uint32 res = coin::check_take( user, cs );
        if ( res != 0 )
            return kErrCopyStrengthNotEnought;
    }

    //货币操作 coins
    std::vector< S3UInt32 > give_coins;
    std::vector< S3UInt32 > take_coins;
    switch ( cur_event.cate )
    {
    case kCopyEventTypeFightMeet:
        {
            //迎敌战 index 一定会是 1
            if ( user->data.copy.index != 1 )
                return kErrCopyEventOrder;
        }
        //不用 break, 迎敌战需要往下跑遭遇战逻辑
    case kCopyEventTypeFight:
        {
            if ( cur_event.val == 0 )
                return kErrFightNotExist;

            if ( cur_event.val != fight_id )
                return kErrCopyFightIdNotEqual;

            SFight* fight = theFightDC.find( cur_event.val );
            if ( fight == NULL )
                return kErrFightNotExist;

            /*暂时不检查
            fight::InitFightLua( fight, user->data.copy.seed[cur_event.val].value );
            if ( 0 != fight::CheckFightLua( fight, order_list, fight_info_list ) )
                return kErrFightCheck;

            //左边赢
            if ( fight::GetWinCamp( fight ) != kFightLeft )
                return kErrFightFailure;
                */

            //怪物击杀事件
            event::dispatch( SEventFightKillMonster( user, cp, fight->def_id ) );

            //保存boss战斗最小回合击杀数
            //iter == mopup.normal_round.end() 时为小怪, 没有 round
            std::map< uint32, uint32 >::iterator iter = user->data.mopup.normal_round.find( fight->def_id );
            if ( iter != user->data.mopup.normal_round.end() )
            {
                uint32 new_round = fight::GetDeadSoldierCount( fight );
                uint32 old_round = iter->second;

                //上个普通副本boss_id
                uint32 before_normal_boss_id = 0;
                if ( iter != user->data.mopup.normal_round.begin() )
                    before_normal_boss_id = (--iter)->first;

                if ( new_round < old_round )
                {
                    //获取星数
                    uint32 old_star = boss_fight_star( old_round );
                    uint32 now_star = boss_fight_star( new_round );

                    //给予星星
                    if ( now_star > old_star )
                        give_coins.push_back( coin::create( kCoinStar, 0, now_star - old_star ) );

                    //修改普通副本阵亡数据
                    set_mopup( user, kCopyMopupTypeNormal, kCopyMopupAttrRound, fight->def_id, new_round );

                    //增加空扫荡记录
                    if ( !exist_mopup( user, kCopyMopupTypeNormal, kCopyMopupAttrTimes, fight->def_id ) )
                        set_mopup( user, kCopyMopupTypeNormal, kCopyMopupAttrTimes, fight->def_id, 0 );

                    //增加战斗记录
                    fight::RecordSave( fight, order_list );
                    uint32 record_id = fightrecord::Save(fight);
                    add_copyfight_log( user, fight->def_id, record_id, now_star );
                }

                //尝试开启新精英boss
                try_open_elite_boss( user );

                //副本boss击杀事件
                event::dispatch( SEventCopyBossKill( user, cp, kCopyMopupTypeNormal, fight->def_id ) );
            }

            user->data.copy.index = 0;

            //删除战斗数据
            fight::DelFight( fight );
            theFightDC.del( cur_event.val );
        }
        break;

    default:
        return kErrCopyEventOrder;
    }

    //扣体力
    if ( cs.val != 0 )
        coin::take( user, cs, cp );

    commit_event_end( user, cur_reward, give_coins, take_coins, cp );

    return 0;
}

void refurbish( SUser* user )
{
    //修正战斗相关数据
    SUserCopy& data = user->data.copy;
    if ( data.copy_id == 0 )
        return;

    if ( data.chunk.empty() )
        return;

    for ( int32 i = 0; i < (int32)data.chunk.size(); ++i )
    {
        S3UInt32& chunk = data.chunk[i];
        switch ( chunk.cate )
        {
        case kCopyEventTypeFight:
        case kCopyEventTypeFightMeet:
            {
                //移除原有战斗数据
                if ( chunk.val != 0 )
                {
                    std::map< uint32, SFight >::iterator iter = data.fight.find( chunk.val );
                    if ( iter != data.fight.end() )
                    {
                        SFight* fight = theFightDC.find( iter->second.fight_id );

                        if ( fight != NULL )
                            fight::DelFight( fight );
                        theFightDC.del( iter->second.fight_id );

                        data.fight.erase( iter );
                        data.seed.erase( chunk.val );
                    }

                    chunk.val = 0;
                }

                //新增战斗数据
                if ( i >= data.posi )
                {
                    SFight* fight = fight::Interface( kFightTypeCopy )->AddFightToMonster( user, chunk.objid );
                    if ( fight != NULL )
                    {
                        data.fight[ fight->fight_id ] = *fight;
                        data.seed[ fight->fight_id ].value = TRand( 0, 0x7FFFFFFF );
                        chunk.val = fight->fight_id;
                    }
                }
            }
            break;
        }
    }
}

uint32 get_copy_guage( SUser* user )
{
    SUserCopy& data = user->data.copy;
    if ( data.copy_id == 0 )
        return 0;

    uint32 guage = 0;
    for ( int32 i = 0; i < data.posi; ++i )
        guage += data.reward[i].val;

    return guage;
}

uint32 get_group_guage( SUser* user )
{
    SUserCopy& data = user->data.copy;
    if ( data.copy_id == 0 )
        return 0;

    uint32 sum = 0;

    //累加已通过的副本完成度
    for ( uint32 i = copy::trans_to_group( data.copy_id ) * 10 + 1; i < data.copy_id; ++i )
    {
        CCopyData::SData* copy = theCopyExt.Find( i );
        if ( copy == NULL )
            continue;

        sum += copy->guage;
    }

    //获取当前副本最高完成度
    uint32 copy_keep_guage = var::get( user, "copy_keep_guage" );
    uint32 current_guage = copy::get_copy_guage( user );

    uint32 guage = std::max( copy_keep_guage, current_guage );

    //累加当前副本完成度
    sum += guage;

    return sum;
}

uint32 boss_fight( SUser* user, uint32 mopup_type, uint32 boss_id )
{
    //副本BOSS最小击杀回合数记录
    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, kCopyMopupAttrRound );
    if ( map == NULL )
        return kErrCopyBossNotExist;

    std::map< uint32, uint32 >::iterator iter = map->find( boss_id );
    if ( iter == map->end() )
        return kErrCopyBossNotExist;

    //副本扫荡次数获取
    map = switch_mopup_map( user, mopup_type, kCopyMopupAttrTimes );

    //扫荡次数检查
    std::map< uint32, uint32 >::iterator times_iter = map->find( boss_id );
    if ( times_iter == map->end() )
        return kErrCopyBossMopupScore;

    switch ( mopup_type )
    {
    case kCopyMopupTypeNormal:
        {
            if ( times_iter->second + 1 > 20 )
                return kErrCopyMopupTimesNotEnough;
        }
        break;
    case kCopyMopupTypeElite:
        {
            if ( times_iter->second + 1 > 3 )
                return kErrCopyMopupTimesNotEnough;
        }
        break;

    default:
        return kErrCopyMopupTimesNotEnough;
    }

    //怪物数据获取
    CMonsterData::SData* monster = theMonsterExt.Find( boss_id );
    if ( monster == NULL || monster->strength <= 0 )
        return kErrCopyBossNotExist;

    //展开战斗
    SFight* fight = fight::Interface( kFightTypeCopy )->AddFightToMonster( user, boss_id );
    if ( fight == NULL )
        return kErrCopyBossNotExist;

    //清空现有数据
    SCopyBossFight boss_fight = theCopyDC.get_boss_fight( user->guid );
    if ( boss_fight.fight_id != 0 )
    {
        SFight* f = theFightDC.find( boss_fight.fight_id );
        if ( f != NULL )
        {
            fight::DelFight( f );
            theFightDC.del( boss_fight.fight_id );

            theCopyDC.del_boss_fight( user->guid );
        }
    }

    //记录BOSS战数据
    boss_fight.mopup_type = mopup_type;
    boss_fight.boss_id = boss_id;

    boss_fight.fight_id = fight->fight_id;
    boss_fight.seed = TRand( 0, 0x7FFFFFFF );

    boss_fight.coins = monster::GetMonsterDrop( user, boss_id );

    theCopyDC.set_boss_fight( user->guid, boss_fight );

    //返回协议
    PRCopyBossFight rep;
    bccopy( rep, user->ext );

    rep.fight_id = boss_fight.fight_id;
    rep.seed    = boss_fight.seed;
    rep.fight   = *fight;
    rep.coins   = boss_fight.coins;

    local::write( local::access, rep );

    return 0;
}

uint32 boss_fight_commit( SUser* user,
    uint32 fight_id,
    std::vector< SFightOrder >& order_list,
    std::vector< SFightPlayerSimple >& fight_info_list )
{
    SCopyBossFight boss_fight = theCopyDC.get_boss_fight( user->guid );
    if ( boss_fight.fight_id == 0 )
        return kErrCopyBossNotExist;
    if ( boss_fight.fight_id != fight_id )
        return kErrCopyFightIdNotEqual;

    SFight* fight = theFightDC.find( boss_fight.fight_id );
    if ( fight == NULL )
        return kErrFightNotExist;

    CMonsterData::SData* monster = theMonsterExt.Find( boss_fight.boss_id );
    if ( monster == NULL || monster->strength <= 0 )
        return kErrFightNotExist;

    //货币消耗
    std::vector<S3UInt32> coins;
    coins.push_back( coin::create( kCoinStrength, 0, monster->strength ) );

    //货币检查
    uint32 res = coin::check_take( user, coins );
    if ( res != 0 )
        return kErrCoinLack;

    /*暂时不检查
    fight::InitFightLua( fight, boss_fight.seed );
    if ( 0 != fight::CheckFightLua( fight, order_list, fight_info_list ) )
        return kErrFightCheck;

    if ( fight::GetWinCamp( fight ) != kFightLeft )
        return kErrFightFailure;
        */

    //基本错误检查
    std::map< uint32, uint32 >* map = switch_mopup_map( user, boss_fight.mopup_type, kCopyMopupAttrRound );

    //需要有boss击杀记录
    std::map< uint32, uint32 >::iterator iter = map->find( boss_fight.boss_id );
    if ( iter == map->end() )
        return 0;

    //副本boss扫荡数据获取
    map = switch_mopup_map( user, boss_fight.mopup_type, kCopyMopupAttrTimes );

    //扫荡次数检查
    std::map< uint32, uint32 >::iterator times_iter = map->find( boss_fight.boss_id );
    if ( times_iter == map->end() )
        return kErrCopyBossMopupScore;

    bool copy_pass = false;
    switch ( boss_fight.mopup_type )
    {
    case kCopyMopupTypeNormal:
        {
            if ( times_iter->second + 1 > 20 )
                return kErrCopyMopupTimesNotEnough;

            //无探索类型副本完成
            if ( iter->second >= 0xFF
                && user->data.copy.copy_id != 0
                && state_not( user->data.copy.status, kCopyStateEventEnd ) )
            {
                uint32 copy_boss_id = ( user->data.copy.copy_id - 1 ) * 100 + 1;

                if ( copy_boss_id == boss_fight.boss_id )
                    copy_pass = true;
            }
        }
        break;
    case kCopyMopupTypeElite:
        {
            if ( times_iter->second + 1 > 3 )
                return kErrCopyMopupTimesNotEnough;
        }
        break;

    default:
        return kErrCopyMopupTimesNotEnough;
    }

    //增加副本扫荡次数并返回
    set_mopup( user, boss_fight.mopup_type, kCopyMopupAttrTimes, boss_fight.boss_id, times_iter->second + 1 );

    //扣除货币
    coin::take( user, coins, kPathCopyBossFight );

    //保存boss战斗最小回合击杀数
    uint32 old_round = iter->second;
    uint32 new_round = fight::GetDeadSoldierCount( fight );

    //修改最小击杀阵亡数
    coins.clear();
    if ( new_round < old_round )
    {
        //获取星数
        uint32 old_star = boss_fight_star( old_round );
        uint32 now_star = boss_fight_star( new_round );

        //给予星星
        if ( now_star > old_star )
            coins.push_back( coin::create( kCoinStar, 0, now_star - old_star ) );

        //增加空扫荡记录
        if ( !exist_mopup( user, boss_fight.mopup_type, kCopyMopupAttrTimes, boss_fight.boss_id ) )
            set_mopup( user, boss_fight.mopup_type, kCopyMopupAttrTimes, boss_fight.boss_id, 0 );

        //更新最小击杀
        set_mopup( user, boss_fight.mopup_type, kCopyMopupAttrRound, boss_fight.boss_id, new_round );

        //增加战斗记录
        fight::RecordSave( fight, order_list );
        uint32 record_id = fightrecord::Save(fight);
        add_copyfight_log( user, fight->def_id, record_id, now_star );
    }

    //插入掉落数据
    coins.insert( coins.end(), boss_fight.coins.begin(), boss_fight.coins.end() );

    if ( !coins.empty() )
        coin::give( user, coins, kPathCopyBossFight );

    //清除数据
    fight::DelFight( fight );
    theFightDC.del( boss_fight.fight_id );

    theCopyDC.del_boss_fight( user->guid );

    //尝试开启新精英boss
    try_open_elite_boss( user );

    //怪物击杀事件
    event::dispatch( SEventFightKillMonster( user, kPathCopyBossFight, boss_fight.boss_id ) );

    //副本boss击杀事件
    event::dispatch( SEventCopyBossKill( user, kPathCopyBossFight, boss_fight.mopup_type, boss_fight.boss_id ) );

    //非探索型副本通关
    if ( copy_pass )
    {
        state_add( user->data.copy.status, kCopyStateEventEnd );

        reply_copy_data( user );
    }

    return 0;
}

uint32 area_present_take( SUser* user, uint32 area_id, uint8 mopup_type, uint8 area_attr )
{
    //获取区域副本id
    std::vector< uint32 >& copy_list = theCopyExt.GetAreaCopyList( area_id );
    if ( copy_list.empty() )
        return kErrCopyAreaNotExist;

    //获取该区域的所有boss_id
    std::vector< uint32 > boss_list;
    for ( std::vector< uint32 >::iterator iter = copy_list.begin();
        iter != copy_list.end();
        ++iter )
    {
        std::vector< uint32 >& temp_list = theCopyExt.GetCopyBossList( *iter );

        boss_list.insert( boss_list.end(), temp_list.begin(), temp_list.end() );
    }

    //数据容错检查
    if ( boss_list.empty() )
        return kErrCopyAreaNotExist;

    //副本区域全星判断
    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, kCopyMopupAttrRound );
    if ( map == NULL )
        return kErrCopyAreaNotExist;

    //全星判断
    for ( std::vector< uint32 >::iterator i = boss_list.begin();
        i != boss_list.end();
        ++i )
    {
        uint32 boss_id = *i;

        switch ( mopup_type )
        {
        case kCopyMopupTypeNormal:
            break;
        case kCopyMopupTypeElite:
            {
                boss_id *= 10;
            }
            break;
        default:
            return kErrCopyAreaNotExist;
        }

        std::map< uint32, uint32 >::iterator i = map->find( boss_id );
        if ( i == map->end() )
            return kErrCopyAreaNotExist;

        //0xFF 为副本记录初始化, >= 0xFF 为未挑战成功
        if ( i->second >= 0xFF )
            return kErrCopyAreaNotExist;

        if ( area_attr == kCopyAreaAttrFullStar && i->second > 0 )
            return kErrCopyAreaNoFullStar;
    }

    //静态数据获取
    CAreaData::SData* area = theAreaExt.Find( area_id );
    if ( area == NULL )
        return kErrCopyAreaNotExist;

    //奖励已领取判断
    SAreaLog& area_log = user->data.area_log_map[ area_id ];
    area_log.area_id = area_id;

    uint32* take_time = NULL;
    uint32 reward_id = 0;
    switch ( mopup_type )
    {
    case kCopyMopupTypeNormal:
        {
            switch ( area_attr )
            {
            case kCopyAreaAttrFullStar:
                {
                    take_time = &area_log.normal_full_take_time;
                    reward_id = area->normal_full_reward;
                }
                break;
            case kCopyAreaAttrPass:
                {
                    take_time = &area_log.normal_pass_take_time;
                    reward_id = area->normal_pass_reward;
                }
                break;
            }
        }
        break;
    case kCopyMopupTypeElite:
        {
            switch ( area_attr )
            {
            case kCopyAreaAttrFullStar:
                {
                    take_time = &area_log.elite_full_take_time;
                    reward_id = area->elite_full_reward;
                }
                break;
            case kCopyAreaAttrPass:
                {
                    take_time = &area_log.elite_pass_take_time;
                    reward_id = area->elite_pass_reward;
                }
                break;
            }
        }
        break;
    }

    if ( take_time == NULL || reward_id == 0 || *take_time != 0 )
        return kErrCopyAreaPresentTaked;

    CRewardData::SData* reward = theRewardExt.Find( reward_id );
    if ( reward == NULL )
        return kErrCopyAreaNotExist;

    //修改数据
    *take_time = server::local_time();
    reply_area_log( user, area_log );

    //发放奖励
    coin::give( user, reward->coins, kPathCopyAreaPresentTake );

    event::dispatch( SEventCopyAreaPresentTake( user, kPathCopyAreaPresentTake, mopup_type, area_id, area_attr ) );

    return 0;
}

uint32 boss_mopup( SUser* user, uint8 mopup_type, uint32 boss_id, uint32 count )
{
    //基本容错
    if ( count <= 0 || count > 10 )
        return kErrCopyParam;

    //副本boss阵亡数据获取
    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, kCopyMopupAttrRound );
    if ( map == NULL )
        return kErrCopyNotPass;

    std::map< uint32, uint32 >::iterator iter = map->find( boss_id );
    if ( iter == map->end() )
        return kErrCopyBossNotExist;

    CMonsterData::SData* monster = theMonsterExt.Find( boss_id );
    if ( monster == NULL || monster->strength <= 0 )
        return kErrCopyBossNotExist;

    //达到3星 评分才允许扫荡
    if ( boss_fight_star( iter->second ) < 3 )
        return kErrCopyBossMopupScore;

    //副本boss扫荡数据获取
    map = switch_mopup_map( user, mopup_type, kCopyMopupAttrTimes );

    //扫荡次数检查
    std::map< uint32, uint32 >::iterator times_iter = map->find( boss_id );
    if ( times_iter == map->end() )
        return kErrCopyBossMopupScore;

    switch ( mopup_type )
    {
    case kCopyMopupTypeNormal:
        {
            if ( times_iter->second + count > 20 )
                return kErrCopyMopupTimesNotEnough;
        }
        break;
    case kCopyMopupTypeElite:
        {
            if ( times_iter->second + count > 3 )
                return kErrCopyMopupTimesNotEnough;
        }
        break;

    default:
        return kErrCopyMopupTimesNotEnough;
    }

    //扫荡花费检查
    std::vector< S3UInt32 > coins;
    coins.push_back( coin::create( kCoinStrength, 0, monster->strength * count ) );

    //检查扫荡券数量
    uint32 item_count = item::GetItemCount( user, 35 );
    if ( item_count >= count )
    {
        //扫荡券货币扣取
        coins.push_back( coin::create( kCoinItem, 35, count ) );
    }
    else if ( item_count == 0 )
    {
        //钻石扣取
        coins.push_back( coin::create( kCoinGold, 0, count ) );
    }
    else
    {
        //部分券, 剩余用钻石替代
        coins.push_back( coin::create( kCoinItem, 35, item_count ) );
        coins.push_back( coin::create( kCoinGold, 0, count - item_count ) );
    }

    uint32 res = coin::check_take( user, coins );
    if ( res != 0 )
        return kErrCoinLack;

    //============================以下开始修改数据=========================

    //扣取花费所需
    coin::take( user, coins,  kPathCopyBossMopup );

    //增加副本扫荡次数并返回
    set_mopup( user, mopup_type, kCopyMopupAttrTimes, boss_id, times_iter->second + count );

    //返回包构建
    PRCopyBossMopup rep;
    bccopy( rep, user->ext );

    rep.mopup_type  = mopup_type;
    rep.boss_id     = boss_id;

    for ( uint32 i = 0; i < count; ++i )
    {
        //怪物掉落
        std::vector< S3UInt32 > coins = monster::GetMonsterDrop( user, boss_id );

        //加入协议包返回统计
        rep.coins.push_back( coins );

        //发送货币
        coin::give( user, coins, kPathCopyBossMopup );
    }

    local::write( local::access, rep );

    for ( uint32 i = 0; i < count; ++i )
    {
        //怪物击杀事件
        event::dispatch( SEventFightKillMonster( user, kPathCopyBossMopup, boss_id ) );

        //副本boss击杀事件
        event::dispatch( SEventCopyBossKill( user, kPathCopyBossMopup, mopup_type, boss_id ) );
    }

    //副本boss击杀事件
    event::dispatch( SEventCopyBossMopup( user, kPathCopyBossMopup, mopup_type, boss_id, count ) );

    return 0;
}

void try_open_elite_boss( SUser* user )
{
    //没有普通 boss 容错
    if ( user->data.mopup.normal_round.empty() )
        return;

    uint32 next_elite_boss_id = 0;

    do
    {
        //取最后精英副本数据
        std::map< uint32, uint32 >::reverse_iterator elite_iter = user->data.mopup.elite_round.rbegin();

        //没有精英boss数据
        if ( elite_iter == user->data.mopup.elite_round.rend() )
        {
            //使用第一个普通boss作为参照boss
            if ( !user->data.mopup.normal_round.empty() )
                next_elite_boss_id = user->data.mopup.normal_round.begin()->first * 10;

            break;
        }

        //精英副本未通关
        if ( elite_iter->second >= 0xFF )
            break;

        uint32 elite_boss_id    = elite_iter->first;
        uint32 normal_boss_id   = elite_boss_id / 10;

        //普通 boss 数据
        std::map< uint32, uint32 >::iterator normal_iter = user->data.mopup.normal_round.find( normal_boss_id );
        if ( normal_iter == user->data.mopup.normal_round.end() )
            break;

        //往后取下一个普通 boss 数据
        if ( ++normal_iter == user->data.mopup.normal_round.end() )
            break;

        //下个普通 boss 未通关判断
        if ( normal_iter->second >= 0xFF )
            break;

        //取得下个普通 boss_id
        uint32 next_normal_boss_id = normal_iter->first;

        next_elite_boss_id = next_normal_boss_id * 10;
    }
    while(0);

    if ( next_elite_boss_id != 0 )
    {
        //开通新精英 boss
        set_mopup( user, kCopyMopupTypeElite, kCopyMopupAttrRound, next_elite_boss_id, 0xFF );

        //增加空扫荡记录
        set_mopup( user, kCopyMopupTypeElite, kCopyMopupAttrTimes, next_elite_boss_id, 0 );
    }
}

uint32 mopup_reset( SUser* user, uint32 mopup_type, uint32 monster_id )
{
    CLevelData::SData* level = theLevelExt.Find( user->data.simple.vip_level );
    if ( level == NULL )
        return kErrCopyMopupNotExist;

    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, kCopyMopupAttrTimes );
    if ( map == NULL )
        return kErrCopyMopupNotExist;

    //副本重置次数
    uint32 day_ref = get_mopup( user, mopup_type, kCopyMopupAttrReset, monster_id );

    uint32 limit_reset_times = 0;
    uint32 reset_price = 0;
    switch ( mopup_type )
    {
    case kCopyMopupTypeNormal:
        {
            limit_reset_times = level->copy_normal_reset_times;

            level = theLevelExt.Find( day_ref );
            if ( level == NULL )
                return kErrCopyMopupNotExist;

            reset_price = level->copy_normal_reset_price;
        }
        break;
    case kCopyMopupTypeElite:
        {
            limit_reset_times = level->copy_elite_reset_times;

            level = theLevelExt.Find( day_ref );
            if ( level == NULL )
                return kErrCopyMopupNotExist;

            reset_price = level->copy_elite_reset_price;
        }
        break;

    default:
        return kErrCopyParam;
    }

    std::map< uint32, uint32 >::iterator iter = map->find( monster_id );
    if ( iter == map->end() || iter->second == 0 )
        return kErrCopyMopupTimesFull;

    if ( day_ref + 1 > limit_reset_times )
        return kErrCopyMopupRefTimesNotEnough;

    if ( reset_price <= 0 )
        return kErrCopyParam;

    S3UInt32 coin = coin::create( kCoinGold, 0, reset_price );

    uint32 ret = coin::check_take( user, coin );
    if ( ret != 0 )
        return kErrCoinLack;

    //扣取货币
    coin::take( user, coin, kPathCopyMopupReset );

    //设置扫荡每日重置次数
    set_mopup( user, mopup_type, kCopyMopupAttrReset, monster_id, day_ref + 1 );

    //重置扫荡次数
    set_mopup( user, mopup_type, kCopyMopupAttrTimes, monster_id, 0 );

    return 0;
}

std::map< uint32, uint32 >* switch_mopup_map( SUser* user, uint32 mopup_type, uint32 mopup_attr )
{
    std::map< uint32, uint32 >* map = NULL;

    switch ( mopup_type )
    {
    case kCopyMopupTypeNormal:
        {
            switch ( mopup_attr )
            {
            case kCopyMopupAttrRound:
                map = &user->data.mopup.normal_round;
                break;
            case kCopyMopupAttrTimes:
                map = &user->data.mopup.normal_times;
                break;
            case kCopyMopupAttrReset:
                map = &user->data.mopup.normal_reset;
                break;
            }
        }
        break;
    case kCopyMopupTypeElite:
        {
            switch ( mopup_attr )
            {
            case kCopyMopupAttrRound:
                map = &user->data.mopup.elite_round;
                break;
            case kCopyMopupAttrTimes:
                map = &user->data.mopup.elite_times;
                break;
            case kCopyMopupAttrReset:
                map = &user->data.mopup.elite_reset;
                break;
            }
        }
        break;
    }

    return map;
}
void set_mopup( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id, uint32 value )
{
    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, mopup_attr );

    if ( map == NULL )
        return;

    (*map)[ monster_id ] = value;

    reply_mopup_data( user, mopup_type, mopup_attr, monster_id, value );
}

uint32 get_mopup( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id )
{
    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, mopup_attr );

    if ( map == NULL )
        return 0;

    return (*map)[ monster_id ];
}

bool exist_mopup( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id )
{
    std::map< uint32, uint32 >* map = switch_mopup_map( user, mopup_type, mopup_attr );

    if ( map == NULL )
        return false;

    return ( map->find( monster_id ) != map->end() );
}

void reply_mopup_data( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id, uint32 value )
{
    PRCopyMopupData msg;
    bccopy( msg, user->ext );

    msg.mopup_type  = mopup_type;
    msg.mopup_attr  = mopup_attr;

    msg.boss_id     = monster_id;
    msg.value       = value;

    local::write( local::access, msg );
}

void reply_area_log( SUser* user, SAreaLog& data )
{
    PRCopyAreaData msg;
    bccopy( msg, user->ext );

    msg.data = data;

    local::write( local::access, msg );
}

void add_copyfight_log( SUser *puser, uint32 copy_id, uint32 record_id, uint32 star )
{
    SCopyFightLog log;
    log.copy_id = copy_id;
    log.fight_id = record_id;
    log.ack_id = puser->guid;
    log.ack_level = puser->data.simple.team_level;
    log.ack_name = puser->data.simple.name;
    log.ack_avatar = puser->data.simple.avatar;
    log.log_time    = time(NULL);
    log.star = star;
    log.fight_value = fightextable::GetFightValue(puser, kFormationTypeCommon);

    theCopyDC.add_copyfight_log( copy_id, log );
}

}// namespace copy

