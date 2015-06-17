local __this = ItemData or {}
ItemData = __this

__this.itemColor = {
    [1] = cc.c3b(0xff, 0xff, 0xff),
    [2] = cc.c3b(0x31, 0xff, 0x16),
    [3] = cc.c3b(0x00, 0xd8, 0xff),
    [4] = cc.c3b(0xff, 0x09, 0xe5),
    [5] = cc.c3b(0xff, 0x90, 0x00)
}

__this.itemColor1 = {
    [1] = cc.c3b(0xff, 0xff, 0xff),
    [2] = cc.c3b(0x2d, 0x35, 0x0e),
    [3] = cc.c3b(0x00, 0x28, 0x50),
    [4] = cc.c3b(0x53, 0x00, 0xa9),
    [5] = cc.c3b(0xff, 0xdf, 0x2b)
}

function __this.clear()
    __this.ItemMergeList = {}
    __this.select_state = 1
    __this.select_index = 1
    __this.item_index = 1
end
__this.clear()
EventMgr.addListener(EventType.UserLogout, __this.clear)

--物品背景 1白 2绿 3蓝 4紫 5橙
function __this.getItemBgUrl(id)
    if id ~= nil and id >= 1 and id <= 5 then 
        return "image/ui/StoreUI/ItemBg/ItemBg_" .. id .. ".png"
    else 
        return "image/ui/StoreUI/ItemBg/ItemBg_" .. 1 .. ".png"
    end 
end 

function __this.getItemYuankuanUrl(id)
    if id ~= nil and id >= 1 and id <= 5 then 
        return "image/ui/StoreUI/ItemYuankuan/Itemyuankuan" .. id .. ".png"
    else 
        return "image/ui/StoreUI/ItemYuankuan/Itemyuankuan" .. 1 .. ".png"
    end 
end 

function __this.getItemKuanUrl(id)
    if id ~= nil and id >= 1 and id <= 5 then 
        return "image/ui/StoreUI/ItemKuan/ItemKuan_" .. id .. ".png"
    else 
        return "image/ui/StoreUI/ItemKuan/ItemKuan_" .. 1 .. ".png"
    end 
end 

function __this.getItemKuangeziUrl(id)
    if id ~= nil and id >= 1 and id <= 5 then 
        return "image/ui/StoreUI/ItemKuangezi/ItemKuangezi_" .. id .. ".png"
    else 
        return "image/ui/StoreUI/ItemKuan/ItemKuangezi_" .. 1 .. ".png"
    end 
end 

function __this.getQuality( jItem, userItem )
    local quality = 1
    if jItem then
        if jItem.type == const.kItemTypeEquip then
            if userItem then
                quality = EquipmentData:getEquipmentQuality( userItem.main_attr_factor ) - const.kCoinEquipWhite + 1
            end
        else
            quality = jItem.quality
            if quality == nil then
                quality = 1
            end
        end
    end
    return quality
end

function __this.qualityName( quality )
    local qualityName = '' 
    if quality == 1 then
        qualityName = "白"
    elseif quality == 2 then
        qualityName = "绿"
    elseif quality == 3 then
        qualityName = "蓝"
    elseif quality == 4 then
        qualityName = "紫"
    elseif quality == 5 then
        qualityName = "橙"
    end
    return qualityName
end

--获取物品的路径
function __this.getItemUrl(id)
    return __this.getItemUrlByJson(findItem(id))
end

function __this.getItemUrlByJson(jItem)
    if jItem then
        return string.format("image/icon/item/%d.png", jItem.icon)
    end
end

function __this.setItemUlr( itemVivw, id, isBag )
    local url = ''
    local loadType = ccui.TextureResType.plistType
    if id ~= 0 then
        url = __this.getItemUrl( id )
        loadType = ccui.TextureResType.localType
    end

    if url ~= '' then
        itemVivw:setVisible(true)
    else
        itemVivw:setVisible(false)
    end

    itemVivw:loadTexture( url, loadType )
end

function __this.getSources( item )
    local list = {}
    if item ~= nil then
        for k,v in pairs(item.sources) do
            if v.first ~= 0 then
                table.insert( list, v )
            end
        end
    end

    return list
end

function __this.getTable( type )
    type = type or const.kBagFuncCommon 
    local item_map = gameData.user.item_map
    if not item_map then
        item_map = {}
        gameData.user.item_map = item_map
    end
    local item_list = item_map[ type ]
    if not item_list then
        item_list = {}
        item_map[ type ] = {}
    end
    return item_list
end

