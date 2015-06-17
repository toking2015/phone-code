-- 聊天录音
local prePath = "image/ui/ChatUI/"
ChatRecord = class("ChatRecord",function() 
    return getLayout(prePath .. "ChatRecord.ExportJson")
end)
local LOCALTIME = 10
local LOCALSOUND = 15
local delaysound = LOCALSOUND
local delaytime = LOCALTIME
function ChatRecord:reset()
    self.recordstart:setVisible(false)
    self.recordcancle:setVisible(false) 
    for i = 1 ,3 do
       self["recordstart"]["hen" .. i]:setVisible(false)
       self["recordstart"]["dian" .. i]:setVisible(false)
    end 
    self.recordvalue = 1
    self.recordsound = 1
end 

function ChatRecord:resetHen()
    for i = 1 ,3 do
        self["recordstart"]["hen" .. i]:setVisible(false)
    end 
end 

function ChatRecord:resetDian()
    for i = 1 ,3 do
        self["recordstart"]["dian" .. i]:setVisible(false)
    end 
end 

function ChatRecord:ctor()
    self:reset()
end 

function ChatRecord:showRecord()
   self:reset()
   self.recordstart:setVisible(true)
end 

function ChatRecord:showCancel()
   self:reset()
   self.recordcancle:setVisible(true) 
end 

function ChatRecord:setSound(num)
    if self.recordstart:isVisible() == true then 
      self:resetHen()
      if num == 1 then   
         self["recordstart"]["hen1"]:setVisible(true) 
      elseif num == 2 then 
         self["recordstart"]["hen1"]:setVisible(true)
         self["recordstart"]["hen2"]:setVisible(true)
      elseif num == 3 then 
         self["recordstart"]["hen1"]:setVisible(true)
         self["recordstart"]["hen2"]:setVisible(true)
         self["recordstart"]["hen3"]:setVisible(true)
      end 
   end 
end 

function ChatRecord:recording()
    if self.recordstart:isVisible() == true then 
        self:resetDian()
        --点
        if self.recordvalue == 1 then 
           self["recordstart"]["dian1"]:setVisible(true)
        elseif self.recordvalue == 2 then 
           self["recordstart"]["dian1"]:setVisible(true)
           self["recordstart"]["dian2"]:setVisible(true)
        elseif self.recordvalue == 3 then 
           self["recordstart"]["dian1"]:setVisible(true)
           self["recordstart"]["dian2"]:setVisible(true)
           self["recordstart"]["dian3"]:setVisible(true)
        end
        delaytime = delaytime - 1 
        if delaytime == 0 then 
           self.recordvalue = self.recordvalue + 1  
           delaytime = LOCALTIME
        end 
        if self.recordvalue > 4 then 
            self.recordvalue = 1 
            delaytime = LOCALTIME
        end       
        
        --声音
        
        self.recordsound = record.getVolume()
--        LogMgr.error("volume .. " .. self.recordsound)
        if self.recordsound == 0 then 
           self.recordsound = 0 
        elseif self.recordsound > 0 and self.recordsound <= 10 then
           self.recordsound = 1
        elseif self.recordsound > 10 and self.recordsound < 30 then 
           self.recordsound = 2
        elseif self.recordsound > 30 and self.recordsound <= 100 then 
           self.recordsound = 3
        end 
        self:setSound(self.recordsound)
--        delaysound = delaysound - 1 
--        if delaysound == 0 then 
--           self.recordsound = self.recordsound + 1 
--           delaysound = LOCALSOUND
--        end 
--        if self.recordsound > 4 then 
--           self.recordsound = 1 
--           delaysound = LOCALSOUND
--        end 

    else 
        -- 点
        self.recordvalue = 1
        delaytime = LOCALTIME
        
        --这里是声音
    end 
end 

function ChatRecord:createView()
   local view = ChatRecord.new()
   return view 
end 