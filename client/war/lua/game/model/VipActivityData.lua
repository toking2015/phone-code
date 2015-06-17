
local __this = VipActivityData or {}
VipActivityData = __this

local cur_selected = 0 -- 当前选择
local now_week = 1 -- 第几周
local max_week = nil
local next_refresh_time = 0

function __this.getVipActivityList()
	local list = gameData.user.viptimelimit_goods_list or {}
	table.sort(list, function(a, b) return a.vip_package_id < b.vip_package_id end)
	return list
end

function __this.getNextBuyTime(lev)
	local sLevel = lev or __this.getCurSelected() -- 当前选中的等级
	local list = __this.getVipActivityList()
	if not list or table.empty(list) then
		return 0
	end
	local next_buy_time = 0
	for _, v in pairs(list) do
		if v.vip_package_id == sLevel then
			next_buy_time = v.next_buy_time
			break
		end
	end
	return next_buy_time
end

function __this.getCurrBuyCount(lev)
	local sLevel = lev or __this.getCurSelected() -- 当前选中的等级
	local list = __this.getVipActivityList()
	if not list or table.empty(list) then
		return 0
	end
	local buyed_count = 0
	for _, v in pairs(list) do
		if v.vip_package_id == sLevel then
			buyed_count = v.buyed_count
			break
		end
	end
	return buyed_count
end

-- 当前选择的等级
function __this.setCurSelected(index)
	if index == cur_selected then
		return
	end
	local cur = cur_selected
	cur_selected = index
	EventMgr.dispatch(EventType.changeSelect, {prev = cur, curr = index})
end

function __this.getCurSelected()
	return cur_selected
end
-- 当前周数
function __this.setTimeWeek(week)
	week = week and week or 1
	max_week = tonumber(findGlobal('vip_timelimitshop_max_week').data)
	if week > max_week then
		week = max_week
	end
	now_week = week
end

function __this.getTimeWeek()
	return now_week
end

function __this.getFirstNotTake()
	local max_level = tonumber(findGlobal('vip_timelimitshop_max_level').data)
	for i = 0, max_level do
		if __this.isCanBuyPackage(i) then
			cur_selected = i
			break
		end
	end
end

function __this.getNextRefreshTime()
	return next_refresh_time
end
function __this.setNextRefreshTime(time)
	if time then
		next_refresh_time = time - gameData.getServerTime()
	else
		next_refresh_time = 0
	end
end

-- 是否达到等级
function __this.isMeetVipLevel(lev)
	local vip_lev = gameData.getSimpleDataByKey('vip_level') or 0
	local cur_lev = lev or __this.getCurSelected()
	if vip_lev < cur_lev then
		return false
	end

	return true
end

function __this.getVipBuyList(list)
	return list or {}
end
-- 判断是否已购买
function __this.isBuyPackage(lev)
	-- 是否已领取
	local max_buy_count = tonumber(findGlobal('vip_timelimitshop_buy_limit').data)
	local cur_buy_count = __this.getCurrBuyCount(lev)
	if cur_buy_count < max_buy_count then
		return false
	end
	local isBuy = __this.getTimeSplus(lev) -- 根据是否有倒计时判断是否购买
	if isBuy <= 0 then
		return false
	end
	return true
end
-- 获取剩余时间
function __this.getTimeSplus(lev)
	-- 获取剩余时间
	local can_buy_time = __this.getNextBuyTime(lev)
	local srv_time = gameData.getServerTime()
	local splus_time = (can_buy_time - srv_time)
	return splus_time < 0 and 0 or splus_time
end
-- 倒计时
function __this.getCDTime(time)
	local result = DateTools.secondToString(time, 4)
	return result
end
-- 读表数据
function __this.getXlsDataByWeek(lev)
	lev = lev or cur_selected
	local list = findVipTimeLimitShop(now_week, lev)
	return list
end
-- 价格
function __this.getPrice(lev)
	lev = lev or cur_selected
	local list = __this.getXlsDataByWeek(lev)
	list = not list and {} or list
	local discount = list.discount_price and list.discount_price.val or 0
	local real = list.real_price and list.real_price.val or 0

	return real, discount
