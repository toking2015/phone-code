FriendData = {}
FriendData.TYPE_FRIEND=1
FriendData.TYPE_BLIACK=2
FriendData.TYPE_ASKED=3
FriendData.TYPE_STRANGER=4
FriendData.current_type=1
FriendData.friend_list = Dictionary:create()
FriendData.friend_limit_list = Dictionary:create()
FriendData.friend_limit_select_list = Dictionary:create()
FriendData.recommend_list={}
FriendData.asked_list={}
FriendData.isFriendChatId = nil
FriendData.frindChatMap = Dictionary:create()
FriendData.frindChatMapAll = Dictionary:create()
FriendData.friendAccesetList = {}
FriendData.FriendAskMakeFriend = {}

function FriendData:getCurrentDataList( friendType )
	if friendType == nil then
		friendType = FriendData.current_type
	end
	local relist = {}
	if friendType == FriendData.TYPE_ASKED then
		relist = self:getAskFriendList()
	else
		for _,v in pairs(FriendData.friend_list:getList()) do
			if v and self:cheakType(v,friendType) then
				table.insert(relist,v)
			end
		end
		--并且有最近私聊的好友排在最上（如果是有未读消息的则优先级更高）
		table.sort(relist, function(a,b)
			local allcount_a = self:getAllChatById(a.friend_id)
			local allcount_b = self:getAllChatById(b.friend_id)
			local newcount_a = self:getNewChatById(a.friend_id)
			local newcount_b = self:getNewChatById(b.friend_id)
			local cansend_a = self:getCanSenActivity(a.friend_id)
			local cansend_b = self:getCanSenActivity(b.friend_id)
			local indexa = table.indexOf(FriendData.friendAccesetList,a.friend_id)
			local indexb = table.indexOf(FriendData.friendAccesetList,b.friend_id)
			if indexa ~= -1 and indexb ~= -1 then
				return indexa < indexb
			elseif indexa ~= -1 then
				return true
			elseif indexb ~= -1 then
				return false
			elseif newcount_a > 0 and newcount_b > 0 then
				if newcount_a > newcount_b then
					return true
				elseif newcount_a == newcount_b then
					return a.friend_id < b.friend_id
				else
					return false
				end
			elseif newcount_a > 0 then
				return true
			elseif newcount_b > 0 then
				return false
			else
				if allcount_b > allcount_a then
					return false
				elseif allcount_b == allcount_a then
					return a.friend_id < b.friend_id
					-- if cansend_a and cansend_a > 0 and cansend_b and  cansend_b > 0 then 
					-- 	return a.friend_id < b.friend_id
					-- elseif cansend_a and cansend_a > 0 then --可以赠送的放上面
					-- 	return false
					-- elseif cansend_b and cansend_b > 0 then
					-- 	return true
					-- else
					-- 	return a.friend_id < b.friend_id
					-- end
				else
					return true
				end
			end
		 end )
	end
	return relist
	--return self:getTestData(friendType)
end

function FriendData:getFriendDataByRoleId( role_id )
	return FriendData.friend_list:get(role_id)
end

function FriendData:getFriendDataByRoleIdType( friend_id,sfriend_type )
	local friend_type = sfriend_type or FriendData.TYPE_FRIEND
	if FriendData.friend_list:get(friend_id) and self:cheakType(FriendData.friend_list:get(friend_id),friend_type) then
		return FriendData.friend_list:get(friend_id)
	end
	return nil
end

function FriendData:getTestData( friendType )
	local  relist = {}
	local len = math.random(1, 50)
	for i=1,len do 
		if friendType == FriendData.TYPE_ASKED then
			table.insert(relist,math.random(1,2015))
		else
			local testdata = {}
			testdata.friend_id = math.random(1,2015)
			testdata.friend_favor = math.random(1,10)
			testdata.friend_group = math.random(1,3)
			testdata.on_time = 0
			table.insert(relist,testdata)
		end
	end
	return relist
end

