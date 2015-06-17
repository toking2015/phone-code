#include "pro.h"
#include "log.h"
#include "misc.h"
#include "local.h"
#include "temple_imp.h"
#include "temple_event.h"
#include "fightextable_event.h"
#include "coin_event.h"
#include "coin_imp.h"
#include "server.h"
#include "user_imp.h"
#include "soldier_imp.h"
#include "building_imp.h"
#include "totem_imp.h"
#include "formation_imp.h"
#include "fight_imp.h"
#include "var_imp.h"
#include "proto/constant.h"
#include "proto/formation.h"
#include "proto/soldier.h"
#include "resource/r_globalext.h"
#include "resource/r_levelext.h"
#include "resource/r_oddext.h"
#include "resource/r_totemext.h"
#include "resource/r_effectext.h"
#include "resource/r_soldierext.h"

// ---------------------------
#define GET_HOLE_COUNT(type)\
    uint32 *dst_hole_count = NULL;\
    if(type == kEquipCloth)\
    {\
        dst_hole_count = &(user->data.temple.hole_cloth);\
    }\
    else if(type == kEquipLeather)\
    {\
        dst_hole_count = &(user->data.temple.hole_leather);\
    }\
    else if(type == kEquipMail)\
    {\
        dst_hole_count = &(user->data.temple.hole_mail);\
    }\
    else if(type == kEquipPlate)\
    {\
        dst_hole_count = &(user->data.temple.hole_plate);\
    }\
    else\
    {\
        LOG_WARN("unkonw hole type=%u", type);\
        return;\
    }

// ---------------------------
namespace temple
{

SFightExtAble GetTempleExt(SUser *user, SUserSoldier &soldier, SFightExtAble &able)
{
    SFightExtAble result;

    // 检测神殿是否已开放
    if(building::GetCount(user, kBuildingTypePalace) == 0)
    {
        return result;
    }

    CSoldierData::SData *soldier_data = theSoldierExt.Find(soldier.soldier_id);
    if(soldier_data == NULL)
    {
        return result;
    }

    // 武将收集
    std::map<uint32, uint32> attr_map;
    std::map<uint32, SUserSoldier> &soldier_map = user->data.soldier_map[kSoldierTypeCommon];
    for(std::map<uint32, SUserSoldier>::iterator iter = soldier_map.begin(); iter != soldier_map.end(); ++iter)
    {
        CSoldierData::SData *data = theSoldierExt.Find(iter->second.soldier_id);
        if(data != NULL)
        {
            for(uint32 i = 0; i < data->get_attr.size(); ++i)
            {
                attr_map[data->get_attr[i].first] += data->get_attr[i].second;
            }
        }
    }

    // 图腾收集
    std::vector<STotem> &totem_list = user->data.totem_map[kTotemPacketNormal].totem_list;
    for(std::vector<STotem>::iterator iter = totem_list.begin(); iter != totem_list.end(); ++iter)
    {
        CTotemData::SData *data = theTotemExt.Find(iter->id);
        if(data != NULL)
        {
            for(uint32 i = 0; i < data->get_attr.size(); ++i)
            {
                attr_map[data->get_attr[i].first] += data->get_attr[i].second;
            }
        }
    }

    // 组合
    for(std::vector<STempleGroup>::iterator iter = user->data.temple.group_list.begin(); iter != user->data.temple.group_list.end(); ++iter)
    {
        CTempleGroupLevelUpData::SData *data = theTempleGroupLevelUpExt.Find(iter->id, iter->level);
        if(data != NULL)
        {
            for(uint32 i = 0; i < data->attrs.size(); ++i)
            {
                attr_map[data->attrs[i].first] += data->attrs[i].second;
            }
        }
    }

    // 神符
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        if(iter->embed_type == soldier_data->equip_type)
        {
            CTempleGlyphAttrData::SData *data = theTempleGlyphAttrExt.Find(iter->id, iter->level);
            if(data != NULL)
            {
                for(uint32 i = 0; i < data->attrs.size(); ++i)
                {
                    attr_map[data->attrs[i].first] += data->attrs[i].second;
                }
            }
        }
    }

    // ---- 加属性 ----
    for(std::map<uint32, uint32>::iterator iter = attr_map.begin(); iter != attr_map.end(); ++iter)
    {
        SFightExtAble temp = theEffectExt.ToFightExtAble(iter->first, able, iter->second);
        result = theEffectExt.AddFightExtAble(result, temp);
    }

