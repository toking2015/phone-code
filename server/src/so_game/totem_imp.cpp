#include "pro.h"
#include "log.h"
#include "misc.h"
#include "local.h"
#include "totem_imp.h"
#include "totem_event.h"
#include "coin_event.h"
#include "coin_imp.h"
#include "server.h"
#include "user_imp.h"
#include "soldier_imp.h"
#include "formation_imp.h"
#include "fight_imp.h"
#include "var_imp.h"
#include "proto/constant.h"
#include "proto/formation.h"
#include "proto/soldier.h"
#include "resource/r_totemext.h"
#include "resource/r_totemattrext.h"
#include "resource/r_totemextext.h"
#include "resource/r_oddext.h"
#include "resource/r_effectext.h"

// ---------------------------
#define NORMAL_PACKET STotemInfo &normal = user->data.totem_map[kTotemPacketNormal]

namespace totem
{
typedef std::vector<STotem> TotemList;

void Add(SUser *user, uint32 totem_id, uint32 path)
{
    LOG_DEBUG("totem_add id=%u begin", totem_id);

    CTotemData::SData *data = theTotemExt.Find(totem_id);
    if(data == NULL)
    {
        HandleErrCode(user, kErrUnkownTotem, 0);
        return;
    }

    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemById(totem_id));
    if(iter != normal.totem_list.end())
    {
        HandleErrCode(user, kErrTotemAlreadyExist, 0);
        return;
    }

    STotem totem;
    totem.guid             = GetTotemGuid(user);
    totem.id               = totem_id;
    totem.level            = data->init_lv;
    totem.speed_lv         = data->init_attr_lv;
    totem.formation_add_lv = data->init_attr_lv;
    totem.wake_lv          = data->init_attr_lv;

    normal.totem_list.push_back(totem);

    ReplyTotemInfo(user);

    event::dispatch(SEventCoin(user, path, kCoinTotem, totem_id, 1, kObjectAdd, 0));

    LOG_DEBUG("totem_add id=%u end", totem_id);
}

void Activate(SUser *user, uint32 totem_id)
{
    NORMAL_PACKET;
    TotemList::iterator iter_exist = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemById(totem_id));
    if(iter_exist != normal.totem_list.end())
    {
        LOG_WARN("totem_id=%u, has exist", totem_id);
        return;
    }

    CTotemData::SData *data = theTotemExt.Find(totem_id);
    if(data == NULL)
    {
        HandleErrCode(user, kErrUnkownTotem, 0);
        return;
    }

    for(uint32 i = 0; i < data->activate_conds.size(); ++i)
    {
        S3UInt32 &cond = data->activate_conds[i];
        if(cond.cate == kCoinArenaWinCount)
        {
            if(user->data.other.single_arena_win_times < cond.val)
            {
                LOG_WARN("win_times=%u, < cond.val=%u", user->data.other.single_arena_win_times, cond.val);
                return;
            }
        }
        else if(cond.cate == kCoinMedal)
        {
            uint32 has_count = coin::count(user, cond);
            if(has_count < cond.val)
            {
                LOG_WARN("has_count=%u, < cond.val=%u", has_count, cond.val);
                return;
            }
        }
        else if(cond.cate == kCoinTotem)
        {
            TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemById(cond.objid));
            if(iter == normal.totem_list.end())
            {
                LOG_ERROR("cannot find totem_id=%u", cond.objid);
                return;
            }
            if(iter->level < cond.val)
            {
                LOG_WARN("totem_id=%u, lv=%u < cond.val=%u", cond.objid, iter->level, cond.val);
                return;
            }
        }
    }

    // 满足条件
    for(uint32 i = 0; i < data->activate_conds.size(); ++i)
    {
        S3UInt32 &cond = data->activate_conds[i];
        if(cond.cate == kCoinMedal)
        {
            coin::take(user, cond, kPathTotemActivate);
        }
    }

    // 添加
    Add(user, totem_id, kPathTotemActivate);

    // RSP
    PRTotemActivate rsp;
    bccopy(rsp, user->ext);
    rsp.is_success = 1;
    rsp.totem_id   = totem_id;
    local::write(local::access, rsp);
}

