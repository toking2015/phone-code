--author zxr
require("lua/game/view/NTotemUI/TotemItem.lua")
local prePath = "image/ui/NTotemUI/"
local preArmaturePath = "image/armature/ui/TotemUI/"
local colorGreen = cc.c3b(0x72, 0xff, 0x00)
local colorRed = cc.c3b(0x54, 0x00, 0x00)
local pageSize = 4

TotemUI = createUIClass('TotemUI', prePath .. "NTotemUI.ExportJson", PopWayMgr.SMALLTOBIG)

function TotemUI:ctor()
	self.isUpRoleTopView = true
	self.itemList = {} 
	self.listSpace = 109
	self.maxPage = 4
	local function onTouchTotem(target)
		ActionMgr.save( 'UI', '[TotemUI] click [con_totem]' )
		if self._totemRole then
			SoundMgr.playEffect("sound/ui/totem_updown.mp3")
			self._totemRole:playOnce("sf")
		end
	end
	UIMgr.addTouchEnded(self.con_totem, onTouchTotem)
	-- self.txt_level = UIFactory.getText("", self, x, y, fontSize, c3b, font, align, depth)
	local function onTouchAttr1(target)
		if self.jWakeOdd then
			TipsMgr.showTips(target:getTouchStartPos(), TipsMgr.TYPE_ODD, self.jWakeOdd)
		end
	end
	local function onTouchAttr2(target)
		if self.jFormationOdd then
			TipsMgr.showTips(target:getTouchStartPos(), TipsMgr.TYPE_ODD, self.jFormationOdd)
		end
	end
	local function onTouchAttr3(target)
		if self.jSpeedOdd then
			TipsMgr.showTips(target:getTouchStartPos(), TipsMgr.TYPE_ODD, self.jSpeedOdd)
		end
	end
	local function onTouchSkill(target)
		if self.jSkill then
			TipsMgr.showTips(target:getTouchStartPos(), TipsMgr.TYPE_SKILL, self.jSkill)
		end
	end
	UIMgr.addTouchBegin(self.con_attr.img_1, onTouchAttr1)
	UIMgr.addTouchBegin(self.con_attr.img_2, onTouchAttr2)
	UIMgr.addTouchBegin(self.con_attr.img_3, onTouchAttr3)
	UIMgr.addTouchBegin(self.img_skill, onTouchSkill)
	-- self.con_list = BoxContainer.new(2, 4, cc.p(100, 105), cc.p(20, 24), cc.p(65, 70))
	-- self.con:addChild(self.con_list)
	-- local function touchHandler(sender, event)
	-- 	local startPos = sender:getTouchStartPos()
	-- 	local endPos = sender:getTouchEndPos()
	-- 	if not cc.pFuzzyEqual(startPos, endPos, Config.FUZZY_VAR) then
	-- 		return
	-- 	end
	-- 	local index = self.con_list:hitTest(endPos)
	-- 	if index ~= 0 and index <= #self.jTotemList then
	-- 		ActionMgr.save( 'UI', string.format('[TotemUI] click [totem.%s]', index))
	-- 		self:changeTotem(self.jTotemList[index])
	-- 	end
	-- end
	-- UIMgr.addTouchEnded(self.con, touchHandler)


	--暂时屏蔽
	self.Image_8:setVisible(true)
	self.con:setVisible(false)
	self:initListSelectedItem()
	self:addSTypePanelEvent()
	self.sPanel:setVisible(false)
end

function TotemUI:changeType( type )
	self.flushPage = true
	self.sPanel:setVisible(false)
	self.selectedType = type
	self:updateData()
end

function TotemUI:addSTypePanelEvent( ... )
	local function swapPanel( ... )
		if self.sPanel:isVisible() then
			self.sPanel:setVisible(false)
		else
			self.sPanel:setVisible(true)
		end
	end
	buttonDisable(self.Image_8,false)
	UIMgr.addTouchBegin(self.Image_8,swapPanel)

	local function btnBegin( sender,type )
		sender.img:setVisible(true)
	end

	local function changeType( sender,type )
		ActionMgr.save( 'UI', string.format('[TotemUI] click [changeType.%s]', sender.type))
		self:changeType(sender.type)
	end

	for i=1,5 do
		local btn = self.sPanel["btn_"..i]
		buttonDisable(btn,false)
		UIMgr.addTouchBegin(btn,btnBegin)
		UIMgr.addTouchEnded(btn,changeType)
	end
end

function TotemUI:dispose( ... )
	if self.selectedItem then
		self.selectedItem:release()
	end
end

function TotemUI:initListSelectedItem()
	local url = "image/ui/NTotemUI/bg/bg_item_cur.png"
	self.selectedItem = cc.Sprite:create()
	self.selectedItem:setTexture(url)
	self.selectedItem:retain()
	self.selectedItem:setAnchorPoint(0,0)
	self.selectedItem:setPosition(-10,-10)
end

function TotemUI:delayInit()
	self.head_figure = UIFactory.getTitleTriangle(self, 1)
	self.con_attr:setBackGroundImage(prePath.."bg/bg_list.png", ccui.TextureResType.localType)
	self.con_skill:setBackGroundImage(prePath.."bg/bg_skill.png", ccui.TextureResType.localType)

	local size = self:getSize()
	size.height = size.height + 46
	self:setSize(size)
end

