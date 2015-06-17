require("lua/game/view/auctionUI/AuctionBuyUntil")
local prepath = "image/ui/AuctionUI/"
local url = prepath .. "AuctionBuy.ExportJson"

local data = {}
local selectType = 4 -- 默认板甲
local selectGounp = 2 -- 默认材料
AuctionBuy = class("AuctionBuy",function() 
    return getLayout(url)
end)

function AuctionBuy.getSelectType()
    return selectType
end 

function AuctionBuy.getSelectGounp()
    return selectGounp
end 

function AuctionBuy.getWindow()
    return PopMgr.getWindow("AuctionUI")
end

function AuctionBuy:ctor()
    buttonDisable(self.scrollview,true)
    self:initBtn()  
     
end 

function AuctionBuy:onShow()
    selectType = 4 -- 默认板甲
    selectGounp = 2 -- 默认材料
    self.setView = function()
        self:initView()
    end
--    EventMgr.addListener(EventType.AuctionUIBuy,self.setView) -- 设置购买显示第一类
    Command.bind( 'refreshAuctionBuy',function() 
        self:initView()
    end)
end 

function AuctionBuy:onClose()
--    EventMgr.removeListener(EventType.AuctionUIBuy,self.setView)
end 

function AuctionBuy:resetBtn()
    self.banbtn:loadTexture("auction_huanseanniu.png",ccui.TextureResType.plistType)
    self.suobtn:loadTexture("auction_huanseanniu.png",ccui.TextureResType.plistType)
    self.pibtn:loadTexture("auction_huanseanniu.png",ccui.TextureResType.plistType)
    self.bubtn:loadTexture("auction_huanseanniu.png",ccui.TextureResType.plistType)
    
    self.banbtn.ban:setColor(cc.c3b(0x73, 0x0b, 0x0b))
    self.suobtn.suo:setColor(cc.c3b(0x73, 0x0b, 0x0b))
    self.pibtn.pi:setColor(cc.c3b(0x73, 0x0b, 0x0b))
    self.bubtn.bu:setColor(cc.c3b(0x73, 0x0b, 0x0b))
end 

function AuctionBuy:showloading()
    Command.run("loading wait show","auctionui")
end 

