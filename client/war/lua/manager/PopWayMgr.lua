-- Create By Hujingjiang --

PopWayMgr = {}

-- 木有动画
PopWayMgr.NONE = 0
-- 从上往下弹出
PopWayMgr.UPTOBOTTOM = 1
-- 在中间从小变大弹出
PopWayMgr.SMALLTOBIG = 2

local MAX_CACHE_COUNT = 3 --最多缓存3个UI
local cacheWinList = {} --缓存的UI，UI的ctor函数里面设置self.isNeedCache = true开启

local positionx = visibleSize.width / 2
local positiony = visibleSize.height / 2

local function callOnShow(win)
	win.hasCallOnShow = true
	if win.onShow then
		xpcall(win.onShow, __G__TRACKBACK__, win)
	end
end

function callOnShowLater(win)
	if win.isNeedCache then
		PopMgr.addWinCache(win)
		local function onShowHandler()
			callOnShow(win)
			PopMgr.setIsPoping(win.winName)
		end
		TimerMgr.runNextFrame(onShowHandler)
	else
    	PopMgr.setIsPoping(win.winName)
    end
end

-- local function callOnClose(win)
-- 	if win.onClose then
-- 		win:onClose()
-- 	end
-- end

-- local function setUiOpacity(ui, value)
--         local isCCUI = (string.find(tolua.type(ui), "ccui.") == 1)
--         if isCCUI == true then
--             local render = ui:getVirtualRenderer()
--             if nil ~= render then
--                 render:setOpacity(value)
--             end
--             local list = ui:getChildren()
--             for _, v in pairs(list) do
--                 setUiOpacity(v, value)
--             end
--         end
--     end
-- local function setUIFade(ui, func, time, target)
--     local isCCUI = (string.find(tolua.type(ui), "ccui.") == 1)
--     if isCCUI == true then
--         local render = ui:getVirtualRenderer()
--         if nil ~= render then
--             if nil == target then
--                 render:runAction(func:create(time))
--             else
--                 render:runAction(func:create(time, target))
--             end
--         end
--         local list = ui:getChildren()
--         for _, v in pairs(list) do
--             setUIFade(v, func, time)
--         end
--     end
-- end

-- 
local function getShowUTBAction(win, handler)
	local size = win.getSize and win:getSize() or win:getContentSize()
	local posX = win:getPositionX()
	local posY = win:getPositionY() + visibleSize.height + size.height
	win:setPosition(posX, posY)
	local toY = visibleSize.height - size.height
	if toY < -10 then toY = -10 end

	local fadeAction = cc.FadeOut:create(0.8)
--	local moveAction = cc.MoveTo:create(0.8, cc.p(posX, toY-40))
--	local daseBounceOut = cc.EaseExponentialIn:create(moveAction)
--	local moveDown = cc.MoveBy:create(0.15, cc.p(0,40))
--    local move_ease = cc.EaseExponentialOut:create(cc.EaseBackIn:create(moveDown))

    local firstDownMove = cc.MoveTo:create(0.3, cc.p(posX, toY + 40))
    local sinInDown = cc.EaseSineIn:create(firstDownMove)  -- 前半部分向下加速运动
    local secondDownMove = cc.MoveBy:create(0.06,cc.p(0, -50))
    local sinOutDown = cc.EaseSineOut:create(secondDownMove) -- 前半部分向下减速运动
    local thirdUpMove = cc.MoveBy:create(0.06,cc.p(0, 20))
    local sinInUp = cc.EaseSineIn:create(thirdUpMove)

	local function showUiPanelFunc()
		PopMgr.setUiAminal(false)
		callOnShowLater(win)
		EventMgr.dispatch(handler, {isVisible = true})
	end
	local animFunc = cc.CallFunc:create(showUiPanelFunc)
--    local action = cc.Sequence:create(cc.Spawn:create(fadeAction, daseBounceOut), move_ease, animFunc)
    local action = cc.Sequence:create(sinInDown,sinOutDown,sinInUp, animFunc)
	return action
end
local function getHideUTBAction(win)
	local function hideAnimFunc()
		PopMgr.removePopBg(win)
	end

	local winSize = cc.Director:getInstance():getWinSize()
	local itemBoxSize = win:getContentSize()
	local action = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(win:getPositionX(), 
		winSize.height + itemBoxSize.height)), 
		cc.CallFunc:create(hideAnimFunc))
	return action
end

