Command.bind("team rename", function(name)
	trans.send_msg("PQTeamChangeName", {name=name})
end)

Command.bind("team avatar change", function(id)
	if id ~= gameData.getSimpleDataByKey("avatar") then
		gameData.user.simple.avatar = id
		EventMgr.dispatch( EventType.UserSimpleUpdate ) --直接假设成功
		trans.send_msg("PQTeamChangeAvatar", {avatar=id})
	end
end)

Command.bind("team levelup", function()
	trans.sentTimeoutMsg("PQTeamLevelUp", {})
end)

Command.bind("team cdkey take", function(cdkey)
	trans.send_msg("PQPresentGlobalTake", {code=cdkey})
end)
