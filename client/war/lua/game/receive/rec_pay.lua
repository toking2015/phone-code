trans.call.PRPayList = function(msg)
    gameData.user.pay_list = msg.list
    EventMgr.dispatch( EventType.UserPayUpdate )
end

trans.call.PRPayInfo = function(msg)
    gameData.user.pay_info = msg.data
    EventMgr.dispatch( EventType.UserPayUpdate )
end

trans.call.PRPayOK = function(msg)
	EventMgr.dispatch( EventType.CheckPayOK)
end

trans.call.PRPayMonthReward = function(msg)
	EventMgr.dispatch( EventType.PayMonthReward )
end

trans.call.PRPayNotice = function(msg)
	VXinYouMgr.user_pay(msg.uid, msg.coin, gameData.getSimpleDataByKey("name"), gameData.getSimpleDataByKey("team_level"), PayData.payTime)
	VXinYouMgr.ad_pay(msg.uid, msg.coin, msg.platform or "")
end