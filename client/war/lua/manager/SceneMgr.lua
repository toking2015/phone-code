--黄少卿
local __this = { data = {}, queue = {}, current_scene = nil, prev_scene_name = "", layers = {}}
SceneMgr = __this
--UI分层
__this.LAYER_SCENE = 1 --使用getCurrentScene
__this.LAYER_SCENE_EFFECT = 2 --场景特效层，低于窗口
__this.LAYER_WINDOW = 3 --窗口层
__this.LAYER_UP_WINDOW = 4 --高层窗口，如资源条，剧情窗口
__this.LAYER_EFFECT = 5 --特效层，高于窗口
__this.LAYER_BACK = 6 --返回按钮层
__this.LAYER_GUT = 7 --剧情层
__this.LAYER_TIPS = 8 --提示层
__this.LAYER_LOCK = 9 --锁定不让点击层
__this.LAYER_INDUCT = 10 --引导层
__this.LAYER_LOADING = 11 --加载条层
__this.LAYER_DEBUG = 12 --Debug层
__this.LAYER_MAX = 12

__this.idleThreshold = 180 --180秒没操作

__this.FRAME_MAP = {
    fight=24,
    main=24,
    copyUI=20,
    copy=20,
    back=2, --后台
    idle=10, --3分钟没操作，且不在战斗中
    default=24 --其他
}

--增加一个场景到场景管理器
function __this.insertScene( name, scene )
    scene:retain()
    scene.name = name
	__this.data[ name ] = scene
end

--获取层次
function __this.getLayer(layerNo)
    if not __this.layers[layerNo] then
        local node = UIFactory.getNode(__this.baseScene, 0, 0, layerNo)
        node:setTag(layerNo)
        node:setContentSize(visibleSize)
        __this.layers[layerNo] = node
    end
    return __this.layers[layerNo]
end

--设置屏蔽touch事件
function __this.setSceneTouch(value)
    local layer = __this.getLayer(__this.LAYER_LOCK)
    local mask = layer.touchMask
    if value then
        if mask then
            mask:removeFromParent()
        end
        return
    end
    if not mask then
        mask = UIFactory.getLayer(visibleSize.width, visibleSize.height)
        layer.touchMask = mask
        mask:retain()
    end
    layer:addChild(mask)
end

function __this.getBaseScene()
    return __this.baseScene
end

--获取场景
function __this.getCurrentScene()
    return __this.current_scene
end

function __this.getSceneName()
    return __this.current_scene and __this.current_scene.name
end

function __this.isSceneName( name )
    return __this.getSceneName() == name
end

--场景是否在堆栈
function __this.hasScene(name)
    for i = #__this.queue, 1, -1 do
        if #__this.queue[i] == name then
            return true
        end
    end
    return false
end

--初始化显示层次
local function initScene()
    if not __this.baseScene then
        local baseScene = cc.Scene:create()
        __this.baseScene = baseScene
        display.replaceScene(baseScene)
        for i = 1, __this.LAYER_MAX do
            __this.getLayer(i)
        end
        PopMgr.setWinLayer(__this.getLayer(__this.LAYER_WINDOW)) --窗口层
        PopMgr.setUpLayer(__this.getLayer(__this.LAYER_UP_WINDOW)) --更高层
        BackButton:init()
        __this.getLayer(__this.LAYER_BACK):addChild(BackButton) --返回按钮层
        local startPos = nil
        local function touchBeganHandler(touch, event)
            startPos = touch:getLocation()
            __this.resetIdle()
        end
        local function touchMovedHandler(touch, event)
            local pos = touch:getLocation()
            if not cc.pFuzzyEqual(pos, startPos, Config.FUZZY_VAR) then
                TipsMgr.hideTips()
            end
        end
        local function touchEndedHandler(touch, event)
            local newtime = DateTools.getTime()
            if TipsMgr.time and (newtime - TipsMgr.time) > 0.5 then
                TipsMgr.hideTips()
            end
            __this.resetIdle()
        end
        local layer = __this.getLayer(__this.LAYER_BACK)
        layer:setContentSize(visibleSize)
        UIMgr.registerScriptHandler(layer, touchBeganHandler, cc.Handler.EVENT_TOUCH_BEGAN, true)
        UIMgr.registerScriptHandler(layer, touchMovedHandler, cc.Handler.EVENT_TOUCH_MOVED, true)
        UIMgr.registerScriptHandler(layer, touchEndedHandler, cc.Handler.EVENT_TOUCH_ENDED, true)
        UIMgr.registerScriptHandler(layer, touchEndedHandler, cc.Handler.EVENT_TOUCH_CANCELLED, true)
        
        EventMgr.addListener(EventType.EnterBackground, __this.onEnterBackground)
        EventMgr.addListener(EventType.EnterForeground, __this.onEnterForeground)
    end