    return result;
}

void AddTempleOdd(SUser *user, SUserSoldier &soldier, std::vector<SFightOdd> &odd_list)
{
    if(building::GetCount(user, kBuildingTypePalace) == 0)
    {
        return;
    }

    CSoldierData::SData *soldier_data = theSoldierExt.Find(soldier.soldier_id);
    if(soldier_data == NULL)
    {
        return;
    }

    // 总经验和品质
    uint32 total_exp = 0;
    std::map<uint32, uint32> quality_map;
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        if(iter->embed_type != soldier_data->equip_type)
        {
            continue;
        }

        CTempleGlyphData::SData *data = theTempleGlyphExt.Find(iter->id);
        if(data != NULL)
        {
            total_exp += GetGlyphTotalExp(*iter);

            if(data->quality >= kQualityWhite)
            {
                quality_map[kQualityWhite] += 1;
            }
            if(data->quality >= kQualityGreen)
            {
                quality_map[kQualityGreen] += 1;
            }
            if(data->quality >= kQualityBlue)
            {
                quality_map[kQualityBlue] += 1;
            }
            if(data->quality >= kQualityPurple)
            {
                quality_map[kQualityPurple] += 1;
            }
            if(data->quality >= kQualityOrange)
            {
                quality_map[kQualityOrange] += 1;
            }
        }
    }

    // 计算激活odd
    CTempleSuitAttrData::UInt32TempleSuitAttrMap all_attrs = theTempleSuitAttrExt.GetAllList();
    for(std::map<uint32, CTempleSuitAttrData::SData*>::iterator iter = all_attrs.begin(); iter != all_attrs.end(); ++iter)
    {
        CTempleSuitAttrData::SData &data = *(iter->second);
        if(data.type != soldier_data->equip_type)
        {
            continue;
        }

        // 条件判断
        if(data.cond_exp > 0)
        {
            if(total_exp < data.cond_exp)
            {
                continue;
            }
        }
        if((data.cond_quality > 0) && (data.cond_count > 0))
        {
            if(quality_map[data.cond_quality] < data.cond_count)
            {
                continue;
            }
        }

        // 激活
        LOG_DEBUG("active temple_suit_attr soldier=%u, equip_type=%u, id=%u", soldier_data->equip_type, soldier.soldier_id, data.id);
        for(std::vector<S2UInt32>::iterator iter_attr = data.odds.begin(); iter_attr != data.odds.end(); ++iter_attr)
        {
            COddData::SData *temp = theOddExt.Find(iter_attr->first, iter_attr->second);
            if(temp != NULL)
            {
                SFightOdd odd;
                fight::CreateFightOdd(temp, odd);
                odd_list.push_back(odd);
            }
        }
    }
}

void TakeScoreReward(SUser *user, uint32 reward_id)
{
    for(uint32 i = 0; i < user->data.temple.score_taken_list.size(); ++i)
    {
        if(user->data.temple.score_taken_list[i] == reward_id)
        {
            LOG_WARN("reard_id=%u, had taken", reward_id);
            return;
        }
    }

    CTempleScoreRewardData::SData *data = theTempleScoreRewardExt.Find(reward_id);
    if(data == NULL)
    {
        LOG_ERROR("cannot find reward data=%u", reward_id);
        return;
    }

    uint32 score = GetScore(user);
    if(score < data->score)
    {
        LOG_WARN("user_score=%u < need_score=%u", score, data->score);
        return;
    }

    // 领取
    user->data.temple.score_taken_list.push_back(reward_id);
    coin::give(user, data->reward, kPathTempleScoreReward);

    // RSP
    PRTempleTakeScoreReward rsp;
    bccopy(rsp, user->ext);
    local::write(local::access, rsp);

    ReplyTempleInfo(user);
}

