local __this ={}
SoldierData = __this
SoldierData.equipExt_map = {}

__this.effLvData = {}
__this.effStepData = {}
__this.effStarData = {}
__this.effRecruitData = {}
__this.stepItemTobj = nil
__this.lvUpNeed = nil

function SoldierData.SFightExtAble()
    local able = {}
    able.hp  = 0
    able.physical_ack  = 0
    able.physical_def  = 0
    able.magic_ack  = 0
    able.magic_def  = 0
    able.speed  = 0
    able.critper  = 0
    able.crithurt  = 0
    able.critper_def  = 0
    able.crithurt_def  = 0
    able.recover_critper  = 0
    able.recover_critper_def  = 0
    return able
end

--virtual(客户端自己英雄计算二级属性)
function SoldierData.getFightValueVir( psoldierlv, psoldierstar,psoldier_quality,psoldierbase,able )
    able = able or __this.SFightExtAble() 
     --等级基础属性*星级成长*英雄属性偏向 6项基本属性
     --等级基础属性 + 英雄属性偏向 百分比属性
    able.hp  = math.floor((psoldierlv.hp * (psoldierstar.grow/10000.0)+  psoldier_quality.hp) * psoldierbase.hp/10000.0)
    able.physical_ack  = math.floor((psoldierlv.physical_ack * (psoldierstar.grow/10000.0) + psoldier_quality.physical_ack) * psoldierbase.physical_ack/10000.0)
    able.physical_def  = math.floor((psoldierlv.physical_def * (psoldierstar.grow/10000.0) + psoldier_quality.physical_def) * psoldierbase.physical_def/10000.0)
    able.magic_ack  = math.floor((psoldierlv.magic_ack * (psoldierstar.grow/10000.0) + psoldier_quality.magic_ack) * psoldierbase.magic_ack/10000.0)
    able.magic_def  = math.floor((psoldierlv.magic_def * (psoldierstar.grow/10000.0) + psoldier_quality.magic_def) * psoldierbase.magic_def/10000.0)
    able.speed  = math.floor((psoldierlv.speed * (psoldierstar.grow/10000.0)  + psoldier_quality.speed) * psoldierbase.speed/10000.0)
    able.critper  = math.floor(psoldierlv.critper * (psoldierbase.critper/10000.0))
    able.hitper  = math.floor(psoldierlv.hitper + (psoldierlv.hitper-10000)*((psoldierbase.hitper-10000)/10000.0))
    able.crithurt  = math.floor(psoldierlv.crithurt * (psoldierbase.crithurt/10000.0))
    able.critper_def  = math.floor(psoldierlv.critper_def * (psoldierbase.critper_def/10000.0))
    able.crithurt_def  = math.floor(psoldierlv.crithurt_def * (psoldierbase.crithurt_def/10000.0))
    able.recover_critper  = math.floor(psoldierlv.recover_critper * (psoldierbase.recover_critper/10000.0))
    able.recover_critper_def  = math.floor(psoldierlv.recover_critper_def * (psoldierbase.recover_critper_def/10000.0))
    return able
end

function SoldierData.dispose( ... )
    __this.effLvData = {}
    __this.effStepData = {}
    __this.effStarData = {}
    __this.effRecruitData = {}
end

--客户端模拟弹出进阶成功UI
function SoldierData.virShowStepSuccessUI( sSoldier )
    SoldierDefine.stepUpSoldier = sSoldier
    SoldierDefine.stepUp = true
    Command.run("ui show", "SoldierStepSuccess", PopUpType.SPECIAL)
    local win = PopMgr.getWindow('SoldierStepSuccess')
    if win ~= nil then
        win:setData( SoldierDefine.stepUpSoldier,nil )
    end 
    EventMgr.dispatch(EventType.UserSoldierUpdate)
end

--服务器返回弹出进阶成功UI
function SoldierData.showStepSuccessUI( sSoldier )
    if SoldierDefine.qStepQualify > 1 then
        SoldierDefine.stepUpSoldier = sSoldier
        SoldierDefine.stepUp = true
        --动画完成再弹UI
    end
end


function SoldierData.getTable(type)
    type = type or const.kSoldierTypeCommon
    local table = gameData.user.soldier_map[type]
    if (table == nil) then
        table = {}
        gameData.user.soldier_map[type] = table
    end
    return table