--更新好友列表
function FriendData:updateFrinedData( msg )
	if FriendData.friend_list == nil then
	 	FriendData.friend_list = Dictionary:create()
 	end
	if msg.set_type == trans.const.kObjectAdd or  msg.set_type == trans.const.kObjectUpdate then
		FriendData.friend_list:add(msg.info.friend_id,msg.info)
		self:dlectRecomListData(msg.info.friend_id)
	elseif msg.set_type == trans.const.kObjectDel then
		FriendData.friend_list:remove(msg.info.friend_id)
	end
end

--更新限制列表
function FriendData:updateFrinedLimitData( msg )
	if FriendData.friend_limit_list == nil then
	 	FriendData.friend_limit_list = Dictionary:create()
 	end
	if msg.set_type == trans.const.kObjectAdd or  msg.set_type == trans.const.kObjectUpdate then
		FriendData.friend_limit_list:add(msg.info.friend_id,msg.info)
	elseif msg.set_type == trans.const.kObjectDel then
		FriendData.friend_limit_list:remove(msg.info.friend_id)
	end
end

--更新选择的材料
function FriendData:updateOrClearLimitSelcetData(  item_guid,item_count)
	if item_guid == nil and item_count == nil then
		FriendData.friend_limit_select_list = Dictionary:create()
	elseif item_count == 0 then
		FriendData.friend_limit_select_list:remove(item_guid)
	else
		FriendData.friend_limit_select_list:add(item_guid,item_count)
	end
end

function FriendData:addLimitSellectData( suserItem,friend_data )
	if suserItem and friend_data then
		local cansend = self:getCanSendItemCount(friend_data.friend_id)
		if cansend == 0 then
			TipsMgr.showError("赠送数量已达上限")
			return
		end

		local count = tonumber(FriendData.friend_limit_select_list:get(suserItem.guid))
		local select_all_count = self:getSelectAllCount()
		if count then
			if count < suserItem.count and count < cansend then
				if select_all_count < cansend then
					self:updateOrClearLimitSelcetData(  suserItem.guid,count + 1)
				else
					TipsMgr.showError("选择数量已达上限")
				end
			end
		else
			count = (cansend >= suserItem.count and suserItem.count or cansend)
			if select_all_count < cansend then
				count = math.min(count, cansend - select_all_count  )
				self:updateOrClearLimitSelcetData(  suserItem.guid,count)
			else
				TipsMgr.showError("选择数量已达上限")
			end
		end
	end
end

function FriendData:getSelectAllCount( ... )
	local count = 0
	for _,v in pairs(FriendData.friend_limit_select_list:getList()) do
		if v and v > 0 then
			count = count + v
		end
	end
	return count
end

function FriendData:delLimitSellectData( suserItem )
	if suserItem then
		local count = FriendData.friend_limit_select_list:get(suserItem.guid)
		if count then
			if count > 0  then
				self:updateOrClearLimitSelcetData(  suserItem.guid,count - 1)
			end
		end
	end
end

function FriendData:getSlectItemCount( userItem )
	if userItem then
		return FriendData.friend_limit_select_list:get(userItem.guid)
	end
end

function FriendData:dlectRecomListData( friendId )
	local index = -1
	for i,k in pairs(FriendData.recommend_list) do 
		if k.friend_id == friendId then
			index = i
		end
	end
	if index ~= -1 then
		table.remove(FriendData.recommend_list, index )
		EventMgr.dispatch( EventType.FriendRecomChange )
	end
end
--返回设置列表
function FriendData:setFriendList( friend_list )
	FriendData.friend_list = Dictionary:create()
	for _,v in pairs(friend_list) do
		if v then
			FriendData.friend_list:add(v.friend_id,v)
		end
	end
end
--返回限制列表
function FriendData:setFriendLimitList( friend_limit_list )
	FriendData.friend_limit_list = Dictionary:create()
	for _,v in pairs(friend_limit_list) do
		if v then
			FriendData.friend_limit_list:add(v.friend_id,v)
		end
	end
