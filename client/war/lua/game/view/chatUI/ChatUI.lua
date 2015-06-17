-- 聊天ui
-- by weihao
require("lua/game/view/chatUI/ChatRecord")
require("lua/game/view/chatUI/ChatCommon")
require("lua/game/view/chatUI/MChatUntil")
require("lua/game/view/chatUI/TChatUntil")
require("lua/game/view/chatUI/TSoundUntil")
require("lua/game/view/chatUI/MSoundUntil")
require("lua/game/view/friendUI/FriendUI.lua")
require("lua/game/view/chatUI/chatAdd/ChatAdd.lua")
require("lua/game/view/chatUI/ChatExpression/ExpressionUI")

local const_mail = "cont_mail"
local const_haoyou = "cont_haoyou"
local prePath = "image/ui/ChatUI/"
local url = prePath .. "ChatUI.ExportJson"
ChatUI = createUIClass("ChatUI", url ,PopWayMgr.SMALLTOBIG)

local ISLOAD = true  --是否load 
local LOADNUM = 5   --load多少行
local LAWIDTH = 130  --下拉的宽度
local keym1 = 1  --我的文字数量
local keym2 = 1  --我的语音数量
local keyt1 = 1  --他的文字数量
local keyt2 = 1  --他的语音数量

--重置数量
function ChatUI:numReset()
    keym1 = 1  --我的文字数量
    keym2 = 1  --我的语音数量
    keyt1 = 1  --他的文字数量
    keyt2 = 1  --他的语音数量
end 

-- 初始化所有组件
function ChatUI:ctor()
    if ExpressionData.isload == false then 
       LoadMgr.loadPlist("image/ui/ChatUI/ExpressUI.plist", "image/ui/ChatUI/ExpressUI.png", LoadMgr.MANUAL, "expressui")
       ExpressionData.isload = true
    end 
    self.vector:retain()
    self:hideMail()
    PopWayMgr.setSTBSkew(-220,0)

    self.isUpRoleTopView = true

    self:initInput()
    self:initSelect() 
    self:initBtn()
    self.isrecord = false
    self.recordui = nil
    self.recordtime = 0  -- 录音时间
    self.chatlist = {}   -- 显示出来的list
    
    self.viewlistm1 = {}  --我的文字
    self.viewlistm2 = {}  --我的语音
    self.viewlistt1 = {}  --他的文字
    self.viewlistt2 = {}  --他的语音
    
    Command.bind( 'chatother', 
       function(data)
          self:sendMessage(data)
    end )
end 

function ChatUI:addExp(data)
   self.bg.input:setText(self.bg.input:getText() .. data )
end 

-- 打开好友聊天
function ChatUI:showFriendchat()
     self:hideFriendUI()
     self:showChat()
     self.bg.firiendlabel:setVisible(true)
     local data = ChatData.getChatWithFriendData()
     self:initChatList(const_haoyou)
     if data.friend_name ~= nil then 
        ChatCommon.name = data.friend_name
     end 
     self.bg.firiendlabel:setString("与 ".. ChatCommon.name .. " 聊天中...")
end 

function ChatUI:addFriendDetail(role_id)
     -- 如果是自己
     if role_id == gameData.id then
        return
     end
     if self.friend_detail == nil then 
         if self.chatadd ~= nil then 
            self.chatadd:removeFromParent()
            self.chatadd = nil
         end 
         self.friend_detail = FriendDetail.new()
         self.friend_detail.parents = self
         self.friend_detail:setRoleId(role_id)
         self:addChild(self.friend_detail)
         local s_detal = self.friend_detail.getSize and self.friend_detail:getSize() or self.friend_detail:getContentSize()
         self.friend_detail:setPosition(670,578 - s_detal.height)
     else 
        self.friend_detail:onClose()
        self.friend_detail:removeFromParent()
        self.friend_detail = nil 
     end 
end 

