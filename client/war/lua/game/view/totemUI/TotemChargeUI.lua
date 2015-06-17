--充能UI
local path = "image/ui/TotemUI/ChargeUI.ExportJson"
TotemChargeUI = createUILayout("TotemChargeUI", path)

function TotemChargeUI:ctor(parent)
	self.parent = parent
	local con = self.con
	local function speedHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemChargeUI] click [btn_speed]' )
		if parent.isLock then
			return
		end
		local cost = TotemData.getAccelerateCost(parent.currentTotem)
		if CoinData.checkLackCoinX(cost) then
			return
		end
        local isFree = TotemData.getAccelerateCost(parent.currentTotem).val == 0
        self:playChargeEffect(parent.currentTotem)
		Command.run("totem accelerate", parent.currentTotem.guid, isFree)
	end
	createScaleButton(con.con_speed.btn_speed, nil, nil)
	con.con_speed.btn_speed:addTouchEnded(speedHandler)
	local size = con.con_speed.btn_speed:getSize()
	self.redPointPos = cc.p(size.width - 7, size.height - 7)
	con.time_prgs:setPercent(0)
	local pos = cc.p(con.con_speed.txt_multi:getPosition())
	local fontSize = 20
	pos.x = pos.x + (con.con_speed.txt_multi:getSize()).width / 2 + 10
	self.txt_1 = UIFactory.getText("5", con.con_speed, pos.x, pos.y, fontSize, cc.c3b(0xad, 0x10, 0x10))
	self.txt_1:setAnchorPoint(0, 0.5)
	self.txt_2 = UIFactory.getText("（剩余", con.con_speed, pos.x, pos.y, fontSize, cc.c3b(0x6b, 0x2c, 0x08))
	self.txt_2:setAnchorPoint(0, 0.5)
	self.txt_3 = UIFactory.getText("2", con.con_speed, pos.x, pos.y, fontSize, cc.c3b(0xad, 0x10, 0x10))
	self.txt_3:setAnchorPoint(0, 0.5)
	self.txt_4 = UIFactory.getText("个）", con.con_speed, pos.x, pos.y, fontSize, cc.c3b(0x6b, 0x2c, 0x08))
	self.txt_4:setAnchorPoint(0, 0.5)
	self:updateTextsPos()
	self.armatures = {}
end

function TotemChargeUI:updateTextsPos()
	for i = 1, 3 do
		local pos = cc.p(self["txt_"..i]:getPosition())
		pos.x = pos.x + (self["txt_"..i]:getSize()).width + 3
		self["txt_"..(i + 1)]:setPosition(pos)
	end
end

function TotemChargeUI:onShow()
	self.con.time_prgs:setPercent(0)
end

function TotemChargeUI:updateData()
	local parent = self.parent
	self.txt_star:setString(parent.currentTotem.level + 1)
	local con = self.con
	local times = TotemData.getAccelerateTime(parent.currentTotem)
	if times <= 4 then
		con.time_bg:loadTexture("TotemCharge/bg_1.png", ccui.TextureResType.plistType)
		con.time_prgs:loadTexture("TotemCharge/p_1.png", ccui.TextureResType.plistType)
	else
		con.time_bg:loadTexture("TotemCharge/bg_2.png", ccui.TextureResType.plistType)
		con.time_prgs:loadTexture("TotemCharge/p_2.png", ccui.TextureResType.plistType)
	end
	local cost = TotemData.getAccelerateCost(parent.currentTotem)
	if cost.cate == const.kCoinItem then
		local url = ItemData.getItemUrl(cost.objid)
		con.con_speed.icon_has:loadTexture(url, ccui.TextureResType.localType)
		con.con_speed.icon_has:setScale(0.4)
		self.txt_1:setString(cost.val)
		self.txt_3:setString(ItemData.getItemCount(cost.objid))
		self:updateTextsPos()
	end
	local percent = TotemData.getCharingPercent(parent.currentTotem)
	con.time_prgs:setPercent(percent)
	self:updateTime()
end

function TotemChargeUI:updateTime()
    local cooldown = TotemData.getLeftCooldown(self.parent.currentTotem)
    self.con.con_speed.txt_free:setString(cooldown == 0 and "当前免费" or DateTools.secondToString(cooldown).."后免费")	
    local canCharge = TotemData.checkCanUpLevel(self.parent.currentTotem)
    setButtonPoint(self.con.con_speed.btn_speed, canCharge, self.redPointPos, 200)	
