local __this ={}
ActivityData = __this

ActivityData.path1 = "image/ui/ActivityUI/"
ActivityData.path2 = "image/ui/ActivityUI/local/"
ActivityData.path3 = "image/icon/actvity/%s.png"

ActivityData.activityList = {}
ActivityData.activityInfoList = {}

ActivityData.factorDescs = {} 
__this.factorDescs[const.kActivityFactorTypeFirstPay] = "首充%s"
__this.factorDescs[const.kActivityFactorTypeAddPay] = "累计充值%s元"
__this.factorDescs[const.kActivityFactorTypeLevel] = "战队等级达到%s级"
__this.factorDescs[const.kActivityFactorTypeSerialLogin] = "连续登录%s天"
__this.factorDescs[const.kActivityFactorTypeGetSoldier] = "搜集%s个英雄"
__this.factorDescs[const.kActivityFactorTypeUpSoldier] = "拥有%s个%s品质的英雄"
__this.factorDescs[const.kActivityFactorTypeGetTotem] = "拥有%s个图腾"
__this.factorDescs[const.kActivityFactorTypeMaxStartTotem] = "图腾总星级达到%s级"
__this.factorDescs[const.kActivityFactorTypePassTomb] = "大墓地通过第%s关"
__this.factorDescs[const.kActivityFactorTypeVipLevel] = "VIP等级达到%s级"
__this.factorDescs[const.kActivityFactorTypeTimeTatalGold] = "累计消耗%s钻石"
__this.factorDescs[const.kActivityFactorTypeDayTatalGold] = "每日消耗%s钻石"
__this.factorDescs[const.kActivityFactorTypeTimeTatalMoney] = "累计消耗%s金币"
__this.factorDescs[const.kActivityFactorTypeDayTatalMoney] = "每日消耗%s金币"
__this.factorDescs[const.kActivityFactorTypeTimeTatalBetGold] = "进行%s次钻石抽卡"
__this.factorDescs[const.kActivityFactorTypeDayTatalBetGold] = "每日进行%s次钻石抽卡"
__this.factorDescs[const.kActivityFactorTypeTimeTatalBetMoney] = "进行%s次普通抽卡"
__this.factorDescs[const.kActivityFactorTypeDayTatalBetMoney] = "每日进行%s次普通抽卡"
__this.factorDescs[const.kActivityFactorTypeDayTimesPayTimesGold] = "每日第%s次单笔充值%s钻石"


function ActivityData.getFactorDescByType( type)
	return __this.factorDescs[type]
end
--
function ActivityData.findOpenData( name )
	local list = __this.activityList.activity_open_list
	if #list <= 0 then  
		return nil
	end
	for k,v in pairs(list) do
		if v.name == name then
			return v
		end
	end
end

function ActivityData.findAData( guid )
	local list = __this.activityList.activity_data_list
	if #list <= 0 then 
		return nil
	end
	for k,v in pairs(list) do
		if v.guid == guid then
			return v
		end
	end
end

function ActivityData.findFactorData( guid )
	local list = __this.activityList.activity_factor_list
	if #list <= 0 then 
		return nil
	end
	for k,v in pairs(list) do
		if v.guid == guid then
			return v
		end
	end
end

function ActivityData.findRewardData( guid )
	local list = __this.activityList.activity_reward_list
	if #list <= 0 then 
		return nil
	end
	for k,v in pairs(list) do
		if v.guid == guid then
			return v
		end
	end
end

--是否有缉拿奖励可以
function ActivityData.checkActionGeted()
	local list = ActivityData.activityInfoList
	if list and #list > 0 then
		for k,v in pairs(list) do
			local openData = ActivityData.findOpenData(v.name)
	        if openData then
	            local AData = ActivityData.findAData(openData.data_id)
	            --读取活动图标
	            if AData then
	                local isGeted = __this.hasGeted(openData,AData)
	                if isGeted then
	                	return true
	        		end
	            end
	        end
		end
	end
	return false
end

--该活动是否有可以领取
function ActivityData.hasGeted( openData,AData )
	local dataList = AData.value_list
	if dataList and #dataList > 0 then
		for k,v in pairs(dataList) do
			local isGeted = VarData.getVar(string.format("activity_%s_present_%d",openData.name,k - 1))
			if not isGeted or isGeted <= 0 then
				local x, y = string.match(v,"(%w+)%%(%w+)")
				local first,second = toMyNumber(x),toMyNumber(y)
				if first and first ~= 0 then
					local factor = __this.findFactorData(first)
	            	if factor then
	            		local meetCondition,curVar = __this.checkFactor(openData.name,factor)
	            		if meetCondition then
	            			return meetCondition
	            		end
	            	end
				end
			end
		end
	end
	return false
end

