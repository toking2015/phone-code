#ifndef IMMORTAL_GAMESVR_FIGHTIMP_H_
#define IMMORTAL_GAMESVR_FIGHTIMP_H_

#include "common.h"
#include "proto/fight.h"
#include "proto/formation.h"
#include "proto/user.h"
#include "resource/r_oddext.h"
#include "luamgr.h"
#include "fight.h"
#include "fight_dc.h"
#include "user_dc.h"
#include "local.h"
/*
 * 战斗功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace fight
{
    //Interface Lua结构修改的时候 要注意战斗服务器是否需要修改
    //设置武将属性
    void SetSoldier( SUser *puser, SUserFormation& formation, SFightSoldier& soldier );
    void SetMonsterSoldier( uint32 soldier_id, SFightSoldier& soldier, std::vector<SUserFormation> &formation_list );
    //设置客户端使用技能序列到Lua
    void SetOrderLua( SFight *psfight, std::vector<SFightOrder> &order_list );
    //设置武将的最终状态到Lua
    void SetSoldierEndLua( SFight *psfight, std::vector<SFightPlayerSimple> &play_info_list );
    void UpdateSoldierHpRage( SUser *puser, uint32 soldier_type, SFightPlayerSimple &play_info );
    uint32 GetDeadSoldierCount( SFight *psfight );
    //设置怪物属性
    void SetMonster( uint32 monster_id, SFightPlayerInfo &play_info, uint32 &guid );
    bool GetFightIndex( SFightPlayerInfo &play_info, uint32 &index );
    void SetTotem( uint32 totem_id, SFightSoldier &fight_soldier );
    void GetMonsterSkill( uint32 monster_id, std::vector<SFightSkill> &skill_list );
    void GetMonsterOdd( uint32 monster_id, uint32 monster_index, std::vector<SFightOdd> &odd_list );
    void GetMonsterSoldierSkill( uint32 id, std::vector<SFightSkill> &skill_list );
    void GetMonsterSoldierOdd( uint32 id, uint32 monster_index, std::vector<SFightOdd> &odd_list );
    void MonsterToFightExt( uint32 monster_id, SFightExtAble &able );
    void SoldierToFightExt( uint32 monster_id, SFightExtAble &able );
    //初始化战斗
    void InitFightLua( SFight *psfight );
    void InitFightLua( SFight *psfight, uint32 seed );
    void AutoFight( SFight *psfight );
    //把战斗信息放到Lua
    void FightInfoToLua( SFight *psfight );
    //检查战斗
    void CreateFightOdd( COddData::SData *podd, SFightOdd &fight_odd );
    uint32 CheckFightLua( SFight *psfight, std::vector<SFightOrder> &order_list, std::vector<SFightPlayerSimple> &play_info_list);
    uint32 GetWinCamp( SFight *psfight );
    std::vector<SFightEndInfo> GetFightEndInfo( SFight *psfight );
    uint32 GetRound( SFight *psfight );
    void DelFight( SFight *psfight );
    void DelFight( uint32 id );
    //返回战斗信息到客户端
    void ReplyFightInfo( SFight *psfight );
    //返回战斗信息到战斗服务器
    void ReplyFightInfoToFightSvr( SFight *psfight );
    //战斗LOG保存
    void RecordSave( SFight *psfight, std::vector<SFightOrder> &order_list );

    //返回技能使用战斗数据
    void RoundSkill( uint32 id );
    void TotemSkill( uint32 id, uint32 guid );
    void TestFightLua();
    void RoundDelaySkill( uint32 id, uint32 seqno );

    //创建一个战斗
    CFight* Interface( uint32 fight_type );
    void InitInterface(void);

    //获取Lua的战斗数据
    void GetFightData();
    void SetFightData();

    template <typename T>
        void ReplyToAll( uint32 id, T &rep )
        {
            SFight *psfight = theFightDC.find( id );
            if ( NULL == psfight )
                return;

            for(std::map<uint32,uint32>::iterator iter = psfight->seqno_map.begin();
                iter != psfight->seqno_map.end();
                ++iter)
            {
                SUser *puser = theUserDC.find( iter->first );
                if( NULL == puser )
                    continue;
                bccopy( rep, puser->ext );
                local::write( local::access, rep );
            }
        }

} // namespace fight

#endif  //IMMORTAL_GAMESVR_FIGHTIMP_H_