void GroupLevelUp(SUser *user, uint32 group_id)
{
    STempleGroup *group = GetGroup(user, group_id);
    if(group == NULL)
    {
        LOG_WARN("cannot find group=%u", group_id);
        return;
    }

    uint32 next_level = group->level + 1;
    CTempleGroupLevelUpData::SData *group_next_data = theTempleGroupLevelUpExt.Find(group_id, next_level);
    if(group_next_data == NULL)
    {
        LOG_ERROR("cannot find group data id=%u, lv=%u", group_id, next_level);
        return;
    }

    uint32 total_star = GetGroupStar(user, group_id);
    if(total_star < group_next_data->star)
    {
        LOG_WARN("total_star=%u < need_star=%u", total_star, group_next_data->star);
        return;
    }

    ++(group->level);
    event::dispatch(SEventTempleGroupLevelUp(user, kPathTempleGroupLevelUp, group_id, group->level));

    // RSP
    PRTempleGroupLevelUp rsp;
    bccopy(rsp, user->ext);
    rsp.group = *group;
    local::write(local::access, rsp);
}

void OpenHole(SUser *user, uint32 hole_type, bool is_use_item)
{
    GET_HOLE_COUNT(hole_type);

    if(*dst_hole_count >= kTempleHoleMaxCount)
    {
        LOG_WARN("reach max count=%u", *dst_hole_count);
        return;
    }

    CTempleHoleData::SData *hole_data = theTempleHoleExt.Find(*dst_hole_count + 1);
    if(hole_data == NULL)
    {
        LOG_WARN("cannot find hole data by count=%u", *dst_hole_count + 1);
        return;
    }

    if(user->data.simple.team_level < hole_data->level)
    {
        LOG_WARN("user_lv=%u < open_lv=%u", user->data.simple.team_level, hole_data->level);
        return;
    }

    std::vector<S3UInt32> cost_list = is_use_item ? hole_data->cost_item : hole_data->cost_coin;
    uint32 ret = coin::check_take(user, cost_list);
    if(ret != 0)
    {
        HandleErrCode(user, kErrCoinLack, ret);
        return;
    }
    coin::take(user, cost_list, kPathTempleOpenHole);

    // 开孔
    *dst_hole_count += 1;
    event::dispatch(SEventTempleOpenHole(user, kPathTempleOpenHole, hole_type));

    // RSP
    PRTempleOpenHole rsp;
    bccopy(rsp, user->ext);
    local::write(local::access, rsp);

    ReplyTempleInfo(user);
}

void EmbedGlyph(SUser *user, uint32 hole_type, uint32 hole_index, uint32 glyph_guid)
{
    // 判断总孔数量
    GET_HOLE_COUNT(hole_type);
    if(hole_index >= *dst_hole_count)
    {
        LOG_WARN("error_index=%u, hole_count=%u", hole_index, *dst_hole_count);
        return;
    }

    // ---------------------- 源神符 --------------------
    // 判断神符是否已经镶嵌
    STempleGlyph *src_glyph = GetGlyph(user, glyph_guid);
    if(src_glyph == NULL)
    {
        LOG_ERROR("cannot find glyph by guid=%u", glyph_guid);
        return;
    }
    if(src_glyph->embed_type != 0)
    {
        LOG_WARN("glyph_guid=%u, had embed in type=%u, index=%u", glyph_guid, hole_type, hole_index);
        return;
    }

    // 需要镶嵌相同类型的神符
    CTempleGlyphData::SData *src_data = theTempleGlyphExt.Find(src_glyph->id);
    if(src_data != NULL)
    {
        if(src_data->type != hole_type)
        {
            LOG_WARN("cannot embed diff, glyph_type=%u, hole_type=%u", src_data->type, hole_type);
            return;
        }
    }
    else
    {
        LOG_ERROR("cannot find data by glypy_id=%u", src_glyph->id);
        return;
    }

    // ---------------------- 目标神符 --------------------
    STempleGlyph *dst_glyph = NULL;
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        if((iter->embed_type == hole_type) && (iter->embed_index == hole_index))
        {
            dst_glyph = &(*iter);
            break;
        }
    }

    // --------- 同系的不能镶嵌同名的神符 --------------------
    std::map<uint32, uint32> other_embed_attr_map; // 其他孔镶嵌的属性
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        if((iter->embed_type == hole_type) && (iter->embed_index != hole_index))
        {
            CTempleGlyphAttrData::SData *temp = theTempleGlyphAttrExt.Find(iter->id, iter->level);
            if(temp != NULL)
            {
                for(std::vector<S2UInt32>::iterator iter_attr = temp->attrs.begin(); iter_attr != temp->attrs.end(); ++iter_attr)
                {
                    other_embed_attr_map[iter_attr->first] = iter_attr->second;
                }
            }
        }
    }
    CTempleGlyphAttrData::SData *src_data_attr = theTempleGlyphAttrExt.Find(src_glyph->id, src_glyph->level);
    if(src_data_attr != NULL)
    {
        for(std::vector<S2UInt32>::iterator iter = src_data_attr->attrs.begin(); iter != src_data_attr->attrs.end(); ++iter)
        {
            std::map<uint32, uint32>::iterator iter_find = other_embed_attr_map.find(iter->first);
            if(iter_find != other_embed_attr_map.end())
            {
                LOG_WARN("attr_id=%u had embed, cannot embed the same attr glyph", iter->first);
                return;
            }
        }
    }

    // ---------------------- 镶嵌 --------------------
    // 目标神符设置未镶嵌
    if(dst_glyph != NULL)
    {
        dst_glyph->embed_type  = 0;
        dst_glyph->embed_index = 0;
    }
    // 镶嵌上源神符
    src_glyph->embed_type  = hole_type;
    src_glyph->embed_index = hole_index;

    // EVENT
    event::dispatch(SEventTempleGlyphEmbed(user, kPathTempleEmbedGlyph, src_glyph->id, hole_type));
    event::dispatch(SEventFightExtAbleAllUpdate(user, kPathTempleEmbedGlyph));

    // RSP
    ReplyTempleInfo(user);
}

