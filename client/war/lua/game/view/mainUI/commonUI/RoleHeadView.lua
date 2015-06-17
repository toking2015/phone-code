-- create by Hujingjiang --

local prevPath = "image/ui/MainUI/"
local effStart_pos = cc.p(-12, 62)
local shineStart_pos = cc.p(108, 56)

RoleHeadView = class("RoleHeadView", function()
	return getLayout(prevPath .. "RoleHeadView.ExportJson")
end)

local function addOutline(item, rgb)
    if item == nil then return end
    local txt = item:getVirtualRenderer()
    txt:enableOutline(rgb, 0.5)
end

local function createHeadProgress()
    local left = cc.ProgressTimer:create(Sprite:createWithSpriteFrameName("main_exp.png"))
    left:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    left:setMidpoint(cc.p(0, 0))
    left:setBarChangeRate(cc.p(1, 0))
    left:setPosition(cc.p(168, 41))

    return left
end

function RoleHeadView:create()
	return RoleHeadView.new()
end

function RoleHeadView:ctor()
	local function teamHandler(ref, eventType)
        ActionMgr.save( 'UI', 'SettingUI click img_icon' )
		Command.run("ui show", "SettingUI", PopUpType.SPECIAL)
	end
	self.img_icon:setTouchEnabled(true)
	UIMgr.addTouchEnded(self.img_icon, teamHandler)

	local function levelHandler(ref, eventType)
		Command.run("logviewer_switch")
	end
	self.img_level_bg:setTouchEnabled(true)
	UIMgr.addTouchEnded(self.img_level_bg, levelHandler)

	-- local progress = createHeadProgress()
	-- self.img_bg:addChild(progress, 10, 1)
	self:initExpBar() -- 初始化经验条
	--self:setExpPercent(1)

	self:init()
	--TASK #6808::【手游12月版】在客户端左上角，把当前服务器时间标记出来
	local txt = UIFactory.getText("", self, 95, 105, 20, cc.c3b(0xff, 0xff, 0xff))
	txt:setAnchorPoint(0, 0)
	local timer_id = nil
	local function updateTime()
		txt:setString(DateTools.toFormatString(gameData.getServerTime(), "%m月%d日 %H:%M:%S"))
	end
    local timer_id = TimerMgr.startTimer(updateTime, 1)
    updateTime()
	local function onNodeEvent(event)
		if "enter" == event then
			if not timer_id then
			    timer_id = TimerMgr.startTimer(updateTime, 1)
			end
		elseif "exit" == event then
			timer_id = TimerMgr.stopTimer()
		end
	end
	local function showFightPower( sender,event )
		self.img_fight:setScale(1,1)
		ActionMgr.save( 'UI', 'SettingUI click img_fight' )
		Command.run("ui show", "FightPowerUI", PopUpType.SPECIAL)
	end
	createScaleButton(self.img_fight)
	--self.img_fight:addTouchCancel(btnHandler)
	self.img_fight:setTouchEnabled(true)
	self.img_fight:addTouchEnded(showFightPower)
end

