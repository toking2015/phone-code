TotemData = TotemData or {}

TotemData.AVATAR_SCALE = 0.85
TotemData.GLYPH_OPEN_ID = 101 --雕文开放ID
TotemData.MAX_ATTR_LEVEL = 25 --图腾最多25级
TotemData.MAX_LEVEL = 5 --图腾最多5星
TotemData.ATTR_COUNT = 3 --图腾共有3种属性
TotemData.levelPerStar = 5 --每星级有多少等级
TotemData.typeJsonMap = nil --typeJsonMap
TotemData.curTotemStarUp = nil
TotemData.qBlessTotem  = nil --请求强化时图腾
TotemData.bBlessTotem  = nil --强化返回时图腾

function TotemData.clear()
	TotemData.currentTabIndex = 0 -- 当前标签
	TotemData.currentTotemGuid = 0 --当前的图腾
	TotemData.mergeData = nil
	TotemData.isWakeDouble = false --是否觉醒翻倍
	TotemData.activeMap = {} --待激活的图腾表
	TotemData.idMap = {} --用id作为索引的表 id=>guid
	TotemData.lockBless = false --是否正在等待服务器返回
end
TotemData.clear()
EventMgr.addListener(EventType.UserLogout, TotemData.clear)

--重建id=>guid索引
function TotemData.updateIdMap()
	local list = TotemData.getData()
	TotemData.idMap = {}
	for _,v in pairs(list) do
		TotemData.idMap[v.id] = v.guid
	end
end
EventMgr.addListener(EventType.UserDataLoaded, TotemData.updateIdMap)

TotemData.RULE_SLOT = {
	"[font=JJ_1]1、雕文只能镶嵌在同系别的图腾上",
	"[font=JJ_1]2、每个图腾最多镶嵌4个雕文，每次镶嵌都有可能成功镶嵌或者随机替换一个已有雕文",
	"[font=JJ_1]3、同一个图腾上如果镶嵌有相同属性雕文，只计算效果最大的一个"
}
TotemData.RULE_MERGE = {
	"[font=JJ_1]1、只有同品质的雕文可以合成",
	"[font=JJ_1]2、合成成功则两个雕文属性叠加，系别在两个参与合成的雕文系别中随机",
	"[font=JJ_1]3、合成失败则参与合成的雕文随机失去一个",
	"[font=JJ_1]4、合成成功有一定几率激活雕文隐藏属性"
}

TotemData.COLOR = {
	[const.kQualityWhite] = cc.c3b(0xff, 0xff, 0xff),
	[const.kQualityGreen] = cc.c3b(0xfa, 0xff, 0xcd),
	[const.kQualityBlue] = cc.c3b(0x00, 0xff, 0xfc),
	[const.kQualityPurple] = cc.c3b(0xfe, 0xa7, 0xff),
	[const.kQualityOrange] = cc.c3b(0xff, 0x54, 0x00)
}

TotemData.TYPE_DATA = {
	[const.kTotemTypeDaDi] = {"土系", "板甲", cc.c3b(0xff, 0xd5, 0x2c)},
	[const.kTotemTypeHuoYan] = {"火系", "锁甲", cc.c3b(0xff, 0x00, 0x00)},
	[const.kTotemTypeShuiLiu] = {"水系", "布甲", cc.c3b(0x53, 0xe9, 0xff)},
	[const.kTotemTypeKongQi] = {"风系", "皮甲", cc.c3b(0xff, 0xff, 0xff)}
}

TotemData.MERGE_RATE = {
	[const.kQualityWhite] = 100,
	[const.kQualityGreen] = 80,
	[const.kQualityBlue] = 70,
	[const.kQualityPurple] = 60,
	[const.kQualityOrange] = 50
}

TotemData.QUALITY_DATA = {
	[const.kQualityWhite] = "粗糙",
	[const.kQualityGreen] = "普通",
	[const.kQualityBlue] = "精良",
	[const.kQualityPurple] = "史诗",
	[const.kQualityOrange] = "传说"
}

TotemData.SLOT_RATE = {
	[0] = 100,
	[1] = 50,
	[2] = 33,
	[3] = 25,
	[4] = 0
}

