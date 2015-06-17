require("lua/game/view/auctionUI/AuctionBuy")
require("lua/game/view/auctionUI/AuctionSell")
require("lua/game/view/auctionUI/AuctionRecord")
require("lua/game/view/chatUI/ChatCommon")
require("lua/game/view/auctionUI/AuctionCommon")
require("lua/game/view/auctionUI/AuctionUp")
require("lua/game/view/auctionUI/AuctionModify")
local prepath = "image/ui/AuctionUI/"
local url = prepath .. "AuctionBG.ExportJson"
AuctionUI = createUIClass("AuctionUI", url, PopWayMgr.SMALLTOBIG)

AuctionUI.selectView = 1 -- 为购买界面 ， 2 为出售 ，3 为记录

local selectT = 1
function AuctionUI:getT()
    return selectT
end 

function AuctionUI:ctor()
   PopWayMgr.setSTBSkew(50,0) 
   self:initBtn()  
   self.buy = AuctionBuy:createView()
   self.vector:addChild(self.buy) 
   selectT = 1
   self.btnbg.bg.height = self.btnbg.bg:getContentSize().height -- 保存设置原来高度
   self.isFirst = true 
    
end 

function AuctionUI:initBtn()
    -- 是否张开下拉列表
    self.isOpen = false 
    self.recordbtn:setVisible(false)
    self.sellbtn.light:setVisible(false)
    self.recordbtn:setVisible(false)
    self.btnbg.bg:setVisible(false)
    self.btnbg.xuanzebtn.shangla:setVisible(false)
    self.recordbtn.light:setVisible(false)

    self.reset = function ()
        if self.buy ~= nil then
           self.buy:setVisible(false)
        end 
        if self.sell ~= nil then
           self.sell:setVisible(false)
        end 
        if self.record ~= nil then
           self.record:setVisible(false)
        end 
        
    end 
    
    createScaleButton(self.buybtn)
    createScaleButton(self.sellbtn)
    createScaleButton(self.btnbg.xuanzebtn)
    createScaleButton(self.recordbtn)
    for i = 1 , 6 do 
        createScaleButton(self.btnbg.bg["t".. i .. "btn"],false,nil,nil,false)
        self.btnbg.bg["t".. i .. "btn"]:addTouchEnded(function() 
            ActionMgr.save( 'UI', 'AuctionUI click btnbg.bg[t' .. i .. 'btn]' )
            selectT = i 
            self.btnbg.type:setString("T" .. i)
            self.isOpen = false
            self.btnbg.xuanzebtn.shangla:setVisible(true)
            self.btnbg.xuanzebtn.xiala:setVisible(false) 
            self.btnbg.bg:setVisible(false) 
            Command.run("loading wait show","auctionui")  
            Command.run( 'refreshbuylist', AuctionBuy.getSelectGounp() , AuctionBuy.getSelectType(), AuctionUI:getT()) 
        end)
    end 
    

    self.buybtn:addTouchBegan(function()  
        ActionMgr.save( 'UI', 'AuctionUI click down buybtn' )
        self.sellbtn:setLocalZOrder(1)
        self.buybtn:setLocalZOrder(5)
    end)

    self.sellbtn:addTouchBegan(function() 
        ActionMgr.save( 'UI', 'AuctionUI click down sellbtn' )
        self.sellbtn:setLocalZOrder(5)
        self.buybtn:setLocalZOrder(1)
    end)

    self.buybtn:addTouchEnded(function()   -- 购买界面
        ActionMgr.save( 'UI', 'AuctionUI click up buybtn' )
        self.reset()
        AuctionUI.selectView = 1 
        self.recordbtn.light:setVisible(false)
        self.btnbg:setVisible(true)
        self.sellbtn.light:setVisible(false)
        self.recordbtn:setVisible(false)
        if self.buy == nil then
           self.buy = AuctionBuy:createView()
           self.vector:addChild(self.buy) 
        end 
        self.buy:setVisible(true)
        
    end)

    self.sellbtn:addTouchEnded(function()  --出售界面
        ActionMgr.save( 'UI', 'AuctionUI click up sellbtn' )
        self.reset()
        AuctionUI.selectView = 2 
        self.recordbtn.light:setVisible(false)
        self.btnbg:setVisible(false)
        self.sellbtn.light:setVisible(true)
        self.recordbtn:setVisible(true)
        if self.sell == nil then 
           self.sell = AuctionSell:createView()
           self.vector:addChild(self.sell)
        end 
        self.sell:setVisible(true)
    end)
    
    self.recordbtn:addTouchEnded(function() --出售记录界面
        ActionMgr.save( 'UI', 'AuctionUI click up recordbtn' )
        self.reset()
        AuctionUI.selectView = 3 
        self.sellbtn.light:setVisible(false)
        self.recordbtn.light:setVisible(true)
        if self.record == nil then 
            self.record = AuctionRecord:createView()
            self.vector:addChild(self.record)
        end 
        self.record:setVisible(true)
    end)
    
    
    self.btnbg.xuanzebtn:addTouchEnded(function() 
            ActionMgr.save( 'UI', 'AuctionUI click up xuanzebtn' )
            if self.isOpen == false then 
                self.isOpen = true 
                self.btnbg.xuanzebtn.xiala:setVisible(true) 
                self.btnbg.xuanzebtn.shangla:setVisible(false)
                self.btnbg.bg:setVisible(true)
            else
                self.isOpen = false
                self.btnbg.xuanzebtn.shangla:setVisible(true)
                self.btnbg.xuanzebtn.xiala:setVisible(false) 
                self.btnbg.bg:setVisible(false)      
            end
    end) 
    
