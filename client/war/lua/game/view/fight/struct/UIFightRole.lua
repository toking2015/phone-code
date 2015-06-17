--战斗人物显示对象
UIRoleForFight = class("UIRoleForFight", function()
    local node = cc.Node:create()
    node:retain()
    node:setCascadeOpacityEnabled(true)

    --背景容器
    node.backgroundLayer = cc.Node:create()
    node.backgroundLayer:retain()
    node.backgroundLayer:setCascadeOpacityEnabled(true)
    node:addChild(node.backgroundLayer)
    
    --角色层容器
    node.viewLayer = cc.Node:create()
    node.viewLayer:retain()
    node.viewLayer:setCascadeOpacityEnabled(true)
    node:addChild(node.viewLayer)

    --表层容器
    node.sprite = cc.Node:create()
    node.sprite:retain()
    node.sprite:setCascadeOpacityEnabled(true)
    node:addChild(node.sprite)

    node.playerView = nil
    node.frame = 0
    node.body = nil
    node.bodyData = nil
    node.action = nil
    
    node.actionType = ''
    node.frame = 0
    node.lastTime = 0
    node.totalFrames = 0
    node.frameRate = 0
    node.along = true
    node.jump_frame = 1

    node.name_bg = UIFactory.getSpriteFrame("role_name_bg.png", node, 0, -37)
    node.txt_name = UIFactory.getText("", node, 0, -38, 16, cc.c3b(0xff, 0xff, 0xff))

    --以下为独立扩展计时器相关属性
    node.timer = {}
    node.timer.time = 0
    node.timer.id = nil
    return node
end)

function UIRoleForFight:create()
    return UIRoleForFight.new()
end

local function getUrl(attr, style, name, type)
    if not attr or const.kAttrTotem ~= attr then
        return "image/armature/fight/model/" .. style .. '/' .. name .. '.' .. type
    else
        return "image/armature/fight/totem/" .. style .. '/' .. name .. '.' .. type
    end
end

