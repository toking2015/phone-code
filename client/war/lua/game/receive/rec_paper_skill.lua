trans.call.PRPaperCreate = function (msg)
	PaperCreateUI:createFinish(msg.paper_id)
end

trans.call.PRPaperCopyMaterial = function(msg)
    LogMgr.debug(">>>>>>>> PRPaperCopyMaterial" .. debug.dump(msg))
    gameData.user.copy_material_list = msg.material_list
    EventMgr.dispatch(EventType.UpdateMaterial)
end

trans.call.PRPaperCopyMaterialPoint = function (msg)
    LogMgr.debug(">>>>>>>>  PRPaperCopyMaterialPoint" .. debug.dump(msg))
    gameData.user.copy_material_list[msg.info.collect_level] = msg.info
    EventMgr.dispatch(EventType.UpdateMaterialPoint, msg.info)
end

trans.call.PRPaperCollect = function(msg)
	-- local list = {{cate = const.kCoinItem, objid = msg.item_id, val = msg.num}}
	-- showGetEffect(list)
	-- TipsMgr.showItemObtained(list)
end

EventMgr.addListener("kErrPaperCollectTimeLimit", function ()
    TipsMgr.showError("采集次数不足")
end)