end

--检查类型
function FriendData:cheakType( SUserFriend,frindeType )
	if SUserFriend then
		if frindeType == FriendData.TYPE_FRIEND and SUserFriend.friend_group == const.kFriendGroupFriend then
			return true
		end
		if frindeType == FriendData.TYPE_BLIACK and SUserFriend.friend_group == const.kFriendGroupBlack then
			return true
		end
		if frindeType == FriendData.TYPE_STRANGER and SUserFriend.friend_group == const.kFriendGroupStranger then
			return true
		end
	end
	return false
end

function FriendData:getIndext( ... )
	if FriendData.current_type == FriendData.TYPE_FRIEND then
		return 1
	elseif FriendData.current_type == FriendData.TYPE_BLIACK then
		return 2
	elseif FriendData.current_type == FriendData.TYPE_STRANGER then
		return 4
	else
		return 3
	end
end

function FriendData:setCurrentType( type )
	if FriendData.current_type == type then
		return
	end
	FriendData.current_type = type
	EventMgr.dispatch(EventType.FriendTypeChange)
end

-- 好友推荐回复
function FriendData:setRecommendList( list )
	if list then
		FriendData.recommend_list = list
	else
		FriendData.recommend_list = {}
	end
end

function FriendData:getRecomIdList( ... )
	local list = {}
	if FriendData.recommend_list then
		for _,v in pairs(FriendData.recommend_list) do
			table.insert(list,v.friend_id)
		end
	end
	return list
end
function FriendData:getAskFriendList( ... )
	local relist = {}
	if FriendData.asked_list then
		for _,v in pairs(FriendData.asked_list) do
			local friend_id = v.friend_id
			if FriendData:getFriendDataByRoleIdType(friend_id,TYPE_ASKED) == nil then
				table.insert(relist,v)
			end
		end
	end
	return relist
end

--被加好友增加
function FriendData:addAskeFriend( friendData )
	if not FriendData.getFriendDataByRoleIdType(friendData.friend_id) then
		local oldList = self:getOldList(friendData.friend_id,FriendData.asked_list)
		table.insert(oldList,1,friendData)
	    FriendData.asked_list = oldList
	end
end

--返回删除后的新列表
function FriendData:getOldList( friendId,oldlist )
	local relist = {}
	if oldlist and #oldlist > 0 then
		for _,v in pairs(oldlist) do
			if v.friend_id ~= friendId then
				table.insert(relist,v)
			end
		end
	end
	return relist
end

--被加好友减少
function FriendData:delAskeFriend( friendId )
	FriendData.asked_list = FriendData:getOldList(friendId,FriendData.asked_list)
	EventMgr.dispatch( EventType.FriendUpdata )
end

function FriendData:updateCachetData( friendid,conainer )
	local function onSimpleCallback( roledata )
		if roledata and conainer and conainer.setRoleData then
			conainer:setRoleData(roledata)
		end
	end 
	local simple_data = UserData.loadSimple(friendid,onSimpleCallback)
	if simple_data then
		onSimpleCallback(simple_data)
	end
end

function FriendData:getTestRole( conainer )
	if conainer then
		local testRole = {}
		testRole.name = "测试名字"
		testRole.gender = 0
		testRole.avatar = 10001
		testRole.team_level = math.random(1,100)
		testRole.guild_id =  math.random(0,1)
		conainer:setRoleData(testRole)
	end
end

function FriendData:getSendItemlist( ... )
	local item_list = {}
	for _,v in pairs(FriendData.friend_limit_select_list:getList()) do
			if v and v > 0 then
				local obj = {cate = const.kBagFuncCommon,objid = _,val = v}
				table.insert(item_list,obj)
			end
	end
	return item_list
end
--获取公会名字
function FriendData:getLegionName( legion_id ,name)
	local legion_name
	if (legion_id == nil or legion_id == 0) and (name == nil or name == "")  then
		legion_name = "暂无公会"
	elseif legion_id and tonumber(legion_id) > 0 then
		legion_name = "公会ID："..legion_id
	else
		legion_name = name
	end
	return legion_name
