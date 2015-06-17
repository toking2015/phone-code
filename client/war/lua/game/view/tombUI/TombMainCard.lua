require "lua/game/model/TombData.lua"

TombMainCard = createUILayout("TombMainCard", "image/ui/TombUI/TombCard.ExportJson")
function TombMainCard:ctor(index)
	self.index = index
	self.box_close:setPosition(100, 210)
	self.box_open:setPosition(100, 210)

	local global = findGlobal("tomb_player_reset_cost")
	if global then
		self.change.text:setString(global.data)
	end

	local color = nil
	if 5 == index then
		color = cc.c3b(0xff, 0xef, 0x31)
	else
		color = cc.c3b(0xff, 0xff, 0xff)
	end
	self.text = UIFactory.getLabel("第" .. index .. "关", self, 124, 320, 18, color)

	local function change()
		local ii = self.tomb_index - 1
		Command.run("tomb player_reset", ii)
	end
	createScaleButton(self.change)
	self.change:addTouchEnded(change)

	local function box()
		if not self.tombTarget or 0 ~= self.tombTarget.reward then
			return
		end

		local ii = self.tomb_index - 1
		Command.run("tomb reward", ii)
	end
	createScaleButton(self.box_close)
	self.box_close:addTouchEnded(box)

	-- self.btn = Sprite:createWithSpriteFrameName("btn_orange_new.png")
	self.btn = ccui.ImageView:create("btn_orange_new.png", ccui.TextureResType.plistType)
	self.btnText = ccui.ImageView:create("tomb_btn2_text1.png", ccui.TextureResType.plistType)
	self.btnText:setPosition(79, 23)
	self.btnText:setTouchEnabled(false)
	self.btn:addChild(self.btnText)

	self.btn:setPosition(106, 32)
	self:addChild(self.btn, 101)
	local function enter()
		if not self.tombTarget then
			return
		end

		local tombTarget = self.tombTarget
		local tomb_index = self.tomb_index
		TombData.loadFightModelAsync(tombTarget, 1,
			function ( ... )
				local ii = tomb_index - 1
				Command.run(
					"formation show tomb",
					tombTarget.target_id,
					function ( ... )
						Command.run(
							"tomb fight", 
							ii, 
							tombTarget.target_id, 
							FormationData.getTypeData(const.kFormationTypeTomb)
						)
						EventMgr.addListener(EventType.FightEnd, TombData.listener)
						Command.run("ui hide", "TombMainUI")
    					Command.run("loading wait show", "tomb")
					end,
					function ( ... )
						Command.run("ui show", "TombMainUI", PopUpType.SPECIAL)
					end,
					tombTarget
				)
			end)
	end
	createScaleButton(self.btn)
	self.btn:addTouchEnded(enter)
end

function TombMainCard:setDate(area, win, reward)
	self.area = area
	self.win = win
	self.reward = reward

	self.tomb_index = self.area * 5 + self.index
	self.tombTarget = GameData.user.tomb_target_list[self.tomb_index]
	if not self.tombTarget then
		return
	end

	if 4 == self.area and 5 == self.index then
		self.Panel_12:setVisible(false)
		self.tile_flag:setVisible(true)
	else
		self.Panel_12:setVisible(true)
		self.tile_flag:setVisible(false)
	end

	local state = 0
	--当前关
	if self.tomb_index == self.win and self.win == self.reward + 1 then
		self.btn_flag:setVisible(false)
		ProgramMgr.setNormal(self.btnText)
		ProgramMgr.setNormal(self.btn)
		self.btn:setVisible(true)
		self.btn:setTouchEnabled(true)

		if const.kAttrMonster == self.tombTarget.attr then
			self.change:setVisible(false)
		else
			self.change:setVisible(true)
		end

		self.box_close:setVisible(false)
		self.box_open:setVisible(false)
		self.box_small:setVisible(true)

	--已通关
	elseif 
		(self.tomb_index < self.win and self.win > self.reward + 1) 
		or 0 ~= self.tombTarget.reward
	then
		self.btn:setVisible(false)
		self.btn_flag:setVisible(true)
		self.change:setVisible(false)
		state = 1

		self.box_small:setVisible(false)
		if 0 == self.tombTarget.reward then
			self.box_close:setVisible(true)
			self.box_open:setVisible(false)

			if not self.finger then
				local name = 'xsz-tx-01'
				local path = 'image/armature/ui/InductUI/'..name..'/'..name..'.ExportJson'
				LoadMgr.loadArmatureFileInfo(path, LoadMgr.WINDOW, name)
				self.finger = ArmatureSprite:addArmatureTo(self, path, name, 90, 240, nil, 100)
			end

			if not self.action then
				local moveUp = cc.MoveBy:create(1, cc.p(0, 20))
				local moveDown = cc.MoveBy:create(1, cc.p(0, -20))
				self.action = self.box_close:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
			end
		else
			self.box_close:setVisible(false)
			self.box_open:setVisible(true)

			if self.finger then
				self.finger:removeFromParent()
				self.finger = nil
			end

			if self.action then
				self.box_close:stopAllActions()
				self.action = nil
			end
		end

	--未通关
	else
		self.btn_flag:setVisible(false)
		ProgramMgr.setGray(self.btn)
		ProgramMgr.setGray(self.btnText)
		self.btn:setTouchEnabled(false)
		self.btn:setVisible(true)
		self.change:setVisible(false)
		state = 2

		self.box_close:setVisible(false)
		self.box_open:setVisible(false)
		self.box_small:setVisible(true)
	end

	if 5 == self.index then
		if 4 == self.area then
			self.bg:loadTexture("image/ui/TombUI/tomb_card3.png", ccui.TextureResType.localType)
			self.box_small:loadTexture("tomb_close_box3.png", ccui.TextureResType.plistType)
			self.box_open:loadTexture("tomb_open_box3.png", ccui.TextureResType.plistType)
			self.box_close:loadTexture("tomb_close_box3.png", ccui.TextureResType.plistType)
		else
			self.bg:loadTexture("image/ui/TombUI/tomb_card2.png", ccui.TextureResType.localType)
			self.box_small:loadTexture("tomb_close_box2.png", ccui.TextureResType.plistType)
			self.box_open:loadTexture("tomb_open_box2.png", ccui.TextureResType.plistType)
			self.box_close:loadTexture("tomb_close_box2.png", ccui.TextureResType.plistType)
		end

		local json = findTomb(TombData.getTombId(self.area))
		if json then
			self.text:setString(json.name .. "守卫")
		end
	else
		self.text:setString("第" .. self.tomb_index .. "关")
		self.bg:loadTexture("image/ui/TombUI/tomb_card1.png", ccui.TextureResType.localType)
		-- self.box_close:loadTexture("tomb_close_box1.png", ccui.TextureResType.plistType)
	end


	self:setPanel(state)
