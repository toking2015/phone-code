#ifndef _GAMESVR_TOTEM_IMP_H_
#define _GAMESVR_TOTEM_IMP_H_

#include "common.h"
#include "proto/common.h"
#include "proto/fight.h"
#include "proto/user.h"
#include "proto/totem.h"
#include "fightextable_imp.h"
#include "resource/r_totemattrdata.h"
#include "resource/r_monsterfightconfext.h"
#include "dynamicmgr.h"

struct FindTotemByGuid
{
    uint32 m_guid;

    FindTotemByGuid(uint32 guid) : m_guid(guid) { }

    bool operator()(const STotem &totem)
    {
        return (totem.guid == m_guid);
    }
};

struct FindTotemById
{
    uint32 m_id;

    FindTotemById(uint32 id) : m_id(id) { }

    bool operator()(const STotem &totem)
    {
        return (totem.id == m_id);
    }
};

namespace totem
{
    void Add(SUser *user, uint32 totem_id, uint32 path); // 增加图腾
    void Activate(SUser *user, uint32 totem_id);
    void Del(SUser *user, uint32 totem_id, uint32 path);    //删除图腾
    void Bless(SUser *user, uint32 totem_guid, uint32 skill_type); // 技能祝福
    void Accelerate(SUser *user, uint32 totem_guid, bool is_free); // 冲能加速
    bool GetTotemExt(uint32 id, uint32 lv, SFightExtAble& able);
    void GetFightInfo(SUser *user, uint32 packet, uint32 guid, SFightSoldier &fight_soldier);
    void GetFightInfo(uint32 id, uint32 level, uint32 wake_lv, uint32 speed_lv, uint32 add_lv, SFightSoldier &fight_soldier);
    void ReplyTotemInfo(SUser *user);
    bool CheckTotem(SUser *user, uint32 guid);
    bool CheckTotemById(SUser *user, uint32 id);
    STotem* GetTotemById(SUser *user, uint32 id);
    uint32 GetTotemGuid(SUser *user);
    uint32 GetTotemLevelCount(SUser *user, uint32 level); // 获得星级大于等于level的图腾数量
    uint32 GetTotemTotalLevel(SUser *user); // 获得图腾总星级
    bool GetTotem(SUser *user, uint32 guid, STotem &totem);
    void AddTotemBuff(uint32 target_id, SFightPlayerInfo &play_info, uint32 packet);
}// namespace totem

#endif
