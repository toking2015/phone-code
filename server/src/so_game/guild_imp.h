#ifndef _IMMORTAL_GAME_GUILD_IMP_H_
#define _IMMORTAL_GAME_GUILD_IMP_H_

#include "common.h"
#include "proto/guild.h"
#include "proto/user.h"

namespace guild
{
    //临时锁定用户异步处理逻辑产生的可能性冲突性操作( 需要其它线程或进程协调处理的逻辑 )
    //如: 避免快速多次创建公会, 避免快速多次改名
    //Lock() 成功后, 如果 5 秒内没有 Unlock 操作会被视作自动 Unlock
    //Lock() == false 为用户正在锁定状态, 应该进行相应的容错处理
    bool TryLock( SGuild* guild );                            //如果已经上锁返回 false, 否则返回 true(不上锁)
    bool Lock( SGuild* guild, uint32 seconds = 5 );         //如果已经上锁返回 false, 否则上锁并返回 true
    void Unlock( SGuild* guild );

    //获取公会长id
    uint32 GetMasterId(SGuild *guild);

    //申请加入
    uint32 Apply(SGuild *guild, SUser *user);
    //删除加入
    uint32 DelApply(SGuild *guild, uint32 role_id);
    //返回已申请的申请公会列表
    void ReplyApplyGuilds(SUser *user);
    //申请人更新
    void ApplyNotify(uint32 master_id, uint32 role_id, uint32 set_type);

    //审批加入申请
    uint32 Approve(SUser *user, SGuild *guild, SUser *target_user, bool is_accpet);

    //获取公会成员的职务, 返回 0 不存在成员, 否则返回 kGuildJobXXX
    uint32 GetJob( SGuild* guild, uint32 role_id );

    //加入公会, 成功返回0, 失败返回错误码
    uint32 Join( SGuild* guild, SUser* user );

    //退出公会, 成功返回0, 失败返回错误码
    uint32 Quit ( SGuild* guild, SUser* user );

    //踢出公会
    uint32 Kick(SGuild* guild, SUser* user, SUser* target);

    //职务修改, 成功返回0, 失败返回错误码
    uint32 ChangeJob( SGuild* guild, SUser* user, SUser* target, uint32 job );

    //添加日志
    void AddLog(SGuild *guild, uint32 log_type, std::string params);

    //成员数据广播
    void ReplyMemberSet(SGuild *guild, SGuildMember &member, uint32 set_type);

    //捐献
    uint32 Contribute(SGuild *guild, SUser *user, uint32 id);

    //升级
    uint32 Levelup(SGuild *guild, SUser *user);
    //等级经验更新
    void ReplyLevel(SGuild *guild);

    void AddXp(SGuild *guild, SUser *user, uint32 value, uint32 path);
    void DelXp(SGuild *guild, SUser *user, uint32 value, uint32 path);

} // namespace guild

#endif

