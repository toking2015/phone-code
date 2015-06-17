local __this = PayData or {}
PayData = __this

__this.payTime = nil

function __this.getPayList()
    return gameData.user.pay_list
end

function __this.getPayInfo()
	return gameData.user.pay_info
end

function __this.countPayByCoin(coin)
	-- 统计某一类型订单的数量
	local count = 0 -- 统计结果
	local list = __this.getPayList()
	for _, v in pairs(list) do
		if v.coin == coin and v.type ~= const.kPayTypeNormal then
			count = count + 1
		end
	end
	return count
end

function __this.judgePayType(coin)
	-- 判断充值类型
end

function __this.checkFirstPay()
	--判断是否首冲
    return __this.getPayInfo().first_pay_coin == const.kPathFirstPay
end

function __this.checkCardValid()
	-- 判断月卡是否到期
	local time = __this.getPayInfo().month_time - gameData.getServerTime()
    return time, (time > 0 and true or false)
end

function __this.getCardRemainDay()
	local time = __this.getPayInfo().month_time - gameData.getServerTime()
	return DateTools.getDay(time)
end

function __this.getCardReward()
	-- 获取月卡奖励
    return __this.getPayInfo().month_reward
end

function __this.getGivePresent(data)
	if nil == data then
		LogMgr.log( 'debug',"获取奖励数据不为空")
	end
	local count = __this.countPayByCoin(data.coin)
	local present = data.present[count+1] or 0

	return present
end

function __this.obtainPrivilegeList(level)
    -- 根据VIP等级获取特权列表
    local rightsList = {}
    -- 某些Vip等级特有的特权
    local vip_level = gameData.getSimpleDataByKey('vip_level')
    if vip_level > 20 then
    	vip_level = 20
    end
    level = level or vip_level
    local vipData = findLevel(level)
    if vipData then
    	local add_rights = vipData.vip_rights_desc
        if add_rights and add_rights ~= '' then
    		table.insert(rightsList, {icon=0, rights=add_rights})
    	end
    end

    local list = GetDataList("VipPrivilege")
    for i = 1, #list do 
        --          local temp_str = "vip" .. level
        local temp = list[i]["vip"]
        local data = temp[level]
        local id = list[i].id
        local rightsName = list[i].name
        if 0 ~= data then 
        	local rights = string.format(rightsName, data)
            table.insert(rightsList, {icon=id, rights=rights})
        end
    end
    return rightsList
end

function __this.sortPayList(list)
	local tmp = {}
	local sortList = {}
	if list[25] ~= nil then
		-- 月卡放在第一的位置显示
		table.insert(sortList, list[25])
	end
	for _,v in pairs(list) do
		table.insert(tmp, v)
	end
	table.sort(tmp, function(a,b) return a.pay > b.pay end)
	for _, v in pairs(tmp) do
		if 25 ~= v.pay then
			table.insert(sortList, v)
		end
	end

	return sortList
end

function __this.getPayDataList()
	local list = GetDataList("Pay")
	return __this.sortPayList(list)
end
