ArenaData = {}

ArenaData.FIGHT_MAP = 1122

local ranklist = {} --排行榜list
local recordlist = {} --战斗纪录list
local arenalist = {} --挑战人物list
local rolelist = {} --人物自身数据list
local windatalist = {} --胜利数据
local cdtime = 0
local realtotem = {} --真人图腾
local realsoldier = {} --真人
local bcoinlist = {} -- 获取的勋章奖励

function ArenaData.clear()
  ArenaData.isIntoScene = false
  ArenaData.updatekey = "ArenaDataupdatekey" --updatekey
  ArenaData.time = 0 --时间
  ArenaData.UserPanels = {}
  ArenaData.lishiflag = false
  ArenaData.realrole = 0
  ArenaData.localrank = -1  --竞技场本地排名
  ArenaData.severrank = -1  --服务器排名
  ArenaData.redPoint = false -- 是否出现红点
  ArenaData.isWarRecord = false --是否在战报进去界面

  ArenaData.isArenaServerRand = false  -- 是否第一次获取serverrand
  ArenaData.isCdTime = false         -- 是否第一次获取cdtime
  ArenaData.outShowFlag = false
end
ArenaData.clear()
EventMgr.addListener(EventType.UserLogout, ArenaData.clear)

function ArenaData.ShowWarRecord ()
   if ArenaData.isWarRecord == true then 
      ArenaData.isWarRecord = false
      Command.run( 'arenalog')
   end 
end 
ArenaData.RULEIMGE = "image/ui/RuleUI/arenauirule.png"
ArenaData.RULE = {
    "[font=JJ_1]1、竞技场次数:",
    "[font=JJ_2]玩家每日默认拥有5次挑战次数（每日6点重置），并且可根据VIP等级购买额外的挑战次数 ",
    "[font=JJ_1]2、竞技场每日累计奖励与挑战对手奖励:",
    "[font=JJ_2]系统会根据玩家当前排名，每日22:00向玩家发放竞技场奖励。排名越靠前，奖励越丰厚哦！"

}


function ArenaData.setBCionLiset(msg)
   bcoinlist = {}
   bcoinlist = msg.coins
end 
--竞技场战斗后获取奖励
function ArenaData.getBCoinList()
   if bcoinlist ~= nil and #bcoinlist ~= 0 then 
      return bcoinlist 
   end
   return nil  
end 

function ArenaData.clearBCoinList()
   bcoinlist = {}
end 

function ArenaData.setRuleList(msg)
    TipsMgr.showRules(ArenaData.RULE, ArenaData.RULEIMGE, true)
end

--历史最高纪录
function ArenaData.setWinFlag(msg)
--   LogMgr.debug("msg .. " .. debug.dump(msg))
   local winflag = msg.win_flag 
   local addrank = msg.add_rank
   local coin = msg.coin  
   local rank = msg.cur_rank
   windatalist = {}
   ArenaData.lishiflag = false
   if winflag == const.kFightLeft then 
      if nil ~= addrank  and ArenaData.getRolelist()[1].historytop ~= nil  then 
         windatalist = {rank = rank ,winflag = winflag,addrank = addrank,coin = coin}
         ArenaData.lishiflag = true
         LogMgr.debug("xuweihao_lishizuigao")

          if PopMgr.getIsShow( "ArenaUI" ) then
              PopMgr.getWindow( 'ArenaUI' ):result()
              TimerMgr.runNextFrame(function() Command.run( 'arenainfo') end)
          end
      end 
   elseif winflag == const.kFightRight then 
      if ArenaData.getRolelist()[1].historytop == 0 then 
         windatalist = {rank = rank ,winflag = winflag,addrank = addrank,coin = coin}
         ArenaData.lishiflag = true
      else 
         ArenaData.lishiflag = false
         windatalist = {}
      end 
   end 
end

function ArenaData.getWinFlag()
     return windatalist 
