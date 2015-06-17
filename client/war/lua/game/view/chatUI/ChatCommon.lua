ChatCommon = {}
local RECORDMIN = 1 -- 最小录音时间

ChatCommon.canSend = true --是否可以发送
ChatCommon.seconds = 0  -- 秒数
ChatCommon.chancel = nil --是那个平台
ChatCommon.iscancel = false --是否取消发送
ChatCommon.other = "other"  -- 其他
ChatCommon.me = "me"  -- 自己
ChatCommon.name = "wo"  --名字
ChatCommon.time = true  -- 限制点击频率
ChatCommon.out = false --在外边out
local startTime = 0 -- 开始多少次
local setHour = 0   -- 记录显示小时
local setMinute = 0   --记录显示分钟
local add_height = 30 -- 固定值30一行
local WORLDX = 400 --文字宽度
local SPACE = 50   --空白
local UNTIL = 19 --每个字的高度是19 
local const_mail = "cont_mail"
local const_haoyou = "cont_haoyou"

function ChatCommon.isCanSound() 
    if ChatData.isCanChat() == false then 
        return 
    end 
end 

function ChatCommon.reset()
    setHour = 0   -- 记录显示小时
    setMinute = 0   --记录显示分钟
end 

-- 时间限制 秒数
function ChatCommon.showTip()
    if ChatData.isCanChat() == false then 
        TipsMgr.showError('莫急请等待'.. ChatData.getLeftTime() .. '秒')
        return 
    end 
end 

-- 禁言显示tip
function ChatCommon.showPostTip()
    TipsMgr.showError('你暂时被禁言了')
end 

-- btn按钮， type 是否放大， mainflag 是否为主界面按钮
function ChatCommon.initBtn(btn ,type,mainflag)
 --触碰事件开始
    if type == nil then 
        btn.presstype = true
    else 
        btn.presstype = type
    end 
    btn.startlocaltion = nil 
    btn.endlocaltion = nil 
    btn.mainflag = mainflag
    btn.onTouchBegan = nil
    btn.onTouchMovedIn = nil
    btn.onTouchMovedOut = nil
    btn.onTouchEnded = nil
    btn.onTouchCancel = nil
    
    -- 设置光亮
    local function setBtnGray(btn, shaderName, uniform)
        local programState = ProgramMgr.createProgramState(shaderName)
        if uniform then
            programState:setUniformFloat("u_multiple", uniform)
        end
        local isCCUI = (string.find(tolua.type(btn), "ccui.") == 1)
        if isCCUI == true then
            local render = btn:getVirtualRenderer()
            if tolua.type(render) ~= "cc.Label" then
                if render ~= nil then
                    render:setGLProgramState( programState )
                end
                local list = btn:getChildren()
                for _, v in pairs(list) do
                    setBtnGray(v, shaderName, uniform)
                end
            end
        end
    end
    
    function btn:addTouchBegan(func)
        btn.onTouchBegan = func
    end
    function btn:addTouchMovedIn(func)
        btn.onTouchMovedIn = func
    end
    function btn:addTouchMoveOut(func)
        btn.onTouchMovedOut = func
    end 
    function btn:addTouchEnded(func)
        btn.onTouchEnded = func
    end
    function btn:addTouchCancel(func)
        btn.onTouchCancel = func
    end

    function btn.touchBeginHandler(touch, eventType)
        local flag = ChatCommon.isPress (touch ,btn)
        btn.startlocaltion = touch:getLocation()
        if flag == true then
            if nil ~= btn.onTouchBegan then
                btn.onTouchBegan()
            end
            setBtnGray(btn, "light", 1.25)
            if btn.presstype == true then 
               btn:setScale(1.1)
            end 
            return true   
        end  
        return false
    end
    
    --触碰事件移动
    function btn.touchMoveHandler(touch, eventType)
          local flag = ChatCommon.isPress (touch ,btn)
          if flag == true then
            if nil ~= btn.onTouchMovedIn then
                btn.onTouchMovedIn()
            end
          else
            -- 录音结束
            if nil ~= btn.onTouchMovedOut then
                btn.onTouchMovedOut()
            end
          end  
    end
    --触碰事件抬起
    function btn.touchEndedHandler(touch, eventType)
        if btn.presstype == true then 
            btn:setScale(1.0)
        end         
        btn.endlocaltion = touch:getLocation()
        setBtnGray(btn, "normal")
        local flag = ChatCommon.isPress (touch ,btn)
        if flag == true then
            if nil ~= btn.onTouchEnded then
                btn.onTouchEnded()
            end
        else 
            if nil ~= btn.onTouchCancel then
                btn.onTouchCancel()
            end
        end
        
    end
    -- 触碰事件取消
    function btn.touchCancelHander(touch , eventType)
        if btn.presstype == true then 
            btn:setScale(1.0)
        end
        setBtnGray(btn, "normal")
        if nil ~= btn.onTouchCancel then
            btn.onTouchCancel()
        end
    end

    local parent = SceneMgr.getLayer(SceneMgr.LAYER_SCENE_EFFECT)
    local touchTarget = btn.mainflag and parent or btn
    ChatCommon.createListenerForBtn(btn, touchTarget)
    
    btn.close = function()
        if btn._chatTouchListener then
            btn._chatEventDispatcher:removeEventListener(btn._chatTouchListener)
            btn._chatTouchListener = nil
            btn._chatEventDispatcher = nil
        end
    end 
