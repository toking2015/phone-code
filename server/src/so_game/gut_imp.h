#ifndef _IMMORTAL_GAMESVR_GUT_IMP_H_
#define _IMMORTAL_GAMESVR_GUT_IMP_H_

#include "proto/gut.h"
#include "proto/user.h"
#include "proto/fight.h"

namespace gut
{

//分配剧情( 并没有指定剧情保存的位置, 需要外部逻辑处理, 如果不处理会导致战斗模块涉漏 )
SGutInfo alloc( SUser* user, uint32 gut_id );

//注销剧情数据
void destory( SGutInfo& gut );

//创建主剧情
void create( SUser* user, uint32 gut_id );

//提交剧情普通事件验证, 成功返回0
int32 commit_event_normal( SGutInfo& gut, int32 index,
    std::vector< S3UInt32 >& give_coins, std::vector< S3UInt32 >& take_coins );

//返回剧情事件
void reply_gut_info( SUser* user, SGutInfo& gut );

} // namespace gut

#endif

