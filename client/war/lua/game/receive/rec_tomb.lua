
trans.call.PRTombTargetList = function(msg)
	TombData:setTargetList(msg.tomb_target_list)
end

trans.call.PRTombInfo = function(msg)
	TombData.tombReset(msg.info)
end

trans.call.PRTombMopUp = function(msg)
	EventMgr.dispatch(EventType.ShowTomb, msg.reward_list)
end

trans.call.PRTombReset = function(msg)
	TombData.tombReset(msg.tomb_info, msg.tomb_target_list, true)
end

trans.call.PRTombPlayerReset = function(msg)
	TombData.setTarget(msg.player_index, msg.target)
end

trans.call.PRTombRewardGet = function(msg)
	--显示奖励
	CoinData.openRewardGetUI( msg.reward_list )
	TombData.setReward(msg.target)
end

trans.call.PRUserTombPanel = function(msg)
	TombData:setPanel(msg.target_id, msg.data)
end