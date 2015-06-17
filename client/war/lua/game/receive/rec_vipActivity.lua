trans.call.PRVipTimeLimitShopWeek = function(msg)
	EventMgr.dispatch(EventType.VipTimeWeek, {now_week = msg.now_week, next_refresh_time = msg.next_refresh_time})
end

trans.call.PRVipTimeLimitShopBuy = function(msg)
	-- gameData.changeMap( VipActivityData.getVipActivityList(), msg.buyed_info.vip_package_id, msg.set_type, msg.buyed_info )
	gameData.changeArrayByValue(VipActivityData.getVipActivityList(), 'vip_package_id', msg.set_type, msg.buyed_info, msg.buyed_info.vip_package_id)
	EventMgr.dispatch(EventType.VipBuyPackage, msg.buyed_info)
end