void Del(SUser *user, uint32 totem_id, uint32 path )
{
    CTotemData::SData *data = theTotemExt.Find(totem_id);
    if(data == NULL)
    {
        HandleErrCode(user, kErrUnkownTotem, 0);
        return;
    }

    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemById(totem_id));
    if(iter == normal.totem_list.end())
    {
        HandleErrCode(user, kErrTotemNoExist, 0);
        return;
    }

    uint32 totem_guid = iter->guid;
    //删除图腾
    normal.totem_list.erase(iter);

    ReplyTotemInfo(user);

    //更新阵型
    formation::DelTotem(user, totem_guid);

    event::dispatch(SEventCoin(user, path, kCoinTotem, totem_id, 1, kObjectDel, 0));
}

void Bless(SUser *user, uint32 totem_guid, uint32 type)
{
    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemByGuid(totem_guid));
    if(iter == normal.totem_list.end())
    {
        LOG_WARN("cannot find totem guid=%u in totem_list", totem_guid);
        return;
    }

    uint32 *ref_lv = NULL;
    switch(type)
    {
    case kTotemSkillTypeSpeed:
        {
            ref_lv = &(iter->speed_lv);
            break;
        }
    case kTotemSkillTypeFormationAdd:
        {
            ref_lv = &(iter->formation_add_lv);
            break;
        }
    case kTotemSkillTypeWake:
        {
            ref_lv = &(iter->wake_lv);
            break;
        }
    default:
        {
            LOG_WARN("error type=%u", type);
            return;
        }
    }

    uint32 &lv = *ref_lv;
    uint32 lv_limit = iter->level * 5;
    if(lv >= lv_limit)
    {
        LOG_WARN("type=%u lv=%u, totem_lv=%u, reach top", type, lv, lv_limit);
        return;
    }

    CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(iter->id, lv);
    if(attr_data == NULL)
    {
        LOG_ERROR("cannot find totem attr id=%u lv=%u", iter->id, lv);
        return;
    }

    if(attr_data->train_cost.size() == 0)
    {
        LOG_ERROR("the train cost size is 0");
        return;
    }

    // 扣除费用
    uint32 ret = coin::check_take(user, attr_data->train_cost);
    if(ret != 0)
    {
        HandleErrCode(user, kErrCoinLack, ret);
        return;
    }
    coin::take(user, attr_data->train_cost, kPathTotemTrain);
    lv += 1;

    // rsp
    PRTotemBless rsp;
    bccopy(rsp, user->ext);
    rsp.totem = *iter;
    local::write(local::access, rsp);

    // EVENT
    event::dispatch(SEventTotemSkillLevelUp(user, kPathTotemTrain));
}

void Accelerate(SUser *user, uint32 totem_guid, bool is_free)
{
    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemByGuid(totem_guid));
    if(iter == normal.totem_list.end())
    {
        LOG_WARN("cannot find totem guid=%u in totem_list", totem_guid);
        return;
    }

    uint32 lv = iter->level * 5;
    if((iter->speed_lv < lv) || (iter->formation_add_lv < lv) || (iter->wake_lv < lv))
    {
        LOG_WARN("totem_guid=%u,totem_id=%u,totem_lv=%u, speed_lv=%u, formation_add_lv=%u, wake_lv=%u",
            iter->guid, iter->id, iter->level, iter->speed_lv, iter->formation_add_lv, iter->wake_lv);
        return;
    }

    CTotemData::SData *data = theTotemExt.Find(iter->id);
    if(data != NULL)
    {
        if(iter->level >= data->max_lv)
        {
            LOG_WARN("totem_guid=%u,totem_id=%u,lv=%u, reach max_lv=%u", iter->guid, iter->id, iter->level, data->max_lv);
            return;
        }
    }
    else
    {
        LOG_ERROR("cannot find totem data id=%u", iter->id);
        return;
    }

    lv = iter->speed_lv; // 三个技能等级随便一个即可
    CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(iter->id, lv);
    if(attr_data == NULL)
    {
        LOG_ERROR("cannot find totem attr id=%u lv=%u", iter->id, lv);
        return;
    }

    uint32 ret = coin::check_take(user, attr_data->accelerate_cost);
    if(ret != 0)
    {
        HandleErrCode(user, kErrCoinLack, ret);
        return;
    }

    coin::take(user, attr_data->accelerate_cost, kPathTotemAccelerate);

    iter->level += 1;
    event::dispatch(SEventTotemLevelUp(user, kPathTotemAccelerate, iter->id, iter->level - 1, iter->level));

    // rsp
    PRTotemAccelerate rsp;
    bccopy(rsp, user->ext);
    rsp.totem = *iter;
    local::write(local::access, rsp);
}

