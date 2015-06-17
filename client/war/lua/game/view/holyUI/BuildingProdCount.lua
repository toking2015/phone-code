require "lua/utils/RichTextUtil.lua" 
require "lua/game/view/holyUI/BuildingProdItem.lua"

local prePath = "image/ui/HolyUI/HolyProductCount/"
local timeVal = 0.5  -- 刷新时间间隔

local isTouch = false  -- 判断是否touch
local isMoved = false   -- 判断是否移动
local isLongTouch = false -- 判断是否长按
local pressTimes = 0  -- 记录touch时间

local building_type = nil
local crit_list = {}
local sumValue = nil

ProdCount = createUIClass("HolyProdCount", prePath .. "HolyProductCount_1.ExportJson", PopWayMgr.SMALLTOBIG)

-- 获取容器中Item的数量
local function getItemCount(view)
    return view:getChildrenCount()
end

-- 出来长按事件
local function onLongPress()
    timeVal = 0.1
end
-- 判断是否长按按钮
local function checkLongClick()
    if isTouch == true and isMoved == false then
        pressTimes = pressTimes + 1
        if pressTimes >= 2 then
            isLongTouch = true
            onLongPress()
        end
    else
        pressTimes = 0
    end
end
-- 不同触摸处理
local function viewTouchFunc(sender, eventType)
    local timeId = nil
    if eventType == ccui.TouchEventType.began then
        isTouch = true
        timeId = TimerMgr.startTimer(checkLongClick,2,false)
    elseif eventType == ccui.TouchEventType.moved then
        isMoved = true
        TimerMgr.killTimer(timeId)
    elseif eventType == ccui.TouchEventType.ended then
        isTouch = false
        isMoved = false
        pressTimes = 0
        TimerMgr.killTimer(timeId)
        if isLongTouch == true then
            timeVal = 0.5
            isLongTouch = false
            return
        else
            timeVal = 0   
        end
    else
        TimerMgr.killTimer(timeId)
    end
end

function ProdCount:onBeforeClose()
    return not (self.isClose)
end
-- 测试
function ProdCount:test()
    building_type = 2
    crit_list = {[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, [7] = 1}
    sumValue = 10000
    self:showProdList()
end

function ProdCount:ctor()
    -- self:test()

    self.isClose = false
    building_type = building_type or 6

    self:init()

    -- scrollview中显示完毕后，显示确认按钮等Icon
    local function showItem()
        self.isClose = true
        self.bg3.container:setVisible(true)
        self.bg1.confirm:setVisible(true)
        self.bg3.container.holyCount:setString('' .. sumValue)
        local posX = self.bg3.container.holyCount:getPositionX()
        local size = self.bg3.container.holyCount:getContentSize()
        self.bg3.container.bigholy:setPositionX(posX+size.width)
    end
    Command.bind("item show", showItem)

    local function confirmTouchFunc()
        ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'confirm') )
        self.bg3.container:setVisible(false)
        PopMgr.removeWindow(self)
    end
    UIMgr.addTouchEnded(self.bg1.confirm, confirmTouchFunc)

    self.bg3.ScrollView:setTouchEnabled(true)
    self.bg3.ScrollView:addTouchEventListener(viewTouchFunc)
end

function ProdCount:onShow()
    self.isClose = false
    self:showProdList()
end

function ProdCount:init()
    local slider = self.bg3.slider
    slider:setVisible(false)
    -- bindScrollViewAndSlider(scrollView, slider) 
    self.bg3.container:setVisible(false)
    self.bg1.confirm:setVisible(false)

    if 6 == building_type then
        self.bg3.container.bigholy:loadTexture("holy_big.png", ccui.TextureResType.plistType)
    else
        self.bg3.container.bigholy:loadTexture("building_coin_big.png", ccui.TextureResType.plistType)
    end
end

function ProdCount:showProdList()
    local list = {}
    local len = #(crit_list)
    local _height = 0
    for i = 1, len do
        local item = ProdItem:create(building_type, crit_list[i])
        item:setVisible(false)
        table.insert(list, item)
        _height = _height + item:getContentSize().height
    end
    initScrollviewWith(self.bg3.ScrollView, list, 1, 0, 5, 0, 2)
    if len > 0 then
        local i = 0
        local _y = 0
        local function callback()
            i = i + 1
            if i <= len then
                local item = list[i]
                item:setVisible(true)
                local sc_size = self.bg3.ScrollView:getSize()
                local sc_con = self.bg3.ScrollView:getInnerContainer()
                local item_size = item:getContentSize()
                LogMgr.debug(item_size.height)
                _y = _y + item_size.height
                local tmp_h = item_size.height * i
                if tmp_h > sc_size.height then
                    a_moveto(sc_con, 0.3, cc.p(0, -(_height - _y)))
                end
                if i == len then
                    Command.run("item show")
                end
            end
        end
        a_repeate(self, callback, 0.5, len + 1)
    end
end

function ProdCount:onClose()
    self.bg3.container:setVisible(false)
    building_type = nil
    crit_list = {}
    sumValue = nil
end

function ProdCount:dispose()
end

local function showProdCount(data)
    building_type = data.type
    crit_list = data.list
    sumValue = data.sum
    Command.run( 'ui show', 'HolyProdCount', PopUpType.SPECIAL, true )
end
EventMgr.addListener(EventType.showProdCount, showProdCount)