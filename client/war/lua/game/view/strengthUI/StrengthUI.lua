StrengthUI = {}

local function createStrengthUI( exMsg )
    if SceneMgr.isSceneName('copy') then
        EventMgr.removeListener(EventType.UserSimpleUpdate, createStrengthUI)
    end
	local teamLevel = gameData.getSimpleDataByKey("team_level")
    if teamLevel >= MainScene.MaxTeamLevel then
	    LogMgr.debug("达到战队最大等级")
        teamLevel = MainScene.MaxTeamLevel
	end
	local currStrength = gameData.getSimpleDataByKey("strength") -- 获取当前体力点
	local levelData = findLevel(teamLevel)
	local maxStrength = levelData.strength -- 体力上限
	local currBuyCount = StrengthData.getCurrBuyTimes()
	local powerData = findGlobal("strength_buy") 
	local strength = powerData.data -- 获得体力
	local vipLevel = gameData.getSimpleDataByKey("vip_level")
	-- local cost = powerData.cost.val -- 消耗钻石数
	local vipData = findLevel(vipLevel)
	local cost = vipData.strength_price or 0
	local maxBuyCount = vipData.strength_buy -- 当日购买体力次数上限

	local function buyStrengthHandler()
	    -- 获取钻石数量
	    local dim = CoinData.getCoinByCate(const.kCoinGold)

	    if cost > dim then
	    	local str = "[image=alert.png][font=ZH_9]钻石不足，请前往充值[btn=two]cancel.png:recharge.png"
	    	showMsgBox(str, function() Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL ) end)
	    elseif currBuyCount >= maxBuyCount then
	    	local str = "[image=alert.png][font=ZH_9]今日购买次数已耗完[br][font=ZH_10]升级Vip可增加购买次数"
	    	showMsgBox(str, function() Command.run('ui show', "VipPayUI", PopUpType.SPECIAL) end)
	    else
	        -- 发送购买请求
	        Command.run('buy strength')
	    end
	end


	if currStrength >= maxStrength then
		local str = "[image=more.png][font=ZH_9]体力太多，先消耗一些吧"
		showMsgBox(str)
	else
  --       if exMsg == nil then exMsg = "" end
  --       local str = "[image=diamond.png][font=ZH_9]" .. exMsg .. "是否消耗[font=ZH_11]" .. cost .."[font=ZH_9]钻石购买[font=ZH_11]" .. strength .."[font=ZH_9]体力[br][font=ZH_10](今日已购买" .. currBuyCount .. '/' .. maxBuyCount .. "次)"
  --       if exMsg ~= "" then
  --           str = "[font=ZH_5]" .. exMsg .. "是否消耗[font=ZH_11]" .. cost .."[image=diamond.png][font=ZH_5]购买[font=ZH_11]" .. strength .."[font=ZH_5]体力[br][font=ZH_10](今日已购买" .. currBuyCount .. '/' .. maxBuyCount .. "次)"
  --       end
		-- showMsgBox(str, buyStrengthHandler)
		ActTipsData.showTipsByType(const.kCoinStrength)
	end
end

function StrengthUI:lackStrength()
	local str = "[image=less.png][font=ZH_9]体力不足，是否前往购买"
	showMsgBox(str, createStrengthUI)
end

function StrengthUI.showBuyStrengt(exMsg)
    createStrengthUI(exMsg)
end

function buyStrength()
	if SceneMgr.getCurrentScene('copy') then
		if CopyData.strength == 0 then
			--副本中没有消耗体力
			createStrengthUI()
		else
			Command.run('copy commit')
			EventMgr.addListener(EventType.UserSimpleUpdate, createStrengthUI)
		end
	else
    	createStrengthUI()
    end
end