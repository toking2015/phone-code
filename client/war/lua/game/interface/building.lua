-- 建筑列表
Command.bind( 'building list', 
	function(tid)
        trans.send_msg( 'PQBuildingList', {target_id = tid} )
	end 
)

-- 激活建筑
Command.bind( 'building add', 
	function(type, pos)
        trans.send_msg( 'PQBuildingAdd', {building_type = type, building_position = pos} )
	end
)

-- 建筑升级
Command.bind( 'building upgrade', 
	function(type, id)
        trans.send_msg( 'PQBuildingUpgrade', {building_type = type, building_id = id} )
	end 
)

-- 查询建筑
Command.bind( 'building query', 
	function(tid, type, id)
        trans.send_msg( 'PQBuildingQuery', { target_id = tid, building_type = type, building_id = id } )
	end 
)

--Command.bind( 'building getholy', 
--    function( type )
--        trans.send_msg( 'PQBuildingGetOutput', { building_type = type } )
--    end 
--)

-- 建筑加速
Command.bind( 'building output',
    function(type, times)
        trans.send_msg( 'PQBuildingSpeedOutput', {building_type = type, times = times})
    end
)

-- 建筑获取金币
Command.bind( 'building getoutput',
    function(type)
        trans.send_msg( 'PQBuildingGetOutput', {building_type = type})
    end
)