end

function ChatCommon.createListenerForBtn(btn, target)
    local listener = btn._chatTouchListener
    if not listener then
        listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(btn.touchBeginHandler, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(btn.touchMoveHandler, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(btn.touchEndedHandler, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(btn.touchCancelHander, cc.Handler.EVENT_TOUCH_CANCELLED)
        btn._chatTouchListener = listener
        local eventDispatcher = target:getEventDispatcher()    
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target)
        btn._chatEventDispatcher = eventDispatcher
    end

end

-- 是否已经按下
function ChatCommon.isPress (touch ,bnt)
    local location = touch:getLocation()
    if  bnt ~= nil and bnt:getParent() ~= nil  then 
        local location1 = bnt:getParent():convertToWorldSpace( cc.p(bnt:getPositionX(), bnt:getPositionY())) 
        local rect = bnt:getBoundingBox()
        rect.x = location1.x - rect.width/2
        rect.y = location1.y - rect.height/2
        local flag = cc.rectContainsPoint(rect, location)
        return flag
    else 
        return false
    end
end


-- 关于view的操作
function ChatCommon.setSound(calculator, type )
    if ChatCommon.canSend == true then
        ChatCommon.canSend = false
        ChatCommon.seconds = calculator  -- 秒数
        if type ~= nil then     
           ChatCommon.chancel = type --是那个平台
        end 
    end 
end 

function ChatCommon.sendSound(calculator,type,result)
--    if gameData.getServerTime() > ReportPostData.getTime() then 
--        ChatCommon.showPostTip()
--        return 
--    end 
    -- data 作为名字以及一些信息
    if record.isrecord ~= nil then 
       local flag = record.isrecord()
    end 
    if calculator ~= nil and calculator >= RECORDMIN then 
        local soundpath = "temp/recording.mp3"
        LogMgr.log( 'debug',soundpath)
        local stream = seq.read_stream_file( soundpath )
--        local stream = nil
        local data = {}
        data.type = ChatData.getChannel()
        if type ~= nil then 
            data.type = type
        end 
        data.msg = stream
        data.text = result
        local time = calculator
        if time > 10 then 
            showMsgBox("[image=alert.png][font=ZH_3]  录音时间过长（需十秒内）[btn=one]")
        else 
            data.time = time * 1000
--            data.time = 0
--			LogMgr.info("data .. " .. debug.dump(data))
            if data.type == const_haoyou then 
                 data.friend_id = ChatData.getChatWithFriendData().friend_id
                 Command.run( 'chatfriendsound',data)
            else
                 Command.run( 'chatsound',data)
            end 
           
        end 
    end 
end

function ChatCommon.sendMessage(input,data)
    if data == nil then 
        if ChatData.isCanChat() == false then 
            ChatCommon.showTip()
            return 
        end 
    end 
    -- 暂时先在世界频道发言
    LogMgr.log( 'debug',"sendMessage......")
    local msg = input:getText()
    local senddata = {}
    senddata.type = ChatData.getChannel()--trans.const.kCastServer
    if msg ~= "" or data ~= nil then
        if msg ~= "" and data == nil then 
            if string.find(msg, "## ") == 1 then
                input:setText("")
                local command = string.gsub(msg, "## ", "")
                LogMgr.log( 'debug',"command = " .. command)
                Command.parse( command )
                return
            end
            input:setText("") 
            if string.find(msg, "$$ ") ~= 1 then 
                msg = WordFilter.filter(msg)
            end 
            senddata.msg = msg
        end 
        
        if data ~= nil then 
           senddata.text_ext = data
        end   
        if senddata.type == const_haoyou then 
           senddata.friend_id = ChatData.getChatWithFriendData().friend_id
           Command.run( 'chatfriendmessage',senddata)
        else
--           local key = string.find(senddata.msg, "#")
--           local key1 = string.find(senddata.msg, " ")
--           local str2 = "" 
--           if key ~= nil and key1 ~= nil then 
--              if key < key1 then 
--                 local str2 = string.sub(senddata.msg, key+1, key1-1) -- 
--              end 
--           end 
           Command.run( 'chatmessage',senddata)
        end 

    end


end

local function callback(result, isLast,serror)
    ChatCommon.iscancel = false
    ChatCommon.canSend = true
    if ChatCommon.out == true then 
        --            LogMgr.error("fasong")
        if isLast == 1 or isLast == true then
            -- 识别完成后发送
            result = WordFilter.filter(result)
            ChatCommon.sendSound(ChatCommon.seconds,ChatCommon.chancel,result)
        else
            --识别失败
            LogMgr.info(serror)
            if ChatCommon.iscancel == false then 
                ChatCommon.sendSound(ChatCommon.seconds,ChatCommon.chancel,"语音转文字失败")
            end 
        end
    end 

end

function ChatCommon.recordStart()

--    LogMgr.error(" ChatCommon.canSend into")
    if ChatCommon.canSend == true then 
--        LogMgr.error("ChatCommon.canSend == true ")
        if record.isrecord ~= nil then 
--            LogMgr.error("record.isrecord ~= nil")
            local flag = record.isrecord()
            if flag == false then 
--                LogMgr.error("record.isrecord() == false")
                if startTime == 0 then 
                   record.start(callback) --开始录音
                   startTime = 1 
                end 
            end
        else 
                if startTime == 0 then 
                   record.start(callback) --开始录音
                   startTime = 1 
                end 
        end 
    else 
        TipsMgr.showError("稍等!正在识别发送")
    end 
end 

function ChatCommon.recordStop()
    if ChatCommon.canSend == true then
        if record.isrecord ~= nil then 
            local flag = record.isrecord()
            if flag == true then 
                record.stop()
            end
        else 
            record.stop() --开始录音  
        end 
    else 
        ChatCommon.canSend = true 
    end 
--    TimerMgr.callLater(function()callback("不装", 1,"不转") end , 1)
    startTime = 0 
end 

--------------------------------------------界面公用实现 ---------------------------------------------
function ChatCommon.setTimeView(view,data)
    view.timebg:setVisible(false)
    local flag = false
    if data.isshow ~= nil then 
       flag = data.isshow 
    else 
        if setHour == 0 and setMinute == 0 then 
            flag = true 
        elseif view.hour ~= setHour or view.minute ~= setMinute then 
            flag = true 
        end 
    end 
    if flag == true then 
        setHour = view.hour   -- 记录显示小时
        setMinute = view.minute   --记录显示分钟
        local str = "" 
        if setHour - 10 < 0 then
            str = str .. "0" ..  view.hour .. ":"
        else 
            str = str ..  view.hour .. ":"
        end
        if setMinute - 10 < 0 then 
            str = str .. "0" ..  view.minute
        else 
            str = str ..  view.minute
        end  
        view.timebg:setVisible(true)
        view.timebg.timelabel:setString(str)
        if data.isshow == nil then 
            data.isshow = true
        end 
    else 
        data.isshow = false
    end 

end 

-- 设置声音view
function ChatCommon.setSoundView(view1,data,type) 
    local view = view1.view
    view.data = data
    if view.rich_text ~= nil then 
        view.rich_text:removeFromParent()
        view.rich_text = nil
    end 
    if view.name_text ~= nil then 
        view.name_text:removeFromParent()
        view.name_text = nil
    end 
   local namestr = fontNameString("CHAT_1_1")
   if type == ChatCommon.me then 
      namestr = fontNameString("CHAT_1_3")
   end 
   ChatCommon.initBtn(view.sound ,false)
   createScaleButton(view.stop ,false)
   createScaleButton(view.play ,false)
   view.stop:setVisible(false)
   view.play:setVisible(true)
   view.length = data.length/1000
    
    if data.time == nil then 
       data.time = gameData.getServerTime()
    end 
    view.time = data.time 
    view.hour = DateTools.getHour(data.time)
    view.minute = DateTools.getMinute(data.time)
    view.second = DateTools.getSecond(data.time)
    view.roleid = data.role_id 
    view.effectid = nil 
    view.sound_index = data.sound_index
    view.miaoshu:setString( math.floor(view.length) .. "''")
    view.sound:setPercent(100) -- 语音的时间百分比
    -- 重置聊天大小
    view:setSize(cc.size(view.size_this.width,view.size_this.height))
    view:setPositionY(0)
    local label = cc.Label:create()
    label:setString("一二三四五六七八九十一二三")
    local max_width = label:getContentSize().width 
    local max_height = label:getContentSize().height 
    label:setString(data.text)
    local label_width = label:getContentSize().width 
    local label_height = label:getContentSize().height 

    label:setString("lv 120 一二三四五六")
    local name_max_width = label:getContentSize().width
    label:setString("lv " .. data.level .. " ".. data.name)
    local name_width = label:getContentSize().width
    
    -- 设置名字
    view.nvector:removeAllChildren(true)
    view.name_text = cc.Node:create()
    local namestr = namestr .. "lv " .. data.level .. " ".. data.name
    RichTextUtil:DisposeRichText(namestr,view.name_text,nil,0,WORLDX,1,SPACE)
    view.nvector:addChild(view.name_text)
    
    -- 显示文字
    view.rich_text = cc.Node:create()
    local yuyinstr = fontNameString("CHAT_1_5")
    local str = nil 
    str =  yuyinstr .. "{}"  .. data.text --这里写文字
    RichTextUtil:DisposeRichText(str,view.rich_text,nil,0,WORLDX,3,SPACE)
    view.vector:addChild(view.rich_text)
    local label = cc.Label:create()
    --设置聊天大小（在这里判断设置）
    label:setString(data.text)
--    view:setAnchorPoint(cc.p(1,1))
    if label_width/(max_width ) > 1.5 then 
        view:setPositionY(view.size_this.height * ( label_width/max_width-1)*0.1)
        view1:setSize(cc.size(view.size_this.width,view.size_this.height * ((label_width/max_width))*0.6 ))
    end 
    if label_width/(max_width ) > 2 and label_width/(max_width ) < 3 then
        view:setPositionY(view.size_this.height * ( label_width/max_width-1)*0.1)
        view1:setSize(cc.size(view.size_this.width,view.size_this.height * ((label_width/max_width))*0.5 ))
    end 

    if label_width/(max_width ) > 3 then
        view:setPositionY(view.size_this.height * ( label_width/max_width-1)*0.1)
        view1:setSize(cc.size(view.size_this.width,view.size_this.height * ((label_width/max_width))*0.4 ))
    end 
    
    if type == ChatCommon.other then 
        view.sound:setPercent(50 + view.length/10 * 100)
        local test = 110 
        view.miaoshu:setPositionX(view.miaoshuP - test*(70 - view.length/10 * 100)/100)
        view.yuyin1:setPositionX(view.yuyin1P - test*(70 - view.length/10 * 100)/100)
        view.yuyin2:setPositionX(view.yuyin2P - test*(70 - view.length/10 * 100)/100)
        view.yuyin3:setPositionX(view.yuyin3P - test*(70 - view.length/10 * 100)/100) 
        if view.length <= 2 then 
            view.sound:setPercent(50)
            view.miaoshu:setPositionX(view.miaoshuP - test)
            view.yuyin1:setPositionX(view.yuyin1P - test)
            view.yuyin2:setPositionX(view.yuyin2P - test)
            view.yuyin3:setPositionX(view.yuyin3P - test)
        elseif view.length >= 7 then 
            view.sound:setPercent(100)
            view.miaoshu:setPositionX(view.miaoshuP )
            view.yuyin1:setPositionX(view.yuyin1P )
            view.yuyin2:setPositionX(view.yuyin2P )
            view.yuyin3:setPositionX(view.yuyin3P )
        end 
        
    elseif type == ChatCommon.me then 
        view.sound:setPercent(50 + view.length/10 * 100)
        local test = 110 
        view.miaoshu:setPositionX(view.miaoshuP + test*(70 - view.length/10 * 100)/100)
        view.yuyin1:setPositionX(view.yuyin1P + test*(70 - view.length/10 * 100)/100)
        view.yuyin2:setPositionX(view.yuyin2P + test*(70 - view.length/10 * 100)/100)
        view.yuyin3:setPositionX(view.yuyin3P + test*(70 - view.length/10 * 100)/100) 
        if view.length <= 2 then 
            view.sound:setPercent(50)
            view.miaoshu:setPositionX(view.miaoshuP + test)
            view.yuyin1:setPositionX(view.yuyin1P + test)
            view.yuyin2:setPositionX(view.yuyin2P + test)
            view.yuyin3:setPositionX(view.yuyin3P + test)
        elseif view.length >= 7 then 
            view.sound:setPercent(100)
            view.miaoshu:setPositionX(view.miaoshuP )
            view.yuyin1:setPositionX(view.yuyin1P )
            view.yuyin2:setPositionX(view.yuyin2P )
            view.yuyin3:setPositionX(view.yuyin3P )
        end 
        if name_width/name_max_width <= 1 then       
            view.name_text:setPositionX(0 + (100 * (1 - name_width/name_max_width)))
        end 
        if label_width/max_width <= 1 then 

            --            view.rich_text

            view.rich_text:setPositionX(0 + (320 * (1-label_width/max_width)))
        end 
    end 
    local url = TeamData.getAvatarUrlById(data.avater)  -- 设置头像
    if url then
        view.coin:loadTexture(url, ccui.TextureResType.localType)
    end



    view.playSoundView = function()
        view.stop:setVisible(true)
        view.play:setVisible(false)
        TimerMgr.callLater(view.stopSound,view.length) 
    end 

    --开始播放
    view.playSound = function()
        view.stop:setVisible(true)
        view.play:setVisible(false)
        ChatData.isPlaying = true 
        if view.hour ~= nil and view.roleid ~= nil and view.minute ~= nil and view.second ~= nil then 
            SoundMgr.stopAllEffects()
            SoundMgr.setMusicValume(0.1)
            local flag = ChatData.isHaveSound(data.role_id,data.sound_index)
            if flag == true then 
--               LogMgr.log("flag .. true")
               local soundpath = "temp/sound/" .. view.hour .. "/" .. view.roleid .. "_" .. view.minute .. "_" .. view.second .. ".mp3"
--               LogMgr.log(soundpath)
               view.effectid = SoundMgr.playChat(soundpath)
               TimerMgr.callLater(view.stopSound,view.length)
               SoundMgr.setPlayChat(true)
            else 
--               LogMgr.log("flag .. false")
               ChatData.getSound(data.role_id,data.sound_index) 
            end 
        end 
    end 
    --结束播放
    view.stopSound = function()
        ChatData.isPlaying = false
        if view ~= nil and view.stop ~= nil and view.play ~= nil then 
           view.stop:setVisible(false)
           view.play:setVisible(true)
        end 
        if view.effectid ~= nil then 
            SoundMgr.stopEffect(view.effectid)
            view.effectid = nil 
        end 
        SoundMgr.setPlayChat(false)
        SoundMgr.resumeAllEffect()
        SoundMgr.resetMusicValume()
    end 

    view.sound:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ChatCommon click sound') 
        if ChatData.isPlaying == false then 
            if view.stop:isVisible() == false then 
               view.playSound()
            else
                view.stopSound()
            end 
        end 
    end )
    view.play:addTouchEnded(function()
        ActionMgr.save( 'UI', 'ChatCommon click play') 
        if ChatData.isPlaying == false then 
            view.playSound()
        end 
    end)
    view.stop:addTouchEnded(function()
        ActionMgr.save( 'UI', 'ChatCommon click stop') 
        if ChatData.isPlaying == false then 
            view.stopSound()
        end 
    end)
    ChatCommon.setTimeView(view,data)

end 

-- 设置文字
function ChatCommon.setTextView(view1,data,type) 
   local view = view1.view
   view.data = data
   view.roleid = data.role_id
   if data.time == nil then 
      data.time = gameData.getServerTime()
   end 
   view.hour = DateTools.getHour(data.time)
   view.minute = DateTools.getMinute(data.time)
   view.second = DateTools.getSecond(data.time)
    
   if view.rich_text ~= nil then 
      view.rich_text:removeFromParent()
      view.rich_text = nil
   end 
   if view.name_text ~= nil then 
      view.name_text:removeFromParent()
      view.name_text = nil
   end 
   local namestr = fontNameString("CHAT_1_1") 
   if type == ChatCommon.me then 
      namestr = fontNameString("CHAT_1_3")
   end  
   -- 设置文字
   view.vector:removeAllChildren(true)
   view.vector:setSize(view.vector.size_this)
   view.rich_text = cc.Node:create()
   view.rich_text:setAnchorPoint(0,0)
   local str = "" .. fontNameString("CHAT_1_2") .. "{}" 
   if data.text == nil then 
      data.text = ""
   end 
   str = str ..  ExpressionData.changeString(data.text,fontNameString("CHAT_1_2"))
    
   local tal = ""
   local text = {}
   if data.text_ext ~= nil and data.text_ext ~= "" then 
      text  = string.split(data.text_ext,"..")
      tal = Json.decode(text[1])
   end 
--   print("tal .. " .. debug.dump(tal))
   local thingname = nil  
   if view.lbg.addTouchBegan ~= nil then 
      view.lbg:addTouchBegan(nil) 
   end 
--   local pos1  = view:getParent():convertToWorldSpace( cc.p(view:getPositionX(), view:getPositionY()) )
--   local pos = cc.p(view.lbg:getPositionX(),view.lbg:getPositionY() )
   local jTotem = nil 
   local itemtype = nil 
   local fntstr = fontNameString("CHAT_1_4")
   local quality = 1 
   if tal.leixin ~= nil then 
        if tal.leixin == ChatAddData.ZHUAN then  --装备
           jTotem = findItem(tal.item_id)
           thingname = jTotem.name
           itemtype = ChatAddData.ZHUAN
        elseif  tal.leixin == ChatAddData.DIAO then  --雕文
            jTotem = findTempleGlyph(tal.id)
            thingname = jTotem.name
            itemtype = TipsMgr.TYPE_RUNE
        elseif  tal.leixin == ChatAddData.TU then  --图腾
            jTotem = findTotem(tal.id)
            thingname = jTotem.name 
            itemtype = TipsMgr.TYPE_TOTEM
        elseif  tal.leixin == ChatAddData.YING then  --英雄
           --还没实现
            jTotem = findSoldier(tal.id)
            thingname = jTotem.name 
            itemtype = TipsMgr.TYPE_SOLDIER_WIN
        elseif  tal.leixin == ChatAddData.WU then  --物品
            jTotem = findItem(tal.item_id)
            thingname = jTotem.name 
            itemtype = TipsMgr.TYPE_ITEM
        elseif tal.leixin == ChatAddData.TAO then -- 套装
            if tal.equip_type == 1 then 
               thingname = "T" .. tal.level .. "布甲"
            elseif tal.equip_type == 2 then 
               thingname = "T" .. tal.level .."皮甲"
            elseif tal.equip_type == 3 then 
               thingname = "T" .. tal.level .."锁甲"
            elseif tal.equip_type == 4 then 
               thingname = "T" .. tal.level .."板甲"
            end 
            itemtype = TipsMgr.TYPE_ITEM
            jTotem = {}
            jTotem.quality = tal.level
        end 
        if itemtype ~= nil then 
            createScaleButton(view.lbg,false,nil,nil,false)
            view.lbg:addTouchBegan(function() 
                ActionMgr.save( 'UI', 'ChatCommon click lbg') 
                local pos = view:getParent():convertToWorldSpace( cc.p(view:getPositionX(), view:getPositionY()) )
                local gp = cc.p(pos.x,pos.y  )
                if type == ChatCommon.me then 
                   gp = cc.p(pos.x - 200,pos.y  )
                else 
                   gp = cc.p(pos.x + 200,pos.y  )
                end 
                if tal.leixin == ChatAddData.TU  then -- 图腾
                    Command.run( 'chattotem' ,tal.target_id,tal.totem_id)
                elseif  tal.leixin == ChatAddData.YING then  --英雄
                    Command.run( 'chatsoldier' , tal.target_id ,tal.soldier_guid) 
                elseif tal.leixin == ChatAddData.ZHUAN then  -- 装备
                    EquipmentData:showEquipmentTips( view,tal )
                elseif tal.leixin == ChatAddData.TAO then --套装
                    Command.run( 'chatequip' ,tal.target_id ,tal.equip_type , tal.level) 
                else
                   TipsMgr.showTips(gp, itemtype, jTotem, tal)
                end
                
            end)
        end 
        if jTotem ~= nil and jTotem.quality ~= nil then 
           quality = jTotem.quality
           if  tal.leixin == ChatAddData.TU then 
               quality = tal.level 
           elseif  tal.leixin == ChatAddData.YING then 
               quality = SoldierData.getQualityAndNum(tal.quality)
           elseif tal.leixin == ChatAddData.ZHUAN then
               quality = tal.quality
           elseif tal.leixin == ChatAddData.TAO then
               quality = tal.level
           end 
           if quality == 1 then 
                fntstr=  fontNameString("CHAT_1_10")
                -- 白色
           elseif quality == 2 then
                fntstr=  fontNameString("CHAT_1_6")
                --聊天18号绿色
           elseif quality == 3 then 
                fntstr=  fontNameString("CHAT_1_7")
                 --聊天18号蓝色
           elseif quality == 4 then 
                fntstr=  fontNameString("CHAT_1_8")
                --聊天18号紫色
           elseif quality == 5 then
                fntstr=  fontNameString("CHAT_1_9")
                 --聊天18号橙色
           end 
        end 
   end 
   if thingname ~= nil then 
      str = str .. fntstr .. " " .. "【" .. thingname .. "】" 
   end 
   RichTextUtil:DisposeRichText(str,view.rich_text,nil,0,WORLDX,1,SPACE)
   view.addheight = 0
   view.beforeheight = view.vector.size_this.height
   view.afterheight = view.vector.size_this.height
   if view.rich_text:getContentSize().height > view.beforeheight then
        view.vector:setSize(cc.size(view.vector.size_this.width,view.rich_text:getContentSize().height)) 
        view.afterheight = view.vector:getSize().height
   end
   view.addheight = view.afterheight - view.beforeheight
   view.vector:addChild(view.rich_text)
   
   local url = TeamData.getAvatarUrlById(data.avater)
   if url then
      view.coin:loadTexture(url, ccui.TextureResType.localType)
   end

   local label = cc.Label:create()
   label:setString("一二三四五六七八九十一二三四五六七八九")
   local max_width = label:getContentSize().width 
   local max_height = label:getContentSize().height 
   if thingname ~= nil then 
      label:setString(data.text .. "【】 " ..thingname)
   else
      local text = string.split(data.text , "]") 
      if text[2] ~= nil then 
         local str  =  ""
          for i = 1 , #text do
              if text[i] ~= nil and text[i] ~= "" then 
                 str  = string.gsub(data.text,"%b[]","一1")
              end 
         end 
         label:setString(str )
      else 
         label:setString(data.text )
      end  
   end 
   local label_width = label:getContentSize().width 
   local label_height = label:getContentSize().height 
   
   label:setString("lv 120 一二三四五六")
   local name_max_width = label:getContentSize().width
   label:setString("lv " .. data.level .. " ".. data.name)
   local name_width = label:getContentSize().width

    -- 设置名字
   view.nvector:removeAllChildren(true)
   view.name_text = cc.Node:create()
   local namestr = namestr .. "lv " .. data.level .. " ".. data.name
   RichTextUtil:DisposeRichText(namestr,view.name_text,nil,0,WORLDX,1,SPACE)
   view.nvector:addChild(view.name_text)
    local beishu = math.ceil(label_width/max_width )
    if beishu == 3 then 
        beishu = 2 
    elseif beishu == 2 then 
        beishu = 1.5
    elseif beishu > 3 then 
        beishu = 3  
    else 
        beishu = 1
    end 
    -- 排版定位设置
   if type == ChatCommon.other then 
--        view.lbg:setSize(cc.size(view.lbg.size_this.width * (label_width/max_width) ,view.lbg.size_this.height * (label_height/max_height)))
        if label_width/max_width >= 1 then 
--            print("label_width/max_width .. " .. label_width/max_width)
            view.lbg:setSize(cc.size(view.lbg.size_this.width ,view.lbg.size_this.height * beishu))

        else 
            view.lbg:setSize(cc.size(view.lbg.size_this.width * (label_width/max_width + 0.01) ,view.lbg.size_this.height ))
            if label_width/max_width <= 0.08 then 
                view.lbg:setSize(cc.size(view.lbg.size_this.width * (0.1 + 0.01) ,view.lbg.size_this.height * beishu))
            end 
        end  
    elseif type == ChatCommon.me then 

        view.lbg:setSize(cc.size(view.lbg.size_this.width * (label_width/max_width) ,view.lbg.size_this.height * beishu))
        if label_width/max_width <= 0.1 then 
            view.lbg:setSize(cc.size(view.lbg.size_this.width * (0.1+0.01) ,view.lbg.size_this.height * beishu))
        end
        if name_width/name_max_width <= 1 then 
           view.name_text:setPositionX(0 + (100 * (1 - name_width/name_max_width)))
        end 
        if label_width/max_width <= 1 then 

           view.rich_text:setPositionX(0 + (355 * (1 - label_width/max_width)))
            if label_width/max_width <= 0.1 then  
                view.rich_text:setPositionX(0 + (355 * (1 - 0.08)))
            end 
        else 
            view.lbg:setSize(cc.size(view.lbg.size_this.width ,view.lbg.size_this.height * beishu))
        end  
    end 
    if label_width/(max_width) > 1 then 
        view:setPositionY(view.size_this.height * ( label_width/max_width - 1)*0.1)
        view1:setSize(cc.size(view.size_this.width,view.size_this.height * ((label_width/max_width)*0.6) ))
    end 
    ChatCommon.setTimeView(view,data)
end 


-- 初始化公用
function ChatCommon.init(view1,type)
   local view = nil 
   if view1.view ~= nil then 
      view = view1.view
   else 
       view = view1
   end 
   if type == ChatCommon.other then 
   
   elseif type == ChatCommon.me then 
   
   end 
   
   view.size_this = view:getContentSize()
   if view.vector ~= nil and view.vector.size_this == nil then 
      view.vector.size_this = view.vector:getSize()
      view.vector.p = {}
      view.vector.p.x = view.vector:getPositionX()
      view.vector.p.y = view.vector:getPositionY()
   end 
   if view.lbg ~= nil then 
      view.lbg.size_this = view.lbg:getSize()
   end 
   if view.nvector.size_this == nil then 
      view.nvector.size_this = view.nvector:getSize()
      view.nvector.p = {}
      view.nvector.p.x = view.nvector:getPositionX()
      view.nvector.p.y = view.nvector:getPositionY()
   end 
   if view.yuyin1 ~= nil and view.yuyin2 ~= nil and view.yuyin3 ~= nil then 
      view.yuyin1P = view.yuyin1:getPosition()
      view.yuyin2P = view.yuyin2:getPosition()
      view.yuyin3P = view.yuyin3:getPosition()
      view.miaoshuP = view.miaoshu:getPosition()
   end 

   
   
   local pianyi = TeamData.AVATAR_OFFSET
   view.coin:setPosition(view.coin:getPositionX() + pianyi.x , pianyi.y + 10 + view.coin:getPositionY())    
   ChatCommon.initBtn(view.bg ,false)
   view.bg:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ChatCommon click bg') 
        if view.roleid ~= nil then 
            EventMgr.dispatch(EventType.addFriendDetail,view.roleid)
            ChatCommon.name = view.data.name 
        end 
    end)
end 