--图腾模拟强化
function TotemData.virTotemData( sTotem )
	if sTotem.wake_lv == 0 then
		sTotem.wake_lv = sTotem.wake_lv + 1
	elseif sTotem.formation_add_lv == 0 then
		sTotem.formation_add_lv = sTotem.formation_add_lv + 1
	elseif sTotem.speed_lv == 0 then
		sTotem.speed_lv = sTotem.speed_lv + 1
	end
	
	SoundMgr.playUI("ui_rolelevelup")
	TotemData.lockBless = false
    TotemData.bBlessTotem = sTotem
    gameData.changeArray(TotemData.getData(), 'guid', const.kObjectUpdate, sTotem)
    EventMgr.dispatch(EventType.UserTotemChange)
    EventMgr.dispatch(EventType.UserTotemBlessSuccess)
end

function TotemData.getSlotRate(hasCount)
	return TotemData.SLOT_RATE[hasCount]
end

function TotemData.getMap(type)
	type = type or const.kTotemPacketNormal
	local info = gameData.user and gameData.user.totem_map[type]
	if not info then
		info = {}
		gameData.user.totem_map[type] = info
	end
	return info
end

function TotemData.getData()
	local map = TotemData.getMap()
    local list = map.totem_list
    if not list then
    	list = {}
    	map.totem_list = list
    end
    return list
end

function TotemData.getLevelForStyle( jTotem )
	local level = 1
    local sTotem = TotemData.getTotemById(jTotem.id)
    if sTotem then
        level = sTotem.level
    end
    return level
end

function TotemData.getTypeJson(type)
	if not TotemData.typeJsonMap then
		TotemData.typeJsonMap = {}
		local allList = {}
		TotemData.typeJsonMap[0] = allList
		for _,v in pairs(GetDataList("Totem")) do
			if v.id >= 80100 then --需要过滤测试图腾
				local typeList = TotemData.typeJsonMap[v.type]
				if not typeList then
					typeList = {}
					TotemData.typeJsonMap[v.type] = typeList
				end
				table.insert(typeList, v)
				table.insert(allList, v)
			end
		end
	end
	return TotemData.typeJsonMap[type]
end

--图腾排序
function TotemData.sortJsonFunc(a, b)
	local aActivate = TotemData.checkCanActivate(a)
	local bActivate = TotemData.checkCanActivate(b)
	if aActivate ~= bActivate then
		return aActivate
	end

	--等级比较
	local levelResult = TotemData.compareLevel(a,b)
	if levelResult ~= nil then
		return levelResult
	end
	
	--激活条件比较
	local condResult = TotemData.compareCond(a,b)
	if condResult ~= nil then
		return condResult
	end

	local aHas = TotemData.hasTotem(a.id)
	local bHas = TotemData.hasTotem(b.id)
	if aHas ~= bHas then
		return aHas
	end
	return a.id < b.id
end

function TotemData.compareLevel(a, b)
	local a_data = TotemData.getTotemById(a.id)
	local b_data = TotemData.getTotemById(b.id)
	if a_data and b_data then
		if a_data.level > b_data.level then
			return true
		elseif a_data.level < b_data.level then
			return false
		end
	end
	return nil
end

function TotemData.compareCond(a, b)
	local a_data = TotemData.getTotemById(a.id)
	local b_data = TotemData.getTotemById(b.id)
	if not a_data and not b_data then
		local a_conds = a.activate_conds
		local a_cond = a_conds[1]
		local b_conds = b.activate_conds
		local b_cond = b_conds[1]
		if a_cond.val > b_cond.val then
			return false
		elseif a_cond.val < b_cond.val then
			return true
		end
	end
	return nil
end

--总共拥有的图腾数量
function TotemData.getCount()
	return table.nums(TotemData.getData())
end

--图腾总星级
function TotemData:getStarCount()
	local result = 0
	local list = TotemData.getData()
	for _,v in pairs(list) do
		result = result + v.level
	end
	return result
end

function TotemData.hasTotem( id )
	return TotemData.idMap[id] ~= nil
end

function TotemData.checkIsLevel()
	local list = TotemData.getData()
	for k,v in pairs(list) do
        if v.energy_time > 0 or v.speed_lv > 0 or v.formation_add_lv > 0 or v.wake_lv > 0 then
			return false
		end
	end
	return true
end

--是否合成的雕纹
function TotemData.isMergedGlyph(sGlyph)
	return sGlyph and #sGlyph.attr_list > 1
