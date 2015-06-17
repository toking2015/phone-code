require "lua/game/view/trialUI/TrialMgr.lua"
require "lua/game/view/trialUI/TrialMainItem.lua"
require "lua/game/view/trialUI/TrialRuleUI.lua"

TrialMainUI = createUIClass("TrialMainUI", TrialMgr.prePath .. "TrialMainUI/TrialMain.ExportJson", PopWayMgr.SMALLTOBIG)
-- TrialMainUI.sceneName = "common"

function TrialMainUI:ctor()
	self.isUpRoleTopView = true
	self.itemList = {}
    local date = GameData.getServerDate()
    local list = {}

	local data = GetDataList("Trial")
	for i, trial in pairs(data) do
		local item = TrialMainItem.new(trial)
		table.insert(self.itemList, item)
		self:addChild(item)

		item:setPosition(128 + 229 * (i - 1), 227)
		item:updateData()

		--预加载模型资源
	    if self.checkWday(date, trial) then
			table.insert(list, trial)
	    end
	end

	--预加载模型资源
	if 1 == #list then
		local userTrial = TrialMgr.getTrial(list[1].id)
		if not userTrial or userTrial.try_count < list[1].try_count then
			local conf = findMonsterFightConf(list[1].monster_id)
			if conf then
				local __l = {}
				for __, s2 in pairs(conf.add) do
					table.insert(__l, {attr=const.kAttrMonster, id=s2.first})
				end
				for __, s2 in pairs(conf.totemadd) do
					table.insert(__l, {attr=const.kAttrTotem, id=s2.first, level=4})
				end
				LoadMgr.loadFightModelListAsyncForWait(__l)
			end
		end
	end

	TrialMgr.initRewardList()
	TrialMgr.refreshData()

	local function enter()
        Command.run("ui show", "TrialRuleUI",PopUpType.SPECIAL)
	end
	createScaleButton(self.btn)
	self.btn:addTouchEnded(enter)

	EventMgr.removeListener(EventType.FightEnd, TrialMgr.listener)

	TrialMgr.currentTrial = nil
end

function TrialMainUI:onClose()
	EventMgr.removeListener(EventType.TrialRewardUpdate, self.updateData)
	EventMgr.removeListener(EventType.TrialUpdate, self.updateData)
end

function TrialMainUI:onShow()
	performNextFrame(self, self.delayOnShow, self)
end

function TrialMainUI:delayOnShow()
	self:updateData()
	EventMgr.addListener(EventType.TrialRewardUpdate, self.updateData, self)
	EventMgr.addListener(EventType.TrialUpdate, self.updateData, self)
end

function TrialMainUI:updateData()
	for __, item in pairs(self.itemList) do
		item:updateData()
	end
end

function TrialMainUI:backHandler()
	--清空预加载资源( 不清会泄漏 )
    PopMgr.removeWindow(self)
	LoadMgr.clearAsyncCache()
end

function TrialMainUI.checkWday(date, trial)
	for __, v in pairs(trial.open_day) do
		local val = v + 1
		if val > 7 then
			val = 1
		end

		if date.hour >= 6  then
	    	if date.wday == val then
	    		return true
	    	end
	    else
	    	val = val + 1
	    	if val > 7 then
	    		val = 1
	    	end

	    	if date.wday == val then
	    		return true
	    	end
    	end
    end

	return false
end