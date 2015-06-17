#ifndef _GAMESVR_TEMPLE_IMP_H_
#define _GAMESVR_TEMPLE_IMP_H_

#include "common.h"
#include "proto/common.h"
#include "proto/fight.h"
#include "proto/user.h"
#include "proto/temple.h"
#include "dynamicmgr.h"
#include "fightextable_imp.h"
#include "resource/r_monsterfightconfext.h"
#include "resource/r_templegroupext.h"
#include "resource/r_templegrouplevelupext.h"
#include "resource/r_templeglyphext.h"
#include "resource/r_templeglyphattrext.h"
#include "resource/r_templescorerewardext.h"
#include "resource/r_templeholeext.h"
#include "resource/r_templesuitattrext.h"

// 神殿
namespace temple
{
    void TakeScoreReward(SUser *user, uint32 reward_id);
    void GroupLevelUp(SUser *user, uint32 group_id);
    void OpenHole(SUser *user, uint32 hole_type, bool is_use_item);
    void EmbedGlyph(SUser *user, uint32 hole_type, uint32 hole_index, uint32 glyph_guid);
    void TrainGlyph(SUser *user, uint32 main_guid, uint32 eated_guid);
    void OnLogin(SUser *user);
    void TimeLimit(SUser *user);
    void ReplyTempleInfo(SUser *user);
    void AddGlyph(SUser *user, uint32 glyph_id, uint32 path);
    void CheckAddGroup(SUser *user);
    void CalTempleScore(SUser *user);
    void AddTempleOdd(SUser *user, SUserSoldier &soldier, std::vector<SFightOdd> &odd_list);
    SFightExtAble GetTempleExt(SUser *user, SUserSoldier &soldier, SFightExtAble &able);
    uint32 GetScore(SUser *user);
    uint32 GetGroupLevel(SUser *user, uint32 group_id);
    uint32 GetGroupStar(SUser *user, uint32 group_id);
    uint32 GetGlyphTotalExp(const STempleGlyph &glyph);
    uint32 GetGlyphCount(SUser *user, uint32 glyph_id);
    uint32 GetEmbedGlyphCountByQuality(SUser *user, uint32 quality);
    STempleGroup* GetGroup(SUser *user, uint32 group_id);
    STempleGlyph* GetGlyph(SUser *user, uint32 guid);
} // namespace temple

#endif
