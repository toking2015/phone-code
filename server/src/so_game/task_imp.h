#ifndef _IMMORTAL_GAMESVR_TASK_IMP_H_
#define _IMMORTAL_GAMESVR_TASK_IMP_H_

#include "proto/user.h"
#include "proto/task.h"
#include "resource/r_taskext.h"

namespace task
{

//接受任务
uint32 task_accept_check( SUser* user, uint32 task_id );
uint32 task_accept( SUser* user, uint32 task_id );

//完成任务
uint32 task_finish_check( SUser* user, uint32 task_id );
uint32 task_finish( SUser* user, uint32 task_id, bool auto_finish, bool debug = false );

//数据修改
uint32 task_set_check( SUser* user, uint32 task_id );
uint32 task_set( SUser* user, SUserTask& data );

//匹配用户任务, 并自动接受任务
void match( SUser* user );

void reply_task_set( SUser* user, uint8 set_type, SUserTask& data );
void reply_task_log( SUser* user, SUserTaskLog& data );
void reply_task_day( SUser* user, SUserTaskDay& data );
void reply_task_day_list( SUser* user );

//操作当前任务完成条件值, < cate:kTaskCondXXX, objid:id, val:val >
void add_cond_value( SUser* user, S3UInt32 coin );     //累计型( 条件值累加 )
void add_cond_value( SUser* user, S3UInt32 coin, SUserTask& user_task );
void max_cond_value( SUser* user, S3UInt32 coin );     //最大型( 条件值取最大 )
void max_cond_value( SUser* user, S3UInt32 coin, SUserTask& user_task );

//日常任务积分领奖
uint32 day_val_reward(SUser *user, uint32 id);
//日常任务积分奖励列表
void ReplyDayTaskValRewardList(SUser *user);

} // namespace task

#endif // _IMMORTAL_GAMESVR_TASK_IMP_H_