function AuctionBuy:initBtn()
    self.isTu = false 
    createScaleButton(self.cailiaobtn)
    createScaleButton(self.banbtn)
    createScaleButton(self.suobtn)
    createScaleButton(self.pibtn)
    createScaleButton(self.bubtn)
    createScaleButton(self.tuzhibtn)
    self.tuzhibtn.shang:setVisible(true)
    self.cailiaobtn.xia:setVisible(true)
    self.cailiaobtn.shang:setVisible(false)
    self.tuzhibtn.xia:setVisible(false)
    self.position = {self.cailiaobtn:getPositionY(),self.banbtn:getPositionY(),
        self.suobtn:getPositionY(),self.pibtn:getPositionY(),
        self.bubtn:getPositionY(),self.tuzhibtn:getPositionY()}
    createScaleButton(self.huanbtn)
    
    self:resetBtn()
    self.banbtn:loadTexture("auction_suojiabtn.png",ccui.TextureResType.plistType)
    self.banbtn.ban:setColor(cc.c3b(0x06, 0x35, 0x11))
    -- 换一批
    self.huanbtn:addTouchEnded(function() 
--        AuctionData.sendRefresh ()
        ActionMgr.save( 'UI', 'AuctionBuy click huanbtn' )
        self:showloading()
        Command.run( 'refreshbuylist', selectGounp , selectType, AuctionUI:getT()) 
    end)

    --材料图纸分组
    self.cailiaobtn:addTouchEnded(function() --材料
        ActionMgr.save( 'UI', 'AuctionBuy click huanbtn' )
        if self.isTu == true and AuctionUI.selectView == 1 then  
            self.isTu = false
            self.tuzhibtn.shang:setVisible(true)
            self.cailiaobtn.xia:setVisible(true)
            self.cailiaobtn.shang:setVisible(false)
            self.tuzhibtn.xia:setVisible(false)
            self.cailiaobtn:setPositionY(self.position[1])
            self.banbtn:setPositionY(self.position[2])
            self.suobtn:setPositionY(self.position[3])
            self.pibtn:setPositionY(self.position[4])
            self.bubtn:setPositionY(self.position[5])
            self.tuzhibtn:setPositionY(self.position[6])
            selectGounp = 2
            self:showloading()
            Command.run( 'refreshbuylist', selectGounp , selectType, AuctionUI:getT())
         end 
    end)
    self.tuzhibtn:addTouchEnded(function() --图纸
        ActionMgr.save( 'UI', 'AuctionBuy click tuzhibtn' )
        if self.isTu == false and AuctionUI.selectView == 1 then  
            self.isTu = true 
            self.tuzhibtn.shang:setVisible(false)
            self.cailiaobtn.xia:setVisible(false)
            self.cailiaobtn.shang:setVisible(true)
            self.tuzhibtn.xia:setVisible(true)
            self.cailiaobtn:setPositionY(self.position[1])
            self.tuzhibtn:setPositionY(self.position[2])
            self.banbtn:setPositionY(self.position[3])
            self.suobtn:setPositionY(self.position[4])
            self.pibtn:setPositionY(self.position[5])
            self.bubtn:setPositionY(self.position[6] + 5) 
            selectGounp = 1
            Command.run( 'refreshbuylist', selectGounp , selectType, AuctionUI:getT())
            self:showloading()
            
         end 
    end) 

    self.banbtn:addTouchEnded(function()  -- 板甲
        ActionMgr.save( 'UI', 'AuctionBuy click banbtn' )
        if AuctionUI.selectView == 1 then 
            selectType = 4
            self:resetBtn()
            self.banbtn.ban:setColor(cc.c3b(0x06, 0x35, 0x11))
            self.banbtn:loadTexture("auction_suojiabtn.png",ccui.TextureResType.plistType)
            self:showloading()
            Command.run( 'refreshbuylist', selectGounp , selectType, AuctionUI:getT())
        end 
    end)
    self.suobtn:addTouchEnded(function()  --锁甲
        ActionMgr.save( 'UI', 'AuctionBuy click suobtn' )
        if AuctionUI.selectView == 1 then 
           selectType = 3
           self:resetBtn()
           self.suobtn.suo:setColor(cc.c3b(0x06, 0x35, 0x11))
           self.suobtn:loadTexture("auction_suojiabtn.png",ccui.TextureResType.plistType)
           self:showloading()
           Command.run( 'refreshbuylist', selectGounp , selectType, AuctionUI:getT())
        end 
    end)    
    self.pibtn:addTouchEnded(function()  --皮甲
        ActionMgr.save( 'UI', 'AuctionBuy click pibtn' )
        if AuctionUI.selectView == 1 then
           selectType = 2
           self:resetBtn()
           self.pibtn.pi:setColor(cc.c3b(0x06, 0x35, 0x11)) 
           self.pibtn:loadTexture("auction_suojiabtn.png",ccui.TextureResType.plistType)
           self:showloading()
           Command.run( 'refreshbuylist', selectGounp , selectType, AuctionUI:getT())
        end 
    end)
    self.bubtn:addTouchEnded(function()  --布甲
        ActionMgr.save( 'UI', 'AuctionBuy click bubtn' )
        if AuctionUI.selectView == 1 then 
           selectType = 1
           self:resetBtn()
           self.bubtn.bu:setColor(cc.c3b(0x06, 0x35, 0x11))
           self.bubtn:loadTexture("auction_suojiabtn.png",ccui.TextureResType.plistType)
           self:showloading()
           Command.run( 'refreshbuylist', selectGounp , selectType, AuctionUI:getT())
        end 
    end)
end 

function AuctionBuy:initView()
    local t = AuctionUI:getT()      
    local viewlist =  {} 
    viewlist = AuctionData.getStoreList({selectGounp, selectType ,t})
    -- 从新排序组合
    local newviewlist = {}
    if viewlist ~= nil then 
        for key , value in pairs(viewlist)do
            if value ~= nil then  
                local money = value.money
                local coin = value.coin
                local newtable = nil 
                local flag = false 
                for key1 ,value1 in pairs(viewlist)do 
                    for key2 , value2 in pairs(newviewlist) do
                        if money == value2.money and coin == value2.coin then 
                           flag = true 
                           break 
                        end
                    end 
                    if flag == true then 
                       break 
                    end 
                    if money == value1.money and coin == value1.coin then 
                       if newtable == nil then 
                          newtable = value1
                          newtable.idlist = {}
                          newtable.countlist = {}
                          table.insert(newtable.idlist,value1.guid)
                          table.insert(newtable.countlist,value1.count)
                       else 
                          newtable.count = newtable.count + value1.count 
                          table.insert(newtable.idlist,value1.guid)
                          table.insert(newtable.countlist,value1.count)
                       end 
                    end  
                end
            
                if newtable ~= nil then 
                   table.insert(newviewlist,newtable)
                end 
            end 
        end 
    end 
    
    if self.tableview ~= nil then 
       self.tableview:removeAllChildren(true)
       self.tableview:removeFromParent(true)
       self.tableview = nil 
    end 
    function self.updateItemData(data ,constant, index, i, widthCount)
        if #data - index + 1> 0 then 
            constant:refreshData( data[#data - index + 1] )
        end 
    end

    function self.create()
        return AuctionBuyUntil:createView(nil)
    end
    self.tableview = createTableView(newviewlist,self.create,self.updateItemData,cc.p(self.scrollview:getPositionX(),self.scrollview:getPositionY()-2),self.scrollview:getSize(),cc.size(600,63),self,nil)  

end 

function AuctionBuy:createView()
   local view = AuctionBuy.new()
   return view 
end 