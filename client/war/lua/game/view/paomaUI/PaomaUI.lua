local prePath = "image/ui/PaomaUI/"
PaomaUI= class("PaomaUI",function() 
    return getLayout(prePath .. "PaomaUI.ExportJson")
end)

function PaomaUI:ctor()
   if ExpressionData.isload == false then 
      LoadMgr.loadPlist("image/ui/ChatUI/ExpressUI.plist", "image/ui/ChatUI/ExpressUI.png", LoadMgr.MANUAL, "expressui")
      ExpressionData.isload = true
   end 
   PaomaData.setShowData()
   local data = PaomaData.getData()
   self.time = 5
   self.movelength = 25
   self.move1 = 0
   self.move2 = 0
   local timetest = 0 
   local time3 = 10 
   self.update = function(dt)
   
--       timetest = timetest + dt 
--       time3 = time3 - dt 
--       if timetest >= 8 then 
--          local pd_data = {}
--          pd_data = {flag = const.kPlacardFlagScene,order = 0 , text = "[font=GG_NAME]玩家名字[font=GG_NORMAL] 将 [font=GG_YELLOW] 英雄名字[font=GG_NORMAL] 升到了 [font=GG_YELLOW]3星！"}
--          timetest = 0 
--          PaomaData.receiveData(pd_data)
--       end 
   
       if self:getParent() == nil then 
          return 
       end 
       data = PaomaData.getData()
       self:setPositionX(366)
       local flag = false
       if data == nil or #data == 0 then 
          flag = false
       else 
          flag = true 
       end
       if self.textshow ~= nil or self.textshow1 ~= nil then
          flag = true 
       end 
       self.time = self.time + dt 
       if self.time >= 5 and self:isVisible() == true then 
          if self.movelength > 0  then
             self.movelength = self.movelength - 0.5
             if self.textshow ~= nil then
                self.textshow:setPositionY(self.textshow:getPositionY()+0.5)
                self.move1 = self.textshow:getPositionY()
             end 
             if self.textshow1 ~= nil then
                self.textshow1:setPositionY(self.textshow1:getPositionY()+0.5)
                self.move2 = self.textshow1:getPositionY()
             end 
          else 
             self.time = 0
             self.movelength = 25
          end  
          
         if self.move1 == 25 or self.move2 == 25 then 
             PaomaData.reduceData()
             PaomaData.setShowData()
             data = PaomaData.getData()
             if data ~= nil and #data ~= 0 then 
                self:refresh(data)
             end
          elseif self.move1 > 25 or self.move2 > 25 then 
             data = PaomaData.getData()
             if data ~= nil and #data ~= 0 then 
                if self.textshow == nil or self.textshow1 == nil then 
                    self:refresh(data)
                    self.time = 5 
                    self.movelength = 25
                end 
             end
          end 
           
          if self.move1 > 49 then 
             if self.textshow ~= nil then 
                self.textshow:removeFromParent(true)
                self.textshow = nil 
             end 
             self.move1 = 0 
          end 
          
          if self.move2 > 49 then 
             if self.textshow1 ~= nil then 
                self.textshow1:removeFromParent(true)
                self.textshow1 = nil 
             end 
             self.move2 = 0            
          end    
       end 
       if flag ~= self:isVisible() then 
          data = PaomaData.getData()
          if data ~= nil and #data ~= 0 then 
             self:refresh(data)
          end 
          EventMgr.dispatch(EventType.PaomaEvent,flag )  
       end   
   end  
   
   
   
end 

function PaomaUI:init()
    self:setVisible(false)
end 

function PaomaUI:onShow()
    if self.textshow1 ~= nil then 
        self.textshow1:removeFromParent(true)
        self.textshow1 = nil 
    end 
    if self.textshow ~= nil then 
        self.textshow:removeFromParent(true)
        self.textshow = nil 
    end 
    self.time = 5 
    self.movelength = 25
    self.move1 = 0
    self.move2 = 0
    TimerMgr.callPerFrame(self.update)
     
end 

function PaomaUI:onClose()
    TimerMgr.killTimer(self.updata)
    if self.textshow1 ~= nil then 
        self.textshow1:removeFromParent(true)
        self.textshow1 = nil 
    end 
    if self.textshow ~= nil then 
        self.textshow:removeFromParent(true)
        self.textshow = nil 
    end 
    self.time = 5 
    self.movelength = 25
    self.move1 = 0
    self.move2 = 0
end 

function PaomaUI:refresh(data)  
    local text = ""
    if data ~= nil then
       for key , value in pairs(data) do 
           if value ~= nil then 
                text = text .. value.text 
           end 
       end
       if self.textshow == nil then 
          self.textshow = cc.Node:create()
          self.vector:addChild(self.textshow) 
          self.textshow:setPositionY(0) 
          RichTextUtil:DisposeRichText(text,self.textshow,nil,0,660,3,1)
          local ntext = string.gsub(text,"%b[]","")
          local label = cc.Label:create()
          label:setString(ntext)
          local size = label:getContentSize()
          local width = size.width
          local alllength = 430 
          local percent = width/alllength
          local length = ( 1 - percent ) * alllength/2
          self.textshow:setPositionX(length) 
       elseif self.textshow1 == nil then 
          self.textshow1 = cc.Node:create()
          self.vector:addChild(self.textshow1) 
          self.textshow1:setPositionY(0) 
          RichTextUtil:DisposeRichText(text,self.textshow1,nil,0,660,3,1)
          local ntext = string.gsub(text,"%b[]","")
          local label = cc.Label:create()
          label:setString(ntext)
          local size = label:getContentSize()
          local width = size.width
          local alllength = 430 
          local percent = width/alllength
          local length = ( 1 - percent ) * alllength/2
          self.textshow1:setPositionX(length) 
       end     
       
    end 
end 

function PaomaUI:createView(data)
   local view = PaomaUI.new()
   if data ~= nil then 
      view:refresh(data)
   end 
   return view 
end 
