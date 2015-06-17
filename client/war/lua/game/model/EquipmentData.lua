EquipmentData = {}
EquipmentData.equipmentMadeData = {}
EquipmentData.selectType = 4
EquipmentData.selectLevel = 1
EquipmentData.selectSubclass = 1
EquipmentData.isEquipmentState = false
EquipmentData.isBuy = false
EquipmentData.autoTips = false
EquipmentData.info_name_list = {'生命','攻击强度','护甲','法术强度','魔法抗性','速度','暴击等级','暴击抵抗','暴击伤害','韧性','命中','躲闪','格挡','精准'}
EquipmentData.tipsData = nil

function EquipmentData:getEquipTypeName( equip_type )
	local equip_name = '' 
	if equip_type == const.kEquipCloth then
		equip_name = '布甲'
	elseif equip_type == const.kEquipLeather then
		equip_name = '皮甲'
	elseif equip_type == const.kEquipMail then
		equip_name = '锁甲'
	elseif equip_type == const.kEquipPlate then
		equip_name = '板甲'
	end
	return equip_name
end

function EquipmentData:getEquipTypeOccupation( equip_type )
	local occupation = '' 
	if equip_type == const.kEquipCloth then
		occupation = '法师、术士、牧师'
	elseif equip_type == const.kEquipLeather then
		occupation = '德鲁伊、潜行者、武僧'
	elseif equip_type == const.kEquipMail then
		occupation = '猎人、萨满'
	elseif equip_type == const.kEquipPlate then
		occupation = '圣骑士、死亡骑士、战士'
	end
	return occupation
end

function EquipmentData:getEquipmentQualityName( quality )
	local qualityName = '' 
	if quality == const.kCoinEquipWhite then
		qualityName = "白"
	elseif quality == const.kCoinEquipGreen then
		qualityName = "绿"
	elseif quality == const.kCoinEquipBlue then
		qualityName = "蓝"
	elseif quality == const.kCoinEquipPurple then
		qualityName = "紫"
	elseif quality == const.kCoinEquipOrange then
		qualityName = "橙"
	end
	return qualityName
end

function EquipmentData:getEquipmentSubclassName( subclass)
	local subclassName = ''
	if subclass == const.kItemEquipTypeHead then
		subclassName = '头盔'
	elseif subclass == const.kItemEquipTypeChest then
		subclassName = '胸甲'
	elseif subclass == const.kItemEquipTypeLegs then
		subclassName = '裤子'
	elseif subclass == const.kItemEquipTypeShoulders then
		subclassName = '肩膀'
	elseif subclass == const.kItemEquipTypeHands then
		subclassName = '护手'
	elseif subclass == const.kItemEquipTypeFeet then
		subclassName = '鞋子'
	end
	return subclassName
end

--解析当前套装的属性
function EquipmentData:getEquipmentAllInfo( type, level,isTips )
	local equipmentList = nil
	if isTips then
		equipmentList = EquipmentData:getTipsList()
	else
		equipmentList = EquipmentData:getEquipmentList()
	end
	local list = {}
    for e,equipment in pairs(equipmentList) do
		local item = findItem( equipment.item_id )
        if item.equip_type == type and item.level == level then
			EquipmentData:getEquipmentInfo( equipment, item, list )	
		end
	end
	return list
end

--解析装备的具体属性列表
function EquipmentData:getEquipmentInfo( userItem, item, list )
	if list == nil then
		list = {}
	end

	local jEffect = nil
    for k,v in pairs(item.attrs) do
		if v.first ~= 0 then
			jEffect = findEffect( v.first )
			if jEffect then
				if list[jEffect.desc] == nil then
					list[jEffect.desc] = 0
				end
				list[jEffect.desc] = list[jEffect.desc] + math.floor( v.second * ( 1 + userItem.main_attr_factor / 10000 ) )
    		end
		end
	end

	--随机属性
	local slave_attr = nil
	for k,v in pairs(userItem.slave_attrs) do
        if v ~= 0 then
		    slave_attr = item.slave_attrs[v]
		    if slave_attr then
    			jEffect = findEffect( slave_attr.first )
    			if jEffect then
    				if list[jEffect.desc] == nil then
    					list[jEffect.desc] = 0
    				end
    				list[jEffect.desc] = list[jEffect.desc] + math.floor( slave_attr.second * ( 1 + userItem.slave_attr_factor / 10000 ) )       				
        		end
    		end
		end
	end
	return list			
