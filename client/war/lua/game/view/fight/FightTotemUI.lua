

local function getUrl(style, name, type)
	FightEffectMgr:loadResouce(style)
    return 'image/armature/fight/effect/' .. style .. '/' .. name .. '.' .. type
end

local function getArmatureEffect(url, name, action, startDuration, startLoop)
    demo = ArmatureSprite:create(name, action, startDuration, startLoop)
    demo:setAnchorPoint(0, 0)
    demo.url = url
    return demo
end

--自动战斗提示
FightTotemAuto = createUILayout("FightTotemAuto", FightFileMgr.prePath .. "FightTotem/totem_auto.json", "FightDataMgr")
function FightTotemAuto:idle(time)
	self.startTime = self.startTime or time
	local frame = math.floor((time - self.startTime) / 800) % 4
	-- self.startTime = time
	for i = 1, 3 do
		self["image" .. i]:setVisible(false)
	end
	for i = 1, 3 do
		self["image" .. i]:setVisible(frame >= i)
	end
end

--技能按钮
FightTotemSkill = createUILayout("FightTotemSkill", FightFileMgr.prePath .. "FightTotem/totem_btn.json", "FightDataMgr")
function FightTotemSkill:ctor(role)
	self:retain()
	self.role = role
	self.size = self:getSize()
	self.flag = false

	local image = UIFactory.getSprite(TotemData.getAvatarUrl(role.totem))
	image:retain()
	self.image = image
    self:addChild(image)
    image:setPosition(self.size.width / 2, self.size.height / 2 + 4)

    local ctSprite = UIFactory.getSprite(FightFileMgr.prePath .. "FightTotem/fight_totem_skill_mask.png")
    local ct = cc.ProgressTimer:create(ctSprite)
    ct:retain()
    self.ct = ct
    self:addChild(ct)
    ct:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    ct:setScaleX(-1)
    ct:setOpacity(180)
    ct:setPosition(self.size.width / 2, self.size.height / 2 + 4)
    ct:setPercentage(100)
    ct.val = 100

    local numberWhite = FightNumberMgr:createTotemNumber("white")
    self.numberWhite = numberWhite
    self:addChild(numberWhite)
    self.numberWhite:idle(self.size)

    --红色
    local numberRed = FightNumberMgr:createTotemNumber("red")
    self.numberRed = numberRed
    self:addChild(numberRed)
    numberRed:setPosition(43, 16)

    --蓝色
    local numberBlue = FightNumberMgr:createTotemNumber("blue")
    self.numberBlue = numberBlue
    self:addChild(numberBlue)
    self.numberBlue:setVisible(false)
    numberBlue:setPosition(43, 16)

    local function skillFire(btn, event)
		--使用技能时特效
		btn.time = btn.time or 0
		if FightDataMgr.totemTime - btn.time < 3 or not btn.role.playerView then
			return
		end

		btn.time = FightDataMgr.totemTime
		local play = btn.role.playerView
		local parent = self:getParent()
		local pt = cc.p(play:getPositionX(), play:getPositionY() + (btn.role.body.footY - btn.role.body.bodyY))
        local flyEffect = SkillFlyEffect:create(FightDataMgr.theFightUI.totemUI:getPositionX() + btn:getPositionX() + 45, FightDataMgr.theFightUI.totemUI:getPositionY() + btn:getPositionY() + 45, pt.x, pt.y, 0.4)
        FightDataMgr.theScene:addChild(flyEffect)

        local skillFire = self:getSkillFire()
		skillFire:setPosition(-514, -437)
		skillFire:setLocalZOrder(50)
    	skillFire:setVisible(true)
		skillFire:gotoAndPlay(1)
        FightDataMgr:touchTotem(btn.role)

        SoundMgr.playEffect("sound/totem_click.mp3", false)
        EventMgr.dispatch( EventType.FightToTemClick, btn )
    end
    UIMgr.addTouchEnded(self, skillFire)
	self:setTouchEnabled(false)
    self.numberBlue.image:setString(math.ceil(self.role.skill.self_costtotem / 10))
    self.numberRed.image:setString(math.ceil(self.role.skill.self_costtotem / 10))
end
function FightTotemSkill:releaseAll()
	self.role = nil

	self.image:removeFromParent()
	self.image:release()
	self.image = nil

	self.ct:removeFromParent()
	self.ct:release()
	self.ct = nil

	FightNumberMgr:unTotemNumber(self.numberBlue)
	self.numberBlue = nil
	FightNumberMgr:unTotemNumber(self.numberRed)
	self.numberRed = nil
	FightNumberMgr:unTotemNumber(self.numberWhite)
	self.numberWhite = nil

	if self.skillFire then
		self.skillFire:removeFromParent()
		self.skillFire:release()
		self.skillFire = nil
	end
	if self.skillActive then
		self.skillActive:removeFromParent()
		self.skillActive:release()
		self.skillActive = nil
	end
	if self.effectPower then
		self.effectPower:removeFromParent()
		self.effectPower:release()
		self.effectPower = nil
	end
	if self.text then
		self.text:removeFromParent()
		self.text:release()
		self.text = nil
	end
	if self.auto then
		self.auto:removeFromParent()
		self.auto:release()
		self.auto = nil
	end

	self:removeFromParent()
	self:release()
