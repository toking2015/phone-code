--图腾升级UI
local path = "image/ui/TotemUI/UpgradeUI.ExportJson"
local preArmaturePath = "image/armature/ui/TotemUI/"
TotemUpgradeUI = createUILayout("TotemUpgradeUI", path)

function TotemUpgradeUI:ctor(parent)
	self.effectList = {}
	self.parent = parent
	local con = self.con
	function self.blessHandler(sender, eventType)
		ActionMgr.save( 'UI', string.format('[TotemSlotProcUI] click [btn_bless_%s]', sender._attr) )
		local attr = sender._attr
		local currentTotem = self.parent.currentTotem
		local attr_level = TotemData.getAttrValue(currentTotem, attr)
		if TotemData.getCanBless(currentTotem, attr_level) then
			local cost = TotemData.getBlessCost(currentTotem, attr_level)
			if not CoinData.checkLackCoinX(cost) then
				Command.run("totem bless", currentTotem.guid, attr)
			end
		end
	end
	con.btn_bless_1._attr = const.kTotemSkillTypeSpeed
	con.btn_bless_2._attr = const.kTotemSkillTypeFormationAdd
	con.btn_bless_3._attr = const.kTotemSkillTypeWake
	local soundUrl = "sound/ui/UI_TTwish.mp3"
	createScaleButton(con.btn_bless_1, nil, nil, soundUrl)
	createScaleButton(con.btn_bless_2, nil, nil, soundUrl)
	createScaleButton(con.btn_bless_3, nil, nil, soundUrl)
	con.btn_bless_1:addTouchEnded(self.blessHandler)
	con.btn_bless_2:addTouchEnded(self.blessHandler)
	con.btn_bless_3:addTouchEnded(self.blessHandler)
end

function TotemUpgradeUI:updateData()
	local parent = self.parent
	local con = self.con
	local data = parent.currentTotem
	local isSameTotem = self.currentGuid == data.guid
	self.currentGuid = data.guid
	self:setProgress(con.progress_1, data, const.kTotemSkillTypeSpeed, isSameTotem)
	self:setProgress(con.progress_2, data, const.kTotemSkillTypeFormationAdd, isSameTotem)
	self:setProgress(con.progress_3, data, const.kTotemSkillTypeWake, isSameTotem)
	if TotemData.getCanBless(data, TotemData.getAttrValue(data, const.kTotemSkillTypeSpeed)) then
		local nextSpeed = findTotemAttr(data.id, data.speed_lv + 1)
		local nextSpeedOdd = findOdd(nextSpeed.speed.first, nextSpeed.speed.second)
		con.txt_tip_1:setString(string.format("速度%s → %s", parent.jSpeedOdd.effect.objid, nextSpeedOdd.effect.objid))
	else
		con.txt_tip_1:setString("")--string.format("速度%s", parent.jSpeedOdd.effect.objid))
	end
	if TotemData.getCanBless(data, TotemData.getAttrValue(data, const.kTotemSkillTypeFormationAdd)) then
		con.txt_tip_2:setString(parent.jFormationAttr.formation_up_desc)
	else
		con.txt_tip_2:setString("")
	end
	if TotemData.getCanBless(data, TotemData.getAttrValue(data, const.kTotemSkillTypeWake)) then
		local nextWakeAttr = findTotemAttr(data.id, data.wake_lv + 1)
		local nextWakeOdd = nextWakeAttr and findOdd(nextWakeAttr.wake.first, nextWakeAttr.wake.second)
		con.txt_tip_3:setString(string.format("几率%s%% → %s%%", parent.jWakeOdd.status.objid / 100, nextWakeOdd.status.objid / 100))
	else
		con.txt_tip_3:setString("")--string.format("觉醒几率%s%%", parent.jWakeOdd.status.objid / 100))
	end
	local canSpeed = TotemData.getCanBless(data, data.speed_lv)
	local canFormation = TotemData.getCanBless(data, data.formation_add_lv)
	local canSkill = TotemData.getCanBless(data, data.wake_lv)
	con.btn_bless_1:setVisible(canSpeed)
	con.btn_bless_2:setVisible(canFormation)
	con.btn_bless_3:setVisible(canSkill)
	local redPos = cc.p(122, 58)
	local isCheckBlessRed = TotemData.isCheckBlessRed()
	setButtonPoint(con.btn_bless_1, isCheckBlessRed and canSpeed and not CoinData.checkLackCoinX(parent.jSpeedAttr.train_cost, true), redPos)
	setButtonPoint(con.btn_bless_2, isCheckBlessRed and canFormation and not CoinData.checkLackCoinX(parent.jFormationAttr.train_cost, true), redPos)
	setButtonPoint(con.btn_bless_3, isCheckBlessRed and canSkill and not CoinData.checkLackCoinX(parent.jWakeAttr.train_cost, true), redPos)
	con.btn_bless_1.txt_money:setString(parent.jSpeedAttr.train_cost.val)
	con.btn_bless_2.txt_money:setString(parent.jFormationAttr.train_cost.val)
	con.btn_bless_3.txt_money:setString(parent.jWakeAttr.train_cost.val)
	self:setMax(con.max_1, not canSpeed)
	self:setMax(con.max_2, not canFormation)
	self:setMax(con.max_3, not canSkill)
end

function TotemUpgradeUI:setMax(max, show)
	max:setVisible(show)
	if show then
		if not max.effect then
			local pos = cc.p(max:getPosition())
			-- pos.x,pos.y = pos.x + 60, pos.y + 52
			max.effect = ArmatureSprite:addArmatureEx(preArmaturePath, "mxg-tx-01", self.parent.winName, self.con, pos.x, pos.y, nil, 1)
		end
	else
		if max.effect then
			max.effect:removeFromParent()
			max.effect = nil
		end
	end
end

function TotemUpgradeUI:doSetProgress(progress, attr)
	local percent = TotemData.getAttrPercent1(self.parent.currentTotem, attr)
	progress:setPercent(percent)
end

function TotemUpgradeUI:setProgress(progress, sTotem, attr, isSameTotem)
	local percent = TotemData.getAttrPercent1(sTotem, attr)
	if progress:getPercent() ~= percent then
		if isSameTotem and percent > 0 then
			local armature
			local function onComplete()
				self:doSetProgress(progress, attr)
				armature:removeNextFrame()
			end
			local pos = cc.p(progress:getPosition())
			pos.x = pos.x + 31 * (percent / 20 - 3) - 0.5
			local name = "zjgh-tx-01"
			if percent == 20 then
				name = "zgh-tx-01"
			elseif percent == 100 then
				name = "ygh-tx-01"
			end
			armature = ArmatureSprite:addArmatureOnce(preArmaturePath, name, self.parent.winName, progress:getParent(), pos.x, pos.y, onComplete, 20)
		else
			progress:setPercent(percent)
		end
	end
end
