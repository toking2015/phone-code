--战斗
Command.bind("tomb fight",
	function (player_index, player_guid, formation_list)
		trans.send_msg("PQTombFight", {player_index = player_index, player_guid = player_guid, formation_list = formation_list})
	end
)

--领奖
Command.bind("tomb reward",
	function (reward_index)
		trans.send_msg("PQTombRewardGet", {reward_index = reward_index})
	end
)

--玩家重置
Command.bind("tomb player_reset",
	function (player_index)
		trans.send_msg("PQTombPlayerReset", {player_index = player_index})
	end
)

--重置
Command.bind("tomb reset",
	function ()
		trans.send_msg("PQTombReset", {})
	end
)

--扫荡
Command.bind("tomb mop_up",
	function ()
		trans.send_msg("PQTombMopUp", {})
	end
)

--
Command.bind("tomb info",
	function ()
		trans.send_msg("PQTombInfo", {})
	end
)

--目标信息
Command.bind("tomb target_list",
	function ()
		trans.send_msg("PQTombTargetList", {})
	end
)

--请求玩家大墓地相关数据
Command.bind("tomb panel",
	function (target_id)
		trans.send_msg("PQUserTombPanel", {target_id = target_id})
	end
)