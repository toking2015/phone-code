local prePath = "image/ui/ChatUI/"
local WORLDX = 286
local add_height = 20 -- 固定值10一行
local SPACE = 10
MainChatUntil= class("MainChatUntil",function() 
--    return getLayout(prePath .. "MainChatUnitl.ExportJson")
    return getLayout(prePath .. "MainSoundUntil.ExportJson")
    
end)

function MainChatUntil:ctor()
    createScaleButton(self.sound.soundplay)
    createScaleButton(self.sound.soundstop)
    ChatCommon.initBtn(self.sound,false)

    self:initSize()
    self.effectid = nil 
    
    --开始播放
    self.playSound = function()
        self.sound.soundstop:setVisible(true)
        self.sound.soundplay:setVisible(false)
        ChatData.isPlaying = true 
        if self.time ~= nil then 
            SoundMgr.stopAllEffects()
            SoundMgr.setMusicValume(0.1)
            local flag = ChatData.isHaveSound(self.data.role_id,self.data.sound_index)
            -- 已经有sound 直接播放       
            if flag == true  then   
                local soundpath = "temp/sound/" .. self.hour .. "/" .. self.roleid .. "_" .. self.minute .. "_" .. self.second .. ".mp3"
                LogMgr.debug(soundpath)
                self.effectid = SoundMgr.playChat(soundpath)
                TimerMgr.callLater(self.stopSound,self.length)
                SoundMgr.setPlayChat(true)
            else 
               -- 请求sound
--                LogMgr.error("sendSound")
               ChatData.getSound(self.data.role_id,self.data.sound_index)
            end 
        end 

    end 
    --结束播放
    self.stopSound = function()
        ChatData.isPlaying = false 
        if self ~= nil and self.sound ~= nil then 
            self.sound.soundstop:setVisible(false)
            self.sound.soundplay:setVisible(true)
            if self.effectid ~= nil then 
                SoundMgr.stopEffect(self.effectid)
                self.effectid = nil 
            end 
            SoundMgr.resumeAllEffect()
            SoundMgr.resetMusicValume()
            SoundMgr.setPlayChat(false)
        end 
    end 
    
    self.sound:addTouchEnded(function()
        ActionMgr.save( 'UI', 'MainChatUntil click up sound')
        if ChatData.isPlaying == false then  
            if self.sound.soundstop:isVisible() == false then 
               self.playSound()
            else 
               self.stopSound()
            end 
        end 
    end )
    self.sound.soundplay:addTouchEnded(function()
        ActionMgr.save( 'UI', 'MainChatUntil click up soundplay')
        if ChatData.isPlaying == false then 
           self.playSound()
        end 
    end)
    self.sound.soundstop:addTouchEnded(function()
        ActionMgr.save( 'UI', 'MainChatUntil click up soundstop')
        if ChatData.isPlaying == false then 
           self.stopSound()
        end 
    end)
end 

function MainChatUntil:onClose()
    self.sound.close()
end 

function MainChatUntil.getWindow()
   local window = MainUIMgr.getMainChat()
   return window
end 

--刷新数据
function MainChatUntil:refreshData(data,type)
--    self:resetView()
    if true == ChatData.hasBlack(data.role_id) then
        -- 如果加入黑名单
    else 
        if data.length == 0 then
            self:setRichText(data,type)
        else
            self:setSound(data,type)
            if self.getWindow().autoflag == true and gameData.id ~= self.roleid then 
                if ChatData.getCloseSound() == false then 
                    if ChatData.isPlaying == false then  
                       self.playSound()
                    else 
                       ChatData.addPlaySound(self)
                    end 
                    self.getWindow().autoflag = false
                end 
            end 
        end 
    end
end


function MainChatUntil:initSize()
    if self.vector.size_this == nil then 
        self.vector.size_this = self.vector:getSize()
    end 

    if self.size_this == nil then 
        self.size_this = self:getSize()
    end 

    if self.sound.positiony == nil then 
        self.sound.positiony = self.sound:getPositionY()
    end 

    if self.sound.time.positionx == nil then 
        self.sound.time.positionx = self.sound.time:getPositionX()
    end
    
    if self.sound.positionx == nil then 
        self.sound.positionx = self.sound:getPositionX()
    end 
     
end 


-- 设置显示语音
function MainChatUntil:setSound(data, type)
    self.data = data
    self.issound = true
    self.time = GameData.getServerTime()
    if data.time ~= nil then 
       self.time = data.time
    end 
    self.sound:setVisible(true)
    local length = math.floor(data.length/1000)
    self.length = length  --录音的时间长度
    local percent = length / 10 * 100 
    -- 百分之百
    if percent >= 100 then 
        percent = 100
    end 
    -- 最少百分之二十
    if percent <= 50 then 
        percent = 50 
    end 
    if percent >= 95 then 
        percent = 95
    end 
    
    if self.rich_text ~= nil then 
        self.rich_text:removeFromParent(true)
    end 

    self.vector:setSize(self.vector.size_this)

    self:setSize(self.size_this)
    
    self.rich_text = cc.Node:create()
    self.rich_text:setAnchorPoint(0,0)
    local str = ""
    if type == trans.const.kCastServer  then 
        str = fontNameString("CHAT_0") .. "（世界）"
    elseif type ==  trans.const.kCastGuild then 
        str = fontNameString("CHAT_1") .. "（公会）"
    end 
    local str = str .. fontNameString("CHAT_2") .. data.name .. ":"
    str = str .. fontNameString("CHAT_4").."　　　　　" .. data.text
    RichTextUtil:DisposeRichText(str,self.rich_text,nil,0,WORLDX,2)
    self.addheight = 0
    self.beforeheight = self.vector.size_this.height
    self.afterheight = self.vector.size_this.height 
    if self.rich_text:getContentSize().height > self.beforeheight then
        self.vector:setSize(cc.size(self.vector.size_this.width,self.rich_text:getContentSize().height)) 
        self.afterheight = self.vector:getSize().height
    end
    self.addheight = self.afterheight - self.beforeheight
    self:setSize(cc.size(self:getSize().width,self.size_this.height + self.addheight))
    self.rich_text:setPosition(cc.p(0,self.vector:getSize().height))
    self.vector:addChild(self.rich_text)
    local testlabel = cc.Label:create()
    testlabel:setString("（公会）" .. data.name .. ":")
    local testvalue = testlabel:getContentSize().width
