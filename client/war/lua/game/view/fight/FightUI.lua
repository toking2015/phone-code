require("lua/display/GLNodeRect")
require( "lua/game/view/fight/SkillFlyEffect.lua" )
require("lua/utils/UICommon.lua")
require("lua/game/view/fight/FightTotemUI.lua")
require("lua/game/view/fight/FightPauseUI.lua")
require("lua/game/view/fight/FightTrialUI.lua")

FightUI = class("FightUI", function(node)
    local node = node or cc.Node:create()
    node:retain()
    return node
end)

--bigboss血条
local FightBossHp = createUILayout("FightBossHp", FightFileMgr.prePath .. "FightNormal/BossBlood.ExportJson", "FightDataMgr")
function FightBossHp:ctor()
	self:retain()
end

--自动战斗
local FightAuto = createUILayout("FightAuto", FightFileMgr.prePath .. "FightNormal/AutoFight.ExportJson", "FightDataMgr")
function FightAuto:ctor()
	self:retain()
end

--取消自动战斗
local CancelAutoFight = createUILayout("CancelAutoFight", FightFileMgr.prePath .. "FightNormal/CancelAutoFight.ExportJson", "FightDataMgr")
function CancelAutoFight:ctor()
	self:retain()
end

function FightUI:getRedView()
	if not self.redView then
		local redView = GLNodeRect:create()
		self.redView = redView
		redView:retain()
	    redView:setAnchorPoint( 0, 0 )
	    redView:createBuffer()
	    redView:drawRect( visibleSize.width, visibleSize.height )
	    
	    redView:setProgramName( 'hurt' )
	    redView:setUniformData( 'u_color', 'vec4', { 0.88, 0, 0, 0.5 } )
	    redView:setUniformData( 'u_distance', 'vec1', { 100 } )
	    redView:setUniformData( 'u_size', 'vec2', { visibleSize.width, visibleSize.height } )
    end

    return self.redView
end

--图腾技能黑屏
function FightUI:getTotemBlackView()
	if not self.totemBlackView then
		local totemBlackView = UIFactory.getSprite("image/ui/FightUI/FightUI_blackView.jpg")
		self.totemBlackView = totemBlackView
		totemBlackView:retain()
		totemBlackView:setAnchorPoint(0, 0)
		totemBlackView:setScaleX(visibleSize.width)
		totemBlackView:setScaleY(visibleSize.height)
		totemBlackView:setOpacity(180)
	end

	return self.totemBlackView
end

--场景黑屏
function FightUI:getSceneBlackView()
	if not self.sceneBlackView then
		local sceneBlackView = UIFactory.getSprite("image/ui/FightUI/FightUI_blackView.jpg")
		sceneBlackView:retain()
		sceneBlackView:setAnchorPoint(0, 0)
		sceneBlackView:setScaleX(visibleSize.width)
		sceneBlackView:setScaleY(visibleSize.height)
		sceneBlackView:setOpacity(127)
		self.sceneBlackView = sceneBlackView
	end

	return self.sceneBlackView
end

--场景白屏
function FightUI:getSceneWhiteView()
	if not self.sceneWhiteView then
		local sceneWhiteView = UIFactory.getSprite("image/ui/FightUI/FightUI_whiteView.jpg")
		sceneWhiteView:retain()
		sceneWhiteView:setAnchorPoint(0, 0)
		sceneWhiteView:setScaleX(visibleSize.width)
		sceneWhiteView:setScaleY(visibleSize.height)
		sceneWhiteView:setOpacity(153)
		self.sceneWhiteView = sceneWhiteView
	end

	return self.sceneWhiteView
end