end

function __this.resetIdle()
    __this.lastTouchTime = DateTools.getTime()
    if __this.currentFPSName == "idle" then
        __this.setFrameRate(__this.getSceneName())
    end
end

function __this.checkIdle()
    local time = DateTools.getTime()
    if __this.lastTouchTime and time - __this.lastTouchTime > __this.idleThreshold then
        __this.setFrameRate("idle")
    end
end

--设置FPS
function __this.doSetFrameRate(name)
    local frame = __this.FRAME_MAP[name] or __this.FRAME_MAP["default"]
    cc.Director:getInstance():setAnimationInterval(1.0 / frame)
end

function __this.setFrameRate(name, delay)
    __this.currentFPSName = name
    if name == "back" or name == "fight" or name == "idle" then
        TimerMgr.removeTimeFun(__this.checkIdle)
    else
        __this.resetIdle()
        TimerMgr.addTimeFun(__this.checkIdle, __this.checkIdle)
    end
    __this.fps_timer = TimerMgr.killTimer(__this.fps_timer)
    if delay then
        -- 切换场景的时候改变帧率会导致闪屏，延迟3秒处理
        __this.fps_timer = TimerMgr.callLater(__this.doSetFrameRate, 3)
    else
        __this.doSetFrameRate()
    end
end

function __this.onEnterBackground(event)
    SoundMgr:pauseAllMusic()
    __this.setFrameRate("back")
end

function __this.onEnterForeground(event)
   SoundMgr:resumeAllMusic()
   __this.setFrameRate(__this.getSceneName())
end

local function closeOldScene()
    if __this.current_scene == nil then
        return
    end
    -- debug.showTime("closeOldScene_1_")
    local scene = __this.current_scene
    local name = scene.name
    __this.prev_scene_name = name -- 记录旧场景的名字
    __this.current_scene = nil
    PopMgr.removeAllWindow()
    PopMgr.removeAllWindow() --第二次关闭所有窗口
    for _, v in pairs( __this.getLayer(__this.LAYER_WINDOW):getChildren() ) do
        LogMgr.error("切换场景的时候，没有被关闭的窗口", v.winName)
    end
    for _, v in pairs( __this.getLayer(__this.LAYER_EFFECT):getChildren() ) do --清空特效
        v:removeFromParent()
    end
    if scene:getParent() then
        if scene.onClose ~= nil then
            scene:onClose()
        end
        scene:removeFromParent() --移除场景
    end
    
    -- LogMgr.system("离开场景：", name)
    ActionMgr.save( 'scene', string.format('close %s', name) )
    -- debug.showTime("closeOldScene_1_")
    -- debug.showTime("closeOldScene_2_")
    EventMgr.dispatch( EventType.SceneClose, name )
    -- debug.showTime("closeOldScene_2_")
end

