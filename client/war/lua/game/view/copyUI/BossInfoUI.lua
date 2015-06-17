-- Create By Hujingjiang -- 
-- 副本信息 --
local prePath = "image/ui/BossInfoUI/"

-- Boss卡牌
local cardFiles = {
    [1] = "copy_card_white",
    [2] = "copy_card_green",
    [3] = "copy_card_blue",
    [4] = "copy_card_purple",
    [5] = "copy_card_purple"
}
CopyBossCard = class("CopyBossCard", function()
    return getLayout(prePath .. "BossCardItem.ExportJson")
end)
function CopyBossCard:ctor()
    local size = self:getSize()
    self.card_bg = ccui.ImageView:create()--Sprite:create(prePath .. "card/copy_card_white.png")
    self.card_bg:setTouchEnabled(false)
    self.card_bg:setPosition(size.width / 2, size.height / 2)
    self:addChild(self.card_bg)

    self.image = ccui.ImageView:create()
    self.image:setTouchEnabled(false)
    self.image:setPosition(size.width / 2, size.height / 2)
    self:addChild(self.image)
    self.image:setScale(0.3)
    -- self.model = nil

    self.img_bright:setVisible(false)
end
function CopyBossCard:hideSome()
    self.img_name_bg:setVisible(false)
    self.txt_boss_name:setVisible(false)
end
function CopyBossCard:loadDefault()
    self.card_bg:loadTexture(prePath .. "card/" .. cardFiles[1] .. ".png", ccui.TextureResType.localType)
end
function CopyBossCard:setData(data)
    self.data = data
    if nil ~= data then
        local starNum, monster = data.starNum, data.monster
        local quality = monster.quality
        self.card_bg:loadTexture(prePath .. "card/" .. cardFiles[quality] .. ".png", ccui.TextureResType.localType)

        for i = 1, starNum do
            local star = self["img_star_" .. i]
            star:loadTexture("boss_star_light.png", ccui.TextureResType.plistType)
        end

        for i = starNum + 1, 3 do
            local star = self["img_star_" .. i]
            star:loadTexture("boss_star_dark.png", ccui.TextureResType.plistType)
        end

        self.txt_boss_name:setString(monster.name)

        local url = MonsterData.getPhotoUrl(monster)
        -- 加载图片
        self.image:loadTexture(url, ccui.TextureResType.localType)

    else
        self:loadDefault()
    end
end
function CopyBossCard:setSelected(bln)
    self.img_bright:setVisible(bln)
end
function CopyBossCard:dispose()
end
function CopyBossCard:create(data)
    local card = CopyBossCard:new()
    card:setData(data)
    return card
end

BossInfoUI = createUIClass("BossInfoUI", prePath .. "BossInfoUI.ExportJson", PopWayMgr.SMALLTOBIG)

