EventMgr.addListener("kErrTrialRewardHave", function ( ... )
	TipsMgr.showError("奖励已经领取")
end)

EventMgr.addListener("kErrTrialRewardDataNoExitLevel", function ( ... )
	TipsMgr.showError("这个等级的奖励不存在")
end)

EventMgr.addListener("kErrTrialNotOpen", function ( ... )
	TipsMgr.showError("暂不开放")
end)

EventMgr.addListener("kErrTrialTryCount", function ( ... )
	TipsMgr.showError("进入次数已经满")
end)

EventMgr.addListener("kErrTrialRewardValNot", function ( ... )
	TipsMgr.showError("试炼值不够")
end)