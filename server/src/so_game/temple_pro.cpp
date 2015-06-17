#include "misc.h"
#include "temple_imp.h"
#include "netsingle.h"
#include "user_dc.h"
#include "proto/temple.h"

MSG_FUNC(PQTempleInfo)
{
    QU_ON(user, msg.role_id);

    temple::ReplyTempleInfo(user);
}

MSG_FUNC(PQTempleGroupLevelUp)
{
    QU_ON(user, msg.role_id);

    temple::GroupLevelUp(user, msg.group_id);
}

MSG_FUNC(PQTempleOpenHole)
{
    QU_ON(user, msg.role_id);

    temple::OpenHole(user, msg.hole_type, msg.is_use_item);
}

MSG_FUNC(PQTempleEmbedGlyph)
{
    QU_ON(user, msg.role_id);

    temple::EmbedGlyph(user, msg.hole_type, msg.hole_index, msg.glyph_guid);
}

MSG_FUNC(PQTempleGlyphTrain)
{
    QU_ON(user, msg.role_id);

    temple::TrainGlyph(user, msg.main_guid, msg.eated_guid);
}

MSG_FUNC(PQTempleTakeScoreReward)
{
    QU_ON(user, msg.role_id);

    temple::TakeScoreReward(user, msg.reward_id);
}
