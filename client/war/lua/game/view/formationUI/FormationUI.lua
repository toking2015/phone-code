--@author zengxianrong
local prePath = "image/ui/FormationUI/"

local boxSize = cc.p(86, 90)
local offset = cc.p(72, 57)
local spaceSize = cc.p(26, 44)
local column = 4
local minRow = 4
local totemOffset = cc.p(0, -3)

FormationProgress = class("FormationProgress", function(pgs_url)
	local sp = cc.Sprite:create(prePath.. "pgs_bg.png")
	sp.progress = UIFactory.getProgress(pgs_url, false, sp, 75 / 2, 9 / 2)
	return sp
end)

function FormationProgress:setPercent(number)
	self.progress:setPercent(number)
end

local FormationItem = class("FormationItem", function()
	return cc.Sprite:createWithSpriteFrameName("bg_role_new.png")
end)

function FormationItem:setData(sData, type, attr)
	self.sData = sData
	if (sData == nil) then
		-- self:setVisible(false)
		self.quality = nil
		BitmapUtil.setTexture(self.item, nil)
		self.item = nil
		self.mark = nil
		self.recommend = nil
		self.progress_health = nil
		self.progress_power = nil
		self.img_dead = nil
		self.star_bg = nil
		for i = 1, 5 do
			self["t_star_"..i] = nil
		end
		self:removeAllChildren()
		return
	end
	-- self:setVisible(true)
	local url
	local qurl
	local isRecommend = false
	local avatarOffset = TeamData.AVATAR_OFFSET
	if (attr == const.kAttrSoldier) then
		qurl = SoldierData.getQualityFrameName(sData.quality)
		local soldier = FormationData.getJson(sData.soldier_id, attr)
		if soldier then
			url = SoldierData.getAvatarUrl(soldier)
			isRecommend = FormationData.isRecommend(type, attr, soldier.equip_type)
		else
			LogMgr.error("英雄数据不存在：", sData.soldier_id)
		end
	elseif (attr == const.kAttrTotem) then
		avatarOffset = totemOffset
		local totem = FormationData.getJson(sData.id, attr)
		url = TotemData.getAvatarUrl(totem)
		qurl = TotemData.getQualityFrameName(sData.level)
		isRecommend = FormationData.isRecommend(type, attr, totem.type)
	end
	self:addSprite("quality", boxSize.x / 2, boxSize.y / 2)
	self.quality:setSpriteFrame(qurl)
	self:addSprite("item", boxSize.x / 2 + avatarOffset.x, boxSize.y / 2 + avatarOffset.y + 3)
	BitmapUtil.setTexture(self.item, url)
	self.item:setScale(attr == const.kAttrTotem and TotemData.AVATAR_SCALE or 1)
	if (FormationData.getIsUp(type, sData.guid, attr)) then
		self:addSprite("mark", boxSize.x / 2 + 25, boxSize.y / 2 - 20, 6)
		self.mark:setSpriteFrame("head_mark.png")
	else
		if (self.mark) then
			self:removeChild(self.mark)
			self.mark = nil
		end
	end
	local rcUrl = isRecommend and "formation_recommend.png" or nil
	UIFactory.setSpriteChild(self, "recommend", true, rcUrl, 15, 85, 5)
	UIFactory.setSpriteChild(self, "star_bg", false, prePath.."star_bg.png", boxSize.x / 2, -10, 4)
	self:setStar(self.star_bg, attr == const.kAttrTotem and sData.level or sData.star)
	if type == const.kFormationTypeTomb and attr == const.kAttrSoldier then
		self:setHP(sData)
	else
		ProgramMgr.setNormal(self.item)
		self:remove("img_dead")
		self:remove("progress_health")
		self:remove("progress_power")
	end
end

function FormationItem:remove(name)
	if self[name] then
		self[name]:removeFromParent()
		self[name] = nil
	end
end

