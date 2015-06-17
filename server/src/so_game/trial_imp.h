#ifndef IMMORTAL_GAMESVR_TRIALIMP_H_
#define IMMORTAL_GAMESVR_TRIALIMP_H_

#include "common.h"
#include "proto/trial.h"
#include "proto/user.h"
/*
 * 阵型功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace trial
{
    uint32 GetFormationType( uint32 id );
    uint32 GetFightType( uint32 id );
    //试炼进入
    void Enter(SUser *puser, uint32 id, std::vector<SUserFormation> &list );
    //添加Val
    void AddVal(SUser *puser, uint32 id, uint32 val);
    //添加try
    void AddTry(SUser *puser, uint32 id);
    //添加领奖次数
    void AddReward(SUser *puser, uint32 id);
    //设置怪物
    void SetMonster( uint32 monster_id, uint32 user_level, SFightPlayerInfo &play_info, uint32 &guid );
    //获取怪物属性
    void GetMonsterExt( uint32 monster_id, uint32 lv, SFightExtAble &dst_able );
    //奖励创建
    bool RandomCreate( SUser *puser, uint32 id );
    //领取奖励
    void RewardGet(SUser *puser, uint32 id, uint32 index);
    //下一个奖励
    void RewardEnd(SUser *puser, uint32 id);
    //返回奖励LIST
    void ReplyRewardList(SUser *puser, uint32 id);
    //返回Trial信息
    void ReplyTrial(SUser *puser, uint32 id);
    //每天重置
    void TimeLimit(SUser *puser);
    //添加武将BUFF
    void AddTrialBuff( uint32 trial_id, uint32 soldier_occu, std::vector<SFightOdd> &odd_list );
    //扫荡
    void MopUp( SUser *puser,  uint32 trial_id );
}// namespace trial

#endif  //IMMORTAL_GAMESVR_TRIALIMP_H_