function TotemUI:onShow()
	EventMgr.addListener(EventType.UserTotemUpdate, self.updateData, self)
	EventMgr.addListener(EventType.UserTotemChange, self.onTotemChange, self)
	EventMgr.addListener(EventType.UserTotemBlessSuccess,self.playBlessEffect, self)
	self.selectedType = 0 --选择所有类型
	self.flushPage = true --刷新PageView
	self.curPage = 1 --第一页
	performNextFrame(self, self.updateData, self)
	self.effectLay = cc.Node:create()
	self.effectLay:retain()
	local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
	layer:addChild(self.effectLay)
end

function TotemUI:playBlessEffect()
	if TotemData.qBlessTotem and TotemData.bBlessTotem then
		self:playBlessBoxEffect()
		self:playArrEffect()
		self:playBlessFightAddEffect()
	end
end

function TotemUI:releaseMoudle(name)
	if self[name] then
		self[name]:release()
		self[name] = nil
	end
end

function TotemUI:onClose()
	EventMgr.removeListener(EventType.UserTotemUpdate, self.updateData)
	EventMgr.removeListener(EventType.UserTotemChange, self.onTotemChange)
	EventMgr.removeListener(EventType.UserTotemBlessSuccess, self.playBlessEffect)
	self:removeView()
	self:releaseMoudle("_active")
	self:releaseMoudle("_upgrade")
	self:releaseMoudle("_charge")

	if self.effectLay then
		self.effectLay:removeFromParent()
		self.effectLay:release()
		self.effectLay = nil
	end
end

function TotemUI:changeTotemById( totemId )
	self.defaultTotemId = totemId
	self:changeType(0)
end

function TotemUI:updateData()
	if self.flushPage then
		local list = TotemData.getTypeJson(self.selectedType)
		self.jTotemList = list
		table.sort(list, TotemData.sortJsonFunc)
		self.jTotemList = list
		if #list == 0 then
			self.con_br:setVisible(false)
			return
		end

		local changePage = nil
		self.jTotem = list[1]
		if self.defaultTotemId then
			for k,v in pairs(list) do
				if v.id == self.defaultTotemId then
					changePage = math.ceil(k/4)
					self.jTotem = v
					self.defaultTotemId = nil
					break
				end
			end
		end
		self:setPageView()
		if changePage then
			self:toPage(changePage,true)
		end
		self.flushPage = false
	end
	self:changeTotem(self.jTotem)
end

function TotemUI:onTotemChange()
	self:changeTotem(self.jTotem)
end

function TotemUI:changeTotem(jTotem)
	self.jTotem = jTotem
	self.sTotem = TotemData.getTotemById(self.jTotem.id)
	-- self.level = self.jTotem.max_lv
	-- self.wake_lv = TotemData.MAX_ATTR_LEVEL
	-- self.formation_add_lv = TotemData.MAX_ATTR_LEVEL
	-- self.speed_lv = TotemData.MAX_ATTR_LEVEL
	self.level = 1 
	self.wake_lv = 0 
	self.formation_add_lv = 0
	self.speed_lv = 0
	if self.sTotem then
		self.level = self.sTotem.level
		self.wake_lv = self.sTotem.wake_lv
		self.formation_add_lv = self.sTotem.formation_add_lv
		self.speed_lv = self.sTotem.speed_lv
	end
	self.jTotemAttr = findTotemAttr(self.jTotem.id, self.level)
	self.jSkillAttr = findTotemAttr(self.jTotem.id, self.level)
	self.jSkill = self.jSkillAttr and findSkill(self.jSkillAttr.skill.first, self.jSkillAttr.skill.second)
	self.jSpeedAttr = findTotemAttr(self.jTotem.id, self.speed_lv)
	self.jSpeedOdd = self.jSpeedAttr and findOdd(self.jSpeedAttr.speed.first, self.jSpeedAttr.speed.second)
	self.jFormationAttr = findTotemAttr(self.jTotem.id, self.formation_add_lv)
	self.jFormationOdd = self.jFormationAttr and findOdd(self.jFormationAttr.formation_add_attr.first, self.jFormationAttr.formation_add_attr.second)
	self.jWakeAttr = findTotemAttr(self.jTotem.id, self.wake_lv)
	self.jWakeOdd = self.jWakeAttr and findOdd(self.jWakeAttr.wake.first, self.jWakeAttr.wake.second)
	self:updateView()
end

