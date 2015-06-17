local prePath = "image/ui/ChatUI/"
ExpressionUntil = class("ExpressionUntil",function() 
    return getLayout(prePath .. "ExpressionUntil.ExportJson")
end)

function ExpressionUntil:ctor()
    ChatCommon.initBtn(self.bg,false)
    self.bg:addTouchEnded(function() 
--        LogMgr.error("[exp=" .. self.data .. "]")
        EventMgr.dispatch(EventType.AddExp, self.data)
    end)
end 

function ExpressionUntil:refreshData(data)
   self.data = data
   local key = string.gsub(self.data, "#", "")
   key = tonumber(key)
   data = ExpressionData.getValuebyKey(key) 
   if data ~= nil then 
        local num = ExpressionData.getNum(data) 
        local list = {}
        if num ~= nil then 
            local num = tonumber(num)
            for i = 1 , num do
                if i < 10 then 
                    table.insert(list, data .. "/" .. "0" .. i .. ".png")
                else 
                    table.insert(list, data .. "/" .. i .. ".png")
                end 
            end      
        end 
        local sprite = nil 
        if num == "1" then 
            sprite = Sprite:createWithSpriteFrame(list[1]) 
        else 
            sprite = AnimateSprite:create(list, true, 1, 0.5,true) 
        end 
        sprite:setPosition(cc.p(self.coin:getPositionX(),self.coin:getPositionY()))
        self.coin:setVisible(false)
        self:addChild(sprite)
   end 
end 

function ExpressionUntil:createView(data)
    local view = ExpressionUntil.new()
    if data ~= nil then 
       view:refreshData(data)
    end 
    return view 
end 
