-- create by Live --
ArmatureSprite = class("ArmatureSprite", function(modelName)
	local armature = ccs.Armature:create(modelName)
	return armature
end)

function ArmatureSprite:getUIType()
	return "ccs"
end

function ArmatureSprite:getCurrentFrames()
    local animation = self:getAnimation()
    return animation:getTotalFrames()
end

function ArmatureSprite:getCurrentFrameIndex()
    local animation = self:getAnimation()
    return animation:getCurrentFrame()
end

function ArmatureSprite:getTotalFrames(animation)
    local animation = self:getAnimation()
    return animation:getTotalFrames()
end

function ArmatureSprite:getCurrentRate()
    local animation = self:getAnimation()
    return math.floor(animation:getFrameRate() * 60)
end

function ArmatureSprite:getFrameRate(animation)
    local animation = self:getAnimation()
    return math.floor(animation:getFrameRate() * 60)
end

-- 跳转动画 ，target 可为 下标或标签名 ，duration 为 时间间隔 ，loop 是否循环
function ArmatureSprite:chnAction(target, duration, loop)
    local animation = self:getAnimation()
    duration = duration or -1
    loop = loop or -1
    if type(target) == "number" then
        animation:playWithIndex(target, duration, loop)
    else
        animation:play(target, duration, loop)
    end
end

function ArmatureSprite:play()
    local animation = self:getAnimation()
    animation:resume()
end

-- 跳转动画帧
function ArmatureSprite:gotoAndPlay(frame)
    local animation = self:getAnimation()
    animation:gotoAndPlay(frame)
end

function ArmatureSprite:stop()
    local animation = self:getAnimation()
    animation:pause()
end

function ArmatureSprite:gotoAndStop(frame)
    local animation = self:getAnimation()
    animation:gotoAndPause(frame)
end

function ArmatureSprite:setSpeedScale(f)
    local animation = self:getAnimation()
    animation:setSpeedScale(f)
end

function ArmatureSprite:onPlayComplete(callback)
    local animation = self:getAnimation()
    if (callback) then
        local  function movementHandler(ref, eventType)
            if (ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType) then
                callback(self)
            end
        end
        animation:setMovementEventCallFunc(movementHandler)
    end
end

-- 设置偏移值 px,py为最最左下角点与注册点相差的偏移值
function ArmatureSprite:setOffset(px, py)
    local size = self:getContentSize()
    local rect = self:getBoundingBox()
    local p = cc.p(px / size.width, py / size.height)

    self:setAnchorPoint(p)
end

function ArmatureSprite:removeNextFrame( callback )
    local function removeHandler()
        if self:getParent() then
            self:removeFromParent()
            if callback then
                callback()
            end
        end
        self:release()
    end
    self:retain()
    TimerMgr.runNextFrame(removeHandler)
    -- self:runAction(cc.CallFunc:create(removeHandler))
end

-- 创建 骨骼动画对象 须先加载文件
function ArmatureSprite:create(modelName, startTarget, startDuration, loopTimes)
	local armature = ArmatureSprite.new(modelName)
	if nil ~= startTarget then
		startDuration = startDuration or -1
		loopTimes = loopTimes or -1
		armature:chnAction(startTarget, startDuration, loopTimes)
	end
	return armature
end

-- 添加一个特效到layer层
function ArmatureSprite:addArmatureTo(layer, path, name, x, y, complete, depth, uiName)
    if uiName == nil then uiName = "copy" end
	LoadMgr.loadArmatureFileInfo(path, LoadMgr.SCENE, uiName)
	local effect = ArmatureSprite:create(name, 0, nil, false)
	effect.json = path
	effect:setPosition(cc.p(x, y))
    if nil == depth then
        depth = 0
    end
	layer:addChild(effect, depth)

	if nil ~= complete then
		effect:onPlayComplete(complete)
	end
	return effect
end

function ArmatureSprite:removeArmature()
    local json = self.json
    self:removeFromParent()
    if json ~= nil then
        LoadMgr.removeArmature(json)
    end
end

function ArmatureSprite:addArmatureOnce(prePath, name, winName, parent, x, y, complete, depth)
    local path = prePath .. string.format("%s/%s.ExportJson", name, name)
    return ArmatureSprite:addArmature(path, name, winName, parent, x, y, complete, depth, 0)
end

function ArmatureSprite:addArmatureEx(prePath, name, winName, parent, x, y, complete, depth, times)
    local path = prePath .. string.format("%s/%s.ExportJson", name, name)
    return ArmatureSprite:addArmature(path, name, winName, parent, x, y, complete, depth, times)
end

local function do_addArmature(path, name, winName, parent, x, y, complete, depth, times, startTarget, startDuration, loadType)
    if Config.is_debug() and not cc.FileUtils:getInstance():isFileExist(path) then
        LogMgr.error("特效文件缺失：" .. path)
        path = "image/armature/ui/cardui/ckdg-tx-01/ckdg-tx-01.ExportJson"
        name = "ckdg-tx-01"
    end
    LoadMgr.loadArmatureFileInfo(path, loadType or LoadMgr.WINDOW, winName)
    local effect = ArmatureSprite:create(name, startTarget or 0, startDuration, times or -1)
    effect:setPosition(cc.p(x or 0, y or 0))
    effect:setLocalZOrder(depth or 0)
    if parent then
        parent:addChild(effect)
    end
    if nil ~= complete then
        effect:onPlayComplete(complete)
    end
    return effect
end

function ArmatureSprite:addArmatureScene(path, name, sceneName, parent, x, y, complete, depth, times)
    return do_addArmature(path, name, sceneName, parent, x, y, complete, depth, times, nil, nil, LoadMgr.SCENE)
end

function ArmatureSprite:addArmature(path, name, winName, parent, x, y, complete, depth, times, startTarget, startDuration)
    return do_addArmature(path, name, winName, parent, x, y, complete, depth, times, startTarget, startDuration, nil)
end

function ArmatureSprite:addGrow()
    local size = self:getContentSize()
    local programState = ProgramMgr.createProgramState( 'glow' )
    programState:setUniformFloat( 'u_strength', 2.0 )
    programState:setUniformVec2( 'u_size', {x = 1.0 / size.width, y = 1.0 / size.height} )
    programState:setUniformVec4( 'u_color', {x = 1.0, y = 0.847, z = 0.0, w =1.0} )
    --先设置缓存渲染
    -- self:setDoubleRender(true)
    --再设置渲染算法
    self:setGLProgramState( programState )
end

function ArmatureSprite:removeGrow()
   --  TimerMgr.callLater( function()
   --      --取消缓存渲染并清空内存, 不然会内存泄漏
   --      self:setDoubleRender(false)
   -- end, 0)
    local programState = ProgramMgr.createProgramState( 'normal' )
    self:setGLProgramState( programState )
end