end 
function ArenaData.setRolelist(msg)
    if msg ~= nil then 
       rolelist = {} 
    end 
    local time = tostring( findGlobal("singlearena_rank_reward_time").data) -- 活动时间
    local time1 = string.split(time, ",")
    if time[2] == 0 then 
       time = time1[1] .. ":" .. time1[2] .. "0"
    else 
       time = time1[1] .. ":" .. time1[2]
    end 
    local coin = 1
    local singlearena_battle_free = VarData.getVar( 'singlearena_battle_free' )
    LogMgr.debug("singlearena_battle_free .." .. singlearena_battle_free)
    if singlearena_battle_free ~= nil and singlearena_battle_free == 0 then 
       coin = 0
    elseif singlearena_battle_free ~= nil and singlearena_battle_free == 1 then 
       coin = findGlobal("singlearena_refresh_coin").data
    end 
    local times = tonumber(findGlobal("singlearena_challenge_times").data)
    local power = FormationData.getFightValueByType(const.kFormationTypeSingleArenaDef)

--    table.insert(rolelist,{id = gameData.getSimpleDataByKey("avatar") ,left = msg.cur_times ,all = msg.max_times ,rank = msg.cur_rank , historytop = msg.max_rank , power = msg.fight_value ,need = coin ,calcul = time,cd = msg.time_cd})
    if msg ~= nil then 
        table.insert(rolelist,{id = gameData.getSimpleDataByKey("avatar") ,left = (msg.add_times * findGlobal("singlearena_add_times_base").data + times - msg.cur_times) ,all = (msg.add_times * findGlobal("singlearena_add_times_base").data + times),rank = msg.cur_rank , historytop = msg.max_rank , power = power ,need = coin ,calcul = time,cd = msg.time_cd})
    else 
        if rolelist == nil then 
           rolelist = {}
        end 
        if rolelist[1] == nil then 
            rolelist[1] = {}  
        end 
        rolelist[1].id = gameData.getSimpleDataByKey("avatar")
        rolelist[1].power = power 
        rolelist[1].need = coin 
        rolelist[1].calcul = time
    end 
    if PopMgr.getIsShow("ArenaUI") == true then 
       EventMgr.dispatch(EventType.ArenaRole)
       EventMgr.dispatch(EventType.UpdateArenaResultData)
    end 
end


function ArenaData.setEmenylist(msg)
   if msg ~= nil then 
      arenalist = {}
   end 
   if msg ~= nil and #msg ~= 0 then 
       ArenaData.realrole = 0 
       ArenaData.UserPanels = {}
       for i, _ in pairs(msg) do   
            table.insert(arenalist,{data = msg[i] ,avatar = msg[i].avatar ,name = msg[i].name , power = msg[i].fight_value , id = msg[i].target_id ,rank =  msg[i].rank ,level = msg[i].team_level ,formationlist = msg[i].formation_list})    
            if ArenaData.isRealMan(msg[i].target_id) then 
                ArenaData.realrole =  ArenaData.realrole + 1 
            end 
       end 
   end
   
   if PopMgr.getIsShow("ArenaUI") == true then 
      EventMgr.dispatch(EventType.ArenaOpponent) 
   end 
    
end

function ArenaData.setRanklist(msg)

    ranklist = {}
    for key , value in pairs(msg) do 
       table.insert(ranklist, {rank = value.rank, id = value.avatar, level = value.team_level ,name = value.name , power = value.fight_value})
    end    
    if PopMgr.getIsShow("ArenaRanking") == true then 
       EventMgr.dispatch(EventType.ArenaRanking) 
    end 
end

