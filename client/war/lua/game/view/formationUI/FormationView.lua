-- 布阵展示
FormationView = createLayoutClass("FormationView", cc.Layer)

function FormationView:ctor(roleCon)
    self.pool = Pool.new()
    self.roles = {}
    self.canUps = {}

	self.conBg = cc.Node:create()
	self.conBg:setPosition(0, 0)
	
	local nextOpen = FormationData.getNextOpenIndex()

	for i = 0, const.kFormationPosMax - 1 do
		local isOpen = FormationData.isIndexOpen(i)
		local circleUrl = nil
		if isOpen then
			circleUrl = FormationData.isTotemPos(i) and "formation_circle_totem.png" or "formation_circle_soldier.png"
		else
			if nextOpen and nextOpen.index == i then
				circleUrl = "formation_circle_none.png"
			end
		end
		if circleUrl then
			local roleCircle = UIFactory.getSpriteFrame(circleUrl, self.conBg, nil, nil, i)
			self:setRolePosition(roleCircle, i)
			if nextOpen and nextOpen.index == i then
				local text = string.format("%s级开启", nextOpen.level)
				local x, y = roleCircle:getPosition()
				local levelUp = UIFactory.getText(text, self.conBg, x, y - 25, 16, cc.c3b(0xff, 0xff, 0xff), nil, nil, const.kFormationPosMax)
				addOutline(levelUp, cc.c4b(0x00, 0x00, 0x00, 0xff), 2)
			end
		end
	end
	self:addChild(self.conBg, 2)
	
	self.canFormation = FormationData.getCanFormation(FormationData.type) --能否布阵	
	if self.canFormation then
		local lbl = cc.Sprite:createWithSpriteFrameName("formation_lbl.png")
		lbl:setPosition(260, 560)
		self:addChild(lbl, 3)
	end

	if not roleCon then
		--此图层与战斗系统的【角色图层为同一引用】
		self.con = FightDataMgr:getLayerRole()
	    self.con:setPosition(0, 0)
	else
		self.con = roleCon
	end
	
    self:setTouchEnabled(true)
    local function touchBeginHandler(touch, eventType)
    	ActionMgr.save( 'UI', '[FormationView] down [self]' )
    	self:startDrag(touch)
    end
    local function touchMoveHandler(touch, eventType)
    	self:drag(touch)
    end
    local function touchEndedHandler(touch, eventType)
    	ActionMgr.save( 'UI', '[FormationView] up [self]' )
    	self:stopDrag(touch)
    end
    UIMgr.addTouchBegin(self, touchBeginHandler)
    UIMgr.addTouchMoved(self, touchMoveHandler)
    UIMgr.addTouchEnded(self, touchEndedHandler)
    UIMgr.addTouchCancel(self, touchEndedHandler)

    self.delayMap = {}
    function self.delayUpdateRight()
    	for i,v in pairs(self.delayMap) do
    		self:addOneRole(unpack(v))
    		self.delayMap[i] = nil
    		break
    	end
    	if table.empty(self.delayMap) then
    		self:stopAction(self.delayAction)
    		self.delayAction = nil
    	end
    end

	function self.showTipsHandler()
		local role = self.dragRole
		if not role or not role.formation then
			return
		end
		local v = role.formation
		if v.attr == const.kAttrTotem then
			local glyphList = FormationData.getGlyphList(v.formation_type, v.attr, role.isMirror, role.exData, v.isFake)
			local sData = FormationData.getSData(v.formation_type, v.guid, v.attr, role.isMirror, role.exData, v.isFake)
			self:stopDrag()
			self._hasShowTips = true
			TipsMgr.showTips(self.startPos, TipsMgr.TYPE_TOTEM, sData, glyphList)
		end
	end
end

