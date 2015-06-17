--write by weihao 
--竞技场

-- 基本信息
trans.call.PRSingleArenaInfo = function(msg)
--    LogMgr.debug("msg.info" .. debug.dump(msg))
    local info = msg.info
    local list = info.opponent_list
    LogMgr.log( 'debug',"PR基本消息")
    LogMgr.log( 'debug',debug.dump(info))
--    LogMgr.debug("list .. " .. debug.dump(list))
    ArenaData.setRolelist(info)
    ArenaData.setEmenylist(list)
    
end

-- 刷新对手
trans.call.PRSingleArenaRefresh = function(msg) 
    local list = msg.opponent_list
--    LogMgr.debug("msg .. " .. debug.dump(msg ))
    ArenaData.setEmenylist(list)
end

-- 清空挑战CD
trans.call.PRSingleArenaClearCD = function(msg)
    LogMgr.log( 'debug',"清除cd时间成功")
--    LogMgr.debug( 'gameData.getServerTime()  .. ' .. gameData.getServerTime() )
--    LogMgr.debug( 'debug' .. debug.dump(msg))
    ArenaData.setCdTime(msg)
end

-- 增加挑战次数
trans.call.PRSingleArenaAddTimes = function(msg)
--    LogMgr.log( 'debug',"PR挑战次数")
--   LogMgr.log( 'debug',debug.dump(msg))
    ArenaData.setTime(msg)
end

-- 申请最近的竞技log
trans.call.PRSingleArenaLog = function(msg)
    LogMgr.log( 'debug',"PR竞技log")
--    print ("d = " .. debug.dump(msg.fightlog_list))
    ArenaData.setRecordList(msg.fightlog_list)  
end

-- 申请排行榜数据
trans.call.PRSingleArenaRank = function(msg)
--   LogMgr.log( 'debug',debug.dump(msg))
   local ranklist = msg.list
   ArenaData.setRanklist(ranklist)  
end

--战斗结束发送奖励
trans.call.PRSingleBattleReply = function(msg)
--    LogMgr.debug( "战斗结束发送奖励")
--    LogMgr.debug( 'msg .. ' .. debug.dump(msg))
    ArenaData.setWinFlag(msg)
end

--敌人的详细信息
trans.call.PRUserSingleArenaPanel = function(msg)
--    LogMgr.debug("敌人的详细信息")
--    LogMgr.debug("msg.target_id .. " .. msg.target_id)
   ArenaData.UserPanels[msg.target_id] = msg.data
   local data = nil 
   if ArenaData.realrole ~= 0 then 
      LogMgr.debug("返回真人布阵信息，申请进入布阵")
      Command.run("arenauerimformation" ,msg.data.formation_map)
      ArenaData.realrole = 0
   end 
   Command.run("formation update arena",msg)
end

--返回我的排名
trans.call.PRSingleArenaMyRank = function(msg)
--   LogMgr.debug("msg .. " .. debug.dump(msg))
   ArenaData.severrank = tonumber (msg.rank)
end 

-- 如果自己被玩家打败将会收到此协议作提醒
trans.call.PRSingleArenaBattleed = function(msg)
   --打败后出现红点
   ArenaData.redPoint = true
end

-- cd 时间 主界面用
trans.call.PRSingleArenaReplyCD = function(msg)
   ArenaData.setMainCdTime(msg)
--   LogMgr.debug("msg .. " .. debug.dump(msg))
end

--真人物布阵
trans.call.PRUserSingleArenaPre = function(msg)
    Command.run("loading wait hide" , "arenaui") 
    LogMgr.debug("msg .. " .. debug.dump(msg))
    ArenaData.setRealRoleList(msg)
end

-- 发送奖励
trans.call.PRSingleArenaBattleEnd = function(msg)
--    LogMgr.debug(debug.dump(msg))
    ArenaData.setBCionLiset(msg)
end 

-- 竞技场名次不对，退出战斗
trans.call.PRSingleArenaCheck = function (msg)
    showMsgBox( "[image=alert.png][font=ZH_10]对手数据不一致，请重新选择对手！[btn=one]confirm.png", function()
--        FightDataMgr:releaseAll()
--     LogMgr.debug("msg.flag .. " .. msg.flag)
     if SceneMgr.isSceneName("fight") then 
        Command.run('scene leave')
     end
    end)
end 