function ArenaData.setRecordList(msg)  
    local flag = false --超过五条数据
    if msg ~= nil and #msg ~= 0 then
        recordlist = {}
        for key , value in pairs(msg) do 
                local rolelevel = value.def_level
                local rolename = value.def_name
                local roleid1 = value.def_id
                local logtime = value.log_time
                local num = value.rank_num
                local flag =false
                local avatar = 1 
                local minute = math.floor((gameData.getServerTime() - logtime)/60)
                local hour = math.floor((gameData.getServerTime() - logtime)/(60*60))
                local day = math.floor(hour/24 )
                local time = {minute = minute, hour = hour , day = day}
                if gameData.id ~= value.ack_id then --防守 
                    rolelevel = value.ack_level
                    rolename = value.ack_name
                    roleid1 = value.ack_id
                    avatar = value.ack_avatar
                    if value.win_flag == 2 then 
                        flag = true   
                    end
                else                                --攻击
                    avatar = value.def_avatar
                    rolelevel = value.def_level
                    rolename = value.def_name
                    roleid1 = value.def_id
                    if value.win_flag == 1 then 
                        flag = true
                    end
                end
                if flag == false then 
                   if num > 0 then 
                      num = 0 - num 
                   end 
                end 
                table.insert(recordlist, 1, {avatar = avatar ,winflag = flag , roleid = roleid1 , level = rolelevel ,time = time , name = rolename , downname = num,fightid = value.fight_id})
        end 
    end
    if PopMgr.getIsShow("ArenaWarRecord") == true then 
        EventMgr.dispatch(EventType.ArenaWarRecord) 
    end 

end

function ArenaData.setTime(msg)

    local times = tonumber(findGlobal("singlearena_challenge_times").data)
    local mactime = msg.add_times * findGlobal("singlearena_add_times_base").data + times
    local curtime = msg.add_times * findGlobal("singlearena_add_times_base").data + times - msg.cur_times
    rolelist[1].left = curtime
    rolelist[1].all = mactime
    if PopMgr.getIsShow("ArenaUI") == true then 
       EventMgr.dispatch(EventType.ArenaAddnum,{max = mactime , cur = curtime})
    end
end 

function ArenaData.setCdTime(msg)
--    LogMgr.debug("cdtime .." .. debug.dump(msg))
    local time =msg.time_cd
    rolelist[1].cd = time
    local coin = 1
    local singlearena_battle_free = VarData.getVar( 'singlearena_battle_free' )
    if singlearena_battle_free ~= nil and singlearena_battle_free == 0 then 
--        LogMgr.debug("singlearena_battle_free == 0")
        coin = 0
    elseif singlearena_battle_free ~= nil and singlearena_battle_free == 1 then 
--        LogMgr.debug("singlearena_battle_free == 1")
--        coin = findGlobal("singlearena_refresh_coin").data
    end 
    ArenaData.setMainCdTime(msg)
    local list = {time = time , coin = coin }
    if PopMgr.getIsShow("ArenaUI") == true then 
       EventMgr.dispatch(EventType.ArenaCdtime,list)
    end
end 

function ArenaData.getRolelist()
    return rolelist
end

function ArenaData.getArenaList()
    return arenalist
end 

function ArenaData.getRandList()
    return ranklist
end 

function ArenaData.getRecordList()
    return recordlist
end 

function ArenaData.updatecd () 
    if rolelist ~= nil and rolelist[1] ~= nil and rolelist[1].cd ~= nil then 
        ArenaData.setCdTime({time_cd = rolelist[1].cd})
        if PopMgr.getIsShow("ArenaUI") == true then 
           EventMgr.dispatch(EventType.ArenaWarReport)
        end 
    end 
end 

function ArenaData.saveRank(rank)
    LocalDataMgr.save_string(gameData.id, "arena.localrank", rank) 
    ArenaData.localrank = rank  
end 

function ArenaData.saveServerRank(rank)
   ArenaData.severrank = rank
end 

function ArenaData.loadRank()
    ArenaData.localrank = tonumber(LocalDataMgr.load_string( gameData.id, "arena.localrank" ))
--    LogMgr.debug(" ArenaData.localrank" ..  ArenaData.localrank )
    if nil == ArenaData.localrank then 
       ArenaData.localrank = 0 
    end 