end

--还能赠送多少
function FriendData:getCanSendItemCount( friend_id )
	local count = self:getMaxSendTimes()
	local limidata = FriendData.friend_limit_list:get(friend_id)
	if limidata then
		if limidata.num_limit then
			local numcount = limidata.num_limit
			if limidata.type_limit then
				local ser_time = GameData.getServerTime()
				if limidata.type_limit <= ser_time then
					numcount = 0
				end
			end
			count =math.max(0,self:getMaxSendTimes() - numcount)
		end
	end
	return count
end


--是赠送手工活力剩余时间 nil或0为没时间限制 秒
function FriendData:getCanSenActivity( friend_id )
	local count = nil
	local limidata = FriendData.friend_limit_list:get(friend_id)
	if limidata then
		if limidata.time_limit then
			local ser_time = GameData.getServerTime()
			if limidata.time_limit < ser_time then
				local bttime = self:getSednActiBetewTimes()
				local indeltime = ser_time - limidata.time_limit
				if bttime <= indeltime then
				else
					count = bttime - indeltime
				end
			end
		end
	end
	return count
end

--好友系统每天可赠送同一人物品限制
function FriendData:getMaxSendTimes( ... )
	if self.friend_give_item_num_limit == nil then
		self.friend_give_item_num_limit= tonumber(findGlobal("friend_give_item_num_limit").data)
	end
	return self.friend_give_item_num_limit
end
--好友系统每隔多少秒可赠送同一人一次手工活力
function FriendData:getSednActiBetewTimes( ... )
	if self.friend_give_activescore_time_limit == nil then
		self.friend_give_activescore_time_limit= tonumber(findGlobal("friend_give_activescore_time_limit").data)
	end
	return self.friend_give_activescore_time_limit
end

--红点处理
--请求加好友待处理
function FriendData:AskedAwaitNum( ... )
	local await_num = 0
	if  #self:getAskFriendList() then
		await_num = #self:getAskFriendList()
	end
	return await_num
end
--好友总待处理事务
function FriendData:FriendAwaitNum( ... )
	return self:AskedAwaitNum()
end

function FriendData:errMap( ... )
	return {kErrFriendNotOpenForSelf="未开启好友功能",kErrFriendNotOpen = "对方未开启好友功能",
	kErrFriendNoExistMine = "你非对方好友",kErrFriendNormalMax="好友已达上限",
	kErrFriendBlackMax="黑名单已达上限",kErrFriendOffline="对方不在线",
	kErrFriendNoExist="好友数据不存在",kErrFriendExist="好友已存在",
	kErrFriendUpdateParam="参数操作错误",kErrFriendActiveScoreNoEnough="赠送的手工活力不够",
	kErrFriendActiveScoreLimit="处于CD冷却中",kErrFriendItemEorror="物品赠送类型不符",
	kErrFriendSelf="不能加自己为好友",kErrFriendItemMaxNumLimit="对方接受物品数量已达上限",
	kErrFriendItemSendNumLimit="对该好友已达最大发送上限",kErrFriendItemNoNum="赠送物品数量为空",
	kErrFriendFightNoOpenSinglearenaOne="竞技场未开放，不能挑战",kErrFriendFightNoOpenSinglearenaTwo="对方竞技场未开放，不能挑战",
	kErrFriendItemNumNoEnough="物品不足",kErrFriendActiveScoreMaxNumLimit="对方接收手工活力已达上限",
	kErrFriendSelfLevelLimit="等级不够，不能添加好友",kErrFriendFrinedLevelLimit="对方等级不够，不能被添加好友"}
end

function FriendData:errtips(keyvalue)
	if FriendData:errMap()[keyvalue] then
		TipsMgr.showError(FriendData:errMap()[keyvalue])
	end
