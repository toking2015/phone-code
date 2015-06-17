#ifndef IMMORTAL_GAMESVR_SINGLEARENAIMP_H_
#define IMMORTAL_GAMESVR_SINGLEARENAIMP_H_

#include "common.h"
#include "proto/formation.h"
#include "proto/user.h"
#include "proto/singlearena.h"
#include "local.h"
/*
 * 竞技场功能:
 * 1.常规接口:
 */

#define REAL_TARGET_GUID 1000000
#define MAX_CREATE_OPPONENT 10000
#define SHOW_RANK_COUNT 50
#define SHOW_LOG_COUNT 5

namespace singlearena
{
    //检测竞技场是否开放
    bool IsOpenSingleArena( SUser* puser );

    //获取布阵信息
    void GetFormation( uint32 rank, std::vector<SUserFormation>& formation_list );

    //检测是否可以刷新
    bool    CheckRefresh( SUser* puser );

    //刷新对手
    void    Refresh( SUser* puser );

    //重置免费刷新对手
    void    ResetRefresh( SUser* puser );

    //返回挑战CD
    void    ReplyCD( SUser* puser );

    //清除挑战CD
    void    ClearCD( SUser* puser );

    //增加挑战次数
    void    AddTimes( SUser* puser );

    //返回个人信息
    void    ReplyInfo( SUser* puser );

    //返回对手信息
    void    ReplyOpponent( SUser* puser );

    //增加战斗log
    void    AddLog( uint32 guid, uint32 fight_id, uint32 target_id, uint32 win_flag );

    //更新名次
    void    UpdateRank( uint32 guid, uint32 target_id, uint32 win_flag );

    //返回战斗log
    void    ReplyLog( SUser* puser );

    //生成四个对手
    void    RandOpponent( SUser* puser );

    //创建对手
    SSingleArenaOpponent    CreateOpponent( uint32 rank );

    //匹配对手的排名
    void    GetRank( uint32 rank, uint32 &rank_one, uint32 &rank_two, uint32 &three, uint32 &four );
    uint32  GetOpponentRank( uint32 one, int32 two, uint32 first, uint32 second );

    void    CreateRank();
    void    LoadData( std::vector< SSingleArenaOpponent >& list );
    void    LoadLog( std::vector< SSingleArenaLog >& list );

    void    SaveDataToDB( SSingleArenaOpponent &data, uint8 set_type );
    void    SaveLogToDB( uint32 target_id, std::vector< SSingleArenaOpponent > &list );

    void    ReplyRank( SUser* puser, uint32 index, uint32 count );
    void    ReplyMyRank( SUser* puser );

    //设置info的基本信息(基本类型属性)
    void    SetInfoBase( SUser *puser, SSingleArenaInfo *info );
    //设置info的对手
    void    SetInfoOpp( SUser *puser, SSingleArenaInfo *info );

    //检测CD
    bool    CheckCD( SUser* puser );
    void    SetCD( SUser* puser );

    //检测挑战次数
    bool    CheckTimes( SUser* puser );
    void    SetTimes( SUser* puser );

    //每日19点结算
    void    SendDayReward( SSingleArenaOpponent *opp );
    //战胜奖励
    void    SendBattleReward( uint32 guid, uint32 target_id, uint32 win_flag );

    void    TimeLimit( SUser* puser );

    void    CheackFirstRank( uint32 rank, uint32 &rank_s, uint32 rank_1, uint32 rank_2, uint32 rank_3 );

    void    SaveYesterday( SUser* puser, bool fresh_fromation = true );

    //检测对手排名是否变动
    bool    CheckRank( SUser* puser, uint32 target_id, uint8 flag );

    //首胜
    bool    GetFirstReward( SUser *puser );
} // namespace singlearena

#endif  //IMMORTAL_GAMESVR_SINGLEARENAIMP_H_