function BossInfoUI:ctor()
    self.isFight = false
    self.clickTime = 0
	self.data = nil
	self.saoType = const.kCopyMopupTypeNormal
	self.event_list = {}
	-- 添加UI背景
	local bg = Sprite:create(prePath .. "copy_boss_bg.png")
	bg:setAnchorPoint(0, 0)
	self:addChild(bg)
	-- 默认精英图标隐藏
	self.img_title:setVisible(false)
	self.txt_desc:setString("")
    self.con_info_sao.txt_quan_num:setString("0")
    self.con_info_times.txt_spend:setString("0")
    self.con_info_times.txt_times:setString("0/0")
    -- 添加boss卡牌
	local card = CopyBossCard:create()
	card:hideSome()
	self.con_card:addChild(card)
	self.card = card
	-- 进度条
	self.con_progress:setVisible(false)
	-- 扫荡按钮
	local con_sao = self.con_info_sao.con_sao
	con_sao.btn_sao_1:setVisible(false)
	con_sao.btn_sao_10:setVisible(false)
	createScaleButton(con_sao.btn_sao_1)
	createScaleButton(con_sao.btn_sao_10)
	local function doSaoFunc(ref, eventType)
		local leftTimes = SaoDangData.getLeftSaoTimes(self.data.type, self.data.boss_id)
		if leftTimes == 0 then
            self:resetBossTimes("当前次数不足，")
			return
		end

		local itemNum = self:getSaoQuanNum()
		local times = 1
		if ref == con_sao.btn_sao_10 then
			times = tonumber(ref.atl_times:getString())

			if gameData.user.simple.vip_level < 4 then
				showMsgBox("vip4以上可用[btn=one]")
				return
			end
		end
		
		SaoDangData.saoDangItemInit()
		local monster = findMonster(self.data.boss_id)
		local useStrength = times * monster.strength
		
		local function saoDangFunc()
			if ref == con_sao.btn_sao_10 then
				ActionMgr.save( 'UI', 'BossInfoUI click btn_sao_10' )
			else
				ActionMgr.save( 'UI', 'BossInfoUI click btn_sao_1' )
			end
			Command.run("copy saodang", self.data.type, self.data.boss_id, times)
			Command.run('SaoDangUI show')
		end
        
        if false == CoinData.checkLackCoin(const.kCoinStrength, useStrength) then
    		local num = times - itemNum
    		if num > 0 then
    			local function spendQuan()
    				if false == CoinData.isNeedBuyGold(num) then
    					saoDangFunc()
    				end
    			end
    			showMsgBox("扫荡券不足，是否消耗" .. num .. "钻石扫荡" .. num .. "次？", spendQuan)
    		else
    			saoDangFunc()
    		end
		end
	end
	con_sao.btn_sao_1:addTouchEnded(doSaoFunc)
	con_sao.btn_sao_10:addTouchEnded(doSaoFunc)

	-- 攻打按钮
	createScaleButton(self.btn_fight)
	function self.fightFunc()
        local data = self.data

        local monster = findMonster(self.data.boss_id)
        if data.type == const.kCopyMopupTypeElite 
        	and CoinData.checkLackCoin(const.kCoinStrength, monster.strength, 0) 
        then
			-- showMsgBox("体力不足不能进入关卡战斗[btn=one]")
			return
		end

		CopyData.isFightBoss = false
    	CopyData.fightBossType = data.type
        if data.type == const.kCopyMopupTypeNormal and true ~= CopyData.checkClearance(data.copy_id) then
        	local u_copy = CopyData.user.copy
        	if u_copy.status == 2 then
        	    ActionMgr.save( 'UI', 'BossInfoUI click btn_fight CopyMgr close' )
                Command.run("copy close", false)
        	elseif #u_copy.chunk > 1 then
	            CopyRewardData.prePosi = gameData.user.copy.posi + 1
	            ActionMgr.save( 'UI', 'BossInfoUI click btn_fight copy scene enter' )
	            Command.run( 'scene enter', 'copy' )
	        else
        		if CoinData.checkLackCoin(const.kCoinStrength, monster.strength, 0) 
		        then
					-- showMsgBox("体力不足不能进入关卡战斗[btn=one]")
					return
				end
	        	-- self:fightNormalMonster()

	            ActionMgr.save( 'UI', 'BossInfoUI click btn_fight CopyMgr directFight' )
	        	Command.run("CopyMgr directFight", false)
	        end
        else
    		local leftTimes = SaoDangData.getLeftSaoTimes(data.type, data.boss_id)
    		if leftTimes == 0 then
				self:resetBossTimes("次数不足", "当前次数不足")
    			return
    		end
    
    		local monster = findMonster(data.boss_id)
    		local useStrength = monster.strength
    		if false == CoinData.checkLackCoin(const.kCoinStrength, useStrength) then
            	self.isFight = true
    			CopyData.isFightBoss = true
    			CopyData.fightBossID = data.boss_id
    			CopyData.fightBossCopyId = data.copy_id
	            ActionMgr.save( 'UI', 'BossInfoUI click btn_fight CopyMgr.showBossFormation' )
    			CopyMgr.showBossFormation()
    		end
		end
        PopMgr.removeWindow(self)
	end
	self.btn_fight:addTouchEnded(self.fightFunc)

	-- 重置次数按钮
    createScaleButton(self.con_info_times.btn_add_times)
	local function addSaoTimes()
		local data = self.data
		ActionMgr.save( 'UI', 'BossInfoUI click btn_add_times type:' .. data.type .. "  boss_id:" .. data.boss_id)
		local resetTimes = SaoDangData.getLeftSaoTimes(data.type, data.boss_id)
		if resetTimes > 0 then
			showConfirmMsgBox("当前次数不为0！")
		else
			if gameData.user.simple.vip_level == 0 then
				showConfirmMsgBox("当前vip等级不足")
			else
				self:resetBossTimes()
			end
		end
	end
    self.con_info_times.btn_add_times:addTouchEnded(addSaoTimes)
