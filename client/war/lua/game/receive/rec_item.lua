--返回物品列表
trans.call.PRItemList = function(msg)
    ItemData.setTable( msg.bag_index, msg.item_list )
    EventMgr.dispatch( EventType.UserItemUpdate )
end 

trans.call.PRItemSet = function(msg)
    if const.kObjectAdd == msg.set_type then 
        if const.kPathCopyPassEquip == msg.path then
            CopyMgr.equipPush(msg.item)
        end
    end

    if trans.const.kObjectDel ~= msg.set_type then
        if msg.item.item_id >= 1031 and msg.item.item_id <= 1038 then 
            BagSale:setData( msg.item, BagSale.TypeUse )
            PopMgr.popUpWindow("BagSale", false, PopUpType.SPECIAL )
        end
    end

    gameData.changeArray( ItemData.getTable( msg.item.bag_type ), 'guid', msg.set_type, msg.item )
    EventMgr.dispatch( EventType.UserItemUpdate )
    EventMgr.dispatch(EventType.CopyPtViewItem)
    EventMgr.dispatch(EventType.UpdateCopyBoss)

    if msg.set_type == const.kObjectAdd then
    	EventMgr.dispatch( EventType.UserItemAdd, msg.item.item_id )
    end
end

trans.call.PRItemMerge = function(msg)
    EventMgr.dispatch( EventType.UserItemMerge, msg.id, msg.count )
end

trans.call.PRItemEquipSkill = function (msg)
	Command.run('ui hide', 'SkillBookMergeUI')
end

trans.call.PRItemUse = function (msg)
    if msg.count > 0 then
        local item = findItem(msg.item_id)
        if item and item.type == const.kItemTypeGift then
            TipsMgr.showSuccess("领取成功")
        end
    end
end