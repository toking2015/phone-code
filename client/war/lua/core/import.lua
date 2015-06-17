--$Id$
local string=string
local table=table
local pairs=pairs

--使用方法Import("base/util.lua")
--代替Lua本身的module, require机制
_G._ImportModule = _G._ImportModule or {}
local _ImportModule = _G._ImportModule
local ModuleArray = {} --这个只是为了维护一个载入顺序，SystemStartup 函数希望能按Import的顺序执行

local function SafeImport(PathFile, Reload)
	local Old = _ImportModule[PathFile]
	if Old and (not Reload) then
		return Old
	end
    local func = nil
	local err = nil	
	
    if cc.Application:getInstance():getTargetPlatform() ~= kTargetAndroid then
        func, err = loadfile(PathFile)
    else
        local file_str = get_lua_str(PathFile)	
        func, err = loadstring(file_str)
    end
	
	--[[local func, err = loadfile(PathFile)
	if not func then
		return func, err
	end--]]

	if not Old then
		_ImportModule[PathFile] = {}
		local New = _ImportModule[PathFile]
		--设置原始环境
		setmetatable(New, {__index = _G})
		setfenv(func, New)()
		table.insert(ModuleArray, New)

		return New
	end
end

function Import(PathFile)
	--PathFile = CCFileUtils:sharedFileUtils():fullPathFromRelativePath(PathFile)
	PathFile = WRITE_PATH .. PathFile
	local Module, Err = SafeImport(PathFile, false)
	assert(Module, Err)

	return Module
end

function Class(PathFile)
	return Import(PathFile):getClass()
end


