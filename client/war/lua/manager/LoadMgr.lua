-- create by Live --
local __this = LoadMgr or {}
LoadMgr = __this

textureCache = cc.Director:getInstance():getTextureCache()
spriteFrameCache = cc.SpriteFrameCache:getInstance()
armatrueMgr = ccs.ArmatureDataManager:getInstance()

__this.SCENE = 1
__this.WINDOW = 2
__this.MODEL = 3 --针对角色的形象特殊处理
__this.MANUAL = 4 --手动控制

--路径--loadType--loadName，释放的时候需要判断路径对应的table是否为空
local PathMap = {image={}, plist={}, json={}}
--路径=>Texture2D，记录被retain的图片
local RefMap = {}
--loadType--loadName--{image={}, plist={}, json={}}, 释放某个系列
local NameMap = {[__this.SCENE]={}, [__this.WINDOW]={}, [__this.MANUAL]={}}
-- Path=>count 延迟释放的骨骼动画
local ReleaseMap = {}

--延迟释放，优化cpu占用
local function doRemoveUnused()
	if __this.needRemovedTexture then
		textureCache:removeUnusedTextures()
		__this.needRemovedTexture = nil
	end
end

--释放未使用的texture
function __this.removeUnused()
	if not __this.remove_timer_id then
    	__this.remove_timer_id = TimerMgr.startTimer(doRemoveUnused, 0.5)
	end
	__this.needRemovedTexture = true
end

--不存在就创建
local function getSubMap(map, name)
	if not map or not name then
		assert(false, "空对象！！！")
	end
	if not map[name] then
		map[name] = {}
	end
	return map[name]
end

--释放图片
function __this.removeImage(path)
	if not __this.hasPool("image", path) then
		if RefMap[path] then
			RefMap[path]:release()
			RefMap[path] = nil
		end
		textureCache:removeTextureForKey(path)
        getSubMap(PathMap, "image")[path] = nil
	end
end

--释放Plist
function __this.removePlist(plist, texture)
	if string.find(plist, 'SharedSource.plist$') or string.find(plist, 'MainUI0.plist$') then
		assert(false, "共享资源被释放！！！")
	end
	if not __this.hasPool("plist", plist) then
		spriteFrameCache:removeSpriteFramesFromFile(plist)
        getSubMap(PathMap, "plist")[plist] = nil
	end
	if texture then
		__this.removeImage(texture)
	end
end

--释放骨骼
function __this.removeArmature(json)
	-- if not __this.hasPool("json", json) then
 --        getSubMap(PathMap, "json")[json] = nil
 --    	ReleaseMap[json] = 2 --倒计时2次
 --    	if nil == __this.timer_id then
 --    		__this.timer_id = TimerMgr.startTimer(__this.doRemoveArmature, 0)
 --    	end
 --    end	
end

function __this.doRemoveArmature()
	-- for json,count in pairs(ReleaseMap) do
	-- 	if count > 0 then
	-- 		ReleaseMap[json] = count - 1
	-- 	else
	-- 		ReleaseMap[json] = nil
	-- 		if not __this.hasPool("json", json) then
 --    			armatrueMgr:removeArmatureFileInfo(json)
 --        		getSubMap(PathMap, "json")[json] = nil
 --        	end
 --    	end
 --    end
end

--图片信息
function __this.addImagePool(texture, loadType, loadName)
	__this.addPool("image", texture, loadType, loadName)
end

--Plist信息
function __this.addPlistPool(plist, texture, loadType, loadName)
	if string.find(plist, 'SharedSource.plist$') then
		return
	end
	if string.find(plist, 'MainUI0.plist$') then
		return
	end
	__this.addPool("plist", plist, loadType, loadName)
	if not texture then
		texture = string.gsub(plist, ".plist", ".png")
	end
	__this.addPool("image", texture, loadType, loadName)
end

--骨骼信息
function __this.addArmaturePool(json, loadType, loadName)
	if __this.MODEL ~= loadType then --角色不在这里缓存
		__this.addPool("json", json, loadType, loadName)
	end
end