end
-- 物品列表
function __this.getPackage(lev)
	lev = lev or cur_selected
	local data_list = __this.getXlsDataByWeek(lev)
	data_list = not data_list and {} or data_list
	local item_list = data_list.item or {}
	local len = #item_list
	local list = {} -- 拆分后数字列表
	table.sort(item_list, function(a, b) return a.val > b.val end)
	if len < 4 then --拆分Item
		local count = 0
		local index = 0
		local max = 0
		for i = 1, len do 
			local val = item_list[i].val
			if val > max then
				max = val
				index = i
			end
			count = item_list[i].val + count
		end
		if count >= 4 then -- 拆分
			local d = 4 - len + 1 -- 还需要分几份
			if max >= d then -- 只要拆分最大的值
				local num = max/d
				for i = 1, d do
					if i == d then
						-- table.insert(list, max-(i-1)*num)
						table.insert(list, {cate = item_list[1].cate, objid = item_list[1].objid, val = max-(i-1)*num})
					else
						-- table.insert(list, num)
						table.insert(list, {cate = item_list[1].cate, objid = item_list[1].objid, val = num})
					end
				end
				for i = 2, len do
					table.insert(list, item_list[i])
				end
			else
				-- 只有一种情况{2,2}
				-- list = {1, 1, 1, 1}
				for i = 1, 2 do
					table.insert(list, {cate = item_list[1].cate, objid = item_list[1].objid, val = 1})
				end
				for i = 1, 2 do
					table.insert(list, {cate = item_list[2].cate, objid = item_list[2].objid, val = 1})
				end
			end
		end
	end

	-- if not table.empty(list) then
	-- 	return list
	-- end

	return item_list
end

-- 判断某一个是否可购买
function __this.isCanBuyPackage(index)
	if VipActivityData.isMeetVipLevel(index) then
		if VipActivityData.isBuyPackage(index) then
			return false
		else
			-- local _,price = VipActivityData.getPrice(index)
			-- local dia = CoinData.getCoinByCate(const.kCoinGold)
			-- if dia < price then
				-- return false
			-- else
				return true
			-- end
		end
	else
		return false
	end
end

function __this.isShowRedPoint()
	local max_level = tonumber(findGlobal('vip_timelimitshop_max_level').data)
	local isShow = false
	for i = 0, max_level do
		if __this.isCanBuyPackage(i) then
			isShow = true
			break
		end
	end
	return isShow
end

function __this.isMove(prev, curr)
	local max_level = tonumber(findGlobal('vip_timelimitshop_max_level').data)
	local d = math.abs(curr - prev)
	local v = (curr - prev) > 0 and -1 or 1
	if v < 0 then
		-- 向左滑动
		-- -- if prev >= 18 or curr == 20 then
		-- if prev >= max_level - 2 or curr == max_level then
		-- 	return false, 100
		-- end
		-- if prev == 0 and d == 1 then
		-- 	return false, 0
		-- elseif prev == 0 then
		-- 	return true, 2 - d
		-- else
		-- 	return true, -1
		-- end
		if curr <= 1 then
			return false, 0
		-- elseif (curr == max_level - 1 and curr - prev < 2) or curr == max_level then
		-- 	return false, 0
		elseif curr >= max_level - 1 then
			return true, 7
		else
			return true, curr - 1
		end
	else
		-- 向右滑动
		-- if curr <= 0 then
		-- 	return false, 100
		-- end
		-- -- if prev == 20 and d == 1 then
		-- if prev == max_level and d == 1 then
		-- 	return false, 0
		-- -- elseif prev == 20 then
		-- elseif prev == max_level then
		-- 	return true, -d--1 - d
		-- else
		-- 	return true, -d-- - 1
		-- end
		if curr >= max_level - 1 then
			return false, 0
		-- elseif (curr == 1 and prev - curr > 1) or curr == 0 then
		-- 	return false, 0
		elseif curr <= 1 then
			return true, 0
		else
			return true, curr - 2
		end
	end
end