end

function TotemData.getGlyphName(sGlyph, jGlyph)
	if sGlyph then
		jGlyph = jGlyph or findTempleGlyph(sGlyph.id)
		if TotemData.isMergedGlyph(sGlyph) then
			return "合成雕文"--TotemData.getTypeName(jGlyph.type)..
		end
	end
	return jGlyph and jGlyph.name or ""
end

function TotemData:getActivateProgress( jTotem )
	--math.max(1,当前竞技场胜利次数/需要的胜利次数) * 0.3 + math.max(1,当前勋章/需要的勋章) * 0.4 + math.max(1,前置图腾星级/需要的星级) * 0.3
	local progress = 0
	if not TotemData.hasTotem(jTotem.id) then
		local conds = jTotem.activate_conds
		local cond
		local progressRate = {30,30,40,0,0}
		local conLen = #conds
		if conLen == 1 then
			progressRate[1] = 100
		elseif conLen == 2 then
			progressRate[1] = 50
			progressRate[2] = 50
		end

		for i = 1, conLen do
			cond = conds[i]
			if cond then
				local val = TotemData.getCondProgress(cond,progressRate[i])
				progress = progress + val
			end
		end
	end
	return math.ceil(progress)
end

function TotemData.getCondProgress(cond,rate)
	local val = 0
	if cond.cate == const.kCoinTotem then
		local sTotem = TotemData.getTotemById(cond.objid)
		if sTotem then
			val = sTotem.level
		end
		val = math.min(1,val/cond.val) * rate
	elseif cond.cate == const.kCoinArenaWinCount then
		val = StoreData.getWinTime()
		val = math.min(1,val/cond.val) * rate
	else
		val = CoinData.getCoinByCate(cond.cate, cond.objid)
		val = math.min(1,val/cond.val) * rate
	end
	return val
end

function TotemData.checkCanActivate(jTotem, showTips,showError)
	if TotemData.hasTotem(jTotem.id) then
		return false
	end
	local conds = jTotem.activate_conds
	local cond
	local result = true
	for i = 1, #conds do
		cond = conds[i]
		if cond then
			local val = TotemData.getCondVal(cond)
			if val and val < cond.val then
				result = false
				break
			end
		end
	end
	if not result and showTips and cond then
		if cond.cate == const.kCoinMedal then
			CoinData.checkLackCoin(cond.cate,cond.val,cond.objid)
		end
		if showError then
			TipsMgr.showError(TotemData.getCondDesc(cond))
		end
	end
	return result
end

function TotemData.getCondVal(cond)
	local val = 0
	if cond.cate == const.kCoinTotem then
		local sTotem = TotemData.getTotemById(cond.objid)
		if sTotem then
			val = sTotem.level
		end
	elseif cond.cate == const.kCoinArenaWinCount then
		val = StoreData.getWinTime()
	else
		val = CoinData.getCoinByCate(cond.cate, cond.objid)
	end
	return val
end

function TotemData.getCondDesc(cond)
	if cond.cate == const.kCoinTotem then
		return string.format("需要%s升到%s星", findTotem(cond.objid).name, cond.val)
	elseif cond.cate == const.kCoinArenaWinCount then
		return string.format("需要竞技场挑战胜利%s次", cond.val)
	else
		return string.format("需要%s%s", cond.val, CoinData.getCoinName(cond.cate))
	end
end

--判断图腾能否充能
function TotemData.checkCanUpLevel(v, showTips)
	if TotemData.isAddEnergying(v) then
		local costList = TotemData.getAccelerateCost(v)
		return not CoinData.checkLackCoinList(costList, not showTips)
	end
	if showTips then
		TipsMgr.showError("图腾当前不能升星")
	end
end

function TotemData.checkCanBlessAttr(v, attr, showTips)
	local level = TotemData.getAttrValue(v, attr)
	if TotemData.getCanBless(v, level) then
		local costList = TotemData.getBlessCost(v, level)
		return not CoinData.checkLackCoinList(costList, not showTips)
	end
	if showTips then
		TipsMgr.showError("已经强化到满级")
	end
	return false
end

