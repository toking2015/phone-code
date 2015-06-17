-- Create By Hujingjiang --
local const = trans.const

local prePath = "image/ui/SaoDangUI/"

SdBoxItem = class("SdBoxItem", function()
	return getLayout(prePath .. "SaoDangBoxItem.ExportJson")
end)

function SdBoxItem:ctor()
	self.txt_num:setString("")
end

function SdBoxItem:create(data)
	local boxItem = SdBoxItem:new()
	boxItem:setData(data)
	return boxItem
end
function SdBoxItem:setData(item)
	if nil == item then return end
	if const.kCoinMoney == item.cate then
		local url = CoinData.getCoinUrl(item.cate)
	    if url == "" then LogMgr.debug("路径不存在：" .. debug.dump(item)) end
	    local rType = ccui.TextureResType.localType
	    local icon = ccui.ImageView:create(url, rType)
	    self.img_item:addChild(icon, 1)
	    local size = self.img_item:getSize()
	    icon:setPosition(cc.p(size.width / 2, size.height / 2))
	    self.txt_num:setString(item.val)
		return
	
	elseif const.kCoinGlyph == item.cate then
		local icon = TotemData.getGlyphObject(item.objid, "SaoDangUI", self.img_item, 50, 50)
		return

	elseif const.kCoinSoldier == item.cate then
		local jSoldier = findSoldier(item.objid)
		if jSoldier then
			local icon = ccui.ImageView:create(SoldierData.getAvatarUrl(jSoldier), ccui.TextureResType.localType)
			icon:setPosition(50, 50)
			self.img_item:addChild(icon)
		end
		return
	end

	local url = CopyRewardData.getRewardIconUrl(item)
    if url == "" then LogMgr.debug("路径不存在：" .. debug.dump(item)) end
    local rType = ccui.TextureResType.plistType
    if item.cate == 4 or item.cate == 13 then
        rType = ccui.TextureResType.localType
    end
    local icon = ccui.ImageView:create(url, rType)
    self.img_item:addChild(icon, 1)
    local size = self.img_item:getSize()
    icon:setPosition(cc.p(size.width / 2, size.height / 2))
    self.txt_num:setString(item.val)
    if item.cate == 4 then
        local obj = findItem(item.objid)
        local quality = obj.quality
        local bgUrl = ItemData.getItemBgUrl(quality)
        local bg = ccui.ImageView:create(bgUrl, ccui.TextureResType.localType)
        bg:setPosition(cc.p(size.width / 2, size.height / 2))
        self.img_item:addChild(bg)
        local color = ItemData.getItemColor(quality)
        setButtonPoint(icon, SoldierData.checkSoldiersBooks(item.objid), nil, nil, "image/ui/NCopyUI/title/copy_tips.png")

        self.txt_num:setString(SaoDangData.getSaoDangItem(item.objid, item.val))
    end
end

SdResultItem = class("SdResultItem", function()
	return getLayout(prePath .. "SaoDangItem.ExportJson")
end)

function SdResultItem:ctor(index, data)
	self.con_items.atl_times:setString(index)
	self.panel_coin.atl_exp:setString("0")
	self.panel_coin.atl_coin:setString("0")
	self.panel_coin.atl_solution:setString("0")
	self.list = {}
	if nil ~= data then
		self:setData(data)
	end
end

function SdResultItem:setTrialData(id, trial_val)
	local json = findTrial(id)
	if not json then
		return
	end

	self.panel_coin:setVisible(false)
	self.text:setString("治疗与伤害量：" .. trial_val)
end

function SdResultItem:setTombData(data)
	self.panel_coin.img_icon_exp:setVisible(false)
	self.panel_coin.img_icon_solution:setVisible(false)
	self.panel_coin.img_icon_coin:setVisible(false)
	self.panel_coin.atl_exp:setVisible(false)
	self.panel_coin.atl_coin:setVisible(false)
	self.panel_coin.atl_solution:setVisible(false)
	local i = 0
	for _, v in pairs(data) do
		i = i + 1
		local item = SdBoxItem:create(v)
		item:setPosition(10 + ((i - 1) % 3) * 160, math.floor((i - 1) / 3) * -130)
		self.con_items:addChild(item)
		table.insert(self.list, item)
	end

	for _, item in pairs(self.list) do
		item:setPositionY(item:getPositionY() + math.floor((i - 1) / 3) * 130)
	end

	self.con_items.atl_times:setPositionY(self.con_items.atl_times:getPositionY() + math.floor((i - 1) / 3) * 130)
	self.con_items.img_times_bg:setPositionY(self.con_items.img_times_bg:getPositionY() + math.floor((i - 1) / 3) * 130)
	self.con_items.img_times_txt:setPositionY(self.con_items.img_times_txt:getPositionY() + math.floor((i - 1) / 3) * 130)

	self:setSize(cc.size(500, 210 + math.floor((i - 1) / 3) * 130))
	LogMgr.debug(self:getSize().height)
