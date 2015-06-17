#ifndef _GAMESVR_PAPER_LOGIC_H_
#define _GAMESVR_PAPER_LOGIC_H_

#include "common.h"
#include "dynamicmgr.h"
#include "proto/user.h"

namespace paper
{
    typedef std::vector<SUserCopyMaterial> CopyMaterialList;
    void LevelUp(SUser *p_user, uint32 skill_type);
    void CountLearnCost(uint32 id, uint32 &sum_star, uint32 &sum_money);
    void Forget(SUser *p_user);
    void CreatePaper(SUser *p_user, uint32 paper_id);
    // 检测创建新的材料采集资源点
    void CheckCreateCollectPoint(SUser *p_user, uint32 collect_skill_level);
    void CopyMaterialRefresh(SUser *p_user);
    void Collect(SUser *p_user, uint32 copy_id);
    void TimeLimit(SUser *p_user);
    void ReplyCopyMaterialList(SUser *p_user);
    void ReplyCopyMaterialPoint(SUser *p_user, SUserCopyMaterial &obj);
    void ReplyCollect(SUser *p_user, uint32 item_id, uint32 num);
    // @skill_type : 技能类型
    // @max_level : 可制作装备最高等级
    bool GetInfo(SUser *p_user, uint32 &skill_type, uint32 &max_level);
} // namespace paper

#endif
