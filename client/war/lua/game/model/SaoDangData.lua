-- Create By Hujingjiang --
------------ 扫荡相关等操作 ---------------
local __this = SaoDangData or {}
SaoDangData = __this


function __this.saoDangItemInit()
    if not __this.itemData then
        __this.itemData = {}

        local data = GetDataList("ItemMerge")
        for __, merge in pairs(data) do
            for __, s3 in pairs(merge.materials) do
                if const.kCoinItem == s3.cate then
                    __this.itemData[s3.objid] = __this.itemData[s3.objid] or {max=0, count=0}
                    __this.itemData[s3.objid].max = s3.val
                end
            end
        end
    end

    for key, item in pairs(__this.itemData) do
        item.count = ItemData.getItemCount(key)
    end
end
function __this.getSaoDangItem(item_id, count)
    -- body
    if not __this.itemData[item_id] then
        return count
    end

    local item = __this.itemData[item_id]
    item.count = item.count + count
    return item.count .. '/' .. item.max
end

-- 获取当前stype类型的boss_id已扫荡的次数
function __this.getCurSaoTimes(stype, boss_id)
    local mopup = gameData.user.mopup
    local times = mopup.normal_times
    if stype == trans.const.kCopyMopupTypeElite then
        times = mopup.elite_times
    end
    if nil ~= times[boss_id] then
        return times[boss_id]
    end
    return 0
end
-- 获取stype类型的最大扫荡次数
function __this.getTotalSaoTimes(stype)
    local times = 20
    if stype == const.kCopyMopupTypeElite then
        times = 3
    end
    return times
end
-- 获取stype类型boss_id的剩余扫荡次数
function __this.getLeftSaoTimes(stype, boss_id)
    local count = __this.getTotalSaoTimes(stype)
    local exCount = __this.getCurSaoTimes(stype, boss_id)
    return count - exCount
end
-- 通过副本id获取剩余扫荡次数
function __this.getLeftSaoTimesByCopyId(stype, copy_id)
    local boss_id = CopyData.getCopyBoss(copy_id, stype).boss_id
    return __this.getLeftSaoTimes(stype, boss_id)
end
-- 获取当前stype类型的boss_id已重置的次数
function __this.getCurResetTimes(stype, boss_id)
    local mopup = gameData.user.mopup
    local times = mopup.normal_reset
    if stype == trans.const.kCopyMopupTypeElite then
        times = mopup.elite_reset
    end
    if nil ~= times[boss_id] then
        return times[boss_id]
    end
    return 0
end
-- 获取stype类型的扫荡重置次数
function __this.getTotalResetTimes(stype)
    local lv = gameData.user.simple.vip_level
    local lvData = findLevel(lv)
    local times = lvData.copy_normal_reset_times
    if stype == trans.const.kCopyMopupTypeElite then
        times = lvData.copy_elite_reset_times
    end
    return times
end