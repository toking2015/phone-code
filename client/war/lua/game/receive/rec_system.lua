local err_map = nil 
trans._isConnected = true --默认假设连接上
trans.call.PRSystemErrCode = function(msg)
	if err_map == nil then
        err_map = {}
        for key, value in pairs(trans.err) do
            err_map[ value ] = key
        end
    end
    
    local key = err_map[ msg.err_no ]
    if key ~= nil then
        if not EventMgr.dispatch( key, msg.err_desc ) then
            LogMgr.log( 'error',"PRSystemErrCode: " .. key .. " - " .. msg.err_desc)
        end
    else
        LogMgr.log( 'error',"no found the erro key, err_no:"..msg.err_no..", err_desc:"..msg.err_desc)        
    end
end

local last_op_time = os.time()
local timer_ping = nil
local timer_online = nil

trans.call.PRSystemLogin = function(msg)
    Command.run("loading fake percent")
    commit_device_log(18) -- 登录成功
    
    gameData.setServerTime(msg.server_time, msg.minuteswest, msg.dsttime, msg.open_time)
    
    -- 保存用户session
    trans.session = { role_id = msg.role_id, session = msg.session, client_order = 1, server_order = 1, action = 1 }
    LogMgr.log( 'debug', "Login role_id:", msg.role_id );

    -- 封装 send_msg 函数, 每个协议请求都需要补全用户 session 信息
    -- 除了 PQSystemLogin 协议外都可以通地 send_msg 函数发送协议请求
    trans.send_msg = function( name, object )
        object.role_id = trans.session.role_id
        object.session = trans.session.session
        object.order = trans.session.client_order
        object.action = trans.session.action

        trans.session.client_order = trans.session.client_order + 1
        trans.session.action = trans.session.action + 1

        trans.base.send( name, object )
        
        last_op_time = os.time()
    end
    
    --注册全服广播频道
    trans.send_msg( 'PQBroadCastSet', { set_type = trans.const.kObjectAdd, broad_cast = trans.const.kCastServer } )
    
    --心跳包
    if not timer_ping then
        timer_ping = TimerMgr.startTimer(function()
            Command.run("system ping")
        end, 6 )
    end    
    
    --锁屏检查
    --[[
    TimerMgr.startTimer(function()
        local wait_time = os.time() - last_op_time
        if wait_time < 180 then
            system.setforbid()
        else
            system.setauto()
        end
    end, 10 )
    --]]
end

local last_ping_time = 0
Command.bind("system ping", function()
    if trans._isConnected and trans.send_msg then
        local time_now = system.time_sec()
        
        if time_now > last_ping_time + 5 then
            last_ping_time = time_now
            
            trans.send_msg( 'PQSystemPing', {} )
        end
    end    
end)

Command.bind("system logout", function()
    inf.logout()
    Command.run("system disconnect")
    timer_ping = TimerMgr.killTimer(timer_ping)
    timer_online = TimerMgr.killTimer(timer_online)
end)

trans.call.PRSystemNetConnected = function(msg)
    trans._isConnected = true
    if trans.send_msg ~= nil then
        trans.send_msg( 'PQSystemSessionCheck', {} )
        
        LogMgr.log( 'net', '网络重连成功' )
    else
        commit_device_log(17) -- 连接服务器成功
        LogMgr.log( 'net', '网络连接成功' )
    end
    Command.run('loading disconnect hide')
end

trans.call.PRSystemNetDisconnected = function(msg)
    trans._isConnected = false
    Command.run('loading disconnect show')
end

trans.call.PRSystemSessionCheck = function()
    LogMgr.log( 'net', '网络重连有效性检查通过' )
end

trans.call.PRSystemPing = function(msg)
    if msg.server_time ~= 0 and math.abs(msg.server_time - gameData.getServerTime()) > 18 then --时间差距过大，重设时间
        local time = gameData.time
        gameData.setServerTime(msg.server_time, time.minuteswest, time.dsttime, time.open_time)
    end
end

--公告接收
trans.call.PRSystemPlacard = function(msg)
    PaomaData.receiveData(msg)
end 

trans.call.PRSystemKick = function()
    showMsgBox( "[image=alert.png][font=ZH_10]" .. '你已被管理员强制下线!' .. "[btn=one]confirm.png", system.exit)
end