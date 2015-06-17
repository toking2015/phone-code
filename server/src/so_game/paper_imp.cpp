#include "paper_imp.h"
#include "user_imp.h"
#include "coin_imp.h"
#include "server.h"
#include "local.h"
#include "pro.h"
#include "resource/r_paperskillext.h"
#include "resource/r_papercreateext.h"
#include "resource/r_copymaterialext.h"
#include "resource/r_itemext.h"
#include "resource/r_copyext.h"
#include "resource/r_globalext.h"
#include "proto/paper.h"
#include "proto/constant.h"
#include <math.h>

namespace paper
{

void LevelUp(SUser *p_user, uint32 skill_type)
{
    CPaperSkillData::SData *p_next_level = NULL;
    if (p_user->data.other.paper_skill == 0)
    {
        p_next_level = thePaperSkillExt.FindByType(skill_type, 1);
    }
    else
    {
        CPaperSkillData::SData *p_paper_skill = thePaperSkillExt.Find(p_user->data.other.paper_skill);
        if (!p_paper_skill)
            return;
        p_next_level = thePaperSkillExt.FindByType(p_paper_skill->skill_type, p_paper_skill->level + 1);
    }

    if (!p_next_level)
        return;

    // check money and star
    std::vector<S3UInt32> coins;
    S3UInt32 cost;
    cost.cate = kCoinStar;
    cost.val = p_next_level->level_up_star;
    if (cost.val > 0)
        coins.push_back(cost);
    cost.cate = kCoinMoney;
    cost.val = p_next_level->level_up_money;
    if (cost.val > 0)
        coins.push_back(cost);
    uint32 ret = coin::check_take(p_user, coins);
    if (ret != 0)
    {
        HandleErrCode(p_user, kErrCoinLack, ret);
        return;
    }
    coin::take(p_user, coins, kPathPaperSkillLevelUp);

    // reward
    S3UInt32 reward = coin::create(kCoinActiveScore, 0, p_next_level->active_score_add);
    coin::give(p_user, reward, kPathPaperSkillLevelUp);

    // update
    p_user->data.other.paper_skill = p_next_level->id;
    user::ReplyUserOther(p_user);

    // material collect point create
    if (p_next_level->collect_skill_level > 0)
        CheckCreateCollectPoint(p_user, p_next_level->collect_skill_level);
}

struct PaperLearnCount
{
    uint32 &star;
    uint32 &money;
    uint32 skill_type;
    uint32 level;
    PaperLearnCount(uint32 &n, uint32 &m, uint32 _type, uint32 _level) : star(n), money(m), skill_type(_type), level(_level) {}
    bool operator ()(CPaperSkillData::UInt32PaperSkillMap::value_type &obj)
    {
        CPaperSkillData::SData *p_data = obj.second;
        if (p_data->skill_type == skill_type && p_data->level <= level)
        {
            star += p_data->level_up_star;
            money += p_data->level_up_money;
        }
        return true;
    }
};
// 学习到该技能的所有花费
void CountLearnCost(uint32 id, uint32 &sum_star, uint32 &sum_money)
{
    CPaperSkillData::SData *p_cur = thePaperSkillExt.Find(id);
    if (!p_cur)
        return;
    thePaperSkillExt.Each(PaperLearnCount(sum_star, sum_money, p_cur->skill_type, p_cur->level));
}

void Forget(SUser *p_user)
{
    if (p_user->data.other.paper_skill == 0)
        return;

    CPaperSkillData::SData *p_data = thePaperSkillExt.Find(p_user->data.other.paper_skill);
    if (!p_data)
        return;

    // min(level * 200, 2000)
    S3UInt32 cost;
    cost.cate = kCoinGold;
    cost.val = p_data->level * 200 > 2000 ? 2000 : p_data->level * 200;
    uint32 ret = coin::check_take(p_user, cost);
    if (ret != 0)
    {
        HandleErrCode(p_user, kErrCoinLack, kCoinGold);
        return;
    }
    coin::take(p_user, cost, kPathPaperSkillForget);

    uint32 sum_star = 0;
    uint32 sum_money = 0;
    CountLearnCost(p_user->data.other.paper_skill, sum_star, sum_money);

    // 重置
    p_user->data.other.paper_skill = 0;
    user::ReplyUserOther(p_user);

    // 删除所有未采集原料
    p_user->data.copy_material_list.clear();
    ReplyCopyMaterialList(p_user);

    // 归还学习到该等级的所有花费
    std::vector<S3UInt32> coins;
    cost.cate = kCoinStar;
    cost.val = sum_star;
    coins.push_back(cost);
    cost.cate = kCoinMoney;
    cost.val = sum_money;
    coins.push_back(cost);
    coin::give(p_user, coins, kPathPaperSkillForget);
}

void CreatePaper(SUser *p_user, uint32 paper_id)
{
    CPaperCreateData::SData *p_paper = thePaperCreateExt.Find(paper_id);
    if (!p_paper)
        return;
    CItemData::SData *p_item = theItemExt.Find(paper_id);
    if (!p_item)
        return;
    CPaperSkillData::SData *p_paper_skill = thePaperSkillExt.Find(p_user->data.other.paper_skill);
    if (!p_paper_skill)
        return;

    // 技能类型
    if (p_paper_skill->skill_type != p_item->equip_type)
    {
        HandleErrCode(p_user, kErrPaperWrongSkillType, 0);
        return;
    }

    // 等级限制
    if (p_paper_skill->paper_level_limit < p_paper->level_limit)
    {
        HandleErrCode(p_user, kErrPaperCreateLevelLimit, 0);
        return;
    }

    // 活跃值
    S3UInt32 cost = coin::create(kCoinActiveScore, 0, p_paper->active_score);
    cost.val = (uint32)ceil(cost.val - cost.val * (p_paper_skill->create_cost_reduce / 10000.0));
    uint32 ret = coin::check_take(p_user, cost);
    if (ret != 0)
    {
        HandleErrCode(p_user, kErrCoinLack, kCoinActiveScore);
        return;
    }
    coin::take(p_user, cost, kPathPaperCreate);

    S3UInt32 item = coin::create(kCoinItem, paper_id, 1);
    coin::give(p_user, item, kPathPaperCreate);

    PRPaperCreate rep;
    rep.paper_id = paper_id;
    bccopy(rep, p_user->ext);
    local::write(local::access, rep);
}

struct SEqualCollectLevel
{
    uint32 collect_level;
    SEqualCollectLevel(uint32 level) : collect_level(level) {}
    bool operator () (const SUserCopyMaterial &obj)
    {
        return obj.collect_level == collect_level;
    }
};

void CheckCreateCollectPoint(SUser *p_user, uint32 collect_skill_level)
{
    CopyMaterialList::iterator find_iter = std::find_if(p_user->data.copy_material_list.begin(), p_user->data.copy_material_list.end(), SEqualCollectLevel(collect_skill_level));
    if (find_iter == p_user->data.copy_material_list.end())
    {
        SUserCopyMaterial obj;
        obj.collect_level = collect_skill_level;
        obj.left_collect_times = kMaterialCollectMaxTime;
        p_user->data.copy_material_list.push_back(obj);
        ReplyCopyMaterialPoint(p_user, obj);
    }
}

void CopyMaterialRefresh(SUser *p_user)
{
    uint32 time_now = server::local_time();
    bool update_flag = false;
    for (CopyMaterialList::iterator iter = p_user->data.copy_material_list.begin();
        iter != p_user->data.copy_material_list.end();
        ++iter)
    {
        if (iter->del_timestamp == 0 || iter->del_timestamp > time_now)
            continue;
        uint32 time_pass = time_now - iter->del_timestamp;
        if (time_pass < kMaterialRefreshInterval)
            continue;
        uint32 add_times = time_pass / kMaterialRefreshInterval;
        iter->left_collect_times += add_times;
        if (iter->left_collect_times >= kMaterialCollectMaxTime)
        {
            iter->left_collect_times = kMaterialCollectMaxTime;
            iter->del_timestamp = 0;
        }
        else
        {
            uint32 fragment_time = time_pass % kMaterialRefreshInterval;
            iter->del_timestamp = time_now - fragment_time;
        }
        update_flag = true;
    }

    if (update_flag)
        ReplyCopyMaterialList(p_user);
}

void Collect(SUser *p_user, uint32 collect_level)
{
    CopyMaterialList::iterator find_iter = std::find_if(p_user->data.copy_material_list.begin(), p_user->data.copy_material_list.end(), SEqualCollectLevel(collect_level));
    if (find_iter == p_user->data.copy_material_list.end())
        return;
    if (find_iter->left_collect_times == 0)
    {
        HandleErrCode(p_user, kErrPaperCollectTimeLimit, 0);
        return;
    }

    CCopyMaterialData::SData *p_copy_material = theCopyMaterialExt.Find(collect_level);
    if (!p_copy_material)
        return;
    CPaperSkillData::SData *p_paper_skill = thePaperSkillExt.Find(p_user->data.other.paper_skill);
    if (!p_paper_skill)
        return;

    // 下标容错
    uint32 index = p_paper_skill->skill_type - 1;
    if (index >= p_copy_material->materials.size())
        return;
    uint32 material_id = p_copy_material->materials[index];

    // 消耗活跃值
    S3UInt32 cost = coin::create(kCoinActiveScore, 0, p_copy_material->active_score);
    uint32 ret = coin::check_take(p_user, cost);
    if (ret != 0)
    {
        HandleErrCode(p_user, kErrCoinLack, ret);
        return;
    }
    coin::take(p_user, cost, kPathPaperCreate);

    // 采集
    uint32 num = TRand(p_copy_material->min_num, p_copy_material->max_num + 1);
    S3UInt32 item = coin::create(kCoinItem, material_id, num);
    coin::give(p_user, item, kPathCopyCollect);
    ReplyCollect(p_user, material_id, num);

    // 更新
    find_iter->left_collect_times--;
    if (find_iter->del_timestamp == 0)
        find_iter->del_timestamp = server::local_time();
    ReplyCopyMaterialPoint(p_user, *find_iter);
}

void TimeLimit(SUser *p_user)
{
    uint32 base = theGlobalExt.get<uint32>("base_active_score_limit");
    CPaperSkillData::SData *p_paper_skill = thePaperSkillExt.Find(p_user->data.other.paper_skill);
    if (p_paper_skill)
        base = p_paper_skill->active_score_limit;

    S3UInt32 tmp = coin::create(kCoinActiveScore, 0, 0);
    uint32 left_active_score = coin::count(p_user, tmp);
    // 超过活跃值上限的部分清零
    if (left_active_score > base)
    {
        tmp.val = left_active_score - base;
        coin::take(p_user, tmp, kPathActiveScoreReset);
    }
}

void ReplyCopyMaterialList(SUser *p_user)
{
    PRPaperCopyMaterial rep;
    rep.material_list = p_user->data.copy_material_list;
    bccopy(rep, p_user->ext);
    local::write(local::access, rep);
}

void ReplyCopyMaterialPoint(SUser *p_user, SUserCopyMaterial &obj)
{
    PRPaperCopyMaterialPoint rep;
    rep.info = obj;
    bccopy(rep, p_user->ext);
    local::write(local::access, rep);
}

void ReplyCollect(SUser *p_user, uint32 item_id, uint32 num)
{
    PRPaperCollect rep;
    rep.item_id = item_id;
    rep.num = num;
    bccopy(rep, p_user->ext);
    local::write(local::access, rep);
}

bool GetInfo(SUser *p_user, uint32 &skill_type, uint32 &max_level)
{
    CPaperSkillData::SData *p_paper_skill = thePaperSkillExt.Find(p_user->data.other.paper_skill);
    if (!p_paper_skill)
        return false;

    skill_type = p_paper_skill->skill_type;
    max_level = p_paper_skill->paper_level_limit;

    return true;
}

} // namespace paper