bool GetTotemExt(uint32 id, uint32 lv, SFightExtAble& able)
{
    CTotemAttrData::SData *data = theTotemAttrExt.Find(id, lv);
    if(data == NULL)
    {
        LOG_ERROR("cannot find totem ext data, id=%u,lv=%u", id, lv);
        return false;
    }

    able.hitper       = 20000;
    able.parryper_dec = 20000;

    return true;
}

void GetFightInfo(SUser *user, uint32 packet, uint32 guid, SFightSoldier &fight_soldier)
{
    STotemInfo &info = user->data.totem_map[packet];
    TotemList::iterator iter = std::find_if(info.totem_list.begin(), info.totem_list.end(), FindTotemByGuid(guid));
    if(iter == info.totem_list.end())
    {
        LOG_WARN("cannot find totem, guid=%u in totem_list", guid);
        return;
    }

    //自己图腾的属性
    fight_soldier.level = iter->level;
    fight_soldier.soldier_guid = guid;

    // 属性
    GetFightInfo(iter->id, iter->level, iter->wake_lv, iter->speed_lv, iter->formation_add_lv, fight_soldier);
}

void AddOddToList(uint32 use_guid, uint32 id, uint32 lv, std::vector<SFightOdd> &list)
{
    COddData::SData *odd_data = theOddExt.Find(id, lv);
    if(odd_data != NULL)
    {
        SFightOdd odd;
        fight::CreateFightOdd(odd_data, odd);
        odd.use_guid = use_guid;
        list.push_back(odd);

        //LOG_DEBUG("totem odd add ok, id=%u, lv=%u, status_id=%u, status_val=%u", odd.id, odd.level, odd.status_id, odd.status_value);
    }
}

bool CheckPosition(uint32 id, uint32 add_lv, uint32 formation_index, uint32 add_target_index)
{
    CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(id, add_lv);
    if(attr_data == NULL)
    {
        LOG_ERROR("cannot find totem attr data, id=%u, formation_add_lv=%u", id, add_lv);
        return false;
    }

    if(attr_data->formation_add_position.size() < 3)
    {
        LOG_ERROR("error pos para=%s", attr_data->formation_add_position.c_str());
        return false;
    }

    // type
    std::string sub_str = attr_data->formation_add_position.substr(0, 1);
    uint32 pos_type = atoi(sub_str.c_str());

    // position
    std::vector<uint32> position_list;
    for(uint32 i = 2; i < attr_data->formation_add_position.size(); ++i)
    {
        sub_str = attr_data->formation_add_position.substr(i, 1);
        position_list.push_back(atoi(sub_str.c_str()));
    }
    if(position_list.size() == 0)
    {
        LOG_ERROR("error position config=%s", attr_data->formation_add_position.c_str());
        return false;
    }

    bool is_add = false;
    if(pos_type == kTotemFormationAddPosition)
    {
        for(uint32 i = 0; i < position_list.size(); ++i)
        {
            if(position_list[i] == add_target_index)
            {
                is_add = true;
                break;
            }
        }
    }
    else if(pos_type == kTotemFormationAddType)
    {
        for(uint32 i = 0; i < position_list.size(); ++i)
        {
            switch(position_list[i])
            {
            case kTotemFormationAddTypeFrontRow:
                {
                    is_add |= (add_target_index % 3 == 1);
                    break;
                }
            case kTotemFormationAddTypeBackRow:
                {
                    is_add |= (add_target_index % 3 == 2);
                    break;
                }
            case kTotemFormationAddTypeColumn:
                {
                    if(add_target_index != formation_index) // 避免计算自身时，传两个0的情况
                    {
                        is_add |= (add_target_index / 3 == formation_index / 3);
                    }
                    break;
                }
            case kTotemFormationAddTypeTotem:
                {
                    is_add |= (add_target_index == formation_index);
                    break;
                }
            }
        }
    }
    else
    {
        LOG_ERROR("error formaiton_add_posistion=%u", pos_type);
    }

    return is_add;
}

