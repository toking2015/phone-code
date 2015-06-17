local hasShowNotice = false
local isLogin = false
local canFrog = false
local aidText = nil
local loadingTips = nil
local WaitingKey = {}
local waitingString = nil
local waitingTimerId = nil --等待时间
local waitingSecond = nil
local disconnectTimerId = nil --等待时间
local disconnectSecond = nil
local justShowPreload = nil --是否刚刚显示了Preload，如果是，则下一帧才能移除
local isPreloadShow = nil --Preload是否处于显示状态
local sound_timer = nil
local sound_id = nil

Command.bind('loading server_list', function()
    local function onHttpError()
        showMsgBox("获取服务器列表失败")
    end
	local function onHttpData(data)
		local preLoad = PreLoadUI:getInstance(true)
		if preLoad then --移除loading界面
			safeRemoveFromParent(preLoad)
		end
        data = seq.stream_to_string( data )
        local json = safeDecodeJson( data )
        if json == nil or json.data == nil then
            onHttpError()
            return
        end
        local jsonData = {}
        for key, var in ipairs(json.data) do 
            local id = tonumber( var[1], 10 )
            local index = tonumber( var[4], 10 )
            
            if index == nil or index == 0 then
                index = id
            end          
        	local data = 
        	{
        	   id      = id,
        	   name    = var[2],
        	   host    = var[3],
        	   port    = index + 17000
        	}
        	table.insert(jsonData, data)
        end
        
		LoadingData.serverList = jsonData
		local str = LocalDataMgr.load_string(0, 'loading')
		if str and str ~= '' then
			local data = safeDecodeJson(str)
			local serverId = data.serverId
			LoadingData.lastServer = gameData.findArrayData(jsonData, 'id', serverId)
			LoadingData.account = data.account
		end
		LoadingData.lastServer = LoadingData.lastServer or jsonData[#jsonData]
		commit_device_log(14) -- 显示登录界面
		--显示公告
		if not hasShowNotice and NoticeData.getNoticeStr() and NoticeData.getNoticeStr() ~="" then
            hasShowNotice = true
			Command.run( 'ui show', 'NoticeUI', PopUpType.SPECIAL, false, 10)
		end
        Command.run('loading show login')
	end
	local filename = cc.FileUtils:getInstance():fullPathForFilename("server_list.json")
    if filename ~= nil and filename ~= '' then
    	local stream = seq.read_stream_file( filename )
    	if stream then
    		 onHttpData(stream)
    		return
    	end
    end
	URLLoader.new('http://' .. Config.data.host .. '/get_server_list.php?platform=' .. Config.platform.name, onHttpData, nil, onHttpError)
end)

local currentName = nil

local function stopSound()
    sound_id = SoundMgr.stopEffect(sound_id)
    sound_timer = TimerMgr.killTimer(sound_timer)
end

local function playSound()
    stopSound()
    sound_id = SoundMgr.playEffect("sound/Ambiences/ambient_denglu.mp3")
    sound_timer = TimerMgr.startTimer(function()
        playSound()
    end, 9)
end

local function changeWin(name)
    if currentName == name then
        return
    end
	if name then
        if not sound_id then
            playSound()
        end
        local bg = PreLoadBg:getInstance()
        if not bg:getParent() then
            local layer = SceneMgr.getLayer(SceneMgr.LAYER_LOADING)
            layer:addChild(bg)
        end
        if name == "PreLoadUI" then
            PreLoadBg:getInstance():changeLoading(true)
            local layer = SceneMgr.getLayer(SceneMgr.LAYER_LOADING)
            local preLoad = PreLoadUI:getInstance()
            layer:addChild(preLoad)
        else
            PreLoadBg:getInstance():changeLoading(false)
            PopMgr.popUpWindow(name, true, nil, true)
        end
	else
        stopSound()
    end
	if currentName then
		if currentName == "PreLoadUI" then
            local preLoad = PreLoadUI:getInstance(true)
            if preLoad then
                preLoad:removeFromParent()
            end
        else
		  PopMgr.removeWindowByName(currentName)
        end
	end
	currentName = name
end

Command.bind('loading show login', function()
	changeWin('LoginUI')
end)

Command.bind('loading show register', function()
	changeWin('RegisterUI')
end)

Command.bind('loading show switch', function()
	changeWin('ServerUI')
end)

Command.bind('loading show preload', function()
    isPreloadShow = true
    justShowPreload = true
    PopMgr.setWinNameLayer('PreLoadUI', SceneMgr.LAYER_LOADING)
    changeWin('PreLoadUI')
    TimerMgr.runNextFrame(function()
        justShowPreload = nil
        if not isPreloadShow then
            Command.run("loading close")
        end
    end)
end)

local tipsList = {
    "战队达到20级可以手工制作装备，在拍卖行卖给其他玩家",
    "装备分为板甲、锁甲、皮甲、布甲，适用于不同的英雄",
    "扫荡精英副本可以获得英雄灵魂石，用于招募和升星英雄",
    "通关普通副本可以获得英雄技能书和天赋书，用于英雄进阶",
    "在竞技场商店可以获得新的图腾",
    "战队25级开启十字军试炼，产出大量图腾充能石",
    "战队30级开启大墓地，产出海量金币和神符",
    "图腾的被动属性对站在图腾后方的英雄生效",
    "升级图腾可以加大英雄的觉醒几率",
    "图腾属性升满后可以升星"
}

Command.bind("loading get tips", function()
    return tipsList[MathUtil.random(1, #tipsList)]
end)

Command.bind('loading fake percent', function(percent)
	local preLoad = PreLoadUI:getInstance(true)
    if preLoad then
    	percent = percent or preLoad:getPercent() + 9
        if percent == 0 then
            loadingTips = Command.run("loading get tips")
        end
    	Command.run("loading set percent", percent, loadingTips)
    end
end)

Command.bind("loading set percent", function(percent, str1, str2)
    local preLoad = PreLoadUI:getInstance(true)
    if preLoad then
        preLoad:setPercent(percent, 100, str1, str2)
    end
end)

Command.bind('loading close', function()
    isPreloadShow = nil
    if justShowPreload then
        return
    end
	changeWin(nil)
    local preLoad = PreLoadUI:getInstance(true)
    if preLoad then
        preLoad:dispose()
    end
    local bg = PreLoadBg:getInstance(true)
    if bg then
        safeRemoveFromParent(bg)
        bg:dispose() --删除背景
    end
	-- SoundMgr.stopMusic()
end)

local function removeAID()
    if aidText then
        aidText:removeFromParent()
        aidText = nil
    end
end

local function showAID(aid, autoHide)
    if not aidText then
        local layer = SceneMgr.getLayer(SceneMgr.LAYER_DEBUG)
        local text = UIFactory.getText("AID:"..aid, layer, 10, visibleSize.height - 30, 20, cc.c3b(0xff, 0xff, 0xff), nil, nil, 100)
        text:setAnchorPoint(0, 0)
        aidText = text
    end
    if autoHide then
        performWithDelay(aidText, removeAID, 0.5)
    end
end

--服务器登录回调
local function __login_server_callback(json)
    if json.code ~= 0 then
        changeWin(nil)
        if json.code == 10 then
            trans.base.disconnect()
            showMsgBox( "[image=alert.png][font=ZH_10]" .. json.msg .. "[btn=one]confirm.png")
            Command.run("loading show login")
            Command.run("loading login enable", true)
        elseif json.code == 17 then
            Command.run("ui show", "ActivationUI", PopUpType.SPECIAL, true)
        elseif json.code == 19 or json.code == 20 then
            EventMgr.dispatch(EventType.ActivationResult, json.code)
        else
            showMsgBox( "[image=alert.png][font=ZH_10]" .. "服务器尚未开启, 请稍后再试" .. "[btn=one]confirm.png")
            Command.run("loading show login")
            Command.run("loading login enable", true)
            LogMgr.error( 'device_login failure - ' .. json.code .. ' : ' .. (json.msg or '') )
        end
        if json.data and json.data.aid then
            showAID(json.data.aid)
        end
        
        Command.run('set loading tips', '')
        return
    end
    
    inf.activated = true
    Command.run("ui hide", "ActivationUI")
    Command.run('loading show preload')
    Command.run("loading fake percent")
    Config.login_data = json.data
    
    VXinYouMgr.user_login()
    VXinYouMgr.ad_login()

    trans.base.send('PQSystemLogin', { role_id = json.data.rid, session = json.data.session }, true)
    
    Command.run('set loading tips', '正在获取用户数据.')
end

--登录到游戏服务器
Command.bind("loading login server", function(act_code)
    removeAID()
    local uid = inf.uid
    local token = inf.token
    local channel = inf.channel
    LogMgr.log( 'inf', 'inf.login: ' .. uid .. ' - ' .. token .. '\n' )
    Config.server = LoadingData.lastServer
    Command.run('loading show preload')
    Command.run("loading fake percent", 0)
    LocalDataMgr.save_string(0, 'loading', Json.encode({serverId=LoadingData.lastServer.id, account=LoadingData.account}))
    commit_device_log(16) -- 开始连接服务器
    trans.base.connect(LoadingData.lastServer.host, LoadingData.lastServer.port)
    --[[
    ping 包发送现在依赖用户成功登录后的 order 值, 不能在这里开始触发 ping 包发送
    Command.run("system ping") --开始发ping
    --]]
    --登录URL
    local url = 'http://' .. Config.data.host .. '/platform/' .. Config.platform.name .. '/device_login.php'
        .. '?uid=' .. uid .. '&token=' .. token .. '&group=' .. Config.data.group 
        .. '&server_id=' .. Config.server.id .. '&channel=' .. (channel or '') .. '&activation_code=' .. (act_code or '')

    local function onError()
        showMsgBox( "[image=alert.png][font=ZH_10]" .. "连接服务器失败, 请稍后再试" .. "[btn=one]confirm.png")
        Command.run("loading show login")
        Command.run("loading login enable", true)
    end
    local function onComplete(content)
        Command.run("loading fake percent")
        content = seq.stream_to_string( content )
        local json = safeDecodeJson( content )
        if json == nil then
            onError()
            Command.run('set loading tips', '验证失败, 请稍后再试.')
            return
        end
        __login_server_callback( json )
    end
    --请求登录
    URLLoader.new(url, onComplete, nil, onError)
end)

--inf 登录接口回调
local function __login_callback(msg, uid, token, channel)
	isLogin = true
    --这里一定要 runNextFrame, 因为直接 callback 在另一个异步过程
    TimerMgr.runNextFrame( function(msg, uid, token, channel)
        if msg == 'succeed' then
            commit_device_log(15) -- 用户验证成功(平台对接后使用)
            inf.uid = uid
            inf.token = token
            inf.channel = channel
            Command.run("loading login server")
            return
        end

        if msg and msg ~= "" then
            inf.msg_progress( msg )
        end
        Command.run('set loading tips', '')
        Command.run("loading login enable", true)
    end, msg, uid, token, channel )
    
    Command.run('set loading tips', '正在验证用户信息.')
end

Command.bind('loading login', function(channel)
    --inf 多登录接口兼容
    if state.has( inf.platform_flags(), inf.f_login_custom ) then
        --自定义登录
        inf.login_custom( __login_callback )
    elseif state.has( inf.platform_flags(), inf.f_login_multi ) then
        inf.login_custom( __login_callback, channel )
    else
        --帐号密码登录        
        local name = LoadingData.account.id
        if name == nil or name == '' then
            TipsMgr.showError("账号不能为空")
            Command.run("loading login enable", true)
            return true
        end
        
        inf.login( name, '登录密码', __login_callback )
    end
    
    Command.run('set loading tips', '正在努力登录中.')
end)

Command.bind("loading register", function()
    
end)

--游戏里面切换小号
Command.bind("loading switch", function(...)
    Command.run("loading logout")
    __login_callback(...)
end)

Command.bind("loading logout", function()
	if isLogin == false then
		return
	end
	isLogin = false
    trans.lock_queue(false) --解锁协议
    FightDataMgr:releaseAll() --清空战斗
    FightAnimationMgr.gut = nil -- 战斗剧情缓存清理
    while not SceneMgr.isSceneName( "opening" ) do
        Command.run("scene leave")
    end
    Command.run("system logout")
    WaitingKey = {}
    Command.run("loading wait hide", "")
    canFrog = false
    EventMgr.dispatch(EventType.UserLogout) --派发登出事件
    for k,v in pairs(gameData.user) do --清空数据
        gameData.user[k] = {}
    end
    local bg = PreLoadBg:getInstance()
    if not bg:getParent() then
        local scene = SceneMgr.getCurrentScene()
        scene:addChild(bg, 100)
    end
    Command.run('loading show login')
end)

local function onWaitingHandler()
    waitingSecond = waitingSecond + 1
    ActionMgr.save('WaitingUI', string.format('waiting %s %s', waitingString, waitingSecond))
    if waitingSecond >= 10 then  -- 等待大于十秒发出派送
        EventMgr.dispatch(EventType.LoadOverTime)
    end  
end

--设置Key可以保证不被其他人关闭
Command.bind('loading wait show', function(key, delay)
    if key then
        WaitingKey[key] = true
    else
        error("wait key must be none nil")
    end
    waitingString = table.concat(table.keys(WaitingKey), " ")
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_LOADING)
    if not layer.waitWin then
        layer.waitWin = WaitingUI.new()
        popUpCenter(layer.waitWin)
    end
    if not layer.waitWin:getParent() then
        ActionMgr.save('WaitingUI', 'show '..key)
        TimerMgr.killTimer(waitingTimerId)
        waitingSecond = 0
        waitingTimerId = TimerMgr.startTimer(onWaitingHandler, 1)
        layer:addChild(layer.waitWin)
        layer.waitWin:onShow(delay)
        BackButton:pushNone(WaitingUI)
    end
end)

Command.bind('loading wait hide', function(key)
    if key then
        WaitingKey[key] = nil
    else
        error("wait key must be none nil")
    end
    waitingString = table.concat(table.keys(WaitingKey), " ")
    if table.empty(WaitingKey) then
        local layer = SceneMgr.getLayer(SceneMgr.LAYER_LOADING)
        if layer.waitWin then
            TimerMgr.killTimer(waitingTimerId)
            ActionMgr.save('WaitingUI', string.format('hide %s %s', waitingString, waitingSecond))
            layer.waitWin:onClose()
            layer.waitWin:removeFromParent()
            layer.waitWin = nil
            BackButton:pop(WaitingUI)
        end
    end
end)

Command.bind("loading can frog", function(val)
    canFrog = val
    if val and not trans._isConnected then
        Command.run("loading disconnect show")
    end
end)

local function onDisconnectHandler()
    disconnectSecond = disconnectSecond + 1
    ActionMgr.save('DisconnectUI', 'waiting '..disconnectSecond)
end

Command.bind('loading disconnect show', function()
    if not canFrog then
        return
    end
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_LOADING)
    if not layer.disconnect then
        layer.disconnect = DisconnectUI.new()
        popUpCenter(layer.disconnect)
    end
    if not layer.disconnect:getParent() then
        ActionMgr.save('DisconnectUI', 'show')
        TimerMgr.killTimer(disconnectTimerId)
        disconnectSecond = 0
        disconnectTimerId = TimerMgr.startTimer(onDisconnectHandler, 1)
        layer:addChild(layer.disconnect)
        layer.disconnect:onShow()
        BackButton:pushNone(DisconnectUI)
    end
end)

Command.bind('loading disconnect hide', function()
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_LOADING)
    if layer.disconnect then
        TimerMgr.killTimer(disconnectTimerId)
        ActionMgr.save('DisconnectUI', 'hide'..disconnectSecond)
        layer.disconnect:onClose()
        layer.disconnect:removeFromParent()
        layer.disconnect = nil
        BackButton:pop(DisconnectUI)
    end
end)