--轮流升级，获取本次升级的attr
function TotemData.getBlessAttr(v)
	local lv1 = TotemData.getAttrValue(v, const.kTotemSkillTypeWake)
	local lv2 = TotemData.getAttrValue(v, const.kTotemSkillTypeFormationAdd)
	local lv3 = TotemData.getAttrValue(v, const.kTotemSkillTypeSpeed)
	if lv3 < lv2 then
		return const.kTotemSkillTypeSpeed
	elseif lv2 < lv1 then
		return const.kTotemSkillTypeFormationAdd
	end
	return const.kTotemSkillTypeWake
end

function TotemData.checkCanBless(v)
	if not TotemData.lockBless then
		if TotemData.checkCanBlessAttr(v, const.kTotemSkillTypeSpeed) or
		TotemData.checkCanBlessAttr(v, const.kTotemSkillTypeWake) or
		TotemData.checkCanBlessAttr(v, const.kTotemSkillTypeFormationAdd) then
			return true
		end
	end
	return false
end

function TotemData.isCheckBlessRed()
	 return gameData.getSimpleDataByKey("team_level") <= 20
end

function TotemData.isTotemOpen(showTips)
	return OpenFuncData.checkIsOpen(OpenFuncData.TYPE_FUNC, 2, showTips) --是否开启
end

function TotemData.checkBottomRedPoint()
	if not TotemData.isTotemOpen() then
		return false
	end
	local list = TotemData.getData()
	for _,v in pairs(list) do
		if TotemData.checkCanUpLevel(v) then
			return true
		end
	end
	if TotemData.isCheckBlessRed() then
		for _,v in pairs(list) do
			if TotemData.checkCanBless(v) then
				return true
			end
		end
	end

	--可激活
	local list = TotemData.getTypeJson(0)
	for k,jTotem in pairs(list) do
		local sTotem = TotemData.getTotemById(jTotem.id)
		if not sTotem then
			if TotemData.checkCanActivate(jTotem, false) then
				return true
			end
		end
	end
	return false
end

--雕文数据
function TotemData.getGlyphList()
	local list = TotemData.getMap().glyph_list
	if not list then
		list = {}
		gameData.user.totem_map[const.kTotemPacketNormal].glyph_list = list
	end
	return list
end

--获取图腾头像路径
function TotemData.getAvatarUrl(jTotem)
	return jTotem and "image/icon/totem/"..jTotem.avatar..".png" or "cc_2x2_white_image"
end

--获取图腾头像路径
function TotemData.getAvatarUrlById(totem_id)
	return TotemData.getAvatarUrl(findTotem(totem_id))
end

local function glyphTouchBegin(touch, event)
	local dw = event:getCurrentTarget()
	if dw then
		local pos = touch:getLocation()
		TipsMgr.showTips(pos, TipsMgr.TYPE_RUNE, dw.jGlyph, dw.sGlyph)
	end
end

--雕文对象，设置滤镜需要传入node.icon
local GlyphNode = class("GlyphNode", function()
	return cc.Node:create()
end)

function GlyphNode:play()
	self.icon:play()
end

function GlyphNode:stop()
	self.icon:stop()
end

--构造雕文显示对象
function TotemData.getGlyphObject(glyph_id, winName, parent, x, y, sGlyph,hideTips)
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
--获取图腾品质url
function TotemData.getQualityUrl(level)
	return string.format("image/ui/NTotemUI/bg/bg_item_%d.png",level)
end

--获取图腾品质SpriteFrameName
function TotemData.getQualityFrameName(level)
	return string.format("qu_totem_%d.png", level - 1)
end

--获取大的图腾品质SpriteFrameName
function TotemData.getBigQuFrame(level)
	return string.format("totem_qu_%d.png", level)
end

function TotemData.getTotem(guid) --@return STotem
	local list = TotemData.getData()
	return gameData.findArrayData(list, "guid", guid)
end

function TotemData.getTotemById(totem_id)
	local list = TotemData.getData()
	return gameData.findArrayData(list, "id", totem_id)
end

function TotemData.getGlyph(guid) --@return STotemGlyph
	local list = TotemData.getGlyphList()
	return gameData.findArrayData(list, "guid", guid)
end