function FormationView:stopDrag(touch)
	if self._hasShowTips then
		self._hasShowTips = nil
		return
	end
	if self._touch_action then
		self:stopAction(self._touch_action)
		self._touch_action = nil
	end
	local win = PopMgr.getWindow("FormationWin")
	if not win then
		return
	end
	if self.dragRole == nil then
		if not win.isUIShow and self.startIndex and self.startIndex < const.kFormationPosMax and FormationData.isIndexOpen(self.startIndex) then
			FormationData.attr = FormationData.isTotemPos(self.startIndex) and const.kAttrTotem or const.kAttrSoldier
			Command.run("formation show ui")
		end
	else
		self.dragRole:setLocalZOrder(self.dragIndex)
		if self.canFormation and self.dragIndex < const.kFormationPosMax then
			local formation = self.dragRole.formation
			local location = touch and touch:getLocation() or cc.p(0, 0)
			local deltaX = location.x - self.startPos.x
			local deltaY = location.y - self.startPos.y
			if math.abs(deltaX) < Config.FUZZY_VAR and math.abs(deltaY) < Config.FUZZY_VAR then
				--点击处理
				if win.isUIShow then
					-- 下阵
					local result = FormationData.downByGuid(self.type, formation.guid, formation.attr)
					if result then
						EventMgr.dispatch(EventType.UserFormationUpdate)
					end
				else
					--同时打开UI
					if self.startIndex then
						FormationData.attr = FormationData.isTotemPos(self.startIndex) and const.kAttrTotem or const.kAttrSoldier
						Command.run("formation show ui")
					end
				end
			else
				local nowPos = cc.p(self.startX + deltaX, self.startY + deltaY)
				local index = self:hitTest(nowPos)
				if index and FormationData.switchIndex(self.type, self.dragRole.index, index) then
					SoundMgr.playEffect("sound/ui/sfx_moverole.mp3")
					EventMgr.dispatch(EventType.UserFormationUpdate)
				else
					self:updateData()
				end
			end
		end
	end
	self.startPos = nil
    self.startX = nil
    self.startY = nil
	self.startIndex = nil
	self.dragRole = nil
	self.dragIndex = nil
	self.targetRole = nil
end

function FormationView:startDrag(touch)
	local location = touch:getLocation()
	local index = self:hitTest(location, true, true)
	self.startPos = location
	self.startX, self.startY = self:getRolePosition(index)
	self.startIndex = index
	local role = self.roles[index]
	if role and role:getParent() then
		role:setLocalZOrder(const.kFormationPosMax * 2)
		self.dragRole = role
		self.dragIndex = index
		if self._touch_action then
			self:stopAction(self._touch_action)
		end
		self._touch_action = performWithDelay(self, self.showTipsHandler, Config.TIPS_DELAY_TIME)
	end
end

function FormationView:drag(touch)
	if self._hasShowTips then
		return
	end
	if self.dragRole == nil or self.dragIndex >= const.kFormationPosMax then
		return
	end
	if self.dragRole.formation and self.dragRole.formation.isFake then
		return
	end
	if not self.canFormation then
		return
	end
	if self.targetRole then
		-- self:setRolePosition(self.targetRole, self.targetRole.index)
		self.targetRole = nil
	end
	local location = touch:getLocation()
	local deltaX = location.x - self.startPos.x
	local deltaY = location.y - self.startPos.y
	local nowPos = cc.p(self.startX + deltaX, self.startY + deltaY)
	self.dragRole:setPosition(nowPos)
	local index = self:hitTest(nowPos)
	if index == nil then
	   return
	end
	local formation = self.dragRole.formation
	if (not FormationData.checkCanMove(self.type, formation.guid, formation.attr, index)) then
		return
	end
	local role = self.roles[index]
	if role then
		self.targetRole = role
		-- self:setRolePosition(role, formation.formation_index)
	end
end

function FormationView:hitTest(location, hasRole, hasRight) --@return 
	return FormationData:hitTest(location, hasRole, hasRight, self.roles)
end

function FormationView:getRolePosition(index)
    if (index == nil) then
        return 0, 0
    end
	local station = FightData.stationList:get(index)
	return station.vX, station.vY
end

function FormationView:setRolePosition(role, index)
    if (index == nil) then
        return
    end
	role:setPosition(cc.p(self:getRolePosition(index)))
    role:setLocalZOrder(index)
end

function FormationView:recoverModel()
	for i,v in pairs(self.roles) do
		ModelMgr:formationRecoverModel(v)
		self.roles[i] = nil
	end
end

function FormationView:dispose()
	for i,v in pairs(self.roles) do
		if not v.formationRecover then
			ModelMgr:recoverModel(v, i >= const.kFormationPosMax)
		end
		self.roles[i] = nil
	end
	self.con = nil
	self.pool:clear()
end

function FormationView:setType(type)
	self.type = type
end

function FormationView:setOppFormation(oppFormation)
	self.oppFormation = oppFormation
end

function FormationView:getRoleView(body, isMirror, force, attr, json, level)
	local role = self.pool:getObject(body)
	if role == nil then
		if isMirror and not force then
			return nil
		end
        role = ModelMgr:useModel(body.style, attr, json.animation_name, level)
		role:nameSwap(true)
		
		role:setMirror(isMirror)
		role:playOnce("stand")
	end
	return role
end

function FormationView:disposeRoleView(role)
    self.pool:disposeObject(role.bodyData, role)
end

