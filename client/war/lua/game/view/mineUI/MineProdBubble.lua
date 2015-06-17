--产生气泡界面
--by weihao  
require "lua/game/view/mineUI/GetMineData.lua"
local prePath = "image/ui/MineUI/MineBubble/"

MineBubble = class("MineBubble", function()
    return getLayout(prePath .. "Bubble_Mine.ExportJson")
end)

--让上面金矿图片由放大效果
local function showMineAdd()
    local top = MainUIMgr.getRoleTop()
    local coin = top.con_gold.img_icon
    local scale1 = cc.ScaleTo:create(0.1,1.5)
    local scale2 = cc.ScaleTo:create(0.1,1)
    local sq = cc.Sequence:create(scale1,scale2)
    if nil ~= coin then 
        coin:runAction(sq)
    end 

end 

function MineBubble:reset()
   for k , v in pairs(self.list) do
       v:setVisible(false)
   end 
end 

--展示时需要处理的数据
function MineBubble:show(type)
      if self.list[11]:isVisible() == false then 
           self.level = type 
           self.list[11]:setVisible(true)
           self.list[type]:setVisible(true)
           if type == 10 then 
                self.list[12]:setVisible(true)
                TimerMgr.removeTimeFun(getMineData.key)
           end
           getMineData.isCoin = true 
--           self:stopAllActions()
           getMineData.isget = false
           self:stopAllActions()
           -- self:setPosition(cc.p(93, 239))
           a_forever_move(self, 0.3 , cc.p(0,2) )
       end 

end

--初始化ui资源，设置所有多为不可视化
function MineBubble:initUI()
    for i = 1, #self.list do
        self.list[i]:setVisible(false)
    end
end 

local function sendMessage()


    -- Command.run( 'building getoutput',const.kBuildingTypeGoldField)
    --收集后延迟10s后开启定时器
    TimerMgr.callLater(function() TimerMgr.addTimeFun(getMineData.key, getMineData.Update) end , 10)
    getMineData.isget = false
end  

function  MineBubble:getCoinAction()
    if getMineData.isget == false then 
        getMineData.isget = true
        TimerMgr.removeTimeFun(getMineData.key)
        self:initUI()

        SoundMgr.playEffect("sound/ui/holy.mp3")
        Command.run( 'building getoutput',const.kBuildingTypeGoldField)
        -- local mine = ccui.ImageView:create("bubble_coin1.png",ccui.TextureResType.plistType)
        -- mine:setPosition(self.list[self.level]:getPosition())
        -- self:addChild(mine)
--        Command.run( 'building getoutput',const.kBuildingTypeGoldField)
        getMineData.isCoin = false
        
        local minesave = math.floor((GameData.getServerTime() - getMineData.oldtime)/60 )* getMineData.prodSpeed
        minesave = minesave + getMineData.curMineCount
        if minesave > getMineData.prodSpeed*8*60 then 
            minesave = getMineData.prodSpeed*8*60
        end 
        if minesave ~= nil then 
            local coinList = {}
            local data = {cate = const.kCoinMoney, objid = 0, val = minesave}
            table.insert(coinList, data)
            TipsMgr.showItemObtained(coinList,nil,nil)
        end 
        
        a_diverse_move_SpeedDown("bubble_coin1.png", cc.p(938, 382), nil, 80, 0.1, 4, {x = 594,y = 611}, function()              
            showMineAdd() end,sendMessage )

    end 
end

--创建金矿气泡
function MineBubble:createMineBubble()  
    local view = MineBubble.new()
--    view:retain()
    view.initposition = {} --位置
    view.level = 1 --金矿等级
    if  not view.bubble:isTouchEnabled() then
       view.bubble:setTouchEnabled(true)
    end
    getMineData.isCoin = false
    view.list ={} 
    view.list = { view.bubble_coin1, view.bubble_coin2, view.bubble_coin3, view.bubble_coin4, view.bubble_coin5, view.bubble_coin6, 
                   view.bubble_coin7, view.bubble_coin8, view.bubble_coin9, view.bubble_coin10, view.bubble,
                    view.bubble_enough }
    view.initposition = cc.p(view.list[1]:getPositionX(),view.list[1]:getPositionY())
    view.list[11]:addTouchEventListener(function (sender, eventType) 
        ActionMgr.save( 'UI', 'MineBubble click view.list[11]')
        if eventType == ccui.TouchEventType.began then 
            view:getCoinAction()
        end 
    end )
   
    view:initUI()
    
    a_forever_move(view, 0.3 , cc.p(0,2) )  
    EventMgr.addListener(EventType.MineBubbleShow, view.show, view)
    EventMgr.addListener(EventType.HideMine, view.reset, view)
    TimerMgr.addTimeFun(getMineData.key, getMineData.Update)
    return view 
end

function MineBubble:dispose()
    self:removeAllChildren()
    TimerMgr.removeTimeFun(getMineData.key)
    EventMgr.removeListener(EventType.HideMine, self.reset)
    EventMgr.removeListener(EventType.MineBubbleShow, self.show)
end