function __this.setTable( type, list )
    gameData.user.item_map[ type ] = list
end

local function sortFunc(a, b) 
    local aCanUser = __this:checkPackage( a )
    local bCanUser = __this:checkPackage( b )
    local sortVal = false
    if aCanUser == bCanUser then
        if a.item_id ~= b.item_id then
            sortVal = a.item_id > b.item_id
        else
            sortVal = a.guid > b.guid
        end
    elseif aCanUser then
        sortVal = true
    else
        sortVal = false
    end
    return sortVal
end

function __this.getItemListForType( bagType, itemType )
    itemType = itemType - 1
    local itemList = {}
    local bagList = __this.getTable( bagType )
    if itemType == 0 then
        itemList = bagList
    else
        local item = nil
        if bagList ~= nil then
            for k,v in pairs(bagList) do
                item = findItem( v.item_id )
                if item and item.client_type == itemType then
                    table.insert( itemList, v )
                end
            end
        end
    end

    table.sort(itemList, sortFunc)
    return itemList
end

function __this.getItemListForCanExchange( bagType )
    local itemList = {}
    local bagList = __this.getTable( bagType )
    if itemType == 0 then
        itemList = bagList
    else
        local item = nil
        if bagList ~= nil then
            for k,v in pairs(bagList) do
                item = findItem( v.item_id )
                if item and item.can_exchange == 1 then
                    local user_can = true
                    if item.bind and item.bind > 0 then
                        user_can = false
                    end
                    if v.flags and v.flags == const.kCoinFlagBind then
                        user_can = false
                    end
                    if v.due_time and v.due_time > 0 then
                        user_can = false
                    end
                    if user_can then
                        table.insert( itemList, v )
                    end
                end
            end
        end
    end
    
    return itemList
end

--获取物品
function __this.getItemCount(itemId,bagType)
    if bagType == nil then bagType = const.kBagFuncCommon end
	local list = __this.getTable( bagType)
	local count = 0
	if list == nil then
		return count
	end
	for k,v in pairs(list) do
        if( v.item_id == itemId ) then
			count = count + v.count
		end
	end
	return count
end

function __this.haveItem(itemId,bagType)
    return __this.getItemCount(itemId, bagType) > 0
end

--合成物品数据
function __this.getItemMergeForItemId( itemId )
    local mergeList = GetDataList( 'ItemMerge' )
    for i,v in pairs(mergeList) do
        if v.dst_item.objid == itemId then
            return v;
        end
    end
    return nil
end

function __this.checkCanMerge( itemId )
    return __this.getItemMergeForItemId( itemId ) ~= nil
end

function __this.checkMerge(itemId)
    local merge = __this.getItemMergeForItemId( itemId )
    if merge ~= nil then
        for k,v in pairs(merge.materials) do
            if v.cate == trans.const.kCoinItem then
                if __this.getItemCount( v.objid, const.kBagFuncCommon  ) < v.val then
                    return false
                end
            elseif v.cate == const.kCoinMoney then
                if CoinData.getCoinByCate( v.cate, v.objid ) < v.val then
                    return false
                end
            end
        end
        return true
    end
    return false
end