function RoleHeadView:initExpBar()
	--创建cliper
   	if self.pClip == nil then
		self.pClip=cc.ClippingNode:create()
		self.pClip:setAnchorPoint( cc.p( 0, 0 ) )
		self:addChild(self.pClip)

		self.pStencil = Sprite:createWithSpriteFrameName("main_exp.png")
		self.pStencil:setAnchorPoint( cc.p( 0, 0 ) )
		self.pStencil:setPosition(cc.p(108, 47))

        --设置模板
	    self.pClip:setAlphaThreshold( 0.5 )
	    self.pClip:setInverted(false)
		self.pClip:setStencil(self.pStencil)
	end

	local posX, posY = 0, 0
	if self.effect1 == nil then
	    local path1 = "image/armature/ui/MainUI/xjyt-tx-01/xjyt-tx-01.ExportJson"
		LoadMgr.loadArmatureFileInfo(path1, LoadMgr.SCENE, "main")
		self.effect1 = ArmatureSprite:create("xjyt-tx-01", 0)
		self.pClip:addChild(self.effect1)
		--注意骨骼动画的锚点
		posX = self.pStencil:getPositionX() + 120 * self.effect1:getAnchorPoint().x
		posY = self.pStencil:getPositionY() + 15 * self.effect1:getAnchorPoint().y
		self.eff_pos = cc.p(posX - 120, posY)
	    self.effect1:setPosition(effStart_pos)
	end

	if not self.shine then
		local path = 'image/armature/ui/MainUI/xjyt-tx-02/xjyt-tx-02.ExportJson'
		LoadMgr.loadArmatureFileInfo(path, LoadMgr.SCENE, "main")
		self.shine = ArmatureSprite:create("xjyt-tx-02", 0)
		self:addChild(self.shine)
		self.shine_pos = cc.p(posX, posY - 6)
		self.shine:setPosition(shineStart_pos)
	end
end

function RoleHeadView:configureEventList()
    self.event_list = {}
    self.event_list[EventType.UserCoinUpdate] = function(data) 
        if data.coin.cate == const.kCoinTeamXp then
        	local scene = SceneMgr.getCurrentScene()
        	if "copy" ~= scene.name and "copyUI" ~= scene.name then
            	-- self:updateExp()
            end
        end
    end
    self.event_list[EventType.UserSimpleUpdate] = function()
    	self:updateAvatar()
		self:updateFightValue()
	end
    EventMgr.addList(self.event_list)
end

--初始化显示
function RoleHeadView:init()
	self:updateName()
	self:updateLevel()
	self:updateVipLevel()
	self:updateAvatar()
	self:updateFightValue()
	
	self:updateExp()
	self:headEffectAction()
end

function RoleHeadView:updateVipLevel()
	self.atlas_vip:setString(gameData.getSimpleDataByKey("vip_level"))
end

function RoleHeadView:updateFightValue()
	-- self.atlas_power:setString(gameData.getSimpleDataByKey("fight_value"))
	self.img_fight.txt_fight_num:setString(UserData.getFightValue())
end

function RoleHeadView:updateLevel()
	local teamLevel = gameData.getSimpleDataByKey("team_level")
	self.txt_level:setString(teamLevel)
end

function RoleHeadView:updateName()
    addOutline(self.txt_name, cc.c4b(255, 240, 0, 255))
	self.txt_name:setString(gameData.getSimpleDataByKey("name"))
end

function RoleHeadView:setPower(value)
	-- self.atlas_power:setString(value)
	self.img_fight.txt_fight_num:setString(value)
end

function RoleHeadView:setVip(value)
	self.atlas_vip:setString(value)
end

function RoleHeadView:updateAvatar()
	local avatarId = gameData.getSimpleDataByKey("avatar")
	if avatarId == 0 then
		local avatarList = GetDataList("Avatar")
		local systemList = {}
		for _,v in ipairs(avatarList) do
			if v.type == TeamData.AVATAR_AVATAR then
				table.insert(systemList, v)
			end
		end
		avatarId = systemList[MathUtil.random(1, #systemList)].id
		Command.run("team avatar change", avatarId)
		return
	end
	if self.avatarId ~= avatarId then
		self.avatarId = avatarId
		local url = TeamData.getAvatarUrlById(avatarId)
		if url then
			self.img_icon:loadTexture(url, ccui.TextureResType.localType)
		end
	end
end

function RoleHeadView:progressAction(level, sumExp, val)
	local jLevel = findLevel(level)
	if not jLevel then
		return
	end
    local maxExp = jLevel.team_xp
    if sumExp >= maxExp then
		LogMgr.debug("超过经验值上限，升级", sumExp, maxExp, val, maxExp - sumExp + val)
		local function callfunc() 
			-- 将eff和shine重置初始位置
			LogMgr.debug("--------重置进度条坐标--------")
			self.effect1:setPosition(effStart_pos)--cc.p(-12, 56))
			self.shine:setPosition(cc.p(shineStart_pos))--108, 50))
            sumExp = sumExp - maxExp
            self:progressAction(level + 1, sumExp, sumExp)
		end
		self:setExpPercent(1, callfunc)
    else
        LogMgr.debug("没有超过上限，增加的经验：", val)
        self:setExpPercent(sumExp/maxExp)
    end