--获取强化加成
function TotemData.getBlessAdd( totem_id,level,type )
	local totemAttr_old = findTotemAttr(totem_id, level - 1 )
	local totemAttr = findTotemAttr(totem_id, level)
	local jOdd_old = nil
	local jOdd = nil
	local old_value = 0
	if totemAttr then
		if type == const.kTotemSkillTypeFormationAdd then
				return totemAttr.formation_attr_up_desc
		elseif type == const.kTotemSkillTypeSpeed then
			if totemAttr_old then
				jOdd_old = findOdd(totemAttr_old.speed.first, totemAttr_old.speed.second)
				if jOdd_old then
					old_value = jOdd_old.effect.objid
				end
			end
			jOdd = findOdd(totemAttr.speed.first, totemAttr.speed.second)
			if jOdd then
				local dValue = jOdd.effect.objid - old_value
				return string.format("英雄速度+%s",tostring(dValue)),dValue
			end
		elseif type == const.kTotemSkillTypeWake then
			if totemAttr_old then
				jOdd_old = findOdd(totemAttr_old.wake.first, totemAttr_old.wake.second)
				if jOdd_old then
					old_value = jOdd_old.status.objid
				end
			end
			jOdd = findOdd(totemAttr.wake.first, totemAttr.wake.second)
			if jOdd then
				local dValue = jOdd.status.objid - old_value
				local typeName = TotemData.getTargetRangeName(jOdd)
				local status = dValue/100 .. "%"
				return string.format("%s觉醒率+%s ",typeName,status),status
			end
		end
	end
end

function TotemData.getTargetRangeName( jOdd )
	local arr = {"布甲","皮甲","锁甲","板甲"}
	if jOdd.target_range_count <= #arr then
		return arr[jOdd.target_range_count]
	end
end

function TotemData.getTotemSkill(sTotem) --@return JSkill
	local skillAttr = findTotemAttr(sTotem.id, sTotem.level)
	if skillAttr then
		return findSkill(skillAttr.skill.first, skillAttr.skill.second)
	end
end

--初始技能
function TotemData.getTotemInitSkill(jTotem) --@return JSkill
	local skillAttr = findTotemAttr(jTotem.id, jTotem.init_lv)
	if skillAttr then
		return findSkill(skillAttr.skill.first, skillAttr.skill.second)
	end
end

function TotemData.getTotemOdd(sTotem) --@return JOdd
	local formationAttr = findTotemAttr(sTotem.id, sTotem.formation_add_lv)	
	if formationAttr then
		return findOdd(formationAttr.formation_add_attr.first, formationAttr.formation_add_attr.second)
	end
end
--初始被动
function TotemData.getTotemInitOdd(jTotem) --@return JOdd
	local formationAttr = findTotemAttr(jTotem.id, jTotem.init_attr_lv)	
	if formationAttr then
		return findOdd(formationAttr.formation_add_attr.first, formationAttr.formation_add_attr.second)
	end
end

local function glyphSortFun(a, b)
	return a.index and b.index and a.index < b.index
end

local function findMinFreeIndex(list)
	local indexes = {1, 2, 3, 4}
	for i = 1, #list do
		if list[i].index ~= nil then
			table.remove(indexes, gameData.indexOfArray(indexes, list[i].index))
		end
	end
	return indexes[1] or 1
end

local function setGlyphIndex(list)
	for i = 1, #list do --设置位置
		if list[i].index == nil then
			list[i].index = findMinFreeIndex(list)
		end
	end
	table.sort(list, glyphSortFun)
end

--获取雕文列表
--@param totem_guid 图腾guid，为0则表示未镶嵌雕文
--@param type 当guid为0的时候有效，筛选某个类型的
function TotemData.getTotemGlyphList(totem_guid, type) --@return 
	type = totem_guid ~= 0 and 0 or type or 0
	local list = TotemData.getGlyphList()
	local result = {}
	for i = 1, #list do
		if list[i].totem_guid == totem_guid then
			if type ~= 0 then
				local jGlyph = findTempleGlyph(list[i].id)
				if jGlyph.type == type then
					table.insert(result, list[i])
				end
			else
				table.insert(result, list[i])
			end
		end
	end
	setGlyphIndex(result)
	return result
end

--根据type排序
function TotemData.sortGlyphByType(list, type)
	local function comp(a, b)
		local jGlyph1 = findTempleGlyph(a.id)
		local jGlyph2 = findTempleGlyph(b.id)
		if jGlyph1.type == jGlyph2.type then
			return a.guid < b.guid
		end
		if jGlyph1.type == type and jGlyph2.type ~= type then
			return true
		elseif jGlyph1.type ~= type and jGlyph2.type == type then
			return false
		else
			return jGlyph1.type < jGlyph2.type
		end
	end
	table.sort(list, comp)
