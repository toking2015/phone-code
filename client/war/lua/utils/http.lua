--[[
--@data:            bytes(stream)结构
--@cur_size:        当前加载的字节数
--@max_size:        数据段最大字节数( 可能为0, 某些情况下 max_size == 0 )
http.request
( 
    'http://www.baidu.com', 
    function(data, cur_size, max_size)
        if cur_size ~= max_size then
            return
        end
    end,
    "GET"
)
--]]

--初始化对象
local __this = http
if __this == nil then
    __this = {}
end
__this.__global_index = 1
__this.__data = {}
--__this.__row_request

--请求函数
function __this.request( url, call, method, stream )
    local index = __this.__global_index
    __this.__global_index = __this.__global_index + 1
    
    __this.__row_request( url, tostring(index), method, stream )
    
    __this.__data[ index ] = { url = url, call = call }
end

--底层返回函数
function __this.__row_call( index, data, cur_size, max_size )
    local info = __this.__data[ tonumber(index,10) ]
    if info == nil or info.call == nil then
        return 
    end
    
    info.call( data, cur_size, max_size )
end

local function decodeURI_algorithm(h)
    return string.char(tonumber(h, 16))
end
function __this.decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', decodeURI_algorithm)
    return s
end

local function encodeURI_algorithm(c)
    return string.format("%%%02X", string.byte(c))
end
function __this.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", encodeURI_algorithm)
    return string.gsub(s, " ", "+")
end

http = __this
