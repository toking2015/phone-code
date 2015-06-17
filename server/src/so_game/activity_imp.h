#ifndef _IMMORTAL_GAMESVR_ACTIVITYLOGIC_H_
#define _IMMORTAL_GAMESVR_ACTIVITYLOGIC_H_

#include "common.h"
#include "proto/user.h"
#include "proto/activity.h"

/*
 用于宏观控制活动入口
 1) 实现单个用户活动刷新回调
 2) 集中对所有活动的刷新时间表进行管理
 3) 支持活动时间动态更新
 4) 支持活动动态开启
 */
namespace activity
{
    void    LoadReward( std::vector< SActivityReward > &list );
    void    LoadFactor( std::vector< SActivityFactor > &list );
    void    LoadOpen( std::vector< SActivityOpen > &list );
    void    LoadData( std::vector< SActivityData > &list );

    bool    CheckReward( SActivityReward &reward);
    bool    CheckFactor( SActivityFactor &factor );
    bool    CheckOpen( SActivityOpen &open );
    bool    CheckData( SActivityData &data );


    //void    OpenSet( uint32 guid, uint32 type, SActivityOpen &open );
    //void    DataSet( uint32 guid, uint32 type, SActivityData &data );

    void    ReplyActivityList( SUser* user );
    void    ReplyActivityInfoList( SUser* user );


    typedef std::pair< uint32, uint32 > SBound;

    std::string time_key( const std::string& name );
    uint32 activity_open_time_to_uint( const char* timestr );

    //设置指定活动玩家个人有效时间范转
    //void    SetPersonalBound( SUser* user, std::string& name, uint32 begin_time, uint32 end_time );
    //SBound  GetPersonalBound( SUser* user, std::string& name );

    SBound  GetActivityBound( SUser* user, std::string &name, uint32 time );
    bool    IsActivityOpen( SUser* user, std::string &name );

    void    Process( SUser* user );

    void    split(std::string& s, std::string& delim,std::vector< std::string > &list);


    //领取奖励
    void    TakeReward( SUser* user, uint32  open_guid, uint32 index );
    //检测活动条件是否达成
    bool    CheckActivityData( SUser* user, uint32 open_guid, uint32 index );
    //发放奖励
    bool    SendReward( SUser* user, uint32 data_guid, uint32 index );


    //更新活动达成值 如果：首充，累积充值
    void    ActivityCheak( SUser* user, uint32 &value, const uint32 type );
    void    ClearVar( SUser* user, std::string & activity_name );
} // namespace activity

#endif