end
-- 重置副本次数
function BossInfoUI:resetBossTimes(msg, noMsg)
	local data = self.data
	local resetTimes = SaoDangData.getTotalResetTimes(data.type)
	local curTimes = SaoDangData.getCurResetTimes(data.type, data.boss_id)
	if resetTimes - curTimes > 0 then
		local lvData = findLevel(curTimes)
		local price = lvData.copy_normal_reset_price
		if data.type == const.kCopyMopupTypeElite then
			price = lvData.copy_elite_reset_price
		end
		if false == CoinData.isNeedBuyGold(price) then
			if nil == msg then msg = "" end
			local str = "[font=ZH_9]是否消耗[font=ZH_11]" .. price .."[image=diamond.png][font=ZH_9]重置挑战次数"
			str = str .. "[br][font=ZH_10](今日已重置" .. curTimes .. "/" .. resetTimes .. "次)"
			-- str = msg .. "是否花费" .. price .. "钻石重置次数？"
			showMsgBox(str, function() 
				Command.run("copy resetBoss", data.type, data.boss_id)
			end)
		end
	else
		if nil == noMsg then noMsg = "当前Boss的重置次数已经用完" end
		showConfirmMsgBox(noMsg)
	end
end
-- 获取扫荡券
function BossInfoUI:getSaoQuanNum()
	local itemNum = ItemData.getItemCount(35, const.kBagFuncCommon)
	return itemNum
end
-- 设置UI
function BossInfoUI:setData(data)
	self.data = data
	self.img_title:setVisible(self.data.type == const.kCopyMopupTypeElite) 
	local starNum = CopyData.getBossStars(data.boss_id, data.type)
	local monster = findMonster(data.boss_id)
	
	-- 显示卡牌信息
	local cardData = {starNum = starNum, monster = monster}
	self.card:setData(cardData)
	-- 显示副本描述
	local copy_id = data.copy_id--math.floor(data.boss_id / 1000) * 10 + 1
	self.copy = findCopy(copy_id)
	self.txt_desc:setString(self.copy.desc)
	
	self:updateCopy()
	-- 是否需预加载
	if true == self:needLoadCache() then
        local list = FormationData.getMonsterFormation(monster.id)
        for _, v in pairs(list) do
            LoadMgr.loadFightModelAsync(v.guid, v.attr, 5)
        end
	end
end
-- 是否需预加载（若小于3星，则需预加载）
function BossInfoUI:needLoadCache()
    local data = self.data
    local starNum = CopyData.getBossStars(data.boss_id, data.type)
    if starNum < 3 then
        if data.type == const.kCopyMopupTypeNormal then
            if true ~= CopyData.checkClearance(data.copy_id) then
                return false
            end
        end
        return true
    end
    return false