function __this.addPool(name, path, loadType, loadName)
	getSubMap(getSubMap(PathMap[name], path), loadType)[loadName] = true
	if NameMap[loadType] then
		getSubMap(getSubMap(NameMap[loadType], loadName), name)[path] = true
	end
end

function __this.removePool(name, path, loadType, loadName)
	getSubMap(getSubMap(PathMap[name], path), loadType)[loadName] = nil
end

function __this.hasPool(name, path)
	local pathList = PathMap[name][path]
	if pathList then
		for _,v in pairs(pathList) do
			if not table.empty(v) then
				return true
			end
		end
	end
end

-- 禁止外部调用
-- 释放缓存
function __this.release(loadType, loadName)
	local list = NameMap[loadType][loadName]
	if list then
		if list.json then
			for path,_ in pairs(list.json) do
				__this.removePool("json", path, loadType, loadName)
				__this.removeArmature(path)
			end
		end
		if list.plist then
			for path,_ in pairs(list.plist) do
				__this.removePool("plist", path, loadType, loadName)
				__this.removePlist(path)
			end
		end
		if list.image then
			for path,_ in pairs(list.image) do
				__this.removePool("image", path, loadType, loadName)
				__this.removeImage(path)
			end
		end
	end
	__this.removeUnused()
end

-- 释放场景
function __this.releaseScene(loadName)
	__this.release(__this.SCENE, loadName)
end

-- 释放窗口
function __this.releaseWindow(loadName)
	__this.release(__this.WINDOW, loadName)
end

function __this.loadImage(path, loadType, loadName)
	__this.addImagePool(path, loadType, loadName)
	local texture = textureCache:addImage(path)
	if not RefMap[path] then
		RefMap[path] = texture
		texture:retain() --引用计数+1，防止被removeUnused移除
	end
end

function __this.loadImageAsync(path, loadType, loadName)
	__this.addImagePool(path, loadType, loadName)
	textureCache:addImageAsync(path)
	-- textureCache:addImageAsync(path, function(texture)
	-- 	if not RefMap[path] then
	-- 		RefMap[path] = texture
	-- 		texture:retain()
	-- 	end
	-- end)
end

function __this.getRefMapTexture(path)
	return RefMap[path]
end

function __this.loadPlist(plist, texture, loadType, loadName)
	__this.addPlistPool(plist, texture, loadType, loadName)
    spriteFrameCache:addSpriteFrames(plist)
end

local function getModelUrl(style)
    return "image/armature/fight/model/" .. style .. '/' .. style .. ".ExportJson"
end
local function getTotemUrl(style)
    return "image/armature/fight/totem/" .. style .. '/' .. style .. ".ExportJson"
end
--图腾模型专用加载接口
--@param	totem_name	    --json引用形象的基本名字
--@param	totem_level	    --图腾等级
function __this.loadArmatureFileInfoTotem(totem_name, totem_level, loadType, loadName)
    local json = getTotemUrl(totem_name .. totem_level)
	__this.loadArmatureFileInfo(json, loadType, loadName)

    --[[
            暂时不实现动态加载, 冒似图腾资源包体大小在可接受范围内
	--动态加载资源
	if 1 ~= totem_level and 5 ~= totem_level then

	end
	--]]
end

function __this.loadArmatureFileInfo(json, loadType, loadName)
	__this.addArmaturePool(json, loadType, loadName)
    armatrueMgr:addArmatureFileInfo(json)
end

function __this.loadArmatureFileInfoAsync(json, loadType, loadName, handler)
	__this.addArmaturePool(json, loadType, loadName)
    armatrueMgr:addArmatureFileInfoAsync(json, cc.CallFunc:create(function()
		if handler then
			handler()
		end
    end))
end

