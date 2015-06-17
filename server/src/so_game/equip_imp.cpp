// 添加物品类型[板甲－布甲]
// item.xls的level代表一个阶的概念，而装备的等级放在每件装备上
// 相同id的装备有可能是不同品质的,所以要根据记录的quilty系数来倒推，
// 而且每件装备需要两个quality系数（主、副）
// 激活属性只针对当前装备
// 装备单件计算时取最高等级者计算
// 装备背包下子背包索引:
// equip_type * 100 + level
// 其中equip_type为甲类型[kEquipCloth-kEquipPlate],level为装备的阶，最高不超过100
// 装备背包子背包物品索引为[kItemEquipTypeHead-kItemEquipTypeFeet]
#include "equip_imp.h"
#include "item_imp.h"
#include "user_imp.h"
#include "soldier_imp.h"
#include "fight_imp.h"
#include "coin_imp.h"
#include "fightextable_event.h"
#include "local.h"
#include "user_util.h"
#include "netsingle.h"
#include "equip_event.h"
#include "item_event.h"
#include "misc.h"
#include "resource/r_itemext.h"
#include "resource/r_soldierext.h"
#include "resource/r_equipqualityext.h"
#include "resource/r_soldierequipmgr.h"
#include "resource/r_effectext.h"
#include "resource/r_oddext.h"
#include "resource/r_soldierqualityoccuext.h"
#include "resource/r_fixedequipext.h"
#include "resource/r_itemmergeext.h"
#include "resource/r_globalext.h"
#include "proto/soldier.h"
#include "proto/constant.h"
#include "proto/coin.h"
#include "log.h"
#include <math.h>

static void FightAbleLog(const char *from, SFightExtAble &able)
{
    LOG_DEBUG("[%s] hp: %u, physical_ack: %u, physical_def: %u, magic_ack: %u, magic_def: %u, speed: %u",
        from, able.hp, able.physical_ack, able.physical_def, able.magic_ack, able.magic_def, able.speed);
    LOG_DEBUG("critper: %u, critper_def: %u, crithurt: %u, crithurt_def: %u, hitper: %u, dodgeper: %u",
        able.critper, able.critper_def, able.crithurt, able.crithurt_def, able.hitper, able.dodgeper);
    LOG_DEBUG("parryper: %u, parryper_dec: %u, rage: %u, stun_def: %u, silent_def: %u, weak_def: %u, fire_def: %u",
        able.parryper, able.parryper_dec, able.rage, able.stun_def, able.silent_def, able.weak_def, able.fire_def);
}

// 先排等级，再排品质，较高者在前
static bool sort_suit(CEquipSuitData::SData *a, CEquipSuitData::SData *b)
{
    if (a->level > b->level)
        return true;
    else if (a->level < b->level)
        return false;

    // 等级相同再排品质
    if (a->quality > b->quality)
        return true;
    return false;
}

