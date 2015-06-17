-- Crreate By Hujingjiang --

Dictionary = {length = 0, content = nil}

Dictionary.new = function(self) 
	local o = {}   --创建新表 
	setmetatable(o,self) --新表的元表设置为原型表 
	self.__index = self --原型表的__index为原型表 
	return o
end

function Dictionary:create()
	local dic = Dictionary:new()
	dic.content = {} 
	return dic
end

function Dictionary:has(key)
	if nil ~= self.content[key] then
		return true
	end
	return false
end

function Dictionary:get(key)
	return self.content[key]
end

function Dictionary:add(key, value)
	if nil == self.content[key] then
		self.length = self.length + 1
	end
	self.content[key] = value
end

function Dictionary:remove(key)
	if nil ~= self.content[key] then
		local value = self.content[key]
		self.content[key] = nil
		self.length = self.length - 1
		return value
	end
	return nil
end

function Dictionary:getList()
	return self.content
end

function Dictionary:getLength()
	return self.length
end

function Dictionary:clear()
	for k, _ in pairs(self.content) do
		self.content[k] = nil
	end
	self.length = 0
end