-- 打开时候
function ChatUI:onShow()
    self.gonghui1:setVisible(false)
    self.gonghui2:setVisible(false)
    Command.run( 'friend list')
    self.flag = false
    self.refreshflag = false
    self.update = function( delay )
        if ChatData.isCanChat() == false then 
            if ChatData.getChannel() ~= const_haoyou then 
                ProgramMgr.setGray(self.bg.yuyin)
                local all = ChatData.getLimitTime()
                local left = ChatData.getLeftTime()
                self.bg.yuyin.me:setPercent(100 - left/(all+2) * 100)
            else 
                ProgramMgr.setNormal(self.bg.yuyin)
            end 
        else 
            ProgramMgr.setNormal(self.bg.yuyin.me)
            self.bg.yuyin.me:setPercent(100)
        end 
        self:recording(delay)
        if self.recordui ~= nil then
            self.recordui:recording()
        end 
    end
    TimerMgr.callPerFrame(self.update)
    performNextFrame(self,self.loadView)
    

    if ChatData.isType == "mail" then 
        self.tab:setSelectedIndex(4)
        ChatData.setChannel(const_mail)
        self:hideChat() 
        self:showMail()
    elseif ChatData.isType == "haoyou" then 
        self.tab:setSelectedIndex(3)
        self:hideChat()
        self:hideMail()
        ChatData.setChannel(const_haoyou)
        self:showFriendUI()
    end 
    
end 

function ChatUI:ShowChatView(data)
    for key , value in pairs(self.chatlist) do 
        if value.sound_index == data.index and value.roleid == data.roleid then  
            if value.data.isover == false then 
                value.playSoundView()
            else 
                value.stopSound()
            end 
        end 
    end 
end 

function ChatUI:addLister()
    EventMgr.addListener(EventType.AddExp, self.addExp,self)  
    EventMgr.addListener(EventType.ShowChatView, self.ShowChatView,self)  
    EventMgr.addListener(EventType.UpdateChat, self.addWorld,self)  
    EventMgr.addListener(EventType.addFriendDetail, self.addFriendDetail,self)
    EventMgr.addListener(EventType.ShowFriendChat, self.showFriendchat,self)
end 

-- 关闭时候
function ChatUI:onClose()
--    self.bg.input:getEventDispatcher():removeEventListener(self.listener)  
    ChatCommon.reset()
    ChatData.saveYuyin()  
    self:removeView()
    self.vector:release()
    TimerMgr.killPerFrame(self.update)
    EventMgr.removeListener(EventType.AddExp, self.addExp)  
    EventMgr.removeListener(EventType.ShowChatView, self.ShowChatView) 
    EventMgr.removeListener(EventType.ShowFriendChat, self.showFriendchat)
    EventMgr.removeListener(EventType.UpdateChat, self.addWorld)
    
    if self.mailbox and self.mailbox:getParent() then
        self.mailbox:releaseAll()
    end
    if self.rid then TimerMgr.killTimer(self.rid) end
    self.rid = nil

    if self.friend_ui then
        self.friend_ui:onClose()
        self.friend_ui:release()
    end
    FriendData.isFriendChatId = nil
    --self:hideFriendUI()
end 

