

--试炼回合界面
FightRound = createUILayout("FightRound", FightFileMgr.prePath .. "Fight_Round/Fight_Round.ExportJson")
function FightRound:ctor(trial)
	self:retain()

	self.trial = trial
	self.image = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_" .. trial.id .. ".png")
	self:addChild(self.image)
	self.image:setPositionY(-28)
end
function FightRound:releaseAll()
	self.trial = nil

	self.image:removeFromParent()
	self:removeFromParent()
	self:release()
end
function FightRound:idle(time)
	local round = FightDataMgr.theFight.round
    if round < 10 then
	    self.number:setString('0' .. round)
	else
	    self.number:setString(round)
	end
end


--试炼回合界面
FightTrial = createUILayout("FightTrial", FightFileMgr.prePath .. "Fight_Trail/Fight_Trail.ExportJson")
function FightTrial:ctor(trial)
	self:retain()

	self.trial = trial
	self.starX = self.panel_2.star:getPositionX() - 271

	for i = 1, 4, 1 do
		if i == trial.id then
			self.panel_1["pro_" .. i]:setVisible(true)
		else
			self.panel_1["pro_" .. i]:setVisible(false)
		end
	end

	self.max = TrialMgr.getMaxVal(trial.id)
	self.val = 0
	self.lastVal = 0
	self.index = 0
	self.val_num = 0
	self.number:setString(0)
	self.textNumber = 0

	local userTrial = TrialMgr.getTrial(self.trial.id)
	self.lastTrialVal = 0
	if userTrial then
		self.lastTrialVal = userTrial.trial_val
	end

	self.max, self.index, self.val_num = TrialMgr.getMaxVal(trial.id, self.lastTrialVal)
	self.val = self.lastTrialVal - self.val_num
	self.lastVal = self.val
	self.number:setString(self.lastTrialVal)

	-- if 1 == trial.id then
	-- 	self.text:setString("生存回合：")
	-- elseif 2 == trial.id then
	-- 	self.text:setString("杀怪数量：")
	-- elseif 3 == trial.id then
	-- 	self.text:setString("伤害次数和闪避：")
	-- else
		self.text:setString("治疗与伤害量：")
	-- end

	local pro = 100 * self.lastVal / self.max
	self:getPro():setPercent(pro)

	self.number:setPositionX(self.text:getPositionX() + self.text:getSize().width)
	self.panel_2.star:setPositionX(self.starX + pro * 271 / 100)
end
function FightTrial:releaseAll()
	self.trial = nil

	self:removeFromParent()
	self:release()
end
function FightTrial:getPro()
	return self.panel_1["pro_" .. self.trial.id]
end
--总量更新
function FightTrial:idle(time)
    self.lastVal = self.val + (self.lastVal - self.val) * 0.75

    local pro = 100 * self.lastVal / (self.max - self.val_num)
    self:getPro():setPercent(pro)
    self.panel_2.star:setPositionX(self.starX + pro * 271 / 100)

    if self.lastVal + 0.05 + self.val_num >= self.max then
    	local max = self.max
    	local val_num = self.val_num
    	self.max, self.index, self.val_num = TrialMgr.getMaxVal(self.trial.id, self.lastVal + 0.05 + self.val_num)
    	if self.max > max then
    		self.lastVal = val_num + self.lastVal - self.val_num + 0.05
    		self.val = val_num + self.val - self.val_num

    		pro = 100 * self.lastVal / self.max
		    self:getPro():setPercent(pro)
		    self.panel_2.star:setPositionX(self.starX + pro * 271 / 100)
		-- else
		-- 	self.val = self.val - self.val_num
		-- 	self.lastVal = self.lastVal - self.val_num + 0.05
    	end
    end
		
	FightDataMgr.theFightUI:boxCountAdd(self.index)
end
--FightDataMgr:runNumber
function FightTrial:set_value(endInfoList)
	local val = self.lastValue

	local leftEndInfo = endInfoList[FightAnimationMgr.camp]
	local rightEndInfo = nil
	if const.kFightLeft == FightAnimationMgr.camp then
		rightEndInfo = endInfoList[const.kFightRight]
	else
		rightEndInfo = endInfoList[const.kFightLeft]
	end

	-- if 1 == self.trial.id then
	-- 	val = leftEndInfo.round
	-- elseif 2 == self.trial.id then
	-- 	val = rightEndInfo.dead_count
	-- elseif 3 == self.trial.id then
	-- 	val = leftEndInfo.attack_count + leftEndInfo.dodge_count
	-- else
		val = leftEndInfo.recover + leftEndInfo.hurt
	-- end

	if not val then
		val = 0
	end

    self.val = self.lastTrialVal + val - self.val_num
    -- if self.val > self.max then
    -- 	self.val = self.max
	if self.val < 0 then
		self.val = 0
    end
    
	showAnimateText(self.number, 0.5, self.textNumber, self.lastTrialVal + val, "%d")
	self.textNumber = self.lastTrialVal + val
end