end

function SoldierData.getSoldierByQuality( quality )
    local count = 0
    local list = SoldierData.getTable()
    if list then
        for k,v in pairs(list) do
            if v.quality >= quality then
                count = count +1
            end
        end
    end
    return count
end

function SoldierData.getEquipExtByGuid( guid )
    for k,v in pairs(SoldierData.equipExt_map) do
        if k == guid then
            return v
        end
    end
    return nil
end

--主界面【英雄红点】
function __this.checkSoldierRedPoint()
    local isRedShow = false
    local enLevelUp,enStarUp = __this.starAndLevelUpMap()
    if  SoldierData.hasRecruit() or not table.empty(enLevelUp) 
            or not table.empty(enStarUp) or __this.hasStepUp() 
            or SoldierData.hasBookDress() then
        isRedShow = true
    else
        isRedShow = false
    end

    return isRedShow
end

function SoldierData.getCount(type)
    local list = SoldierData.getTable(type)
    return table.nums(list)
end

--获得英雄
function SoldierData.soldierGetUI( callBack,soldier_id ,replaceReward )
    Command.run("ui show", "SoldierGetUI", PopUpType.SPECIAL)
    local win = PopMgr.getWindow('SoldierGetUI')
    if win ~= nil then
        win:setCloseCB(callBack,soldier_id ,replaceReward )
    end  
end

--获取英雄职业路径(图标)
function SoldierData.getOccUrl(jSoldier)
    return "image/icon/occupation/"..jSoldier.occupation..".png"
end

--获取英雄职业路径(名称)
function SoldierData.getOccNameUrl(jSoldier)
    return "image/icon/occname/"..jSoldier.occupation..".png"
end

function SoldierData.getOccName( jSoldier )
    local nameData = {"圣骑士","死亡骑士","战士","猎人","萨满","德鲁伊","潜行者","武僧","法师","术士","牧师"}
    return nameData[jSoldier.occupation]
end

function SoldierData.getEquipTypeName( jSoldier )
    --1:布甲，2:皮甲，3:锁甲，4:板甲
    local nameData = {"布甲","皮甲","锁甲","板甲"}
    return nameData[jSoldier.equip_type]
end

--获取英雄头像路径
function SoldierData.getAvatarUrl(jSoldier)
    return "image/icon/avatar/"..jSoldier.avatar..".png"
end

function SoldierData.getBodyUrl(jSoldier)
    return string.format("image/body/%s.png", jSoldier.avatar)
end

--获取品质与+?
--@return quality, "+num"
function SoldierData.getQualityAndNum(quality)
    local jSoldierQuality = findSoldierQuality(quality)
    if jSoldierQuality then
        local num = jSoldierQuality.quality_effect.second
        return jSoldierQuality.quality_effect.first, num ~= 0 and "+"..num or ""
    end
    return 1, "" --默认白色
end

--获取英雄品质SpriteFrameName
function SoldierData.getQualityFrameName(quality)
    quality = math.max(quality - 1, 0)
    return string.format("qu_soldier_%d.png", quality)
end

function SoldierData.getSoldier(guid, type) --@return SUserSoldier
    type = type or const.kSoldierTypeCommon
	local table = SoldierData.getTable(type)
	return table[guid]
end

---获取二级属性
--user.fightextable_map  attr=>{guid=>SFightExtAbleInfo}
--@param guid 标识ID
--@param attr 类型 kAttrSoldier英雄，kAttrTotem图腾...等
--@return SFightExtAbleInfo
function SoldierData.getFightextAble(guid, attr) --@return SFightExtAbleInfo
    local map = gameData.user.fightextable_map
    if map then
        local sub = map[attr]
        if sub then
            for __, s in pairs(sub) do
                if guid == s.guid then
                    return s
                end
            end
        end
    end
end

--根据二级属性计算战斗力
function SoldierData.getFightValue(guid, attr)
    local fightAble = SoldierData.getFightextAble(guid, attr)
    if fightAble then
        return SoldierData.getAbleFightValue(fightAble.able)
    end
    return 0
end

