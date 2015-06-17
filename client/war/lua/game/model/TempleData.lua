TempleData = TempleData or {}

local cur_selected = 0 -- 当前选择
local cur_fight_value = 0 -- 当前战力

TempleData.RUNE_BOX_OPEN_BAG = 1
TempleData.UPGRADE_OPEN_BAG = 2
TempleData.OPEN_BAG = 3

TempleData.TYPE_SCORE = {
	[const.kTempleScoreSoldierCollect] = {"txt_add_hero","score_icon_hero","本日新增%s个英雄"},
	[const.kTempleScoreSoldierLevelUp] = {"txt_train_hero","score_icon_hero","本日英雄升级%s次"},
	[const.kTempleScoreSoldierQuality] = {"txt_hero_upgrade","score_icon_hero","本日英雄进阶%s次"},
	[const.kTempleScoreSoldierStar] = {"txt_hero_star","score_icon_hero","本日英雄升星%s次"},
	[const.kTempleScoreTotemCollect] = {"txt_add_totem","score_icon_totem","本日收集%s个图腾"},
	[const.kTempleScoreTotemLevelUp] = {"txt_totem_star","score_icon_totem","本日图腾升星%s次"},
	[const.kTempleScoreTotemSkillLevelUp] = {"txt_train_totem","score_icon_totem","本日图腾升级%s次"},
	[const.kTempleScoreGroupCollect] = {"txt_add_group","score_icon_group","本日收集组合%s个"},
	[const.kTempleScoreGroupLevelUp] = {"txt_upgrade_group","score_icon_group","本日组合升级%s次"}
}

TempleData.TYPE_DATA = {
	[const.kEquipPlate] = {"土系", "板甲", cc.c3b(0xff, 0xd5, 0x2c)},
	[const.kEquipMail] = {"火系", "锁甲", cc.c3b(0xff, 0x00, 0x00)},
	[const.kEquipCloth] = {"水系", "布甲", cc.c3b(0x53, 0xe9, 0xff)},
	[const.kEquipLeather] = {"风系", "皮甲", cc.c3b(0xff, 0xff, 0xff)},
	[0] = {"风系", "", cc.c3b(0xff, 0xff, 0xff)}
}

function TempleData.getData()
	local temple = gameData.user.temple
	if not temple then
		temple = {}
		gameData.user.temple = temple
	end
	return temple
end

function TempleData.setData(value)
	gameData.user.temple = value
	EventMgr.dispatch(EventType.TempleInfo)
end

--系别颜色
function TempleData.getTypeColor(type)
	return TempleData.TYPE_DATA[type][3]
end


function TempleData.getRuneOpenLevel( ... )
	return tonumber( findGlobal("temple_rune_open_level").data )
	-- return 40
end

-- 获取当前类型开了多少个格子
function TempleData.getBoxLenById( type )
	if not TempleData.getData() then
		return nil
	end
	if type == const.kEquipCloth then
		return TempleData.getData().hole_cloth
	elseif type == const.kEquipLeather then
		return TempleData.getData().hole_leather
	elseif type == const.kEquipMail then
		return TempleData.getData().hole_mail
	elseif type == const.kEquipPlate then
		return TempleData.getData().hole_plate
	end
end

function TempleData.getTypeName( type )
    --1:布甲，2:皮甲，3:锁甲，4:板甲
    return TempleData.TYPE_DATA[type][2]
    -- local nameData = {"布甲","皮甲","锁甲","板甲"}
    -- return nameData[type]
end

function TempleData.getRuneTypeName(type)
	local rune_name = '' 
	if type == const.kEquipCloth then
		rune_name = '布甲神符'
	elseif type == const.kEquipLeather then
		rune_name = '皮甲神符'
	elseif type == const.kEquipMail then
		rune_name = '锁甲神符'
	elseif type == const.kEquipPlate then
		rune_name = '板甲神符'
	end
	return rune_name
end

function TempleData.getRuneTypeIcon(type)
	local rune_name = '' 
	if type == const.kEquipCloth then
		rune_name = '_rune_cloth.png'
	elseif type == const.kEquipLeather then
		rune_name = '_rune_leather.png'
	elseif type == const.kEquipMail then
		rune_name = '_rune_mail.png'
	elseif type == const.kEquipPlate then
		rune_name = '_rune_plate.png'
	end
	return rune_name
end