--添加数据
function ChatUI:addWorld(world)
    local type = world.type
    local data = ChatData.getWordListBy(type)
    local chatuntil = nil
    local percent = 0
    local beforheight = 0

    if #self.chatlist >= 60 then -- 保持最多60个对象retain
       chatuntil = self.chatlist[#self.chatlist]
       table.remove(self.chatlist,#self.chatlist)
       chatuntil:removeFromParent(true)
       chatuntil:release() 
       chatuntil = nil 
       chatuntil = self:createChatUntil(data[1]) 
    else 
       chatuntil = self:createChatUntil(data[1]) 
    end 

    if chatuntil.roleid ~= gameData.id and chatuntil.issound == true and ChatData.isPlaying == false then 
        chatuntil.playSoundView()
    end 
    table.insert(self.chatlist ,chatuntil)
    initScrollviewWith(self.bg.sc,self.chatlist , 1, 0, 0, 0, 0)
    self:initScrollview()
    if #self.chatlist <= 4 then 
        self.bg.sc:jumpToBottom()
        self.bg.sc.percent = 0
    elseif self.bg.sc.percent ~= nil and self.bg.sc.percent <= 95 then 
        self.bg.sc:jumpToPercentVertical(100 - self.bg.sc.percent )  
    else
        self.bg.sc:jumpToTop()
        self.bg.sc.percent = 100
    end 
    self.afterheight = ChatData.getHeight(self.chatlist)

--    local flag = ChatData.getMoreFlag()
--    if flag == true then 
--        self:addRefresh()
--    end 
end 

function ChatUI:removeView()
   for i = 1 ,2 do 
       if self["viewlistm" .. i] ~= nil then  -- 消除自己人
           for key ,value in pairs(self["viewlistm" .. i]) do 
                if value ~= nil  then 
                    if value.release ~= nil then 
                        value:release()
                    end 
                end 
           end 
       end 
       if self["viewlistt" .. i] ~= nil then  -- 消除他人
           for key ,value in pairs(self["viewlistt" .. i]) do 
                if value ~= nil  then 
                    if value.release ~= nil then 
                        value:release()
                    end 
                end  
                self["viewlistt" .. i][key] = nil 
           end 
       end 
   end 
end 
-- loadView 
function ChatUI:loadView()
   if ISLOAD == true then 
      for i = 1 ,LOADNUM do
          local viewm1 = MChatUntil:createView()
          local viewm2 = MSoundUntil:createView()
          local viewt1 = TChatUntil:createView()
          local viewt2 = TSoundUntil:createView()
          viewm1:retain()
          viewm2:retain()
          viewt1:retain()
          viewt2:retain()
          table.insert(self.viewlistm1,viewm1)
          table.insert(self.viewlistm2,viewm2)
          table.insert(self.viewlistt1,viewt1)
          table.insert(self.viewlistt2,viewt2)
      end 
   end 
   
    
    -- 开始初始化
    if ChatData.isFriend == true then
        ChatData.isFriend = false
        self.tab:setSelectedIndex(3)
        self:hideChat()
        self:hideMail()
        ChatData.setChannel(const_haoyou)
        self:showFriendUI()
    elseif ChatData.isType == "server" then 
        self.tab:setSelectedIndex(1)
        self:initChatList(const.kCastServer)
        self:showChat()
    elseif ChatData.isType == "guild" then
        self.tab:setSelectedIndex(2) 
        self:initChatList(const.kCastGuild)
        self:showChat()
    end 
    ChatData.isType = "server"
    self:addLister()
end 

--发送语音 ，参数为时间
function ChatUI:sendSound(calculator)
    ChatCommon.setSound(calculator,ChatData.getChannel())
end 

--发送文字
function ChatUI:sendMessage(data)
    ChatCommon.sendMessage(self.bg.input,data)
end


--计时record
function ChatUI:recording(t)
    if self.isrecord == false then 
        self.recordtime = 0
    else 
        self.recordtime = self.recordtime + t 
    end 
end 

--添加刷新数据
function ChatUI:addRefresh()
    -- 加入刷新
--    self.refresh = ChatRefresh:createView()
--    self.refresh:retain()
--    local h = self.refresh:getSize().height
--    self.refresh:setPosition(8 , -h)
--    self.sc_chat:addChild(self.refresh)
end 

--隐藏邮件
function ChatUI:hideMail()
    if self.vector ~= nil  then 
        local parent = self.vector:getParent()
        if parent ~= nil then 
            self.vector:removeFromParent(true)
--            self.sc:setLocalZOrder(2)
        end 
        if self.mailbox and self.mailbox:getParent() then
            self.mailbox:releaseAll()
            self.mailbox:removeFromParent()
            self.mailbox = nil
        end
    end 
end 

--展示邮件
function ChatUI:showMail()
    if self.vector ~= nil  then 
        local parent = self.vector:getParent()
        if parent == nil then 
            self:addChild(self.vector)
--            self.sc:setLocalZOrder(0)
        end 
    end 
    self.vector:setVisible(true)
    local mailbox = NMailBoxUI:create()
    self.vector:addChild(mailbox, 3)
    mailbox:setAnchorPoint(cc.p(0, 0))
    mailbox:setPosition(cc.p(-4, -4))
    self.mailbox = mailbox
end 

-- 隐藏聊天 
function ChatUI:hideChat()
--    print("self .. " .. debug.dump(self))
    self.bg:setVisible(false)
    if self.chatadd ~= nil then  
        self.chatadd:removeFromParent()
        self.chatadd = nil 
    end 
    if self.friend_detail ~= nil then 
        self.friend_detail:onClose()
        self.friend_detail:removeFromParent()
        self.friend_detail = nil 
    end 
end 

-- show聊天
function ChatUI:showChat()
    self.bg.firiendlabel:setVisible(false)
    self.bg:setVisible(true) 
end 

-- 增加record
function ChatUI:addRecord()
    self.recordui = ChatRecord:createView()
    self.recordui:setAnchorPoint(cc.p(0.5,0.5))
    local pos = self:convertToNodeSpace( cc.p(visibleSize.width/2,visibleSize.height/2))  -- 转换成局部坐标
    self.recordui:setPosition(cc.p(pos.x,pos.y))
    self:addChild(self.recordui,5)
end 

-- 删除record
function ChatUI:deleteRecord()
    if self.recordui ~= nil then 
        self.recordui:removeFromParent()
        self.recordui = nil 
    end 
end 

function ChatUI:createChatUntil(value) 
     local view = nil
     if value.type == ChatCommon.other then 
        if value.length == 0 then  -- 其他非语音的
           if self.viewlistt1[keyt1] ~= nil then 
              view = self.viewlistt1[keyt1]
              view:refreshData(value)
           else 
              view = TChatUntil:createView(value)
              view:retain()
              table.insert(self.viewlistt1,view)
           end 
           keyt1 = keyt1 + 1 
        else  -- 其他的语音
            if self.viewlistt2[keyt2] ~= nil then 
                view = self.viewlistt2[keyt2]
                view:refreshData(value)
            else 
                view = TSoundUntil:createView(value)
                view:retain()
                table.insert(self.viewlistt2,view)
            end 
            keyt2 = keyt2 + 1 
        end
      elseif value.type == ChatCommon.me then  
           if value.length == 0 then  -- 自己非语音的
              if self.viewlistm1[keym1] ~= nil then 
                   view = self.viewlistm1[keym1]
                   view:refreshData(value)
              else 
                   view = MChatUntil:createView(value)
                   view:retain()
                   table.insert(self.viewlistm1,view)
              end 
              keym1 = keym1 + 1 
           else  -- 其他的语音
              if self.viewlistm2[keym2] ~= nil then 
                 view = self.viewlistm2[keym2]
                 view:refreshData(value)
              else 
                 view = MSoundUntil:createView(value)
                 view:retain()
                 table.insert(self.viewlistm2,view)
              end 
              keym2 = keym2 + 1 
           end
     end 
     return view 
end 

--初始化聊天列表，以及切换也用这个
function ChatUI:initChatList(type)
    self.chatlist = {}
    ChatData.setChannel(type) 
    local list = {}
    if type == const_haoyou then 
       local id = ChatData.getChatWithFriendData().friend_id
       list = ChatData.getFriendChatList(id)
    else 
       list = ChatData.getInitList()
    end 
    if list ~= nil then 
        for key , value in pairs(list) do
            if value ~= nil then  -- 当数据不为nil
                local view = nil 
                view = self:createChatUntil(value)
                if view ~= nil then     
                    table.insert(self.chatlist,1,view)
                end 
            end 
        end 
    end 
    -- 判断是否要加入加入刷新
    initScrollviewWith(self.bg.sc,self.chatlist , 1, 0, 0, 0, 0)
    self:initScrollview()
    self.bg.sc:jumpToBottom()
--    local flag = ChatData.getMoreFlag()
--    if flag == true then 
--        self:addRefresh()
--    end 

end 

--初始化scrollview
function ChatUI:initScrollview()
-- 增加滚动监听
    self.scrolling = function() 
        self.refreshflag = false
--        print("self.sc.prev_y .. " .. self.sc.prev_y)
--        cc.Sprite:getContentSize()
--        print("- self.sc.ph .. " .. - self.sc.ph)
        if self.bg.sc.prev_y ~= nil and self.bg.sc.prev_y < - self.bg.sc.ph then 
            self.refreshflag = true 
        else 
            self.refreshflag = false
        end 
        if self.refreshflag == false then 
            self:hideRefresh()
        else 
            self:showRefresh()         
        end 
    end 
    self.bg.sc.scrollFun(self.scrolling)
    self.bg.sc.scrolltop(function() 
        self:addRefreshList()
    end)

end 

--隐藏刷新
function ChatUI:hideRefresh()
--     print("不显示刷新")
     self.flag = false
end 

--移除刷新导航条
function ChatUI:removeRefresh()
   
end 

-- 显示松开刷新聊天
function ChatUI:showRefresh()
--    print("显示刷新")
    self.flag = true 
end 

--添加刷新list
function ChatUI:addRefreshList()
    if self.flag == true then 
        self.beforheight = ChatData.getHeight(self.chatlist)
        local list = ChatData.getMoreList()
        if list ~= nil and #list ~= 0 then 
            for i = 1  , #list do
                local value = list[i]
                if value ~= nil then  -- 当数据不为nil
                    local view = nil 
                    view = self:createChatUntil(value)
                    if view ~= nil then     
                        table.insert(self.chatlist,1,view)
                    end 
                end 
            end 
            initScrollviewWith(self.bg.sc,self.chatlist , 1, 0, 0, 0, 0) 
            self:initScrollview()
            if #list == 15  then 
                self:addRefresh()  
            end 
        end 
        self.afterheight = ChatData.getHeight(self.chatlist)
        local percent = ( (self.afterheight - self.beforheight )/self.afterheight) * 100
        if percent ~= 0 then 
          self.bg.sc:jumpToPercentVertical(percent)
        end 
--        print("percent .. " .. percent)
    end
end 

--初始化input
function ChatUI:initInput()
    local txt_input = self.bg.txt_input
    local t_size = txt_input:getSize()
    self.bg.input = TextInput:create(t_size.width, t_size.height)
    FontStyle.applyStyle(self.bg.input, FontStyle.ZH_5)
    self.bg.input:setPlaceHolder("请输入文字                    ")
    self.bg.input:setFontColor(cc.c3b(255, 221, 179))
    self.bg.input:setPosition(0, t_size.height/2)
    self.bg.input:setMaxLength(50)  --设置最多字数
    self.bg.chatvector:addChild(self.bg.input, 2)
    txt_input:setVisible(false)
    self.bg.input:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" then 
--           LogMgr.error(strEventName)
           self:sendMessage()
        end 
    end
    self.bg.input:registerScriptEditBoxHandler(editBoxTextEventHandle)
--    self.bg.input:registerScriptEditBoxHandleR(editBoxTextEventHandle)
end 

--初始化按钮
function ChatUI:initBtn()
    createScaleButton(self.bg.add)
    createScaleButton(self.bg.biaoqing)
    createScaleButton(self.bg.clean)
    ChatCommon.initBtn(self.bg.yuyin)
    ChatCommon.initBtn(self.bg.kuan,false)
    ChatCommon.initBtn(self.bg.anniu,false)
    local flag = ChatData.getCloseSound()
    if flag == false then 
        self.bg.duihao:setVisible(true)
    else 
       self.bg.duihao:setVisible(false)
    end 
    self.bg.duihao:setLocalZOrder(1)
    self.bg.kuan:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ChatUI click kuan') 
        if self.bg.duihao:isVisible() == true then 
            self.bg.duihao:setLocalZOrder(0)
            self.bg.duihao:setVisible(false)
           ChatData.setCloseSound(true) 
        else 
            self.bg.duihao:setLocalZOrder(1)
            self.bg.duihao:setVisible(true)
           ChatData.setCloseSound(false) 
        end 
    end)
    self.bg.add:addTouchEnded(function()
--        PaomaData.receiveData({text = "#1 枫减肥#1 [font=GG_WHITE]的身份#1 京津冀#1 " ,order = 0})
        ActionMgr.save( 'UI', 'ChatUI click add') 
        if self.chatadd == nil then 
           if self.friend_detail ~= nil then 
              self.friend_detail:removeFromParent()
              self.friend_detail = nil 
           end  
           if self.chatexp ~= nil then 
              self.chatexp:removeFromParent()
              self.chatexp = nil 
           end  
           self.chatadd = ChatAdd:createView()
           self.chatadd:setPosition(670,0)
           self:addChild(self.chatadd,2)
        else 
           self.chatadd:removeFromParent()
           self.chatadd = nil 
        end 
    end)
    self.bg.biaoqing:addTouchEnded(function()  -- 表情 

--        PaomaData.receiveData({flag = const.kPlacardFlagScene,order = 0 , text = "[font=GG_NAME]#17 玩家#17 名字[font=GG_NORMAL]#16 将 [font=GG_WHITE] 英雄名字[font=GG_NORMAL] 升到了 [font=GG_WHITE]3星！松岛枫减肥的身份" })
        if self.chatexp == nil then 
            if self.friend_detail ~= nil then 
                self.friend_detail:removeFromParent()
                self.friend_detail = nil 
            end  
            if self.chatadd ~= nil then 
                self.chatadd:removeFromParent()
                self.chatadd = nil 
            end  
            self.chatexp = ExpressionUI:createView()
            self.chatexp:setPosition(670,0)
            self:addChild(self.chatexp,2)
        else 
            self.chatexp:removeFromParent()
            self.chatexp = nil 
        end 
--        TipsMgr.showError("功能尚未开启")
        ActionMgr.save( 'UI', 'ChatUI click biaoqing') 
    end)
    self.bg.clean:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ChatUI click clean') 
        self.bg.input:setText("")
    end)   

    self.bg.yuyin:addTouchBegan(function() 
        ActionMgr.save( 'UI', 'ChatUI click down yuyin') 
        ChatCommon.out = true 
        if ChatCommon.time == false then 
            return 
        end 
        ChatCommon.time = false
        
        if ChatData.isCanChat() == false then 
            return 
        end 
        if ChatCommon.canSend == true then
            -- 开始录音
            SoundMgr.stopAllEffects()
            SoundMgr.pauseAllMusic()
            SoundMgr.setPlayChat(true)
            if self.recordui == nil then 
                self:addRecord()
            end 
            if self.isrecord == false then 
                ChatCommon.recordStart()
            end 

            self.isrecord = true
            if self.recordui ~= nil then 
                self.recordui:showRecord()
            end 
            ChatCommon.iscancel = false
        end
    end)
    self.bg.yuyin:addTouchMovedIn(function() 
        ChatCommon.out = true 
        ActionMgr.save( 'UI', 'ChatUI click down yuyin') 
        if ChatCommon.time == false then 
            return 
        end 
        ChatCommon.time = false
        if ChatData.isCanChat() == false then 
            return 
        end 
        if ChatCommon.canSend == true then
            SoundMgr.stopAllEffects()
            SoundMgr.pauseAllMusic()
            SoundMgr.setPlayChat(true)
            if self.recordui == nil then 
                self:addRecord()
                self.recordui:showRecord()
            elseif self.recordui ~= nil and self.recordui.recordstart:isVisible() == false then 
                self.recordui:showRecord()
            end 
            if self.isrecord == false then 
                ChatCommon.recordStart()
            end 
            self.isrecord = true 
            ChatCommon.iscancel = false
        end
    end)
    self.bg.yuyin:addTouchMoveOut(function() 
        ChatCommon.out = false  
        ActionMgr.save( 'UI', 'ChatUI click up yuyin') 
        if ChatData.isCanChat() == false then 
            return 
        end 
        -- 录音结束
        if ChatCommon.canSend == true then
            SoundMgr.resumeAllMusic()
            SoundMgr.resumeAllEffect()
            SoundMgr.setPlayChat(false) 
            if self.isrecord == true then 
                ChatCommon.recordStop()
            end 
            self.isrecord = false
            if self.recordui ~= nil then 
                self.recordui:showCancel()
            end 
            ChatCommon.iscancel = true
        end
    end)
    self.bg.yuyin:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ChatUI click up yuyin') 
        ChatCommon.showTip()
        if ChatData.isCanChat() == false then 
            return 
        end 
        SoundMgr.resumeAllMusic()
        SoundMgr.resumeAllEffect()
        SoundMgr.setPlayChat(false)
        if self.recordui ~= nil then 
           self:deleteRecord()
        end   
        if self.isrecord == true then 
           ChatCommon.recordStop()
        end 
        self:sendSound(self.recordtime)
        self.isrecord = false
        TimerMgr.callLater(function()ChatCommon.time = true ChatCommon.canSend = true end , 2)
    end)
    self.bg.yuyin:addTouchCancel(function()
        ChatCommon.out = false 
        ActionMgr.save( 'UI', 'ChatUI click up yuyin')  
        ChatCommon.showTip()
        if ChatData.isCanChat() == false then 
            return 
        end 
        SoundMgr.resumeAllMusic()
        SoundMgr.resumeAllEffect()
        SoundMgr.setPlayChat(false)
        if self.isrecord == true then 
            ChatCommon.recordStop()
        end 
        if self.recordui ~= nil then 
            self:deleteRecord()
        end   
        self.isrecord = false
        ChatCommon.iscancel = true
        ChatCommon.canSend = true 
        TimerMgr.callLater(function()ChatCommon.time = true end , 2)
    end)
    
    
