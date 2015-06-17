-- class $Id$
--基础类库

--获取一个class的父类
function Super(TmpClass)
	return TmpClass.__SuperClass
end

--判断一个class或者对象是否
function IsSub(clsOrObj, Ancestor)
	local Temp = clsOrObj
	while  1 do
		local mt = getmetatable(Temp)
		if mt then
			Temp = mt.__index
			if Temp == Ancestor then
				return true
			end
		else
			return false
		end
	end
end

--和 AttachToClass 相对应
function GetObjClass(Obj)
	local mt = getmetatable(Obj)
	if mt then
		return mt.__index
	end
end

--使用metatable方式继承
function InheritWithMetatable(Base, o)
	o = o or {}
	setmetatable(o, {__index = Base})
	o.__SuperClass = Base
	return o
end

--使用Copy方式实现继承，默认继承方式
function InheritWithCopy(Base, o)
	o = o or {}

	--没有对table属性做深拷贝，如果这个类有table属性应该在init函数中初始化
	--不应该把一个table属性放到class的定义中

	if not Base.__SubClass then
		Base.__SubClass = {}
		setmetatable(Base.__SubClass, {__mode="v"})
	end
	table.insert(Base.__SubClass, o)

	for k, v in pairs(Base) do
		if not o[k] then
			o[k]=v
		end
	end
	o.__SubClass = nil
	o.__SuperClass = Base

	return o
end	

