--对象池，不支持自动创建对象，需要手动disposeObject
local __this = class("Pool", {})

function __this:ctor()
    self.pool = {}
    self.count = 0
end

function __this:getSize() --@return 对象池的对象个数
    return self.count
end

function __this:getArray(name)
    local result = self.pool[name]
    if (result == nil) then
        result = {}
        self.pool[name] = result
    end 
    return result
end

function __this:getObject(name)
    local ary = self:getArray(name)
    if (#ary > 0) then
        local obj = table.remove(ary)
        self.count = self.count - 1
        return obj
    end
    return nil
end

function __this:disposeObject(name, obj)
    local ary = self:getArray(name)
    table.insert(ary, obj)
    self.count = self.count + 1
end

--释放对象的引用
function __this:clear()
    for name,ary in pairs(self.pool) do
        self.pool[name] = nil
    end
    self.count = 0
end

Pool = __this