end

--转换成适合聊天传输的轻量级装备数据结构
function EquipmentData:getEquipmentForChat( userItem )
	local userData = {}
	userData.item_id = userItem.item_id
	userData.main_attr_factor = userItem.main_attr_factor
	userData.slave_attrs = userItem.slave_attrs
	userData.slave_attr_factor = userItem.slave_attr_factor

	return userData
end

function EquipmentData:getEquipmentQuality( main_attr_factor )
	local list = GetDataList( 'EquipQuality' )
    for k,v in pairs(list) do
        if v ~= nil then
            if v.main_min == nil then
                v.main_min = 0
            end
            
            if v.main_max == nil then
                v.main_max = 0
            end
            
    		if v.main_min <= main_attr_factor and v.main_max >= main_attr_factor then
    			return v.quality
    		end
    	end
	end
	return const.kCoinEquipWhite
end

function EquipmentData:getEquipSuit( level, quality, equip_type )
	local equipSuitList = GetDataList( 'EquipSuit' )
	for k,v in pairs(equipSuitList) do
        if v.level == level and v.quality == quality and v.equip_type == equip_type then
			return v
		end
	end
	return nil
end

--已经装备的装备列表
function EquipmentData:getEquipmentList()
	return ItemData.getTable( const.kBagFuncSoldierEquip )
end

--未装备的装备列表
function EquipmentData:getUnEquipmentList()
	local itemList = ItemData.getTable( const.kBagFuncCommon )
	local equipmentList = {}
	local item = nil
	for k,v in pairs(itemList) do
		item = findItem( v.item_id )
		if item then
			if item.type == const.kItemTypeEquip then
				table.insert( equipmentList, v )
			end
		end
	end
	return equipmentList
end

--没有装备的物品
function EquipmentData:getNoEquipment( type, level, subclass )
	local itemList = GetDataList( 'Item' )
	for k,v in pairs(itemList) do
        if v.type == const.kItemTypeEquip and v.equip_type == type and v.level == level and v.subclass == subclass then
			return v
		end
	end
    return nil
end

--获取对应品质装备数量
function EquipmentData:getEquipmentCountForQuality( equip_type, level, quality, isTips )
	local equipmentList = nil
	if isTips then
		equipmentList = EquipmentData:getTipsList()
	else
		equipmentList = EquipmentData:getEquipmentList()
	end
	local count = 0
	for k,v in pairs(equipmentList) do
		if EquipmentData:checkEquipment( v, equip_type, level, nil ,quality, true ) then
			count = count + 1
		end
	end
	return count
end

--获取对应套装, 等级, 位置的已装备信息
function EquipmentData:getEquipmentForCondition( equip_type, level, subclass, isTips )
	local equipmentList = nil
	if isTips then
		equipmentList = EquipmentData:getTipsList()
	else
		equipmentList = EquipmentData:getEquipmentList()
	end
	for k,v in pairs(equipmentList) do
		if EquipmentData:checkEquipment( v, equip_type, level, subclass ) then
			return v
		end
	end
	return nil
end

--获取对应套装, 等级的已装备列表信息
function EquipmentData:getEquipmentListForSuit( equip_type, level )
	local equipmentList = EquipmentData:getEquipmentList()
	if level == nil then
		level = GameData.user.equip_suit_level[equip_type]
	end
	
	local list = {}
	for k,v in pairs(equipmentList) do
		if EquipmentData:checkEquipment( v, equip_type, level ) then
			table.insert( list, v )
		end
	end

	return list, equip_type, level
end