function TotemUI:updateView()
	UIFactory.setSpriteChild(self.img_skill, "icon", false, TotemData.getAvatarUrl(self.jTotem), 49, 49)
	if self.jSkill then
		self.txt_skill:setString(self.jSkill.desc)
	else
		LogMgr.error("图腾技能不正确"..self.jTotem.id.."星级"..self.level)
	end
	self.img_skill:loadTexture(TotemData.getBigQuFrame(self.level), ccui.TextureResType.plistType)
	self.con_attr.txt_1:setString(TotemData.getWakeName(self.jTotem.type).."觉醒")
	self.con_attr.txt_2:setString(self.jFormationOdd.name)
	self.con_attr.txt_3:setString(self.jSpeedOdd.name)

	self.txt_name:setString(self.jTotem.name)
	self.txt_name:setColor(TotemData.getColor(self.level))
	self.con_totem:setBackGroundImage(string.format(prePath.."bg/bg_%s.png", self.level), ccui.TextureResType.localType)
	self.typeImg:loadTexture(string.format("TotemUI/type_%s.png",tostring(self.jTotem.type)),ccui.TextureResType.plistType) 
	self:addView()
	local star = self.jTotem.init_lv
	if self.sTotem then
		star = self.sTotem.level
		self.con_br:setVisible(true)
		self.con_star:setVisible(true)
		self.con_br.txt_br:setString(TotemData.getFightValue(self.sTotem))
		self:setStar(self.level)
	else
		self.con_br:setVisible(false)
		self.con_star:setVisible(false)
	end

	local max = star * TotemData.levelPerStar
	self.con_attr.lv_1:setString(string.format("lv%d/",self.wake_lv))
	self.con_attr.lv_2:setString(string.format("lv%d/",self.formation_add_lv))
	self.con_attr.lv_3:setString(string.format("lv%d/",self.speed_lv))
	self.con_attr.lvmax_1:setString(max)
	self.con_attr.lvmax_2:setString(max)
	self.con_attr.lvmax_3:setString(max)

	self:setProgress(self.con_attr.pgs_1, self.wake_lv, const.kTotemSkillTypeWake, self.jTotem.id)
	self:setProgress(self.con_attr.pgs_2, self.formation_add_lv, const.kTotemSkillTypeFormationAdd, self.jTotem.id)
	self:setProgress(self.con_attr.pgs_3, self.speed_lv, const.kTotemSkillTypeSpeed, self.jTotem.id)

	self:updateList()
	self:updateActive()
	self:updateUpgrade()
	self:updateCharge()
	self:updateType()
end

function TotemUI:doSetProgress(pgs, attrLevel)
	local percent = TotemData.getAttrPercent(self.level, attrLevel)
	pgs:setPercent(percent)
end

function TotemUI:setProgress(pgs, attrLevel, attr, id)
	local isSameTotem = false --pgs._totem_id == id --屏蔽动画
	pgs._totem_id = id
	local percent = TotemData.getAttrPercent(self.level, attrLevel)
	if pgs:getPercent() ~= percent then
		if isSameTotem and percent > 0 then
			local armature
			local function onComplete()
				self:doSetProgress(pgs, attrLevel)
				armature:removeNextFrame()
			end
			local pos = cc.p(pgs:getPosition())
			pos.x = pos.x + 31 * (percent / 20 - 3) - 0.5
			local name = "zjgh-tx-01"
			if percent == 20 then
				name = "zgh-tx-01"
			elseif percent == 100 then
				name = "ygh-tx-01"
			end
			armature = ArmatureSprite:addArmatureOnce(preArmaturePath, name, self.winName, pgs:getParent(), pos.x, pos.y, onComplete, 20)
		else
			pgs:setPercent(percent)
		end
	end
end

function TotemUI:addView()
	self:removeView()
	local style = self.jTotem.animation_name
	if style ~= nil or style ~= "" then
		local level = self.level
		if level > 4 then
			level = 4
		end
		local _totemRole = ModelMgr:useModel(style .. level, const.kAttrTotem, style, level)
		if _totemRole then
			_totemRole:setPosition(cc.p(122, 80))
			_totemRole:playOne(false, "stand")
			self.con_totem:addChild(_totemRole, 1)
			self._totemRole = _totemRole
		end
	end
end

function TotemUI:removeView()
	if self._totemRole then
		ModelMgr:recoverModel(self._totemRole)
		self._totemRole = nil
	end
end

function TotemUI:setStar(level)
	for i = 1, TotemData.MAX_LEVEL do
		local url = i <= level and "TotemUI/totem_res_25.png" or "TotemUI/totem_res_26.png"
		local x = i * 44 - 20
		UIFactory.setSpriteChild(self.con_star, "star"..i, true, url, x, 27)
	end
end

function TotemUI:onActiveHandler( induct )
	if self.jTotem and not self.sTotem then
		if TotemData.checkCanActivate(self.jTotem, true, true) then
			if induct then
				TotemData.showTotemGet( self.jTotem.id )
			end
			Command.run("totem activate", self.jTotem.id)
		end
	end
end

function TotemUI:updateActive()
	local con = self._active
	if self.sTotem then
		if con then
			con:removeFromParent()
		end
		return
	end
	if not con then
		con = getLayout(prePath.."NTotemActivate.ExportJson")
		con:retain()
		self._active = con
		con.batch_1 = LabelBatch.new(3, 16)
		con.batch_2 = LabelBatch.new(3, 16)
		con.batch_3 = LabelBatch.new(3, 16)
		addToParent(con.batch_1, con, 590, con.pot_1:getPositionY(), 2)
		addToParent(con.batch_2, con, 590, con.pot_2:getPositionY(), 2)
		addToParent(con.batch_3, con, 590, con.pot_3:getPositionY(), 2)
		local function onActiveHandler()
			self:onActiveHandler( false )
		end
		createScaleButton(con.btn)
		con.btn:addTouchEnded(onActiveHandler)
	end

	if not con:getParent() then
		self:addChild(con, 30)
	end

	local isRedShow = TotemData.checkCanActivate(self.jTotem, false)
	local size = con.btn:getSize()
    local off = cc.p(size.width - 8,size.height - 8)
    setButtonPoint( con.btn, isRedShow ,off,199)

	con.batch_1:setFontColor(2, cc.c3b(0x54, 0x00, 0x00))
	con.batch_2:setFontColor(2, cc.c3b(0x00, 0xff, 0x1e))
	con.batch_3:setFontColor(2, cc.c3b(0x54, 0x00, 0x00))

	local conds = self.jTotem.activate_conds
	for i = 1, 3 do
		local batch = con["batch_"..i]
		local pot = con["pot_"..i]
		if i <= #conds then
			local cond = conds[i]
			local str = TotemData.getCondDesc(cond)
			local cur = TotemData.getCondVal(cond)
			batch:setFontColor(2, cur < cond.val and colorRed or colorGreen)
			batch:setString(str.."（", cur .. "/" .. cond.val,"）")
			pot:setVisible(true)
		else
			batch:setString("", "", "")
			pot:setVisible(false)
		end
	end
