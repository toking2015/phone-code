local __this = LogMgr or {  data = { }, cache = { fight = '' } }
LogMgr = __this

function __this.open( module )
    __this.data[ module ] = true
end

function __this.close( module )
    __this.data[ module ] = nil
end

local commit_count = 0
function __this.log( module, ... )
    local text = string.format(...)
    if __this.data[ 'all' ] or __this.data[ module ] or ( module == 'action' and Config.is_debug() ) then
        print(module, ... )
        
        --if Config.is_debug() and writable.append then
        --    writable.append( 'log.txt', text .. "\r\n" )
        --end
    end
    
    if module == 'error' or module == 'crash' then
        if commit_count < 10 then
            commit_count = commit_count + 1
            
            commit_error_log( text )
        end
    end
    
    if __this.cache[ module ] ~= nil then
        __this.cache[ module ] = __this.cache[ module ] .. text .. '\n'
    end
    
    if Config.is_debug() then        
        if (__this.data[ module ] and module == 'time') or module == 'error' or module == 'crash' then
            pcall(Command.run, 'logviewer', ...)
        end
    end
    
    --这是返回给C++逻辑, 确认函数调用成功
    return true
end

function __this.get_cache_log( module )
    return __this.cache[ module ]
end

function __this.clear_cache_log( module )
    __this.cache[ module ] = ''
end

function __this.debug( ... )
    __this.log( 'debug', ... )
end

function __this.info( ... )
	__this.log( 'info', ...)
end

function __this.error( ... )
    __this.log( 'error', ... )
end

function __this.system( ... )
	__this.log( 'system', ...)
end

--定时每秒向 cpp 层获取 log 信息, cpp 直接调用 LogMgr.log 输出可能会出现异线程调用导致崩溃
if system.cpp_log_progress then
    local function cpp_log_timer()
        --cpp_log_progress 会调用 LogMgr.log 接口
        system.cpp_log_progress()
    end
    TimerMgr.startTimer( cpp_log_timer, 1, false)
end

__this.open( 'crash' )
__this.open( 'error' )
--__this.open( 'font' )
--__this.open( 'login' )
--__this.open( 'inf' )