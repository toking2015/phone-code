require "lua/game/view/tombUI/TombMainCard.lua"
require "lua/game/view/tombUI/TombRuleUI.lua"

TombMainUI = createUIClass("TombMainUI", "image/ui/TombUI/TombMain.ExportJson", PopWayMgr.SMALLTOBIG)

function TombMainUI:ctor()
	TombData:init()
	TombData.refreshData()
	self.actionFlag = 0
	self.nextFlag = 0
	self.list = {}

	self.ScrollView:setInnerContainerSize(cc.size(1065, 350))

	local function reset()
		if self.mopup then
			showMsgBox("本次扫荡会自动通关到第" .. GameData.user.tomb_info.max_win_count ..  "关，通关后所有\r\n\r\n              英雄将阵亡。是否确认？",
				function ( ... )
					Command.run("tomb mop_up")
					Command.run('SaoDangUI show')
				end)
			return
		end
		local count = TombData.getTryCount()
		if count <= 0 then 
			showMsgBox("今日剩余重置次数：0[btn=one]")
		else
			showMsgBox("是否重新开始？（今日剩余重置次数：" .. count .. "）",
			function ( ... )
				Command.run("tomb reset")
			end)
		end
	end
	createScaleButton(self.btn_start)
	self.btn_start:addTouchEnded(reset)

	local function next()
			if TombData.area + 1 >= 5 then
			return
		end

		self.btn_next:setVisible(false)

		-- for __, card in pairs(self.list) do
		-- 	card:clear()
		-- end

		local moveUp = cc.MoveBy:create(1, cc.p(0, 344))
		local call = cc.CallFunc:create(function ( ... )
					self.ScrollView.panel:stopAllActions()
			self.ScrollView.panel:setPositionY(344)
			-- self.ScrollView.panel:runAction(cc.MoveTo:create(0, cc.p(0, 344)))

			for __, card in pairs(self.list) do
				card:clear()
				card:removeFromParent()
			end
			
			self.list = self.nextList
			self.nextList = nil

			TombData.area = TombData.area + 1
			self:update()
			self.ScrollView:scrollToPercentHorizontal(0, 1, true)
		end)
		self.panelAction = self.ScrollView.panel:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, call)))
	end
	createScaleButton(self.btn_next)
	self.btn_next:addTouchEnded(next)
	self.btn_next:setVisible(false)

	local function rule()
			Command.run("ui show", "TombRuleUI", PopUpType.SPECIAL)
	end
	createScaleButton(self.btn_rule)
	self.btn_rule:addTouchEnded(rule)

	local function reward()
			--选择显示那个商店
		StoreData.SelectType = StoreData.Type.DJ
        StoreData.yongqiflag = true 
        Command.run("ui hide" , "TombMainUI" )
		Command.run("ui show", "Store", PopUpType.SPECIAL)
	end
	createScaleButton(self.btn_reward)
	self.btn_reward:addTouchEnded(reward)

	if 0 == #GameData.user.tomb_target_list then
		Command.run("tomb target_list")
	end
end

function TombMainUI:delayInit()
	for i = 1, 5, 1 do
		local card = TombMainCard.new(i)
		table.insert(self.list, card)
        
		self.ScrollView.panel:addChild(card)
		card:setPosition((i - 1) * 215, 0)
	end
end

function TombMainUI:onShow()
	performNextFrame(self, self.doOnShow, self)
end

function TombMainUI:doOnShow()
	performNextFrame(self, self.update, self)
	EventMgr.addListener(EventType.tombUiUpdata, self.update, self)
	EventMgr.removeListener(EventType.FightEnd, TombData.listener)
end

function TombMainUI:onClose()
	EventMgr.removeListener(EventType.tombUiUpdata, self.update)

	for __, card in pairs(self.list) do
		card:clear()
	end
	ModelMgr:releaseUnFormationModel()
end

function TombMainUI:update()
	self.win = GameData.user.tomb_info.win_count + 1
	self.reward = GameData.user.tomb_info.reward_count
	self.area = TombData.area

	if GameData.user.tomb_info.max_win_count > 0 and 2 == GameData.user.tomb_info.try_count then
		self.btn_start.btn_image:loadTexture("tomb_text2.png", ccui.TextureResType.plistType)
		self.mopup = true
	else	
		self.btn_start.btn_image:loadTexture("tomb_text1.png", ccui.TextureResType.plistType)
		self.mopup = nil
	end

	if self.reward % 5 > 2 then
		self.ScrollView:scrollToPercentHorizontal(100, 1, true)
	end

	--最后通关兼容处理
	if 5 == self.area then
		self.area = 4
	end

	for __, card in pairs(self.list) do
		card:setDate(self.area, self.win, self.reward)
	end

	if 2 == self.win and 0 == self.reward and 1 ~= self.actionFlag then
		self.actionFlag = 1
	end

	if not TombData.checkNext(self.area) then
		self.btn_next:setVisible(false)
	else
		self.btn_next:setVisible(true)
		self:initNext()
	end

	if self.win <= 1 and 0 == self.reward then
		if self.mopup then
			self.btn_start.btn_image:loadTexture("tomb_text2.png", ccui.TextureResType.plistType)
			-- self.btn_start:setVisible(true)
		else
			-- self.btn_start:setVisible(false)
			self.btn_start.btn_image:loadTexture("tomb_text1.png", ccui.TextureResType.plistType)
		end
	else
		self.btn_start.btn_image:loadTexture("tomb_text1.png", ccui.TextureResType.plistType)
		self.mopup = nil
		-- self.btn_start:setVisible(true)
	end

	self.bg.tile:loadTexture("tomb_title" .. TombData.getTombId(self.area) .. ".png", ccui.TextureResType.plistType)
end

function TombMainUI:initNext()
	if 1 == self.nextFlag or self.area + 1 >= 5 then
		if self.nextList then
			for __, card in pairs(self.nextList) do
				card:setDate(self.area + 1, self.win, self.reward)
			end
		end

		return
	end

	self.nextFlag = 1
	self.nextList = self.nextList or {}

	for i = 1, 5, 1 do
		local card = TombMainCard.new(i)
		table.insert(self.nextList, card)

		self.ScrollView.panel:addChild(card)
		card:setPosition((i - 1) * 215, -344)
		card:setDate(self.area + 1, self.win, self.reward)
	end
end
