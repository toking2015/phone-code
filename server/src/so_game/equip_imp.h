#ifndef _GAMESVR_EQUIP_LOGIC_H_
#define _GAMESVR_EQUIP_LOGIC_H_

#include "common.h"
#include "dynamicmgr.h"
#include "proto/user.h"
#include "proto/item.h"
#include "proto/equip.h"
#include "resource/r_equipsuitmgr.h"

namespace equip
{
    typedef std::vector<SUserItem> ItemList;
    typedef std::vector<SUserEquipGrade> EquipGradeList;

    // 从beg到end的连续数段中产生不重复的num个数，用于产生副属性列表
    std::vector<uint16> GetRandList(uint16 beg, uint16 end, uint16 num);
    // 添加固定系数（填在FixedEquip.xls）的装备
    uint32 AddFixed(SUser *user, uint32 item_id, uint32 quality, uint32 count, uint32 path);
    // 添加
    uint32 Add(SUser *user, uint32 quality, uint32 item_id, uint32 count, uint32 path, int32 main_attr_factor = -1, int32 slave_attr_factor = -1);

    // 通过equip_type和level获取装备背包下子背包（xx甲xx套）索引
    uint32 GetSubBag(uint32 equip_type, uint32 level);

    // 穿戴
    void Equip(SUser *user, S2UInt32 src);
    //检查是否能穿戴
    bool CheckEquipSkill(SUser *puser, uint32 guid );
    //穿戴技能书
    void EquipSkill(SUser *user, S2UInt32 src, uint32 soldier_guid);

    // 替换
    bool Replace(SUser *p_user, uint32 equip_guid, bool is_replace);
    void DelEquip(SUser *p_user, uint32 bag, uint32 suit_bag, uint32 index);

    // 选择类型为equip_type生效的套装等级
    void SelectSuit(SUser *p_user, uint32 equip_type, uint32 level);
    uint32 GetSelectSuitLevel(SUser *user, uint32 equip_type);
    void ReplyEquipSuits(SUser *p_user);

    // 找到soldier_level等级的武将拥有的最高等级的类型为equip_type的套装
    CEquipSuitData::SData * FindSuitEquip(SUser *user, uint32 equip_type, uint32 soldier_level);

    // 找到soldier_level等级的武将可穿戴胡最高等级的equp_type类型的body_pos部位装备
    ItemList::iterator FindMaxLevelEquip(ItemList &equip_list, uint32 equip_type, uint32 body_pos, uint32 soldier_level, uint32 select_level);

    // 获取装备二级属性
    SFightExtAble GetFightExt(SUser *user, SUserSoldier &soldier, SFightExtAble &able);
    SFightExtAble GetFightExtSkill(SUser *user, SUserSoldier &soldier, SFightExtAble &able);
    // 获取装备odd
    void AddOdd(SUser *user, SUserSoldier &soldier, std::vector<SFightOdd> &odd_list);

    // 更新系别评分
    void UpdateGrade(SUser *p_user, uint32 equip_type, uint32 level);
    // 获取系别评分
    uint32 GetEquipGrade(SUser *p_user, uint32 equip_type, uint32 level);
    EquipGradeList::iterator FindGradeIter(EquipGradeList &gl, uint32 equip_type, uint32 level);

    // 获取套装
    void GetEquipSuit(SUser *p_user, uint32 equip_type, uint32 level, ItemList &suit);

    //获取最高评分
    uint32 GetMaxGrade( SUser *puser, uint32 &equip_type, uint32 &equip_level );

    //统计quality品质（或以上）的套装的数量
    uint32 CountEquipSuit(SUser *p_user, uint32 quality);

    // 固定合成
    bool FixedMerge( SUser *user, uint32 id );

}// namespace equip

#endif
