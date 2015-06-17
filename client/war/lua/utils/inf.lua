local _this = inf
_this.uid = ""
_this.token = ""
_this.activated = false --是否已经激活

local msgs = 
{
    error_init = function()
        showMsgBox( "[image=alert.png][font=ZH_10]" .. "初始化错误, 请与客服联系" .. "[btn=one]confirm.png", system.exit)
        return false
    end,
    
    error_timeout = function()
        showMsgBox( "[image=alert.png][font=ZH_10]" .. "响应超时, 请稍后再试 " .. "[btn=one]confirm.png", nil)
        return false
    end
}
_this.msg_progress = function(msg)
    local call = msgs[ msg ]
    if call ~= nil then
        return call()
    end

    showMsgBox( "[image=alert.png][font=ZH_10]" .. "处理失败  - " .. msg .. "[btn=one]confirm.png", nil)    
    return false
end

--窗口打开
_this.onOpen = function(name)
end

--窗口关闭
_this.onClose = function(name)
    if name == 'login' then
        PopMgr.getWindow('LoginUI').setLoginEnable(true)
    end
end

EventMgr.addListener( EventType.UserDataLoaded, function()
    local object = 
    {
        event_type = EventType.UserDataLoaded,
        sid = Config.server.id,
        sname = Config.server.name,
        aid = Config.login_data.aid .. '',
        rid = gameData.id,
        rname = gameData.user.simple.name,
        level = gameData.user.simple.team_level,
        vip_level = gameData.user.simple.vip_level,
        host = Config.data.host,
        platform = Config.platform.name
    }

    _this.setup( Json.encode( object ) )
end )

EventMgr.addListener( EventType.InfEnterServer, function()
    _this.setExtData("enterServer")
end )

EventMgr.addListener( EventType.InfCreateRole, function()
    _this.setExtData("createRole")
end )

EventMgr.addListener( EventType.InfLevelUp, function()
    _this.setExtData("levelUp")
end )

_this.setExtData = function( _type )
    local object = 
    {
        _id = _type,
        zoneId = Config.server.id,
        zoneName = Config.server.name,
        roleId = gameData.id,
        roleName = gameData.user.simple.name,
        roleLevel = gameData.user.simple.team_level,
        vip = gameData.user.simple.vip_level,
        balance = gameData.user.coin.money,
        partyName = "无帮派"
    }
    _this.doSetExtData( Json.encode( object ) )
end
