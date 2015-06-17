local __this = {}
local CDTIME = 360 -- 6分钟恢复一点体力

function __this.getTeamLevel()
    local data = __this.getData()
	if data == nil then data = {} end
	return data.team_level
end

function __this.getCurrBuyTimes()
    if nil == VarData.getVarData().strength_day_buy_count then
        VarData.getVarData().strength_day_buy_count= {}
        VarData.getVarData().strength_day_buy_count.value = 0
    end
    return VarData.getVarData().strength_day_buy_count.value -- 当日购买体力的次数
end

function __this.getMaxBuyTimes()
	local vipLevel = gameData.getSimpleDataByKey('vip_level')
	local vipData = findLevel(vipLevel)
	local maxBuyCount = vipData.strength_buy -- 当日购买体力次数上限

	return maxBuyCount
end

function __this.getCurrCostTime()
	local last_time = VarData.getVarData()["strength_last_time"].value
	local srv_time = gameData.getServerTime()
	local time = srv_time - last_time
	
	return time
end

function __this.isStrengthFull( itemId, count )
	local addStrength = 0
	local item = findItem( itemId )
	if item then
		if item.coin.cate == const.kCoinStrength then
			addStrength = item.val * count
		end
	end

	local teamLevel = gameData.getSimpleDataByKey("team_level")
	local levelData = findLevel(teamLevel)
	local maxStrength = levelData.strength -- 体力上限
	local currStrength = gameData.getSimpleDataByKey('strength')

	return maxStrength <= ( currStrength + addStrength )
end

-- 恢复一点体力所要剩余的时间
function __this.getFewStrengthTime(t)
	t = t or 0
	return CDTIME - t
end
-- 体力完全恢复所需要剩余的时间
function __this.getAllStrengthTime(t)
	t = t or 0
	local teamLevel = gameData.getSimpleDataByKey("team_level")
	local levelData = findLevel(teamLevel)
	local maxStrength = levelData.strength -- 体力上限
	local currStrength = gameData.getSimpleDataByKey('strength')
	local tmp = (maxStrength - currStrength) < 0 and 0 or (maxStrength - currStrength)
	local time = tmp * CDTIME - t
	time = time < 0 and 0 or time

	return time
end

function __this.getStrengthTime(t)
	local st = {[2] = "00:00:", [5] = "00:", [8] = ""}
	local time = DateTools.secondToStringTwo(__this.getFewStrengthTime(t))
	local allTime = DateTools.secondToStringTwo(__this.getAllStrengthTime(t))
	time = st[string.len(time)] .. time
	allTime = st[string.len(allTime)] .. allTime
	local nextAdd = "下次增加体力：" .. time
	local allRecovery = "全部回复时间：" .. allTime

	return nextAdd .. '[br]' .. allRecovery
end

function __this.getRecoveryTips(t)
	if true == __this.isStrengthFull() then
		return "您的体力已充满"
	else
		return __this.getStrengthTime(t)
	end
end

function __this.getStrengthTips(t)
	local tips = __this.getRecoveryTips(t)
	local curr = __this.getCurrBuyTimes()
	local max = __this.getMaxBuyTimes()
	-- LogMgr.debug("curr = " .. curr, "max = " .. max)
	local buyTimes = "今日购买次数：" .. curr .. '/' .. max
	local info = tips .. '[br]' .. buyTimes

	return info
end

StrengthData = __this