end 

-- 初始化左边的导航条
function ChatUI:initSelect() 
    
    createScaleButton(self.shijie1)
    createScaleButton(self.haoyou1)
    createScaleButton(self.gonghui1)
    createScaleButton(self.mail1)
  
    createScaleButton(self.shijie2,false,nil,nil,false)
    createScaleButton(self.gonghui2,false,nil,nil,false)
    createScaleButton(self.haoyou2,false,nil,nil,false)
    createScaleButton(self.mail2,false,nil,nil,false)
--    self.gonghui1:setVisible(false)
--    self.gonghui2:setVisible(false)
    local list = {
        {btn_selected = self.shijie2, btn_unselected = self.shijie1},
        {btn_selected = self.gonghui2, btn_unselected = self.gonghui1},
        {btn_selected = self.haoyou2, btn_unselected = self.haoyou1},
        {btn_selected = self.mail2, btn_unselected = self.mail1}
    }
    local data = {trans.const.kCastServer, trans.const.kCastGuild,const_haoyou,const_mail}
    self.tab = createTab(list, data,true)

    local rp_pos = cc.p(0, 50)
    local function showRedPoint()
        setButtonPointWithNum(self.mail2, ChatData.getMailFlag(), MailBoxData.countUnReadMail(), rp_pos)
        setButtonPointWithNum(self.mail1, ChatData.getMailFlag(), MailBoxData.countUnReadMail(), rp_pos)
        setButtonPointWithNum(self.haoyou1, FriendData:getAwaitNum() > 0, FriendData:getAwaitNum(), rp_pos)
        setButtonPointWithNum(self.haoyou2, FriendData:getAwaitNum() > 0, FriendData:getAwaitNum(), rp_pos)
    end
    if not self.rid then self.rid = TimerMgr.startTimer(showRedPoint, 1) end

    local function handler(value)
        -- local mail_content = PopMgr.getWindow("MailContent")
        self:hideFriendUI()
        if value.data ~= const_mail and value.data ~= const_haoyou then 
            ActionMgr.save( 'UI', 'ChatUI click up chat') 
            self:hideMail()
            self:showChat()
            ChatData.setChannel(value.data)
            self:numReset()
            self:initChatList(value.data)
        elseif value.data == const_mail then 
            -- 展示邮件
            ActionMgr.save( 'UI', 'ChatUI click up mail') 
            self:hideChat()
            self:showMail()
            ChatData.setChannel(const_mail)

        elseif value.data == const_haoyou then 
            -- 点击好友
            --setVilsible(false)
            ActionMgr.save( 'UI', 'ChatUI click up const_haoyou') 
            self:hideChat()
            self:hideMail()
            ChatData.setChannel(const_haoyou)
            -- if mail_content and mail_content:isShow() then
            --     Command.run("mailContent close")
            --     mail_content = nil
            -- end
            self:showFriendUI()
        end 
    end
    self.tab:addEventListener(self.tab, handler)
