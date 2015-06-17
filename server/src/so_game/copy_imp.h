#ifndef _IMMORTAL_SO_GAME_COPY_IMP_H_
#define _IMMORTAL_SO_GAME_COPY_IMP_H_

#include "common.h"
#include "proto/user.h"
#include "proto/fight.h"

namespace copy
{

//副本id转换为集群id
uint32 trans_to_group( uint32 copy_id );

//打开一个新副本
uint32 open( SUser* user );

//关闭当前副本
uint32 close( SUser* user, bool force = false );

//获取最后通关副本Id
uint32 get_last_log_id( SUser* user );

//增加副本通关记录
void set_copy_log( SUser* user, uint32 copy_id );

//获取副本通关记录
SCopyLog get_copy_log( SUser* user, uint32 copy_id );

//获取副本BOSS最小伤亡记录, 返回 -1 为不存在记录
int32 get_boss_round( SUser* user, uint32 copy_id, uint32 mopup_type );

//返回副本数据
void reply_copy_data( SUser* user );

//返回副本记录
void reply_copy_log( SUser* user, SCopyLog& log );

//返回副本记录列表
void reply_copy_log_list( SUser* user );

//获取下一环节事件
S3UInt32 get_copy_next_event( SUser* user );

//获取下一环节奖励
S3UInt32 get_copy_next_reward( SUser* user );

//整合事件提交
uint32 commit_event_to( SUser* user, int32 posi, int32 index );

//普通事件提交
uint32 commit_event_normal( SUser* user, int32 posi, int32 index );

//战斗事件提交
uint32 commit_event_fight(
    SUser* user,
    int32 posi,
    int32 index,
    uint32 fight_id,
    std::vector< SFightOrder >& order_list,
    std::vector< SFightPlayerSimple >& fight_info_list );

//刷新副本数据( 不影响已提交验证的事件 )
void refurbish( SUser* user );

//获取当前副本完成度
uint32 get_copy_guage( SUser* user );

//获取集群副本完成度
uint32 get_group_guage( SUser* user );

//挑战通关副本boss
uint32 boss_fight( SUser* user, uint32 mopup_type, uint32 boss_id );

//挑战boss战斗确认
uint32 boss_fight_commit( SUser* user, uint32 fight_id, std::vector< SFightOrder >& order_list, std::vector< SFightPlayerSimple >& fight_info_list );

//副本区域满星奖励领取
uint32 area_present_take( SUser* user, uint32 area_id, uint8 mopup_type, uint8 area_attr );

//boss扫荡
uint32 boss_mopup( SUser* user, uint8 mopup_type, uint32 boss_id, uint32 count );

//尝试开启新精英boss
void try_open_elite_boss( SUser* user );

//重置扫荡次数
uint32 mopup_reset( SUser* user, uint32 mopup_type, uint32 monster_id );

//根据副本类型和扫荡值类型获取对应 map 对象
std::map< uint32, uint32 >* switch_mopup_map( SUser* user, uint32 mopup_type, uint32 mopup_attr );

//设置扫荡数据
void set_mopup( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id, uint32 value );

//获取扫荡数据
uint32 get_mopup( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id );

//判断扫荡数据是否存在
bool exist_mopup( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id );

//返回扫荡单条记录
void reply_mopup_data( SUser* user, uint32 mopup_type, uint32 mopup_attr, uint32 monster_id, uint32 value );

//返回区域记录
void reply_area_log( SUser* user, SAreaLog& data );

void add_copyfight_log( SUser *puser, uint32 copy_id, uint32 record_id, uint32 star );

}// namespace copy

#endif

