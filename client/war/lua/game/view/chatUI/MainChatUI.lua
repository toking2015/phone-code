local prePath = "image/ui/ChatUI/"
local RECORDMIN = 1 -- 最小录音时间
require("lua/game/view/chatUI/MainChatUntil")
--require("lua/game/view/chatUI/ChatCommon")
local issound = true -- 是否有声音
MainChatUI= class("MainChatUI",function() 
    return getLayout(prePath .. "MainChatUI.ExportJson")
end)

function MainChatUI:ctor()
   if ChatData.sound_index == 0 then 
      ChatData.sound_index = tonumber(MathUtil.random(100,100000))  -- 制定初始值index
   end 
   createScaleButton(self.bg.sc,false,nil,nil,false)
   createScaleButton(self.bg.chatbtn)
   createScaleButton(self.bg.mailbtn)
   createScaleButton(self.bg,false,nil,nil,false)
   ProgramMgr.setGray(self.bg.recordbtn)
   
   self.autoflag = false
    --录音时间
   self.recordtime = 0 
   self.isrecord = false
   self.bg.mailbtn:setVisible(false)   
   
    self.bg:addTouchEnded(function()
        --聊天按钮
        ActionMgr.save( 'UI', 'MainChatUI click up bg')
        ChatData.isType = "server"
        Command.run('ui show' , 'ChatUI' ,PopUpType.SPECIAL)
    end)
    self.bg.sc:addTouchEnded(function()
        --聊天按钮
        ActionMgr.save( 'UI', 'MainChatUI click up sc')
        ChatData.isType = "server"
        Command.run('ui show' , 'ChatUI' ,PopUpType.SPECIAL)
    end)
   
   self.bg.chatbtn:addTouchEnded(function()
      --聊天按钮
       ActionMgr.save( 'UI', 'MainChatUI click up chatbtn')
       ChatData.isType = "server"
       Command.run('ui show' , 'ChatUI' ,PopUpType.SPECIAL)
   end)

   function self.mailbtnTouch( ... )
       ActionMgr.save( 'UI', 'MainChatUI click up mailbtnTouch')
       ChatData.isType = "mail"
       Command.run('ui show' , 'ChatUI' ,PopUpType.SPECIAL)
   end
   self.bg.mailbtn:addTouchEnded(self.mailbtnTouch)
   
   --录音定时器
   self.update = function( delay )
       if ChatData.isCanChat() == false then 
          ProgramMgr.setGray(self.bg.recordbtn)
          local all = ChatData.getLimitTime()
          local left = ChatData.getLeftTime()
          self.bg.recordbtn.me:setPercent(100 - left/(all + 2 ) * 100)
       else 
           ProgramMgr.setNormal(self.bg.recordbtn.me)
           self.bg.recordbtn.me:setPercent(100)
       end 
       ChatData.updatePlaySound()
       ChatData.addChatNum(delay)
       self:recording(delay)
       if self.recordui ~= nil then 
          self.recordui:recording()
       end 
       local flag = ChatData.getMailFlag()
       if flag == true then 
          self.bg.mailbtn:setVisible(true) 
          self.bg.chatbtn:setVisible(false)
       else 
          self.bg.mailbtn:setVisible(false) 
          self.bg.chatbtn:setVisible(true)
       end 
       setButtonPoint(self.bg.chatbtn, FriendData:getAwaitNum() > 0)
   end
end 

function MainChatUI:recreateRecord()
   self.recordbtn = ccui.ImageView:create("mainchat_yuyinbtn1.png",ccui.TextureResType.plistType)
   self.recordbtn:setPosition(self.bg.recordbtn:getPositionX(),self.bg.recordbtn:getPositionY())
   self.bg.recordbtn:removeFromParent(true)
   self:addChild(self.recordbtn)
end 

function MainChatUI:addRecord()
    self.recordui = ChatRecord:createView()
    self.recordui:setAnchorPoint(cc.p(0.5,0.5))
    local pos = self:convertToNodeSpace( cc.p(visibleSize.width/2,visibleSize.height/2))  -- 转换成局部坐标
    self.recordui:setPosition(cc.p(pos.x ,pos.y  ))
    self:addChild(self.recordui)
end 

function MainChatUI:deleteRecord()
   if self.recordui ~= nil then 
      self.recordui:removeFromParent()
      self.recordui = nil 
   end 
end 