end 

function ChatUI:showFriendUI( ... )
    if self.vector:getParent() == nil then
        self:addChild(self.vector)
    end
    self.vector:setVisible(true)
    if self.friend_ui == nil then
        self.friend_ui = FriendUI:new()
        self.friend_ui:retain()
    end
     self.vector:addChild(self.friend_ui)
     self.friend_ui:addMainUI(self)
     self.friend_ui:onShow()
     FriendData.isFriendChatId = nil
end

function ChatUI:hideFriendUI( ... )
    if self.vector:getParent() ~= nil then
       self.vector:removeFromParent()
    end
    if self.friend_ui then
        if self.friend_ui:getParent() then
            self.friend_ui:removeFromParent()
        end
    end
end

function ChatUI:backOtherth( ... )
    local doOtherth
    if self.friend_ui and self.friend_ui:isVisible() then
        doOtherth = self.friend_ui:hideOtherAllWin()
    end

    if FriendData.isFriendChatId and ChatData.getChannel() == const_haoyou then
        self:hideChat()
        self:showFriendUI()
        doOtherth = true
    end
    return doOtherth
end

function ChatUI:backHandler()
    ActionMgr.save( 'UI', 'ChatUI click up backHandler')
    if self.chatadd ~= nil then  
        self.chatadd:removeFromParent()
        self.chatadd = nil 
        return 
    end 
    if self.chatexp ~= nil then 
        self.chatexp:removeFromParent()
        self.chatexp = nil 
        return 
    end  
    if self.friend_detail ~= nil then 
       self.friend_detail:onClose()
       self.friend_detail:removeFromParent()
       self.friend_detail = nil 
       return 
    end 
    if not self:backOtherth() then
        self:doBack()
    end
end

function ChatUI:doBack(isSave, notCheckEmptyHp)
    PopMgr.removeWindow(self)
end

