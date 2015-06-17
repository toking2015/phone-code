trans.call.PRTeamChangeName = function(msg)
	gameData.setSimpleDataByKey("name", msg.name)
	TeamData.addChangeNameCount() --增加改名次数
	TeamData.forceRename = false --取消强制改名
	EventMgr.dispatch(EventType.TeamNameChange)
	TipsMgr.showGreen("恭喜你，改名成功")
end

trans.call.PRTeamLevelUp = function(msg)
    EventMgr.dispatch(EventType.InfLevelUp)
	EventMgr.dispatch(EventType.TeamLevelUp, msg)
	CopyMgr.checkOpenNextCopy(msg.old_level, msg.new_level)
	VXinYouMgr.role_upgrade(msg.new_level)
	VXinYouMgr.ad_update_level(msg.new_level)
end

EventMgr.addListener("kErrTeamNameHave", function()
	TipsMgr.showError("名字已存在")
end)

trans.call.PRPresentGlobalTake = function(msg)
	EventMgr.dispatch(EventType.TeamCDKeyTakeRusult, msg)
end