--获取对应套装, 等级的已装备列表评分
function EquipmentData:getEquipmentScoreForSuit( equip_type, level )
	local equipmentList = EquipmentData:getEquipmentList()
	if level == nil then
		level = GameData.user.equip_suit_level[equip_type]
	end
	
	local score = 0
	for k,v in pairs(equipmentList) do
		if EquipmentData:checkEquipment( v, equip_type, level ) then
			score = score + EquipmentData:getEquipmentScore(v, level)
		end
	end

	return score
end

--获取对应装备的评分
function EquipmentData:getEquipmentScore( userItem, level )
	local score = 0
	if userItem then
		local a = findGlobal("equip_grade_a").data;
		local b = findGlobal("equip_grade_b").data;
		local c = findGlobal("equip_grade_c").data;
		score = math.floor( ( 13333 + userItem.main_attr_factor + userItem.slave_attr_factor / 3 ) * a / 10000 * ( level ^ ( c / 100 ) + b / 100 ) )
	end
	return score	
end

--获取对应套装, 等级, 位置的已装备信息【如果本级没有，读更小一级】
function EquipmentData:getEquipmentForConditionMin( equip_type, level, subclass )
	for i=level,1,-1 do
		local findItem = EquipmentData:getEquipmentForCondition(equip_type,i,subclass)
		if findItem then
			return findItem
		end
	end
	return nil
end

--获取对应套装, 等级, 位置的未装备信息
function EquipmentData:getUnEquipmentListForCondition( equip_type, level, subclass )
	local equipmentList = EquipmentData:getUnEquipmentList()
	local list = {}
	for k,v in pairs(equipmentList) do
		if EquipmentData:checkEquipment( v, equip_type, level, subclass ) then
			table.insert( list, v )
		end
	end
	return list
end

--检测物品是否为装备物品
function EquipmentData:checkEquipment( user_item, equip_type, level, subclass, quality, containQuality )
	local item = findItem( user_item.item_id )
	if ( equip_type == nil or item.equip_type == equip_type ) 
		and ( level == nil or item.level == level ) 
		and ( subclass == nil or item.subclass == subclass ) then
		if containQuality ~= nil then
            return quality == nil or EquipmentData:getEquipmentQuality( user_item.main_attr_factor ) >= quality
		else
            return quality == nil or EquipmentData:getEquipmentQuality( user_item.main_attr_factor ) == quality
		end
	end
	return false
end

function EquipmentData:setEquipmentMadeData( type, level, subclass )
	EquipmentData.equipmentMadeData.jItem = EquipmentData:getNoEquipment( type, level, subclass )
	if EquipmentData.equipmentMadeData.jItem ~= nil then 
		EquipmentData.equipmentMadeData.noEquipment = ItemData.getItemMergeForItemId( EquipmentData.equipmentMadeData.jItem.id )
	else
		EquipmentData.equipmentMadeData.noEquipment = nil 
	end
end

function EquipmentData:getLevel( soldierLevel )
	local dataList = GetDataList("EquipSuit")
	local pre = nil
	for k,v in pairs(dataList) do
		if v.limit_level > soldierLevel then
			break
		else
			pre = v
		end
	end
	
	if pre then
		return pre.level
	end

	return 0 
end


function EquipmentData:getSoldierEquipTemp( type, level, subclass )
	local list = ItemData.getTable( const.kBagFuncSoldierEquipTemp )
	for k,v in pairs(list) do
		if EquipmentData:checkEquipment( v, type, level, subclass ) then
			return v
		end
	end
end

function EquipmentData:checkSoldierEquipTemp( type, level, subclass )
	return EquipmentData:getSoldierEquipTemp( type, level, subclass ) ~= nil
end

function EquipmentData:CheckSolderEquipTempForType( type)
	local list = ItemData.getTable( const.kBagFuncSoldierEquipTemp )
	for k,v in pairs(list) do
		for level=1,4 do
			for subclass=1,6 do
				if EquipmentData:checkEquipment( v, type, level, subclass ) then
					return true
				end
			end
		end
	end
	return false
