ActTipsData = {}

-- 获取建筑ID
local function getBuildingId( ... )
	local b_id = const.kBuildingTypeGoldField
	if ActTipsData.currentType == const.kCoinMoney then
		b_id = const.kBuildingTypeGoldField
	elseif ActTipsData.currentType == const.kCoinWater then
		b_id = const.kBuildingTypeWaterFactory
	end
	return b_id
end

--显示窗口类型 const.kCoinMoney  const.kCoinWater const.kCoinStrength
function ActTipsData.showTipsByType(showtype)
	if showtype == const.kCoinStrength or ((showtype == const.kCoinMoney or showtype == const.kCoinWater) and 
		BuildingData.checkBuildingExist(showtype) and gameData.getSimpleDataByKey("team_level") >= 20) then
		ActTipsData.currentType = showtype
		Command.run( 'ui show', 'ActTipsUI', PopUpType.SPECIAL )
		return true
	else
		return false
	end
end

function ActTipsData.ComFirClick( ... )
	if(ActTipsData.getBuyLeft() == 0) then
		ActTipsData.hideTips()
		Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
	else
		-- 获取钻石数量
	    local dim = CoinData.getCoinByCate(const.kCoinGold)
	    if ActTipsData.getCost() > dim then
	    	local str = "[image=alert.png][font=ZH_9]钻石不足，请前往充值[btn=two]cancel.png:recharge.png"
	    	showMsgBox(str, function() ActTipsData.hideTips() Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL ) end)
	    else
	        -- 发送购买请求
	        if(ActTipsData.currentType == const.kCoinStrength) then
         	 	Command.run('buy strength')
	        else
				Command.run('building output', getBuildingId(), 1) 
	        end
	        ActTipsData.hideTips()
	    end
	end

end

function ActTipsData.hideTips( ... )
	ActTipsData.currentType = nil
	Command.run( 'ui hide', 'ActTipsUI')
end

-- 购买上限
function ActTipsData.getBuyMax( ... )
	local teamLevel = gameData.getSimpleDataByKey("vip_level")
	local levelData = findLevel(teamLevel)
	while levelData == nil and teamLevel > 0 do
        teamLevel = teamLevel - 1
        levelData = findLevel(teamLevel)
    end
	local buy_max = 0
	if levelData then
		if(ActTipsData.currentType == const.kCoinStrength) then
	  		while levelData.strength_buy == 0 and teamLevel > 0 do
		        teamLevel = teamLevel - 1
		        levelData = findLevel(teamLevel)
		    end
	  		buy_max = levelData.strength_buy
		elseif(ActTipsData.currentType == const.kCoinMoney) then
			while levelData.building_gold_times == 0 and teamLevel > 0 do
		        teamLevel = teamLevel - 1
		        levelData = findLevel(teamLevel)
		    end
			buy_max = levelData.building_gold_times
		elseif(ActTipsData.currentType == const.kCoinWater) then
			while levelData.building_water_times == 0 and teamLevel > 0 do
		        teamLevel = teamLevel - 1
		        levelData = findLevel(teamLevel)
		    end
			buy_max = levelData.building_water_times
		end
	end
	return buy_max
end
--获取已购买次数
function ActTipsData.getBuyCount( ... )
	local buy_count = 0
	if(ActTipsData.currentType == const.kCoinStrength) then
  		if VarData.getVarData().strength_day_buy_count == nil then
	       VarData.getVarData().strength_day_buy_count= {}
	       VarData.getVarData().strength_day_buy_count.value = 0
   		end
   		buy_count =  VarData.getVarData().strength_day_buy_count.value
	elseif(ActTipsData.currentType == const.kCoinMoney) then
		if VarData.getVarData().building_goldfiel_speed_time == nil then
	       VarData.getVarData().building_goldfiel_speed_time= {}
	       VarData.getVarData().building_goldfiel_speed_time.value = 0
   		end
   		buy_count =  VarData.getVarData().building_goldfiel_speed_time.value
	elseif(ActTipsData.currentType == const.kCoinWater) then
		if VarData.getVarData().building_waterfactory_speed_time == nil then
	       VarData.getVarData().building_waterfactory_speed_time= {}
	       VarData.getVarData().building_waterfactory_speed_time.value = 0
   		end
   		buy_count =  VarData.getVarData().building_waterfactory_speed_time.value
	end
	return buy_count
end

function ActTipsData.getBuyLeft( ... )
	return ActTipsData.getBuyMax() - ActTipsData.getBuyCount()
end

--单次购买数数值
function ActTipsData.getBuyNum( ... )
	local vip_level = gameData.getSimpleDataByKey("vip_level")
	local buynum = 0
	local building_level = 0
	local timesData = nil
	local u_building = nil
	local buildingid= getBuildingId()
	if (ActTipsData.currentType == const.kCoinStrength) then
		local powerData = findGlobal("strength_buy")
		if powerData then
			buynum = powerData.data -- 体力
		end
	else
		building_level = 1
    	u_building = BuildingData.getDataByType(buildingid)
        if u_building and u_building.data then
            building_level = u_building.data.info_level
        end
		 timesData = findBuildingCoin(buildingid)
		if timesData then
			while timesData.value[building_level] == nil and building_level > 0 do
		        building_level = building_level - 1
		    end
			buynum = timesData.value[building_level].val
		end
	end
	return buynum
end
--消耗钻石数
function ActTipsData.getCost( ... ) 
	local buycost = 0
	local vipLevel = gameData.getSimpleDataByKey("vip_level")
	if ActTipsData.currentType == const.kCoinStrength then
		local buytimes = ActTipsData.getBuyCount() + 1
		while findLevel(buytimes) == nil or (findLevel(buytimes).strength_price == nil or  findLevel(buytimes).strength_price == 0) do
			buytimes = buytimes -1
		end
		if findLevel(buytimes) and findLevel(buytimes).strength_price then
			buycost = findLevel(buytimes).strength_price
		end
	else
		local times = ActTipsData.getBuyCount() + 1
	  	local cost =  findBuildingCost(times)["cost"..getBuildingId()].val
	  	while (findBuildingCost(times) == nil or findBuildingCost(times)["cost"..getBuildingId()] == nil)and times > 0 do
		        times = times - 1
		        cost =  findBuildingCost(times)["cost"..getBuildingId()].val
	    end
    	if cost then
    		buycost = cost
    	end
    end
	return buycost
end

function ActTipsData.getButItemUrl( ... )
	if(ActTipsData.currentType == const.kCoinMoney) then
		return "icon_gold.png"
	elseif (ActTipsData.currentType == const.kCoinStrength) then
		return "icon_power.png"
	elseif(ActTipsData.currentType == const.kCoinWater) then
		return "icon_warter.png"
	end
end

function ActTipsData.getTitleUrl( ... )
	if(ActTipsData.currentType == const.kCoinMoney) then
		return "title_gold.png"
	elseif (ActTipsData.currentType == const.kCoinStrength) then
		return "title_power.png"
	else
		return "title_warte.png"
	end
end

function ActTipsData.showGetTips( data ,type)
	if type == const.kCoinStrength then
	    local txt = "购买成功！获得 体力：" .. data
    	TipsMgr.showSuccess(txt, visibleSize.width / 2, visibleSize.height / 2)
	end
end

Command.bind("show actTips",function ( showtype )
	ActTipsData.showTipsByType(showtype)
end
	)


