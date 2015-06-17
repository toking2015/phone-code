#ifndef _GAMESVR_USER_IMP_H_
#define _GAMESVR_USER_IMP_H_

#include "common.h"
#include "proto/common.h"
#include "proto/user.h"
/*
 * 玩家功能:
 */

namespace user
{

//判断用户是否为 online 状态
bool is_online( SUser* user );

//临时锁定用户异步处理逻辑产生的可能性冲突性操作( 需要其它线程或进程协调处理的逻辑 )
//如: 避免快速多次创建公会, 避免快速多次改名
//Lock() 成功后, 如果 5 秒内没有 Unlock 操作会被视作自动 Unlock
//Lock() == false 为用户正在锁定状态, 应该进行相应的容错处理
bool TryLock( SUser* user );                            //如果已经上锁返回 false, 否则返回 true(不上锁)
bool Lock( SUser* user, uint32 seconds = 5 );           //如果已经上锁返回 false, 否则上锁并返回 true
void Unlock( SUser* user );

//设置战斗id
void SetFightId( SUser *puser, uint32 id );
void DelFightId( SUser *puser );
uint32 GetFightId( SUser *puser );

//Simple
void ReplyUserSimple( SUser *puser, SUser *ptarget );
//other
void ReplyUserOther( SUser *puser);

void reply_data( SUser* user );

} // namespace user

#endif
