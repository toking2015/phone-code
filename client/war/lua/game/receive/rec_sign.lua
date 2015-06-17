trans.call.PRSign = function(msg)
	SignData.addMarkLog(msg.sign)
    EventMgr.dispatch(EventType.UserMarkUpdate)
    TipsMgr.floatingNode(UIFactory.getSprite("image/ui/SignUI/result_qdcg.png"), visibleSize.width / 2, visibleSize.height / 2)
    -- local jSign = findSignDay(msg.sign.day_id)
    -- if jSign then
    -- 	showGetEffect(jSign.rewards)
    --     TipsMgr.showItemObtained(jSign.rewards)
    -- end
    SignData.getCanGet(true)
end

trans.call.PRTakeSignSumReward = function (msg)
	SignData.addRewardLog(msg.reward_id)
	EventMgr.dispatch(EventType.UserMarkReward)
    local jReward = findSignSum(msg.reward_id)
    -- if jReward then
    --     showGetEffect(jReward.rewards)
    --     TipsMgr.showItemObtained(jReward.rewards) 
    -- end
	SignData.getCanGet(true)
end

trans.call.PRTakeHaohuaReward = function (msg)
    EventMgr.dispatch(EventType.UserMarkReward)
    SignData.getCanGet(true)
end