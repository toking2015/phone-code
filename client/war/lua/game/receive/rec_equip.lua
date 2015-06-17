trans.call.PREquipSelectSuits = function(msg)
    GameData.user.equip_suit_level = msg.select_suits
    EventMgr.dispatch( EventType.UserItemUpdate )
end


trans.call.PREquipReplace = function(msg)
    EventMgr.dispatch( EventType.UserMergeReplace, msg.is_replace )
end

trans.call.PREquipMerge = function(msg)
    EventMgr.dispatch( EventType.UserEquipMerge, msg.item.item_id )
end
