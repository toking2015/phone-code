#ifndef IMMORTAL_GAMESVR_TOMBIMP_H_
#define IMMORTAL_GAMESVR_TOMBIMP_H_

#include "common.h"
#include "proto/tomb.h"
#include "proto/user.h"
/*
 * 阵型功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace tomb
{
    uint32 GetSoldierType( uint32 id );
    //墓地战斗
    void Fight(SUser *puser, uint32 player_index, uint32 player_guid, std::vector<SUserFormation> &list );
    //奖励
    void RewardGet(SUser *puser, uint32 reward_index);
    //重置
    void Reset(SUser *puser);
    //玩家重置
    void PlayerReset(SUser *puser, uint32 player_index);
    //扫荡
    void MopUp(SUser *puser);
    //每天重置
    void TimeLimit(SUser *puser);
    //生成对战人员
    uint32 RandomCreatePlayer(SUser *puser, uint32 part);
    void RandomCreate(SUser *puser);
    //设置人员
    void SetSoldier(SUser *puser, SUserFormation& formation, SFightSoldier &fight_soldier );
    //设置怪物
    void SetMonster(SUser *puser, uint32 monster_id, uint32 user_level, SFightPlayerInfo &play_info, uint32 &guid );
    //获取怪物属性
    void GetMonsterExt( uint32 monster_id, uint32 lv, float ratio, SFightExtAble &dst_able );
    //AddWinCount
    void AddWinCount(SUser *puser);
    void ReplyInfo(SUser *puser);
    void ReplyList(SUser *puser);
    bool CheckList(SUser *puser);
}// namespace tomb

#endif  //IMMORTAL_GAMESVR_TOMBIMP_H_
