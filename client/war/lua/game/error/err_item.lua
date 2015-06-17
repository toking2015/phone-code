EventMgr.addListener("kErrItemUseLimitLevel", function ( ... )
	TipsMgr.showError("物品使用等级不足")
end)

EventMgr.addListener("kErrStrengthFull", function ( ... )
	TipsMgr.showError("体力太多，先消耗一些吧")
end)