function FormationItem:setHP(ss)
	local isDead = false
	local hasRage = false
	local hp, maxHp = 0, 1
	local rage, maxRage = 0, 1
	if ss then
		local extAble = SoldierData.getFightextAble(ss.guid, const.kAttrSoldier)
		if extAble then
			maxHp = extAble.able.hp
			hp = extAble.able.hp
			maxRage = 100
			rage = extAble.able.rage
			
			local quality = ss.quality
			if const.kQualityWhite ~= quality then
				hasRage = true
			end

			extAble = TombData.getTargetFightSoldier(const.kSoldierTypeTombSelf, ss.guid)
			if extAble then
				hp = extAble.hp
				rage = extAble.mp

				if 0 == extAble.hp then
					isDead = true
				end
			end
		end
	end
	if not isDead then
		if not self.progress_health then
			self.progress_health = FormationProgress.new(prePath.."health.png")
			self.progress_health:setPosition(boxSize.x / 2, boxSize.y /2 + 50)
			self:addChild(self.progress_health, 10)
		end
		self.progress_health:setPercent(math.min(100, hp * 100 / maxHp))
		if hasRage then
			if not self.progress_power then
				self.progress_power = FormationProgress.new(prePath.."power.png")
				self.progress_power:setPosition(boxSize.x / 2, boxSize.y /2 + 40)
				self:addChild(self.progress_power, 10)
			end
			self.progress_power:setPercent(math.min(100, (rage or 0) * 100 / maxRage))
		else
			self:remove("progress_power")
		end
		self:remove("img_dead")
		ProgramMgr.setNormal(self.item)
	else
		if not self.img_dead then
			self:addSprite("img_dead", boxSize.x / 2, boxSize.y / 2 + 45, 10)
			self.img_dead:setTexture(prePath.."hasdead.png")
		end
		self:remove("progress_health")
		self:remove("progress_power")
		ProgramMgr.setGray(self.item)
	end
end

function FormationItem:setStar(con, level)
	local pos = cc.p(boxSize.x / 2 - 11 - (level - 1) * 6, 15)
	local url = prePath .. "star.png"
	for i = 1, 5 do
		if i <= level then
			local star = UIFactory.setSpriteChild(con, "t_star_"..i, false, url, pos.x + 12 * i, pos.y)
		else
			UIFactory.setSpriteChild(con, "t_star_"..i, false)
		end
	end
end

function FormationItem:addSprite(name, dx, dy, depth)
	local sp = self[name]
	if (sp == nil) then
		sp = cc.Sprite:create()
		self:addChild(sp, depth or 0)
		self[name] = sp
	end
	dx = dx or 0
	dy = dy or 0
	sp:setPosition(dx, dy)
end

local FormationBr0 = class("", function()
	return getLayout(prePath .. "FormationBr0.ExportJson")
end)

local FormationBr1 = class("", function()
	return getLayout(prePath .. "FormationBr1.ExportJson")
end)

FormationUI = createUILayout("FormationUI", prePath .. "FormationUI.ExportJson", "FormationWin")

function FormationUI:ctor()
	self.canFormation = FormationData.getCanFormation(FormationData.type) --能否布阵
	self.txt_title:setVisible(self.canFormation) --显示
	self:setTouchEnabled(false)
    self.attr = const.kAttrSoldier
    self.pool = Pool.new()
    self.subMenuAttrs = {const.kAttrSoldier, const.kAttrTotem}
    self.btnList = {self.btn_1, self.btn_2}
    local subMenuNames = {"formation_soldier_", "formation_totem_"}
    local function btnHandler(index)
    	ActionMgr.save( 'UI', string.format('[FormationUI] click [btn_%s]', index) )
    	FormationData.attr = index == 1 and const.kAttrSoldier or const.kAttrTotem --保存状态
		self.attr = self.subMenuAttrs[index]
		self:updateData()
		self.con_icon:jumpToTop()
    end
    UIFactory.initSubMenu(self.btnList , subMenuNames, btnHandler, 2)
	self.boxCon = BoxContainer.new(column, minRow, boxSize, spaceSize, cc.p(offset.x, offset.y))
	self.con_icon:addChild(self.boxCon)
	self.containerSize = self.con_icon:getSize()
	self.scrollSize = cc.size(self.containerSize.width, self.containerSize.height)

	function self.showTipsHandler()
		local item = self._touch_start_item
		if not item then
			return
		end
		if self.attr == const.kAttrTotem then
			self._hasShowTips = true
			TipsMgr.showTips(endPos, TipsMgr.TYPE_TOTEM, item.sData, TotemData.getGlyphList())
		end
	end
end

function FormationUI:setAttrIndex(index)
	self.btnList.touchEndedHandler(self['btn_'..index], ccui.TouchEventType.ended)
end

function FormationUI:setAttr(attr)
	if attr == const.kAttrSoldier then
		self:setAttrIndex(1)
	elseif attr == const.kAttrTotem then
		self:setAttrIndex(2)
	end
end

function FormationUI:setType(type)
	self.type = type
end

function FormationUI:setStyle(style)
	if (style ~= self.style) then
		self.style = style
		if (self.item_br) then
			self.con_br:removeChild(self.item_br)
			self.item_br = nil
		end
	end
    if (self.style == FormationData.STYLE_TWO and FormationData.oppFightValue) then
    	self.item_br = FormationBr1.new()
    else
    	self.item_br = FormationBr0.new()
    end
    local function comfirmHandler()
    	ActionMgr.save( 'UI', '[FormationUI] click [item_br.btn]' )
    	Command.run("formation confirm")
    end
    self.item_br.btn:setTouchEnabled(true)
    createScaleButton(self.item_br.btn)
    self.item_br.btn:addTouchEnded(comfirmHandler)
    self.con_br:addChild(self.item_br, 10)
