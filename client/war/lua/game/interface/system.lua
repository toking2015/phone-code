interface = interface or {}
--系统
local isLock = false
local noLockMap = {
	PRSystemPing = true,
	PRChatContent = true, -- 聊天不锁
	PRMailData = true, -- 邮件不锁
	PRMailDataList = true, -- 一键邮件操作
	PRFriendChatContent = true, -- 好友聊天
	PRChatSound = true  -- 声音聊天
}

local timeoutSec = 30 --超时秒数
--判断超时重发的协议
local timeoutMap = {
	PQCopyRefurbish="PRCopyRefurbish",
	PQSystemLogin="PRSystemLogin",
	PQFormationSet="PRFormationList",
	PQTeamLevelUp="PRTeamLevelUp"
}
local returnMap = {} --转置
for k,v in pairs(timeoutMap) do
	returnMap[v] = k
end
local msgCache = {} --Q=>{timer_id=0, msg=nil}
local callbackMap = {}
local lockMsgName = {} --锁住的协议名字
local lockMsgQueue = {} --锁住的协议列表

--发送有回调函数的消息
function trans.sendReturnMsg(name, msg, callback)
	callbackMap[name] = callback
	trans.sentTimeoutMsg(name, msg)
end

--发送超时重发的消息
function trans.sentTimeoutMsg(name, msg, isBase, notFirst)
	trans.removeTimeoutMsg(name) --先移除
	if timeoutMap[name] then
		local function timeoutSend()
			trans.sentTimeoutMsg(name, msg, isBase, true)
		end
		msgCache[name] = {msg=msg}
		msgCache[name].timer_id = TimerMgr.callLater(timeoutSend, timeoutSec)
	end
	if notFirst and not trans._isConnected then
		return
	end
	if isBase then
		trans.base.send(name, msg)
	else
		trans.send_msg(name, msg)
	end
end

function trans.removeTimeoutMsg(name)
	local obj = msgCache[name]
	if obj then
		msgCache[name] = nil
		TimerMgr.killTimer(obj.timer_id)
	end
end

function trans.removeTimeoutMsgByR(rname)
	local name = returnMap[rname]
	if name then
		trans.removeTimeoutMsg(name)
	end
end

--下一帧发送协议
function trans.sendNextFrame(...)
	TimerMgr.runNextFrame(trans.send_msg, ...)
end

--是否锁住了某个协议 --锁协议做在客户端，这里全部返回false
--@param name 协议名称
function trans.isLockMsg(name)
	return false
end

function trans.isLockMsgImpl(name) --实际处理锁协议的地方
	trans.removeTimeoutMsgByR(name)
	if noLockMap[name] then
		return false
	end
	return isLock
end

--不要在协议里面处理lock_queue(false)
function trans.lock_queue(lock)
	isLock = lock
	if not lock then
		while #lockMsgName > 0 do
			if isLock then --在处理的中间又锁住协议了
				return
			end
			interface.progressMsg(lockMsgName[1], lockMsgQueue[1])
			table.remove(lockMsgName, 1)
			table.remove(lockMsgQueue, 1)
		end
	end
end

--设置某个协议是否在锁住的时候例外
function trans.setMsgExcept(name, except)
	noLockMap[name] = except or nil
end

Command.bind("system disconnect", function()
	trans.base.disconnect()
end)

local msg_queue = {}
local msg_filter = 
{ 
    PRSystemPing = true,
    PRSystemSessionCheck = true,
    PRSystemNetConnected = true,
    PRSystemNetDisconnected = true
}

local msg_timer_id = 0
trans.call.OnListenMsg = function( name, msg )
    --数据包序列化检查
    if msg.order ~= nil and msg.order ~= 0 then
        --未初始化容错, 存在收到 PRSystemLogin 前先收到其它逻辑协议
        if not trans.session or not trans.session.server_order then
            return
        end
    
        --忽略重复数据包
        if msg.order < trans.session.server_order then
            return
        end
        
        --请求数据包重发
        if msg.order > trans.session.server_order then
            trans.base.send( 'PQSystemResend', 
            {
                role_id = trans.session.role_id,
                session = trans.session.session,
                server_order = trans.session.server_order
            })
            return
        end
        
        trans.session.server_order = trans.session.server_order + 1
    end

    if trans.isLockMsgImpl(name) then
    	table.insert(lockMsgName, name)
    	table.insert(lockMsgQueue, msg)
    	return
    end
    interface.progressMsg(name, msg)
end

function interface.progressMsg(name, msg)
    --获取协议监听函数
    local call = trans.call[ name ]
    if call ~= nil then
        if Config.data.delay ~= nil and Config.data.delay > 0 then
            if msg_timer_id <= 0 then
                msg_timer_id = TimerMgr.startTimer( function()
                    if #msg_queue > 0 then
                        msg_queue[1]()
                        table.remove( msg_queue, 1 )
                    end
                end, Config.data.delay, false )
            end
            
            --延迟执行
            if not msg_filter[ name ] then
                table.insert( msg_queue, #msg_queue + 1, function()
                    print( 'later run: ' .. name )
                    interface.call( call, name, msg )
                end )
                
                return
            end
        end
        
        interface.call( call, name, msg )
    end
end

function interface.call( call, name, msg )
	call( msg )
	local oname = returnMap[name]
    if callbackMap[oname] then --协议注册函数回调
		callbackMap[oname]()
		callbackMap[oname] = nil
	end
end