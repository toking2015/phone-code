-- UI 窗口管理
-- UI的层次为100
local __this = PopMgr or {}
PopMgr = __this

PopUpType = {}
PopUpType.NORMAL = 0		-- 普通弹出
PopUpType.MODEL = 1			-- 弹出后 ，屏蔽穿透
PopUpType.SPECIAL = 2		-- 弹出后 ，屏蔽穿透 ，但是点击窗口外的点 ，窗口关闭

local MAX_CACHE_COUNT = 3 --最多缓存3个UI
local cacheWinList = {} --缓存的UI，UI的ctor函数里面设置self.isNeedCache = true开启，也可以在下面的Dic添加

PopOrType ={}
PopOrType.InductUI = 1
PopOrType.Optional = 2
PopOrType.Gut = 3
PopOrType.GetToTem = 4
PopOrType.Com = 5

--需要缓存的窗口
__this.NEED_CACHE_DIC = 
{
	-- SoldierUI=true
	-- NCopyUI=true
}

--UI优先级，剧情 > 升级 > 通关结算
__this.UI_PRIORITY = 
{
	--引导互斥
	[1] = { "InductUI", "TeamUpgradeUI", "FightResultUI", "CopySearchCompleteUI", "GutUI", "OpenFuncUI", "TotemGetUI", "ArenaResult", "SaoDangUI", "OpenIocnUI", "CopyTipsMainUI" },
	--指引互斥
	[2] = { "GutUI", 'InductUI' },
	--剧情互斥
	[3] = { "GutUI", "TeamUpgradeUI", "FightResultUI", "CopySearchCompleteUI", "CardUI", "InductUI", "OpenFuncUI", "TotemGetUI" },
	--获得图腾互斥
	[4] = { "TeamUpgradeUI", "FightResultUI", "CopySearchCompleteUI", "CardUI",  "TotemGetUI", "CardGetSoidier", "OpenFuncUI" },
	--普通的互斥
	[5] = {"OpenFuncUI", "GutUI", "TeamUpgradeUI", "FightResultUI", "CopySearchCompleteUI", "CardUI", "InductUI", "TotemGetUI", "NCopyUI", "CardGetSoidier", "ArenaResult","RewardGetUI", "CopyTipsMainUI"}
}


-- __this.priorityWinList = { [PopOrType.InductUI]={},[PopOrType.Optional]={}, [PopOrType.Gut]={},[PopOrType.GetToTem]={},[PopOrType.Com]={} }
__this.notRemoveWindowList = { 'GutUI', 'TeamUpgradeUI', 'QuitConfirmUI'}

-- 窗口字典
local winDic = {}
-- 窗口生成函数字典
local winCreateDic = {}
-- 当前显示窗口字典
local winPopDic = {}
-- 弹出层
local winLayer = nil
-- 更高窗口层
local upLayer = nil
-- 窗口背景层字典
local bgPopDic = {}
local existDic = {}
local isUiAminal = false
local isRemoveOnce = false

local popingDic = {} --正在打开的窗口
local closingDic = {} --正在关闭的窗口

local roleTopParent = nil -- 资源条的父对象
local roleTopWins = {} -- 把资源条拉高的了窗口
local upLayerWins = {} -- 高层次的窗口
local winSceneMap = {} -- 切换到了CommonScene的窗口

local winNameLayer = {} -- name => layerNo

function __this.setWinNameLayer(name, layerNo)
	winNameLayer[name] = layerNo
end

--------------窗口释放相关START---------------
--检测是否已经被缓存了
function __this.addWinCache(win)
	if gameData.findArrayData(cacheWinList, "winName", win.winName) then
		return false
	else
		if #cacheWinList >= MAX_CACHE_COUNT then
			local oldWin = table.remove(cacheWinList, 1)
			__this.releaseWin(oldWin)
		end
		table.insert(cacheWinList, win)
		return true
	end
end

--添加窗口的plist与texture
function __this.addWinPlist(winName, plist, texture)
	LoadMgr.addPlistPool(plist, texture, LoadMgr.WINDOW, winName)
end

--把窗口加入准备释放的列表
--暂时直接释放
--@param winName 窗口名称
function __this.releaseWin(winName, isNeedCache)
	if not isNeedCache then
		__this.releaseWindow(winName)
		LoadMgr.releaseWindow(winName)
		-- 关闭UI内存检查
		-- LoadMgr.compareOpenCached(winName)
	end
	-- ClearDataExceptList( {} ) --清除所有json数据
end

--居中弹出
function popUpCenter(win)
	local s = win.getSize and win:getSize() or win:getContentSize()
	win:setPosition(visibleSize.width / 2 - s.width / 2, visibleSize.height / 2 - s.height / 2)
end

function __this.setUiAminal(value)
	isUiAminal = value
end