function FormationView:getBody(json, sData, attr, level)
	if not json or json.animation_name == "" then
		return nil
	end

	if const.kAttrTotem == attr then
		return FightFileMgr:getBody(json.animation_name .. level)
	end

	return FightFileMgr:getBody(json.animation_name)
end

function FormationView:addOneRole(v, isMirror, toRelease, force)
	if v and v.guid ~= 0 then
		local i = v.formation_index
		local exData = isMirror and FormationData.oppExData or nil
		local json, sData = FormationData.getJsonByGuid(self.type, v.guid, v.attr, isMirror, exData, v.isFake)
		
        --BOSS战的图腾等级需要显示为5级, 不确认这里强赋值 level = 5 到底会不会影响其它布阵
        --sData.level = 5
		if not sData or not json then
			return
		end
		local level = sData.level
		if isMirror and v.isFake then
			level = 5
		end
		local body = self:getBody(json, sData, v.attr, level)
		if (body ~= nil) then
			if (isMirror) then
				i = i + const.kFormationPosMax
			end
			
			local role = self:getRoleView(body, isMirror, force, v.attr, json, level)
			if role ~= nil then
				role.index = i
				self.roles[i] = role
				role.formation = v
				role.isMirror = isMirror
				role.exData = exData
				local color, num = FormationData.getNameColorAndNum(v, isMirror, exData, v.isFake)
				role:setRoleName(json.name..num, color)
				self:setRolePosition(role, i)
				self.con:addChild(role, i, i)
				if v.attr == const.kAttrMonster then
					role:setTalk(MonsterData.getTalk(v.guid))
				end
				if toRelease then toRelease[role] = nil end
				if self.type == const.kFormationTypeTomb and const.kAttrTotem ~= v.attr then
					if isMirror then
						local tombTarget = TombData.getCurrentTomb()
						if tombTarget then
							if const.kAttrMonster ~= tombTarget.attr then
								local panel = TombData:getPanel(tombTarget.target_id)
								if panel then
									local able, quality = TombData.getPanelFightSoldier(panel, v.guid)
									role:initHp(quality)
									role.hpView.maxHp = able.hp
									role.hpView.hp = able.hp
									role.hpView.lastHp = able.hp
									role.hpView.maxRage = 100
									role.hpView.rage = 0
									role.hpView.lastRage = 0
									role.hpView:hp_update()

									local extAble = TombData.getTargetFightSoldier(const.kSoldierTypeTombTarget, v.guid)
									if extAble then
										role.hpView.hp = extAble.hp
										role.hpView.lastHp = extAble.hp
										role.hpView.rage = extAble.mp
										role.hpView.lastRage = extAble.mp
									else
										local _soldier = findSoldierBase(json.id)
										if _soldier then
											role.hpView.rage = _soldier.initial_rage
											role.hpView.lastRage = _soldier.initial_rage
										end
									end
									
									role.hpView:hp_update()
								end

							else
								local monster = findMonster(v.guid)
								if monster then
									role:initHp(2)
									role.hpView.maxHp = monster.hp
									role.hpView.hp = monster.hp
									role.hpView.lastHp = monster.hp
									role.hpView.maxRage = 100
									role.hpView.rage = 0
									role.hpView.lastRage = 0

									local extAble = TombData.getTargetFightSoldier(const.kSoldierTypeTombTarget, v.guid)
									if extAble then
										role.hpView.hp = extAble.hp
										role.hpView.lastHp = extAble.hp
										role.hpView.rage = extAble.mp
										role.hpView.lastRage = extAble.mp
										role.hpView:hp_update()
									else
										role.hpView.rage = monster.initial_rage
										role.hpView.lastRage = monster.initial_rage
									end

									role.hpView:hp_update()
								end
							end
						end

					--我方阵营
					else
						local ss = SoldierData.getSoldier(v.guid)
						if ss then
							role:initHp(ss.quality)
							local extAble = SoldierData.getFightextAble(v.guid, v.attr)
							if extAble then
								role.hpView.maxHp = extAble.able.hp
								role.hpView.hp = extAble.able.hp
								role.hpView.lastHp = extAble.able.hp
								role.lastHp = extAble.able.hp
								role.hpView.maxRage = 100
								role.hpView.rage = extAble.able.rage
								role.hpView.lastRage = extAble.able.rage

								extAble = TombData.getTargetFightSoldier(const.kSoldierTypeTombSelf, v.guid)
								if extAble then
									role.hpView.hp = extAble.hp
									role.hpView.lastHp = extAble.hp
									role.hpView.rage = extAble.mp
									role.hpView.lastRage = extAble.mp

									if 0 == extAble.hp then
										role:playOnce("dead", true)
									end

								else
									local _soldier = findSoldierBase(json.id)
									if _soldier then
										role.hpView.rage = _soldier.initial_rage
										role.hpView.lastRage = _soldier.initial_rage
									end
								end
									
								role.hpView:hp_update()
							end
						end
					end
				end
			else
				self.delayMap[i] = {v, isMirror, nil, true, v.isFake}
				if not self.delayAction then
					self.delayAction = schedule(self, self.delayUpdateRight, 0)
				end
			end
		end
	end