--加载跳青蛙
--@list 	s2
function __this.loadFightModelListAsyncForWait(list, callback, callback1)
	LoadMgr.fightModelCount = #list
    local count = LoadMgr.fightModelCount

	for __, obj in pairs(list) do
		local data = nil
        if obj.attr == const.kAttrSoldier then
            data = findSoldier(obj.id)
	    elseif obj.attr == const.kAttrTotem then
            data = findTotem(obj.id)
        elseif obj.attr == const.kAttrMonster then
            data = findMonster(obj.id)
	    end
	    
	    if not data then
	    	LoadMgr.fightModelCount = LoadMgr.fightModelCount - 1
            --Command.run("loading set percent", (count - LoadMgr.fightModelCount) * 100 /count , "加载竞技场数据", json)
	    	if LoadMgr.fightModelCount <= 0 then
                if callback ~= nil then 
                    TimerMgr.callLater(callback,0.1)
                end 
	    	end
	    else
            local json = ''
            local animation_name = ''
            if obj.attr == const.kAttrTotem then
                animation_name = data.animation_name .. obj.level                
		    	json = getTotemUrl( animation_name )
		    else
                animation_name = data.animation_name
                json = getModelUrl( animation_name )
		    end
		    
		    armatrueMgr:addArmatureFileInfoAsync(json, cc.CallFunc:create(function()
		        armatrueMgr:addArmatureFileInfo(json)
		        ccs.Armature:createAsync( animation_name,
		        	cc.CallFunc:create(function ( ... )
		        		LoadMgr.fightModelCount = LoadMgr.fightModelCount - 1
                        if callback1 ~= nil then 
                            callback1((count - LoadMgr.fightModelCount) * 100 / count, nil, json)
                        end 

				    	if LoadMgr.fightModelCount <= 0  then
                            if callback ~= nil then 
                                TimerMgr.callLater(callback,0.1)
                            end 			    		
				    	end
		        	end))
		    end))
		end
	end
end

function __this.loadFightModelAsync(id, attr, level)
    local data = nil
    if attr == const.kAttrSoldier then
        data = findSoldier( id )
    elseif attr == const.kAttrTotem then
        data = findTotem( id )
    elseif attr == const.kAttrMonster then
        data = findMonster( id )
    end
    if data == nil then
        return
    end
    
    local json = ''
    local animation_name = ''
    if const.kAttrTotem == attr then
    	level = level or 1
        animation_name = data.animation_name .. level    	
    	json = getTotemUrl( animation_name )
    else
        animation_name = data.animation_name
        json = getModelUrl( animation_name )
    end
    
    armatrueMgr:addArmatureFileInfoAsync(json, cc.CallFunc:create(function()
        armatrueMgr:addArmatureFileInfo(json)
        ccs.Armature:createAsync(animation_name)
    end))
end

function __this.clearAsyncCache()
    ccs.Armature:clearAsync()
    ccs.ArmatureDataManager:getInstance():clearDataAsync()
    cc.Director:getInstance():getTextureCache():clearImageAsync()
end

-----------------------资源释放检查---------------------
function __this.showCacheInfo()
	LogMgr.log( "resource", "---------------- TextureInfo -------------" )
    LogMgr.log( "resource", textureCache:getCachedTextureInfo() )
end

local openData = nil
local lastWinName = nil

local function isShared(str)
	return string.find(str, 'image/share/SharedSource.png') ~= nil or string.find(str, 'TextureCache dumploadInfo: ') ~= nil
end

local function doCompareOpenCached()
	local data = textureCache:getCachedTextureInfo()
	local closeData = string.split(data, '\n')
	for i,v in ipairs(closeData) do
		if openData[v] or isShared(v) then
			closeData[i] = nil
		else
			closeData[i] = v
		end
	end
	if not table.empty(closeData) then
	   LogMgr.log("resource", lastWinName, '窗口没有释放的资源：\n', debug.dump(closeData))
	end
end

function __this.recordOpenCached()
    local data = textureCache:getCachedTextureInfo()
    local tmp = string.split(data, '\n')
    openData = {}
    for i,v in ipairs(tmp) do
        openData[v] = true
    end
end

function __this.compareOpenCached(winName)
	lastWinName = winName
	TimerMgr.callLater(doCompareOpenCached, 1) --1秒后比较 
end

EventMgr.addListener( 'reachabilityChanged', function(p)
    local net_info = system.net_info()
    LogMgr.log( 'net', 'net_info: ' .. net_info )
end )

------------------------接口绑定------------------------
Command.bind('LoadMgr releaseScene', __this.releaseScene)
Command.bind('LoadMgr releaseWindow', __this.releaseWindow)