end
--事件侦听
for _,v in pairs(FriendData:errMap()) do
	EventMgr.addListener( _, function()
    FriendData:errtips(_)
end )
end
--好友信息
EventMgr.addListener(EventType.FriendChatUpdate, function ( data )
	FriendData.updateFrineChatMap(data)
end )

function FriendData.updateFrineChatMap( data )
	if data then
		local count = 1
		if FriendData.frindChatMapAll:get(data) then 
			count = FriendData.frindChatMapAll:get(data) + 1 
		end
		FriendData.frindChatMapAll:add(data,count)
	end

	if data and FriendData.isFriendChatId == nil then
		local count = 1
		if FriendData.frindChatMap:get(data) then 
			count = FriendData.frindChatMap:get(data) + 1 
		end
		FriendData.frindChatMap:add(data,count)
		EventMgr.dispatch("chatUpdate")
	end
end
--所有聊天
function FriendData:getAllChatById( role_id )
	local count = 0
	if FriendData.frindChatMapAll and FriendData.frindChatMapAll:get(role_id) then
		count = FriendData.frindChatMapAll:get(role_id)
	end
	return count
end
--待处理的聊天
function FriendData:getNewChatById( role_id )
	local count = 0
	if FriendData.frindChatMap and FriendData.frindChatMap:get(role_id) then
		count = FriendData.frindChatMap:get(role_id)
	end
	return count
end

function FriendData:setFrineChatMapByRoId( role_id )
	FriendData.frindChatMap:remove(role_id)
	EventMgr.dispatch("chatUpdate")
end

function FriendData:getNewFriendChat( cur_type )
	local count = 0
	if FriendData.frindChatMap and FriendData.frindChatMap:getList() then
		for _,v in pairs(FriendData.frindChatMap:getList()) do
			if cur_type then
		 		if self:cheakType(FriendData.friend_list:get(_),cur_type) then
					count = count + v
				end
			else
				count = count + v
			end
		end
	end
	return count
end
--已请求列表清空
function FriendData:clearnAskMakeList( ... )
	FriendData.FriendAskMakeFriend = {}
end
--请求列表添加
function FriendData:addAskMakeList( ask_list )
	if ask_list and #ask_list > 0 then
		for i = 1,#ask_list do 
			local index = table.indexOf(FriendData.FriendAskMakeFriend,ask_list[i])
			if index == -1 then
				table.insert(FriendData.FriendAskMakeFriend,ask_list[i])
			end
		end
		EventMgr.dispatch( EventType.FriendRecomChange )
	end
end

function FriendData:getAwaitNum( ... )
	return self:getNewFriendChat() + self:AskedAwaitNum()
end