end

--图腾战力
function TotemData.getFightValue(sTotem)
	-- 200+15*(3+图腾星级)*(图腾速度培养等级+图腾觉醒培养等级+图腾阵法培养等级+1)
	return 200 + 15 * (3 + sTotem.level) * (sTotem.speed_lv + sTotem.wake_lv + sTotem.formation_add_lv + 1)
end

--觉醒的英雄类别名称
function TotemData.getWakeName(type)
	return TotemData.TYPE_DATA[type][2]
end

--系别名称
function TotemData.getTypeName(type)
	return TotemData.TYPE_DATA[type][1]
end

--系别颜色
function TotemData.getTypeColor(type)
	return TotemData.TYPE_DATA[type][3]
end

function TotemData.getColor(quality)
	return TotemData.COLOR[quality]
end

--系别描述
function TotemData.getTypeDesc(type, jWakeAttr)
	local result = TotemData.getTypeName(type)
	local wakeDesc = TotemData.getWakeDesc(type, jWakeAttr)
	if wakeDesc ~= "" then
		result = result .. "——" .. wakeDesc
	end
	return result
end

--技能描述
function TotemData.getSkillDesc(jSkill)
	return jSkill and jSkill.desc or ""
end

--速度描述
function TotemData.getSpeedDesc(jSpeedOdd)
	local speed = jSpeedOdd and jSpeedOdd.effect.objid or 0
	return string.format("增加同列英雄%d速度", speed)
end

--阵法加成描述
function TotemData.getFormationDesc(jFormationOdd)
	return jFormationOdd and jFormationOdd.description or ""
end

--觉醒描述
function TotemData.getWakeDesc(type, jWakeAttr, isWakeDouble)
	local data = TotemData.TYPE_DATA[type]
	if jWakeAttr and jWakeAttr.wake.first ~= 1122 and jWakeAttr.wake.first ~= 1151 then --祖传的风怒图腾特殊处理
		local jWakeOdd = findOdd(jWakeAttr.wake.first, jWakeAttr.wake.second)
		if jWakeOdd then
			local percent = jWakeOdd.status.objid / 100
			if isWakeDouble then
				percent = percent + percent
			end
			return string.format("图腾发动时有%s%%几率觉醒%s英雄", percent, data[2])
		end
	end
	return ""	
end

function TotemData.getGlyphBaseDescList(sGlyph, list)
	list = list or {}
	local temp = nil
	for i,v in ipairs(sGlyph.attr_list) do
		if v.first then
			if not temp then
				temp = clone(v)
			elseif temp.first == v.first then
				temp.second = temp.second + v.second
			else
				table.insert(list, TotemData.getGlyphAttrDesc(temp, false))
				temp = clone(v)
			end
		end
	end
	if temp then
		table.insert(list, TotemData.getGlyphAttrDesc(temp, false))
	end
	return list
end

function TotemData.getGlyphHidenDescList(sGlyph, list)
	list = list or {}
	local temp = nil
	for i,v in ipairs(sGlyph.hide_attr_list) do
		if v.first then
			if not temp then
				temp = clone(v)
			elseif temp.first == v.first then
				temp.second = temp.second + v.second
			else
				table.insert(list, TotemData.getGlyphAttrDesc(v, true))
				temp = clone(v)
			end
		end
	end
	if temp then
		table.insert(list, TotemData.getGlyphAttrDesc(temp, true))
	end
	return list
end

--雕文单条属性描述
function TotemData.getGlyphAttrDesc(s2uint, isHide)
	local valueString = ""
	if isHide then
		local jOdd = findOdd(s2uint.first, s2uint.second)
        if jOdd and jOdd.description then
        	valueString = jOdd.description
       	else
        	valueString = "该隐藏属性没有描述。odd id "..s2uint.first.." level "..s2uint.second
        end
	else
		local jEffect = findEffect(s2uint.first)
		if jEffect then
    		valueString = jEffect.desc.."+"
    		if jEffect.PercenValue == 1 then
    			valueString = valueString..(s2uint.second/100).."%"
    		else
    			valueString = valueString..s2uint.second
    		end
    	end
	end
	return valueString