end
function FightTotemSkill:getText()
	if not self.text then
	    self.text = UIFactory.getText("没有目标", nil, 50, 120, 22, cc.c3b(0xff, 0xff, 0x02))
	    self.text:retain()
	    self:addChild(text)
	end

	return self.text
end
function FightTotemSkill:getSkillFire()
	if not self.skillFire then
		local effect = FightFileMgr:getEffect(FightAnimationMgr.const.TOTEM_FIRE)
    	local effectItem = effect:getEffectNormal()
		self.skillFire = getArmatureEffect(getUrl(FightAnimationMgr.const.TOTEM_FIRE, FightAnimationMgr.const.TOTEM_FIRE, "ExportJson"), FightAnimationMgr.const.TOTEM_FIRE, effectItem.flag, 2, 0)
	    self:addChild(self.skillFire)

	    self.skillFire:retain()
		self.skillFire:setScale(4)
		self.skillFire:setVisible(false)
		local completeHandler = function()
			self.skillFire:setVisible(false)
		end
		self.skillFire:onPlayComplete(completeHandler)
	end

	return self.skillFire
end
function FightTotemSkill:setValue(value)
	if value >= self.role.skill.self_costtotem then
        self.numberBlue:setVisible(true)
        self.numberRed:setVisible(false)
        self.flag = true
	else
        self.numberRed:setVisible(true)
        self.numberBlue:setVisible(false)
        self.flag = false
	end
end
function FightTotemSkill:setTextVisible(visible)
	self:getText():setVisible(visible or false)
end
function FightTotemSkill:setAuto(visible)
	-- body
	if not visible and not self.auto then
		return
	end

	if not self.auto then
		self.auto = UIFactory.getSprite(FightFileMgr.prePath .. "FightTotem/fight_totem_img1.png")
		self.auto:retain()
		self:addChild(self.auto)
		self.auto:setPosition(50, 90)
	end

	self.auto:setVisible(visible)
end

--图腾界面
FightTotemUI = createUILayout("FightTotemUI", FightFileMgr.prePath .. "FightTotem/totem_power.json", "FightDataMgr")
function FightTotemUI:ctor()
	self:retain()
	self.list = {}
	self.value = 0
	self.max = 100
	self.last = 0

	--创建cliper
	self.pClip=cc.ClippingNode:create()
	self.pClip:retain()
	self.pClip:setAnchorPoint(cc.p( 0, 0 ))
	self:addChild(self.pClip)
	self.pClip:setPosition(36, 16)

    --设置模板
	self.pStencil = cc.Sprite:create("image/ui/FightUI/FightTotem/fight_totem_pro.png")
	self.pStencil:setAnchorPoint( cc.p( 0, 0 ) )
	self.pStencil:setPosition(-386, 0)
	self.pClip:setStencil(self.pStencil)

	--进度条
	self.effect4 = getArmatureEffect(getUrl("ttjdt-tx-01", "ttjdt-tx-01", "ExportJson"), "ttjdt-tx-01", 0, 2)
	self.effect4:retain()
	self.pClip:addChild(self.effect4)
	self.effect4:setPosition(-2, -2)
 --   	local function actionCom( )
 --   	end
	-- self.newP = cc.p(0, 0)
	-- self.pStencil:stopAllActions()
	-- local moveto = cc.MoveTo:create(10, self.newP)
	-- local func = cc.CallFunc:create(actionCom)
	-- local seq = cc.Sequence:create(moveto, func)
	-- self.pStencil:runAction(seq)

	self.effect2 = getArmatureEffect(getUrl("ytoug-tx-02", "ytoug-tx-02", "ExportJson"), "ytoug-tx-02", 0, 2)
	self.effect2:retain()
	self:addChild(self.effect2)
	self.effect2:setPosition(10, 11)

	self.effect1 = getArmatureEffect(getUrl("ytoug-tx-01", "ytoug-tx-01", "ExportJson"), "ytoug-tx-01", 0, 2)
	self.effect1:retain()
	self:addChild(self.effect1)
	self.effect1:setPosition(-17, -18)

	self.effect3 = getArmatureEffect(getUrl("bubdt-tx-01", "bubdt-tx-01", "ExportJson"), "bubdt-tx-01", 0, 2)
	self.effect3:retain()
	self:addChild(self.effect3)
	self.effect3:setPosition(-10, 40)

	--进度条光标
	self.effect5 = getArmatureEffect(getUrl("ttjdt-tx-02", "ttjdt-tx-02", "ExportJson"), "ttjdt-tx-02", 0, 2)
	self.effect5:retain()
	self:addChild(self.effect5)
	self.effect5:setPosition(9, -3)
	--进度条火焰
	self.effect6 = getArmatureEffect(getUrl("ttjdt-tx-03", "ttjdt-tx-03", "ExportJson"), "ttjdt-tx-03", 0, 2)
	self.effect6:retain()
	self:addChild(self.effect6)
	self.effect6:setPosition(-6, -20)

	self.number = FightNumberMgr:createTotemNumber("val")
	self.number:setPosition(225, 17)
	self:addChild(self.number)
