local __this = CoinData or {}
CoinData = __this

local notify_coin_type = {}
--user.coin--
notify_coin_type[ const.kCoinMoney ] = { 'coin', 'money' }
notify_coin_type[ const.kCoinTicket ] = { 'coin', 'ticket' }
notify_coin_type[ const.kCoinGold ] = { 'coin', 'gold' }
notify_coin_type[ const.kCoinWater ] = { 'coin', 'water'}
notify_coin_type[ const.kCoinStar ] = { 'coin', 'star'}
notify_coin_type[ const.kCoinActiveScore ] = { 'coin', 'active_score'}
notify_coin_type[ const.kCoinMedal ] = {'coin','medal'}
notify_coin_type[ const.kCoinTomb ] = {'coin','tomb'}
notify_coin_type[ const.kCoinDayTaskVal ] = { 'coin', 'day_task_val' }
--user.simple--
notify_coin_type[ const.kCoinTeamLevel ] = { 'simple', 'team_level' }-- 战队等级
notify_coin_type[ const.kCoinTeamXp ] = { 'simple', 'team_xp' }-- 战队经验
notify_coin_type[ const.kCoinVipLevel ] = { 'simple', 'vip_level' }-- vip等级
notify_coin_type[ const.kCoinVipXp ] = { 'simple', 'vip_xp' }-- vip经验
notify_coin_type[ const.kCoinStrength ] = { 'simple', 'strength' }-- 体力点

--simple update notify
local simple_update_notify = {}
simple_update_notify[ const.kCoinTeamLevel ] = true
simple_update_notify[ const.kCoinTeamXp ] = true
simple_update_notify[ const.kCoinVipLevel ] = true
simple_update_notify[ const.kCoinVipXp ] = true
simple_update_notify[ const.kCoinStrength ] = true

local coinNameMap = {}
coinNameMap[const.kCoinTomb] = "勇气徽章"
coinNameMap[const.kCoinMoney] = "金币"
coinNameMap[const.kCoinTicket] = "礼金"
coinNameMap[const.kCoinGold] = "钻石"
coinNameMap[const.kCoinWater] = "圣水"
coinNameMap[const.kCoinStar] = "星星"
coinNameMap[const.kCoinActiveScore] = "手工活力"
coinNameMap[const.kCoinTotem] = "图腾"
coinNameMap[const.kCoinMedal] = "勋章"
coinNameMap[const.kCoinTeamLevel] = "战队等级"
coinNameMap[const.kCoinTeamXp] = "战队经验"
coinNameMap[const.kCoinVipLevel] = "VIP等级"
coinNameMap[const.kCoinVipXp] = "VIP经验"
coinNameMap[const.kCoinStrength] = "体力"
coinNameMap[const.kCoinDayTaskVal] = '日常任务积分'

local coinC3BMap = {}
coinC3BMap[const.kCoinMoney] = cc.c3b(255,240,0)
coinC3BMap[const.kCoinTicket] = nil
coinC3BMap[const.kCoinGold] = cc.c3b(255,240,0)
coinC3BMap[const.kCoinWater] = cc.c3b(255,240,0)
coinC3BMap[const.kCoinStar] = nil
coinC3BMap[const.kCoinActiveScore] = nil
coinC3BMap[const.kCoinTotem] = cc.c3b(255,240,0)

coinC3BMap[const.kCoinTeamLevel] = cc.c3b(255,240,0)
coinC3BMap[const.kCoinTeamXp] = cc.c3b(255,240,0)
coinC3BMap[const.kCoinVipLevel] = cc.c3b(255,240,0)
coinC3BMap[const.kCoinVipXp] = cc.c3b(255,240,0)
coinC3BMap[const.kCoinStrength] = cc.c3b(255,240,0)


--货币资源路径
function __this.getCoinUrl(cate, objid)
    if cate == const.kCoinItem or ( cate >= const.kCoinEquipWhite and cate <= const.kCoinEquipOrange )then
        return ItemData.getItemUrl(objid)
    end
    return "image/icon/coin/"..cate..".png"
end

function __this.getCoinName(cate, objid)
    cate = tonumber(cate)
    if cate == const.kCoinItem then
        local jItem = findItem(objid)
        return jItem and jItem.name
    elseif cate == const.kCoinGlyph then 
        local glph = findTempleGlyph(objid)
        return glph and glph.name
    elseif cate == const.kCoinSoldier then
        local soldier = findSoldier(objid) 
        return soldier and soldier.name
    elseif cate == const.kCoinTotem then
        local totem = findTotem(objid) 
        return totem and totem.name
    elseif cate >= const.kCoinEquipWhite and cate <= const.kCoinEquipOrange then
        local jItem = findItem(objid)
        return jItem and jItem.name
    end
    
    if coinNameMap[cate] then
        return coinNameMap[cate]
    end
    return '货币-' .. cate