end

--根据属性类型获取属性的值
function TotemData.getAttrValue(data, attr)
	if attr == const.kTotemSkillTypeSpeed then
		return data.speed_lv
	elseif attr == const.kTotemSkillTypeFormationAdd then
		return data.formation_add_lv
	elseif attr == const.kTotemSkillTypeWake then
		return data.wake_lv
	end
end

-- 获取上阵图腾列表
function TotemData.getUpTotemList(type)
	local result = {}
	local formationList = FormationData.getAttrList(type, const.kAttrTotem)
	local list = TotemData.getData()
	for _,v in ipairs(formationList) do
		local data = TotemData.getTotem(v.guid)
		if (data) then
			table.insert(result, data)
		end
	end
	return result
end

function TotemData.getCanBless(data, level)
	if level >= data.level * TotemData.levelPerStar then
		return false
	end
	local totemAttr = findTotemAttr(data.id, level + 1)
	return totemAttr ~= nil
end

function TotemData.getBlessCost(data, level)
	local totemAttr = findTotemAttr(data.id, level)
	if totemAttr then
		return totemAttr.train_cost
	end
	return nil
end

--显示的进度百分比
function TotemData.getAttrPercent(level, attrLevel)
	return (attrLevel - (level - 1) * TotemData.levelPerStar) * 20
end

function TotemData.getAttrPercent1(data, attr)
	local level = TotemData.getAttrValue(data, attr)
	return (level - (data.level - 1) * TotemData.levelPerStar) * 20
end

--是否正在充能
function TotemData.isAddEnergying(data)
	return TotemData.checkCanAddEnergy(data)
end

--充能百分比
function TotemData.getCharingPercent(data)
	local totemAttr = findTotemAttr(data.id, data.level * TotemData.levelPerStar)
	return 100 * data.accelerate_count / totemAttr.acc_count or 0
end

--剩余次数
function TotemData.getLeftEnergyTime(data)
    return math.max(0, TotemData.getAccelerateTime(data) - data.accelerate_count)
end

--需要充能的次数
function TotemData.getAccelerateTime(data)
	local totemAttr = findTotemAttr(data.id, data.level * TotemData.levelPerStar)
	return totemAttr.acc_count
end

--充能消耗
function TotemData.getAccelerateCost(data)
	local totemAttr = findTotemAttr(data.id, data.level * TotemData.levelPerStar) --5的倍数
	if totemAttr then
		return totemAttr.accelerate_cost
	end
	return nil
end

--剩余冷却时间
function TotemData.getLeftCooldown(data)
	local jTotem = findTotem(data.id)
	local freeTime = VarData.getVar("totem_free_acc_time_"..jTotem.type)
	return math.max(0, freeTime - gameData.getServerTime())
end

function TotemData.checkCanAddEnergy(data)
	local totem = findTotem(data.id)
	if totem.max_lv <= data.level then
		return false
	end
	-- if data.energy_time ~= 0 then
	-- 	return false
	-- end
	local level = TotemData.getAttrValue(data, const.kTotemSkillTypeSpeed)
	if level < data.level * TotemData.levelPerStar then
		return false
	end
	level = TotemData.getAttrValue(data, const.kTotemSkillTypeWake)
	if level < data.level * TotemData.levelPerStar then
		return false
	end
	level = TotemData.getAttrValue(data, const.kTotemSkillTypeFormationAdd)
	if level < data.level * TotemData.levelPerStar then
		return false
	end
	return true
end

local function mergeAttrToGlyph(glyph1, glyph2)
	local glyph = clone(glyph1)
	glyph.hide_attr_list = {}
	for i = 1, #glyph2.attr_list do
		table.insert(glyph.attr_list, glyph2.attr_list[i])
	end
	return glyph
end

--可能合成的雕文
function TotemData.getMayGlyphList(glyph1, glyph2)
	local list = {}
	table.insert(list, glyph1)
	table.insert(list, mergeAttrToGlyph(glyph1, glyph2))
	table.insert(list, glyph2)
	table.insert(list, mergeAttrToGlyph(glyph2, glyph1))
	return list
end

function TotemData.getCanMerge(id1, id2, silent)
	local jGlyph1 = findTempleGlyph(id1)
	local jGlyph2 = findTempleGlyph(id2)
	if jGlyph1.quality ~= jGlyph2.quality then
		if not silent then
			TipsMgr.showError("只能合成同样品质的雕文")
		end
		return false
	end
	return true