end

--更新显示
--delay 延迟更新右边的时间
function FormationView:updateData(first)
	self:doUpdateData(true, first)
end

function FormationView:addCanUpView(index)
	local sp = self.pool:getObject("formation_can_up.png")
	if not sp then
		sp = UIFactory.getSpriteFrame("formation_can_up.png")
	end
	local x, y = self:getRolePosition(index)
	sp:setPosition(x, y - 25)
	self.conBg:addChild(sp, const.kFormationPosMax)

	if not self.new_open then
		if FormationData.getIndexOpenLevel(index) == gameData.getSimpleDataByKey("team_level") then
			local url = "image/ui/FormationUI/new_open.png"
			self.new_open = UIFactory.getSprite(url, self.con, x - 15, y + 73, const.kFormationPosMax + 1)
		end
	end

	return sp
end

--更新显示
--isLeft 更新左边
--isRight 更新右边
function FormationView:doUpdateData(isLeft, isRight)
    local toRelease = {}
    local toUpRelease = {}
    for key,value in pairs(self.roles) do
    	if (isLeft and  key < const.kFormationPosMax) or
    		(isRight and key >= const.kFormationPosMax) then
	    	self:disposeRoleView(value)
	    	toRelease[value] = true
	    	self.con:removeChild(value)
	    	self.roles[key] = nil
    	end
    end
	local isMirror = false
	if isLeft then
		local canUpSoldier = FormationData.checkCanUpSoldier(self.type)
		local canUpTotem = FormationData.checkCanUpTotem(self.type)
		--移除可上阵
		if self.new_open then
			self.new_open:removeFromParent()
			self.new_open = nil
		end
		for k,v in pairs(self.canUps) do
			self.pool:disposeObject("formation_can_up.png", v)
			v:retain()
			v:removeFromParent()
			toUpRelease[v] = true
			self.canUps[k] = nil
		end
	    local list = FormationData.getTypeData(self.type)
		for _,v in pairs(list) do
			self:addOneRole(v, isMirror, toRelease, true)
		end
		list = FormationData.helpFormation
		if list then
			for _,v in pairs(list) do
				self:addOneRole(v, isMirror, toRelease, true)
			end
		end
		for i = 0, const.kFormationPosMax - 1 do --显示可上阵的
			if not self.roles[i] and FormationData.isIndexOpen(i) then
				if FormationData.isTotemPos(i) then
					if canUpTotem then
						self.canUps[i] = self:addCanUpView(i)
					end
				else
					if canUpSoldier then
						self.canUps[i] = self:addCanUpView(i)
					end
				end
			end
		end
	end
	if isRight and self.oppFormation then
		isMirror = true
		for _,v in pairs(self.oppFormation) do
			self:addOneRole(v, isMirror, toRelease, true)
		end
	end
	self.pool:clear()
	for k,_ in pairs(toRelease) do
		ModelMgr:recoverModel(k)
	end
	for k,_ in pairs(toUpRelease) do
		k:release()
	end
end

function FormationView:updateArena()
	self:doUpdateData(false, true)
end

local soldierActs = {"physical1", "physical2", "physical3"}

--播放特殊动作
function FormationView:playSpecialAction(data)
	local index = FormationData.getIndexByGuid(data.type, data.sData.guid, data.attr)
	if const.kFormationPosMax ~= index then
		local role = self.roles[index]
		if role then
			local act = "sf"
			if data.attr == const.kAttrSoldier then
				act = soldierActs[MathUtil.random(1, #soldierActs)]
			end

			local change = nil
			if self.type == const.kFormationTypeTomb and const.kAttrTotem ~= data.attr then
				local extAble = TombData.getTargetFightSoldier(const.kSoldierTypeTombSelf, data.sData.guid)
                if extAble and 0 == extAble.hp then
                	change = true
                	act = "dead"
                end
			end

			role:playOnce(act, change)
			if data.attr == const.kAttrSoldier then
				SoundMgr.playSoldierTalk(data.sData.soldier_id)
			elseif data.attr == const.kAttrTotem then
				SoundMgr.playUI("totem_updown")
			end
		end
	end
end
