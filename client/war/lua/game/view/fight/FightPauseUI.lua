--暂停主界面
FightPauseUI = createUILayout("FightPauseUI", FightFileMgr.prePath .. "Fight_Pause/Fight_Pause/Fight_Pause.ExportJson", "FightDataMgr")
function FightPauseUI:ctor()
	self:retain()
	self.flag = false

	local function btn_event()
		ActionMgr.save('fight', 'FightPauseUI image btn_event')
		self:updateBtn(not self.flag)
	end
	createScaleButton(self.image)
	self.image:addTouchEnded(btn_event)

	local function play_event()
		ActionMgr.save('fight', 'FightPauseUI play play_event')
		self:updateBtn(false)
	end
	createScaleButton(self.play)
	self.play:addTouchEnded(play_event)

	local function quit_event()
		if 
			const.kFightTypeSingleArenaPlayer == FightDataMgr.fight_type
			or const.kFightTypeSingleArenaMonster == FightDataMgr.fight_type
		then
			ActionMgr.save('fight', 'FightPauseUI kFightTypeSingleArenaPlayer fight_id:' .. FightDataMgr.fight_id)
			FightDataMgr.autoFightFlag = true
			self:updateBtn(false)
			return
		elseif 
			not FightDataMgr.collaborationist 
			and const.kFightTypeCopy ~= FightDataMgr.fight_type
		then
			ActionMgr.save('fight', 'FightPauseUI quit quit_event quit fight_id:' .. FightDataMgr.fight_id)
			Command.run("fight quit", FightDataMgr.fight_id)
		else
			ActionMgr.save('fight', 'FightPauseUI quit quit_event')
		end
		
		CopyData.fightData = nil
		CopyData.getBossReward = nil
		FightDataMgr:releaseAll()
	end
	createScaleButton(self.quit)
	self.quit:addTouchEnded(quit_event)

	local size = self.play:getContentSize()
	self.quit:setPosition((visibleSize.width - (size.width * 2 + 22)) / 2 - self:getPositionX(), -1 * (visibleSize.height - size.height) / 2 - self:getPositionY())
	self.play:setPosition(self.quit:getPositionX() + 219, self.quit:getPositionY())

	self:updateBtn(false)
end
function FightPauseUI:releaseAll()
	self:removeFromParent()
	self:release()
end

function FightPauseUI:updateBtn(v)
	self.flag = v
	self.quit:setVisible(v)
	self.play:setVisible(v)

	if v then
		FightDataMgr:fightPause()
	else
		FightDataMgr:fightContinue()
	end
end


--宝箱界面
FightPauseBox = createUILayout("FightPauseBox", FightFileMgr.prePath .. "Fight_Pause/Fight_Pause_Box/Fight_Pause_Box.ExportJson", "FightDataMgr")
function FightPauseBox:ctor()
	self:retain()
end
function FightPauseBox:releaseAll()
	self:removeFromParent()
	self:release()
end


--变速器
FightSpeed = createUILayout("FightSpeed", FightFileMgr.prePath .. "Fight_Pause/Fight_Speed/Fight_Speed.ExportJson", "FightDataMgr")
function FightSpeed:ctor()
	self:retain()

	local function event()
		self.val = self.val + 1
		if self.val > 3 then
			self.val = 1
		end

		for i = 1, 3 do
			self.image["img" .. i]:setVisible(i == self.val)
		end

		if 1 == self.val then
			FightDataMgr.speed = 1
		elseif 2 == self.val then
			FightDataMgr.speed = FightDataMgr.speed_2 or 2
		else
			FightDataMgr.speed = FightDataMgr.speed_3 or 3
		end
	end
	createScaleButton(self.image)
	self.image:addTouchEnded(event)
	self.val = 1
end
function FightSpeed:releaseAll()
	self:removeFromParent()
	self:release()
end