namespace equip
{

struct SEqualItemGuid
{
    uint32 guid;
    SEqualItemGuid(uint32 _guid) {guid = _guid;}
    bool operator () (const SUserItem& item)
    {
        return item.guid == guid;
    }
};

struct SEqualItemSoldierGuid
{
    uint32 guid;
    SEqualItemSoldierGuid(uint32 _guid) {guid = _guid;}
    bool operator () (const SUserItem& item)
    {
        return item.soldier_guid == guid;
    }
};


std::vector<uint16> GetRandList(uint16 beg, uint16 end, uint16 num)
{
    std::vector<uint16> ret;
    std::vector<uint16> num_list;
    for (uint16 i = beg; i < end + 1; i++)
        num_list.push_back(i);

    uint16 list_size = num_list.size();
    if (num >= list_size)
        return num_list;

    for (uint16 n = list_size; n > 0 && num > 0; n--, num--)
    {
        uint16 i = TRand((uint16)0, n);
        if (i >= list_size)
            continue;
        ret.push_back(num_list[i]);
        num_list[i] = num_list[n-1];
    }
    return ret;
}

uint32 AddFixed(SUser *user, uint32 item_id, uint32 quality, uint32 count, uint32 path)
{
    CFixedEquipData::SData *p_data = theFixedEquipExt.Find(item_id, quality);
    if (!p_data)
        return 0;
    return Add(user, quality, item_id, count, path, p_data->main_factor, p_data->slave_factor);
}

uint32 Add(SUser *user, uint32 quality, uint32 item_id, uint32 count, uint32 path, int32 main_attr_factor, int32 slave_attr_factor)
{
    SWildItem new_item;
    new_item.item_id = item_id;
    new_item.count = count;
    CEquipQualityData::SData *p_data = theEquipQualityExt.Find(quality);
    if (!p_data)
        return 0;
    if (main_attr_factor >= 0)
        new_item.main_attr_factor = main_attr_factor;
    else
        new_item.main_attr_factor = TRand(p_data->main_min, p_data->main_max + 1);

    if (slave_attr_factor >= 0)
        new_item.slave_attr_factor = slave_attr_factor;
    else
        new_item.slave_attr_factor = TRand(p_data->slave_min, p_data->slave_max + 1);

    uint32 slave_attr_num = p_data->slave_attr_num;
    CItemData::SData *p_item = theItemExt.Find(item_id);
    if (!p_item)
        return 0;
    slave_attr_num = slave_attr_num > p_item->slave_attrs.size() ? p_item->slave_attrs.size() : slave_attr_num;
    new_item.slave_attrs = GetRandList(1, p_item->slave_attrs.size(), slave_attr_num);
    new_item.slave_attrs.resize(kItemRandMax);
    LOG_DEBUG("AddEquip: user[%u], item_id[%u], quality[%u], main_attr_factor[%u], slave_attr_factor[%u], slave_attr_num[%u]",
            user->guid, item_id, quality, new_item.main_attr_factor, new_item.slave_attr_factor, slave_attr_num);

    // 删除缓存背包里旧的装备
    uint32 suit_bag = GetSubBag(p_item->equip_type, p_item->level);
    uint32 index = p_item->subclass;
    DelEquip(user, kBagFuncSoldierEquipTemp, suit_bag, index);

    uint32 guid = item::AddItemToBag(user, new_item, kBagFuncSoldierEquipTemp, path);

    // 自动替换高品质
    if (path != kPathMergeEquip)
    {
        ItemList &equip_list = user->data.item_map[kBagFuncSoldierEquip];
        ItemList::iterator iter = std::find_if(equip_list.begin(), equip_list.end(), Item_EqualItemIndexAndSoldier(index, suit_bag));
        if (iter != equip_list.end() && iter->main_attr_factor >= p_data->main_min)
            return guid;
        Replace(user, guid, true);
    }
    return guid;
}

// 装备背包下子背包索引
uint32 GetSubBag(uint32 equip_type, uint32 level)
{
    // 数值确保item的level不超过100
    return equip_type * 100 + level;
}

void Equip(SUser *user, S2UInt32 src)
{
    // 暂定只能从背包装备
    if (src.first != kBagFuncCommon)
        return;
    ItemList &src_list = user->data.item_map[src.first];
    ItemList::iterator src_iter = std::find_if(src_list.begin(), src_list.end(), SEqualItemGuid(src.second));
    if (src_iter == src_list.end())
        return;

    uint32 item_id = src_iter->item_id;
    CItemData::SData *p_item = theItemExt.Find(item_id);
    if (!p_item)
        return;

    // 非装备
    if (p_item->type != kItemTypeEquip)
        return;
    if (p_item->equip_type < kEquipCloth || p_item->equip_type > kEquipPlate)
        return;

    // 暂定未够等级的装备均可使用，只不过属性计算无效果
    uint32 suit_bag = GetSubBag(p_item->equip_type, p_item->level);
    uint32 index = p_item->subclass;
    S2UInt32 dst;
    dst.first = kBagFuncSoldierEquip;
    dst.second = index;
    item::MoveItem(user, src, dst, suit_bag);
    LOG_DEBUG("Equip: user[%u], src[%u:%u], dst[%u:%u]", user->guid, src.first, src.second, suit_bag, index);
    event::dispatch(SEventFightExtAbleAllUpdate(user, kPathSoldierEquip));
}

bool CheckEquipSkill(SUser *puser, uint32 soldier_guid)
{
    ItemList &src_list = puser->data.item_map[kBagFuncSoldierEquipSkill];

    ItemList::iterator src_iter = std::find_if(src_list.begin(), src_list.end(), SEqualItemSoldierGuid(soldier_guid));
    if (src_iter == src_list.end())
        return true;
    return false;
}

void EquipSkill(SUser *user, S2UInt32 src, uint32 soldier_guid)
{
    // 暂定只能从背包装备
    if (src.first != kBagFuncCommon)
        return;
    ItemList &src_list = user->data.item_map[src.first];
    ItemList::iterator src_iter = std::find_if(src_list.begin(), src_list.end(), SEqualItemGuid(src.second));
    if (src_iter == src_list.end())
        return;

    if (!CheckEquipSkill(user,soldier_guid) )
        return;

    uint32 item_id = src_iter->item_id;
    CItemData::SData *p_item = theItemExt.Find(item_id);
    if (!p_item)
        return;

    SUserSoldier soldier;
    soldier::GetSoldier(user, soldier_guid, soldier);
    CSoldierData::SData *psoldier_data = theSoldierExt.Find(soldier.soldier_id);
    if ( NULL == psoldier_data )
        return;
    CSoldierQualityOccuData::SData *poccu_data = theSoldierQualityOccuExt.Find( soldier.quality, psoldier_data->occupation );
    if ( NULL == poccu_data )
        return;

    if ( kCoinItem != poccu_data->cost.cate || item_id != poccu_data->cost.objid )
        return;

    // 暂定未够等级的装备均可使用，只不过属性计算无效果
    //如果物品超过1个那么先拆分
    if( src_iter->count > 1 )
    {
        src_iter->count--;
        item::ReplyItemSet(user, *src_iter, kObjectUpdate,kPathSoldierEquipSkill);

        SUserItem user_item = *src_iter;
        std::vector<SUserItem> &item_list = user->data.item_map[kBagFuncSoldierEquipSkill];
        user_item.item_index= item::GetIndex(item_list, kBagFuncSoldierEquipSkill );
        user_item.guid      = item::GetGuid( user );
        user_item.soldier_guid = soldier_guid;
        user_item.bag_type = kBagFuncSoldierEquipSkill;
        user_item.count     = 1;
        item_list.push_back(user_item);
        item::ReplyItemSet(user, user_item, kObjectAdd, kPathSoldierEquipSkill);
    }
    else
    {
        S2UInt32 dst;
        dst.first = kBagFuncSoldierEquipSkill;
        item::MoveItem(user, src, dst, soldier_guid);
    }
    event::dispatch(SEventFightExtAbleAllUpdate(user, kPathSoldierEquipSkill));

    PRItemEquipSkill rep;
    bccopy( rep, user->ext );
    local::write( local::access, rep );
}

CEquipSuitData::SData * FindSuitEquip(SUser *user, uint32 equip_type, uint32 soldier_level)
{
    uint32 select_level = GetSelectSuitLevel(user, equip_type);
    CEquipSuitData::UInt32EquipSuitVec suit_list = theEquipSuitMgr.FindSuits(equip_type, soldier_level, select_level);
    std::sort(suit_list.begin(), suit_list.end(), sort_suit);
    ItemList &equip_list = user->data.item_map[kBagFuncSoldierEquip];
    for (CEquipSuitData::UInt32EquipSuitVec::iterator iter = suit_list.begin();
        iter != suit_list.end();
        ++iter)
    {
        CEquipSuitData::SData *p_suit = *iter;
        int count = 0;
        uint32 suit_bag = GetSubBag(p_suit->equip_type, p_suit->level);
        for (ItemList::iterator equip_iter = equip_list.begin();
            equip_iter != equip_list.end();
            ++equip_iter)
        {
            if (equip_iter->soldier_guid != suit_bag)
                continue;
            uint32 quality = theEquipQualityExt.FactorToQuality(equip_iter->main_attr_factor);
            if (quality < p_suit->quality)
                continue;
            count++;
        }
        if (count >= 6)
            return p_suit;
    }
    return NULL;
}

ItemList::iterator FindMaxLevelEquip(ItemList &equip_list, uint32 equip_type, uint32 body_pos, uint32 soldier_level, uint32 select_level)
{
    ItemList::iterator ret_iter = equip_list.end();
    uint32 max_level = 0;
    for (ItemList::iterator iter = equip_list.begin();
        iter != equip_list.end();
        ++iter)
    {
        CItemData::SData *p_item = theItemExt.Find(iter->item_id);
        if (!p_item || p_item->equip_type != equip_type || p_item->subclass != body_pos || p_item->level > select_level)
            continue;
        if (p_item->limitlevel <= soldier_level && p_item->level > max_level)
        {
            max_level = p_item->level;
            ret_iter = iter;
        }
    }
    return ret_iter;
}

SFightExtAble GetFightExt(SUser *user, SUserSoldier &soldier, SFightExtAble &able)
{
    LOG_DEBUG("GetFightExt: user[%u], soldier[%u]", user->guid, soldier.soldier_id);
    CSoldierData::SData *p_soldier = theSoldierExt.Find(soldier.soldier_id);
    if (!p_soldier)
        return SFightExtAble();
    uint32 equip_type = p_soldier->equip_type;
    uint32 level = soldier.level;

    uint32 select_level = GetSelectSuitLevel(user, equip_type);
    ItemList &equip_list = user->data.item_map[kBagFuncSoldierEquip];
    // 单件装备
    SFightExtAble all_equip_able;
    for (uint32 i = kItemEquipTypeHead; i <= kItemEquipTypeFeet; i++)
    {
        ItemList::iterator iter = FindMaxLevelEquip(equip_list, equip_type, i, level, select_level);
        if (iter == equip_list.end())
            continue;
        CItemData::SData *p_item = theItemExt.Find(iter->item_id);
        if (!p_item)
            continue;

        SFightExtAble equip_able;
        LOG_DEBUG("body_pos[%u], item_id[%u]", i, iter->item_id);
        // 主属性
        uint32 main_attr_factor = iter->main_attr_factor;
        for (std::vector<S2UInt32>::iterator main_attr_iter = p_item->attrs.begin();
            main_attr_iter != p_item->attrs.end();
            ++main_attr_iter)
        {
            // first : effect_id, second : val
            uint32 value = main_attr_iter->second + (uint32)(main_attr_iter->second * main_attr_factor / 10000.0);
            SFightExtAble temp = theEffectExt.ToFightExtAble(main_attr_iter->first, able, value);
            FightAbleLog("main_attr", temp);
            equip_able = theEffectExt.AddFightExtAble(equip_able, temp);
        }

        // 副属性
        uint32 slave_attr_factor = iter->slave_attr_factor;
        uint16 slave_attrs_size = p_item->slave_attrs.size();
        for (std::vector<uint16>::iterator slave_attr_iter = iter->slave_attrs.begin();
            slave_attr_iter != iter->slave_attrs.end();
            ++slave_attr_iter)
        {
            // slave_attr_iter为副属性在item.xls中的下标
            if (*slave_attr_iter == 0 || *slave_attr_iter > slave_attrs_size)
                continue;
            uint16 index = *slave_attr_iter - 1;
            S2UInt32 &effect = p_item->slave_attrs[index];
            // first : effect_id, second : val
            uint32 value = effect.second + (uint32)(effect.second * slave_attr_factor / 10000.0);
            SFightExtAble temp = theEffectExt.ToFightExtAble(effect.first, able, value);
            FightAbleLog("slave_attr", temp);
            equip_able = theEffectExt.AddFightExtAble(equip_able, temp);
        }

        // 额外属性
        FightAbleLog("before_soldier_effect", equip_able);
        CSoldierEquipData::SData *p_equip = theSoldierEquipMgr.Find(soldier.soldier_id, iter->item_id);
        if (!p_equip)
            continue;
        for (std::vector<S2UInt32>::iterator effect_iter = p_equip->effects.begin();
            effect_iter != p_equip->effects.end();
            ++effect_iter)
        {
            // first : effect_id, second : val
            SFightExtAble temp = theEffectExt.ToFightExtAble(effect_iter->first, equip_able, effect_iter->second);
            equip_able = theEffectExt.AddFightExtAble(equip_able, temp);
        }
        FightAbleLog("final_albe", equip_able);
        all_equip_able = theEffectExt.AddFightExtAble(all_equip_able, equip_able);
    }
    return all_equip_able;
}

SFightExtAble GetFightExtSkill(SUser *user, SUserSoldier &soldier, SFightExtAble &able)
{
    SFightExtAble extra_able;
    CSoldierData::SData *psoldier = theSoldierExt.Find(soldier.soldier_id);
    if (!psoldier)
        return extra_able;

    ItemList &equip_list = user->data.item_map[kBagFuncSoldierEquipSkill];

    ItemList::iterator src_iter = std::find_if(equip_list.begin(), equip_list.end(), SEqualItemSoldierGuid(soldier.guid));
    if (src_iter == equip_list.end())
        return extra_able;

    CSoldierQualityOccuData::SData *poccu_data = theSoldierQualityOccuExt.Find( soldier.quality, psoldier->occupation );
    if ( NULL == poccu_data )
        return extra_able;
    if ( kCoinItem != poccu_data->cost.cate )
        return extra_able;

    CItemData::SData *p_itemdata = theItemExt.Find(poccu_data->cost.objid);
    if (NULL == p_itemdata)
        return extra_able;

    for (std::vector<S2UInt32>::iterator jter = p_itemdata->attrs.begin();
        jter != p_itemdata->attrs.end();
        ++jter )
    {
        SFightExtAble temp = theEffectExt.ToFightExtAble(jter->first, able, jter->second);
        extra_able = theEffectExt.AddFightExtAble(extra_able, temp);
    }

    return extra_able;
}


void AddOdd(SUser *user, SUserSoldier &soldier, std::vector<SFightOdd> &odd_list)
{
    CSoldierData::SData *p_soldier = theSoldierExt.Find(soldier.soldier_id);
    if (!p_soldier)
        return;
    // 套装战斗加成
    CEquipSuitData::SData *p_max_suit = FindSuitEquip(user, p_soldier->equip_type, soldier.level);
    if (!p_max_suit)
        return;
    LOG_DEBUG("AddOdd: user[%u], soldier[%u], suit_level[%u], suit_quality[%u]",
            user->guid, soldier.soldier_id, p_max_suit->level, p_max_suit->quality);
    for (uint32 quality = p_max_suit->quality; quality >= kQualityWhite; quality--)
    {
        CEquipSuitData::SData *p_suit = theEquipSuitMgr.Find(p_max_suit->equip_type, p_max_suit->level, quality);
        if (!p_suit)
            continue;
        for (std::vector<S2UInt32>::iterator iter = p_suit->odds.begin();
            iter != p_suit->odds.end();
            ++iter)
        {
            // first : odd_id, second : odd_level
            COddData::SData *odd_data = theOddExt.Find(iter->first, iter->second);
            if (!odd_data)
                continue;
            SFightOdd odd;
            fight::CreateFightOdd(odd_data,odd);
            odd_list.push_back(odd);
        }
    }
}

void DelEquip(SUser *p_user, uint32 bag, uint32 suit_bag, uint32 index)
{
    item::DelItem(p_user, bag, suit_bag, index, kPathEquipReplace);
}

bool Replace(SUser *p_user, uint32 equip_guid, bool is_replace)
{
    // 暂定只能从背包装备
    ItemList &src_list = p_user->data.item_map[kBagFuncSoldierEquipTemp];
    ItemList::iterator src_iter = std::find_if(src_list.begin(), src_list.end(), SEqualItemGuid(equip_guid));
    if (src_iter == src_list.end())
        return false;
    if (!is_replace)
    {
        S2UInt32 src_item;
        src_item.first = kBagFuncSoldierEquipTemp;
        src_item.second = src_iter->guid;
        item::DelItemByGuid(p_user, src_item, src_iter->count, kPathEquipReplace);
        return true;
    }

    uint32 item_id = src_iter->item_id;
    CItemData::SData *p_item = theItemExt.Find(item_id);
    if (!p_item)
        return false;

    // 非装备
    if (p_item->type != kItemTypeEquip)
        return false;
    if (p_item->equip_type < kEquipCloth || p_item->equip_type > kEquipPlate)
        return false;

    // 暂定未够等级的装备均可使用，只不过属性计算无效果
    uint32 suit_bag = GetSubBag(p_item->equip_type, p_item->level);
    uint32 index = p_item->subclass;

    // 删除装备背包里旧的装备
    DelEquip(p_user, kBagFuncSoldierEquip, suit_bag, index);

    // 将新的装备放到装备背包
    S2UInt32 src;
    src.first = kBagFuncSoldierEquipTemp;
    src.second = equip_guid;
    S2UInt32 dst;
    dst.first = kBagFuncSoldierEquip;
    dst.second = index;
    item::MoveItem(p_user, src, dst, suit_bag);

    // 更新系别评分
    UpdateGrade(p_user, p_item->equip_type, p_item->level);

    LOG_DEBUG("EquipReplace: user[%u], src[%u:%u], dst[%u:%u]", p_user->guid, src.first, src.second, suit_bag, index);
    event::dispatch(SEventFightExtAbleAllUpdate(p_user, kPathSoldierEquip));
    return true;
}

void SelectSuit(SUser *p_user, uint32 equip_type, uint32 level)
{
    if (equip_type == 0 || equip_type > p_user->data.equip_suit_level.size())
        return;
    p_user->data.equip_suit_level[equip_type - 1] = level;
    ReplyEquipSuits(p_user);
    event::dispatch(SEventFightExtAbleAllUpdate(p_user, kPathEquipSelect));
}

uint32 GetSelectSuitLevel(SUser *user, uint32 equip_type)
{
    if (equip_type == 0 || equip_type > user->data.equip_suit_level.size() )
        return 0;

    return user->data.equip_suit_level[equip_type - 1];
}

void ReplyEquipSuits(SUser *p_user)
{
    PREquipSelectSuits rep;
    rep.select_suits = p_user->data.equip_suit_level;
    bccopy(rep, p_user->ext);
    local::write(local::access, rep);
}

void UpdateGrade(SUser *p_user, uint32 equip_type, uint32 level)
{
    if (equip_type < kEquipCloth || equip_type > kEquipPlate)
        return;
    ItemList &equip_list = p_user->data.item_map[kBagFuncSoldierEquip];

    uint32 suit_bag = GetSubBag(equip_type, level);
    uint32 sum = 0;
    for (ItemList::iterator iter = equip_list.begin();
        iter != equip_list.end();
        ++iter)
    {
        if (iter->soldier_guid != suit_bag)
            continue;

        uint32 main_factor = iter->main_attr_factor;
        uint32 slave_factor = iter->slave_attr_factor;
        uint32 a = theGlobalExt.get<uint32>("equip_grade_a");
        uint32 b = theGlobalExt.get<uint32>("equip_grade_b");
        uint32 c = theGlobalExt.get<uint32>("equip_grade_c");
        // 装备评分=round((13333+主属性品质系数+副属性品质系数/3)*a/10000*(装备阶数^(c/100)+b/100))
        uint32 grade = (uint32)((13333 + main_factor + slave_factor / 3.0) * a / 10000.0 * (pow(level, c / 100.0) + b / 100.0));
        sum += grade;
    }

    EquipGradeList::iterator iter = FindGradeIter(p_user->data.equip_grade_list, equip_type, level);
    if (iter == p_user->data.equip_grade_list.end()) {
        SUserEquipGrade obj;
        obj.equip_type = equip_type;
        obj.level = level;
        obj.grade = sum;
        p_user->data.equip_grade_list.push_back(obj);
    } else {
        iter->grade = sum;
    }
    event::dispatch(SEventEquipGradeUpdate(p_user, kPathEquipReplace, equip_type, level));
}

EquipGradeList::iterator FindGradeIter(EquipGradeList &gl, uint32 equip_type, uint32 level)
{
    for (EquipGradeList::iterator iter = gl.begin();
        iter != gl.end();
        ++iter)
    {
        if (iter->equip_type == equip_type && iter->level == level)
            return iter;
    }
    return gl.end();
}

uint32 GetEquipGrade(SUser *p_user, uint32 equip_type, uint32 level)
{
    EquipGradeList::iterator iter = FindGradeIter(p_user->data.equip_grade_list, equip_type, level);
    if (iter == p_user->data.equip_grade_list.end())
        return 0;
    return iter->grade;
}

uint32 GetMaxGrade( SUser *puser, uint32 &equip_type, uint32 &equip_level )
{
    uint32 max_grade = 0;
    for( EquipGradeList::iterator iter = puser->data.equip_grade_list.begin();
        iter != puser->data.equip_grade_list.end();
        ++iter )
    {
        if( max_grade < iter->grade )
        {
            max_grade   = iter->grade;
            equip_type  = iter->equip_type;
            equip_level = iter->level;
        }
    }
    return max_grade;
}

uint32 CountEquipSuit(SUser *p_user, uint32 quality)
{
    quality += 20;
    CEquipQualityData::SData *p_data = theEquipQualityExt.Find(quality);
    if (!p_data)
        return 0;

    std::map<uint32, uint32> suits;
    ItemList &equip_list = p_user->data.item_map[kBagFuncSoldierEquip];
    for (ItemList::iterator iter = equip_list.begin();
        iter != equip_list.end();
        ++iter)
    {
        if (iter->main_attr_factor >= p_data->main_min)
            suits[iter->soldier_guid] += 1;
    }

    uint32 sum = 0;
    for (std::map<uint32, uint32>::iterator iter = suits.begin();
        iter != suits.end();
        ++iter)
    {
        if (iter->second >= 6)
            sum++;
    }
    return sum;
}

bool FixedMerge( SUser *user, uint32 id )
{
    CItemMergeData::SData *pitemmerge = theItemMergeExt.Find(id);
    if (!pitemmerge)
        return false;

    if ( user->data.simple.team_level < pitemmerge->limit_level )
        return false;

    if (coin::check_take(user, pitemmerge->materials) != 0)
        return false;

    uint32 item_id = pitemmerge->item_id;
    uint32 quality = theGlobalExt.get<uint32>("equip_merge_first_quality");
    if (AddFixed(user, item_id, quality, 1, kPathMergeEquip) == 0)
        return false;

    std::vector<S3UInt32> coins;
    coins.push_back(coin::create(quality, item_id, 1));
    event::dispatch(SEventItemMerge(user, kPathMergeEquip, id, coins));
    item::ReplyMerge(user, id, 1);
    return true;
}

void GetEquipSuit(SUser *p_user, uint32 equip_type, uint32 level, ItemList &suit)
{
    uint32 suit_bag = GetSubBag(equip_type, level);
    ItemList &equip_list = p_user->data.item_map[kBagFuncSoldierEquip];
    for (ItemList::iterator iter = equip_list.begin();
        iter != equip_list.end();
        ++iter)
    {
        if (iter->soldier_guid != suit_bag)
            continue;
        suit.push_back(*iter);
    }
}

} // namespace equip