function TempleData.getRuneListByType( type )
	if #TempleData.getData().glyph_list == 0 then 
		return {}
	end
	local rune_list = {}
	local rune = nil
	for k,v in pairs(TempleData.getData().glyph_list) do
		rune = findTempleGlyph(v.id)
		if rune and rune.type == type then
			table.insert(rune_list,v)
		end
	end
	table.sort(rune_list,TempleData.sortFunc)
	return rune_list
end

function TempleData.sortRuneList( list )
	table.sort(list,TempleData.sortFunc)
	return list
end

function TempleData.sortFunc( a,b )
	if a == nil or b == nil then
		return true
	end
	local aGlyph = findTempleGlyph(a.id)
	local bGlyph = findTempleGlyph(b.id)
	if a.embed_type > b.embed_type then
		return true
	elseif a.embed_type < b.embed_type then
		return false
	end
	if aGlyph.quality > bGlyph.quality then
		return true
	elseif aGlyph.quality < bGlyph.quality then
		return false
	end
	if a.level > b.level then
		return true
	elseif a.level < b.level then
		return false
	end
	if aGlyph.type > bGlyph.type then
		return true
	elseif aGlyph.type < bGlyph.type then
		return false
	end
end

function TempleData.sortAttrFunc( a,b )
	if a == nil or b == nil then
		return true
	end
	if a.first<b.first then
		return true
	end
end

function TempleData.getEmbedListByType( type )
	if not TempleData.getData() then 
		return {}
	end
	local rune_list = {}
	local rune = nil
	for k,v in pairs(TempleData.getData().glyph_list) do
		rune = findTempleGlyph(v.id)
		if rune and rune.type == type then
			if v.embed_type == type then
				table.insert(rune_list,v)
			end
		end
	end
	return rune_list
end

function TempleData.SetGroupInfo(sTempleGroup)
	TempleData.getData().group_list[sTempleGroup.id] = sTempleGroup
end

function TempleData.CheckIsCanLvUp(id)
	local jGroup = findTempleGroup(id)
	local star = 0
	local temple_group = TempleData.getTempleGroupById(id)
	local jLvUp = nil
	if(temple_group ~= nil) then
		jLvUp = findTempleGroupLevelUp(id,temple_group.level+1)
	else
		return false
	end
	if(jLvUp == nil) then
		return false
	end
	star = TempleData.getGroupStar(jGroup)
	if star >= jLvUp.star then
		return true
	else
		return false
	end
end

-- 获取组合星数
function TempleData.getGroupStar(jGroup)
	if jGroup == nil then return 0 end
	local star = 0
	local sData = nil
	for k,v in pairs(jGroup.members) do
		if(v.first == const.kCoinSoldier) then
			sData = SoldierData.getSoldierBySId(v.second)
		else
			sData = TotemData.getTotemById(v.second)
		end
		if(sData ~= nil) then 
			star = star + (v.first == const.kCoinSoldier and sData.star or sData.level)
		end
	end
	return star
end

-- 根据id获取组合数据
function TempleData.getTempleGroupById(id)
	if TempleData.getData() ~=nil then
		local list = TempleData.getData().group_list
		if list ~= nil then
			return gameData.findArrayData(list,"id",id)
		end
	end
	return nil
end

-- 根据id判断是否已经领取奖励
function TempleData.getIsTakenReward( id )
	local list = TempleData.getData().score_taken_list
	if list then
		for i,v in ipairs(list) do
			if (id == v) then
				return true
			end
		end
	end
	return false
end

-- 根据分数获取奖励列表
function TempleData.getReward( score )
	local list = GetDataList("TempleScoreReward")
	for k,v in pairs(list) do
		if score >= v.score and not TempleData.getIsTakenReward(v.id) then
			return v
		end
	end
	return nil
end

-- 获取下一个可领取奖励
function TempleData.getNextReward( ... )
	score = TempleData.getRewardScore( 1 )
	local list = GetDataList("TempleScoreReward")
	for k,v in pairs(list) do
		if score < v.score and not TempleData.getIsTakenReward(v.id) then
			return v
		end
	end
	return nil
end

--type为1是当前积分，2为昨日积分
function TempleData.getRewardScore( type )
	if not TempleData.getData() then 
		return 0 
	end

	local score = 0
	local list = {}
	if type == 1 then
		list = TempleData.getData().score_current
	else
		list = TempleData.getData().score_yesterday
	end
	for k,v in pairs(list) do
		score = score + v.second
	end
	return score
end

function TempleData.checkIsCanTakeReward( ... )
	if not TempleData.getReward(TempleData.getRewardScore(1)) then
		return false
	end
	return true
end

function TempleData.getScoreTxtUrl( type )
	return TempleData.TYPE_SCORE[type][1]