end

function SdResultItem:setData(data)
	local i = 0
	for _, v in pairs(data) do
		if v.cate == const.kCoinItem then
			i = i + 1
			local item = SdBoxItem:create(v)
			item:setPosition(10 + ((i - 1) % 3) * 160, 6 - math.floor((i - 1) / 3) * 130)
			self.con_items:addChild(item)
			table.insert(self.list, item)
		elseif v.cate == const.kCoinTeamXp then
			self.panel_coin.atl_exp:setString(v.val)
		elseif v.cate == const.kCoinMoney then
			self.panel_coin.atl_coin:setString(v.val)
		elseif v.cate == const.kCoinWater then
			self.panel_coin.atl_solution:setString(v.val)
		end
	end

	for _, item in pairs(self.list) do
		item:setPositionY(item:getPositionY() + math.floor((i - 1) / 3) * 130)
	end

	self.con_items.atl_times:setPositionY(self.con_items.atl_times:getPositionY() + math.floor((i - 1) / 3) * 130)
	self.con_items.img_times_bg:setPositionY(self.con_items.img_times_bg:getPositionY() + math.floor((i - 1) / 3) * 130)
	self.con_items.img_times_txt:setPositionY(self.con_items.img_times_txt:getPositionY() + math.floor((i - 1) / 3) * 130)

	self:setSize(cc.size(500, 210 + math.floor((i - 1) / 3) * 130))
	LogMgr.debug(self:getSize().height)
end

local url = prePath .. "SaoDangUI.ExportJson"
SaoDangUI = createUIClass("SaoDangUI", url, PopWayMgr.SMALLTOBIG)

function SaoDangUI:ctor()
	local btn_close = createScaleButton(self.btn_close)
	local function closeHandler()
		ActionMgr.save( 'UI', 'SaoDangUI click btn_close')
		PopMgr.removeWindowByName("SaoDangUI")
	end
	btn_close:addTouchEnded(closeHandler)
	btn_close:setVisible(false)

	self.level = gameData.getSimpleDataByKey('team_level')
    self.currExp = gameData.getSimpleDataByKey('team_xp')
end

function SaoDangUI:onShow()
	EventMgr.addListener(EventType.ShowResultList, self.showResult, self)
	EventMgr.addListener(EventType.ShowTomb, self.showTomb, self)
	EventMgr.addListener(EventType.ShowTrial, self.showTrial, self)
--	local list = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10} 
--    EventMgr.dispatch(EventType.ShowResultList, list)
end

function SaoDangUI:onClose()
	EventMgr.removeListener(EventType.ShowResultList, self.showResult)
	EventMgr.removeListener(EventType.ShowTomb, self.showTomb)
	EventMgr.removeListener(EventType.ShowTrial, self.showTrial)
end

function SaoDangUI:showTrial(msg)
	local list = {}
	local len = 1
	local item = SdResultItem.new(1)
	table.insert(list, item)
	item:setVisible(false)
	item:setTrialData(msg.id, msg.trial_val)
	local _height = item:getSize().height

	initScrollviewWith(self.scr_result, list, 1, 0, 0, 0, 2)
    if len > 0 then
        local i = 0
        local _y = 0
        local function callback()
            i = i + 1
            if i <= len then
                local item = list[i]
                item:setVisible(true)
                local sc_size = self.scr_result:getSize()
                local sc_con = self.scr_result:getInnerContainer()
                local item_size = item:getSize()
                LogMgr.debug(item_size.height)
                _y = _y + item_size.height
                local tmp_h = item_size.height * i
                if tmp_h > sc_size.height then
					a_moveto(sc_con, 0.3, cc.p(0, -(_height - _y)))
                end
                if i == len then
                    self.btn_close:setVisible(true)
                end
            end
        end
        a_repeate(self, callback, 0.5, len + 1)
