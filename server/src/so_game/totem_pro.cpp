#include "misc.h"
#include "totem_imp.h"
#include "netsingle.h"
#include "user_dc.h"
#include "proto/totem.h"

MSG_FUNC(PQTotemInfo)
{
    QU_ON(user, msg.role_id);

    totem::ReplyTotemInfo(user);
}

MSG_FUNC(PQTotemBless)
{
    QU_ON(user, msg.role_id);

    totem::Bless(user, msg.totem_guid, msg.skill_type);
}

MSG_FUNC(PQTotemAccelerate)
{
    QU_ON(user, msg.role_id);

    totem::Accelerate(user, msg.totem_guid, (msg.is_free != 0));
}

MSG_FUNC(PQTotemGlyphMerge)
{
    QU_ON(user, msg.role_id);
}

MSG_FUNC(PQTotemGlyphEmbed)
{
    QU_ON(user, msg.role_id);
}

MSG_FUNC(PQTotemActivate)
{
    QU_ON(user, msg.role_id);

    totem::Activate(user, msg.totem_id);
}