end

function __this.getCoinC3B(cate, objid)
    local color
    if cate == const.kCoinItem then
        local jItem = findItem(objid)
        if jItem then
            color = ItemData.getItemColor(jItem.quality)
        end
    elseif cate == const.kCoinGlyph then
        local jGlyph = findTempleGlyph(objid)
        if jGlyph then
            color = QualityData.getColor(jGlyph.quality)
        end
    elseif cate >= const.kCoinEquipWhite and cate <= const.kCoinEquipOrange then
        color = ItemData.getItemColor(cate-const.kCoinEquipWhite+1) 
    else
        color = coinC3BMap[cate]
    end
    return color or cc.c3b(0xff, 0xff, 0xff)
end

function __this.getCoinQuality( cate, objid )
    local quality = 1
    if cate == const.kCoinItem then
        quality = ItemData.getQuality( findItem( objid) )
    elseif ( cate >= const.kCoinEquipWhite and cate <= const.kCoinEquipOrange )then
        quality = cate - const.kCoinEquipWhite + 1
    end
    return quality
end

function __this.NotifyCoin( msg )
    LogMgr.system(CoinData.getPathString(msg.path))
    for key, coin in ipairs( msg.coins ) do
        local cate = coin.cate
        local type_path = notify_coin_type[ cate ]

        local old_value = 0
        --整型数据增减通知
        if type_path ~= nil then
            local object = gameData.user

            --取得保存数据的对象
            for i = 1, #type_path - 1 do
                object = object[ type_path[i] ]
            end

            local local_key = type_path[ #type_path ]

            old_value = object[ local_key ]
            if old_value == nil then
                old_value = 0
            end

            local value = 0

            if msg.set_type == const.kObjectAdd then
                value = old_value + coin.val
            elseif msg.set_type == const.kObjectDel then
                value = old_value - coin.val
            else
                value = coin.val
            end

            object[ local_key ] = value
        end
        EventMgr.dispatch( EventType.UserCoinUpdate, { coin = coin, old_value = old_value , set_type = msg.set_type, path = msg.path} )
        if simple_update_notify[ cate ] then
            EventMgr.dispatch( EventType.UserSimpleUpdate )
        end

        if not CoinData.noEffectPathMap[msg.path] then
            if msg.set_type == const.kObjectAdd then
                --如果有武将
                if cate == const.kCoinSoldier then
                    SoldierData.soldierGetUI( nil,coin.objid )
                -- --如果有图腾
                -- elseif cate == const.kCoinTotem then
                --     TotemData.showTotemGet(coin.objid)
                end
            end
        end
    end

    if msg.set_type == const.kObjectAdd then --const.kObjectUpdate
        if CoinData.getUIPathMap[msg.path] then
            --弹领奖界面
            __this.openRewardGetUI(msg.coins)
        else
            if not CoinData.noEffectPathMap[msg.path] then
                --统一处理飞物品，飘文字
                TipsMgr.showGetEffect(msg.coins)
            end
        end
    end
end

function CoinData.openRewardGetUI( coins , canGet,cue, callBack )
    Command.run("ui show", "RewardGetUI", PopUpType.SPECIAL)
    local win = PopMgr.getWindow('RewardGetUI')
    if win ~= nil then
        win:setData( coins,canGet,cue, callBack )
    end
end

--神符显示
function CoinData:setGlyphItem( coin,winName,item,iconName,bgName,point,hideTip )
    local glyph_id = coin.objid
    local jGlyph = findTempleGlyph( glyph_id )
    if jGlyph then
        item[iconName]:setVisible(false)
        local p = cc.p(50,50)
        local dw = TotemData.getGlyphObject(jGlyph.id, winName, item[bgName], point.x, point.y,nil,hideTip)
        dw:setScale(1.5,1.5)
    end
end
--英雄
function CoinData:setSoldierItem( coin,item,iconName,bgName,point)
    local soldier_id = coin.objid
    --soldier_id = 10001
    local jSoldier = findSoldier( soldier_id )
    local url = ""
    if jSoldier then
        url = SoldierData.getQualityFrameName(1)
        item[bgName]:loadTexture( url, ccui.TextureResType.plistType  )
        url = SoldierData.getAvatarUrl(jSoldier)
        item[iconName]:loadTexture( url, ccui.TextureResType.localType )
        local off = TeamData.AVATAR_OFFSET
        item[iconName]:setPosition(point.x,point.y + off.y)
    end
end

--弹UI的获得途径
CoinData.getUIPathMap = {}
CoinData.getUIPathMap[const.kPathSign] = true
CoinData.getUIPathMap[const.kPathActivityReward] = true
CoinData.getUIPathMap[const.kPathTaskFinished] = true
CoinData.getUIPathMap[const.kPathOpenTargetTake] = true
CoinData.getUIPathMap[const.kPathOpenTargetBuy] = true

--不需要飞物品、获得UI的获得途径
CoinData.noEffectPathMap = {}
CoinData.noEffectPathMap[const.kPathCopySearch] = true
CoinData.noEffectPathMap[const.kPathBuildingGetOutput] = true
CoinData.noEffectPathMap[const.kPathAltar] = true
CoinData.noEffectPathMap[const.kPathCopyBossMopup] = true
-- CoinData.noEffectPathMap[const.kPathCopyAreaFullStarPass] = true
CoinData.noEffectPathMap[const.kPathTombRewardGet] = true   --- PRTombRewardGet返回处理
CoinData.noEffectPathMap[const.kPathMarketAutoBuy] = true
CoinData.noEffectPathMap[const.kPathTaskAutoFinished] = true
CoinData.noEffectPathMap[const.kPathMerge] = true
CoinData.noEffectPathMap[const.kPathDayTaskValReward]=true

function CoinData.getPathString(path)
    if not CoinData.__pathMap then
        CoinData.__pathMap = {}
        for k,v in pairs(const) do
            if string.find(k, "kPath") then
                CoinData.__pathMap[v] = k
            end
        end
    end
    return 'kPath: ' .. ( CoinData.__pathMap[path] or "nil" )
end

local function getData()
    return gameData.user
end

---
-- 根据货币类型获取货币的数量
---
function __this.getCoinByCate(cate, objid)
    --物品
    if cate == const.kCoinItem then
        return ItemData.getItemCount(objid)
    end

    local cateInfo = notify_coin_type[cate]
    if cateInfo == nil then
        return 0
    end
    local num = getData()[cateInfo[1]][cateInfo[2]]
    if cate == const.kCoinStrength then
        num = num - CopyData.strength
    end
    return num
end

--检查是否缺少货币列表
function __this.checkLackCoinList(coinList, silent)
    for i = 1, #coinList do
        if __this.checkLackCoinX(coinList[i], silent) then
            return true
        end
    end
    return false
end

--检查是否缺少货币
--@param coin S3Uint32 货币数据
--@param silent 可选，为ture时不弹出对话框
--@retuan 货币不足返回true, 否则返回false
function __this.checkLackCoinX(coin, silent)
    if not coin then
        return false
    end
    return __this.checkLackCoin(coin.cate, coin.val, coin.objid, silent)
end

---
-- 检查是否缺少货币，道具只判断普通背包[const.kBagFuncCommon]
--@param cate 货币类型
--@param value 数量
--@param objid 物品ID
--@retuan 货币不足返回true, 否则返回false
function __this.checkLackCoin(cate, value, objid, silent)
    value = value or 10000000000
    local result = false
    --是否缺少缺少物品
    if cate == const.kCoinItem then
        local packNum = ItemData.getItemCount(objid,const.kBagFuncCommon)
        result = value > packNum
        if not silent and result then --物品不足
            LogMgr.info("item not enough: "..objid)
            local item = findItem(objid)
            if item then
                 if AlteractData.canShow( cate,objid) then
                    AlteractData.showByData(cate,objid)
                else
                    TipsMgr.showError(string.format("%s 不足", item.name, value - packNum))
                end
            end
        end
        return result
    end

    --货币及simple一些值
    local coinData = __this.getCoinByCate(cate, objid)
    result = value > coinData
    if not silent and result then --处理货币不足
        LogMgr.info("coin not enough: "..cate)
        if ActTipsData.showTipsByType(cate) == false then
            if AlteractData.canShow( cate,objid) then
                AlteractData.showByData(cate,objid)
            elseif coinNameMap[cate] then
                TipsMgr.showError(string.format("%s不足", coinNameMap[cate], value - coinData))
            else
                TipsMgr.showError(string.format("%s货币不足", cate, value - coinData))
            end
        end
    end
    return result
end

function __this.isNeedBuyGold(num)
    if num > gameData.user.coin.gold then
        showMsgBox("钻石不足，是否购买钻石", function()
            Command.run( 'ui show', 'VipPayUI', PopUpType.SPECIAL)
        end)
        return true
    end
    return false
end
