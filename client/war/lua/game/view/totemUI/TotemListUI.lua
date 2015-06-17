--图腾列表UI

local path = "image/ui/TotemUI/ListUI.ExportJson"
TotemListUI = createUILayout("TotemListUI", path)

function TotemListUI:ctor(parent)
	self.parent = parent
	self.bg_0:setVisible(false)
	self.con_list = BoxContainer.new(2, 4, cc.p(100, 105), cc.p(20, 24), cc.p(60, 70))
	self.con:addChild(self.con_list)
	local function touchEndedHandler(sender, event)
		ActionMgr.save( 'UI', '[TotemListUI] click [con]' )
		local startPos = sender:getTouchStartPos()
		local endPos = sender:getTouchEndPos()
		if not cc.pFuzzyEqual(startPos, endPos, Config.FUZZY_VAR) then
			return
		end
		local index = self.con_list:hitTest(endPos)
		self.parent:changeTotem(parent.sTotemList[index])
	end
	UIMgr.addTouchEnded(self.con, touchEndedHandler)
end

function TotemListUI:updateData()
	local parent = self.parent
	local con = self.con_list
	local list = parent.sTotemList
	local currentTotem = parent.currentTotem
	local shoulShowRed = parent.subIndex == 1
	local shoulBlessRed = TotemData.isCheckBlessRed()
	local redPos = cc.p(80, 80)
	con:setNodeCount(#list)
	for i = 1, con.count do
		local totemIcon = con:getNode(i)
		if not totemIcon then
			totemIcon = UIFactory.getSpriteFrame("bg_role_new.png")
			con:addNode(totemIcon, i)
		end
		local hasMark = false
		local hasRed = false
		if i <= #list then
			sTotem = list[i]
			hasMark = currentTotem.guid == sTotem.guid
			UIFactory.setSpriteChild(totemIcon, "quality", true, TotemData.getQualityFrameName(sTotem.level), 43, 43)
			local iconSp = totemIcon.icon or UIFactory.getSprite(nil, totemIcon, 43, 43)
			totemIcon.icon = iconSp
			local url = TotemData.getAvatarUrlById(sTotem.id)
			BitmapUtil.setTexture(iconSp, url)
			totemIcon.icon:setScale(TotemData.AVATAR_SCALE)
			UIFactory.setSpriteChild(totemIcon, "bg_star", true, "bg_star.png", 43, -10)
			if TotemData.isAddEnergying(sTotem) then
				self:setProgress(totemIcon, true, TotemData.getCharingPercent(sTotem))
				self:setStar(totemIcon, 0)
				self:setDraw(totemIcon, true)
			else
				self:setProgress(totemIcon, false)
				self:setStar(totemIcon, sTotem.level)
				self:setDraw(totemIcon, false)
			end
			if shoulShowRed then
				hasRed = TotemData.checkCanUpLevel(sTotem) or (shoulBlessRed and TotemData.checkCanBless(sTotem))
			end
		else
			UIFactory.setSpriteChild(totemIcon, "quality", true)
			UIFactory.setSpriteChild(totemIcon, "icon", false)
			UIFactory.setSpriteChild(totemIcon, "star_bg", true)
			self:setProgress(totemIcon, false)
			self:setStar(totemIcon, 0)
			self:setDraw(totemIcon, false)
		end
		if hasMark then
			UIFactory.setSpriteChild(totemIcon, "mark", true, "head_mark.png", 70, 20, 10)
		else
			UIFactory.setSpriteChild(totemIcon, "mark", true)
		end
		setButtonPoint(totemIcon, hasRed, redPos)
	end
	local scrollSize = cc.size(235, con:getHeight())
	self.con:setInnerContainerSize(scrollSize)
	con:setPosition(0, scrollSize.height)
end

function TotemListUI:setDraw(con, isShow)
	if isShow then
		if not con.bg_mask then
			con.bg_mask = UIFactory.getDrawNode(con, 43, 43, 5)
			con.bg_mask:drawDot(cc.p(0, 0), 36, cc.c4f(0, 0, 0, 0x40))
			con.txt_mask = UIFactory.getLabel("充能中...", con, 43, 41, 18, cc.c3b(0x31, 0xff, 0x16), nil, nil, 6)
		end
	else
		if con.bg_mask then
			con.bg_mask:removeFromParent()
			con.bg_mask = nil
			con.txt_mask:removeFromParent()
			con.txt_mask = nil
		end
	end
end

function TotemListUI:setProgress(con, isShow, percent)
	if isShow then
		if not con.progress then
			con.progress = UIFactory.getProgress("bg_progress.png", true, con, 43, -10)
		end
		con.progress:setPercent(percent)
	else
		if con.progress then
			con.progress:removeFromParent()
			con.progress = nil
		end
	end
end

function TotemListUI:setStar(con, level)
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