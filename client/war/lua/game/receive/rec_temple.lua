--神殿信息
trans.call.PRTempleInfo = function(msg)
	TempleData.setData(msg.info)
end

--  升级组合
trans.call.PRTempleGroupLevelUp = function(msg)
	SoundMgr.playUI("ui_rolelevelup")
	TempleData.SetGroupInfo(msg.group)
	EventMgr.dispatch(EventType.TempleGroupLevelUp)
end

--  开神符孔
trans.call.PRTempleOpenHole = function(msg)
	TipsMgr.showGreen("成功开启一个神符格子")
end

--  镶嵌神符
trans.call.PRTempleEmbedGlyph = function(msg)
end

--  神符升级
trans.call.PRTempleGlyphTrain = function(msg)
	if msg.new_lv - msg.old_lv > 0 then
		SoundMgr.playUI("ui_rolelevelup")
		TipsMgr.showGreen("当前神符已升至"..msg.new_lv.."级")
	end
end

--  领取积分奖励
trans.call.PRTempleTakeScoreReward = function(msg)
end