local function initBtn(view)
	if 
		const.kFightTypeSingleArenaPlayer == FightDataMgr.fight_type
		or const.kFightTypeSingleArenaMonster == FightDataMgr.fight_type
		or FightDataMgr.record or view.btnAuto or view.btnCancel 
	then
		return
	end

    local function setAutoFight()
    	if not FightDataMgr.autoFightFlag and GameData.getSimpleDataByKey("vip_level") < 1 then
    		local str = "使用该功能需要达到VIP1级[br]（连续登录2天或充值10元即可成为VIP1）[btn=two]cancel.png:look_over.png"
    		showMsgBox(str,function ( ... )
    			Command.run('ui show', 'VipPayUI', PopUpType.SPECIAL)
    		end)
    		return
    	end

        FightDataMgr.autoFight = true
        FightDataMgr.theFight:setAutoFight(1, const.kFightLeft)
        FightDataMgr:getLayerTop():addChild(view.btnCancel)
        view.btnAuto:removeFromParent()
    end
	
	local function setCancelFight()
		FightDataMgr.autoFight = false
		FightDataMgr.theFight:setAutoFight(0, const.kFightLeft)
        FightDataMgr:getLayerTop():addChild(view.btnAuto)
        view.btnCancel:removeFromParent() 
	end
	
	local btnAuto = FightAuto.new()
    view.btnAuto = btnAuto
    FightDataMgr:getLayerTop():addChild(btnAuto)
    btnAuto:setPosition(15, 15)
    createScaleButton(btnAuto.image)
    btnAuto.image:addTouchEnded(setAutoFight)
	
    local btnCancel = CancelAutoFight.new()
	view.btnCancel = btnCancel
    btnCancel:setPosition(15, 15)
    createScaleButton(btnCancel.image)
	btnCancel.image:addTouchEnded(setCancelFight)
end

--主界面
function FightUI:create(ui)
    local view = ui or FightUI.new()
    
    if GameData.getSimpleDataByKey("team_level") >= 10 or FightDataMgr.autoFightFlag then
    	initBtn(view)
	end

	--调速
	if FightDataMgr.speed_static then
		self.speed = FightSpeed.new()
		FightDataMgr:getLayerTop():addChild(self.speed)
		self.speed:setPosition(0, visibleSize.height - 170)
	end

	if FightDataMgr.save_fight_log then
		local function save_fight_log()
			FightDataMgr:saveFightLog()
		end
		local saveLogBtn = CancelAutoFight.new()
		view.saveLogBtn = saveLogBtn
	    saveLogBtn:setPosition(0, 100)
	    createScaleButton(saveLogBtn.image)
		saveLogBtn.image:addTouchEnded(setCancelAutoFight)
		view:addChild(saveLogBtn)
	end

	if not FightDataMgr.collaborationist then
		local box = nil
		if const.kFightTypeSingleArenaPlayer ~= FightDataMgr.fight_type then
			box = FightPauseBox.new()
			view.box = box
			FightDataMgr:getLayerTop():addChild(box)
			local size1 = box:getContentSize()
			box.size = size1
		end

		--试炼
		if const.kFightTypeTrialSurvival == FightDataMgr.fight_type 
			or const.kFightTypeTrialStrength == FightDataMgr.fight_type 
			or const.kFightTypeTrialAgile == FightDataMgr.fight_type 
			or const.kFightTypeTrialIntelligence == FightDataMgr.fight_type
		then
			local json = nil
			if const.kFightTypeTrialSurvival == FightDataMgr.fight_type then
				json = findTrial(1)
			elseif const.kFightTypeTrialStrength == FightDataMgr.fight_type then
				json = findTrial(2)
			elseif const.kFightTypeTrialAgile == FightDataMgr.fight_type then
				json = findTrial(3)
			else
				json = findTrial(4)
			end

			local round = FightRound.new(json)
			local trial = FightTrial.new(json)

			view.round = round
			view:addChild(round)
			round:setPosition(visibleSize.width / 2, visibleSize.height)

			view.trial = trial
			view:addChild(trial)
			local size = trial:getContentSize()
			trial:setPosition(5, visibleSize.height - size.height - 30)

			if box then
				box:setPosition(trial:getPositionX() + size.width, visibleSize.height - box.size.height)
			end
			initBtn(view)
		elseif not FightDataMgr.pauseLock then
			local pauseUI = FightPauseUI.new()
			view.pauseUI = pauseUI
			FightDataMgr:getLayerTop():addChild(pauseUI)
			local size = pauseUI:getContentSize()
			pauseUI:setPosition(size.width / 2, visibleSize.height - size.height * 1.5)

			if box then
				box:setPosition(pauseUI:getPositionX() + size.width, visibleSize.height - box.size.height)
			end
		else
			if box then
				local size = box:getContentSize()
				box:setPosition(0, visibleSize.height - size.height)
			end
		end
	end

	if 
        const.kFightTypeSingleArenaPlayer == FightDataMgr.fight_type
        or const.kFightTypeSingleArenaMonster == FightDataMgr.fight_type
    then
		view.auto = FightTotemAuto.new()
		view.auto:retain()
		view:addChild(view.auto)
		view.auto:setPosition((visibleSize.width - view.auto:getContentSize().width) / 2, 460)
	end
	
    return view
