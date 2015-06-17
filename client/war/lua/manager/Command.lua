--[[
命令行管理器 -- 黄少卿
主要用于封装用户行为操作, 例如: 升级建筑、查物其它用户进行交互等，均通过 Command.run 触发相关行为
命令行参数规则如下:
[系统名(小写字母)] [行为(小写字母)] [参数1] [参数2] [参数3]
chat send "hello world!"
--]]
local __this = Command or { __map = {} }
Command = __this

local function __find_node( cmd )
    local list = string.split( cmd, ' ' )
    local __map = __this.__map
    local params = {}
    local cmd = ""
    for i = #list, 1, -1 do
        local cmd = table.concat(list, ' ')
        local _call = __map[cmd]
        if _call ~= nil then
            return _call, params
        end
        table.insert(params, 1, table.remove(list))
    end
    return nil
end

--[[
绑定命令simple:
Command.bind( "chat send", 
    function( text )
        trans.send( { cmd = "PQChatContent", content = text } )
        return true
    end
)
--]]
function __this.bind( cmd, call )
    assert( type(cmd) == 'string' and cmd ~= '' )
    __this.__map[cmd] = call
end

--[[
解除命令绑定
]]
function __this.unbind(cmd)
    assert( type(cmd) == 'string' and cmd ~= '' )
    __this.__map[cmd] = nil
end

--[[
调用方式simple:
不对参数进行类型转换
if Command.run( "chat send", "Hello world!" ) then
    LogMgr.log( 'debug', "chat send : hello world!" )
end
--]]
function __this.run( cmd, ... )
    assert(type(cmd) == 'string' and cmd ~= '')
    local __node = __this.__map[cmd]
    assert(__node ~= nil and type( __node ) == 'function', cmd .. ' 命令没有绑定处理函数')
    return __node( ... )
end

--[[
调用方式simple:
if Command.run_string( "chat send 'Hello world!'" ) then
LogMgr.log( 'debug', "chat send : hello world!" )
end
--]]
function __this.parse( cmd )
    if type(cmd) ~= 'string' or cmd == '' then
        return
    end
    local __node, params = __find_node( cmd )
    __this.__last_call = __node
    if __node == nil or type( __node ) ~= 'function' then
        LogMgr.log( 'error', 'Command parse error: ' .. cmd )
        return
    end
    local call = loadstring(string.format("return Command.__last_call(%s)", table.concat(params, ",")))
    return call()
end
