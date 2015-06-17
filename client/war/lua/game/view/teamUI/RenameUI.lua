--声明类
local url = TeamCommon.prePath .. "RenameUI.ExportJson"
RenameUI = createUIClass("RenameUI", url, PopWayMgr.SMALLTOBIG)

--构造函数
function RenameUI:ctor()
	UIFactory.getTitleTriangle(self)
	local conX = self.btn_confirm:getPositionX()
	self.btn_confirm:setPositionX(self.btn_cancel:getPositionX())
	self.btn_cancel:setPositionX(conX)
	local function changeNameHandler(ref, eventType)
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'btn_confirm') )
		local cost = TeamData.getChangeNameCost()
		local name = self.txt_name:getText();
		if name == nil or name == "" then
			TipsMgr.showError("请输入名字")
			return
		end
		if (name ~= "" and name ~= gameData.getSimpleDataByKey("name")) then
			if not (CoinData.checkLackCoin(const.kCoinGold, cost)) then
				if not WordFilter.checkName(name) then
					Command.run("team rename", name)
				else
					TipsMgr.showError("名字存在非法字符")
				end
			end
		end
	end
	local function closeHandler(ref, eventType)
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'btn_cancel') )
		Command.run("ui hide", "RenameUI")
	end
	local function randomHandler(ref, eventType)
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'btn_roll') )
		self.txt_name:setText(NameRandom.getRandomName())
	end
	TeamCommon.createButton(self.btn_confirm, changeNameHandler)
	TeamCommon.createButton(self.btn_cancel, closeHandler)
	TeamCommon.createButton(self.btn_roll, randomHandler)
	self.onTeamNameChange = closeHandler
	TextInput:replace(self.txt_name, Config.MAX_NAME_LENGTH)
end

--onShow处理方法
--处理添加事件侦听
function RenameUI:onShow()
	self.txt_name:setText(gameData.getSimpleDataByKey("name"))
	self:updateData() --调用窗口更新
	EventMgr.addListener(EventType.TeamNameChange, self.onTeamNameChange)
end

--onClose处理方法
--移除事件侦听
function RenameUI:onClose()
	EventMgr.removeListener(EventType.TeamNameChange, self.onTeamNameChange)
end

function RenameUI:onBeforeClose()
	if TeamData.forceRename == true then
		return true
	end
end

--窗口更新方法
function RenameUI:updateData()
	local cost = TeamData.getChangeNameCost()
	if cost == 0 then
		self.img_free:setVisible(true)
		self.img_cost:setVisible(false)
		self.img_gold:setVisible(false)
	else
		self.img_free:setVisible(false)
		self.img_cost:setVisible(true)
		self.img_gold:setVisible(true)
	end
end