end

function FightUI:show()
    if 0 ~= #FightRoleMgr:getSoldierList(FightAnimationMgr.camp, const.kAttrTotem) then
	    self.totemUI = FightTotemUI.new()
	    self:addChild(self.totemUI)
	    self.totemUI:setPositionX(visibleSize.width - self.totemUI:getSize().width)
	    self.totemUI:show()
    end

	if not FightAnimationMgr.boss.monster or 2 ~= FightAnimationMgr.boss.monster.type then
		-- self.bossHp:setVisible(false)
		return
	end

	--boss血条初始化============================================start
    local bossHp = FightBossHp.new()
    self.bossHp = bossHp
    self:addChild(bossHp)
    local size = bossHp:getSize()
    bossHp:setPosition(visibleSize.width - size.width, visibleSize.height - size.height)

    --血条光标
    FightEffectMgr:loadResouce("xtyt-tx-01")
    local light = ArmatureSprite:create("xtyt-tx-01", 0)
    light:retain()
    bossHp.light = light
    bossHp:addChild(light)
    --boss血条初始化============================================end

    local face = UIFactory.getSprite(MonsterData.getAvatarUrl(FightAnimationMgr.boss.monster))
	face:retain()
	face:setPosition(328 + TeamData.AVATAR_OFFSET.x, 56 + TeamData.AVATAR_OFFSET.y)
    self.bossHp.face = face
    self.bossHp:addChild(face)

    -- local faceLight = UIFactory.getSprite(FightFileMgr.prePath .. "fight_boss_light.png")
    -- faceLight:retain()
    -- faceLight:setPosition(face:getPositionX() + 5, face:getPositionY() - 21)
    -- self.bossHp.faceLight = faceLight
    -- self.bossHp:addChild(faceLight)
    
    --初始化boss血条相关数据
    local role = FightAnimationMgr.boss.role
    self.bossHp.role = role
	self.bossHp.light:setPosition(34, 54)
    self.bossHp.maxHp = role.fightSoldier.last_ext_able.hp
    self.bossHp.hp = role.fightSoldier.last_ext_able.hp
    self.bossHp.lastHp = role.fightSoldier.last_ext_able.hp
    self.bossHp.size = self.bossHp.proSprite.hp_bar_1.hp:getSize()

	--second
	self.bossHp.hpSecond = self.bossHp.hp
	self.bossHp.lastHpSecond = self.bossHp.lastHp

	self.bossHp.hp_layer = role.fightSoldier.last_ext_able.hp / role.monster.hp_layer
    for i = 1, role.monster.hp_layer, 1 do 
		self.bossHp.proSprite["hp_bar_" .. i].hp:setPercent(100)
		self.bossHp.proSprite["hp_bar_second_" .. i].hp:setPercent(100)
	end

	for i = role.monster.hp_layer + 1, 4, 1 do
		self.bossHp.proSprite["hp_bar_" .. i].hp:setPercent(0)
		self.bossHp.proSprite["hp_bar_second_" .. i].hp:setPercent(0)
	end

	self.bossHp.layer.number:setString('/' .. role.monster.hp_layer)
	if 1 == role.monster.hp_layer then
		self.bossHp.layer:setVisible(false)
	else
		self.bossHp.layer:setVisible(true)
	end
