-- 返回好友列表
trans.call.PRFriendList = function(msg)
	LogMgr.debug( 'friend', '[好友列表返回] 列表长度 = ' .. #msg.friend_list..'\n')
	FriendData:setFriendList(msg.friend_list)
	EventMgr.dispatch( EventType.FriendUpdata )
end

-- 加好友返回
trans.call.PRFriendRequest = function(msg)
	LogMgr.debug( 'friend', '[被加好友通知回] 对方id = ' .. msg.target_id..'\n')
	FriendData:addAskeFriend(msg.info)
	EventMgr.dispatch( EventType.FriendUpdata )
	--FriendData:setFriendList(msg.friend_list)
	--FriendData:addAskeFriend(msg.targetid)
end

-- 被加好友通知
trans.call.PRFriendMake = function(msg)
	LogMgr.debug( 'friend PRFriendMake', '[被加好友] 对方id = ' .. msg.target_id..'\n')
	EventMgr.dispatch( EventType.FriendUpdata )
	--FriendData:setFriendList(msg.friend_list)
end

-- 好友数据更新
trans.call.PRFriendUpdate = function(msg)
	LogMgr.debug( 'friend', '[好友数据更新] \n')
	FriendData:updateFrinedData(msg)
	EventMgr.dispatch( EventType.FriendUpdata )
end

-- 返回消息
trans.call.PRFriendMsg = function(msg)
	LogMgr.debug( 'friend', '[消息返回] 对方id= ' .. msg.friend_id..'\n')
	--FriendData:updateFriendData(msg)
end

-- 好友推荐回复
trans.call.PRFriendRecommend = function(msg)
	LogMgr.debug( 'friend', '[推荐返回] 返回列表长度= ' .. #msg.target_id_list..'\n')
	FriendData:setRecommendList(msg.friend_list)
	EventMgr.dispatch( EventType.FriendRecomChange )
end

-- 好友限制列表
trans.call.PRFriendLimitList = function(msg)
	LogMgr.debug( 'friend', '[好友限制列表] 返回列表长度= ' .. #msg.limit_list..'\n')
	FriendData:setFriendLimitList(msg.limit_list)
	EventMgr.dispatch( EventType.FriendLimitChange )
end
-- 好友限制数据更新
trans.call.PRFriendLimitUpdate = function(msg)
	LogMgr.debug( 'friend', '[好友限制数据更新] \n')
	FriendData:updateFrinedLimitData(msg)
	local tick_id
	local function runLater()
		EventMgr.dispatch( EventType.FriendLimitChange )
		TimerMgr.killTimer(tick_id)
	end
	tick_id = TimerMgr.startTimer(runLater, 1)
end

-- 赠送返回
trans.call.PRFriendGive = function(msg)
	LogMgr.debug( 'friend', '[赠送返回] \n')
	if msg and msg.give_type == trans.const.kFriendGiveOne then --手工活力
		TipsMgr.showGreen("成功向好友赠送10手工活力")
	else
		TipsMgr.showGreen("赠送成功")
	end
	FriendData:updateOrClearLimitSelcetData()
	EventMgr.dispatch( EventType.FriendLimitChange )
end
