#include "misc.h"
#include "equip_imp.h"
#include "item_imp.h"
#include "var_imp.h"
#include "netsingle.h"
#include "local.h"
#include "proto/equip.h"
#include "resource/r_globalext.h"
#include "user_dc.h"

MSG_FUNC(PQEquipMerge)
{
    QU_ON(user, msg.role_id);
    uint32 first_id = theGlobalExt.get<uint32>("equip_merge_first_id");
    std::string var_key("equip_merge_first_flag");
    uint32 first_flag = var::get(user, var_key);
    if (first_id == msg.id && first_flag == 0)
    {
        // add at a very late time
        if (!equip::FixedMerge(user, msg.id))
            return;
        var::set(user, var_key, 1);
    }
    else if (!item::Merge(user, msg.id, 1))
    {
        return;
    }

    std::vector<SUserItem> &item_list = user->data.item_map[kBagFuncSoldierEquipTemp];
    if (item_list.empty())
        return;

    PREquipMerge rep;
    rep.item = *(item_list.rbegin());
    bccopy(rep, user->ext);
    local::write(local::access, rep);
}

MSG_FUNC(PQEquipReplace)
{
    QU_ON(user, msg.role_id);
    if (!equip::Replace(user, msg.equip_guid, msg.is_replace))
        return;

    PREquipReplace rep;
    rep.is_replace = msg.is_replace;
    bccopy(rep, user->ext);
    local::write(local::access, rep);
}

MSG_FUNC(PQEquipSelectSuit)
{
    QU_ON(user, msg.role_id);
    equip::SelectSuit(user, msg.equip_type, msg.select_level);
}
