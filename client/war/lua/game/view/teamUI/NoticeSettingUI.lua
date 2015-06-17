NoticeSettingUI = createUIClass("NoticeSettingUI", TeamCommon.prePath .. "NoticeSettingUI.ExportJson", PopWayMgr.SMALLTOBIG)

function NoticeSettingUI:ctor()
	self.toggle_names = {
		"strength_get",
		"activity",
		"store",
		"strength_full"
	}
	local function toggleHandler(target, selected)
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, target.toggleName) )
		TeamData.setSettingValue(target.toggleName, selected)
	end
	for i = 1, #self.toggle_names do
		self["toggle_"..i].toggleName = self.toggle_names[i]
		UIFactory.initToggleButton(self["toggle_"..i], self["state_"..i], true, toggleHandler)
	end
end

function NoticeSettingUI:delayInit()
	UIFactory.getTitleTriangle(self)
end

function NoticeSettingUI:onShow()
	self:updateData()
end

function NoticeSettingUI:updateData()
	for i = 1, #self.toggle_names do
		UIFactory.setToggleButton(self["toggle_"..i], self["state_"..i], TeamData.getSettingValue(self.toggle_names[i]))
	end
end