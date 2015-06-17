
Command.bind("trial enter",
	function (target_id, formation_list)
		Command.run("loading wait show", "trian")
		trans.send_msg("PQTrialEnter", {id = target_id, formation_list = formation_list})
	end
)

Command.bind("trial reward_list",
	function (id)
		trans.send_msg("PQTrialRewardList", {id = id})
	end
)

Command.bind("trial reward_get",
	function (id, index)
		trans.send_msg("PQTrialRewardGet", {id = id, index = index})
	end
)

Command.bind("trial reward_end",
	function (id)
		trans.send_msg("PQTrialRewardEnd", {id = id})
	end
)

Command.bind("trial update",
	function ()
		trans.send_msg("PQTrialUpdate", {})
	end
)

Command.bind("trial mopup",
	function (trail_id)
		trans.send_msg("PQTrialMopUp", {id=trail_id})
	end
)