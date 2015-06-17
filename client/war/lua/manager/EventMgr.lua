require "lua/manager/EventType.lua"
-- 自定义事件管理
local __this = EventMgr or {}
EventMgr = __this

local nameHandlerMap = {}

local function getHandlerMap(eventName)
	assert(eventName ~= nil, '事件名不能为空')
	local list = nameHandlerMap[eventName]
	if not list then
		list = {}
		nameHandlerMap[eventName] = list
	end
	return list
end

function __this.hasListener(eventName, handler)
	return getHandlerMap(eventName)[handler] ~= nil
end

--添加事件
--@param eventName EventType的常量
--@param handler 事件处理函数
--@param self 针对handler为“:”声明的成员函数，必须传入self用于回调
function __this.addListener(eventName, handler, self)
    getHandlerMap(eventName)[handler] = self or true
end

function __this.removeListener(eventName, handler)
	getHandlerMap(eventName)[handler] = nil
end

--派发事件
--@param eventName 事件名称
--@param data 事件处理函数的参数
function __this.dispatch(eventName, data)
	local list = getHandlerMap(eventName)
	for k, v in pairs(list) do
		if v == true then
			k(data, eventName)
		else
			k(v, data, eventName)
		end
	end
	return not table.empty(list)
end

--批量注册事件
--@param list evnetName, handler的列表
--params self 可选，针对成员函数必须传入self
function __this.addList(list, self)
    for k, v in pairs(list) do
        __this.addListener(k, v, self)
    end
end

--批量移除事件
function __this.removeList(list)
    for k, v in pairs(list) do
    	__this.removeListener(k, v)
    end
end