--根据二级属性计算战斗力(未招募英雄)
function SoldierData.getNotRecruitFightValue(jSoldier,able)
    --SoldierData.getFightValueVir( psoldierlv, psoldierstar,psoldier_quality,psoldierbase,able )
    local psoldierlv = findSoldierLv(1)
    local psoldierstar = findSoldierStar(jSoldier.star)
    local psoldier_quality = findSoldierQuality(jSoldier.quality)
    local psoldierbase = findSoldierBase(jSoldier.id)
    if not psoldierlv or not psoldierstar or not psoldier_quality or not psoldierbase then
        return 0 
    end

    local fightAble = __this.getFightValueVir( psoldierlv, psoldierstar,psoldier_quality,psoldierbase,able )
    if fightAble then
        return SoldierData.getAbleFightValue(fightAble)
    end
    return 0
end

--战斗力计算公式
function SoldierData.getAbleFightValue(able)
    return math.floor(math.max(able.physical_ack, able.magic_ack) * 5 + (able.physical_def + able.magic_def) * 2.5 + able.hp * 0.4)
end

function SoldierData.getSoldierBySId( _soldierId, type) --@return SUserSoldier
    type = type or const.kSoldierTypeCommon
    if _soldierId == 0 then
        return nil
    end

    local table1 = SoldierData.getTable(type)
    if table1 == nil then
        return nil
    end
    for k,v in pairs(table1) do
    	if v.soldier_id == _soldierId then
    		return v
    	end
    end
    return nil
end

function SoldierData.notHaveSoldier( soldierId , type )
    return SoldierData.getSoldierBySId( soldierId, type ) == nil
end

function SoldierData.getItemMerge(itemId) 
	if item == nil then
		return nil
	end
	
	local itemMergeList = getDataList("ItemMerge")
	for k,v in pairs(itemMergeList) do
		if v.dst_item.objid == itemId then
			return v
		end
	end

	return nil
end

--获取技能等级
function SoldierData.getLevel(skill_list,id)
	for i=1,table.getn(skill_list) do
        if skill_list[i].id == id then
			return skill_list[i].level
		end
	end

	return 1
end

--获取英雄二级属性
function SoldierData.getSoldierFightExtAble( soldierGuid )
    if gameData.user.fightextable_map == nil then
        return nil
    end
    
    local list = gameData.user.fightextable_map[const.kAttrSoldier]
    if list == nil then
        return nil
    end
    for k,v in pairs(list) do
        if v.guid == soldierGuid then
            return v
        end
    end
    
    return nil
end

function SoldierData.getArrLabel(  )
    local str ="生　　命|攻击强度|护　　甲|暴击等级|暴击伤害|偏　　斜|命　　中|速　　度|魔法强度|魔法抗性|暴击抵抗|韧　　性|精　　准|躲　　闪"
    return string.split(str,"|")
end

function SoldierData.getSortedSoldierList()
    local allList = SoldierData.getTable()
    local list = {}
    if allList == nil then
        return list
    end
    for k,v in pairs(allList) do
        table.insert(list,v)
    end
    table.sort( list, SoldierData.soldierSortFun )
    return list
end

function SoldierData.SoldiersByEquipType( type )
    type = type or 0
    local allList = SoldierData.getTable()
    local list = {}
    if allList == nil then
        return list
    end
    
    local serverData = nil
    local soldier = nil
    local obj ={}
    
    for key, serverData in pairs(allList) do
        soldier = findSoldier(serverData.soldier_id)
        if soldier then
            if type == 0 or soldier.equip_type == type then 
                table.insert(list,serverData)
            end
        end
    end
    table.sort( list, SoldierData.soldierSortFun )
    return list
end

function SoldierData.hasEatStepItem(type)
    type = type or 0
    local list = SoldierData.SoldiersByEquipType(type)
    for k,v in pairs(list) do
        if SoldierData.enEatStepItem(v) then
            return true
        end
    end
    return false
end

--是否可吃材料(对应该某个英雄)
function SoldierData.enEatStepItem(sData)
    if sData.quality == 1 or SoldierData.enStepXp(sData)then
        return false
    end

    if not __this.hasStepItemInPack() 
        and not __this.hasStepItemInCopy() then
        return false
    end

    local min = SoldierData.getMinEatItemQlv()
    if min ~= 0 and sData.quality <= min then
        return true
    end

    return false