--        performWithDelay(self.btn_close, function() self.btn_close:setVisible(true) end, (len + 1) * 0.5)
    end
end

function SaoDangUI:showTomb(result)
	local list = {}
	local len = #result

	if 0 == len then
		self.btn_close:setVisible(true)
	end

	local _height = 0
	for i = 1, len do
		local item = SdResultItem.new(i)
		table.insert(list, item)
		item:setVisible(false)
		item:setTombData(result[i])
		-- self.scr_result:addChild(item)

		_height = _height + item:getSize().height
	end
	-- scrollview, list, rowNum, off_x, off_y, space_x, space_y
	initScrollviewWith(self.scr_result, list, 1, 0, 0, 0, 2)
    if len > 0 then
        local i = 0
        local _y = 0
        local function callback()
            i = i + 1
            if i <= len then
                local item = list[i]
                item:setVisible(true)
                local sc_size = self.scr_result:getSize()
                local sc_con = self.scr_result:getInnerContainer()
                local item_size = item:getSize()
                LogMgr.debug(item_size.height)
                _y = _y + item_size.height
                local tmp_h = item_size.height * i
                if tmp_h > sc_size.height then
					a_moveto(sc_con, 0.3, cc.p(0, -(_height - _y)))
                end
                if i == len then
                    self.btn_close:setVisible(true)
                end
            end
        end
        a_repeate(self, callback, 0.5, len + 1)
--        performWithDelay(self.btn_close, function() self.btn_close:setVisible(true) end, (len + 1) * 0.5)
    end
--    ccui.ScrollView:jumpToPercentVertical(float)
--	self.btn_close:setVisible(true)
end

function SaoDangUI:showResult(result)
	local list = {}
	local len = #result
	local expResult = 0

	if 0 == len then
		self.btn_close:setVisible(true)
	end

	local _height = 0
	for i = 1, len do
		local item = SdResultItem.new(i, result[i])
		item:setVisible(false)
		table.insert(list, item)
		-- self.scr_result:addChild(item)

		_height = _height + item:getSize().height
        local resultList = result[i]
		for _, v in pairs(resultList) do
			if v.cate == const.kCoinTeamXp then
				expResult = expResult + v.val
			end
		end
	end
	-- scrollview, list, rowNum, off_x, off_y, space_x, space_y
	initScrollviewWith(self.scr_result, list, 1, 0, 0, 0, 2)
    if len > 0 then
        local i = 0
        local _y = 0
        local function callback()
            i = i + 1
            if i <= len then
                local item = list[i]
                item:setVisible(true)
                local sc_size = self.scr_result:getSize()
                local sc_con = self.scr_result:getInnerContainer()
                local item_size = item:getSize()
                LogMgr.debug(item_size.height)
                _y = _y + item_size.height
                local tmp_h = item_size.height * i
                if tmp_h > sc_size.height then
					a_moveto(sc_con, 0.3, cc.p(0, -(_height - _y)))
                end
                if i == len then
                    self.btn_close:setVisible(true)
                end
            end
        end
        a_repeate(self, callback, 0.5, len + 1)
--        performWithDelay(self.btn_close, function() self.btn_close:setVisible(true) end, (len + 1) * 0.5)
    end
--    ccui.ScrollView:jumpToPercentVertical(float)
--	self.btn_close:setVisible(true)


    if expResult ~= 0 then
    	LogMgr.debug('SaoDangUI expBar>>>>>>>>>>')
		local level = self.level
        local currExp = self.currExp
        EventMgr.dispatch(EventType.showExpBarUI, {val = expResult, sumExp = currExp+expResult, level = level})
	    -- local expBar = SweepExpBar:createSweepExpBar()
	    -- expBar:setTouchEnabled(false)
	    -- expBar:setAnchorPoint(cc.p(0.5, 0.5))
	    -- self:addChild(expBar)
	    -- expBar:setPosition(visibleSize.width/2 - expBar:getSize().width/2, visibleSize.height/2 + 200)
	    -- expBar:updateSweepExpBar( currExp, expResult, level, 0.5)
	end
end

Command.bind( 'SaoDangUI show', function()
    local win = PopMgr.popUpWindow("SaoDangUI", true, PopUpType.MODEL, true)
    -- win:showUI(area_id)
end )
