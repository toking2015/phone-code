trans.call.PRActivityOpenLoad = function(msg)
	local list = ActivityData.activityList.activity_open_list 
	if list then
		list = msg.list
	end
	EventMgr.dispatch(EventType.activityListUpdate)
end

trans.call.PRActivityDataLoad = function(msg)
	local list = ActivityData.activityList.activity_data_list 
	if list then
		list = msg.list
	end
	EventMgr.dispatch(EventType.activityListUpdate)
end

trans.call.PRActivityFactorLoad = function(msg)
	local list = ActivityData.activityList.activity_factor_list 
	if list then
		list = msg.list
	end
	EventMgr.dispatch(EventType.activityListUpdate)
end

trans.call.PRActivityRewardLoad = function(msg)
	local list = ActivityData.activityList.activity_reward_list 
	if list then
		list = msg.list
	end
	EventMgr.dispatch(EventType.activityListUpdate)
end

trans.call.PRActivityList = function(msg)
	ActivityData.activityList = msg
	EventMgr.dispatch(EventType.activityListUpdate)
end

trans.call.PRActivityInfoList = function(msg)
	ActivityData.activityInfoList = msg.list
	EventMgr.dispatch(EventType.activityListUpdate)
end

--领取奖励
trans.call.PRActivityTakeReward = function(msg)
	EventMgr.dispatch(EventType.activityGetReward)
end