--添加数据
function MainChatUI:addWorld(world)
    if nil ~= self:getParent() then  
        local type = world.type
        local data = ChatData.getWordListBy(type)
        local chatuntil = nil
        if self.chatlist == nil then
           self.chatlist = {}
        end 
        self.autoflag = true
        self.beforheight = 0
        self.afterheight = 0
--        LogMgr.error("gameData.getServerTime()显示 .. " .. gameData.getServerTime())
        self.beforheight = ChatData.getHeight(self.chatlist)
        -- 设置十五条显示
        if #self.chatlist >= ChatData.getNUMLINE() then 
            chatuntil = self.chatlist[1]
            table.remove(self.chatlist,1)   
            chatuntil:refreshData(data[1],type)
            table.insert(self.chatlist,chatuntil)
        else 
            chatuntil = MainChatUntil:createView(data[1],type)
            chatuntil:retain()
            table.insert(self.chatlist,chatuntil)
        end 
        initScrollviewWith(self.bg.sc,self.chatlist , 1, 0, 0, 0, 0)
        if #self.chatlist <= 4 then 
           self.bg.sc:jumpToBottom()
           self.bg.sc.percent = 0
        elseif self.bg.sc.percent ~= nil and self.bg.sc.percent <= 95 then 
           self.bg.sc:jumpToPercentVertical(100 - self.bg.sc.percent ) 
            self.bg.sc:jumpToBottom() 
            self.bg.sc.percent = 0  
        end 
--        self.bg.sc:jumpToBottom() 
    end 
end 

function MainChatUI:removeWorld()
--    if self.chatlist ~= nil and #self.chatlist ~= 0 then 
--        table.remove(self.chatlist,#self.chatlist)
--    end 
end 

--初始化聊天列表，以及切换也用这个
function MainChatUI:initChatList(type)
    self.autoflag = false
    ChatData.setChannel(type) 
    self.chatlist = {}
    local list = ChatData.getInitList()
    for key , value in pairs(list) do
        local view = nil 
        view = MainChatUntil:createView(value,type)
        view:retain()
        table.insert(self.chatlist,1,view)
    end 
    initScrollviewWith(self.bg.sc,self.chatlist , 1, 0, 0, 0, 0)
    TimerMgr.runNextFrame(function() 
        if self ~= nil and self.bg ~= nil and self.bg.sc ~= nil then 
           self.bg.sc:jumpToBottom()
        end 
    end)
    
end 

function MainChatUI:onShow()
    ChatCommon.recordStop()
    if self.recordui ~= nil then 
        self:deleteRecord()
    end 
    
    self:initBtn()
--    createScaleButton(self.bg.recordbtn)
    self:initChatList(const.kCastServer)
    TimerMgr.callPerFrame(self.update)
    EventMgr.addListener(EventType.ShowChatView, self.ShowChatView,self) 
    EventMgr.addListener(EventType.UpdateMainChat, self.addWorld,self)
    EventMgr.addListener(EventType.RemoveMainChat, self.removeWorld,self)
end 

function MainChatUI:onClose()
    TimerMgr.killPerFrame(self.update)
    if self.chatlist ~= nil and #self.chatlist ~= 0 then 
        for key , value in pairs(self.chatlist) do 
            if value ~= nil and value.release ~= nil then 
                value:onClose()
                TimerMgr.releaseLater(value)
                self.chatlist[key] = nil 
            end 
        end 
    end 
    if self.bg.recordbtn.close then
       self.bg.recordbtn.close()
    end
    EventMgr.removeListener(EventType.ShowChatView, self.ShowChatView)
    EventMgr.removeListener(EventType.UpdateMainChat, self.addWorld)
    EventMgr.removeListener(EventType.RemoveMainChat, self.removeWorld)
    ChatData.isPlaying = false
    ChatData.clearSounList()
end 

--发送语音 ，参数为时间
function MainChatUI:sendSound(calculator)
    ChatCommon.setSound(calculator,trans.const.kCastServer)
end 

--计时record
function MainChatUI:recording(t)
    if self.isrecord == false then 
        self.recordtime = 0
    else 
        self.recordtime = self.recordtime + t 
    end 
end 

--初始化按钮以及监听
function MainChatUI:initBtn()
    local btn = self.bg.recordbtn
    ChatCommon.initBtn(btn,nil,true)
    btn:addTouchBegan(function() 
         ChatCommon.out = false
         ActionMgr.save( 'UI', 'MainChatUI click down recordbtn')
         if ChatData.isCanChat() == false then 
            return 
         end 
--        LogMgr.error("ChatCommon.canSend == false")
         if ChatCommon.canSend == true then
--            LogMgr.error("ChatCommon.canSend == true")
             ChatCommon.iscancel = false
             ChatCommon.recordStart()
             self.isrecord = true
             if self.recordui == nil then 
                self:addRecord()
             end 
             if issound == true then 
                SoundMgr.stopAllEffects()
                SoundMgr.pauseAllMusic()
                SoundMgr.setPlayChat(true)
--                LogMgr.error("SoundMgr.setPlayChat(true)")
             end 
             issound = false 
             self.recordui:showRecord()
         end 
    end)
    btn:addTouchMovedIn(function()
        ChatCommon.out = true 
        ActionMgr.save( 'UI', 'MainChatUI click down recordbtn')
         if ChatData.isCanChat() == false then 
            return 
         end 
         if ChatCommon.canSend == true then  
             ChatCommon.iscancel = false
             if issound == true then 
                SoundMgr.stopAllEffects()
                SoundMgr.pauseAllMusic()
                SoundMgr.setPlayChat(true)
--                LogMgr.error("SoundMgr.setPlayChat(true)")
             end 
             issound = false 
             ChatCommon.recordStart()
             self.isrecord = true 
             if self.recordui == nil then 
                self:addRecord()
                self.recordui:showRecord()
             elseif self.recordui ~= nil and self.recordui.recordstart:isVisible() == false then 
                self.recordui:showRecord()
             end 
         end 
         
    end)
    btn:addTouchMoveOut(function() 
        ChatCommon.out = false
        ActionMgr.save( 'UI', 'MainChatUI click up recordbtn')
        if ChatData.isCanChat() == false then 
            return 
        end 
        -- 录音结束
        if ChatCommon.canSend == true then  
            ChatCommon.recordStop()
            if  issound == false then 
               SoundMgr.resumeAllMusic()
               SoundMgr.resumeAllEffect()
               SoundMgr.setPlayChat(false)
--                LogMgr.error("SoundMgr.setPlayChat(true)")
            end 
            issound = true
            self.isrecord = false
            if self.recordui ~= nil then 
               self.recordui:showCancel()
            end 
            ChatCommon.iscancel = true
         end 
    end)
    btn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'MainChatUI click up recordbtn')
        ChatCommon.showTip()
        if ChatData.isCanChat() == false then 
            return 
        end 
        if self.recordui ~= nil then 
           self.recordui:reset()
        end 
        --录音结束 可以发送 
        
        ChatCommon.recordStop()
        if issound == false then 
            SoundMgr.resumeAllMusic()
            SoundMgr.resumeAllEffect()
            SoundMgr.setPlayChat(false)