function __this.setItemMerge( item_Id )
    local index = table.indexOf( __this.ItemMergeList, item_Id, 1, #table ) 
    if index == -1 then
        table.insert( __this.ItemMergeList, item_Id )
    else 
        for i = index + 1, #__this.ItemMergeList  do
            table.remove( __this.ItemMergeList, i )
        end
    end
end

function __this.getItemMerget( index )
    if index == 1 then
        if #__this.ItemMergeList > 3 then
            return __this.ItemMergeList[1]
        end
    elseif index == 2 then
        if #__this.ItemMergeList > 4 then
            return -1
        elseif #__this.ItemMergeList > 2 then
            return __this.ItemMergeList[3]
        end
    elseif index == 3 then
        if #__this.ItemMergeList > 1 then
            return __this.ItemMergeList[#__this.ItemMergeList - 1]
        end
    end
    
    return nil
end

function __this.getItemMergeList()
    return __this.ItemMergeList
end

function __this.cleartemMergeList()
    __this.ItemMergeList = {}
end

function __this.nextMerge()
    table.remove( __this.ItemMergeList, #__this.ItemMergeList )
    return __this.ItemMergeList[#__this.ItemMergeList]
end

--获得途径处理

function __this.getGainWayName( source )
    local name = ''
    if source.first == 1 then
        local copy = findCopy( source.second )
        if copy ~= nil then
            name = copy.name
        end
    elseif source.first == 2 then
        if source.second == 1 then
            name = '游戏商店'
        end
    end
    return name
end

function __this.getGainWayUrl(source)
    local url = ''
    if source.first == 1 then
        local copy = findCopy( source.second )
        if copy ~= nil then
            url = 'image/icon/copy/' .. copy.icon .. '.png'
        end
    elseif source.first == 2 then
        url = 'image/ui/bagUI/bag_way_icon_' .. source.second .. '.png'
    end

    return url
end

function __this.getGainWayLoadType(source)
    local type = ''
    if source.first == 1 then
        type = ccui.TextureResType.localType
    elseif source.first == 2 then
        type = ccui.TextureResType.localType
    end

    return type
end

-- 通过品质获取颜色
function __this.getItemColor(quality, type)
    local index = ''
    if type ~= nil then
        index = type
    end
    return __this['itemColor'..index][quality]
end

--道具描述
function __this.getItemDesc(id)
    local itemInfo = findItem(id)
    local str = ''
    if itemInfo then
        local mainTitle = fontNameString("TIP_T") ..itemInfo.name.. "[br]"
        local mainContent = fontNameString("TIP_C") .. itemInfo.desc
        str = mainTitle .. mainContent
    end
    return str
end

-- 获得对应item_id第一个item_guid
function __this.getItemGuid(bag_type, item_id)
    local item_list = __this.getTable(bag_type)
    for _, v in pairs(item_list) do
        if v.item_id == item_id then
            return v.guid
        end
    end
end

-- 获得对应item_id第一个UserItem
function __this.getItemById(bag_type, item_id)
    local item_list = __this.getTable(bag_type)
    for _, v in pairs(item_list) do
        if v.item_id == item_id then
            return v
        end
    end
end

--返回武将技能书
function __this.getSoldierSkillBook( soldierGuid )
    local list = ItemData.getTable( const.kBagFuncSoldierEquipSkill )
    for k,v in pairs(list) do
        if v.soldier_guid == soldierGuid then
            return v
        end
    end
    return nil
end

local function appendCostList(cost, _obj, count)
    obj = {cate = _obj.cate, objid = _obj.objid, val = _obj.val * count}
    for i, v in ipairs(cost) do
        if v.cate == obj.cate and v.objid == obj.objid then
            cost[i].val = cost[i].val + obj.val
            return
        end
    end
    cost[#cost+1] = obj
end

local function checkArrayCost(cost)
    for _, v in ipairs(cost) do
        if CoinData.getCoinByCate(v.cate, v.objid) < v.val then
            return false
        end
    end
    return true
end

local function getAlreadyUsed(cost, itemId)
    for _, v in ipairs(cost) do
        if v.cate == const.kCoinItem and v.objid == itemId then
            return v.val
        end
    end
    return 0
end

-- 层层合成
function __this.bookMergeRecursionCheck(itemId, cost, count)
    local jMerge = __this.getItemMergeForItemId(itemId)
    if not jMerge then return false end
    count = count or 1
    cost = cost or {}
    local subMergeItems = {}
    for k, v in ipairs(jMerge.materials) do
        if v.cate == const.kCoinMoney then
            appendCostList(cost, v, count)
        else
            local subMerge = __this.getItemMergeForItemId(v.objid)
            if not subMerge then
                appendCostList(cost, v, count)
            else
                subMergeItems[#subMergeItems+1] = v
            end
        end
    end

    if not checkArrayCost(cost) then return false end

    for k, v in ipairs(subMergeItems) do
        local need = v.val * count
        local got = __this.getItemCount(v.objid) - getAlreadyUsed(cost, v.objid)
        if got < need then
            if not __this.bookMergeRecursionCheck(v.objid, cost, need - got) then return false end
        else
            appendCostList(cost, v, count)
        end
    end

    return true
end

--检测是否有可以开启的礼包
function ItemData:checkBagPackage()
     local list = ItemData.getTable( const.kBagFuncCommon )
     local item = nil
     for k,v in pairs(list) do
        item = findItem( v.item_id )
        if ItemData:checkPackage( v) then
            return true
        end
     end
     return false
end

function ItemData:checkPackage( userItem )
    if userItem then
        item = findItem( userItem.item_id )
        if item and gameData.checkLevel( item.limitlevel ) and ( item.buff.cate == const.kItemUseAddRewardIndex or item.buff.cate == const.kItemUseAddRewardRandom)then
            -- if item.coin.cate == const.kCoinStrength then
            --     return not StrengthData.isStrengthFull()
            -- else
                return true
            -- end
        end
    end
    return false
end