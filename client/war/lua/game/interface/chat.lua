--by weihao
-- 聊天
Chat = {}
Chat.sendMessage = function(value)
    trans.send_msg( 'PQChatContent', { text_ext = value.text_ext , broad_cast = value.type, avater = gameData.getSimpleDataByKey("avatar"),text = value.msg ,sound_length = 0,sound_index = 0} )
    ChatData.resetChatNum()
end 
 
-- 发送文字
Command.bind( 'chatmessage', 
    function(value)
        trans.send_msg( 'PQChatContent', { text_ext = value.text_ext ,broad_cast = value.type, avater = gameData.getSimpleDataByKey("avatar"), text = value.msg ,sound_length = 0,sound_index = 0} )
        ChatData.resetChatNum()
    end 
)

-- 发送语音
Command.bind( 'chatsound', 
    function(value)
        ChatData.sound_index = ChatData.sound_index + 1 
--        LogMgr.error("ChatData.sound_index .. " .. ChatData.sound_index)
        trans.send_msg( 'PQChatContent', { text_ext = value.text_ext ,broad_cast = value.type, avater = gameData.getSimpleDataByKey("avatar"), sound_data = value.msg ,text = value.text ,sound_length = value.time,sound_index = ChatData.sound_index} )
        ChatData.resetChatNum()
    end 
)


-- 发送好友语音
Command.bind( 'chatfriendsound' ,
    function( value)
        -- LogMgr.error("chatfriendsound")
        trans.send_msg( 'PQFriendChatContent', {text_ext = value.text_ext ,friend_id = value.friend_id , broad_cast = value.type , avater = gameData.getSimpleDataByKey("avatar"),sound = value.msg ,text = value.text ,length = value.time} )
        value.target_id = gameData.id
        value.broad_cast = value.type
        value.type = ChatCommon.me
        value.avater = gameData.getSimpleDataByKey("avatar") 
        value.sound = value.msg 
        value.length = value.time
        value.name = gameData.getSimpleDataByKey("name")
        value.level = gameData.getSimpleDataByKey("team_level")
        ChatData.addFriendWorld(value) 
    end 
)

-- 发送好友文字
Command.bind( 'chatfriendmessage' ,
    function( value)
        -- LogMgr.error("chatfriendmessage")
        trans.send_msg( 'PQFriendChatContent', {text_ext = value.text_ext , friend_id = value.friend_id , broad_cast = value.type , avater = gameData.getSimpleDataByKey("avatar") ,text = value.msg ,length = 0 } )
        value.target_id = gameData.id
        value.broad_cast = value.type
        value.type = ChatCommon.me
        value.avater = gameData.getSimpleDataByKey("avatar") 
        value.text = value.msg 
        value.length = 0
        value.name = gameData.getSimpleDataByKey("name")
        value.level = gameData.getSimpleDataByKey("team_level")
        ChatData.addFriendWorld(value)  

    end 
)

Command.bind( 'getsound' ,
    function(target_id ,sound_index) 
        trans.send_msg( 'PQChatSound',{target_id = target_id,sound_index = sound_index})
    end
)

--  图腾
Command.bind( 'chattotem' ,
    function(target_id ,totem_guid) 
        trans.send_msg( 'PQChatGetTotem',{target_id = target_id,totem_guid = totem_guid})
    end
)

-- 英雄
Command.bind( 'chatsoldier' ,
    function(target_id ,soldier_guid) 
        trans.send_msg( 'PQChatGetSoldier',{target_id = target_id,soldier_guid = soldier_guid})
    end
)

-- 装备
Command.bind( 'chatequip' ,
    function(target_id ,equip_type,equip_level) 
        trans.send_msg( 'PQChatGetEquip',{target_id = target_id,equip_type = equip_type,equip_level = equip_level})
    end
)
