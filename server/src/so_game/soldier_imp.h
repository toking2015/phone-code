#ifndef _GAMESVR_SOLDIER_IMP_H_
#define _GAMESVR_SOLDIER_IMP_H_

#include "common.h"
#include "proto/user.h"
#include "proto/soldier.h"
#include "proto/fight.h"

/*
 * 武将功能:
 * 1.常规接口: 列表/添加/删除/移动
 */

#define MacroCheckSoldierGuid(soldier)\
    std::map< uint32, SUserSoldier >& soldier_map = puser->data.soldier_map[ (soldier).first ];\
    std::map< uint32, SUserSoldier >::iterator soldier_iter = soldier_map.find( (soldier).second );\
    if (soldier_map.end() == soldier_iter)\
    {\
        HandleErrCode(puser, kErrSoldierGuidNotExist, 0);\
        return;\
    }

#define MacorCheckSoldierId(psoldier, soldier_id)\
    CSoldierData::SData* psoldier = theSoldierExt.Find(soldier_id);\
    if (!psoldier)\
    {\
        HandleErrCode(puser, kErrSoldierDataNotExist, soldier_id);\
        return;\
    }

namespace soldier
{
    typedef std::vector<SUserItem> ItemList;
    //取可用索引
    uint16  GetIndex( std::map< uint32, SUserSoldier >& soldier_map );
    //取可用GUID
    uint32  GetGuid( SUser *puser );
    //是否存在这个id 存在返回true
    bool    CheckSoldier( SUser *puser, uint32 soldier_id );
    //是否存在这个guid 存在返回true
    bool    CheckSoldierGuid( SUser *puser, uint32 guid );
    uint32 GetSoldierStar(SUser *user, uint32 soldier_id);

    //回复收编武将列表
    void    ReplyList(SUser* puser, uint32 soldier_type);
    //添加
    void    Add(SUser* puser, uint32 soldier_id, uint32 path, uint32 count = 1 );
    void    ReplySet(SUser* puser, SUserSoldier &soldier, uint32 set_type, uint32 path );
    //删除
    void    TakeGuid(SUser* puser, S2UInt32 soldier, uint32 path);
    void    TakeId(SUser* puser, uint32 soldier_id, uint32 path, uint32 count = 0xffffffff );
    //移动
    void    Move(SUser* puser, S2UInt32 soldier, S2UInt32 index, uint32 path );
    void    AddQualityXp(SUser* puser, S2UInt32 soldier, std::vector<S3UInt32>& coin_list );
    bool    GetSoldierBaseExt(SUser* user, S2UInt32 soldier, SFightExtAble& able);
    bool    GetBaseExt(SUser* user, S2UInt32 soldier, SFightExtAble& able);
    SFightExtAble GetQualityExt(SUser* puser, S2UInt32 soldier, SFightExtAble& able);
    bool    GetSoldierExt(SUser* user, S2UInt32 soldier, SFightExtAble& able);

    bool    GetSoldier(SUser *puser, uint32 guid, SUserSoldier &soldier, uint32 kType = kSoldierTypeCommon );
    void    GetSoldierSkill(SUser *puser, uint32 guid, uint32 soldier_type, std::vector<SFightSkill> &skill_list );
    void    GetSoldierOdd(SUser *puser, uint32 guid, uint32 soldier_type, uint32 index, std::vector<SFightOdd> &odd_list );
    uint32  GetSkillPoint(SUser *puser, S2UInt32 soldier );
    uint32  GetSkillPointMax(SUser *puser, S2UInt32 soldier );
    uint32  GetSoldierRage(SUser *puser, uint32 guid);
    uint32  GetSoldierCountByQuality(SUser *puser, uint32 quality);
    uint32  GetSoldierCount(SUser *puser);
    uint32  GetSoldierStar(SUser *puser);
    //品质升级
    void    QualityUp(SUser* puser, S2UInt32 soldier);
    void    QualityUp(SUser* puser);
    //等级升级
    void    LvUp(SUser* puser, S2UInt32 soldier);
    //等级跟着主角走
    void    LvUpToTeam(SUser* puser);
    //星级升级
    void    StarUp(SUser* puser, S2UInt32 soldier);
    //武将招募
    void    Recruit(SUser* puser, uint32 id );
    //武将装备
    void    Equip(SUser* puser, S2UInt32 soldier, S2UInt32 item );
    //武将技能重置
    void    SkillReset(SUser* puser, S2UInt32 soldier );
    //武将技能升级
    void    SkillLvUp(SUser* puser, S2UInt32 soldier, uint32 skill_id);
    //获得武将的类型
    bool    GetSoldierOccu(SUser *puser, uint32 guid, uint32 &occu );
    //获取武将装备属性
    void    ReplySoldierEquipExt(SUser *puser, S2UInt32 soldier );

    //获取武奖数量(星级及以上)
    uint32  GetSoldierCountByStar( SUser *puser, uint32 star );

    //直接修改传进来的coins 所以别传静态数据
    std::vector<S3UInt32> ChangeSoldierToOther( SUser *puser, std::vector<S3UInt32> &coins );
    std::vector<std::vector<S3UInt32> > ChangeSoldierToOther( SUser *puser, std::vector<std::vector<S3UInt32> > &coins );

}// namespace soldier

#endif  //IMMORTAL_GAMESVR_SOLDIER_IMP_H_