void TrainGlyph(SUser *user, uint32 main_guid, uint32 eated_guid)
{
    if(main_guid == eated_guid)
    {
        LOG_WARN("cannot eat myself, main_guid=%u,eated_guid=%u", main_guid, eated_guid);
        return;
    }

    STempleGlyph *main_glyph  = GetGlyph(user, main_guid);
    STempleGlyph *eated_glyph = GetGlyph(user, eated_guid);
    if((main_glyph == NULL) || (eated_glyph == NULL))
    {
        LOG_WARN("cannot find main_glyph=%u, or eated_glyph=%u", main_guid, eated_guid);
        return;
    }

    CTempleGlyphData::SData *eated_data = theTempleGlyphExt.Find(eated_glyph->id);
    if(eated_data == NULL)
    {
        LOG_ERROR("cannot find eated_data=%u", eated_glyph->id);
        return;
    }

    // 培养上限
    uint32 old_level = main_glyph->level;
    CLevelData::SData *level_data = theLevelExt.Find(user->data.simple.team_level);
    if(level_data == NULL)
    {
        LOG_ERROR("cannot find level data by %u", user->data.simple.team_level);
        return;
    }
    if(old_level >= level_data->glyph_lv)
    {
        LOG_WARN("cannot train, glpyh_lv=%u >= level_glyph_lv=%u", old_level, level_data->glyph_lv);
        return;
    }

    // 先加经验
    main_glyph->exp = GetGlyphTotalExp(*main_glyph) + GetGlyphTotalExp(*eated_glyph) + eated_data->exp;
    std::map<uint32, CTempleGlyphAttrData::SData*> glyph_attrs = theTempleGlyphAttrExt.GetGlyphAttrs(main_glyph->id);
    for(std::map<uint32, CTempleGlyphAttrData::SData*>::iterator iter = glyph_attrs.begin(); iter != glyph_attrs.end(); ++iter)
    {
        if(main_glyph->exp >= iter->second->exp)
        {
            main_glyph->exp  -= iter->second->exp;
            main_glyph->level = iter->second->level;

            // 不能超过等级上限
            if(main_glyph->level >= level_data->glyph_lv)
            {
                break;
            }
        }
        else
        {
            break;
        }
    }

    // 升级成功，删除被吃的神符
    for(uint32 i = 0; i < user->data.temple.glyph_list.size(); ++i)
    {
        if(user->data.temple.glyph_list[i].guid == eated_guid)
        {
            user->data.temple.glyph_list.erase(user->data.temple.glyph_list.begin() + i);
            break;
        }
    }

    // RSP
    PRTempleGlyphTrain rsp;
    bccopy(rsp, user->ext);
    rsp.old_lv = old_level;
    rsp.new_lv = main_glyph->level;
    local::write(local::access, rsp);

    ReplyTempleInfo(user);

    // EVENT
    event::dispatch(SEventTempleGlyphTrain(user, kPathTempleTrainGlyph, main_glyph->id, old_level, main_glyph->level));
    if((main_glyph->embed_type > 0) && (main_glyph->level > old_level))
    {
        event::dispatch(SEventFightExtAbleAllUpdate(user, kPathTempleTrainGlyph));
    }
}

