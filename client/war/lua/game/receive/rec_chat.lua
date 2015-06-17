-- create by Live --
--聊天通讯

-- 获取基本信息
trans.call.PRChatContent = function(msg)
--    msg.text = ExpressionData.changeString(msg.text)
	ChatData.addWord(msg)
	
end
trans.call.PRFriendChatContent = function(msg)
--    msg.text = ExpressionData.changeString(msg.text)
    msg.type = ChatCommon.other
    ChatData.addFriendWorld(msg)
end

trans.call.PRChatSound = function(msg)
   local isover = false 
   if msg.result == 0 then 
      ChatData.resetSound(msg.target_id,msg.sound_index,msg.sound_data)
   else
      TipsMgr.showError("语音过时获取失败")
      isover = true 
   end 
   local data1 = {}
   data1.roleid = msg.target_id
   data1.index = msg.sound_index
   data1.isover = isover
   EventMgr.dispatch(EventType.ShowChatView,data1)
end 

-- 图腾
trans.call.PRChatGetTotem = function(msg)
       
       local totemid = msg.totem_data.id
       local jTotem = findTotem(totemid)
       local sTotem = msg.totem_data
       TipsMgr.showTips(nil,TipsMgr.TYPE_TOTEM_WIN,jTotem,sTotem)
end

-- 英雄
trans.call.PRChatGetSoldier = function(msg)    
     local soldierId = msg.soldier_data.soldier_id
     local jSoldier = findSoldier(soldierId)
     local sSoldier = msg.soldier_data
     local data = {}
     data.jSoldier = jSoldier
     data.sSoldier = sSoldier
     data.sFightExtAble1 = msg.ext_able
     TipsMgr.showTips(nil,TipsMgr.TYPE_SOLDIER_WIN,data)
end

-- 装备
trans.call.PRChatGetEquip = function(msg)
    print("msg .. " .. debug.dump(msg))
    EquipmentData:setData(msg)
    Command.run("ui show" , "EquipmentTips" )
end