end

function TombMainCard:setPanel(state)
	self:clear()
	self.Panel_12.guild:setString("")

	if not self.tombTarget then
		return
	end

	if const.kAttrMonster == self.tombTarget.attr then
		self:setMonster(state)
	else
		self:setPlayer(state)
	end
end

function TombMainCard:setMonster(state)
	local monster = findMonster(self.tombTarget.target_id)
	if not monster then
		return
	end
	self.Panel_12.number:setString(monster.level)
	self.Panel_12.attack:setString("?????")
	self.Panel_12.guild:setString("?????")

	if 1 ~= state then
		self.view = ModelMgr:useModel(monster.animation_name)
		if self.view then
			self.view:setScale(0.70)
			self.view:setPosition(104, 150)
			self.Panel_10:addChild(self.view)
		end
	end

	if 2 ~= state then
		if self.view then
			self.view:playOne(false, "stand")
		end
	else
		self.Panel_12.name:setString("?????")
		self.Panel_12.guild:setString("?????")
		self.Panel_12.number:setString("")

		if self.view then
			self.view:setGLProgramStateChildren("black")
		end
		return	
	end

	self.Panel_12.name:setString(monster.name)
end

function TombMainCard:setPlayer(state)
	local target = TombData:getPanel(self.tombTarget.target_id)
	if not target then
		Command.run("tomb panel", self.tombTarget.target_id)
		return
	end
	self.Panel_12.number:setString(target.simple.team_level)

	local value = 0
	for __, formation in pairs(target.formation_map) do
		if const.kAttrTotem ~= formation.attr then
			--形象
			if 1 ~= state and not self.view then
				for __, soldier in pairs(target.soldier_map) do
					if formation.guid == soldier.guid then
						local s = findSoldier(soldier.soldier_id)
						if s then
							self.view = ModelMgr:useModel(s.animation_name)
							if self.view then
								self.view:setScale(0.70)
								self.view:setPosition(104, 150)
								self.Panel_10:addChild(self.view)
								flag = true
								break
							end
						end
					end
				end
			end

			for __, ext in pairs(target.fightextable_map) do
				if formation.attr ~= const.kAttrTotem and formation.guid == ext.guid then
					value = value + SoldierData.getAbleFightValue(ext.able)
				end
			end
		end
	end

	if 2 ~= state then
		if self.view then
			self.view:playOne(false, "stand")
		end

		self.Panel_12.guild:setString("无公会")
	else
		self.Panel_12.name:setString("?????")
		self.Panel_12.attack:setString("?????")
		self.Panel_12.guild:setString("?????")
		self.Panel_12.number:setString("")

		if self.view then
			self.view:setGLProgramStateChildren("black")
		end
		return
	end

	self.Panel_12.name:setString(target.simple.name)
	self.Panel_12.attack:setString(value)
end

function TombMainCard:clear()
	if self.view then
		ModelMgr:recoverModel(self.view)
		self.view = nil
	end
end