function __this.getUiAminal(value)
	return isUiAminal
end

function __this.setRemoveOnce(value)
	isRemoveOnce = value
end

function __this.getRemoveOnce()
	return isRemoveOnce
end

function PopMgr.getWinLayer()
	return winLayer
end

function __this.setWinLayer( _winLayer )
	winLayer = _winLayer
end

function __this.setUpLayer( _upLayer )
	upLayer = _upLayer
end

---Start-> 窗口生成函数的操作
--@param winName 窗口名字
--@param winClass 窗口类
---
function __this.addWinCreate(winName, winClass)
    if winClass == nil then
        LogMgr.error('没有窗口类')
    end
	if nil == winCreateDic[winName] then
		winClass.winName = winName --给窗口命名
		winCreateDic[winName] = winClass
	else
		LogMgr.error('窗口重名 '..winName)
	end
end

function __this.hasWinCreate(winName)
	return nil ~= winCreateDic[winName]
end
-- 窗口生成函数的操作 <-End

local function createPopBg(owner, isClickClose, isModel, bgC4b)
	local bg = bgPopDic[owner]
	if nil == bg then
		bgC4b = bgC4b or cc.c4b(0, 0, 0, 160)
		if isModel == true then
			bg = LayerColor:create(bgC4b, visibleSize.width, visibleSize.height)
		else 
			bg = LayerColor:create(bgC4b, visibleSize.width, visibleSize.height)
		end
		function bg:getUIType()
			return "cc"
		end
		bgPopDic[owner] = bg
		bg.owner = owner
	end
    bg:setTouchEnabled(true)
	local function onTouchBegan(touch, event)
--		EventMgr.dispatch(EventType.WindowOutClick)
		return true
	end
	local function onTouchEnded(touch, event)
		if PopMgr.getIsPoping(bg.owner) then
			return
		end
		EventMgr.dispatch(EventType.WindowOutClick, {winName = owner.winName})
		if true == isClickClose then 
			if nil ~= bg.owner then
				if false == isUiAminal then
					if bg.owner.backHandler ~= nil then
						bg.owner:backHandler()
					elseif __this.removeWindow(bg.owner) then
						bg = bgPopDic[bg.owner]
						if bg then
							bg:setTouchEnabled(false)
						end
					end
				end
			end
		end
	end

	UIMgr.addTouchBegin(bg, onTouchBegan)
    UIMgr.addTouchEnded(bg, onTouchEnded)
	return bg
end

--获取某个窗口是否正在打开
function __this.getIsPoping(winName)
	return popingDic[winName]
end

function __this.setIsPoping(winName, value)
    popingDic[winName] = value
end

--获取某个窗口是否已经打开
function __this.getIsShow(winName)
	local win = __this.getWindow(winName)
	return win and win:isShow()
end

function __this.getPriorityList( type, winName)
	return __this.UI_PRIORITY[type]
end

function __this.getIsHide(winName)
	return ( not __this.getIsPoping( winName ) ) and ( not __this.getIsShow( winName ) )
end

--执行优先级窗口弹出
function __this.checkPriorityPop(winName, runType, callback)
	if winName then
		local hasWindow = false
		for k,v in pairs(__this.priorityWinList[runType]) do
			if v.name == winName then
				hasWindow = true
				__this.priorityWinList[runType][k] = {name=winName, type=runType, fun=callback}
			end
		end

		if not hasWindow then
			table.insert( __this.priorityWinList[runType], {name=winName, type=runType, fun=callback} )
		end
	end

	for i=PopOrType.Com, 1, -1 do
		if #__this.priorityWinList[i] > 0 then
			for m=#__this.priorityWinList[i], 1, -1 do
				local funData = __this.priorityWinList[i][m]
				if funData == nil then
					table.remove( __this.priorityWinList[i], m )
				end
				if funData then
					local priorityList = __this.getPriorityList(funData.type, funData.name)
					local canOpen = true
				    if priorityList then
						for _,v in ipairs(priorityList) do
							if __this.getIsPoping(v) or __this.getIsShow(v) then
								canOpen = false
								break
							end
						end
					end

					if canOpen then			
						funData.fun()
						table.remove( __this.priorityWinList[i], m )
					end
				end
			end
		end
	end
end

local function onCloseHandler()
	TimerMgr.callLater( __this.checkPriorityPop, 0 )
end
EventMgr.addListener(EventType.CloseWindow, onCloseHandler)