end

function SoldierData.getMinEatItemQlv( )
    local list = SoldierData.getTable()
    local min = 0
    for k,v in pairs(list) do
        if not SoldierData.enStepXp(v) then
            if min == 0 or v.quality < min then
                min = v.quality
            end
        end
    end
    return min
end

--可吃材料
function SoldierData.hasStepItemInPack( ) 
    for i=1,4 do
        local qualityXpInfo = findSoldierQualityXp(i)
        if qualityXpInfo then
            local item = findItem( qualityXpInfo.coin.objid)
            if item then
                local packNum = ItemData.getItemCount(item.id,const.kBagFuncCommon)
                if packNum > 0 then
                    return true
                end
            end
        end
    end
    return false
end

--可吃材料
function SoldierData.hasStepItemInCopy( )
    for i=1,4 do
        local qualityXpInfo = findSoldierQualityXp(i)
        if qualityXpInfo then
            local item = findItem( qualityXpInfo.coin.objid)
            if item then
                local packNum = ItemData.getItemCount(item.id,const.kBagFuncCommon)
                local copyNum = CopyRewardData.getEatItemNum(item.id)
                if packNum + copyNum > 0 then
                    return true
                end
            end
        end
    end
    return false
end


function SoldierData.hasStepUp( type )
    type = type or 0
    local list = SoldierData.SoldiersByEquipType(type)
    for k,v in pairs(list) do
        if SoldierData.enStepUp(v) then
            return true
        end
    end
end

function SoldierData.hasBookDress( type )
    type = type or 0
    local list = SoldierData.SoldiersByEquipType(type)
    for k,v in pairs(list) do
        if SoldierData.enBookDress(v) then
            return true
        end
    end
end

function SoldierData.enBookDress( sData ) 
    if sData then
        local jSoldier = findSoldier(sData.soldier_id)
        if jSoldier then
            local jSoldierQualityOccu = findSoldierQualityOccu(sData.quality,jSoldier.occupation)
            if jSoldierQualityOccu then
                if sData.level < jSoldierQualityOccu.limit_lv then
                    return false
                end
                local itemId = jSoldierQualityOccu.cost.objid
                local jItem = findItem(itemId)
                if jItem then
                    local quality = ItemData.getQuality( jItem, nil )
                    quality = quality - 1
                    --是否已经装备
                    local userItem = ItemData.getSoldierSkillBook(sData.guid) 
                    if not userItem then
                        local packNum = ItemData.getItemCount(itemId,const.kBagFuncCommon)
                        if packNum > 0 then
                                return true
                        else
                            if ItemData.bookMergeRecursionCheck(itemId) then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

--获取英雄需要的技能书
function SoldierData.getSoldierBook( sSoldier )
    if sSoldier then
        local jSoldier = findSoldier(sSoldier.soldier_id)
        if jSoldier then
            local jSoldierQualityOccu = findSoldierQualityOccu(sSoldier.quality,jSoldier.occupation)
            if jSoldierQualityOccu then
                return jSoldierQualityOccu.cost
            end
        end
    end
end

--检测技能书是否为当前英雄所需要的
function SoldierData.checkSoldiersBooks(item_id)
    local bookList = {}
    local list = SoldierData.getTable()
    for k,v in pairs(list) do
        --该英雄已经有书
        local userItem = ItemData.getSoldierSkillBook(v.guid) 
        if not userItem then
            local costItem = SoldierData.getSoldierBook(v)
            if costItem and costItem.objid == item_id then
                return true
            end
        end
    end
    return false
end

function SoldierData.enStepXp( sData )
    if not sData then
        return false
    end

    local xpEn = false
    local jSoldier = findSoldier(sData.soldier_id)
    if not jSoldier then
        return false
    end

    local jSoldierQuality = findSoldierQuality(sData.quality)
    if jSoldierQuality and jSoldierQuality.xp then 
        local needMaxXp = jSoldierQuality.xp
        if sData.quality_xp >= needMaxXp then
            xpEn = true
        end 
    end

    return xpEn
end

