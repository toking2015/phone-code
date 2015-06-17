#ifndef IMMORTAL_FIGHTSVR_FIGHTIMP_H_
#define IMMORTAL_FIGHTSVR_FIGHTIMP_H_

#include "common.h"
#include "proto/fight.h"
#include "proto/formation.h"
#include "proto/user.h"
#include "luamgr.h"
/*
 * 战斗功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace fight
{
    //Interface
    //设置客户端使用技能序列到Lua
    void SetOrderLua( SFight *psfight, std::vector<SFightOrder> &order_list );
    std::vector<SFightOrder> GetOrderLua( uint32 id );
    //设置武将的最终状态到Lua
    void SetSoldierEndLua( SFight *psfight, std::vector<SFightPlayerSimple> &play_info_list );
    //初始化战斗
    void InitFightLua( uint32 fight_id, uint32 fight_seed, uint32 fight_type, std::vector<SFightPlayerInfo> &play_info_list );
    //把战斗信息放到Lua
    void FightInfoToLua( uint32 fight_id, std::vector<SFightPlayerInfo> &play_info_list );
    //检查战斗
    uint32 CheckFightLua( SFight *psfight, std::vector<SFightOrder> &order_list, std::vector<SFightPlayerSimple> &play_info_list);
    void FightLua( uint32 fight_id, uint32 random_seed, uint32 fight_type, std::vector<SFightPlayerInfo> &play_info_list );
    uint32 GetWinCamp( uint32 id );
    uint32 GetRoundOut( uint32 id );
    std::map<uint32, SFightEndInfo> GetFightEndInfo( uint32 id );
    void DelFight( uint32 id );

    //返回技能使用战斗数据
    void RoundSkill( uint32 id );
    void TotemSkill( uint32 id, uint32 guid );
    void TestFightLua();
} // namespace fight

#endif  //IMMORTAL_FIGHTSVR_FIGHTIMP_H_
