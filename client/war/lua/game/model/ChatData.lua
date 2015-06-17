
local kCastUni = trans.const.kCastUni	-- 个人[ broad_id:角色Id ] 0
local kCastServer = trans.const.kCastServer	-- 全服 1
local kCastGuild = trans.const.kCastCopy	-- 副本( 暂不使用 ) 2
local kCastGuild = trans.const.kCastGuild		-- 公会[ broad_id:工会Id ] 3

ChatData = {}

ChatData.isShowChat = false

local channel = kCastServer		-- 当前频道
local blackList = {}	-- 黑名单
local wordList = {}		-- 聊天列表 包含N个类型列表：个人，全服，公会等
local needLevel = 1		-- 获得世界聊天等级
local NUMLINE = 15   --刷新跟初始化出现的聊天个数
local nowline = 0   -- 当前排到第几个聊天个数
local vlist = {}    --展示的聊天列表
local morelist = {}  --展示morelist
local namelist = {}  --存储的sound名字
local playsoundlist = {}
local blacklist = {} -- 黑名单
ChatData.effectid = nil 
ChatData.auto = false
ChatData.isType = "server"  -- Type是server 表示打开世界，guild 表示打开公会 ， mail 表示打开邮件
ChatData.isFriend = false
local LIMITTIME = 15 --固定限制说话
local chat_second = 15  -- 说话秒数
local chat_width_frienddata = nil 
local sound_is_close = true -- 默认自动播放关闭
local haoyou_chat_list = {} -- 好友聊天记录
local const_mail = "cont_mail"
local const_haoyou = "cont_haoyou"
ChatData.sound_index = 0  -- 声音index
local sounddata = {} --声音数据 

-- 测试数据 ，添加世界频道聊天记录
--wordList[1] = {}
--local j = 1
--for i = 1, 10, 1 do
--    --语音
--    table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 1000, sound = 1 ,level = 12 ,name = "魔惊", role_id = (10000 + j), text = "一二三"})
--    table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 2000, sound = 1 ,level = 12 ,name = "魔惊", role_id = (10000 + j), text = "一二三四五六七八一二三四五六七八九十"})
--table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 3000, sound = 1 ,level = 12 ,name = "魔惊商", role_id = (10000 + j), text = "一二三四五六七八九"})
--    table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 4000, sound = 1 ,level = 12 ,name = "魔惊商", role_id = (10000 + j), text = "一二三四五六七八一二三四五六七八九十"})
--table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 5000, sound = 1 ,level = 12 ,name = "魔惊惊商", role_id = (10000 + j), text = "一二三四五六七八九"})
--    table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 6000, sound = 1 ,level = 12 ,name = "魔惊惊商", role_id = (10000 + j), text = "一二三四五六七八一二三四五六七八九十一二三四五六七八九一二三四五六七八九"})
--    table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 7000, sound = 1 ,level = 12 ,name = "魔惊惊惊商", role_id = (10000 + j), text = "一二三四五六七八九一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十"})
--table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 0, sound = 1 ,level = 12 ,name = "魔惊惊惊商", role_id = (10000 + j), text = "一二三四五六七八"})
----
----    table.insert(wordList[1],1,{avater = 3 , type = "me" , broad_cast = 1,length = 0, sound = 1 ,level = 12 ,name = "魔惊第三", role_id = (10000 + j), text = "一二三四五六七八九十一二三"})
--    table.insert(wordList[1],1,{avater = 4 , type = "other" , broad_cast = 1,length = 0, sound = 1 ,level = 12 ,name = "魔惊第三方", role_id = (10000 + j), text = "一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十"})
--    table.insert(wordList[1],1,{avater = 5 , type = "other" , broad_cast = 1,length = 0, sound = 1 ,level = 12 ,name = "魔惊第三方的", role_id = (10000 + j), text = "一二三四五六七八九十"})
--	j = j + 1
--	if j > 60 then
--		j = 1
--	end
--end
-- 测试数据 ，添加公会频道聊天记录
--wordList[1] = {}
--local j = 1
--for i = 1, 60, 1 do
----    table.insert(wordList[1], 1,{broad_cast = 3, level = 12 ,name = "魔王大人", role_id = (10000 + j), text = "this is guild world :"..i.." ~~~"})
--	table.insert(wordList[1],1,{avater = 1 , type = "me" , broad_cast = 1,length = 0, sound = 1 ,level = 12 ,name = "魔惊惊惊商" .. i, role_id = (10000 + j), text = "一二三四五六七八"})
--	j = j + 1
--	if j > 60 then
--		j = 1
--	end
--end


 
ChatData.isPlaying = false 