function SoldierData.enStepUp( sData )
    if sData then
        if SoldierData.enStepXp(sData) then
            local jSoldier = findSoldier(sData.soldier_id)
            if jSoldier then
                local jSoldierQualityOccu = findSoldierQualityOccu(sData.quality,jSoldier.occupation)
                if jSoldierQualityOccu then
                    local itemId = jSoldierQualityOccu.cost.objid
                    local jItem = findItem(itemId)
                    if jItem then
                        --是否已经装备
                        local userItem = ItemData.getSoldierSkillBook(sData.guid) 
                        if userItem then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end
--可升星
function SoldierData.enableStarUp( starNum,soldierInfo )
    if starNum == 6 then
        return false
    end

    local starInfo = findSoldierStar(starNum)
    if not soldierInfo or not starInfo then
        return false
    end

    local starUpCost = {}
    starUpCost.first = soldierInfo.star_cost.objid
    starUpCost.second = starInfo.cost
    local need = starUpCost.second
    local packNum = ItemData.getItemCount(starUpCost.first,const.kBagFuncCommon)
    local needMoney = starInfo.need_money.val
    local money = CoinData.getCoinByCate(const.kCoinMoney)
    return packNum >= need and money >= needMoney
end

--*英雄是否要升级
function SoldierData.enLevelUp(level,lvInfo)
    local teamLevel = gameData.getSimpleDataByKey("team_level")
    if teamLevel < 3 or teamLevel > 20 then
        return false
    end

    local levelBaseInfo = findLevel(teamLevel)
    if not levelBaseInfo or not lvInfo then
        return false
    end

    local warter = CoinData.getCoinByCate(const.kCoinWater)
    if level < levelBaseInfo.soldier_lv and warter >= lvInfo.cost.val then
       return true
    end

    return false
end

--**是否有英雄升级**--------
function SoldierData.starAndLevelUpMap( )
    local enLevelUp = {}
    local enStarUp = {}
    local allList = SoldierData.getTable()
    if allList == nil then
        return enLevelUp,enStarUp
    end
    
    for k,v in pairs(allList) do
        local soldier = findSoldier(v.soldier_id)
        local lvInfo = findSoldierLv(v.level)
        if soldier and SoldierData.enLevelUp(v.level,lvInfo) then
            enLevelUp[soldier.equip_type] = 1
        end
        if SoldierData.enableStarUp(v.star,soldier) then
            enStarUp[soldier.equip_type] = 1
        end
    end

    return enLevelUp,enStarUp
end

--是否有武将可招募
function SoldierData.hasRecruit( type )
    local dataList = GetDataList("SoldierRecruit")
    for k,v in pairs(dataList) do
        local typeEn = true
        if type then
            local JSoldierInfo = findSoldier(v.soldier_id)
            if type ~= JSoldierInfo.equip_type then
                typeEn = false
            end
        end

        if typeEn and SoldierData.enRecruit(v) then
            return true
        end
    end
    return false
end

--是否可以招募
function SoldierData.enRecruit( jSoldierRecruit )
    if jSoldierRecruit then
        if not SoldierData.getSoldierBySId(jSoldierRecruit.soldier_id) then
            local packNum = ItemData.getItemCount(jSoldierRecruit.cost_[1].objid,const.kBagFuncCommon)
            if packNum >= jSoldierRecruit.cost_[1].val then
                return true
            end
        end
    end
    return false
end

--可招募字典(key为英雄类型)
function SoldierData.enRecruitMapByEquipType( )
    local enRecruitMap = {}
    local dataList = GetDataList("SoldierRecruit")
    for k,v in pairs(dataList) do
        local JSoldierInfo = findSoldier(v.soldier_id)
        if JSoldierInfo and SoldierData.enRecruit(v) then
            enRecruitMap[JSoldierInfo.equip_type] = true
        end
    end
    return enRecruitMap
end

--获取招募列表
function SoldierData.getRecruitList( type )
    type = type or 0
    local enRecruitList = {}  --可招募(灵魂石头满足)
    local list = {}
    local dataList = GetDataList("SoldierRecruit")
    for k,v in pairs(dataList) do
        local soldierInfo = findSoldier(v.soldier_id)
        if soldierInfo and SoldierData.getSoldierBySId(v.soldier_id) == nil then
            if type == 0 or soldierInfo.equip_type == type then
                local packNum = ItemData.getItemCount(v.cost_[1].objid,const.kBagFuncCommon)
                local obj = {}
                obj.num = packNum
                obj.star = soldierInfo.star
                obj.id = soldierInfo.id
                obj.jData = soldierInfo
                if packNum >= v.cost_[1].val then
                    table.insert(enRecruitList,obj)
                end
                table.insert(list,obj)
            end
        end
    end

    table.sort(list,SoldierData.soldierSortFun2)
    return enRecruitList,list 
