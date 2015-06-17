require "lua/game/view/trialUI/TrialMgr.lua"
require "lua/game/view/trialUI/TrialRewardLabel.lua"
require "lua/game/view/trialUI/TrialRewardCard.lua"

TrialRewardMain = createUIClass("TrialRewardMain", TrialMgr.prePath .. "TrialRewardUI/TrialRewardMain.ExportJson", PopWayMgr.SMALLTOBIG)
function TrialRewardMain:ctor()
	-- UIFactory.getWindowBg(self)
	self.trial = TrialMgr.currentTrial

	self.labelTitle = nil
	self.labelList = {}
	for i = 1, 9, 1 do
		local label = TrialRewardLabel.new(i - 1)
		self.Image_4:addChild(label)

		label:setPosition(7, 400 - 49 * label.index)

		if 1 == i then
			self.labelTitle = label
		else
			table.insert(self.labelList, label)
		end
	end

	self.image = UIFactory.getSprite(TrialMgr.prePath .. "TrialRewardUI/TrialReward_Bg3.png", self)
	self.image.size = self.image:getContentSize()
	self.image:setPosition(self.labelList[1]:getPositionX() + self.image.size.width / 2 + 14, 394)

	createScaleButton(self.btn_image)
	self.btn_image:addTouchEnded(function()
		if not TrialMgr.checkRewardEnd(self.userTrial, self.trial.id, self.index) then
			return
		end
		
		TrialMgr.showRewardList(self.trial.id)
		Command.run("trial reward_end", TrialMgr.currentTrial.id)
	end)

	self.index = 1
	if self.trial then
		self.jsonTrialRewardCounts = TrialMgr.getJsonRewardCounts(self.trial.id)
		for i, json in pairs(self.jsonTrialRewardCounts) do
			local label = self.labelList[i]
			label:setData(json, self, self.callback)
		end
	end
end

function TrialRewardMain:delayInit()
	self.cardList = {}
	for i = 1, 6, 1 do
		local card = TrialRewardCard.new(i - 1)
		table.insert(self.cardList, card)
		self:addChild(card)

		card:setPosition(439 + ((i - 1) % 3) * 187, 291 - (math.floor((i - 1) / 3)) * 223)
	end
	self:doOnShow() --执行显示
end

function TrialRewardMain:onShow()
	performNextFrame(self, self.doOnShow, self)
end

function TrialRewardMain:doOnShow()
	performNextFrame(self, self.updateData, self)
	EventMgr.addListener(EventType.TrialRewardUpdate, self.updateData, self)
	EventMgr.addListener(EventType.TrialUpdate, self.updateData, self)
end

function TrialRewardMain:onClose()
	TrialMgr.currentTrial = nil
	EventMgr.removeListener(EventType.TrialRewardUpdate, self.updateData)
	EventMgr.removeListener(EventType.TrialUpdate, self.updateData)
end

function TrialRewardMain:updateData()
	if not self.trial then
		return
	end
	local userTrial = TrialMgr.getTrial(self.trial.id)
	if not userTrial then
		return
	end

	self.userTrial = userTrial
	self:callback(nil, userTrial.reward_count + 1)
	self.Image_4.label:setString("今日累计治疗与伤害量：" .. userTrial.trial_val)
	
	-- if 1 == self.trial.id then
	-- 	self.Image_4.label:setString("今日累计生存回合：" .. userTrial.trial_val)
	-- elseif 2 == self.trial.id then
	-- 	self.Image_4.label:setString("今日累计伤害量：" .. userTrial.trial_val)
	-- elseif 3 == self.trial.id then
	-- 	self.Image_4.label:setString("今日累计出手和闪避量：" .. userTrial.trial_val)
	-- else
	-- 	self.Image_4.label:setString("今日累计治疗与伤害量：" .. userTrial.trial_val)
	-- end

	for __, label in pairs(self.labelList) do
		label:updateData()
	end

	local list = TrialMgr.getRewardCounts(TrialMgr.currentTrial.id)
	local index = 1
	if userTrial.reward_count + 1 > 8 then
		index = 5
	else
		for __, value in pairs(list) do
			if 1 == value.flag then
				index = index + 1
			end
		end
	end

	for i, userTrialReward in pairs(list) do
		local card = self.cardList[i]
		card:setData(userTrial, 
			userTrialReward, 
			self.jsonTrialRewardCounts[index].reward_cost or {cate=0, objid=0, val=0}, 
			index,
			self.jsonTrialRewardCounts[self.index])
	end
end

function TrialRewardMain:callback(trial, index)
	if index > #self.labelList then
		index = #self.labelList
	end

	if index ~= self.index then
		for i, card in pairs(self.cardList) do
			card:clear()
		end
	end

	self.image:setPositionY(444 - index * 49)
	self.index = index
	-- __this:updateData()
end