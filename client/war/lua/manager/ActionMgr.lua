local __this = ActionMgr or {  data = { timer_id = 0, queue = {}, last_online_time = 0 } }
ActionMgr = __this

local function commit_action()
    --容错过滤
    if not gameData or not gameData.user or not gameData.user.simple then
        return
    end
    
    --20级以内发送行为记录
    if gameData.user.simple.team_level == nil or gameData.user.simple.team_level < 20 then
        local action_string = ''
        for key, var in pairs( __this.data.queue ) do
            action_string = action_string .. var .. '\n'
        end
    
        trans.send_msg('PQUserActionSave', { last_action = action_string } )
    end
    
    --发送 online 记录, 服务器每收到一个 PQSystemOnline 作为用户在线1分钟的记录
    local time = system.time_sec()
    if time > __this.data.last_online_time + 60 then
        __this.data.last_online_time = time;
        
        trans.send_msg( 'PQSystemOnline', {} )
    end
end

local function action_timer()
    TimerMgr.killTimer( __this.data.timer_id )
    __this.data.timer_id = 0
    
    if not trans or not trans.send_msg then
        return
    end
    
    commit_action()
end
function __this.save( module, text )
    local action_string = module .. ': ' .. text
    LogMgr.log( 'action', '[action] ' .. action_string )
    
    --维护队列
    if #__this.data.queue >= 10 then
        table.remove( __this.data.queue, 1 )
    end
    table.insert( __this.data.queue, #__this.data.queue + 1, action_string )
    
    --创建定时器
    if __this.data.timer_id ~= 0 then
        TimerMgr.killTimer( __this.data.timer_id )
        __this.data.timer_id = 0
    end
    
    --每2秒提交一次最后行为记录
    __this.data.timer_id = TimerMgr.startTimer(action_timer, 2, false)
end

EventMgr.addListener( 'enterBackground', function()
    commit_action()
end )