function ChatData.setLimitTime( )
    LIMITTIME = 0
end
Command.bind("cmd chatTime", ChatData.setLimitTime)

function ChatData.saveYuyin()
    if sound_is_close == false then 
       LocalDataMgr.save_string(gameData.id, "chat.yuyin", 0)  
    elseif sound_is_close == true then 
       LocalDataMgr.save_string(gameData.id, "chat.yuyin", 1) 
    end 
    
end 

-- 记录语音是否开启或关闭
function ChatData.loadYuyin()
    local num = tonumber(LocalDataMgr.load_string( gameData.id, "chat.yuyin" ))
    if num == 0 then 
       sound_is_close = false
    elseif num == 1 then 
       sound_is_close = true
    end 
end 


-- 获取语音
function ChatData.getSound(target_id , index)
   if sounddata ~= nil and sounddata[target_id] ~= nil and sounddata[target_id][index] ~= nil then 
      Command.run( 'getsound' ,target_id ,index) 
   end 
end

function ChatData.isHaveSound(target_id , index )
   if target_id == nil or index == nil then 
      return true 
   end 
   if channel ~= const_haoyou  and sounddata ~= nil and sounddata[target_id] ~= nil and sounddata[target_id][index] ~= nil then
      return false 
   end 
   return true 
end 

function ChatData.resetSound(target_id , index,data)
   local hour = DateTools.getHour(sounddata[target_id][index])
   local minute = DateTools.getMinute(sounddata[target_id][index])
   local second = DateTools.getSecond(sounddata[target_id][index])
   local roleid = target_id
   local soundpath = ""
   soundpath = "temp/sound/" .. hour .. "/" .. roleid .. "_" .. minute .. "_" .. second .. ".mp3"
   seq.write_stream_file(soundpath, data )
   sounddata[target_id][index] = nil
end 