end

--获取英雄招募信息
function SoldierData.getRecruitInfo( soldierId )
    local dataList = GetDataList("SoldierRecruit")
    for k,v in pairs(dataList) do
        if v.soldier_id == soldierId then
            return v
        end
    end
    return nil
end


function SoldierData.SoldierQualityOpenNeed( skill_active )
    local dataList = GetDataList("SoldierQuality")
    local qLv = 100
    local find = false
    for k,v in pairs(dataList) do
        if v.skill_active == skill_active then
            qLv = v.lv
            find = true
            break
        end
    end
    if not find then
        return "橙色"
    end

    local q,n = __this.getQualityAndNum(qLv)
    local color = QualityData.getColor(q)
    return QualityData.getName(q)..n,color
end

function SoldierData.getSoldierQualityColor( quality )
    local q,n = __this.getQualityAndNum(quality)
    local color = QualityData.getColor(q)
    return QualityData.getName(q)..n,color
end

function SoldierData.checkSoldierBookDressLv( guid )
   local sData = SoldierData.getSoldier(guid)
   if sData then
        local jSoldier = findSoldier(sData.soldier_id)
        if jSoldier then
            local jSoldierQualityOccu = findSoldierQualityOccu(sData.quality,jSoldier.occupation)
            if jSoldierQualityOccu then
                if sData.level >= jSoldierQualityOccu.limit_lv then
                    return jSoldierQualityOccu.limit_lv,true
                else
                    return jSoldierQualityOccu.limit_lv,false
                end
            end
        end
   end
   return 0,false
end

--soldier -- serverdata 排序
function SoldierData.soldierSortFun(a, b)
    if a == nil or b == nil then
        return true
    end

    if a.level > b.level then
        return true
    elseif a.level < b.level then
        return false
    end

    if a.star > b.star then
        return true
    elseif a.star < b.star then
        return false
    end

    return a.soldier_id > b.soldier_id
end

function SoldierData.soldierSortFun2( a,b )
    if a == nil or b == nil then
        return true
    end

    if a.num > b.num then
        return true
    elseif a.num < b.num then
        return false
    end

    if a.star > b.star then
        return true
    elseif a.star < b.star then
        return false
    end

    return a.id > b.id
end


-----------------------------数字跳动---------------------
function SoldierData.getArrChange(new,old)
    local change = {}
    change.numi = {}
    change.numf = {}
    local num = new - old
    local num_i = math.modf(num)  --整数部分
    local num_f = ( num - num_i ) --小数部分
    num_f = math.ceil(num_f*100)/100
    local numi_arr = __this.getNumChangeArr(num_i,false)
    change.numi = numi_arr

    if num_f > 0 then
        local num_f_len = string.len(tostring(num_f)) - 1
        local num_f_b = __this.getNum_B(num_f_len)
        local numf_arr = __this.getNumChangeArr(num_f * num_f_b,true)
        --还原小数点
        for i=1,num_f_len - 1 do
            numf_arr[i] = numf_arr[i]/num_f_b
        end
         change.numf = numf_arr
    end
    return change
end

function SoldierData.getNumChangeArr( num)
    local num_arr = {}
    local len = string.len(tostring(num))
    local left = num
    local step = 0
    local b = 0
    for i=len,1,-1 do
        if i == 1 then
            step = left
        else
            b = __this.getNum_B(i)
            step = __this.getNumBase(left, b)
            left = left - step
        end
        table.insert( num_arr, step )
    end
    return num_arr
end

--返回倍数 1,10,100,1000
function SoldierData.getNum_B( bit )
    local base = 10
    local result = 1
    for i=1,bit - 1  do
        result = result * base
    end
    return result
end
--返回基数 11 = 10, 111 = 100,222 = 200
function SoldierData.getNumBase( num,num_b)
    return math.floor(num/num_b) * num_b
end
-----------------------------数字跳动---------------------