--返回已经排序好的列表。1：有奖励可以领取，2：未达到领取，3:已经领取
function ActivityData.getCondintionListBySort( openData,AData )
	local list = {}
	local list1 = {}
	local list2 = {}
	local list3 = {}
	local obj = nil
	local dataList = AData.value_list
	if dataList and #dataList > 0 then
		for k,v in pairs(dataList) do
			local obj = {}
			obj.index = k
			local x, y = string.match(v,"(%w+)%%(%w+)")
			obj.first,obj.second = toMyNumber(x),toMyNumber(y)

			local isGetedValue = VarData.getVar(string.format("activity_%s_present_%d",openData.name,k - 1))
			if isGetedValue and isGetedValue > 0 then
				table.insert(list3,obj)
				obj.isGeted = true
			else
				obj.isGeted = false
			end

			if obj.first and obj.first ~= 0 then
				local factor = __this.findFactorData(obj.first)
            	if factor then
            		obj.meetCondition,obj.curVar = __this.checkFactor(openData.name,factor)
            		if not obj.isGeted then
	            		if obj.meetCondition then
	            			table.insert(list1,obj)
	            		else
	            			table.insert(list2,obj)
	            		end
            		end
            	end
        	end
		end
	end
	__this.JoinList(list,list1)
	__this.JoinList(list,list2)
	__this.JoinList(list,list3)
	return list
end

function ActivityData.JoinList( list,jList )
	for k,v in pairs(jList) do
		table.insert(list,v)
	end
end

function ActivityData.checkFactor( name,factor)
	local curVar = nil
	if factor then
		cue = __this.getFactorDescByType(factor.type)
		if factor.type == const.kActivityFactorTypeAddPay then  --累积充值X
			curVar = VarData.getVar(string.format("activity_%sadd_pay",name))

		elseif factor.type == const.kActivityFactorTypeTimeTatalGold then --活动期间累计消耗XX钻石
			curVar = VarData.getVar(string.format("activity_%stime_tatal_gold",name))

		elseif factor.type == const.kActivityFactorTypeTimeTatalMoney then --活动期间累计消耗XX金币活动期间累积消费金币
			curVar = VarData.getVar(string.format("activity_%stime_tatal_money",name))	

		elseif factor.type == const.kActivityFactorTypeTimeTatalBetGold then --活动期间进行X次钻石抽卡
			curVar = VarData.getVar(string.format("activity_%stime_tatal_bet_gold",name))

		elseif factor.type == const.kActivityFactorTypeTimeTatalBetMoney then --活动期间进行X次普通抽卡
			curVar = VarData.getVar(string.format("activity_%stime_tatal_bet_money",name))

		elseif factor.type == const.kActivityFactorTypeDayTatalBetGold then--每日钻石抽卡次数
			curVar = VarData.getVar(string.format("day_bet_gold"))

		elseif factor.type == const.kActivityFactorTypeDayTatalBetMoney then--每日普通抽卡次数
			curVar = VarData.getVar(string.format("day_bet_money"))

		elseif factor.type == const.kActivityFactorTypeDayTatalGold then--每日消费钻石
			curVar = VarData.getVar(string.format("day_cost_gold"))

		elseif factor.type == const.kActivityFactorTypeDayTatalMoney then--每日消费金币
			curVar = VarData.getVar(string.format("day_cost_money"))

		elseif factor.type == const.kActivityFactorTypeSerialLogin then --连续登入天数
            curVar = VarData.getVar(string.format("login_continuous_day"))

		elseif factor.type == const.kActivityFactorTypeLevel then--玩家等级
			curVar = gameData.getSimpleDataByKey("team_level")
		elseif factor.type == const.kActivityFactorTypeGetSoldier then--搜集X个英雄
			local sList = SoldierData.getTable()
			curVar = #sList
		elseif factor.type == const.kActivityFactorTypeVipLevel then--VIP等级达到X级
			curVar = gameData.getSimpleDataByKey("vip_level")
		elseif factor.type == const.kActivityFactorTypePassTomb then--大墓地通过第X关
			curVar = GameData.user.tomb_info.win_count
		elseif factor.type == const.kActivityFactorTypeGetTotem then -- 搜集X个图腾
			curVar = TotemData.getCount()
		elseif factor.type == const.kActivityFactorTypeMaxStartTotem then -- 图腾总星级达到X级
			curVar = TotemData:getStarCount()
		elseif factor.type == const.kActivityFactorTypeUpSoldier then -- 进阶X个英雄到X品质
			--注意：两个条件
			curVar = SoldierData.getSoldierByQuality(factor.value1)
		elseif factor.type == const.kActivityFactorTypeDayTimesPayTimesGold then -- 进阶X个英雄到X品质
			--注意：两个条件
			curVar = VarData.getVar(string.format("activity_day_times_pay_times_gold_%d",factor.value1)) -- 每日第X次单笔充值X
		end

		if curVar and curVar >= factor.value then
			return true,curVar
		else
			return false,curVar
		end
	end
end

function ActivityData.getFactorCue( name,factor)
	local cue = ""
	if factor then
		local meetCondition,curVar = __this.checkFactor(name,factor)
		if meetCondition then
			return true,""
		else
			if curVar and curVar < factor.value then
				if factor.type == const.kActivityFactorTypeUpSoldier then
					local qColorName = SoldierData.getSoldierQualityColor(factor.value1)
					return false,"需要"..string.format(cue,factor.value,qColorName)
				else
					return false,"需要"..string.format(cue,factor.value)
				end
			end
		end
	end
end
--首充是否已充值
function ActivityData.hasFirstRecharge( ... )
	return gameData.user.pay_info and gameData.user.pay_info.pay_count >= 1
end
--首充是否已领
function ActivityData.hasGetedFR( ... )
	return VarData.getVar("frist_pay_reward_flag") >= 1
end
--首充是否能领取
function ActivityData.isCanGet( ... )
	return ActivityData.hasFirstRecharge() == true and ActivityData.hasGetedFR() == false 
end