void AddGlyph(SUser *user, uint32 glyph_id, uint32 path)
{
    CTempleGlyphData::SData *data = theTempleGlyphExt.Find(glyph_id);
    if(data == NULL)
    {
        LOG_ERROR("cannot find data by glypy_id=%u", glyph_id);
        return;
    }

    std::map<uint32, bool> used_map;

    // 获取可用的guid
    uint32 guid = 1;
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        used_map[iter->guid] = true;
    }
    for(std::map<uint32, bool>::iterator iter = used_map.begin(); iter != used_map.end(); ++iter, ++guid)
    {
        if(iter->first != guid)
        {
            break;
        }
    }

    // 增加
    STempleGlyph glyph;
    glyph.guid  = guid;
    glyph.id    = glyph_id;
    glyph.level = data->init_lv;
    glyph.exp   = 0;
    user->data.temple.glyph_list.push_back(glyph);

    // RSP
    ReplyTempleInfo(user);

    event::dispatch(SEventCoin(user, path, kCoinGlyph, glyph_id, 1, kObjectAdd, 0));
}

void CalTempleScore(SUser *user)
{
    uint32 old_score = GetScore(user);

    std::map<uint32, S2UInt32> &current = user->data.temple.score_current;
    current.clear();

    // 组合
    uint32 group_count       = 0;
    uint32 group_score       = 0;
    uint32 group_level       = 0;
    uint32 group_level_score = 0;
    for(std::vector<STempleGroup>::iterator iter = user->data.temple.group_list.begin(); iter != user->data.temple.group_list.end(); ++iter)
    {
        CTempleGroupData::SData        *group_data = theTempleGroupExt.Find(iter->id);
        CTempleGroupLevelUpData::SData *lv_data    = theTempleGroupLevelUpExt.Find(iter->id, iter->level);
        if((group_data != NULL) && (lv_data != NULL))
        {
            group_count       += 1;
            group_score       += group_data->get_score;
            group_level_score += lv_data->score;

            if(iter->level > group_data->init_lv)
            {
                group_level += (iter->level - group_data->init_lv);
            }
        }
        else
        {
            LOG_ERROR("cannot find group_data or lv_data id=%u,lv=%u", iter->id, iter->level);
        }
    }
    current[kTempleScoreGroupCollect].first  = group_count;
    current[kTempleScoreGroupCollect].second = group_score;
    current[kTempleScoreGroupLevelUp].first  = group_level;
    current[kTempleScoreGroupLevelUp].second = group_level_score;

    // 图腾
    uint32 totem_count = 0;
    uint32 totem_score = 0;
    uint32 totem_level = 0;
    uint32 totem_skill = 0;
    std::vector<STotem> &totem_list = user->data.totem_map[kTotemPacketNormal].totem_list;
    for(std::vector<STotem>::iterator iter = totem_list.begin(); iter != totem_list.end(); ++iter)
    {
        CTotemData::SData *data = theTotemExt.Find(iter->id);
        if(data != NULL)
        {
            totem_count += 1;
            totem_score += data->get_score;
            totem_skill += (iter->speed_lv + iter->formation_add_lv + iter->wake_lv);

            if(iter->level > data->init_lv)
            {
                totem_level += (iter->level - data->init_lv);
            }
        }
        else
        {
            LOG_ERROR("cannot find totem_data id=%u,lv=%u", iter->id, iter->level);
        }
    }
    current[kTempleScoreTotemCollect].first       = totem_count;
    current[kTempleScoreTotemCollect].second      = totem_score;
    current[kTempleScoreTotemSkillLevelUp].first  = totem_skill;
    current[kTempleScoreTotemSkillLevelUp].second = totem_skill * theGlobalExt.get<uint32>("temple_score_totem_shengji_cof");
    current[kTempleScoreTotemLevelUp].first       = totem_level;
    current[kTempleScoreTotemLevelUp].second      = totem_level * theGlobalExt.get<uint32>("temple_score_totem_shengxing_cof");

    // 英雄
    uint32 soldier_count   = 0;
    uint32 soldier_score   = 0;
    uint32 soldier_level   = 0;
    uint32 soldier_star    = 0;
    uint32 soldier_quality = 0;
    std::map<uint32, SUserSoldier> &soldier_map = user->data.soldier_map[kSoldierTypeCommon];
    for(std::map<uint32, SUserSoldier>::iterator iter = soldier_map.begin(); iter != soldier_map.end(); ++iter)
    {
        CSoldierData::SData *data = theSoldierExt.Find(iter->second.soldier_id);
        if(data != NULL)
        {
            soldier_count += 1;
            soldier_score += data->get_score;

            if(iter->second.level > 0) // 武将默认1级
            {
                soldier_level += iter->second.level - 1;
            }

            if(iter->second.star > data->star)
            {
                soldier_star += (iter->second.star - data->star);
            }

            if(iter->second.quality > data->quality)
            {
                soldier_quality += (iter->second.quality - data->quality);
            }
        }
        else
        {
            LOG_ERROR("cannot find soldier_data id=%u", iter->second.soldier_id);
        }
    }
    current[kTempleScoreSoldierCollect].first  = soldier_count;
    current[kTempleScoreSoldierCollect].second = soldier_score;
    current[kTempleScoreSoldierLevelUp].first  = soldier_level;
    current[kTempleScoreSoldierLevelUp].second = soldier_level * theGlobalExt.get<uint32>("temple_score_hero_shengji_cof");
    current[kTempleScoreSoldierQuality].first  = soldier_quality;
    current[kTempleScoreSoldierQuality].second = soldier_quality * theGlobalExt.get<uint32>("temple_score_hero_jinjie_cof");
    current[kTempleScoreSoldierStar].first     = soldier_star;
    current[kTempleScoreSoldierStar].second    = soldier_star * theGlobalExt.get<uint32>("temple_score_hero_shengxing_cof");

    // 积分
    uint32 new_score = GetScore(user);
    if(old_score != new_score)
    {
        ReplyTempleInfo(user);

        event::dispatch(SEventFightExtAbleAllUpdate(user, kPathTemple));
        event::dispatch(SEventTempleScoreChanged(user, kPathTemple));
    }
}