end

function TotemData.getCanSlot(sTotem, sGlyph, silent)
	if not sGlyph or 0 ~= sGlyph.totem_guid then
		return false
	end
	local jTotem = findTotem(sTotem.id)
	local jGlyph = findTempleGlyph(sGlyph.id)
	if jTotem.type ~= jGlyph.type then
		if not silent then
			TipsMgr.showError("只能镶嵌同系别的雕文")
		end
		return false
	end
	return true
end

function TotemData.showTotemGet( id, callBack )
	PopMgr.checkPriorityPop(
		"TotemGetUI", 
		PopOrType.GetToTem,
		function()
			TotemData.TotemGetId = id
		    TotemData.toTemGetCallBack = callBack			
 			Command.run( 'ui show', 'TotemGetUI',nil,true)
 		end
 	)
end

function TotemData.totemStarUpUIBack( ... )
	local win = PopMgr.getWindow('TotemUI')
	if win then
		win.top:setVisible(true)
	end
end

function TotemData.showTotemStarUpUI( id )
	local win = PopMgr.getWindow('TotemUI')
	if win then
		win.top:setVisible(false)		
		Command.run( 'ui show', 'TotemStarUpUI', PopUpType.SPECIAL)
		local winTotemStarUp = PopMgr.getWindow('TotemStarUpUI')
		if winTotemStarUp then
			winTotemStarUp:setData(id,TotemData.totemStarUpUIBack)
		end
	end
end


function TotemData.runToTemGetCallBack()
	if TotemData.toTemGetCallBack ~= nil then
		TotemData.toTemGetCallBack()
		TotemData.toTemGetCallBack = nil
	end
end

function TotemData.glyphArrForList( list,titleStr,quality )
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
            if jEffect.PercenValue == 0 then
            	valStr = valStr .. v.second
            else
            	valStr = valStr .. (v.second/100) .. '%'
            end

            local arrT = fontNameString("TIP_T2") .. titleStr ..k..':'
    		local arr = fontNameString("TIP_C") .. jEffect.desc
    		str = str .. arrT .. arr .. valStr
            index = index + 1
        end
    end
    
    --未合成属性(合成)
    if quality then
	    local maxLen = QualityData.getMaxArr(quality)
	    for i=index,maxLen do
	        str = str .. "[br]"
	        local arrT = fontNameString("TIP_T2") .. '属性X:'
	        local arr = fontNameString("TIP_C") .. '可合成'
	        str = str .. arrT .. arr
	    end
    end
    return str
end

--雕文基础加成（描述）
function TotemData.getJGlyphArr( jGlyph )
    local str = ''
    local jEffect = nil
    if jGlyph then
    	str = TotemData.glyphArrForList(jGlyph.attrs,"属性")
    end
    return str
end

--雕文随机加成 + 隐藏属性（描述）
function TotemData.getSGlyphArr( sGlyph,quality )
    local str = ''
    local jEffect = nil
    if sGlyph then
    	if TotemData.isMergedGlyph(sGlyph) then 
    		str = TotemData.glyphArrForList(sGlyph.attr_list,"随机属性",quality)
    	else
    		str = TotemData.glyphArrForList(sGlyph.attr_list,"随机属性")
    	end
        --隐藏属性
        for k,v in pairs(sGlyph.hide_attr_list) do
            if v.first ~= 0 then
                local jOdd = findOdd(v.first, v.second)
                local valueString = ""
                if jOdd then
	                str = str .. "[br]"
					
			        if jOdd and jOdd.description then
			        	valueString = jOdd.description
			       	else
			        	valueString = "该隐藏属性没有描述。odd id "..s2uint.first.." level "..s2uint.second
			        end

	                local arrT = fontNameString("TIP_T2") .. '隐藏属性'..k..':'
	        		local arr = fontNameString("TIP_C") .. valueString
	        		str = str .. arrT .. arr
	        	end
            end
        end
    end
    return str
end

Command.bind("totem show glyph merge", function()
	if OpenFuncData.checkIsOpenFunc(TotemData.GLYPH_OPEN_ID, true) then
		TotemData.currentTabIndex = 3
		Command.run("ui show", "TotemUI")
	end
end)