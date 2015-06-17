-- create by Live --
-- UI 点击事件管理
local __this = UIMgr or {}
UIMgr = __this

local clickDic = {}

local function __touchBeginBase( touch, event )
    local target = event:getCurrentTarget()
    local cname = ''

    if target.class ~= nil then
        cname = target.class.__cname
    end
    
    local coord = target:convertToNodeSpace( touch:getLocation() )
    local rect = nil
    if cname == 'Armature' or cname == 'ArmatureSprite' then
        if target:getDoubleRender() then
            rect = target:getCurrentBoundingBox()
        else
            if target.getBoundingBox ~= nil then
                rect = target:getBoundingBox()
                coord.y = coord.y + rect.height;
            end
            
            rect = cc.rect( 0, 0, target:getContentSize().width, target:getContentSize().height )
        end
    else
        --骨赂动画特别处理( swf导出主因为(0,0)点原坐标象限 不一致)
        if cname == 'ArmatureSprite' then
            if target.getBoundingBox ~= nil then
                rect = target:getBoundingBox()
                coord.y = coord.y + rect.height;
            end
        end
        
        rect = cc.rect( 0, 0, target:getContentSize().width, target:getContentSize().height )
    end
    
    if coord.x > rect.x and coord.x < rect.x + rect.width and coord.y > rect.y and coord.y < rect.y + rect.height then
        if target.__touchBegin ~= nil then
            target.__touchBegin( touch, event, coord )
        end
        
        return true
    end
end

local function __touch_listener( target, bubbles )
    local listener = target.__listener

    if listener == nil then
        listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(bubbles ~= true)

        listener:registerScriptHandler( __touchBeginBase, cc.Handler.EVENT_TOUCH_BEGAN )
        target:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, target)

        target.__listener = listener
    end

    return listener
end

--移除原始的事件侦听器，可能影响ccui的侦听器
function __this.removeScriptHandler(target)
    local listener = target.__listener
    if listener then
        target:getEventDispatcher():removeEventListener(listener)
        target.__listener = nil
    end
end

--获取原始的侦听器方式
function __this.registerScriptHandler(target, call, eventType, bubbles)
    if eventType == cc.Handler.EVENT_TOUCH_BEGAN then
        target.__touchBegin = call
    end
    local listener = __touch_listener(target, bubbles)
    if eventType ~= cc.Handler.EVENT_TOUCH_BEGAN then
        listener:registerScriptHandler(call, eventType)
    end
end

local function __touch_handler( target )
    if target.__touchHandler == nil then
        target.__touchHandler = function( touch, event )
            if event == ccui.TouchEventType.began then
                if target.__touchBegin ~= nil then
                    target.__touchBegin(touch, event)
                end
            elseif event == ccui.TouchEventType.ended then
                if target.__touchEnded ~= nil then
                    target.__touchEnded(touch, event)
                end
            elseif event == ccui.TouchEventType.moved then
                if target.__touchMoved ~= nil then
                    target.__touchMoved(touch, event)
                end
            elseif event == ccui.TouchEventType.canceled then
                if target.__touchCancel ~= nil then
                    target.__touchCancel(touch, event)
                end
            end
        end

        target:addTouchEventListener( target.__touchHandler )
    end
end

function __this.addTouchBegin( target, call )
    local isCCUI = (string.find(tolua.type(target), "ccui.") == 1)

    target.__touchBegin = call

    if false == isCCUI then
        --TouchBegin 特殊处理, 在内部已经封装了 cc.Handler.EVENT_TOUCH_ENDED 响应事件
        __touch_listener( target )
    else
        __touch_handler( target )
    end
end

function __this.addTouchEnded( target, call )
    local isCCUI = (string.find(tolua.type(target), "ccui.") == 1)

    target.__touchEnded = call

    if false == isCCUI then        
        __touch_listener( target ):registerScriptHandler( call, cc.Handler.EVENT_TOUCH_ENDED )
    else
        __touch_handler( target )
    end
end

function __this.addTouchMoved( target, call )
    local isCCUI = (string.find(tolua.type(target), "ccui.") == 1)

    target.__touchMoved = call

    if false == isCCUI then
        __touch_listener( target ):registerScriptHandler( call, cc.Handler.EVENT_TOUCH_MOVED )
    else
        __touch_handler( target )
    end
end

function __this.addTouchCancel( target, call )
    local isCCUI = (string.find(tolua.type(target), "ccui.") == 1)

    target.__touchCancel = call

    if false == isCCUI then
        __touch_listener( target ):registerScriptHandler( call, cc.Handler.EVENT_TOUCH_CANCELLED )
    else
        __touch_handler( target )
    end
end
