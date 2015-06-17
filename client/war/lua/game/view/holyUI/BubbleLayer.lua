local prePath = "image/ui/HolyUI/HolyBubble/"

BubbleLayer = {}

BubbleLayer.key = "HolyBubbleProd"
BubbleLayer.isBubble = false -- 判断是否产生气泡
BubbleLayer.isget = false
HolyBubble = class("HolyBubble", function()
    return getLayout(prePath .. "Holy_Bubble.ExportJson")
end)

--让上面圣水图片由放大效果
local function showHolyAdd()
    local top = MainUIMgr.getRoleTop()
    top:showIconScale("con_solution")
end 

--创建圣水气泡
function HolyBubble:createHolyBubble()  
    local view = HolyBubble.new()
    BubbleLayer.isBubble = false
    view.bubble:setTouchEnabled(true)

    local function bubbleTouchHandler(sender, eventType)
        ActionMgr.save( 'UI', 'BubbleLayer click collect_bubble' )
        view:collectHolyAction()
    end
    UIMgr.addTouchEnded(view.bubble, bubbleTouchHandler)

    view.list = {}
    view.list = {view.holy_1,view.holy_2, view.holy_3, view.holy_4, view.holy_5, 
                    view.holy_6, view.holy_7, view.holy_8, view.holy_9, view.holy_10, view.bubble} 
   
    view:initHolyBubble()
    
    a_forever_move(view, 0.3 , cc.p(0,2) )  

    view.event_list = {}
    -- local function obtainBubbleData(data)
    --     view.isShow = data.isShow
    --     view.level = data.level
    --     if true == data.isShow then
    --         view:showHolyBubble(data.level)
    --     else
    --         view:initHolyBubble()
    --     end
    -- end
    -- EventMgr.addListener(EventType.BuildingBubbleShow, obtainBubbleData)
    view.event_list[EventType.BuildingBubbleShow] = function(data) view:obtainBubbleData(data) end
    EventMgr.addList(view.event_list)

    TimerMgr.addTimeFun(BubbleLayer.key, function() BuildingData.judgeBubbleByTime() end)

    return view 
end

function HolyBubble:obtainBubbleData(data)
    self.isShow = data.isShow
    self.level = data.level
    -- LogMgr.debug("bubble level = " .. self.level .. ">>>>>>>>>>>>>>>")
    if true == data.isShow then
        self:showHolyBubble(data.level)
    else
        self:initHolyBubble()
    end
end

function HolyBubble:initHolyBubble()
    for _, v in pairs(self.list) do
        v:setVisible(false)
    end
    BubbleLayer.isBubble = false
    BubbleLayer.isget = false
end

function HolyBubble:showHolyBubble(level)
    if self.bubble:isVisible() == false then
        -- self.level = level
        BubbleLayer.isBubble = true -- 是否有气泡
        BubbleLayer.isget = false
        self.bubble:setVisible(true)
        self.list[level]:setVisible(true)
        if 10 == bubbleLevel then
            -- 气泡满级
            TimerMgr.removeTimeFun(BubbleLayer.key)
        end
        self:stopAllActions()
        -- self:setPosition(cc.p(69, 239))
        a_forever_move(self, 0.3 , cc.p(0,2))
    end
end

-- 点击收取圣水
function HolyBubble:collectHolyAction() 
    if BubbleLayer.isget == false then 
        TimerMgr.removeTimeFun(BubbleLayer.key)

        SoundMgr.playEffect("sound/ui/holy.mp3")

        BubbleLayer.isget = true
        BubbleLayer.isBubble = false
        self:initHolyBubble()
        
        Command.run( 'building getoutput', const.kBuildingTypeWaterFactory) -- 收取圣水    
        -- local holy = ccui.ImageView:create("holy_1.png",ccui.TextureResType.plistType)
        -- holy:setPosition(self.list[self.level]:getPosition())
        -- local pos = self.list[self.level]:getPosition()
        -- self:addChild(holy)  

        local curHoly = BuildingData.getCurrProdCount(trans.const.kBuildingTypeWaterFactory)
        if curHoly ~= nil then 
            local coinList = {}
            local data = {cate = const.kCoinWater, objid = 0, val = curHoly}
            table.insert(coinList, data)
            TipsMgr.showItemObtained(coinList)
        end 
        
        local function sendMessage()
            -- Command.run( 'building getoutput', const.kBuildingTypeWaterFactory) -- 收取圣水
            local function callback()
                BuildingData.judgeBubbleByTime()
            end
            TimerMgr.callLater(function()
                    TimerMgr.addTimeFun(BubbleLayer.key, callback) end, 10)
               
            BubbleLayer.isget = false
        end
        a_diverse_move_SpeedDown("holy_1.png", cc.p(699,315), nil , 80 ,0.1 , 4 ,{x= 789 , y = 607}, showHolyAdd, sendMessage)
     end 
end

function HolyBubble:dispose()
    self:removeAllChildren()
    EventMgr.removeList(self.event_list)
    -- EventMgr.removeListener(EventType.BuildingBubbleShow, obtainBubbleData)
    TimerMgr.removeTimeFun(BubbleLayer.key)
end