--    self.sound:setAnchorPoint(cc.p(0,1))
    self.sound:setPositionX(self.rich_text:getPositionX() + testvalue * 1.5 + 15 )
    self.sound:setPositionY(self.sound.positiony + self.addheight )
--    self.sound:setPercent(percent)  -- 语音长度
    self.sound.time:setString(length .. "''") -- 语音的时间
--    self.sound.time:setPositionX(self.sound.time.positionx - (1 - percent /100) *100)
    self.sound:setVisible(true)   --sound
    self.sound.soundplay:setVisible(true) -- 语音
    self.sound.time:setVisible(true)  --语音时间
    self.sound.soundstop:setVisible(false)

    self.hour = DateTools.getHour(self.time)
    self.minute = DateTools.getMinute(self.time)
    self.second = DateTools.getSecond(self.time)
    self.roleid = data.role_id 
    
    

end 

function MainChatUntil:setRichText(data,type)
--    FontStyle.CHAT_1  --聊天16号蓝色
--    FontStyle.CHAT_2  --聊天16号黄色
--    FontStyle.CHAT_3  --聊天16号白色
--    FontStyle.CHAT_4  --聊天16号绿色
--    FontStyle.CHAT_0  --聊天16号深黄色
    self.issound = false
    self.sound:setVisible(false)
    if self.rich_text ~= nil then 
        self.rich_text:removeFromParent(true)
    end 

    self.vector:setSize(self.vector.size_this)
    self.rich_text = cc.Node:create()
    self.rich_text:setAnchorPoint(0,0)
    
    local str = ""
    if type == trans.const.kCastServer  then 
        str = fontNameString("CHAT_0") .. "（世界）"
    elseif type ==  trans.const.kCastGuild then 
        str = fontNameString("CHAT_1") .. "（公会）"
    end 
    
    local tal = ""
    local text = {}
    if data.text_ext ~= nil and data.text_ext ~= "" then 
        text  = string.split(data.text_ext,"..")
        tal = Json.decode(text[1])
    end 
    local thingname = nil 
    local fntstr = fontNameString("CHAT_9")
    local jTotem = nil 
    local quality = 1 
    local itemtype = nil 
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
            createScaleButton(self.vector,false,nil,nil,false)
            self.vector:addTouchBegan(function() 
                ActionMgr.save( 'UI', 'MainChatUntil click vector') 
                local pos = self.vector:getParent():convertToWorldSpace( cc.p(self.vector:getPositionX(), self.vector:getPositionY()) )
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
                    EquipmentData:showEquipmentTips( self.vector,tal )
                elseif tal.leixin == ChatAddData.TAO then --套装
                    Command.run( 'chatequip' ,tal.target_id ,tal.equip_type , tal.level) 
                else
                   TipsMgr.showTips(gp, itemtype, jTotem, tal)
                end

            end)
        end 
        
        
        if jTotem ~= nil and  jTotem.quality ~= nil then 
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
                fntstr=  fontNameString("CHAT_3")
            elseif quality == 2 then
                fntstr=  fontNameString("CHAT_10")
                --聊天18号绿色
            elseif quality == 3 then 
                fntstr=  fontNameString("CHAT_11")
                --聊天18号蓝色
            elseif quality == 4 then 
                fntstr=  fontNameString("CHAT_12")
                --聊天18号紫色
            elseif quality == 5 then
                fntstr=  fontNameString("CHAT_9")
                --聊天18号橙色
            end 
        end 
    end 
    
    str = str .. fontNameString("CHAT_2") .." " ..  data.name .. ": " 
    str = str .. fontNameString("CHAT_3") ..  ExpressionData.changeString(data.text,fontNameString("CHAT_3"))
    if thingname ~= nil then 
        str = str .. fntstr .." " .. "【" .. thingname .. "】" 
    end 
    RichTextUtil:DisposeRichText(str,self.rich_text,nil,0,WORLDX,1,SPACE)
    self.addheight = 0
    self.beforeheight = self.vector.size_this.height
    self.afterheight = self.vector.size_this.height
    if self.rich_text:getContentSize().height > self.beforeheight then
        self.vector:setSize(cc.size(self.vector.size_this.width,self.rich_text:getContentSize().height)) 
        self.afterheight = self.vector:getSize().height
    end
    self.addheight = self.afterheight - self.beforeheight
    self:setSize(cc.size(self.size_this.width,self.size_this.height + self.addheight))
    self.rich_text:setPosition(cc.p(0,self.vector:getSize().height))

    self.vector:addChild(self.rich_text)
   
    
--    createScaleButton(self.rich_text,false)
--    self.rich_text:addTouchEnded(function()
--        ChatData.isType = "server"
--        Command.run('ui show' , 'ChatUI' ,PopUpType.SPECIAL)
--    end)

end 
    
    
function MainChatUntil:createView(data,type)
    local view = MainChatUntil.new()
    if data ~= nil then 
       view:refreshData(data,type)
    end 
    return view
end 

