SettingUI = createUIClass("SettingUI", TeamCommon.prePath .. "SettingUI.ExportJson", PopWayMgr.SMALLTOBIG)

function SettingUI:ctor()
	local function logoutHandler(ref, eventType)
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'btn_logout') )
		Command.run("loading logout")
	end
	TeamCommon.createButton(self.btn_avatar, TeamCommon.getUIShowHandler("HeadSelectUI", nil, self.winName, 'btn_avatar'))
	TeamCommon.createButton(self.btn_name, TeamCommon.getUIShowHandler("RenameUI", nil, self.winName, 'btn_name'))
	TeamCommon.createButton(self.btn_notice, TeamCommon.getUIShowHandler("NoticeSettingUI", nil, self.winName, 'btn_notice'))
	TeamCommon.createButton(self.btn_logout, logoutHandler)
	TeamCommon.createButton(self.btn_gift, TeamCommon.getUIShowHandler("CDKeyUI", nil, self.winName, 'btn_gift'))
	self.toggle_names = {"sound", "music"}
	local function toggleHandler(target, selected)
		ActionMgr.save( 'UI', string.format('[SettingUI] click [toggle_%s]', target.toggleName) )
		TeamData.setSettingValue(target.toggleName, selected)
	end
	for i = 1, #self.toggle_names do
		self["toggle_"..i].toggleName = self.toggle_names[i]
		UIFactory.initToggleButton(self["toggle_"..i], self["state_"..i], true, toggleHandler)
	end
	self.txt_id = UIFactory.getText("", self, 108, 312, 18, cc.c3b(0xff, 0xd6, 0x73))
end

function SettingUI:delayInit()
	UIFactory.getTitleTriangle(self)
	self.img_load_1:loadTexture(TeamCommon.prePath .. "flag.png", ccui.TextureResType.localType)
	self.img_load_2:loadTexture(TeamCommon.prePath .. "222.png", ccui.TextureResType.localType)
end

function SettingUI:onShow()
	EventMgr.addListener(EventType.TeamNameChange, self.updateName, self)
	EventMgr.addListener(EventType.UserSimpleUpdate, self.updateData, self)
	self:updateData()
	if inf.user_center then
		if not self.btn_user then
			local function clickHandler()
				ActionMgr.save( 'UI', '[SettingUI] click [btn_user]' )
				inf.user_center()
			end
			self.btn_user = UIFactory.getButton("btn3_red.png", self, 185, 24, 2)
			UIFactory.getSprite(TeamCommon.prePath .. "user.png", self.btn_user, 71, 47 / 2)
			self.btn_user:addTouchEnded(clickHandler)
		end
		self.btn_logout:setPosition(cc.p(25, 24))
	else
		self.btn_logout:setPosition(cc.p(105, 24))
	end
	self.txt_id:setString("ID:"..gameData.id)
end

function SettingUI:onClose()
	EventMgr.removeListener(EventType.TeamNameChange, self.updateName)
	EventMgr.removeListener(EventType.UserSimpleUpdate, self.updateData)
	if self.btn_user then
		self.btn_user:removeFromParent()
		self.btn_user = nil
	end
end

function SettingUI:updateData()
	for i = 1, #self.toggle_names do
		UIFactory.setToggleButton(self["toggle_"..i], self["state_"..i], TeamData.getSettingValue(self.toggle_names[i]))
	end
	self:updateName()
	self:updateAvatar()
	self:updateTexts()
end

function SettingUI:updateName()
	self.txt_name:setString(gameData.getSimpleDataByKey("name"))
end

function SettingUI:updateAvatar()
	local avatarId = gameData.getSimpleDataByKey("avatar")
	if self.avatarId ~= avatarId then
		self.avatarId = avatarId
		local url = TeamData.getAvatarUrlById(avatarId)
		UIFactory.setSpriteChild(self.img_avatar, "icon", false, url, 43 + TeamData.AVATAR_OFFSET.x, 43 + TeamData.AVATAR_OFFSET.y)
	end
end

function SettingUI:updateTexts()
	local team_level = gameData.getSimpleDataByKey("team_level")
	self.value_1:setString(team_level) -- 等级
	local jLevel = findLevel(team_level)
	local addStr = ""
	if jLevel then
		addStr = "/" .. jLevel.team_xp
	end
	self.value_2:setString(gameData.getSimpleDataByKey("team_xp") .. addStr) -- 经验
	self.value_3:setString(SoldierData.getCount(const.kSoldierTypeCommon)) -- 英雄数量
	self.value_4:setString(TotemData.getCount()) -- 图腾数量
	local jLevel = findLevel(team_level)
	self.value_5:setString(jLevel and jLevel.soldier_lv or "") -- 英雄等级上限
end
