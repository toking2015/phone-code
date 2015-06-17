local prepath = "image/ui/StoreUI/"
local url = prepath .. "AutoSell.ExportJson"
local url1 = prepath .. "AutoSellUntil.ExportJson"
StoreAutoSell = createUIClass("StoreAutoSell", url,PopWayMgr.SMALLTOBIG)

function StoreAutoSell:ctor()
 
   local l = self.scrollview  -- scrollview
   l = self.coinlabel1    -- 金币label
   l = self.coinlabel2   -- 圣水label
end 

function StoreAutoSell:onShow()
   -- 设置图标列表
    local data = StoreData.getAutoList()
    local itemlist = {}
    local viewlist = {}
    local flag = false 
    local coinsum1 = 0
    local coinsum2 = 0  
    if data ~= nil then 
        for k,v in pairs(data) do 
            if v ~= nil then 
                if v.coin.cate == const.kCoinWater then 
                   coinsum2 = coinsum2 + v.coin.val * v.count
                elseif v.coin.cate == const.kCoinMoney then 
                   coinsum1 = coinsum1 + v.coin.val * v.count
                end 
                table.insert(itemlist ,{first = v.guid ,second = v.count})
                local autountil = StoreAutoUntil:createView({itemid = v.itemid, quality = v.quality,count = v.count,name = v.name})
                table.insert(viewlist,autountil)
            end 
        end 
    end 
    initScrollviewWith(self.scrollview, viewlist, 2, 30, 0, 6, 6)
    self.viewlist = viewlist
    if coinsum1 == 0 then 
        self.coinbg1:setVisible(false)
        self.coin1:setVisible(false)
        self.coinlabel1:setVisible(false)
        self.coinbg2:setPosition(self.coinbg1:getPosition())
        self.coin2:setPosition(self.coin1:getPosition())
        self.coinlabel2:setPosition(self.coinlabel1:getPosition())
    elseif coinsum2 == 0 then 
       self.coinbg2:setVisible(false)
       self.coin2:setVisible(false)
       self.coinlabel2:setVisible(false)
    end 
    self.coinlabel1:setString("X" .. coinsum1)
    self.coinlabel2:setString("X" .. coinsum2)
    
    createScaleButton(self.sure) 
    createScaleButton(self.cancle)
    local function confirmHandler()
        ActionMgr.save( 'UI', 'StoreAutoSell click confirmHandler') 
        LogMgr.debug("itemlist = " .. debug.dump(itemlist))
        Command.run( 'item sell', const.kBagFuncCommon ,itemlist)
        Command.run('ui hide' , 'StoreAutoSell')
        
    end 
    local function cancle ()
        ActionMgr.save( 'UI', 'StoreAutoSell click cancle') 
        Command.run('ui hide' , 'StoreAutoSell')
    end 
    self.sure:addTouchEnded(confirmHandler)
    self.cancle:addTouchEnded(cancle)
    
end 

function StoreAutoSell:onClose()
    if self.viewlist ~= nil then
       for key ,value in pairs(self.viewlist) do
           if value ~= nil and value.update ~= nil then 
              TimerMgr.killPerFrame( value.update)
           end 
       end 
    end 
end  

StoreAutoUntil = class("StoreAutoUntil", function()
    return getLayout(url1)
end)

function StoreAutoUntil:button()
    StoreUntil.button(self)
end 

function StoreAutoUntil:createView(data)
   local view = StoreAutoUntil.new()
   if data.quality ~= nil then 
      -- 选择quality 来选择文字 以及背景bg 
      view.coinbg:loadTexture(ItemData.getItemBgUrl(data.quality),ccui.TextureResType.localType)
      view.coin:loadTexture(ItemData.getItemUrl(data.itemid),ccui.TextureResType.localType)
      view.coin:setScale(0.6)
      view.name:setString(data.name)
      view.name:setColor(ItemData.getItemColor(data.quality))
      view.count:setString("X" .. data.count)
      view.count:setPositionX(view.name:getPositionX() + view.name:getSize().width + 10 )
      view.leixin = const.kCoinItem
      view.itemid = data.itemid 
      createScaleButton(view,false)  
      view:button()
      view:addTouchEnded(function()
            ActionMgr.save( 'UI', 'StoreAutoSell click view') 
            view.reset()
            view:setLocalZOrder(1)
      end)
      
   end 
   return view
end 