end

function FightUI:update(time)
	if self.totemUI then
	    self.totemUI:idle(time)
	end

    if self.round then
    	self.round:idle(time)
    end

    if self.auto then
    	self.auto:idle(time)
    end
end

---------------------------bossHp start
--血条更新
function FightUI:boss_hp_update(time)
	if not FightAnimationMgr.boss.monster or 2 ~= FightAnimationMgr.boss.monster.type then
		return
	end

    local bossHp = self.bossHp
    bossHp.lastHp = bossHp.hp + (bossHp.lastHp - bossHp.hp) * 0.75
    local layer = math.ceil(bossHp.lastHp / bossHp.hp_layer)
    for i = layer + 1, 4, 1 do
    	self.bossHp.proSprite["hp_bar_" .. i].hp:setPercent(0)
    end
    if 0 == layer then
    	layer = 1
	elseif layer > 4 then
		layer = 4
    end

    local hp_bar = self.bossHp.proSprite["hp_bar_" .. layer]
    hp_bar.hp:setPercent(100 * (bossHp.lastHp - (layer - 1) * bossHp.hp_layer) / bossHp.hp_layer)
	
	bossHp.lastHpSecond = bossHp.hpSecond + (bossHp.lastHpSecond - bossHp.hpSecond) * 0.75
    layer = math.ceil(bossHp.lastHpSecond / bossHp.hp_layer)
    for i = layer + 1, 4, 1 do
    	self.bossHp.proSprite["hp_bar_second_" .. i].hp:setPercent(0)
    end
    if 0 == layer then
    	layer = 1
	elseif layer > 4 then
		layer = 4
    end
	local hp_bar_second = self.bossHp.proSprite["hp_bar_second_" .. layer]
	hp_bar_second.hp:setPercent(100 * (bossHp.lastHpSecond - (layer - 1) * bossHp.hp_layer) / bossHp.hp_layer)

    local size = cc.size((bossHp.lastHpSecond - (layer - 1) * bossHp.hp_layer) / bossHp.hp_layer * bossHp.size.width, bossHp.size.height)
    bossHp.light:setPosition(34 + bossHp.size.width - size.width, 54)
   	bossHp.light:setVisible(bossHp.lastHpSecond > 1)

    self.bossHp.layer.number:setString('/' .. layer)
end

--重置血条数据
function FightUI:reset_boss_hp(maxHp)
	if not FightAnimationMgr.boss.monster or 2 ~= FightAnimationMgr.boss.monster.type then
		return
	end

    self.bossHp.maxHp = maxHp
    self.bossHp.hp = maxHp
    --self.bossHp.lastHp = maxHp
	--self.bossHp.proSprite.hp_bar.hp:setPercent(100)
	--self.bossHp.light:setPosition(76, 96)
	
	self.bossHp.hpSecond = maxHp
	--self.bossHp.lastHpSecond = maxHp
	--self.bossHp.proSprite.hp_bar_second.hp:setPercent(100)
end

--FightDataMgr:runNumber
function FightUI:setbossHp(hp)
	if not FightAnimationMgr.boss.monster or 2 ~= FightAnimationMgr.boss.monster.type then
		return
	end

    self.bossHp.hp = self.bossHp.hp + hp
    if self.bossHp.hp > self.bossHp.maxHp then
    	self.bossHp.hp = self.bossHp.maxHp
	elseif self.bossHp.hp < 0 then
		self.bossHp.hp = 0
    end
end