function ChatData.addFriendWorld(msg) 
    if msg.friend_id == nil then 
        msg.role_id = msg.target_id
    else 
        msg.role_id = msg.friend_id
    end 

    if haoyou_chat_list == nil then
       haoyou_chat_list = {}
    end 
    if haoyou_chat_list[msg.role_id] == nil then 
       haoyou_chat_list[msg.role_id] = {}
    end 
    msg.time = gameData.getServerTime()
    local hour = DateTools.getHour(msg.time)
    local minute = DateTools.getMinute(msg.time)
    local second = DateTools.getSecond(msg.time)
    local roleid = msg.role_id 
    local soundpath = ""

    if msg.length ~= 0 then 
        LogMgr.log("save")
        soundpath = "temp/sound/" .. hour .. "/" .. roleid .. "_" .. minute .. "_" .. second .. ".mp3"
        LogMgr.log(soundpath)
        seq.write_stream_file(soundpath, msg.sound )
    end 
    table.insert(haoyou_chat_list[msg.role_id],1,msg)
    if #haoyou_chat_list[msg.role_id] > 60 then 
        table.remove(haoyou_chat_list[msg.role_id], #haoyou_chat_list[msg.role_id])
    end 
    if PopMgr.hasWindow("ChatUI") then 
       if FriendData.isFriendChatId and channel == "cont_haoyou" then 
          EventMgr.dispatch(EventType.UpdateChat, {type = "cont_haoyou"})
       end 
    end  
    EventMgr.dispatch(EventType.FriendChatUpdate, roleid)
end 

function ChatData.getFriendChatList(id)
    if haoyou_chat_list[id] ~= nil then 
        return haoyou_chat_list[id]
    end 
    return nil 
end 


function ChatData.setCloseSound(flag) 
   if flag == nil then 
      sound_is_close = false 
   else 
      sound_is_close = flag
   end 
end

function ChatData.getCloseSound()
    return sound_is_close
end 

function ChatData.chatWithFriend(data)
    chat_width_frienddata = data 
--    print("data .. " .. debug.dump(data))
    if PopMgr.hasWindow("ChatUI") then 
          EventMgr.dispatch(EventType.ShowFriendChat)
    end 
end 

function ChatData.getChatWithFriendData()
    return chat_width_frienddata
end 

function ChatData.addChatNum(num)
   chat_second = chat_second + num 
   if chat_second >= LIMITTIME then 
        chat_second = LIMITTIME
   end 
end 

function ChatData.resetChatNum()
   if channel == kCastServer then 
      chat_second = 0
   end 
end 

function ChatData.getLimitTime()
   return LIMITTIME
end 

function ChatData.getLeftTime()
    return math.floor(LIMITTIME - chat_second)
end 

function ChatData.isCanChat()
   if channel == kCastServer then 
       if chat_second >= LIMITTIME then  
             return true 
       end 
       return false
   end 
   return true 
end 

function  ChatData.getPlaySoundList()
    return playsoundlist 
end 

function ChatData.clearSounList()
    playsoundlist = {}
end 

function ChatData.addPlaySound(url)
    if playsoundlist ~= nil or # playsoundlist >= 2 then 
       table.remove(playsoundlist , #playsoundlist)
    end 
    table.insert(playsoundlist,url)
end 


function ChatData.updatePlaySound()
    if ChatData.isPlaying == false then 
        if playsoundlist ~= nil and #playsoundlist ~= 0 then                
           -- 表示是语音
           ChatData.isPlaying = true 
           if playsoundlist[1] ~= nil then 
               if playsoundlist[1].issound == false then
                  -- 不是语音
                  ChatData.auto = false
                  table.remove(playsoundlist,1)
               else 
                  -- 是语音
                  ChatData.auto = true 
                  playsoundlist[1].playSound()
                  table.remove(playsoundlist,1) 
               end
           end              
        end 
    else 
        ChatData.auto = false
    end 
end 

function ChatData.getMailFlag()
   -- return mailflag 
   return MailBoxMgr.hasNewMail() 
end

function ChatData.getNUMLINE()
   return NUMLINE
end 
ChatData.getHeight = function (viewlist)
   local height = 0 
   if viewlist ~= nil then 
       for key ,value in pairs(viewlist) do
           if value ~= nil then 
              height = height + value:getSize().height
           end 
       end 
   end 
   return height
end 
 
-- 添加聊天记录，broad_cast这个表示是哪种类型的list
function ChatData.addWord(value)
    local type = "other"
    blacklist = FriendData:getCurrentDataList( FriendData.TYPE_BLIACK )
--    print("blacklist .. " .. debug.dump(blacklist))
    for key ,value1 in pairs(blacklist) do
        if value1.friend_id == value.role_id then
            return 
        end  
    end 
    if value.role_id == gameData.id then 
       type = "me"
    end 
    
	local broad_cast = value.broad_cast
    LogMgr.log( 'debug',"broad_cast = "..broad_cast)
--    LogMgr.error("gameData.getServerTime()接收到 .. " .. gameData.getServerTime())
	if nil == wordList[broad_cast] then
		wordList[broad_cast] = {}
	end
	if nil == namelist[broad_cast] then 
	   namelist[broad_cast] = {}
	end 
	local list = wordList[broad_cast]
    local time = GameData.getServerTime()
	value.time = time 
	value.type = type 
    value.length = value.sound_length
	table.insert(list, 1,value)
	wordList[broad_cast] = list
	table.insert(vlist,1,value)

    local hour = DateTools.getHour(value.time)
    local minute = DateTools.getMinute(value.time)
    local second = DateTools.getSecond(value.time)
    local roleid = value.role_id 
    local soundpath = ""
    
    if value.sound_length ~= 0 then 
        if sounddata[roleid] == nil then 
            sounddata[roleid] = {}
        end 
        if sounddata[roleid][value.sound_index] == nil then 
            sounddata[roleid][value.sound_index] = value.time
        end 
        soundpath = "temp/sound/" .. hour .. "/" .. roleid .. "_" .. minute .. "_" .. second .. ".mp3"
--        seq.write_stream_file(soundpath, value.sound_data )
    end 
    table.insert(namelist[broad_cast],1,soundpath)
	if table.getn(list) >= 60 then
		table.remove(list, #list)
        if namelist[broad_cast] ~= nil and namelist[broad_cast][#namelist] ~= nil and namelist[broad_cast][#namelist] ~= "" then 
            writable.unlink( namelist[broad_cast][#namelist] )
	    end 
	    table.remove(namelist[broad_cast],#namelist)
        EventMgr.dispatch(EventType.RemoveMainChat)	
        if PopMgr.getIsShow("ChatUI") then
           EventMgr.dispatch(EventType.RemoveChat)
        end  
	end
	
--    LogMgr.debug("worldList3 .. " .. debug.dump(wordList))
	if PopMgr.getIsShow("ChatUI") then
        if  channel == broad_cast and (broad_cast == const.kCastGuild or broad_cast == const.kCastServer ) then 
	       EventMgr.dispatch(EventType.UpdateChat, {type = broad_cast})
	   else
            if channel == const_haoyou and broad_cast == const_haoyou then 
                EventMgr.dispatch(EventType.UpdateChat, {type = broad_cast})
            end 
	   end 
    end 
    EventMgr.dispatch(EventType.UpdateMainChat, {type = broad_cast})
end

-- 登录的时候清空上次的语音
function ChatData.clearSoundFile()
    writable.unlink( "temp/sound" )
end 

-- 获取展示聊天list
function ChatData.getInitList()
    local type = ChatData.getChannel()
    local list = ChatData.getWordListBy(type)
    vlist = {}
    if list ~= nil and #list >= NUMLINE then 
       nowline = NUMLINE
       for i = 1 , NUMLINE , 1 do 
           table.insert(vlist,list[i])
       end 
    else 
        nowline = 0
        return list
    end 
    return vlist
end 

-- 获取更多数据
function ChatData.getMoreList()
    local type = ChatData.getChannel()
    local list = ChatData.getWordListBy(type)
    morelist = {}
    if vlist ~= nil and #vlist >= NUMLINE then
       if list ~= nil and #list > #vlist then 
          if #list - #vlist > NUMLINE then 
             for i = #vlist + 1 ,#vlist + NUMLINE  do
                table.insert( morelist ,list[i])
                table.insert(vlist,list[i])
             end 
          else 
             for i = #vlist + 1 ,#list do 
                table.insert(morelist,list[i])
                table.insert(vlist,list[i])
             end 
          end 
       end 
    end  
    return morelist
end 

--是否大于15条
function ChatData.getMoreFlag()
    local type = ChatData.getChannel()
    local list = ChatData.getWordListBy(type)
    local vlist = {}
    if #list > NUMLINE then 
        return true 
    end 
    return false
end 

-- 获取全部聊天记录
function ChatData.getAllWordList()
	return wordList
end

-- 获取频道为broad_cast的聊天记录
function ChatData.getWordListBy(broad_cast)
	if nil ~= wordList[broad_cast] then
	    LogMgr.log( 'debug',"change3")
		return wordList[broad_cast]
	elseif channel == const_haoyou then 
	    -- print (" .. " .. chat_width_frienddata.friend_id)
        return ChatData.getFriendChatList(chat_width_frienddata.friend_id)
	end
	return {}
end

-- 查看黑名单是否有id的对象
function ChatData.hasBlack(id)
	for k,v in pairs(blackList) do
		if v == id then
			return true
		end
	end
	return false
end
-- 添加黑名单对象id
function ChatData.addBlack(id)
	if false == ChatData.hasBlack(id) then
		table.insert(blackList, id)
	end
end
-- 移除黑名单对象id
function ChatData.removeBlack(id)
	for k,v in pairs(blackList) do
		if v == id then
			table.remove(blackList, k)
			break
		end
	end
end
-- 获取黑名单列表
function ChatData.getBlackList()
	return blackList
end

-- 获取当前频道
function ChatData.getChannel()
	return channel
end
-- 设置当前频道
function ChatData.setChannel(value)
	channel = value
end