-- start-> 窗口字典操作
-- 弹出窗口
--@param winName 窗口名称
--@param isCenter 是否居中
--@param popUpType 弹出类型
--@param noBack 是否不需要退出按钮
--@param depth 窗口的层次
--@param isNeedAnimate
--@param bgC4b 背景的颜色
--@param x 坐标x --不好控制，先不处理
--@param y 坐标y
--@return 返回窗口实例
function __this.popUpWindow(winName, isCenter, popUpType, noBack, depth, isNeedAnimate, bgC4b, x, y)
    ActionMgr.save( 'UI', string.format('%s show', winName) )
    
	if true == popingDic[winName] then
		return
	end
	if true == closingDic[winName] then
		PopWayMgr.cancelUiPanel(__this.getWindow(winName))
		closingDic[winName] = nil
	end
	local win = nil

	--关闭UI内存检查
	-- LoadMgr.recordOpenCached()
	
	local win = __this.getOrCreateWin(winName)
	
	if nil ~= win then
		if win:isShow() then
			return
		end
		local function doAddWindow()
			if win.__uiGroup and win.__uiGroup ~= 0 then --判断系统UI，关闭其他UI
				for i,v in pairs(existDic) do
					if v.__uiGroup and v.__uiGroup ~= 0 and v.__uiGroup ~= win.__uiGroup then
						__this.removeWindow(v)
					end
				end
			end
    		if true == isCenter then
    			popUpCenter(win)
    		end
    		local layer
    		if winNameLayer[winName] then
    			print(1)
    			layer = SceneMgr.getLayer(winNameLayer[winName])
    		else
    			print(2)
    			layer = win._isUpLayer and upLayer or winLayer
    		end
    		if win._isUpLayer then
    			upLayerWins[win.winName] = true
    			winLayer:setVisible(false)
    		end
    		-- 创建并添加屏蔽背景
    		local bg = bgPopDic[win]
    		if not bg then
    			if PopUpType.MODEL == popUpType then
    				bg = createPopBg(win, false, true, bgC4b)
    			elseif PopUpType.SPECIAL == popUpType then
    				bg = createPopBg(win, true, nil, bgC4b)
    			end
    
    			if nil ~= bg then
    				bg.winName = winName
    				layer:addChild(bg, depth or 0)
    			end
    		end
    
    		-- 添加窗口 ，并执行show方法
    		if not win:getParent() then
    			if bg ~= nil then
    		    	bg:addChild(win)
    		    else
    				layer:addChild(win, depth or 0)
    		    end
    		end
    		if win.isUpRoleTopView then --最高层资源条
    			roleTopWins[win.winName] = true
    			local top = MainUIMgr.getRoleTop()
    			win.top = top
    			if top then
    				if top:getParent() ~= winLayer then
	    				roleTopParent = top:getParent()
	    				if roleTopParent then
	    					top:removeFromParent()
	    				end
	    				winLayer:addChild(top, 999)
	    			end
    				if top._sub_action_tag then
    					top:stopActionByTag(top._sub_action_tag)
    				end
					top:setPositionX(visibleSize.width - top:getBoundingBox().width - 10)
					top:setPositionY(visibleSize.height - top:getBoundingBox().height)
					top:resetShow()
    			end
    		end
    
    		local function backHandler()
    			if __this.getIsPoping(winName) then
    				return
    			end
    			if win.backHandler then
    				win:backHandler()
    			else
    				__this.removeWindow(win)
    			end
    		end
    		if noBack then
    			BackButton:pushNone(win)
    		else
    			BackButton:pushBack(win, backHandler)
    		end
    		existDic[winName] = win
    		if nil == isNeedAnimate then isNeedAnimate = true end
    		win.isNeedAnimate = isNeedAnimate
    		if not win:show() then
    			LogMgr.error("不能重写窗口的show函数"..winName)
    		end
    		EventMgr.dispatch(EventType.ShowWindow, {winName = winName})
    		EventMgr.dispatch(EventType.ShowWinNames, winName)
    		EventMgr.dispatch(EventType.ShowWinName, winName)
    	end
		if false and win.sceneName then --暂时屏蔽
			winSceneMap[win.winName] = true
			if not SceneMgr.isSceneName("copyUI")
				and not SceneMgr.isSceneName("copy")
				and not SceneMgr.isSceneName(win.sceneName) then
				SceneMgr.enterScene(win.sceneName, win.sceneMap)
				doAddWindow()
			else
				doAddWindow()
			end
		else
			doAddWindow()
		end
	end
	-- popingDic[winName] = nil
	return win
end