end

function TempleData.getScoreIconUrl( type )
	return TempleData.TYPE_SCORE[type][2]
end

function TempleData.getScoreTxt( type )
	return TempleData.TYPE_SCORE[type][3]
end

-- 获取组合所加属性列表
function TempleData.getGroupAttr( ... )
	local group_attrs = {}
	for k,vitem in pairs(TempleData.getData().group_list) do
		local jLvup = findTempleGroupLevelUp(vitem.id,vitem.level)
		if jLvup then
			for i,v in ipairs(jLvup.attrs) do
				local attr = gameData.findArrayData(group_attrs,"first",v.first)
				if attr then
					attr.second = attr.second + v.second
				else
					local val = clone(v)
					table.insert(group_attrs,val)
				end
			end
		end
	end
	return group_attrs
end

-- 获取神符所加属性列表
function TempleData.getGlyphAttr( ... )
	local glyph_attrs = {}
	for i=1,4 do
		local list = TempleData.getEmbedListByType(i)
		for k,vitem in pairs(list) do
			local jGlyph = findTempleGlyphAttr(vitem.id,vitem.level)

			if jGlyph then
				for j,v in ipairs(jGlyph.attrs) do
					local index = gameData.findArrayIndex(glyph_attrs,"first",v.first)
					if index > 0 then
						glyph_attrs[index].second = glyph_attrs[index].second + v.second
					else 
						local val = clone(v)
						table.insert(glyph_attrs,val)
					end
				end
			end
		end
	end	
	return glyph_attrs
end

-- 获取神符所加属性
function TempleData.getGlyphAttrByType( type )
	local glyph_attrs = {}
	local list = TempleData.getEmbedListByType(type)
	for k,v in pairs(list) do
		local jGlyph = findTempleGlyphAttr(v.id,v.level)

		if jGlyph then
			for j,vItem in ipairs(jGlyph.attrs) do
				local index = gameData.findArrayIndex(glyph_attrs,"first",vItem.first)
				if index > 0 then
					glyph_attrs[index].second = glyph_attrs[index].second + vItem.second
				else 
					local val = clone(vItem)
					table.insert(glyph_attrs,val)
				end
			end
		end
	end
	return glyph_attrs
end

function TempleData.getGlyphByGuid( guid )
	if TempleData.getData() then
		return gameData.findArrayData(TempleData.getData().glyph_list,"guid",guid)
	end
	return nil
end

function TempleData.getTotalAttr( ... )
	local total_attrs = {}
	local group_list = TempleData.getGroupAttr()
	local glyph_list = TempleData.getGlyphAttr()
	-- if #group_list >= 0 and #glyph_list >= 0 then
		table.insertTo(glyph_list,group_list)
	-- end
	for k,v in pairs(glyph_list) do
		local attr = gameData.findArrayData(total_attrs,"first",v.first)
		if attr then
			attr.second = attr.second + v.second
		else
			local val = clone(v)
			table.insert(total_attrs,val)
		end
	end
	-- for k,v in pairs(group_list) do
	-- 	local attr = gameData.findArrayData(total_attrs,"first",v.first)
	-- 	if attr then
	-- 		attr.second = attr.second + v.second
	-- 	else
	-- 		local val = clone(v)
	-- 		table.insert(total_attrs,val)
	-- 	end
	-- end
	return total_attrs
end

-- type=1是消耗物品2是消耗货币
function TempleData.checkIsEnoughOpen( type ,index )
	local jTempleHole = findTempleHole(index)
	if not GameData.checkLevel(tonumber(jTempleHole.level)) then
		return false
	end
	local cost_list = nil
	if type == 1 then 
		cost_list = jTempleHole.cost_item
	else
		cost_list = jTempleHole.cost_coin
	end
	if index > const.kTempleHoleMaxCount then
		return false
	end

	for k,v in pairs(cost_list) do
		if type == 1 then
			local packNum = ItemData.getItemCount(v.objid,const.kBagFuncCommon)
			if packNum < v.val then
				return false
			end
		else
			local cost = CoinData.getCoinByCate(v.cate)
			if cost < v.val then
				return false
			end
		end
	end
	return true
end

function TempleData.getPackNum( index )
	local jTempleHole = findTempleHole(index)
	local packNum = ItemData.getItemCount(jTempleHole.cost_item[1].objid,const.kBagFuncCommon)
	return packNum
end