end
-- 更新UI内容
function BossInfoUI:updateCopy()
	local data = self.data
	local starNum = CopyData.getBossStars(data.boss_id, data.type)
	local monster = findMonster(data.boss_id)
	-- 显示扫荡信息
	local con_sao = self.con_info_sao.con_sao
	local bln = (starNum == 3)
	con_sao.label_cond:setVisible(not bln)
	con_sao.btn_sao_1:setVisible(bln)
	con_sao.btn_sao_10:setVisible(bln)
	-- 显示扫荡券信息
	local itemNum = self:getSaoQuanNum()
	self.con_info_sao.txt_quan_num:setString(itemNum)
	-- 显示消耗体力信息
    self.con_info_times.txt_spend:setString(monster.strength)
	-- 显示扫荡次数
	local stype = data.type--const.kCopyMopupTypeNormal -- kCopyMopupTypeElite
	local leftTimes = SaoDangData.getLeftSaoTimes(stype, data.boss_id)
	local totalTimes = SaoDangData.getTotalSaoTimes(stype)
	self.con_info_times.txt_times:setString( leftTimes .. "/" .. totalTimes)

	if leftTimes == 0 then
	   leftTimes = 20
	   if self.data.type == const.kCopyMopupTypeElite then 
	       leftTimes = 3
	   end
	end
	local minTimes = math.min(10, leftTimes)
	con_sao.btn_sao_10.atl_times:setString(minTimes)
	-- 小于10级时
	if gameData.user.simple.team_level < 10 then
        -- self.con_info_sao:setVisible(itemNum > 0)
        self.con_info_sao.txt_quan_num:setVisible(false)
        self.con_info_sao.label_quan_num:setVisible(false)
        self.con_info_sao.img_quan:setVisible(false)
		con_sao.btn_sao_1:setVisible(false)
		con_sao.btn_sao_10:setVisible(false)
    else
        self.con_info_sao.txt_quan_num:setVisible(true)
        self.con_info_sao.label_quan_num:setVisible(true)
        self.con_info_sao.img_quan:setVisible(true)
    end
    --没有扫荡卷
    if 0 == itemNum then
        con_sao.btn_sao_10.atl_times:setString(minTimes)
    else
        con_sao.btn_sao_10.atl_times:setString(math.min(minTimes, itemNum))
	end
	
	local bln = (data.type == const.kCopyMopupTypeNormal 
		and true ~= CopyData.checkClearance(data.copy_id))
	-- if bln == true then
	-- 	local u_copy = CopyData.user.copy
	-- 	if data.copy_id == u_copy.copy_id and #u_copy.chunk == 1 then
	-- 		bln = false
	-- 	end
	-- end

	local jcopy = findCopy(data.copy_id)
	if jcopy then
		if jcopy.chunk and 0 ~= #jcopy.chunk then
			self.con_progress:setVisible(bln)
		else
			self.con_progress:setVisible(false)
		end
	end

	-- self.con_progress:setVisible(bln)
    self.con_info_times:setVisible(not bln) 
	if bln == true then
        local cur, max = CopyData.getCopyGuage(data.copy_id)

        local percent = math.min(100, math.floor( cur * 100 / max ))
        self.con_progress.progress:setPercent(percent)

        self.con_progress.label_percent:setString( tostring(percent) .. '%' )
	end
end
-- onShow方法
function BossInfoUI:onShow()
	self.event_list[EventType.UpdateCopyBoss] = function()
        self:updateCopy()
    end
	self.event_list[EventType.SelectNormalBoss] = function()
        -- PopMgr.removeWindow(self)
        self.saoType = const.kCopyMopupTypeNormal
    end
	self.event_list[EventType.SelectEliteBoss] = function()
        -- PopMgr.removeWindow(self)
        self.saoType = const.kCopyMopupTypeElite
    end

    self.event_list[EventType.ShowWinName] = function(winName)
    	if winName == 'GutUI' then
    		PopMgr.removeWindow(self)
    	end
	end
    self.event_list[EventType.HideWinName] = function(winName)
    	if winName == 'GutUI' then
    		PopMgr.removeWindow(self)
    	end
	end	
    EventMgr.addList(self.event_list)
    EventMgr.dispatch(EventType.ShowBossInfo)
end

function BossInfoUI:onClose()
	if false == self.isFight then
		LoadMgr.clearAsyncCache()
	end
	self.isFight = false
	EventMgr.removeList(self.event_list)
	EventMgr.dispatch(EventType.CloseBossInfo)
end

Command.bind( 'BossInfoUI show', function(data, isNeedAnimate)
	if nil == isNeedAnimate then isNeedAnimate = true end
	local win = PopMgr.getWindow("BossInfoUI")
	if nil == win then
    	win = PopMgr.popUpWindow("BossInfoUI", false, PopUpType.SPECIAL, true, 0, isNeedAnimate)
	    local size = win:getSize()
	    win:setPosition(visibleSize.width / 2, visibleSize.height / 2 + 50)
    end
    win:setData(data)
    CopyMgr.bossData = data
end )

Command.bind("BossInfoUI showWith", function(id, type)
	local data = CopyData.getCopyBoss(id, type)
    Command.run("BossInfoUI show", data)
end)