end
function FightTotemUI:releaseAll()
	for __, btn in pairs(self.list) do
		btn:releaseAll()
	end
	self.list = nil

	self.effect1:removeFromParent()
	self.effect1:release()
	self.effect2:removeFromParent()
	self.effect2:release()
	self.effect3:removeFromParent()
	self.effect3:release()
	self.effect4:removeFromParent()
	self.effect4:release()
	self.effect5:removeFromParent()
	self.effect5:release()
	self.effect6:removeFromParent()
	self.effect6:release()
	self.pClip:removeFromParent()
	self.pClip:release()

	FightNumberMgr:unTotemNumber(self.number)
	self.number = nil

	self:removeFromParent()
	self:release()
end
function FightTotemUI:show()
	--加载图腾技能图标
    local list = FightRoleMgr:getSoldierList(FightAnimationMgr.camp, const.kAttrTotem)
    if 0 == #list then
    	return
    end

    local flag = false
    if 
        const.kFightTypeSingleArenaPlayer == FightDataMgr.fight_type
        or const.kFightTypeSingleArenaMonster == FightDataMgr.fight_type
    then
	    flag = true
	end

    self:setVisible(true)
    for i, role in pairs(list) do
        local skill = role.skill
        local btnSkill = FightTotemSkill.new(role)
        table.insert(self.list, btnSkill)
        self:addChild(btnSkill)

        btnSkill:setAuto(flag)
        btnSkill:setPosition(310 - (i - 1) * 130, 35)
    end
end
function FightTotemUI:setTotemValue(role, value)
	FightAnimationMgr.leftTotemValue = value
	for __, btn in pairs(self.list) do
		btn:setValue(value)
	end

	self.number.image:setString(math.floor(value / 10) .. '/100')
	self.value = value
end

function FightTotemUI:setTotemTextVisible(role, visible)
	for __, btn in pairs(self.list) do
	    if role == btn.role then
	    	btn:setTextVisible(visible)
	    end
	end
end

function FightTotemUI:isTouchEnabled(role)
	for __, btn in pairs(self.list) do
		if role == btn.role then
			return btn:isTouchEnabled()
		end
	end

	return false
end