end

function TotemUI:updateUpgrade()
	local con = self._upgrade
	if not self.sTotem or TotemData.isAddEnergying(self.sTotem) then
		if con then
			self:removeUpgradeEffect()
			con:removeFromParent()
		end
		return
	end
	if not con then
		con = getLayout(prePath.."NTotemUpgrade.ExportJson")
		con:retain()
		self._upgrade = con
		-- addOutline(con.txt_pgs, cc.c3b(0x5a, 0x22, 0x11), 2)
		createScaleButton(con.btn)
		function self.onUpgradeHandler(induct)
			if TotemData.lockBless then
				return
			end
			if not self.sTotem then
				return
			end
			local attr = TotemData.getBlessAttr(self.sTotem)
			if TotemData.checkCanBlessAttr(self.sTotem, attr, true) then
				TotemData.lockBless = true
				if induct then
					TotemData.qBlessTotem = clone(self.sTotem)
					TotemData.virTotemData( self.sTotem )
				else
					TotemData.qBlessTotem = self.sTotem
				end
				Command.run("totem bless", self.sTotem.guid, attr)
			end
		end

		local function onUpgradeHandler( ... )
			self.onUpgradeHandler(false)
		end

		con.btn:addTouchEnded(onUpgradeHandler)
		TipsMgr.addCoinTipsHandler(con.ico_1)
		TipsMgr.addCoinTipsHandler(con.ico_2)
	end
	if not con:getParent() then
		self:addChild(con, 30)
	end
	local canBless = TotemData.checkCanBless(self.sTotem)
	local size = con.btn:getSize()
    local off = cc.p(size.width - 13,size.height - 18)
    setButtonPoint( con.btn, canBless ,off,199)

	local lv1 = TotemData.getAttrValue(self.sTotem, const.kTotemSkillTypeWake)
	local lv2 = TotemData.getAttrValue(self.sTotem, const.kTotemSkillTypeFormationAdd)
	local lv3 = TotemData.getAttrValue(self.sTotem, const.kTotemSkillTypeSpeed)
	local levels = lv1 + lv2 + lv3
	local totalLevels = TotemData.levelPerStar * self.sTotem.level * TotemData.ATTR_COUNT
	con.txt_pgs:setString(string.format("%s/%s", levels, totalLevels))
	local percent = levels * 100 / totalLevels
	con.pgs:setPercent(percent)
	con.light:setPositionX(con.pgs:getPositionX() + (percent - 50) / 100 * con.pgs:getSize().width)
	con.light:setVisible(false)
	local effectPosi = cc.p( con.light:getPosition() )
	effectPosi.x = effectPosi.x - 7
	effectPosi.y = effectPosi.y + 2
	self:playUpgradeEffect(con, effectPosi)
	local attr = TotemData.getBlessAttr(self.sTotem)
	local attrLevel = TotemData.getAttrValue(self.sTotem, attr)
	local costList = TotemData.getBlessCost(self.sTotem, attrLevel)
	local cost = costList[2]
	if cost then
		con.ico_1.tipsData = cost
		con.ico_1:loadTexture(CoinData.getCoinUrl(cost.cate, cost.objid), ccui.TextureResType.localType)
		con.ico_1:setScale(0.3)
		con.cos_1:setString("×"..cost.val)
		local hasValue = CoinData.getCoinByCate(cost.cate, cost.objid)
		con.has_1:setString(string.format("(%s)", hasValue))
		con.has_1:setPositionX(con.cos_1:getPositionX() + con.cos_1:getSize().width + 3)
		con.has_1:setColor(hasValue >= cost.val and colorGreen or colorRed)
		con.ico_1:setVisible(true)
		con.cos_1:setVisible(true)
		con.has_1:setVisible(true)
	else
		con.ico_1:setVisible(false)
		con.cos_1:setVisible(false)
		con.has_1:setVisible(false)
	end
	cost = costList[1]
	if cost then
		con.ico_2.tipsData = cost
		con.ico_2:loadTexture(CoinData.getCoinUrl(cost.cate, cost.objid), ccui.TextureResType.localType)
		con.ico_2:setScale(0.3)
		con.cos_2:setString("×"..cost.val)
		con.ico_2:setVisible(true)
		con.cos_2:setVisible(true)
	else
		con.ico_2:setVisible(false)
		con.cos_2:setVisible(false)
	end
end

