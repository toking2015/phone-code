require "lua/game/view/holyUI/BuildingMgr.lua"

BuildingUI = createUIClass("BuildingUI", BuildingMgr.prePath .. "NHolyUI.ExportJson", PopWayMgr.SMALLTOBIG)

function BuildingUI:ctor()
	local btn_speed = createScaleButton(self.btn_speed)

	self.buildingType = BuildingMgr.buildingType
	self.tid = nil

	self:initUI(self.buildingType)

	local function showSpeedStyle()
		local ui = {[2] = "mine", [6] = "holy"}
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', ui[self.buildingType], 'btn_speed') )
		local isOpen, tips = BuildingMgr.isOpenSpeedPanel(self.buildingType)
		if false == isOpen then
			TipsMgr.showError(tips)
		else
			if self.buildingType == const.kBuildingTypeWaterFactory then
				EventMgr.dispatch(EventType.showSpeedStyle, 6)
				-- Command.run('ui show', 'HolySpeedStyle', PopUpType.SPECIAL, true)
			else
				EventMgr.dispatch(EventType.showSpeedStyle, 2)
				-- Command.run('ui show', "MineUpSpeed", PopUpType.SPECIAL, true)
			end
		end
	end
	btn_speed:addTouchEnded(showSpeedStyle)
end

function BuildingUI:initUI(type)
	self.icon:loadTexture(BuildingMgr.prePath .. "holy_greed_bg.png", ccui.TextureResType.localType)
	self.info:loadTexture(BuildingMgr.prePath .. "holy_yellow_bottom.png", ccui.TextureResType.localType)
	self:initTitleTriangle()
	self:initBuildingPanel(type)
end

function BuildingUI:initTitleTriangle()
	local triangle = UIFactory.getTitleTriangle(self, 1)
	triangle:setPositionY(triangle:getPositionY() - 6)
	self.title_bg:setLocalZOrder(2)
end

function BuildingUI:initBuildingPanel(type)
	type = nil == type and const.kBuildingTypeWaterFactory or type
	local icon, name, volume, output, coin_icon = BuildingMgr.getInfoByType(type)

	self.icon_bg.icon:loadTexture(icon, ccui.TextureResType.plistType)
	self.info_bg.coin_icon:loadTexture(coin_icon, ccui.TextureResType.plistType)
	self.title_bg.title:loadTexture(name, ccui.TextureResType.plistType)
	self.info_bg.coin_prod:loadTexture(output, ccui.TextureResType.plistType)
	self.info_bg.coin_cotainer:loadTexture(volume, ccui.TextureResType.plistType)
end

function BuildingUI:onShow()
	-- 更新收取时间
	local cd = BuildingMgr.CDTIME
	local _, time = BuildingData.timeInterval(self.buildingType)
	cd = cd - time
	self:updateObtainTime(cd)
	self.tid = TimerMgr.startTimer(function() 
		cd = cd - 1
		self:updateObtainTime(cd)
	end, 1)
	
	self:updateBuildingData()
end

function BuildingUI:updateBuildingData()
	self:updateIconBg()
	self:updateBuildingInfoBg()
	self:updateBuildingDesc()
	self:updateBuildingUpgrade()
end

function BuildingUI:updateIconBg()
	self:updateBuildingLevel()
end

function BuildingUI:updateBuildingLevel()
	local bLevel = BuildingData.getBuildingLevel(self.buildingType)
	self.icon_bg.lev_bg.lev_num:setString(bLevel)
end

function BuildingUI:updateObtainTime(cd)
	local isShow, time = BuildingMgr.getCDTime(self.buildingType, cd)
	if false == isShow then
		if nil ~= self.tid then
			TimerMgr.killTimer(self.tid)
			self.tid = nil
		end
		self.icon_bg.obtain_time:setVisible(false)
		self.icon_bg.surplus_time:setVisible(false)
	else
		self.icon_bg.obtain_time:setVisible(true)
		self.icon_bg.surplus_time:setVisible(true)
		local dTime, _ = string.gsub(time, ":", "/")
		self.icon_bg.surplus_time:setString(dTime)
	end
end

function BuildingUI:updateBuildingInfoBg()
	local speed = BuildingData.getBuildingProdSpeed(self.buildingType)
	local bLevel = BuildingData.getBuildingLevel(self.buildingType)
	local next_lev = (bLevel == BuildingMgr.MAXLEVEL) and BuildingMgr.MAXLEVEL or (bLevel + 1)
	local next_speed = BuildingData.getBuildingProdSpeed(self.buildingType, next_lev)
	local add_speed = next_speed - speed
	local cur_count = BuildingData.getCurrProdCount(self.buildingType)
	local max_count = speed * 8 * 60
	local next_max_count = next_speed * 8 * 60
	local add_count = next_max_count - max_count

	self.info_bg.txt_speed:setString(speed .."/小时")
	self.info_bg.txt_add_speed:setString("(下一级+" .. add_speed .. ")")
	self.info_bg.txt_cotainer:setString(cur_count .."/" .. max_count)
	self.info_bg.txt_add_container:setString("(下一级+" .. add_count .. ")")

	self.info_bg.prog_bg.prog_bar:setPercent(cur_count/max_count * 100)
end

function BuildingUI:updateBuildingDesc()
	local desc = BuildingMgr.getBuildingDesc(self.buildingType)
	self.desc:setString(desc)
end

function BuildingUI:updateBuildingUpgrade()
	local cond = BuildingMgr.getUpgradeCondition(self.buildingType)
	self.upgrade:setString(cond)
end

function BuildingUI:onClose()
end

function BuildingUI:dispose()
	if nil ~= self.tid then
		TimerMgr.killTimer(self.tid)
		self.tid = nil
	end
end