--点击处理
function FriendData:btnHandler( btnname,fdata )
	local blick_str = "是否将玩家名加入黑名单？[br]加入黑名单后将无法收到该玩家消息"
	LogMgr.debug( 'friend', '[点击] 目标名字 = ' .. btnname ..'\n')
	if btnname == "btn_main_add" then
		if fdata then
			fdata:showOtherWin("addui")
			--fdata:showDetailUI()
		end
	elseif btnname == "btn_main_invit" then
		--Command.run( 'frined recom' )
		if fdata then
			fdata:showOtherWin("recomui")
			Command.run( 'frined recom')
		end
		--Command.run('ui show', 'FriendRecomUI', PopUpType.NORMAL)
	elseif btnname == "btn_gift_jubao" then
		ReportPostData.sendReportMessage(fdata) ----举布
	elseif btnname == "btn_gift_black" then --移入黑名单
		showMsgBox(blick_str, function()
			Command.run( 'frined FriendBlack', fdata)
			TipsMgr.showGreen("成功拉入黑名单")
		 end)
	elseif btnname == "btn_gift_look" or btnname == "btn_black_look" then
		TipsMgr.showError("暂未开放！")
	elseif btnname == "btn_gift_challenge" or btnname == "btn_black_challenge" then
		--TipsMgr.showError("暂未开放！")
		Command.run( 'frined fightapply',fdata)
	elseif btnname == "btn_gift_chat" then --聊天
		FriendData.isFriendChatId = fdata
		local friend_data = self:getFriendDataByRoleId(fdata)
		if friend_data then
			ChatData.chatWithFriend(self:getFriendDataByRoleId(fdata))
		else
			ChatData.chatWithFriend({friend_id=fdata})
		end
		FriendData:setFrineChatMapByRoId(fdata)
	elseif btnname == "btn_review" then --换一批
		Command.run( 'frined recom')
	elseif btnname == "btn_addall" then --全部添加
		if gameData.checkLevel(15) == false then
            TipsMgr.showError("需要15级以上才可以加好友")
            return
        end
		if #self:getRecomIdList() > 0 then
			Command.run( 'frined make_all', self:getRecomIdList())
			TipsMgr.showGreen("申请成功，请等待回复")
			self:addAskMakeList(self:getRecomIdList())
		end
	elseif btnname == "btn_recom_add" then --添加好友
		if gameData.checkLevel(15) == false then
            TipsMgr.showError("需要15级以上才可以加好友")
            return
        end
		Command.run( 'frined make_group', fdata.friend_id,trans.const.kFriendGroupFriend)
		TipsMgr.showGreen("申请成功，请等待回复")

		self:addAskMakeList({fdata.friend_id})
	elseif btnname == "btn_black_delect" then --移除
		Command.run( 'frined update_group', fdata.friend_id, trans.const.kObjectDel,{} )
	elseif btnname == "btn_gift_delect" then --移除
		Command.run( 'frined update_group', fdata, trans.const.kObjectDel,{} )
		local index = table.indexOf(FriendData.friendAccesetList,fdata)
		if index ~= -1 then
			table.remove(FriendData.friendAccesetList,index)
		end
	elseif btnname == "btn_gift_add" then  --加好友
		if gameData.checkLevel(15) == false then
            TipsMgr.showError("需要15级以上才可以加好友")
            return
        end
		TipsMgr.showGreen("申请成功，请等待回复")
		Command.run( 'frined make_group', fdata,trans.const.kFriendGroupFriend)
	elseif btnname == "btn_gift_invit_legion" then--公会邀请
		TipsMgr.showError("暂未开放！")
	elseif btnname == "btn_ask_accept" then
		self:delAskeFriend( fdata.friend_id )
		Command.run( 'frined accept', fdata.friend_id)
		if table.indexOf(FriendData.friendAccesetList,fdata.friend_id) == -1 then
			table.insert(FriendData.friendAccesetList,fdata.friend_id)
		end
	elseif btnname == "btn_ask_refuse" then
		self:delAskeFriend( fdata.friend_id )
	elseif btnname == "btn_ask_black" then
		showMsgBox(blick_str, function()
	 		self:delAskeFriend( fdata.friend_id )
			Command.run( 'frined FriendBlack', fdata.friend_id)
			TipsMgr.showGreen("成功拉入黑名单")
		 end)
	elseif btnname == "btn_send" then -- 赠送物品
		local item_list = self:getSendItemlist()
		if item_list and #item_list > 0 then
			self:updateOrClearLimitSelcetData()
			EventMgr.dispatch( EventType.FriendLimitChange )
			Command.run( 'friend give', fdata,trans.const.kFriendGiveTwo,0,item_list)
		else
			TipsMgr.showError("没有选择发送物品")
		end
	elseif btnname == "btn_send1" then 
		TipsMgr.showError("CD冷却中...")
	elseif btnname == "btn_send2" then ---赠送手工活力
		Command.run( 'friend give', fdata.friend_id,trans.const.kFriendGiveOne,10,{})
		-- local acticount = CoinData.getCoinByCate(const.kCoinActiveScore)
		-- if acticount and acticount >= 10 then
		-- 	Command.run( 'friend give', fdata.friend_id,trans.const.kFriendGiveOne,10,{})
		-- else
		-- 	TipsMgr.showError("手工活力少于10（最少送10）")
		-- end
	end
end
