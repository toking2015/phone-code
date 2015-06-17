HeadSelectUI = createUIClass("HeadSelectUI", TeamCommon.prePath .. "HeadSelectUI.ExportJson", PopWayMgr.SMALLTOBIG)

function HeadSelectUI:ctor()
	self.offset = cc.p(65, -75)
	self.cellSize = cc.size(125, 110)
	self.column = 5
	function self.onAvatarTouchEnded(touch, event)
		ActionMgr.save( 'UI', string.format('[%s] up [%s]', self.winName, 'icon') )
		local pos = touch:getLocation()
		if math.abs(self.orgClickPos.x - pos.x) > 5 or math.abs(self.orgClickPos.y - pos.y) > 5 then
			return
		end
		local icon = event:getCurrentTarget()
		if icon.avatar then
			Command.run("team avatar change", icon.avatar.id)
		end
	end
	function self.onAvatarTouchBegin(touch, event)
		ActionMgr.save( 'UI', string.format('[%s] down [%s]', self.winName, 'icon') )
		self.orgClickPos = touch:getLocation()
	end
	self.img_mark = cc.Sprite:createWithSpriteFrameName("head_mark.png")
	self:addChild(self.img_mark)
	function self.updateMarkHandler()
		local avatar = findAvatar(gameData.getSimpleDataByKey("avatar"))
		if avatar then
			local con = self:getConByType(avatar.type)
			local bg = con:getChildByTag(avatar.id)
			if not bg then
				return
			end
			self.img_mark:retain()
			self.img_mark:removeFromParent()
			self.img_mark:setPosition(bg:getPositionX(), bg:getPositionY())
			con:addChild(self.img_mark, 3)
			self.img_mark:release()
		end
	end
	self.avatarList = GetDataList("Avatar")
	self.systemList = {}
	self.soldierMap = {}
	for _,v in ipairs(self.avatarList) do
		if v.type == TeamData.AVATAR_SOLDIER then
			self.soldierMap[v.soldier] = v
		elseif v.type == TeamData.AVATAR_AVATAR then
			table.insert(self.systemList, v)
		end
	end
end

function HeadSelectUI:getConByType(type)
	return self.scroll.con["con_"..type]
end

function HeadSelectUI:addOneAvatar(con, count, avatar)
	local x = count % self.column * self.cellSize.width + self.offset.x
	local y = -math.floor(count / self.column) * self.cellSize.height + self.offset.y
	local bg = UIFactory.getSpriteFrame("SettingUI/txdk.png", con, x, y, 1)
	bg:setTag(avatar.id)
	local icon = UIFactory.getSprite(TeamData.getAvatarUrl(avatar), con, x + TeamData.AVATAR_OFFSET.x, y + TeamData.AVATAR_OFFSET.y, 2)
	bg.avatar = avatar
	icon.avatar = avatar
	UIMgr.registerScriptHandler(icon, self.onAvatarTouchEnded, cc.Handler.EVENT_TOUCH_ENDED, true)
	UIMgr.registerScriptHandler(icon, self.onAvatarTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN, true)
end

function HeadSelectUI:delayInit()
	UIFactory.getTitleTriangle(self)
	self.img_cover:loadTexture(TeamCommon.prePath .. "gdt.png", ccui.TextureResType.localType)
end

function HeadSelectUI:onShow()
	performNextFrame(self, self.delayOnShow, self)
end

function HeadSelectUI:delayOnShow()
	EventMgr.addListener(EventType.UserSimpleUpdate, self.updateMarkHandler)
	self:updateData()
	self.updateMarkHandler()
end

function HeadSelectUI:onClose()
	EventMgr.removeListener(EventType.UserSimpleUpdate, self.updateMarkHandler)
end

function HeadSelectUI:updateData()
	local countList = {[TeamData.AVATAR_AVATAR]=0, [TeamData.AVATAR_SOLDIER]=0, [TeamData.AVATAR_CHENGJIU]=0}
	for i = 1, #self.systemList do
		local v = self.systemList[i]
		local con = self:getConByType(v.type)
		self:addOneAvatar(con, countList[v.type], v)
		countList[v.type] = countList[v.type] + 1
	end
	local soldierTable = SoldierData.getTable()
	for _,soldier in pairs(soldierTable) do
		if soldier.quality >= 7 then --大于等于紫色
			local v = self.soldierMap[soldier.soldier_id]
			if v then
				local con = self:getConByType(v.type)
				self:addOneAvatar(con, countList[v.type], v)
				countList[v.type] = countList[v.type] + 1
			end
		end
	end
	local startY = 0
	for i = 1, 3 do
		local txt = self.scroll.con["txt_"..i]
		startY = startY + txt:getSize().height + 10
		txt:setPositionY(-startY)
		if i == TeamData.AVATAR_SOLDIER then
			local tips = self.scroll.con["tips_"..i]
			startY = startY + tips:getSize().height + 10
			tips:setPositionY(-startY)
		end
		local con = self:getConByType(i)
		local conHeight = self.cellSize.height * math.ceil(countList[i] / self.column) + 30
		conHeight = math.max(100, conHeight)
		local conSize = con:getSize()
		conSize.height = conHeight
		con:setSize(conSize)
		con.bg:setSize(conSize)
		con.bg:setPositionY(-conHeight)
		startY = startY + conHeight + 10
		con:setPositionY(-startY + conHeight)
		if countList[i] == 0 then
			if not con.txt_none then
				con.txt_none = UIFactory.getText("当前没有可以使用的头像", con, conSize.width / 2, -conSize.height / 2, 20, cc.c3b(0xe8, 0xa1, 0x61))
			end
		else
			if con.txt_none then
				con.txt_none:removeFromParent()
				con.txt_none = nil
			end
		end
	end
	startY = startY + 20
	local size = self.scroll:getSize()
	self.scroll.con:setPositionY(startY)
	self.scroll:setInnerContainerSize(cc.size(size.width, math.max(size.height, startY)))
end