end

function FormationUI:updateFightValue()
	local fightValue = FormationData.lastFightValue
	self.item_br.txt_br_my:setString(tostring(fightValue))
end

function FormationUI:updateData()
	self.txt_title:setString(FormationData.getRecommendText(self.type, self.attr))
	self:updateFightValue()
	if self.style == FormationData.STYLE_TWO then
		if FormationData.oppFightValue then
			self.item_br.txt_br_recommend:setString(tostring(FormationData.oppFightValue))
		end
	end
	local list = nil
	if self.attr == const.kAttrSoldier then
		list = SoldierData.getSortedSoldierList()
	elseif self.attr == const.kAttrTotem then
		list = TotemData.getData()
	end
	self.boxCon:setNodeCount(#list)
	local len = self.boxCon.count
	for i = 1, len do
		local item = self.boxCon:getNode(i)
		if (item == nil) then
			item = FormationItem.new()
			self.boxCon:addNode(item, i)
			local function itemClickHandler(touch)
				ActionMgr.save( 'UI', string.format('[FormationUI] click [item.%s]', i) )
				self:onItemClicked(i, touch)
			end
			local function itemBeginHandler(touch)
				self:onItemBeginHandler(i, touch)
			end
			UIMgr.registerScriptHandler(item, itemClickHandler, cc.Handler.EVENT_TOUCH_ENDED, true)
			UIMgr.registerScriptHandler(item, itemBeginHandler, cc.Handler.EVENT_TOUCH_BEGAN, true)
		end
		item:setData(list[i], self.type, self.attr)
	end
	self.scrollSize.height = math.max(self.boxCon.row * (boxSize.y + spaceSize.y) + offset.y, self.containerSize.height)
	self.con_icon:setInnerContainerSize(self.scrollSize)
	self.boxCon:setPosition(0, self.scrollSize.height)
	self:updateRedPoint()
end

function FormationUI:updateRedPoint()
	local pos = cc.p(8, 70)
	setButtonPoint(self.btn_1, FormationData.checkCanUpSoldier(self.type), pos, 200)
	setButtonPoint(self.btn_2, FormationData.checkCanUpTotem(self.type), pos, 200)
end

function FormationUI:getSoldierNodeForId( soldierId )
	for i = 1, self.boxCon.count do
		local item = self.boxCon:getNode(i)
		if item and item.sData and item.sData.soldier_id == soldierId then
			return item
		end
	end
end

function FormationUI:getShenMingTotemNode()
	for i = 1, self.boxCon.count do
		local item = self.boxCon:getNode(i)
		if item and item.sData and item.sData.id == 80201 then
			return item
		end
	end
end

function FormationUI:onItemBeginHandler(index, touch)
	self._touch_start_pos = touch:getLocation()
	self._touch_start_item = self:getTouchItem(index, touch)
	if self._touch_action then
		self:stopAction(self._touch_action)
	end
	self._touch_action = performWithDelay(self, self.showTipsHandler, Config.TIPS_DELAY_TIME)
end

function FormationUI:getTouchItem(index, touch)
	local item = self.boxCon:getNode(index)
	if not item or not item.sData then
		return
	end
	local startPos = self._touch_start_pos
	local endPos = touch:getLocation()
	if not cc.pFuzzyEqual(startPos, endPos, Config.FUZZY_VAR) then
		return
	end
	return item
end

function FormationUI:onItemClicked(index, touch)
	if self._hasShowTips then
		self._hasShowTips = nil
		return
	end
	if self._touch_action then
		self:stopAction(self._touch_action)
		self._touch_action = nil
	end
	local item = self:getTouchItem(index, touch)
	if not item then
		return
	end
	local result = false
	local isUp = false
	if item.sData then
        if FormationData.getIsUp(self.type, item.sData.guid, self.attr) then
			if not self.canFormation then
				return
			end
			result = FormationData.downByGuid(self.type, item.sData.guid, self.attr)
		else
			if FormationData.checkCanUp(self.type, item.sData.guid, self.attr) then
				result = FormationData.upByGuid(self.type, item.sData.guid, self.attr)
				isUp = true
			else
				if self.attr == const.kAttrTotem then
					TipsMgr.showError("图腾上阵数量已满")
				else
					TipsMgr.showError("英雄上阵数量已满")
				end
			end
		end
	end
	if result then
		item:setData(item.sData, self.type, self.attr)
		self:updateRedPoint()
		self:updateFightValue()
		if isUp then
			EventMgr.dispatch(EventType.UserFormationUp, {type=self.type, attr=self.attr, sData=item.sData})
		else
			EventMgr.dispatch(EventType.UserFormationDown)
		end
	end
end

