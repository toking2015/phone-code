trans.call.PRBuildingSet = function(msg)
    local isNew = not BuildingData.checkBuildingExist(msg.building.building_type)
    BuildingData.addBuilding(msg)
    if isNew then
        EventMgr.dispatch( EventType.UserBuildingAdd, msg )
    end
end

trans.call.PRBuildingList = function(msg)
    gameData.user.building_list = msg.list
    LogMgr.log( 'building', "建筑返回数据：" .. debug.dump(msg.list) )
    EventMgr.dispatch( EventType.UserBuildingUpdate, {} )
end

trans.call.PRBuildingSpeedOutput = function(msg)
    EventMgr.dispatch( EventType.BuildingCritUpdate, msg )
end

trans.call.PRBuildingMove = function(msg)
	-- LogMgr.log( 'debug',"+++++++++++++++++++PRBuildingMove++++++++++++")
	-- local building=msg.building
	-- local data=building.data
	-- LogMgr.log( 'debug',"data.target_id  "..data.target_id.."  data.info_id  "..data.info_id.."  data.info_type  "..data.info_type..
	-- 	"  data.info_level  "..data.info_level.."  data.info_position.first  "..data.info_position.first..
	-- 	"  data.info_position.second  "..data.info_position.second)
end

trans.call.PRBuildingUpgrade =function(msg)
    LogMgr.log( 'debug',"+++++++++++++++++PRBuildingUpgrade++++++++++")
end 