function FightTotemUI:idle(time, target, visible)
    self.last = self.value + (self.last - self.value) * 0.75
    local v = self.last / 1000 * 386
    self.pStencil:setPositionX(-386 + v)
    self.effect5:setPositionX(9 + v)
    self.effect6:setPositionX(-6 + v)
    self.effect6:setVisible(self.last - 10 > self.value)

	---------------------------图腾技能图标相关start
    for i, btn in pairs(self.list) do
        local soldier = FightDataMgr.theFight:findSoldier(btn.role.guid)
        if soldier then
	        local role = btn.role

	        --没有目标文本显示
	        if target == role then
	        	btn:setTextVisible(visible)
	        end

	        if FightDataMgr.load_fight_log 
	        	or FightDataMgr.autoFight
	        	or not soldier:checkTotemSkill()
	        	or FightDataMgr.totem_btn_lock 
	        	or FightDataMgr.totem_btn_right_lock
	        	or role.totemCool > 0 
	        	or 0 == FightDataMgr.round 
	        	or not btn.flag 
	        	or FightDataMgr.round < 1
	        then
	            --去色
	            -- btn.image:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
	            btn.active = false
	            btn:setTouchEnabled(false)
				--去除满怒特效
	            if (btn.effectPower) then
                    btn.effectPower:setVisible(false)
                    --图腾满怒触发相关效果
                    FightTotemMgr:parseTotemPower(btn.role, time, false)
	            end
	        else
	            -- 还原
	            -- btn.image:setGLProgramState( ProgramMgr.createProgramState( 'normal' ) )
				btn:setTouchEnabled(true)

	            if not btn.active then
			        SoundMgr.playEffect("sound/totem_use.mp3", false)

	            	self:createEffectActive(btn)
		            --图腾满怒触发相关效果
					FightTotemMgr:parseTotemPower(btn.role, time, true)
	            end
	            --满怒特效
	            if (btn.effectPower == nil) then
	                btn.effectPower = getArmatureEffect(getUrl("angq-tx-01", "angq-tx-01", "ExportJson"), "angq-tx-01", 0, 2)
	                btn.effectPower:retain()
					btn.effectPower:setPosition(-152, -10)
					btn:addChild(btn.effectPower)
					btn.effectPower:setLocalZOrder(60)
					btn.effectPower:play()
					btn.effectPower:setSpeedScale(0.5)
					btn.effectPower:setScale(2)
	            end
	            btn.effectPower:setVisible(true)

	            if 1021 == FightDataMgr.fight_induct and not btn.fight_induct then
	            	btn.fight_induct = true
	                self.fight_induct_btn = btn

		            local animation = FightData.newAnimation()
		            animation.startTime = time
		            animation.endTime = time
		            animation.attr = 9
		            animation.val = 2
		            table.insert(FightDataMgr.othersAnimationList, animation)
	            end
	        end

	        if 
	        	FightDataMgr.totem_btn_Enable and 
	        	(1011 == FightDataMgr.fight_induct or (2061 == FightDataMgr.fight_induct and 1 == i))
	        then
	        	btn:setTouchEnabled(false)
	        end

	        --冷却相关更新
	        btn.numberWhite:setValue(role.totemCool)
	        btn.numberWhite:idle(btn.size)

	        local percent = math.ceil(role.totemCool / (role.canSkillRound - role.lastSkillRound) * 100)
	        if 0 == role.totemCool and 0 == role.canSkillRound and 0 == role.lastSkillRound then
	           percent = 100
	        end
	        local val = btn.ct.val + (percent - btn.ct.val) * 0.2
	        if math.ceil(val - percent) < 0.2 then
	           val = percent
	        end
	        if val < 0.2 then
	           val = 0
	        end
	        if 0 == percent and 0 == btn.ct.val then
	           val = 0
	        end
	        btn.ct.val = val
			btn.ct:setPercentage(btn.ct.val)
    	end
    end
end

function FightTotemUI:createEffectActive(btn)
	if not btn.skillActive then
		local effect = FightFileMgr:getEffect(FightAnimationMgr.const.TOTEM_READY)
		if not effect then
			return
		end
		local effectItem = effect:getEffectNormal()
		if not effectItem then
			return
		end

		local demo = getArmatureEffect(getUrl(FightAnimationMgr.const.TOTEM_READY, FightAnimationMgr.const.TOTEM_READY, "ExportJson"), FightAnimationMgr.const.TOTEM_READY, effectItem.flag, 2, 0)
		demo:retain()
		btn.skillActive = demo
		local onComplete = function()
			demo:setVisible(false)
		end
		demo:setPosition(-152, -83)
		demo:onPlayComplete(onComplete)
		btn:addChild(demo)
	end

	btn.skillActive:setVisible(true)
	btn.skillActive:gotoAndPlay(1)
	btn.active = true
end

------------------剧情引导专用-----------------start
--战斗剧情引导专用
function FightTotemUI:getPro()
	return self.effect4
end

--战斗剧情引导专用
function FightTotemUI:getCollBtn()
	if table.empty(self.list) then
		return nil
	end

	if not self.fight_induct_btn then
		self.fight_induct_btn = self.list[1]
	end

	return self.fight_induct_btn
end

--假战斗触发图腾技能[剧情引导专用]
function FightTotemUI:skillFire()
	--使用技能时特效
	if not self.fight_induct_btn then
		return
	end

	local btn = self.fight_induct_btn
	local role = self.fight_induct_btn.role
	local play = self.fight_induct_btn.role.playerView
	local parent = self.fight_induct_btn:getParent()
	local pt = cc.p(play:getPositionX(), play:getPositionY() + (role.body.footY - role.body.bodyY))
    local flyEffect = SkillFlyEffect:create(FightDataMgr.theFightUI.totemUI:getPositionX() + btn:getPositionX() + 45, FightDataMgr.theFightUI.totemUI:getPositionY() + btn:getPositionY() + 45, pt.x, pt.y, 0.4)
    FightDataMgr.theScene:addChild(flyEffect)

    local skillFire = self.fight_induct_btn:getSkillFire()
	skillFire:setPosition(-514, -437)
	skillFire:setLocalZOrder(50)
	skillFire:setVisible(true)
	skillFire:gotoAndPlay(1)
    FightDataMgr:touchTotem(role)
end
------------------剧情引导专用-----------------end