end 

function AuctionUI:loadOverTime()
    Command.run("loading wait hide","auctionui")
    TipsMgr.showError('请求超时')
end 

function AuctionUI:onShow()
    
    AuctionUI.selectView = 1 
    
    self.setT = function(t)
        if self.isFirst == true then  -- 第一次进来设置一次就行了 
            self.isFirst = false
            selectT = t
            self.btnbg.type:setString("T" .. t)
            local num = selectT -- 按顺序的num个t 显示
            self.btnbg.type:setString("T" .. (num))  
            self.btnbg.bg:setSize(cc.size(self.btnbg.bg:getContentSize().width,(self.btnbg.bg.height - (6 - num) * self.btnbg.bg.t1btn:getContentSize().height)))
            for i = 1 ,6 do
                self.btnbg.bg["t" .. i .. "btn"]:setVisible(false)
            end  
            while num ~= 0 do 
                self.btnbg.bg["t" .. num .. "btn"]:setVisible(true)
                num = num - 1 
            end 
--            EventMgr.dispatch(EventType.AuctionUIBuy )  
        end    
    end  

    if self.buy ~= nil and self.buy.onShow ~= nil then
        self.buy:onShow()
    end 
    if self.sell ~= nil and self.sell.onShow ~= nil then
        self.sell:onShow()
    end 
    
    EventMgr.addListener(EventType.AuctionUIsetT,self.setT) -- 设置t
    EventMgr.addListener(EventType.LoadOverTime,self.loadOverTime,self)
    AuctionData.setAuctionStore() 
end 

function AuctionUI:onClose()
    EventMgr.removeListener(EventType.AuctionUIsetT,self.setT)
    if self.buy ~= nil and self.buy.onClose ~= nil then
        self.buy:onClose()
    end 
    if self.sell ~= nil and self.sell.onClose ~= nil then
        self.sell:onClose()
    end 
    if self.record ~= nil and self.sell.onClose ~= nil then 
        self.record:onClose()
    end
    EventMgr.removeListener(EventType.LoadOverTime,self.loadOverTime)
    Command.run("loading wait hide","auctionui") 
end 
function AuctionUI:backHandler()
    Command.run("loading wait hide","auctionui") 
    PopMgr.removeWindow(self)
end