local function getShowSTBAction(win, handler)
    local midX, midY = positionx, positiony 
	local winSize = win.getSize and win:getSize() or win:getContentSize()

	if false == win:isCascadeOpacityEnabled() then
            win:setCascadeOpacityEnabled(true)
        end
    setUiOpacity(win, 45)
    win:setAnchorPoint(cc.p(0.5, 0.5))
    win:setPosition(cc.p(midX, midY))
    positionx = visibleSize.width / 2
    positiony = visibleSize.height / 2
	local sAction = cc.ScaleTo:create(0.1, 1.05)
    local scaleBack = cc.ScaleTo:create(0.08, 1)
    setUIFade(win, cc.FadeIn, 0.18)
	
	local function showUiPanelFunc()
		PopMgr.setUiAminal(false)
		callOnShowLater(win)
		EventMgr.dispatch(handler, {isVisible = true})
	end
	local animFunc = cc.CallFunc:create(showUiPanelFunc)
	-- local action = cc.Sequence:create(cc.Spawn:create(sBounceOut, mBounceOut), animFunc)
	local action = cc.Sequence:create(sAction, scaleBack, animFunc)

	return action
end


local function getHideSTBAction(win)
    local midX, midY = visibleSize.width / 2, visibleSize.height / 2
	local winSize = win.getSize and win:getSize() or win:getContentSize()
	win:setAnchorPoint(cc.p(0.5, 0.5))

	local sAction = cc.ScaleTo:create(0.14, 1.05)
	setUIFade(win, cc.FadeOut, 0.14)
	
	local function showUiPanelFunc()
		PopMgr.removePopBg(win)
	end
	local animFunc = cc.CallFunc:create(showUiPanelFunc)
	-- local action = cc.Sequence:create(cc.Spawn:create(sBounceOut, mBounceOut), animFunc)
	local action = cc.Sequence:create(sAction, animFunc)
	return action
end

function PopWayMgr.setSTBSkew(x,y)
   positionx = positionx + x
   positiony = positiony + y 
end 

--执行UI显示动画
--@param win 需要执行的动画的窗口
--@param handler 回调函数 参数值是字符串 调用返回按钮隐藏或者显示的方法 event参数必须是isVisible
function PopWayMgr.showUiPanel(win, handler)
	PopMgr.setUiAminal(true)
	PopMgr.setIsPoping(win.winName, true) --正在打开窗口
	if not win.isNeedCache then
		callOnShow(win)
	end
	local action = nil
	local hasSound
	if win.popType == PopWayMgr.NONE or win.isNeedAnimate == false then
		if win.isNeedAnimate == false and win.popType == PopWayMgr.SMALLTOBIG then
			local midX, midY = visibleSize.width / 2, visibleSize.height / 2
			win.isNeedAnimate = true
			win:setAnchorPoint(cc.p(0.5, 0.5))
    		win:setPosition(cc.p(midX, midY))
		end
		PopMgr.setUiAminal(false)
		if win.isNeedCache then
			callOnShowLater(win)
		else
            PopMgr.setIsPoping(win.winName)
		end
		EventMgr.dispatch(handler, {isVisible = true})
	elseif win.popType == PopWayMgr.UPTOBOTTOM then
		action = getShowUTBAction(win, handler)
		hasSound = true
	elseif win.popType == PopWayMgr.SMALLTOBIG then
		action = getShowSTBAction(win, handler)
		hasSound = true
	end
	if hasSound then
		SoundMgr.playEffect("sound/ui/sfx_windowslideon.mp3")
	end
	if nil ~= action then
		win:runAction(action)
	end
end

--执行UI退出动画
--@param win 需要执行的动画的窗口
function PopWayMgr.hideUiPanel(win, noAnimation)
	local action = nil
	-- if not win.isNeedCache then
	-- 	callOnClose(win)
	-- end
	local hasSound
	local popType = noAnimation and PopWayMgr.NONE or win.popType
	if PopMgr.getRemoveOnce() or popType == PopWayMgr.NONE then
		PopMgr.removePopBg(win)
	elseif popType == PopWayMgr.UPTOBOTTOM then
		action = getHideUTBAction(win)
		hasSound = true
	elseif popType == PopWayMgr.SMALLTOBIG then
		-- action = getHideSTBAction(win)
		PopMgr.removePopBg(win)
		hasSound = true
	end
	if hasSound then
		SoundMgr.playEffect("sound/ui/sfx_windowslideoff.mp3")
	end
	if nil ~= action then
		win:runAction(action)
	end
end

--取消正在执行的动画
--@param win 需要取消执行动画的窗口
function PopWayMgr.cancelUiPanel(win)
	win:stopAllActions()
end