--            LogMgr.error("SoundMgr.setPlayChat(false)")
        end 
        issound = true
        self:deleteRecord()
        if self.isrecord == true then 
           self:sendSound(self.recordtime)
        end 
        self.isrecord = false
        TimerMgr.callLater(function()ChatCommon.canSend = true end , 2)
    end)
    btn:addTouchCancel(function() 
        ChatCommon.out = true 
        ActionMgr.save( 'UI', 'MainChatUI click up recordbtn')
        ChatCommon.showTip()
        if ChatData.isCanChat() == false then 
            return 
        end 
        ChatCommon.iscancel = true
        if self.recordui ~= nil then 
            self.recordui:reset()
        end 
        ChatCommon.recordStop()
        SoundMgr.resumeAllMusic()
        SoundMgr.resumeAllEffect()
        SoundMgr.setPlayChat(false)
--        LogMgr.error("SoundMgr.setPlayChat(false)")
        issound = true
        self:deleteRecord()
        self.isrecord = false
        ChatCommon.canSend = true 
        TimerMgr.callLater(function()ChatCommon.time = true end , 2)
    end)
end 

function MainChatUI:ShowChatView(data)
    for key , value in pairs(self.chatlist) do 
        if value ~= nil and value.data ~= nil and value.data.sound_index == data.index and value.roleid == data.roleid then 
           if data.isover == false then 
              value.playSound()
           else 
              value.stopSound()
           end 
        end 
    end 
end

function MainChatUI:createView()
   local view = MainChatUI.new()
   return view
end