function TotemUI:updateCharge()
	local con = self._charge
	if not self.sTotem or not TotemData.isAddEnergying(self.sTotem) then
		if con then
			self:removeChargeEffect()
			self:removeCanUpEffect()
			con:removeFromParent()
		end
		return
	end

	local canUp = TotemData.checkCanUpLevel(self.sTotem, false)
	if not con then
		con = getLayout(prePath.."NTotemCharge.ExportJson")
		con:retain()
		self._charge = con
		-- addOutline(con.txt_pgs, cc.c3b(0x5a, 0x22, 0x11), 2)
		createScaleButton(con.btn)
		local function onChargeHandler()
			if not self.sTotem then
				return
			end
			
			if self._charge then
				function self.okFun()
					if TotemData.checkCanUpLevel(self.sTotem, true) then
						Command.run("totem accelerate", self.sTotem.guid, false)
					end
			    end

			    if (CoinData.checkLackCoinX(self.costItem)) then
            		return
       			end

			    if self.costMoney then
					showMsgBox( string.format("[font=ZH_5]是否消耗[font=ZH_3]%s[font=ZH_5]金币为[font=ZH_3]%s升星？",
	            						self.costMoney.val,self.jTotem.name), self.okFun, function() end )
					return
				end

				self.okFun()
			end
		end
		con.btn:addTouchEnded(onChargeHandler)
		TipsMgr.addCoinTipsHandler(con.ico)
	end

	if not con:getParent() then
		self:addChild(con, 30)
	end

    self.costMoney = nil
	local costList = TotemData.getAccelerateCost(self.sTotem)
	for k,cost in pairs(costList) do
    	if cost and cost.cate and cost.cate ~= 0 and cost.cate == const.kCoinMoney then
    		self.costMoney = cost
    	end
    end
    local cost = costList[1]
    self.costItem = cost

    local size = con.btn:getSize()
    local off = cc.p(size.width - 13,size.height - 18)
    setButtonPoint( con.btn, canUp ,off,199)

	con.ico.tipsData = cost
	con.ico:loadTexture(CoinData.getCoinUrl(cost.cate, cost.objid), ccui.TextureResType.localType)
	con.ico:setScale(0.3)
	-- con.txt_pgs:setString(string.format("%s/%s", self.sTotem.accelerate_count, self.jTotemAttr.acc_count))
	local hasCount = CoinData.getCoinByCate(cost.cate, cost.objid)
	con.txt_pgs:setString(string.format("%s/%s", hasCount, cost.val))
	local percent = math.min(100, hasCount * 100 / cost.val)
	con.pgs:setPercent(percent)
	con.light:setPositionX(con.pgs:getPositionX() + (percent - 50) / 100 * con.pgs:getSize().width)
	con.light:setVisible(false)
	if canUp then
		self:removeChargeEffect()
		local p1 = cc.p(con:getPosition())
		p1.x = p1.x + 188/2 - 2
		p1.y = p1.y + 12
		local p2 = cc.p(con.btn:getPosition() )
		p2.x = p2.x + size.width/2
		p2.y = p2.y + size.height/2
		self:playCanUpEffect(con.pgs, con,p1, p2)
	else
		self:removeCanUpEffect()
		local effectPosi = cc.p( con.light:getPosition() )
		effectPosi.x = effectPosi.x - 7
		effectPosi.y = effectPosi.y + 2
		self:playChargeEffect(con, effectPosi)
	end
end

--左侧列表刷新逻辑开始
function TotemUI:updateList()
	self.selectedItem:removeFromParent()
	for k,v in pairs(self.itemList) do
		self:setItemData(v,v.jTotem)
	end
