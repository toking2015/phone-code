#ifndef _SUserData_H_
#define _SUserData_H_

#include <weedong/core/seq/seq.h>
#include <proto/user/SUserSimple.h>
#include <proto/user/SUserOther.h>
#include <proto/team/STeamInfo.h>
#include <proto/user/SUserInfo.h>
#include <proto/user/SUserProtect.h>
#include <proto/coin/SUserCoin.h>
#include <proto/copy/SUserCopy.h>
#include <proto/star/SUserStar.h>
#include <proto/gut/SGutInfo.h>
#include <proto/copy/SCopyMopup.h>
#include <proto/friend/SUserFriend.h>
#include <proto/friend/SFriendLimit.h>
#include <proto/mail/SUserMail.h>
#include <proto/item/SUserItem.h>
#include <proto/formation/SUserFormation.h>
#include <proto/fightextable/SFightExtAbleInfo.h>
#include <proto/soldier/SUserSoldier.h>
#include <proto/building/SUserBuilding.h>
#include <proto/copy/SCopyLog.h>
#include <proto/copy/SAreaLog.h>
#include <proto/shop/SUserShopLog.h>
#include <proto/totem/STotemInfo.h>
#include <proto/task/SUserTask.h>
#include <proto/task/SUserTaskLog.h>
#include <proto/task/SUserTaskDay.h>
#include <proto/sign/SSignInfo.h>
#include <proto/altar/SAltarInfo.h>
#include <proto/pay/SUserPay.h>
#include <proto/pay/SUserPayInfo.h>
#include <proto/paper/SUserCopyMaterial.h>
#include <proto/shop/SUserMysteryGoods.h>
#include <proto/var/SUserVar.h>
#include <proto/trial/SUserTrial.h>
#include <proto/trial/SUserTrialReward.h>
#include <proto/tomb/SUserTomb.h>
#include <proto/tomb/STombTarget.h>
#include <proto/market/SMarketLog.h>
#include <proto/temple/STempleInfo.h>
#include <proto/viptimelimitshop/SUserVipTimeLimitGoods.h>
#include <proto/equip/SUserEquipGrade.h>
#include <proto/bias/SUserBias.h>

/*用户存储数据库的所有数据结构*/
class SUserData : public wd::CSeq
{
public:
    SUserSimple simple;
    SUserOther other;
    STeamInfo team;    //战队信息
    SUserInfo info;
    SUserProtect protect;
    SUserCoin coin;    //货币信息
    SUserCopy copy;    //当前副本信息
    SUserStar star;    //星星总数
    SGutInfo gut;    //当前剧情信息
    SCopyMopup mopup;    //扫荡信息
    std::map< uint32, SUserFriend > friend_map;    //好友列表
    std::map< uint32, SFriendLimit > friend_limit_map;    //好友赠送限制
    std::map< uint32, SUserMail > mail_map;    //邮件列表
    std::map< uint32, std::vector< SUserItem > > item_map;    //物品列表
    std::map< uint32, std::vector< SUserFormation > > formation_map;    //玩家阵型
    std::map< uint32, std::vector< SFightExtAbleInfo > > fightextable_map;    //战斗属性
    std::map< uint32, std::map< uint32, SUserSoldier > > soldier_map;    //武将列表
    std::vector< SUserBuilding > building_list;    //建筑群
    std::map< uint32, SCopyLog > copy_log_map;    //副本通关列表
    std::map< uint32, SAreaLog > area_log_map;    //副本区域通关列表
    std::vector< SUserShopLog > shop_log;    //商店购买记录
    std::map< uint32, STotemInfo > totem_map;    //图腾信息列表
    std::map< uint32, SUserTask > task_map;    //任务列表
    std::map< uint32, SUserTaskLog > task_log_map;    //任务记录列表
    std::map< uint32, SUserTaskDay > task_day_map;    //日常任务列表
    SSignInfo sign_info;    //签到信息
    SAltarInfo altar_info;    //祭坛信息
    std::vector< SUserPay > pay_list;    //充值List
    SUserPayInfo pay_info;    //充值信息
    std::vector< SUserCopyMaterial > copy_material_list;    //副本原料
    std::vector< SUserMysteryGoods > mystery_goods_list;    //神秘商店商品列表
    std::map< std::string, SUserVar > var_map;    //key-value
    std::map< uint32, SUserTrial > trial_map;    //试炼
    std::map< uint32, std::vector< SUserTrialReward > > trial_reward_map;    //试炼奖励
    SUserTomb tomb_info;    //墓地信息
    std::vector< STombTarget > tomb_target_list;    //对战信息
    std::vector< SMarketLog > market_log;    //拍卖行交易记录
    std::vector< uint32 > equip_suit_level;    //装备套装生效等级
    STempleInfo temple;    //神殿
    std::vector< SUserVipTimeLimitGoods > viptimelimit_goods_list;    //vip限时商店商品列表
    std::vector< SUserEquipGrade > equip_grade_list;    //装备系别评分
    std::map< uint32, SUserBias > bias_map;    //偏向性掉落数据
    std::vector< uint32 > day_task_reward_list;    //日常任务积分已领奖励列表