void GetFightInfo(uint32 id, uint32 level, uint32 wake_lv, uint32 speed_lv, uint32 add_lv, SFightSoldier &fight_soldier)
{
    CTotemData::SData *totem_data = theTotemExt.Find(id);
    if(totem_data == NULL)
    {
        LOG_ERROR("cannot find totem data, id=%u", id);
        return;
    }

    fight_soldier.totem.id               = id;
    fight_soldier.totem.level            = level;
    fight_soldier.totem.speed_lv         = speed_lv;
    fight_soldier.totem.formation_add_lv = add_lv;
    fight_soldier.totem.wake_lv          = wake_lv;

    // 觉醒odd
    CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(id, wake_lv);
    if(attr_data != NULL)
    {
        AddOddToList(0, attr_data->wake.first, attr_data->wake.second, fight_soldier.odd_list);
    }

    // 主动技能
    attr_data = theTotemAttrExt.Find(id, level);
    if(attr_data == NULL)
    {
        LOG_ERROR("cannot find totem_attr data, id=%u, level=%u", id, level);
        return;
    }

    // base info
    fight_soldier.name       = totem_data->name;
    fight_soldier.soldier_id = totem_data->id;
    fight_soldier.attr       = kAttrTotem;
    if ( 0 == fight_soldier.level )
        fight_soldier.level = attr_data->level;

    // skill
    if(attr_data->skill.first != 0)
    {
        SFightSkill skill;
        skill.skill_id    = attr_data->skill.first;
        skill.skill_level = attr_data->skill.second;

        fight_soldier.skill_list.push_back(skill);
    }

    // 给自己加的odd
    if(CheckPosition(id, add_lv, 0, 0))
    {
        CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(id, add_lv);
        if(attr_data != NULL)
        {
            S2UInt32 &attr = attr_data->formation_add_attr;
            AddOddToList(0, attr.first, attr.second, fight_soldier.odd_list);
        }
    }

    // extable
    totem::GetTotemExt(id, speed_lv, fight_soldier.fight_ext_able );
}

void ReplyTotemInfo(SUser *user)
{
    NORMAL_PACKET;

    PRTotemInfo rsp;
    bccopy(rsp, user->ext);
    rsp.info = normal;

    local::write(local::access, rsp);
}

uint32 GetTotemGuid(SUser *user)
{
    std::map<uint32, bool> used_map;

    NORMAL_PACKET;
    for(TotemList::iterator iter = normal.totem_list.begin(); iter != normal.totem_list.end(); ++iter)
    {
        used_map[iter->guid] = true;
    }

    uint32 guid = 1;
    for(std::map<uint32, bool>::iterator iter = used_map.begin(); iter != used_map.end(); ++iter, ++guid)
    {
        if(iter->first != guid)
        {
            break;
        }
    }

    return guid;
}

bool CheckTotem(SUser *user, uint32 totem_guid)
{
    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemByGuid(totem_guid));
    return (iter != normal.totem_list.end());
}

STotem* GetTotemById(SUser *user, uint32 id)
{
    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemById(id));
    if(iter != normal.totem_list.end())
    {
        return &(*iter);
    }

    return NULL;
}

bool CheckTotemById(SUser *user, uint32 id)
{
    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemById(id));
    return (iter != normal.totem_list.end());
}

uint32 GetTotemLevelCount(SUser *user, uint32 level)
{
    uint32 count = 0;

    NORMAL_PACKET;
    for(TotemList::iterator iter = normal.totem_list.begin(); iter != normal.totem_list.end(); ++iter)
    {
        if(iter->level >= level)
        {
            ++count;
        }
    }

    return count;
}

uint32 GetTotemTotalLevel(SUser *user)
{
    uint32 count = 0;

    NORMAL_PACKET;
    for(TotemList::iterator iter = normal.totem_list.begin(); iter != normal.totem_list.end(); ++iter)
    {
        count += iter->level;
    }

    return count;
}

