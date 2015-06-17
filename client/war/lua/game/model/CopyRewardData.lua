-- Create By Hujingjiang --
------------------- 副本获取经验及物品 相关操作

local __this = {}

__this.prePosi = 1

-- 获取在副本posi阶段，reward , coins等所获得的 经验及物品奖励
function __this.getCurExpAndReward(posi)
--    LogMgr.debug(">>>>>>>>getCurExpAndReward posi = " .. posi)
    local exp = 0
    local itemList = {}
    if posi > 0 then
        local list = CopyData.user.copy.coins[posi]
        if nil ~= list then
            for i = 1, #list do
                local getReward = list[i]
                if getReward.cate == trans.const.kCoinTeamXp then
--                    LogMgr.debug(">>>>>>>>> coins 获得经验：" .. getReward.val)
                    exp = exp + getReward.val
                else
--                    LogMgr.debug(">>>>>>>>> coins 获得物品：" .. debug.dump(getReward))
                    table.insert(itemList, getReward)
                end
            end
        end
        
        local reward = CopyData.user.copy.reward[posi]
        if nil ~= reward then
            local rewardObj = findReward(reward.objid)
            if nil ~= rewardObj then
                local list = rewardObj.coins
                for i = 1, #list do
                    local getReward = list[i]
                    if nil ~= getReward then
                        if getReward.cate == trans.const.kCoinTeamXp then
--                            LogMgr.debug(">>>>>>>>> reward 获得经验：" .. getReward.val)
                            exp = exp + getReward.val
                        else
--                            LogMgr.debug(">>>>>>>>> reward 获得物品：" .. debug.dump(getReward))
                            table.insert(itemList, getReward)
                        end
                    end
                end
            end
        end
    end

    return exp, itemList
end

-- 获取进入副本内当前(包括reward,coins,奖励和宝箱等)所得到的奖励物品列表
function __this.getCurTotalRewardList()
    local rewardList = {}
    local posi = CopyData.user.copy.posi

    if posi ~= nil then
--    LogMgr.debug(">>>>>>> getCurTotalRewardList : prev = " .. __this.prePosi .. " posi = " .. posi)
        for i = __this.prePosi, posi do
            local chunk = CopyData.user.copy.chunk[i]
            if chunk.cate == trans.const.kCopyEventTypeBox or chunk.cate == trans.const.kCopyEventTypeReward then
                local _, list = __this.getPrizeOrBoxReward(chunk)
                for j = 1, #list do
                    local item = list[j]
                    local objid = __this.getRewardObjid(item)
                    if nil == rewardList[objid] then
                        rewardList[objid] = {cate = item.cate, val = 0, objid = item.objid}
                    end
                    rewardList[objid].val = rewardList[objid].val + item.val
                end
            end
            local _, list = __this.getCurExpAndReward(i)
            for j = 1, #list do
                local item = list[j]
                local objid = __this.getRewardObjid(item)
                if nil == rewardList[objid] then
                    rewardList[objid] = {cate = item.cate, val = 0, objid = item.objid}
                end
                rewardList[objid].val = rewardList[objid].val + item.val
            end
        end
    end

    return rewardList
end
-- 获取当前可获得reward及coins的经验及奖励
function __this.getCurReward()
    if nil == CopyData.user.copy then
        return 0, {}
    end
    local posi = CopyData.user.copy.posi + 1
    local exp, list = __this.getCurExpAndReward(posi)

    return exp, list
end
-- 获取chunk所得的经验及奖励列表
function __this.getPrizeOrBoxReward(chunk)
    local stype = "探索奖励"
    if chunk.cate == const.kCopyEventTypeBox then
        stype = "探索宝箱"
    end

    local exp = 0
    local list = {}
    local rewardObj = findReward(chunk.objid)
    if nil ~= rewardObj then
        local coins = rewardObj.coins
        for i = 1, #coins do
            local getReward = coins[i]
            if nil ~= getReward then
                if getReward.cate == trans.const.kCoinTeamXp then
--                    LogMgr.debug(">>>>>>>>> " .. stype .. " 获得经验：" .. getReward.val)
                    exp = getReward.val
                else
--                    LogMgr.debug(">>>>>>>>> " .. stype .. " 获得物品：" .. debug.dump(getReward))
                    table.insert(list, getReward)
                end
            end
        end
    end
    
    return exp, list
end
-- 显示 在posi所获得的奖励
function __this.showRewardAt(posi)
    local exp, list = 0, {}
    local c_exp, c_list = __this.getCurExpAndReward(posi)
    local chunk = CopyData.user.copy.chunk[posi]
    local p_exp, p_list = 0, {}
    if chunk.cate == trans.const.kCopyEventTypeBox or chunk.cate == trans.const.kCopyEventTypeReward then
        p_exp, p_list = __this.getPrizeOrBoxReward(chunk)
    end
    
    exp = c_exp + p_exp
    if exp > 0 then
        local data = {cate = 7, val = exp, obiid = 0}
        table.insert(list, data)
        EventMgr.dispatch(EventType.CopyGetExp, exp)
    end
    for k, v in pairs(p_list) do
        table.insert(list, v)
    end
    for k, v in pairs(c_list) do
        table.insert(list, v)
    end
--    if #list > 0 then
        EventMgr.dispatch(EventType.CopyGetList, list)
--    end
end

function __this.getEatItemNum(id)
    local num = 0
    local list = __this.getCurTotalRewardList()
    for k, v in pairs(list) do
        if v.cate == const.kCoinItem and v.objid == id then
            num = num + v.val
        end
    end
    return num
end

------------------ 物品的一些数据转换
-- 通过reward获取物品id
function __this.getRewardObjid(reward)
    local const = trans.const
    local cate = reward.cate
    local id = cate
    if cate == const.kCoinItem then
        id = reward.objid
    elseif cate == const.kCoinTotem then
        id = reward.objid
    end
    return id
end
-- 通过reward获取物品icon路径
function __this.getRewardIconUrl(reward)
    local const = trans.const
    local cate = reward.cate
    local url = ""
    if cate == const.kCoinMoney then
        url = "coin.png"
    elseif cate == const.kCoinGold then
        url = "diamond.png"
    elseif cate == const.kCoinItem then
        url = ItemData.getItemUrl(reward.objid)
    elseif cate == const.kCoinStrength then
        url = "power.png"
    elseif cate == const.kCoinWater then
        url = "solution.png"
    elseif cate == const.kCoinTotem then
        url = TotemData.getAvatarUrlById(reward.objid)
    end
    return url
end
-- 通过reward获取物品名称
function __this.getRewardIconName(reward)
    local const = trans.const
    local cate = reward.cate
    local name = "物品" .. reward.objid
    if cate == const.kCoinMoney then
        name = "金币"
    elseif cate == const.kCoinStrength then
        name = "体力"
    elseif cate == const.kCoinWater then
        name = "圣水"
    elseif cate == const.kCoinGold then
        name = "钻石"
    elseif cate == const.kCoinItem then
        local item = findItem(reward.objid)
        if nil ~= item then
            name = item.name
        end
    elseif cate == const.kCoinTotem then
        local item = findTotem(reward.objid)
        if nil ~= item then
            name = item.name
        end
    end
    return name
end

CopyRewardData = __this