    SUserData()
    {
    }

    virtual ~SUserData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserData(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType eType, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( simple, eType, stream, uiSize )
            && TFVarTypeProcess( other, eType, stream, uiSize )
            && TFVarTypeProcess( team, eType, stream, uiSize )
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && TFVarTypeProcess( protect, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && TFVarTypeProcess( copy, eType, stream, uiSize )
            && TFVarTypeProcess( star, eType, stream, uiSize )
            && TFVarTypeProcess( gut, eType, stream, uiSize )
            && TFVarTypeProcess( mopup, eType, stream, uiSize )
            && TFVarTypeProcess( friend_map, eType, stream, uiSize )
            && TFVarTypeProcess( friend_limit_map, eType, stream, uiSize )
            && TFVarTypeProcess( mail_map, eType, stream, uiSize )
            && TFVarTypeProcess( item_map, eType, stream, uiSize )
            && TFVarTypeProcess( formation_map, eType, stream, uiSize )
            && TFVarTypeProcess( fightextable_map, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_map, eType, stream, uiSize )
            && TFVarTypeProcess( building_list, eType, stream, uiSize )
            && TFVarTypeProcess( copy_log_map, eType, stream, uiSize )
            && TFVarTypeProcess( area_log_map, eType, stream, uiSize )
            && TFVarTypeProcess( shop_log, eType, stream, uiSize )
            && TFVarTypeProcess( totem_map, eType, stream, uiSize )
            && TFVarTypeProcess( task_map, eType, stream, uiSize )
            && TFVarTypeProcess( task_log_map, eType, stream, uiSize )
            && TFVarTypeProcess( task_day_map, eType, stream, uiSize )
            && TFVarTypeProcess( sign_info, eType, stream, uiSize )
            && TFVarTypeProcess( altar_info, eType, stream, uiSize )
            && TFVarTypeProcess( pay_list, eType, stream, uiSize )
            && TFVarTypeProcess( pay_info, eType, stream, uiSize )
            && TFVarTypeProcess( copy_material_list, eType, stream, uiSize )
            && TFVarTypeProcess( mystery_goods_list, eType, stream, uiSize )
            && TFVarTypeProcess( var_map, eType, stream, uiSize )
            && TFVarTypeProcess( trial_map, eType, stream, uiSize )
            && TFVarTypeProcess( trial_reward_map, eType, stream, uiSize )
            && TFVarTypeProcess( tomb_info, eType, stream, uiSize )
            && TFVarTypeProcess( tomb_target_list, eType, stream, uiSize )
            && TFVarTypeProcess( market_log, eType, stream, uiSize )
            && TFVarTypeProcess( equip_suit_level, eType, stream, uiSize )
            && TFVarTypeProcess( temple, eType, stream, uiSize )
            && TFVarTypeProcess( viptimelimit_goods_list, eType, stream, uiSize )
            && TFVarTypeProcess( equip_grade_list, eType, stream, uiSize )
            && TFVarTypeProcess( bias_map, eType, stream, uiSize )
            && TFVarTypeProcess( day_task_reward_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserData";
    }
};

#endif
