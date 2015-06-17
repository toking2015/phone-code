require( "lua/game/view/fight/misc/FightDataMgr.lua" )
require("lua/server/BattleLogic")

trans.call.PRCommonFightInfo = function( msg )
	LogMgr.log( 'debug',">>>>>>>>>>>>>FightInfo..........")
    ActionMgr.save("fight", string.format("fight_type[%s]", msg.fight_type))
    FightDataMgr:fightEnter(msg)
end

trans.call.PRFormationSet = function(msg)
	LogMgr.log( 'debug', "PRFormationSet+++++++++set_type:" .. msg.set_type)
	trans.send_msg( "PQCommonFightApply", {fight_type = 1, target_id = 20001} ) --请求战斗
end

--战斗结果
trans.call.PRCommonFightClientEnd = function(msg)
    if #FightDataMgr.fight_info_list > 1 and FightDataMgr.fight_id then
        ActionMgr.save( 'fight', 
            'PRCommonFightClientEnd check_result:' .. msg.check_result .. ' type:' .. FightDataMgr.fight_type 
            .. "  win_camp:" .. msg.win_camp
            .. "  id:" .. tostring(FightDataMgr.fight_id)
            .. "  player_guid:" .. FightDataMgr.fight_info_list[2].player_guid
            .. "  guid:" .. FightDataMgr.fight_info_list[2].guid )
    end

    if 0 ~= msg.check_result then
        --将记录上传到服务器
        local log = LogMgr.get_cache_log( 'fight' )
        if log ~= nil and log ~= '' then
            local stream = seq.string_to_stream( log )
            local length = seq.stream_length( stream )

            trans.send_msg( 'PQFightErrorLog', { data = { size = length, data = zlib.compress( stream ) } } )
        end
    end

    FightDataMgr:fight_quit(msg.check_result, msg.win_camp, msg.coins_list)
end

--战报
trans.call.PRFightRecordGet = function(msg)
	-- LogMgr.log( 'debug',"战报")
	-- LogMgr.log( 'debug',debug.dump(msg))
	EventMgr.dispatch(EventType.FightRecordGet)
	FightDataMgr.record = true
    FightDataMgr:recordEnter(msg.fight_record)
end

trans.call.PRCommonFightServerEnd = function (msg)
    FightDataMgr.record = true
    FightDataMgr:SingleArenaEnter(msg)
end

--协议为双人战斗相关============================start
--战斗技能返回
trans.call.PRFightRoundData = function (msg)
	FightDataMgr:roundDataPro(msg)
end

--战斗技能返回
trans.call.PRPlayerFightAck = function (msg)
	FightDataMgr:roundSoldierPro(msg)
end
--协议为双人战斗相关============================end


--[[
trans.call.PRFightInfo = function(msg)
    LogMgr.log( 'debug',"++++++++++++++++trans.call.PRFightInfo")

end
]]