end

function TotemChargeUI:onClose()
	for k,v in pairs(self.armatures) do
		k:removeFromParent()
	end
	self.armatures = {}
end

function TotemChargeUI:playChargeEffect(sTotem)
	local totalCount = TotemData.getAccelerateTime(sTotem)
	local currentCount = sTotem.accelerate_count
	local shouldPlayLevelUp = nil
	if currentCount + 1 == totalCount then --最后一次充能
		self.parent:lockUpdate(true)
		shouldPlayLevelUp = true
		SoundMgr.playEffect("sound/ui/UI_TTfull.mp3")
	else
		SoundMgr.playEffect("sound/ui/UI_TTenergy.mp3")
	end
	local function onComplete(arm)
		self.armatures[arm] = nil
		arm:removeNextFrame()
		if shouldPlayLevelUp then
			shouldPlayLevelUp = nil
			self:playLevelUpEffect(sTotem, totalCount <= 4 and 4 or 8)
		end
	end
	local prePart = totalCount <= 4 and 4 or totalCount
	local totalWidth = prePart == 4 and 279 or 365
	local multi = prePart / totalCount
	local orgPos = cc.p(self.con.time_prgs:getPosition())
	for i = currentCount * multi + 1, (currentCount + 1) * multi do
		local addPart = i == 1 and 1 or i == prePart and 3 or 2
		local name = prePart .. "gsx-tx-0" .. addPart
		local pos = cc.p(orgPos.x + (i - prePart * 0.5 - 0.5) * totalWidth / prePart, orgPos.y)
		local arm = ArmatureSprite:addArmatureOnce("image/armature/ui/TotemUI/", name, self.parent.winName, self.con, pos.x, pos.y, onComplete, 20)
		self.armatures[arm] = true
	end
	self.con.time_prgs:setPercent(100 * (currentCount + 1) / totalCount)
end

function TotemChargeUI:playLevelUpEffect(sTotem, part)
	if sTotem.guid ~= self.parent.currentTotem.guid then
		return
	end
	local function onComplete(arm)
		self.armatures[arm] = nil
		arm:removeNextFrame()
		self.con.time_prgs:setPercent(0)
		self:playStarFly(sTotem)
	end
	local pos = cc.p(self.con.time_prgs:getPosition())
	local name = part .. "gsx-tx-04"
	local arm = ArmatureSprite:addArmatureOnce("image/armature/ui/TotemUI/", name, self.parent.winName, self.con, pos.x, pos.y, onComplete, 20)
	self.armatures[arm] = true
end

function TotemChargeUI:playStarFly(sTotem)
	if sTotem.guid ~= self.parent.currentTotem.guid then
		return
	end
	SoundMgr.playEffect("sound/totem_use.mp3")
	local parent = self.parent
	local pStart = self.con:convertToWorldSpace(cc.p(self.con.time_prgs:getPosition()))
	pStart = parent:convertToNodeSpace(pStart)
	local pEnd = parent:getNextStarPos(parent.currentTotem.level)
	local completeCount = 0
	local c1List = {
		cc.p(pStart.x + 75, pStart.y + 75),
		cc.p(pStart.x + 25, pStart.y + 25),
		cc.p(pStart.x - 25, pStart.y - 25),
		cc.p(pStart.x - 75, pStart.y - 75)
	}
	local c2List = {
		cc.p(pEnd.x + 75, pEnd.y + 75),
		cc.p(pEnd.x + 25, pEnd.y + 25),
		cc.p(pEnd.x - 25, pEnd.y - 25),
		cc.p(pEnd.x - 75, pEnd.y - 75)
	}
	for i = 1, 4 do
		local sp = UIFactory.getSprite("image/ui/TotemUI/nlx.png", parent, pStart.x, pStart.y, 20)
		local bezier = {
	        c1List[i],
	        c2List[i],
	        pEnd
	    }
	    local function onComplete()
	    	if sp:getParent() then
	    		sp:removeFromParent()
	    	end
	    	completeCount = completeCount + 1
	    	if completeCount == 4 then
	    		parent:checkPlayUpEffect(sTotem)
	    	end
	    end
		sp:runAction(cc.Sequence:create(cc.BezierTo:create(1, bezier), cc.CallFunc:create(onComplete)))
	end
end