void TimeLimit(SUser *user)
{
    if(building::GetCount(user, kBuildingTypePalace) > 0)
    {
        CalTempleScore(user);

        user->data.temple.score_yesterday.clear();
        user->data.temple.score_yesterday = user->data.temple.score_current;

        ReplyTempleInfo(user);
    }
}

void OnLogin(SUser *user)
{
    // 判断第一次开启神符格
    if(user->data.temple.hole_cloth == 0)
    {
        user->data.temple.hole_cloth   = 1;
        user->data.temple.hole_leather = 1;
        user->data.temple.hole_mail    = 1;
        user->data.temple.hole_plate   = 1;
    }

    // 容错，之前的神符，如果等级为0，那么就将等级设计为初始等级
    bool need_clear = false;
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        if(iter->level == 0)
        {
            need_clear = true;

            CTempleGlyphData::SData *data = theTempleGlyphExt.Find(iter->id);
            if(data != NULL)
            {
                iter->level = data->init_lv;
                iter->exp   = 0;
            }
        }
    }
    if(need_clear)
    {
        user->data.temple.group_list.clear();
        user->data.temple.score_yesterday.clear();
    }

    CheckAddGroup(user);
}

void CheckAddGroup(SUser *user)
{
    CTempleGroupData::UInt32TempleGroupMap &group_map = theTempleGroupExt.GetGroups();
    for(CTempleGroupData::UInt32TempleGroupMap::iterator iter = group_map.begin(); iter != group_map.end(); ++iter)
    {
        CTempleGroupData::SData &group = *(iter->second);
        if((group.members.size() == 0) || (GetGroup(user, group.id) != NULL))
        {
            continue;
        }

        bool is_ok = false;
        for(uint32 i = 0; i < group.members.size(); ++i)
        {
            S2UInt32 &member = group.members[i];
            if(member.first == kCoinSoldier)
            {
                is_ok = soldier::CheckSoldier(user, member.second);
            }
            else if(member.first == kCoinTotem)
            {
                is_ok = totem::CheckTotemById(user, member.second);
            }

            if(!is_ok)
            {
                break;
            }
        }

        // 满足组条件
        if(is_ok)
        {
            STempleGroup g;
            g.id    = group.id;
            g.level = group.init_lv;
            user->data.temple.group_list.push_back(g);

            event::dispatch(SEventTempleGroupAdd(user, kPathTempleGroupAdd, g.id));
        }
    }

    CalTempleScore(user);
}

