
TrialRewardLabel = createUILayout('TrialRewardLabel', TrialMgr.prePath .. "TrialRewardUI/TrialRewardLabel.ExportJson")
function TrialRewardLabel:ctor(index)
	self.index = index
end

function TrialRewardLabel:setData(json, __this, callback)
	self.trialRewardCount = json
	self.label1:setString(json.trial_val)
	self.label2:setString('1')

	self.label1:setColor(cc.c3b(0xff, 0xd7, 0x92))
	self.label2:setColor(cc.c3b(0xff, 0xd7, 0x92))

	-- UIMgr.addTouchEnded(self, 
	-- 	function (...)
	-- 		callback(__this, json, self.index)
	-- 		-- self.bg:loadTexture("TrialReward_Bg4.png", ccui.TextureResType.plistType)
	-- 		-- self.bg:loadTexture(TrialMgr.prePath .. "TrialRewardUI/TrialReward_Bg2.png", ccui.TextureResType.localType)
	-- 	end
	-- 	)
end

function TrialRewardLabel:updateData()
	local userTrial = TrialMgr.getTrial(self.trialRewardCount.trial_id)
	if not userTrial then
		self.label1:setColor(cc.c3b(0xff, 0xff, 0xff))
		self.label2:setColor(cc.c3b(0xff, 0xff, 0xff))
		self.label3:setColor(cc.c3b(0x55, 0x2b, 0x23))
		self.label3:setString("未达成")
		self.bg:loadTexture("TrialReward_Bg4.png", ccui.TextureResType.plistType)
		return
	end

	if userTrial.trial_val < self.trialRewardCount.trial_val then
		self.label1:setColor(cc.c3b(0x55, 0x2b, 0x23))
		self.label2:setColor(cc.c3b(0x55, 0x2b, 0x23))
		self.label3:setString("未达成")
		self.label3:setColor(cc.c3b(0x55, 0x2b, 0x23))
		self.bg:loadTexture("TrialReward_Bg4.png", ccui.TextureResType.plistType)
	elseif userTrial.reward_count + 1 == self.index then
		self.label1:setColor(cc.c3b(0xff, 0xff, 0xff))
		self.label2:setColor(cc.c3b(0xff, 0xff, 0xff))
		self.label3:setString("领取中")
		self.label3:setColor(cc.c3b(0xfc, 0xff, 0x00))
		self.bg:loadTexture(TrialMgr.prePath .. "TrialRewardUI/TrialReward_Bg2.png", ccui.TextureResType.localType)
	elseif userTrial.reward_count + 1 < self.index then
		self.label1:setColor(cc.c3b(0xff, 0xff, 0xff))
		self.label2:setColor(cc.c3b(0xff, 0xff, 0xff))
		self.label3:setString("可领取")
		self.label3:setColor(cc.c3b(0x60, 0xff, 0x00))
		self.bg:loadTexture(TrialMgr.prePath .. "TrialRewardUI/TrialReward_Bg2.png", ccui.TextureResType.localType)
	else
		self.label1:setColor(cc.c3b(0x55, 0x2b, 0x23))
		self.label2:setColor(cc.c3b(0x55, 0x2b, 0x23))
		self.label3:setString("已领取")
		self.label3:setColor(cc.c3b(0x55, 0x2b, 0x23))
		self.bg:loadTexture(TrialMgr.prePath .. "TrialRewardUI/TrialReward_Bg2.png", ccui.TextureResType.localType)
	end
end