function UIRoleForFight:createNode(body, load, attr, animation_name, level)
    self.body = body
    self.bodyData = body

    LogMgr.debug(#self.body.style)
    if load then
        if attr and const.kAttrTotem == attr then
            LoadMgr.loadArmatureFileInfoTotem(animation_name, level, LoadMgr.MODEL)
        else
            LoadMgr.loadArmatureFileInfo(getUrl(attr, body.style, body.style, "ExportJson"), LoadMgr.MODEL)
        end
    end
    
    self.playerView = ArmatureSprite:create(body.style)
    self.playerView:retain()
    self.viewLayer:addChild(self.playerView)
    self.playerView:setPosition(cc.p(-1 * self.body.footX, self.body.footY))
    self.playerView:setScale(self.body.scale / 100)

    self:chnAction(self.mirror, "stand")

    --如果为当次计时器执行
    if self.playOneFlag then
        self:playOne(self.mirror, self.playOneFlag)
    end
end

function UIRoleForFight:init(body, mirror, load, attr, animation_name, level)
    self.attr = attr
    self.mirror = mirror
    if mirror then
        self.viewLayer:setScaleX(-1)
    end

    if not self.playerView then
        self:createNode(body, load, attr, animation_name, level)
        return
    end
	
    self.playerView:setPosition(cc.p(-1 * body.footX, body.footY))
    self.playerView:setScale(body.scale / 100)
    self:chnAction(mirror, "stand")
end

function UIRoleForFight:change(body, mirror)
    if self.playerView then
        if self.body == body then
            return
        end

        self.playerView:removeFromParent()
        self.playerView:release()
        self.playerView = nil
        self:createNode(body)
        return
    end
    
    if "BS01bdanzong" == body.style then
        --暂时补上倍数2，待美术优化完资源后，导出时为100%
        self.playerView:setScale(2 * body.scale / 100)
    else
        self.playerView:setScale(body.scale / 100)
    end
    self.playerView:setPosition(cc.p(-1 * body.footX, body.footY))
    self:chnAction(mirror, "stand")
    if mirror then
        self.viewLayer:setScaleX(-1)
    end
end

function UIRoleForFight:chnAction(mirror, flag, data, role)
    if not self.body or not self.playerView then
        self.frame = 0
        return false
    end
    
    if mirror then
        self.viewLayer:setScaleX(-1)
    else
        self.viewLayer:setScaleX(1)
    end

    self.actionType = flag
    local tempAction = self.body:getActionByFlag(flag)
    if not tempAction then
        LogMgr.log("error", "%s", "缺少动作，动作标签：" .. flag .. " 模型：" .. self.body.style)
    end

    if not self.action or tempAction ~= self.action then
        self.action = tempAction
        self.totalFrames = tempAction.count
        self.frameRate = 25
        self.playerView:chnAction(flag)
        self.frame = 0
        self.lastTime = 0
        self:attack(0)

        local frames = self.playerView:getCurrentFrames()
        self.totalFrames = frames

        --小马要求待机和死亡帧频修改为33毫秒/帧
        if "stand" == flag then
            self.frameRate = 33
        elseif "dead" == flag then
            self.frameRate = 40
        else
            local rate = self.playerView:getCurrentRate()
            self.frameRate = math.ceil(1000 / rate)
        end
    end
    
    if data and role and 0 ~= data.endTime then
        data.endTime = data.startTime + self.totalFrames * self.frameRate
        if "dead" == flag and 0xfffff0 ~= role.dearTime then
            role.dearTime = data.endTime
        end
    end
end

function UIRoleForFight:stand(time)
    if not self.playerView or (time - self.lastTime) < (self.frameRate * self.jump_frame) then
        return
    end
    
    self.lastTime = time

    --小马要求待机和死亡帧频修改为33毫秒/帧
    if "stand" == self.action.flag then
        self.frameRate = 33
    elseif "dead" == self.action.flag then
        self.frameRate = 40
    else
        self.frameRate = 25
    end
    
    if 0 == self.action.play then
        self.frame = self.frame + 1
        if self.frame >= self.totalFrames then
            self.frame = 0
        end
        self.playerView:gotoAndStop(self.frame)

        local frames = self.playerView:getCurrentFrames()
        self.totalFrames = frames
        return
    end
    
    if self.along then
        self.frame = self.frame + 1
    else
        self.frame = self.frame - 1
    end
    
    if self.frame >= self.action.count then
        self.frame = self.action.count - 2
        self.along = false
    end
    if self.frame <= 0 then
        self.frame = 0
        self.along = true
    end
    self.playerView:gotoAndStop(self.frame)

    local frames = self.playerView:getCurrentFrames()
    self.totalFrames = frames
end

function UIRoleForFight:attack(frame, data, role)
    if not self.playerView or frame > self.totalFrames then
        return
    end

    self.playerView:gotoAndStop(frame)

    local frames = self.playerView:getCurrentFrames()
    self.totalFrames = frames
    --小马要求待机和死亡帧频修改为33毫秒/帧
    if "stand" == self.action.flag then
        self.frameRate = 33
    elseif "dead" == self.action.flag then
        self.frameRate = 40
    else
        local rate = self.playerView:getCurrentRate()
        self.frameRate = math.ceil(1000 / rate)
    end

    if data and role and 0 ~= data.endTime then
        data.endTime = data.startTime + self.totalFrames * self.frameRate
        if "dead" == self.actionType and 0xfffff0 ~= role.dearTime then
            role.dearTime = data.endTime
        end
    end
end

--设置滤镜
function UIRoleForFight:setGLProgramStateChildren(state)
    if not self.playerView then
        return
    end

	local filter = nil
	if "paint" == state then
		filter = FightFileMgr:getfiltersRed()
    elseif "white" == state then
        filter = FightFileMgr:getFiltersWhite()
    elseif "black" == state then
        filter = FightFileMgr:getFiltersBlack()
	else
		filter = ProgramMgr.createProgramState( state )
	end
	
	self.playerView:setGLProgramStateChildren(filter)
end

function UIRoleForFight:idle_PlayStand()
    local idle = function (time)
        self:playStand(time)
    end

    self:stopStand()
    self:chnAction(self.mirror, "stand")
    self.timer.id = TimerMgr.startTimer( idle, 0.001, false )
end

--一次性播放指定动作后恢复待机动作  [mirror:镜像, flag:动作标签名, change:nil==恢复待机动作]
function UIRoleForFight:playOne(mirror, flag, change)
    self.mirror = mirror
    self.playOneFlag = flag
    if not self.playerView or self.lastPlayOneFlag == flag then
        return
    end

    if "stand" == flag then
        self:idle_PlayStand()
        return
    end

    self:stopStand()
    local idle = function (time)
        if not self.playerView then
            return
        end

        self.lastPlayOneFlag = self.playOneFlag
        self.timer.time = self.timer.time + time
        local time = math.ceil(self.timer.time * 1000)
        local frame = tonumber(time / self.frameRate)
        if frame > self.totalFrames then
            self:stopStand()

            if not change then
                self.lastTime = 0
                self.timer.time = 0
                self:idle_PlayStand()
            end
            return
        end

        self:attack(frame)
    end
    self.lastTime = 0
    self.timer.time = 0
    self:chnAction(mirror, flag)
    self.timer.id = TimerMgr.startTimer(idle, 0.001, false)

    -- local completeHandler = nil
    -- if not change then
    --     completeHandler = function()
    --         self.lastPlayOneFlag = self.playOneFlag
    --         if not self.playOneFlag then
    --             self:stopStand()
    --             return
    --         end
    --         self:chnAction(self.mirror, "stand")
    --         self:stopStand()
    --         self.timer.id = TimerMgr.startTimer( idle, 0.001, false )
    --     end
    -- else
    --     completeHandler = function()
    --         self.lastPlayOneFlag = self.playOneFlag
    --         self:stopStand()
    --         -- self.playerView:gotoAndStop(self.action.count - 2)
    --         self.playerView:stop()
    --         -- self.playerView:gotoAndStop(self.totalFrames)
    --     end
    -- end

    -- self.playerView:onPlayComplete(completeHandler)
    -- self:chnAction(mirror, flag)
    -- self.playerView:gotoAndPlay(1)
end

function UIRoleForFight:playStand(time)
    if not self.playerView then
        return
    end
    self.timer.time = self.timer.time + time
    local time = math.ceil(self.timer.time * 1000)
    self:stand(time)
end
function UIRoleForFight:stopStand()
    if not self.timer.id then
        return
    end

    TimerMgr.killTimer( self.timer.id )
    self.timer.id = nil
    self.lastPlayOneFlag = nil
end

--设置显示的名字
function UIRoleForFight:setRoleName(name, c3b)
    if name then
        self:nameSwap(true)
        self.txt_name:setString(name)
        self.txt_name:setColor(c3b)
    else
        self:nameSwap(false)
    end
end

function UIRoleForFight:setMirror(isMirror)
    self.mirror = isMirror
    if isMirror then
        self.viewLayer:setScaleX(-1)
    else
        self.viewLayer:setScaleX(1)
    end
end

function UIRoleForFight:playOnce(act, change)
    self:playOne(self.mirror, act, change)
end

function UIRoleForFight:nameSwap(b)
    self.name_bg:setVisible(b)
    self.txt_name:setVisible(b)
end

--设置喊话内容
function UIRoleForFight:setTalk(str)
    if not str or '' == str then
        if self.talkBg then
            self.talkBg:setVisible(false)
        end
        return
    end

    if not self.talkBg then
        self.talkBg = UIFactory.getSprite("image/ui/FightUI/Fight_Talk.png")
        self.talkBg:retain()
        self.talkTxt = UIFactory.getText("", node, 0, 0, 16, cc.c3b(0xff, 0xf9, 0x9e))
        self.talkTxt:ignoreContentAdaptWithSize(false)
        self.talkTxt:setSize(cc.size(140, 50))
        self.sprite:addChild(self.talkBg)
        self.talkBg:addChild(self.talkTxt)
        self.talkBg:setPositionY(self.body.footY - self.body.headY)
        self.talkTxt:setPosition(88, 60)
    end

    self.talkBg:setVisible(true)
    self.talkTxt:setString(str)
end

--初始化血条
function UIRoleForFight:initHp(quality)
    if self.hpView then
        return self.hpView
    end

    self.quality = quality
    if const.kQualityWhite == quality then
        self.hpView = FightNumberMgr:useNormalHp()
    else
        self.hpView = FightNumberMgr:useNormalHpSecond()
    end
    self:addChild(self.hpView)
    self.hpView.size = self.hpView:getSize()
    self.hpView:setPosition(-self.hpView.size.width / 2, self.body.footY - self.body.headY + 18)
    return self.hpView
end

function UIRoleForFight:releaseHp()
    if not self.hpView then
        return
    end

    FightNumberMgr:unNormalHp(self.hpView)
    self.hpView = nil
end

function UIRoleForFight:releaseAll()
    LogMgr.debug("*****************UIRoleForFight:releaseAll*****************")
    self:stopStand()

    if self.timer.id then
        TimerMgr.killTimer( self.timer.id )
    end
    self.timer.id = nil

    if self.talkBg then
        -- FightTextMgr.removeImage("image/ui/FightUI/Fight_Talk.png")
        self.talkBg:removeFromParent()
        self.talkBg:release()
    end

    if self.hpView then
        self:releaseHp()
    end

	if self.playerView then
		self.playerView:release()
	end

    if self.backgroundLayer then
        self.backgroundLayer:release()
    end

    if self.viewLayer then
        self.viewLayer:release()
    end

	if self.sprite then
		self.sprite:release()
	end

    self.name_bg:removeFromParent()
    self.txt_name:removeFromParent()

    self:removeAllChildren()
    self.body = nil
    self.bodyData = nil
    self.action = nil
    self:removeFromParent()
    TimerMgr.releaseLater(self)
end