uint32 GetGlyphTotalExp(const STempleGlyph &glyph)
{
    uint32 total_exp = glyph.exp;
    std::map<uint32, CTempleGlyphAttrData::SData*> glyph_attrs = theTempleGlyphAttrExt.GetGlyphAttrs(glyph.id);
    for(std::map<uint32, CTempleGlyphAttrData::SData*>::iterator iter = glyph_attrs.begin(); iter != glyph_attrs.end(); ++iter)
    {
        if(glyph.level >= iter->second->level)
        {
            total_exp += iter->second->exp;
        }
        else
        {
            break;
        }
    }

    return total_exp;
}

uint32 GetGroupStar(SUser *user, uint32 group_id)
{
    CTempleGroupData::SData *group = theTempleGroupExt.Find(group_id);
    if(group == NULL)
    {
        LOG_ERROR("cannot find group, id=%u", group_id);
        return 0;
    }

    uint32 total_star = 0;
    for(uint32 i = 0; i < group->members.size(); ++i)
    {
        S2UInt32 &member = group->members[i];
        if(member.first == kCoinSoldier)
        {
            total_star += soldier::GetSoldierStar(user, member.second);
        }
        else if(member.first == kCoinTotem)
        {
            STotem *t = totem::GetTotemById(user, member.second);
            if(t != NULL)
            {
                total_star += t->level;
            }
        }
    }

    return total_star;
}

STempleGlyph* GetGlyph(SUser *user, uint32 guid)
{
    for(uint32 i = 0; i < user->data.temple.glyph_list.size(); ++i)
    {
        if(user->data.temple.glyph_list[i].guid == guid)
        {
            return &(user->data.temple.glyph_list[i]);
        }
    }

    return NULL;
}

STempleGroup* GetGroup(SUser *user, uint32 group_id)
{
    for(uint32 i = 0; i < user->data.temple.group_list.size(); ++i)
    {
        if(user->data.temple.group_list[i].id == group_id)
        {
            return &(user->data.temple.group_list[i]);
        }
    }

    return NULL;
}

uint32 GetScore(SUser *user)
{
    uint32 total = 0;
    for(std::map<uint32, S2UInt32>::iterator iter = user->data.temple.score_current.begin(); iter != user->data.temple.score_current.end(); ++iter)
    {
        total += iter->second.second;
    }

    return total;
}

uint32 GetGroupLevel(SUser *user, uint32 group_id)
{
    uint32 level = 0;
    uint32 total_star = GetGroupStar(user, group_id);
    std::map<uint32, CTempleGroupLevelUpData::SData*> lv_map = theTempleGroupLevelUpExt.GetGroupLevelUp(group_id);
    for(std::map<uint32, CTempleGroupLevelUpData::SData*>::iterator iter = lv_map.begin(); iter != lv_map.end(); ++iter)
    {
        if(total_star >= iter->second->star)
        {
            level = iter->second->level;
        }
        else
        {
            break;
        }
    }

    return level;
}

void ReplyTempleInfo(SUser *user)
{
    PRTempleInfo rsp;
    bccopy(rsp, user->ext);
    rsp.info = user->data.temple;

    local::write(local::access, rsp);
}

uint32 GetGlyphCount(SUser *user, uint32 glyph_id)
{
    uint32 count = 0;
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        if(iter->id == glyph_id)
        {
            ++count;
        }
    }

    return count;
}

uint32 GetEmbedGlyphCountByQuality(SUser *user, uint32 quality)
{
    uint32 count = 0;
    for(std::vector<STempleGlyph>::iterator iter = user->data.temple.glyph_list.begin(); iter != user->data.temple.glyph_list.end(); ++iter)
    {
        if(iter->embed_type > 0)
        {
            CTempleGlyphData::SData *data = theTempleGlyphExt.Find(iter->id);
            if((data != NULL) && (data->quality >= quality))
            {
                ++count;
            }
        }
    }

    return count;
}

}// namespace temple