bool GetTotem(SUser *user, uint32 guid, STotem &totem)
{
    NORMAL_PACKET;
    TotemList::iterator iter = std::find_if(normal.totem_list.begin(), normal.totem_list.end(), FindTotemByGuid(guid));
    if(iter != normal.totem_list.end())
    {
        totem = *iter;
        return true;
    }

    return false;
}

void AddTotemBuff(uint32 target_id, SFightPlayerInfo &play_info, uint32 packet)
{
    if(play_info.attr == kAttrPlayer)
    {
        SUser *user = theUserDC.find(target_id);
        if(user == NULL)
        {
            LOG_ERROR("cannot find user=%u", target_id);
            return;
        }

        for(uint32 i = 0; i < play_info.soldier_list.size(); ++i)
        {
            SFightSoldier &soldier = play_info.soldier_list[i];
            if(soldier.attr == kAttrTotem)
            {
                continue;
            }

            for(uint32 x = 0; x < play_info.soldier_list.size(); ++x)
            {
                SFightSoldier &soldier_totem = play_info.soldier_list[x];
                if(soldier_totem.attr != kAttrTotem)
                {
                    continue;
                }

                STotemInfo &info = user->data.totem_map[packet];
                TotemList::iterator iter = std::find_if(info.totem_list.begin(), info.totem_list.end(), FindTotemByGuid(soldier_totem.soldier_guid));
                if(iter == info.totem_list.end())
                {
                    LOG_ERROR("cannot find totem guid=%u in user=%u totem packet=%u", soldier_totem.soldier_guid, user->guid, packet);
                    continue;
                }
                STotem &totem = *iter;

                if(CheckPosition(totem.id, totem.formation_add_lv, soldier_totem.fight_index, soldier.fight_index))
                {
                    // 阵法加成
                    CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(totem.id, totem.formation_add_lv);
                    if(attr_data != NULL)
                    {
                        S2UInt32 &attr = attr_data->formation_add_attr;
                        AddOddToList(soldier_totem.guid, attr.first, attr.second, soldier.odd_list);
                    }
                }

                // 速度加成
                CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(totem.id, totem.speed_lv);
                if(attr_data != NULL)
                {
                    if(soldier_totem.fight_index / 3 == soldier.fight_index / 3)
                    {
                        AddOddToList(soldier_totem.guid, attr_data->speed.first, attr_data->speed.second, soldier.odd_list);
                    }
                }
            }
        }
    }
    else if(play_info.attr == kAttrMonster)
    {
        for(uint32 i = 0; i < play_info.soldier_list.size(); ++i)
        {
            SFightSoldier &soldier = play_info.soldier_list[i];
            if(soldier.attr == kAttrTotem)
            {
                continue;
            }

            for(uint32 x = 0; x < play_info.soldier_list.size(); ++x)
            {
                SFightSoldier &soldier_totem = play_info.soldier_list[x];
                if(soldier_totem.attr != kAttrTotem)
                {
                    continue;
                }

                CTotemExtData::SData *ext = theTotemExtExt.Find(soldier_totem.soldier_guid);
                if(ext == NULL)
                {
                    continue;
                }

                // 阵法加成
                if(CheckPosition(ext->totem_id, ext->formation_lv, soldier_totem.fight_index, soldier.fight_index))
                {
                    CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(ext->totem_id, ext->formation_lv);
                    if(attr_data != NULL)
                    {
                        S2UInt32 &attr = attr_data->formation_add_attr;
                        AddOddToList(soldier_totem.guid, attr.first, attr.second, soldier.odd_list);
                    }
                }

                // 速度加成
                CTotemAttrData::SData *attr_data = theTotemAttrExt.Find(ext->totem_id, ext->speed_lv);
                if(attr_data != NULL)
                {
                    if(soldier_totem.fight_index / 3 == soldier.fight_index / 3)
                    {
                        AddOddToList(soldier_totem.guid, attr_data->speed.first, attr_data->speed.second, soldier.odd_list);
                    }
                }
            }
        }
    }
}

}// namespace totem