function TempleData.getOpenItemString( type ,index )
	local jTempleHole = findTempleHole(index)
	local cost_list = nil
	if type == 1 then 
		cost_list = jTempleHole.cost_item
	else
		cost_list = jTempleHole.cost_coin
	end
	local str = ""
	for k,v in pairs(cost_list) do
		if str == "" then
			str = v.val.."个"..CoinData.getCoinName(v.cate,v.objid)
		else 
			str = str .. "," ..  v.val.."个"..CoinData.getCoinName(v.cate,v.objid)
		end
	end
	return str
end

function function_name( ... )
	-- body
end

--根据队伍等级获取图腾升级等级
function TempleData.getMaxLevel( ... )
	local levelData = findLevel(gameData.user.simple.team_level)
	return levelData.glyph_lv
end

--神符对象，设置滤镜需要传入node.icon
local GlyphNode = class("GlyphNode", function()
	return cc.Node:create()
end)

function GlyphNode:play()
	self.icon:play()
end

function GlyphNode:stop()
	self.icon:stop()
end

local function glyphTouchBegin(touch, event)
	local dw = event:getCurrentTarget()
	if dw then
		local pos = touch:getLocation()
		TipsMgr.showTips(pos, TipsMgr.TYPE_RUNE, dw.jGlyph, dw.sGlyph)
	end
end

--神符基础加成（描述）
function TempleData.getJGlyphArr( sGlyph )
    local str = ''
    local jEffect = nil
    local exp = ""
    if sGlyph then
    	local attr = findTempleGlyphAttr(sGlyph.id,sGlyph.level)
    	if attr then
    		str = TempleData.glyphArrForList(attr.attrs,"属性")
    		local jGlyph = findTempleGlyph(sGlyph.id)
			exp = fontNameString("GG_GREEN") .. "吞噬后可增加" .. TempleData.getJGlyphExp(sGlyph)+jGlyph.exp .."神符经验"
    		str = str .. "[br]"
    		str = str .. exp 
    	else
    		local jGlyph = findTempleGlyph(sGlyph.id)
    		str = fontNameString("TIP_T2").."经验"..fontNameString("TIP_C") .. "+" .. jGlyph.exp
		end
    end
    return str
end

function TempleData.getJGlyphExp( sGlyph )
	local exp = 0
	for i=1,sGlyph.level - 1 do
		local attr = findTempleGlyphAttr(sGlyph.id,sGlyph.level)
		exp = exp + sGlyph.exp
	end
	return exp
end

--神符基础加成（描述）
function TempleData.getJGlyphArrByJGlyph( jGlyph )
    local str = ''
    local jEffect = nil
    local exp = ""
    if jGlyph then
    	local attr = findTempleGlyphAttr(jGlyph.id,jGlyph.init_lv)
    	if attr then
    		str = TempleData.glyphArrForList(attr.attrs,"属性")
			exp = fontNameString("GG_GREEN") .. "吞噬后可增加" .. jGlyph.exp .."神符经验"
    		str = str .. "[br]"
    		str = str .. exp 
		end
    end
    return str
end

--构造神符显示对象
function TempleData.getGlyphObject(glyph_id, winName, parent, x, y, sGlyph,hideTips)
	local jGlyph = findTempleGlyph(glyph_id)
	if jGlyph then
		local name = jGlyph.icon
		local url = string.format("image/armature/glyph/%s/%s.ExportJson", name, name)
		local dw = GlyphNode.new()
		local icon = ArmatureSprite:addArmature(url, name, winName, dw, 30, 30)
		parent:addChild(dw)
		dw:setPosition(x, y)
		dw:setContentSize(60, 60)
		dw:setAnchorPoint(0.5, 0.5)
		dw.icon = icon
		dw._dwname = jGlyph.icon
		dw.jGlyph = jGlyph
		dw.sGlyph = sGlyph
		if not hideTips then
			UIMgr.registerScriptHandler(dw, glyphTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN, true)
		end
		return dw
	end
	return nil
end

function TempleData.totalGlyphArrForList( list,titleStr )
	if list == nil then
		return ""
	end

	local str = ''
    local index = 1
    -- for i=1,14 do
    for k,v in pairs(list) do
    	-- local v = gameData.findArrayData(list,"first",i)
    	local jEffect = findEffect( v.first )
        if i ~= 1 then
        	str = str .. "[br]"
        end
        local valStr = " +"
        valStr = fontNameString("GG_GREEN") .. valStr .. v.second
     --    if v then
	    --     -- if jEffect.PercenValue == 0 then
	    --     -- else
	    --     -- 	valStr = valStr .. (v.second/100) .. '%'
	    --     -- end
	    -- else
	    -- 	valStr = "  --"
	    -- end

        local arrT = fontNameString("TIP_T2") .. titleStr ..k..':'
		local arr = fontNameString("GG_YELLOW") .. jEffect.desc
		str = str .. arr .. valStr
        index = index + 1    	
	end
	return str