local function showNewScene(isShow, ...)
    assert(__this.current_scene == nil, "上一个场景没有退出")
    if #__this.queue == 0 then
        return
    end
    local name = __this.queue[#__this.queue]
    local scene = __this.data[name]
    __this.current_scene = scene
    if isShow then
        __this.showCurrentScene(...)
    end
end

local function getSceneMusic( old_scene, new_scene )
    local old_music = nil
    local new_music = nil
    
    if old_scene then
        old_music = SoundMgr.getSceneMusic( old_scene.name )
    end
    
    if new_scene then
        new_music = SoundMgr.getSceneMusic( new_scene.name )
    end
    
    if not new_music then
        new_music = old_music
    end
    
    return old_music, new_music
end

local function doPushScene(name, isShow, ...)
    initScene() --初始化
    assert( __this.data[ name ] ~= nil, "enterScene: " .. name .. " not found" ) 
    if __this.isSceneName(name) then --就是当前的场景
        return
    end
    
    --获取背景音乐路径
    local old_music, new_music = getSceneMusic( __this.current_scene, __this.data[ name ] )
    closeOldScene() --清理旧场景
    table.insert( __this.queue, name )
    
    --释放音乐资源
    if old_music ~= new_music then
        SoundMgr.release()
    end
    
    showNewScene( isShow, ... ) --显示新场景
    
    --播放场景音乐
    if new_music then
        SoundMgr.playSceneMusic(__this.current_scene.name)
    end
end

function __this.showCurrentScene( ... )
    local scene = __this.current_scene
    if scene then
        assert( scene.onShow ~= nil, "scene must include onShow method!" )
        ActionMgr.save( 'scene', string.format('show %s', scene.name) )
        
        __this.getLayer(__this.LAYER_SCENE):addChild(scene)--添加场景
        debug.clearTime() --清理时间
        debug.showTime("showCurrentScene_1_")
        scene:onShow( ... )
        debug.showTime("showCurrentScene_1_")
        debug.showTime("showCurrentScene_2_")
        EventMgr.dispatch( EventType.SceneShow, scene.name )
        debug.showTime("showCurrentScene_2_")
        __this.setFrameRate(__this.getSceneName(), true)
    end
end

--压入场景，不显示
function __this.pushScene( name, ... )
    doPushScene(name, false, ...)
end

--进入场景
function __this.enterScene( name, ... )
    doPushScene(name, true, ...)
end

--退出场景
function __this.leaveScene( ... )
    if __this.current_scene ~= nil then
        if #__this.queue == 1 then -- 只有一个场景不能退出
            return
        end
        table.remove( __this.queue )
        --获取背景音乐路径
        local old_music, new_music = getSceneMusic( __this.current_scene, __this.data[__this.queue[#__this.queue]] )
        closeOldScene() --清理场景
        --释放音乐资源
        if old_music ~= new_music then
            SoundMgr.release()
        end
        showNewScene( true, ... ) --显示新场景
        --播放场景音乐
        if new_music then
            SoundMgr.playSceneMusic(__this.current_scene.name)
        end
    end
end

function __this.leaveCommon()
    if __this.isSceneName("common") then
        __this.leaveScene()
    else
        for i = #__this.queue, 1, -1 do
            if __this.queue[i] == "common" then
                table.remove(__this.queue, i)
                break
            end
        end
    end
end

local function checkLoginHandler( name )
    if ( name == 'main' and CopyData.checkClearance( 1071 ) ) or name == 'copyUI' then
        -- EventMgr.removeListener( EventType.SceneShow, checkLoginHandler )
        --恢复剧情
        GutMgr:sceneEnter( name )
    end

    if __this.isInduct == nil then
        if ( name ~= 'opening' ) then
        --恢复新手引导
            -- InductMgr:sceneEnter( name )

            LogMgr.log( 'login', '[login] 引导数据初始化\n' )
            InductMgr:initStart()            
            __this.isInduct = true
        end
    end

    EventMgr.dispatch( EventType.SceneShows, name )
end
EventMgr.addListener( EventType.SceneShow, checkLoginHandler )

EventMgr.addListener(EventType.UserLogout, function()
    __this.isInduct = nil
end)

Command.bind( 'scene enter', __this.enterScene )
Command.bind( 'scene leave', __this.leaveScene )
