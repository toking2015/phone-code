trans.call.PRTrialRewardList = function( msg )
	TrialMgr.rewardUpdate(msg.id, msg.reward_list)
end

trans.call.PRTrialUpdate = function(msg)
	TrialMgr.trialUpdata(msg.user_trial)
end

trans.call.PRTrialRewardGet = function (msg)
	TrialMgr.SetReward(msg.id, msg.index)
end

trans.call.PRTrialRewardEnd = function(msg)
	
end

trans.call.PRTrialMopUp = function (msg)
	EventMgr.dispatch(EventType.ShowTrial, msg)
end