end

function TempleData.glyphArrForList( list,titleStr,quality )
	if list == nil then
		return ""
	end

	local str = ''
    local index = 1
	for k,v in pairs(list) do
        if v.first ~= 0 then
            jEffect = findEffect( v.first )
            if k ~= 1 then
            	str = str .. "[br]"
            end
            local valStr = "+"
            -- if jEffect.PercenValue == 0 then
            	valStr = fontNameString("GG_GREEN") .. valStr .. v.second
            -- else
            -- 	valStr = valStr .. (v.second/100) .. '%'
            -- end

            local arrT = fontNameString("TIP_T2") .. titleStr ..k..':'
    		local arr = fontNameString("GG_YELLOW") .. jEffect.desc
    		str = str .. arr .. valStr
            index = index + 1
        end
    end
    return str
end

function TempleData.isMove(prev, curr)
	local jGroup = findTempleGroup(cur_selected)
	local max_level = #jGroup.members
	local d = math.abs(curr - prev)
	local v = (curr - prev) > 0 and -1 or 1
	if v < 0 then
		-- 向左滑动
		LogMgr.debug(">>>>>left>>>>>")
		-- if prev >= 18 or curr == 20 then
		if prev >= max_level - 2 or curr == max_level then
			return false, 100
		end
		if prev == 0 and d == 1 then
			return false, 0
		elseif prev == 0 then
			return true, 2 - d
		else
			return true, -1
		end
	else
		-- 向右滑动
		LogMgr.debug(">>>>>right>>>>>")
		if curr <= 0 then
			return false, 100
		end
		-- if prev == 20 and d == 1 then
		if prev == max_level and d == 1 then
			return false, 0
		-- elseif prev == 20 then
		elseif prev == max_level then
			return true, -d--1 - d
		else
			return true, -d-- - 1
		end
	end
end

function TempleData.checkOpenRedPoint( type,index)
	local len = TempleData.getBoxLenById(type)
	if index ~= len + 1 then
		return false
	end
	if TempleData.checkIsEnoughOpen(1,index) or TempleData.checkIsEnoughOpen(2,index) then
		return true
	end
	return false
end

function TempleData.checkIsEmpty( type,index )
	local len = TempleData.getBoxLenById(type)
	local list = TempleData.getEmbedListByType(type)
	local glyph_list = TempleData.getRuneListByType(type)
	if index < len then
		local data = gameData.findArrayData(list,"embed_index",index)
		if not data and #glyph_list > #list then 
			return true
		end
	end
	return false
end

-- 检测是否有相同类型的神符
function TempleData.checkIsSameGlyph(sGlyph,index)
	local jGlyphAttr = findTempleGlyphAttr(sGlyph.id,sGlyph.level)
	local type = TempleData.getCurSelected()
	local list = TempleData.getEmbedListByType(type)
	for k,v in pairs(list) do
		local attr = findTempleGlyphAttr(v.id,v.level)
		if jGlyphAttr.attrs[1].first == attr.attrs[1].first then
			if v.embed_index ~= index then
				return true
			end
		end
	end
	return false
end

-- 检测是否有空的神符孔，并且有可以装备的神符
function TempleData.checkHasEmptyByType( type )
	local len = TempleData.getBoxLenById(type)
	local list = TempleData.getEmbedListByType(type)
	local glyph_list = TempleData.getRuneListByType(type)
	if #list < len and #glyph_list > #list then
		return true
	end
	return false
end

-- 检测当前神符格子是否空余
function TempleData.getEmptyIndex( type )
	local len = TempleData.getBoxLenById(type)
	local list = TempleData.getEmbedListByType(type)
	for i=1,len do
		local index = i - 1
		if not gameData.findArrayData(list,"embed_index",index) then
			return index
		end
	end
	return -1
end

-- 背包当前选择
function TempleData.setCurSelected(index)
	if index == cur_selected then
		return
	end
	cur_selected = index
end

function TempleData.getCurSelected()
	return cur_selected
end

-- 记录打开界面时战力
function TempleData.setCurFightValue(value)
	if value == cur_fight_value then
		return
	end
	cur_fight_value = value
end

function TempleData.getCurFightValue()
	return cur_fight_value
end