function FightUI:setSecondBossHp(hp)
	if not FightAnimationMgr.boss.monster or 2 ~= FightAnimationMgr.boss.monster.type then
		return
	end

	self.bossHp.hpSecond = self.bossHp.hpSecond + hp
    if self.bossHp.hpSecond > self.bossHp.maxHp then
    	self.bossHp.hpSecond = self.bossHp.maxHp
	elseif self.bossHp.hpSecond < 0 then
		self.bossHp.hpSecond = 0
    end
end

function FightUI:setBossHpFace(state)
	-- setGLProgramStateChildren("paint")
	if not FightAnimationMgr.boss.monster or 2 ~= FightAnimationMgr.boss.monster.type then
		return
	end

	local filter = nil
	if "paint" == state then
		filter = FightFileMgr:getfiltersRed()
	else
		filter = ProgramMgr.createProgramState( state )
	end
	self.bossHp.face:setGLProgramState(filter)
end
---------------------------bossHp end

function FightUI:idle(time)
    self:update(time)
    self:boss_hp_update(time)

    if self.trial then
    	self.trial:idle(time)
    end
end

function FightUI:setTrialValue(endInfo)
	if not self.trial then
		return
	end

	self.trial:set_value(endInfo)
end

function FightUI:setTotemValue(role, value)
	if not self.totemUI then
		return
	end

	self.totemUI:setTotemValue(role, value)
end

function FightUI:boxCountAdd(count)
	if not self.box then
		return
	end
	
	if not self.box.count then
		self.box.count = 0
	end

	if not count then
		self.box.count = self.box.count + 1
	else
		self.box.count = count
	end
	self.box.image1.number:setString(self.box.count)
end

function FightUI:releaseAll()
	if self.bossHp then
		if self.bossHp.light then
		    self.bossHp.light:removeFromParent()
			self.bossHp.light:release()
			self.bossHp.light = nil
		end

		-- if self.bossHp.faceLight then
		--     self.bossHp.faceLight:removeFromParent()
		-- 	self.bossHp.faceLight:release()
		-- 	self.bossHp.faceLight = nil
		-- end

		if self.bossHp.face then
			self.bossHp.face:removeFromParent()
			self.bossHp.face:release()
			self.bossHp.face = nil
		end

		self.bossHp:removeFromParent()
		self.bossHp:release()
		self.bossHp = nil
	end

	if self.redView then
		self.redView:removeFromParent()
		self.redView:deleteBuffer()
		self.redView:release()
		self.redView = nil
	end

	if self.totemBlackView then
		self.totemBlackView:removeFromParent()
		self.totemBlackView:release()
		self.totemBlackView = nil
	end
	
	if self.sceneBlackView then
		self.sceneBlackView:removeFromParent()
		self.sceneBlackView:release()
		self.sceneBlackView = nil
	end

	if self.sceneWhiteView then
		self.sceneWhiteView:removeFromParent()
		self.sceneWhiteView:release()
		self.sceneWhiteView = nil
    end
    if self.auto then
    	self.auto:removeFromParent()
    	self.auto:release()
    end
    if self.btnAuto then
	    self.btnAuto:removeFromParent()
		self.btnAuto:release()
		self.btnAuto = nil
	end
	
	if self.btnCancel then
		self.btnCancel:removeFromParent()
		self.btnCancel:release()
		self.btnCancel = nil
	end
    
    if self.box then
		self.box:releaseAll()
		self.box = nil
	end
	
	if self.pauseUI then
		self.pauseUI:releaseAll()
		self.pauseUI = nil
	end

	if self.speed then
		self.speed:releaseAll()
		self.speed = nil
	end

	if self.round then
		self.round:releaseAll()
		self.round = nil
	end

	if self.trial then
		self.trial:releaseAll()
		self.trial = nil
	end

	if self.totemUI then
		self.totemUI:releaseAll()
		self.totemUI = nil
	end

    self:removeFromParent()
	self:release()
end