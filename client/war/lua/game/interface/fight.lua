--触发双人战斗
Command.bind("fight apply",
	function (target_id)
		trans.send_msg("PQPlayerFightApply", {target_id = target_id})
	end
)
--触发战斗
Command.bind("fight common_apply", 
	function (attr, target_id)
		trans.send_msg("PQCommonFightApply", {attr=attr, target_id=target_id})
	end
)

--战斗技能确认
Command.bind("fight syn",
	function (fight_id, seqno)
		trans.send_msg("PQPlayerFightSyn", {fight_id = fight_id, seqno = seqno})
	end
)

--战斗请求技能
Command.bind("fight ack",
	function (fightId, guid, order_id, order_level)
		trans.send_msg("PQPlayerFightAck", {fight_id = fightId, fight_order = {guid = guid, order_id = order_id, order_level = order_level}})
	end
)

Command.bind("fight clientend",
	function (fight_id, order_list, fight_info_list, win_camp, is_roundout, fightEndInfo)
		trans.send_msg("PQCommonFightClientEnd", {fight_id=fight_id, order_list=order_list, fight_info_list=fight_info_list, win_camp=win_camp, is_roundout=is_roundout, fightEndInfo=fightEndInfo})
	end
)

--竞技场战斗请求
Command.bind("fight arena",
    function (type, id)
        trans.send_msg( 'PQFightSingleArenaApply', { attr = type , target_id = id } )
    end
)

--回看战报
Command.bind("fight replay",
    function (id)
        trans.send_msg( 'PQFightRecordGet', { guid = id } )
    end
)

--回看战报
Command.bind("fight quit",
    function (id)
        trans.send_msg( 'PQPlayerFightQuit', { fight_id = id } )
    end
)

-- 触发假人战斗
Command.bind("fight common_auto",
	function (target_id)
		trans.send_msg("PQCommonFightAuto", {target_id=target_id})
	end
)