--    ArenaData.localrank = -1
end 

--local numberweihao = 0 
function ArenaData.isRedPoint()
   -- 是否为服务器排名大于竞技场排名就会出现
   if nil ~= ArenaData.localrank and ArenaData.severrank ~= nil  then 
       if ArenaData.localrank ~= 0 and ArenaData.localrank < ArenaData.severrank then 
          ArenaData.redPoint = true 
       end 
   end 
   return ArenaData.redPoint
end 

function ArenaData.mainUpdatacd()

end 

--挑战时通过id加载
function ArenaData.loadChallege(id)
   local list = {}
   if id ~= nil and id ~= 0 and ArenaData.isRealMan(id) then 
        list = ArenaData.loadRealRoleById(id)
   elseif id ~= nil and id ~= 0 then 
        list = ArenaData.loadJiaRoleById(id)
   end 
   return list 
end 

-- 加载假人阵容
function ArenaData.loadJiaRoleById(id)
    local data = nil 
    for key ,value in pairs(arenalist) do 
        if value.id == id then 
           data = {}
           data = value 
           break  
        end 
    end 
    if data == nil then 
       return 
    end 
    local list = {}

    if data.data.formation_list ~= nil then    
        for key1, value1 in pairs(data.data.formation_list) do 
            if value1 ~= nil and  value1.attr ~= nil and value1.formation_type ~= nil then
                local attr = const.kFormationTypeSingleArenaAct
                local json = FormationData.getJsonByGuid(attr,value1.guid, value1.attr,true,data.data,true) 
                local untillist = {attr = value1.attr, id = json.id , level = 1 } -- 假人的话 就为1
                table.insert(list,untillist)        
            end 
        end 
    end  
    return list
end 

--发送真人阵容请求
function ArenaData.sendRealRole()
    if ArenaData.realrole ~= 0 and ArenaData.realrole > 0 then 
        --发送协议
--        LogMgr.error("发送")
        Command.run("loading wait show" , "arenaui")
        Command.run("arenarealrole")
    end 
end 

--加载真人阵容
function ArenaData.setRealRoleList(msg)
    realtotem = {}
    realsoldier = {}
    realtotem = msg.t_map 
    realsoldier = msg.s_map
    LogMgr.debug("value .. " .. debug.dump(realtotem))
end 

--加载真人
function ArenaData.loadRealRoleById(id)
    local msg = {}
    msg.t_list = realtotem[id]
    msg.s_list = realsoldier[id]
    local list = {}
    if msg ~= nil and msg.t_list ~= nil and #msg.t_list ~= nil then 
        for key , value1 in pairs(msg.t_list) do 
            if value1 ~= nil then 
               local untillist = {attr = const.kAttrTotem, id = value1.first , level = value1.second }
               table.insert(list,untillist)
--                LoadMgr.loadFightModelAsync( value1, const.kAttrTotem, level )
            end 
        end 
    end 
    if msg ~= nil and msg.s_list ~= nil and #msg.s_list ~= nil then 
        for key , value1 in pairs(msg.s_list) do 
            if value1 ~= nil then 
                local untillist = {attr = const.kAttrSoldier, id = value1.first , level = value1.second } 
                table.insert(list,untillist)
--                LoadMgr.loadFightModelAsync( value1, const.kAttrSoldier, level )
            end 
        end 
    end 
    return list
end 

function ArenaData.sendCdTime()
    local flag = false 
    for key ,value in pairs(gameData.user.building_list) do
        if value.building_type == const.kBuildingTypeSingleArena then 
           flag = true 
           break 
        end 
    end 
    if flag == true then 
       Command.run("arenacdtime")
    end 

end 

function ArenaData.setMainCdTime(msg)
   cdtime = msg.time_cd
end 

function ArenaData.getCdTime()
   return cdtime
end 

function ArenaData.isRealMan(id)
    return id >= 1000000
end 