--[[
	local con = self.con_list
	local list = self.jTotemList
	con:setNodeCount(#list)
	local sTotem
	local jTotem
	local level
	for i = 1, con.count do
		local totemIcon = con:getNode(i)
		if not totemIcon then
			totemIcon = UIFactory.getSpriteFrame("bg_role_new.png")
			con:addNode(totemIcon, i)
		end

		if totemIcon.redPoint then
			totemIcon.redPoint:removeFromParent()
			totemIcon.redPoint = nil
		end

		local hasMark = false
		local hasRed = false
		if i <= #list then
			jTotem = list[i]
			sTotem = TotemData.getTotemById(jTotem.id)
			level = sTotem and sTotem.level or jTotem.max_lv
			hasMark = self.jTotem.id == jTotem.id
			UIFactory.setSpriteChild(totemIcon, "quality", true, TotemData.getQualityFrameName(level), 43, 43)
			local iconSp = totemIcon.icon or UIFactory.getSprite(nil, totemIcon, 43, 43)
			totemIcon.icon = iconSp
			local url = TotemData.getAvatarUrl(jTotem)
			BitmapUtil.setTexture(iconSp, url)
			totemIcon.icon:setScale(TotemData.AVATAR_SCALE)
			UIFactory.setSpriteChild(totemIcon, "bg_star", true, "bg_star.png", 43, -10)
			self:setIconStar(totemIcon, level)
			if sTotem then
				if TotemData.checkCanUpLevel(sTotem) or TotemData.checkCanBless(sTotem) then
					hasRed = true
				end
			end
			if sTotem then
				ProgramMgr.setNormal(totemIcon)
			else
				hasRed = TotemData.checkCanActivate(jTotem, false)
				ProgramMgr.setGray(totemIcon)
			end
		else
			ProgramMgr.setNormal(totemIcon)
			UIFactory.setSpriteChild(totemIcon, "quality", true)
			UIFactory.setSpriteChild(totemIcon, "icon", false)
			UIFactory.setSpriteChild(totemIcon, "star_bg", true)
			self:setIconStar(totemIcon, jTotem.max_lv)
		end

		if hasMark then
			UIFactory.setSpriteChild(totemIcon, "mark", true, "head_mark.png", 70, 20, 10)
		else
			UIFactory.setSpriteChild(totemIcon, "mark", true)
		end
		setButtonPoint(totemIcon, hasRed, redPos)
	end

	local scrollSize = cc.size(250, con:getHeight())
	self.con:setInnerContainerSize(scrollSize)
	con:setPosition(0, scrollSize.height)
	]]
end

function TotemUI:updateType( ... )
	local typeList = {0,const.kTotemTypeDaDi,const.kTotemTypeHuoYan,const.kTotemTypeShuiLiu,const.kTotemTypeKongQi}
	local curTxt = "全部"
	if self.selectedType ~= 0 then
		curTxt = TotemData.getTypeName(self.selectedType)
	end
	local index = 1
	for i=1,#typeList do
		local btn = self.sPanel["btn_"..index]
		btn.type = typeList[i]
		index = index + 1
		local txt = "全部"
		if btn.type ~= 0 then
			txt = TotemData.getTypeName(btn.type)
		end
		btn.txt:setString(txt)
		btn.img:setVisible(false)
	end
	self.curType:setString(curTxt)
end

function TotemUI:setPageView( ... )
	local function onClickItem(sender,type)
		--LogMgr.debug("onClickTxt")
		ActionMgr.save( 'UI', string.format('[TotemUI] click [totem.%s]', sender.jTotem.id))
		self:changeTotem(sender.jTotem)
	end

	--位置重置
	if self.curPage > 1 then
		self:toPage(1,true)
	end

	self.itemList = {}
	local list = self.jTotemList
	local pageView = self.page_view
	pageView:removeAllPages()
	local pageViewSize = pageView:getSize()
	local dLen = #list
	local totalPage = math.ceil(dLen/4)
	for p=1,totalPage do
		local page = ccui.Layout:create()
        page:setSize(pageViewSize)
        local dDataIndex = (p - 1) * pageSize
		for i=1,pageSize do
			local dIndex = dDataIndex + i
			if dIndex <= dLen then
				local item = self:getItem()
			    item:setPosition(8, self.listSpace * pageSize + 6 - i * self.listSpace)
			    page:addChild(item)
			    UIMgr.addTouchEnded(item,onClickItem)
			    item.jTotem = list[dIndex]
			    table.insert(self.itemList,item)
			end
		end
		pageView:addPage(page)
	end

	local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
        	self:toPage(pageView:getCurPageIndex() + 1)
        end
    end 

    pageView:addEventListenerPageView(pageViewEvent)
    self:InitPageImg(totalPage)
    self:addScrollVerticalEvent(self.con)
    self:toPage(1,true)
end

function TotemUI:toPage( page,jump)
	self.curPage = page
    self:setCurPageImg(self.curPage)
    if jump then
    	self.page_view:scrollToPage(self.curPage -1)
    end
end

function TotemUI:addScrollVerticalEvent( target )
	local function onTouchEnded(touches, event) 
        local target = event:getCurrentTarget()
        target:setPosition(0,0)
    end

   	local function onTouchMoved(touches, event) 
        local target = event:getCurrentTarget()
		if self.moveStarP then
			self.moveEndP = touches:getLocation()
			local offY = self.moveEndP.y - self.moveStarP.y
			local offX = self.moveEndP.x - self.moveStarP.x
			local space = 30
			if offY > 0 and self.curPage == 1 then
				return
			end
			if offY < 0 and self.curPage == self.maxPage then
				return
			end

--			local size = self.con:getSize()
--			--避免以水平翻页冲突
--			if math.abs(offX) > size.width/2 then
--				return
--			end

			if  math.abs(offY) > space then
				self.clickItemFlag = false
				self.moveStarP = nil
				target:stopAllActions()
				target:setPosition(0,0)
				--LogMgr.debug("addScrollVerticalEvent--move:::"..offY)
				if offY >= 0 then
					--self.page_view:scrollToPage(self.curPage - 2)
					self:toPage(self.curPage - 1,true)
				else
					--self.page_view:scrollToPage(self.curPage)
					self:toPage(self.curPage + 1,true)
				end
			end
		end
    end

    local function onTouchBegan(touches, event)
    	self.clickItemFlag = true
    	self.moveStarP = nil
        local target = event:getCurrentTarget()
        if target then
            local locationInNode = touches:getLocation()
            local size = self.page_view:getSize()
	    	local posi = self.page_view:convertToWorldSpace( cc.p( self.page_view:getPosition() ) ) 
	    	local rect = cc.rect(posi.x, posi.y, posi.x + size.width, posi.y + size.height)
            if cc.rectContainsPoint(rect, locationInNode) then
                local pos = touches:getLocation()
              	self.moveStarP = pos  
              	return true
            end
        end
    end

    if not target.listener1 then
	    target.listener1 = cc.EventListenerTouchOneByOne:create()
	    target.listener1:setSwallowTouches(false)
	    target.listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	    target.listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
	    target.listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	    target:getEventDispatcher():addEventListenerWithSceneGraphPriority(target.listener1, target)
	end
end

function TotemUI:InitPageImg( totemPage )
	local function toPage( sender,type )
		ActionMgr.save( 'UI', string.format('[TotemUI] click [toPage.%s]', sender.page))
		if sender.page ~= self.curPage then
			self:toPage(sender.page,true)
		end
	end
	if not self.pageImgCon then
		self.pageImgCon = cc.Node:create()
		self:addChild(self.pageImgCon,333)
	end

	self.pageImgCon:removeAllChildren()
	self.pageImgCon.count = totemPage
	local bgSize = self.Image_5:getSize()
	local center = cc.p(bgSize.width/2 + self.Image_5:getPositionX(),20)
	local imgSize
	local space
	for i=1,totemPage do
		self.pageImgCon["img"..i] = ccui.ImageView:create("TotemUI/totem_res_30.png",ccui.TextureResType.plistType)
		local img = self.pageImgCon["img"..i]
		img.page = i
		img:setAnchorPoint(0,0)
		imgSize = img:getContentSize()
		space = imgSize.width + 6
		img:setPosition( (i-1) * space, 0 ) 
		self.pageImgCon:addChild(img)
		UIMgr.addTouchBegin(img,toPage)
	end
	local imgConWidth = (totemPage - 1 ) * space + imgSize.width
	self.pageImgCon:setPosition(center.x - imgConWidth/2,center.y)
end

function TotemUI:setCurPageImg( curPage )
	local totalPage = self.pageImgCon.count
	for i=1,totalPage do
		local img = self.pageImgCon["img"..i]
		if i == curPage then
			img:loadTexture("TotemUI/totem_res_31.png",ccui.TextureResType.plistType)
		else
			img:loadTexture("TotemUI/totem_res_30.png",ccui.TextureResType.plistType)
		end
	end
end

function TotemUI:setItemData( item,jTotem )
	item.jTotem = jTotem
	local sTotem
	local level 
	local hasMark = false
	local hasRed = false
	sTotem = TotemData.getTotemById(jTotem.id)
	level = sTotem and sTotem.level or 1
	hasMark = self.jTotem.id == jTotem.id
	item.bg:loadTexture(TotemData.getQualityUrl(level),ccui.TextureResType.localType)
	local url = TotemData.getAvatarUrl(jTotem)
	item.icon:loadTexture(url,ccui.TextureResType.localType)
	--item.icon:setScale(TotemData.AVATAR_SCALE)
	item.name:setString(jTotem.name)
	--item.name:setColor((TotemData.getColor(level)))
	item.name:setPosition(163,74)
	local url = TotemData.getAvatarUrl(jTotem)
	for i=1,5 do
		local starIcon = item["star"..i]
		starIcon:setScale(0.6)
		if i <= level then
			starIcon:loadTexture("TotemUI/totem_res_25.png",ccui.TextureResType.plistType)
		else
			starIcon:loadTexture("TotemUI/totem_res_26.png",ccui.TextureResType.plistType)
		end
	end
	if sTotem then
		if TotemData.checkCanUpLevel(sTotem) or TotemData.checkCanBless(sTotem) then
			hasRed = true
		end
		self:setItemNormal(item)
		item.progress:setVisible(false)
	else
		item.progress:setVisible(true)
		item.name:setPosition(163,83)
		self:setItemGray(item)
		local progress = TotemData:getActivateProgress(item.jTotem)
		item.progress.bar:setPercent(progress)
		item.progress.txt:setString(progress.."%")
	end

	local size = item:getSize()
    local off = cc.p(size.width - 8,size.height - 8)
    setButtonPoint( item, hasRed ,off,199)

	if hasMark then
		item:addChild(self.selectedItem,50)
	end

	local canActivity = TotemData.checkCanActivate(jTotem, false)
	if canActivity then
		UIFactory.setSpriteChild(item, "activity", true, "TotemUI/activity.png", 0, 0, 10)
		item.activity:setAnchorPoint(1,1)
		item.activity:setPosition(size.width + 5 - 140,size.height + 3)
	else
		UIFactory.setSpriteChild(item, "activity", true)
	end
end

function TotemUI:setItemGray( item )
	item.name:setColor(cc.c3b(0xcc, 0xcc, 0xcc))
	ProgramMgr.setGray(item.bg)
	ProgramMgr.setGray(item.icon)
	for i=1,5 do
		local starIcon = item["star"..i]
		ProgramMgr.setGray(starIcon)
	end
end

function TotemUI:setItemNormal( item )
	item.name:setColor(cc.c3b(0xff, 0xff, 0xff))
	ProgramMgr.setNormal(item.bg)
	ProgramMgr.setNormal(item.icon)
	for i=1,5 do
		local starIcon = item["star"..i]
		ProgramMgr.setNormal(starIcon)
	end
end

function TotemUI:getItem( )
	local item = getLayout(prePath .. "NTotemListItem.ExportJson")
	return item
end

function TotemUI:setIconStar(con, level)
	local pos = cc.p(31 - (level - 1) * 6, -10)
	for i = 1, 5 do
		if i <= level then
			local star = UIFactory.setSpriteChild(con, "t_star_"..i, true, "star_2.png", pos.x + 12 * i, pos.y)
			star:setScale(0.5)
		else
			UIFactory.setSpriteChild(con, "t_star_"..i, true)
		end
	end
end
--左侧列表刷新逻辑结束
---------------------------------------------------------
--特效
--强化进度条
function TotemUI:playUpgradeEffect( layer,posi )
	if not self.blessProgressE then
		local name = "zdyt-tx-01"
		local path1 = string.format('image/armature/ui/NTotemUI/%s/%s.ExportJson',name,name)
		self.blessProgressE = ArmatureSprite:addArmature(path1, name, "TotemUI", 
	                      layer, 0,0,nil,999)
	end
	self.blessProgressE:setPosition(posi)
end

function TotemUI:removeUpgradeEffect( ... )
	if self.blessProgressE then
    	self.blessProgressE:removeFromParent()
    	self.blessProgressE = nil
    end
end

--星级进度条
function TotemUI:playChargeEffect( layer,posi )
	if not self.ChargeE then
		local name = "zdyt2-tx-01"
		local path1 = string.format('image/armature/ui/NTotemUI/%s/%s.ExportJson',name,name)
		self.ChargeE = ArmatureSprite:addArmature(path1, name, "TotemUI", 
	                      layer, 0,0,nil,999)
	end
	self.ChargeE:setPosition(posi)
end

function TotemUI:removeChargeEffect( ... )
	if self.ChargeE then
    	self.ChargeE:removeFromParent()
    	self.ChargeE = nil
    end
end

--可升星
function TotemUI:playCanUpEffect( layer_g,layer_btn,posi_g,posi_btn )
	if not self.starProgressEffect then
		local name = "sxjdtgh-tx-02"
		local path1 = string.format('image/armature/ui/NTotemUI/%s/%s.ExportJson',name,name)
		self.starProgressEffect = ArmatureSprite:addArmature(path1, name, "TotemUI", 
	                      layer_g, 0,0,nil,999)
	end
	self.starProgressEffect:setPosition(posi_g)

	if not self.starBtnEffect then
		local name = "sxangh-tx-01"
		local path1 = string.format('image/armature/ui/NTotemUI/%s/%s.ExportJson',name,name)
		self.starBtnEffect = ArmatureSprite:addArmature(path1, name, "TotemUI", 
	                      layer_btn, 0,0,nil,999)
	end
	self.starBtnEffect:setPosition(posi_btn)
end

function TotemUI:removeCanUpEffect( ... )
	if self.starProgressEffect then
    	self.starProgressEffect:removeFromParent()
    	self.starProgressEffect = nil
    end
	if self.starBtnEffect then
    	self.starBtnEffect:removeFromParent()
    	self.starBtnEffect = nil
    end
end


function TotemUI:playBlessBoxEffect( ... )
	local blessBoxEffect = nil
    local function effectComplete()
    	blessBoxEffect:removeNextFrame()
    	blessBoxEffect = nil
    	self:updateView()
    end
	local posi = nil 
	local qData = TotemData.qBlessTotem 
	local effectIndex,curLevel = TotemUI:getBlessEffectIndex()
	local effectType = TotemUI:getTypeByIndex(effectIndex)
	if effectIndex and effectType then
		local progress = self.con_attr["pgs_"..effectIndex]
		--重置
		self:setProgress(progress, curLevel -1 , effectType, qData.id)
		local precent = progress:getPercent()
		local w = 168
		local s_p = progress:getPositionX() - w/2
		posi = cc.p(s_p + w *precent/100  + w/10 ,0)
		posi = progress:getParent():convertToWorldSpace(posi)
		local layer = self.effectLay
		local name = ""
		if precent <= 0 then
			name = "zgh-tx-01"
			posi.y = progress:getPositionY() + 35
		elseif precent >= 80 then
			name = "ygh-tx-01"
			posi.y = progress:getPositionY() + 35
		else
			name = "zjgh-tx-01"
			posi.y = progress:getPositionY() + 35
		end
		local path1 = string.format('image/armature/ui/NTotemUI/%s/%s.ExportJson',name,name)
    	blessBoxEffect = ArmatureSprite:addArmature(path1, name, "TotemUI", 
                          layer, 0,0,effectComplete)
    	blessBoxEffect:setPosition(posi)
	end
end
--强化属性加成效果
function TotemUI:playArrEffect()
	local addArr = nil
	local posi = nil
	local img = nil
	local qData = TotemData.qBlessTotem 
	local effectIndex,curLevel = TotemUI:getBlessEffectIndex()
	local effectType = TotemUI:getTypeByIndex(effectIndex)
	if effectIndex and effectType then
		addArr = TotemData.getBlessAdd(qData.id,curLevel,effectType)
		img = self.con_attr["img_"..effectIndex]
	end
	if addArr then
		posi = img:getParent():convertToWorldSpace( cc.p( img:getPosition() ) )
		TipsMgr.showSuccess(addArr , posi.x,posi.y)
	end
end

--强化战力效果  战力+xxx
function TotemUI:playBlessFightAddEffect()
	local qData = TotemData.qBlessTotem 
	local bData = TotemData.bBlessTotem
    local dFight =  TotemData.getFightValue(bData) - TotemData.getFightValue(qData)
    if dFight > 0 then
    	local centerPoint = cc.p(693,133)
		TipsMgr.showFightAdd(centerPoint,self,dFight)
    end
end

function TotemUI:getTypeByIndex( index )
	if index == nil then
		return
	end

	local arr = {const.kTotemSkillTypeWake,const.kTotemSkillTypeFormationAdd,const.kTotemSkillTypeSpeed}
	if index <= #arr then
		return arr[index]
	end
end
function TotemUI:getBlessEffectIndex( ... )
	local qData = TotemData.qBlessTotem 
	local sData = TotemData.bBlessTotem
	local q_wake_lv = qData.wake_lv
	local q_speed_lv = qData.speed_lv
	local q_formation_add_lv = qData.formation_add_lv
	local b_wake_lv = sData.wake_lv
	local b_speed_lv = sData.speed_lv
	local b_formation_add_lv = sData.formation_add_lv
	if q_wake_lv ~= b_wake_lv then
		return 1,b_wake_lv
	elseif q_speed_lv ~= b_speed_lv then
		return 3,b_speed_lv
	elseif q_formation_add_lv ~= b_formation_add_lv then
		return 2,b_formation_add_lv
	end
end