---
-- 窗口关闭后的清理
-- 既然必须调用，那么就在这里释放资源
---
function __this.removePopBg(win)
	closingDic[win.winName] = nil
	if win:getParent() then
		win:removeFromParent()
	else
		LogMgr.error(win.winName, " has already been removed")
	end
	--移除黑色背景
	if nil ~= bgPopDic[win] then
		bgPopDic[win].owner = nil
		bgPopDic[win]:removeFromParent()
		bgPopDic[win] = nil
	end
	if win.hasCallOnShow then
		if win.onClose then --处理窗口关闭逻辑
			xpcall(win.onClose, __G__TRACKBACK__, win) --try catch
		end
		win.hasCallOnShow = nil
	end
	EventMgr.dispatch(EventType.CloseWindow, {winName = win.winName})
    EventMgr.dispatch(EventType.HideWinName, win.winName)
	if win.isUpRoleTopView then
		roleTopWins[win.winName] = nil
		if table.empty(roleTopWins) then -- 都空了才加回去
			local top = MainUIMgr.getRoleTop()
			if top then
				if top:getParent() then
					top:removeFromParent()
				end
				if roleTopParent then
					top:setPosition(top._targetPos)
					top:showLastStatus()
					roleTopParent:addChild(top)
					roleTopParent = nil
				end
			end
		end
	end
	if win._isUpLayer then
		upLayerWins[win.winName] = nil
		if table.empty(upLayerWins) then
			winLayer:setVisible(true)
		end
	end
	if win.sceneName then
		winSceneMap[win.winName] = nil
		--只有一个common场景
		if table.empty(winSceneMap) then --原来是有场景的，现在要返回去
			SceneMgr.leaveCommon()
		end
	end
	--释放窗口与资源
	if not win.isNotRelease then
		__this.releaseWin(win.winName, win.isNeedCache)
	end
end
-- 移除窗口
--@param win 窗口实例
--@param force 强制移除
--@param noAnimation 不需要动画
--@return 成功移除ture，否则false
function __this.removeWindow(win, force, noAnimation)
	if nil ~= win then
	    ActionMgr.save( 'UI', string.format('%s hide', win.winName) )
    	if true == closingDic[win.winName] then
    		return false
    	end
		if not existDic[win.winName] then
			return true
		end
		if not force and win.onBeforeClose and win:onBeforeClose() then
			return false
		end
    	if true == popingDic[win.winName] then
    		PopWayMgr.cancelUiPanel(win)
    		popingDic[win.winName] = nil
    	end
		closingDic[win.winName] = true
		existDic[win.winName] = nil
		local winName = win.winName
		BackButton:pop(win)
		local ra,rb = xpcall(win.close, __G__TRACKBACK__, win, noAnimation)
		if ra and not rb then
			LogMgr.error("不能重写窗口的close函数"..winName)
		end
		return true
	end
	return false
end

-- 通过winName移除窗口
function __this.removeWindowByName(winName, force)
	local win = __this.getWindow(winName)
	__this.removeWindow(win, force)
end

-- 彻底移除窗口
function __this.releaseWindow(winName)
	local win = winDic[winName]
	if win then 
		-- 判断是否显示 ，移除窗口 ，移除窗口背景
		if nil ~= win.dispose then
			win:dispose()
		end
		TimerMgr.releaseLater(win)
		winDic[winName] = nil
		LogMgr.debug("释放窗口 ：", winName)
	end
end

function __this.removeAllWindow()
	isRemoveOnce = true
	local remove = true
	for k,_ in pairs(existDic) do
		remove = true
		for n,m in pairs(__this.notRemoveWindowList) do
			if m == k then
				remove =false
				break
			end
		end

		if remove then
			__this.removeWindowByName(k, true)
			existDic[k] = nil
		end
	end
	isRemoveOnce = false
end

function __this.getOrCreateWin(winName)
	local win = nil
	if __this.hasWindow(winName) then
		win = __this.getWindow(winName)
	elseif __this.hasWinCreate(winName) then
		win = winCreateDic[winName].new()
		winDic[winName] = win
		win:retain()
	end
	return win
end

-- 获取窗口
function __this.getWindow(winName)
	if nil ~= winDic[winName] then
		return winDic[winName]
	end
	return nil
end
-- 是否有窗口
function __this.hasWindow(winName)
	if nil ~= winDic[winName] then
		return true
	end
	return false
end
function __this.hasWindowOpen()
	if false == table.empty(existDic) then
		return table.nums(existDic) > 0
	else
		return false
	end
end
--调试用
function __this.getWinCreateDic()
	return winCreateDic
end
-- 窗口字典操作 <-End

Command.bind( 'ui show', function( name, type, noBack, depth, bgC4b, x, y)
    __this.popUpWindow( name, true, type, noBack, depth, nil, bgC4b, x, y)
end )
Command.bind( 'ui hide', function( name, force, noAnimation )
    __this.removeWindowByName( name, force, noAnimation )
end )

function __this.clear()
	__this.priorityWinList = { [PopOrType.InductUI]={},[PopOrType.Optional]={}, [PopOrType.Gut]={},[PopOrType.GetToTem]={},[PopOrType.Com]={} }
	for k,v in pairs(__this.notRemoveWindowList) do
		Command.run( 'ui hide', v )
	end
	
	if InductMgr then InductMgr.clear() end
end
__this.clear()
EventMgr.addListener(EventType.UserLogout, __this.clear)