end

function EquipmentData:CheckSolderEquipTempForLevel( level)
	local list = ItemData.getTable( const.kBagFuncSoldierEquipTemp )
	for k,v in pairs(list) do
		for type=1,4 do
			for subclass=1,6 do
				if EquipmentData:checkEquipment( v, type, level, subclass ) then
					return true
				end
			end
		end
	end
	return false
end

function EquipmentData:selectSuit( type, level )
	local theLevel = 0
	local equipSuit = EquipmentData:getEquipSuit( EquipmentData.selectLevel, const.kCoinEquipWhite, EquipmentData.selectType )
	if equipSuit ~= nil then 
		theLevel = equipSuit.limit_level 
	end	
	local info = '[font=CHAT_3]T'..level..EquipmentData:getEquipTypeName(type)..'套装已经穿齐，是否使用该套装备？[br][font=CHAT_3]（生效后'..theLevel..'级以上'..EquipmentData:getEquipTypeOccupation(type)..'英雄自动使用该套装备）'
	Command.run("showMsgBox", 
				info, 
				function() 
					Command.run( 'equip selectSuit', type, level )
				end)
end

function EquipmentData:MadeEquipment()
	EquipmentData:setEquipmentMadeData( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
	
    EquipmentData.autoTips = ( EquipmentData:getEquipmentForCondition( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass ) == nil )
	if EquipmentData.autoTips then
		for i=1,6 do
            if EquipmentData:getEquipmentForCondition( EquipmentData.selectType, EquipmentData.selectLevel, i ) == nil and i ~= EquipmentData.selectSubclass then
				EquipmentData.autoTips = false
			end	
		end
	end

	Command.run( 'ui show', "EquipmentMadeUI", PopUpType.MODEL )
end

function EquipmentData:checkSelectSuit( type, level )
	for i=1,6 do
		if EquipmentData:getEquipmentForCondition( type, level, i ) == nil then
			return false
		end	
	end
	return true
end

function EquipmentData:showEquipmentTips( sender, equipment )
	local postion = sender:getParent():convertToWorldSpace( cc.p(sender:getPositionX(), sender:getPositionY() - 100) )
	if equipment == nil then
		TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, '打造装备可获得属性' )		
	else
		local item = findItem( equipment.item_id )
        TipsMgr.showTips(postion, TipsMgr.TYPE_EQUIP, equipment )			
	end
end

function EquipmentData:checkMade( itemId )
 	local merge = ItemData.getItemMergeForItemId( itemId )
	for k,v in pairs(merge.materials) do
		if v["cate"] == trans.const.kCoinItem then
			if ItemData.getItemCount( v.objid, const.kBagFuncCommon ) < v.val then
               	return false
			end
		end
	end	 
	return true
end

function EquipmentData:checkNewThanOld( isNew )
	local userItem = EquipmentData:getSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
	local quality = 1
	local oldQuality = 1
	if userItem then
		local jItem = findItem( userItem.item_id )
		quality = ItemData.getQuality( jItem, userItem )
		local oldUserItem = EquipmentData:getEquipmentForCondition( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
		if oldUserItem then
			jItem = findItem( oldUserItem.item_id )
            oldQuality = ItemData.getQuality( jItem, oldUserItem )
		end
	end
	
	if isNew then
		return quality > oldQuality, oldQuality
	else
		return oldQuality > quality, quality
	end
end

function EquipmentData:setData(data)
    EquipmentData.tipsData = data 
end 

function EquipmentData:getTipsLevel()
	local level = 1
	if EquipmentData.tipsData then
       level = EquipmentData.tipsData.equip_level
	end
	return level
end

function EquipmentData:getTipsType()
	local type = 4
	if EquipmentData.tipsData then
       type = EquipmentData.tipsData.equip_type
	end
	return type
end

function EquipmentData:getTipsList()
	local list = EquipmentData:getEquipmentList()
	if EquipmentData.tipsData then
        list = EquipmentData.tipsData.item_list
	end
	return list
end