end

---------------
--@ sumExp: 总经验
--@ value: 获得的经验
function RoleHeadView:roleHeadExpAction(level, sumExp, value)
	local teamLevel = level
	local preExp = sumExp - value

	if teamLevel >= MainScene.MaxTeamLevel then
		self.effect1:setPosition(cc.p(effStart_pos.x + 120, effStart_pos.y))--cc.p(self.eff_pos.x + 120, self.eff_pos.y))
	    self.shine:setPosition(cc.p(shineStart_pos.x + 120, shineStart_pos.y))--cc.p(self.shine_pos.x + 120, self.shine_pos.y))
    	return
    end
    self:progressAction(teamLevel, sumExp, value)
end

function RoleHeadView:setExpPercent(percent, callfunc)
	local function actionCom()
		if callfunc then 
			callfunc() 
		end
	end

	percent = math.min(1,percent)
	local w = 120 * percent -- 增加的长度
	-- local new_eff_pos = cc.p(self.effect1:getPositionX() + w, self.effect1:getPositionY())
	-- local new_shine_pos = cc.p(self.shine:getPositionX() + w, self.shine:getPositionY())
	local new_eff_pos = cc.p(effStart_pos.x + w, 62)
	local new_shine_pos = cc.p(shineStart_pos.x + w, 56)
	LogMgr.debug("percent = " .. percent, "add length = " .. w)
	self.effect1:stopAllActions()
	self.shine:stopAllActions()
	local eff_move = cc.MoveTo:create(0.3, new_eff_pos)
	local delay = cc.DelayTime:create(0.3)
	local shine_move = cc.MoveTo:create(0.3, new_shine_pos)
	local func = cc.CallFunc:create(actionCom)
	local eff_seq = cc.Sequence:create(eff_move, delay, func)
	self.effect1:runAction(eff_seq)
	self.shine:runAction(shine_move)
end

function RoleHeadView:updateExp()
	local exp = gameData.getSimpleDataByKey('team_xp')
	local teamLevel = gameData.getSimpleDataByKey("team_level")
	local maxExp = findLevel(teamLevel).team_xp
	local w = 120 * exp/maxExp
	local eff_pos = cc.p(effStart_pos.x + w, effStart_pos.y)
	local shine_pos = cc.p(shineStart_pos.x + w, shineStart_pos.y)
	if not self.effect1 and not self.shine then
		self:initExpBar()
	end
	self.effect1:stopAllActions()
	self.shine:stopAllActions()
	self.effect1:setPosition(eff_pos)
	self.shine:setPosition(shine_pos)
end

function RoleHeadView:addRoleExp(level, sumExp, value)
    self:roleHeadExpAction(level, sumExp, value)
end

function RoleHeadView:obtainExpAction(data)
    local sumExp = data.coin.val + data.old_value
    local value = data.coin.val
    local level = gameData.getSimpleDataByKey("team_level")
    self:roleHeadExpAction(level, sumExp, value)
end

function RoleHeadView:headEffectAction()
	local path = "image/armature/ui/MainUI/zjmvip-tx-01/zjmvip-tx-01.ExportJson"
	local effect_1 = ArmatureSprite:addArmatureScene(path, "zjmvip-tx-01", "main")
	local bSize = self.img_vip_bg:getSize()
	effect_1:setPosition(cc.p(bSize.width/2, bSize.height/2 + 2))
	self.img_vip_bg:addChild(effect_1)
end