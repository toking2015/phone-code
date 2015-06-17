
require "lua/game/view/vipActivityUI/Item.lua"
local prePath = 'image/ui/VipActivityUI/'
local isShowRed = false

local VipBtn = createLayoutClass("VipBtn", ccui.Layout)

function VipBtn:ctor(lev)
	self:setSize(cc.size(106, 55))
	self:setTouchEnabled(true)
	local function showSelectBox(touch, event)
		local pos = touch:getTouchStartPos()
		LogMgr.debug('pos.x = ', pos.x, 'pos.y = ', pos.y)
		if pos.x > 790 or pos.x < 338 then
			return
		end
		LogMgr.debug("<<<<<<<<selectbox touch>>>>>>>", lev)
		EventMgr.dispatch(EventType.showSelectBox, lev)
	end
	UIMgr.addTouchEnded(self, showSelectBox)
end

function VipBtn:create(lev)
	local view = VipBtn.new(lev)
	view.lev = lev
	view:updateData(lev)
	view:showRedPoint(lev)

	return view
end

function VipBtn:updateData(lev)
	local btn_bg = ccui.ImageView:create('va_blue_btn.png', ccui.TextureResType.plistType)
	btn_bg:setTouchEnabled(false)
	self:addChild(btn_bg)
	local txt_vip = ccui.ImageView:create('va_txt_vip.png', ccui.TextureResType.plistType)
	txt_vip:setTouchEnabled(false)
	btn_bg:addChild(txt_vip)
	local vip_lev = UIFactory.getTextAtlas(btn_bg, '0123456789', prePath..'va_blue_num.png', 24, 29, '0', lev)
	vip_lev:setTouchEnabled(false)
	vip_lev:setAnchorPoint(cc.p(0, 0.5))
	local bg_size = btn_bg:getSize()
	local txt_size = txt_vip:getSize()
	local lev_size = vip_lev:getContentSize()
	btn_bg:setPosition(cc.p(bg_size.width/2, bg_size.height/2))
	local posX = (bg_size.width)/2 - lev_size.width/2
	local posY = (bg_size.height)/2
	txt_vip:setPosition(cc.p(posX, posY))
	vip_lev:setPosition(cc.p(posX + txt_size.width/2, posY))
end

function VipBtn:showRedPoint(lev)
	local isShow = VipActivityData.isCanBuyPackage(lev)
	setButtonPoint( self, isShow, cc.p(101, 50) )
end

----------------------------------------------------

VipActivity = createUIClass("VipActivityUI", prePath .. "VipActivity.ExportJson", PopWayMgr.SMALLTOBIG)

function VipActivity:ctor()
	local triangle = UIFactory.getTitleTriangle(self, 1)
	triangle:setPositionY(triangle:getPositionY() - 6)
	self:initVipBtn()
	VipActivityData.getFirstNotTake()
	self:scrollVipBtn(0,  VipActivityData.getCurSelected())
	self.cur_selected = VipActivityData.getCurSelected() -- 保存当前选中的Vip

	self.right_arrow:setPosition(cc.p(self:getPositionX()+self:getSize().width+40, visibleSize.height/2 - 50))
	self.left_arrow:setPosition(cc.p(self:getPositionX()-40, visibleSize.height/2-50))

	if not self.selected_box then
		self.selected_box = cc.Sprite:createWithSpriteFrameName("va_select_box.png")
		self.selected_box:setPosition(cc.p(self.btn_list[1]:getSize().width/2, self.btn_list[1]:getSize().height/2))
		self.selected_box:retain()
	end

	if not self.img_buy then
		local img_buy = Sprite:createWithSpriteFrameName("va_has_buy.png")
		-- img_buy:setAnchorPoint(cc.p(0, 0))
		img_buy:setPosition(self.bg1.btn_buy:getPosition())
		img_buy:setPositionY(img_buy:getPositionY() + 8)
		self.bg1:addChild(img_buy)
		self.img_buy = img_buy
		self.img_buy:retain()
	end

	self.btn_list[self.cur_selected + 1]:addChild(self.selected_box)

	self:configureTouchFunc()
	self:configureEventFunc()
	self:setBtnEnabled()

end
-- 初始化Vip按钮
function VipActivity:initVipBtn()
	local btn_list = {}
	local max_level = tonumber(findGlobal('vip_timelimitshop_max_level').data)
	for i = 0, max_level do
		LogMgr.debug("i = ", i)
		local vip_btn = VipBtn:create(i)
		table.insert(btn_list, vip_btn)
	end
	self.btn_list = btn_list
	initScrollviewWith(self.vip_bg.con_vip, btn_list, max_level+1, 6, 11, 6, 0)
end
-- 按钮触摸处理
function VipActivity:configureTouchFunc()
	local btn_buy = createScaleButton(self.bg1.btn_buy)
	local left_arrow = createScaleButton(self.left_arrow)
	local right_arrow = createScaleButton(self.right_arrow)
	local function buyPackageFunc()
    	ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'btn_buy') )
    	local _, price = VipActivityData.getPrice()
    	local dia = CoinData.getCoinByCate(const.kCoinGold)
    	local vip_lev = gameData.getSimpleDataByKey('vip_level')
    	if vip_lev < self.cur_selected then
    		local str = string.format("Vip%s级可购买", self.cur_selected)
    		TipsMgr.showError(str)
    		return
    	end
    	if price > dia then
    		local str = '[image=alert.png][font=ZH_10]钻石不足，是否购买钻石'
    		local function callfunc()
    			Command.run( 'ui show', 'VipPayUI', PopUpType.SPECIAL)
    		end
    		showMsgBox(str, callfunc)
    		return
    	end
    	if VipActivityData.isBuyPackage() then
    		TipsMgr.showError("已购买")
    	end
		Command.run( 'buy_list request', self.cur_selected, 1)
	end
	btn_buy:addTouchEnded(buyPackageFunc)

	local function arrowTouchFunc(ref, eventType)
		if ref == left_arrow then
			self.cur_selected = self.cur_selected - 1
			VipActivityData.setCurSelected(self.cur_selected)
		else
			self.cur_selected = self.cur_selected + 1
			VipActivityData.setCurSelected(self.cur_selected)
		end
	end
	left_arrow:addTouchEnded(arrowTouchFunc)
	right_arrow:addTouchEnded(arrowTouchFunc)
end
-- 事件监听处理
function VipActivity:configureEventFunc()
	self.event_list = {}
	self.event_list[EventType.showSelectBox] = function(level)
		LogMgr.debug('touch btn = ', level)
		self.cur_selected = level
		VipActivityData.setCurSelected(level)
	end

	self.event_list[EventType.changeSelect] = function(data)
		-- local index = data.curr
		self:setBtnEnabled()
		local btn = self.btn_list[self.cur_selected + 1]
		if not btn then return end
		if self.selected_box and self.selected_box:getParent() then self.selected_box:removeFromParent() end
		btn:addChild(self.selected_box)

		self:scrollVipBtn(data.prev, data.curr)
		self:updateData()
	end

	self.event_list[EventType.VipBuyPackage] = function(data) 
		local btn = self.btn_list[self.cur_selected + 1]
		btn:showRedPoint(self.cur_selected)
		self:setBuyBtn()
		self:updateRefreshTime()
	end
end

function VipActivity:scrollVipBtn(prev, curr)
	local isMove, direction = VipActivityData.isMove(prev, curr)
	if true == isMove then
		local posX = 0 --self.btn_list[curr + 1]:getPositionX()
		local sW, iW = 450, self.vip_bg.con_vip:getInnerContainerSize().width
		local percent = (posX + direction * (106 + 6) - 6)/(iW - sW)*100
		self.vip_bg.con_vip:scrollToPercentHorizontal(percent, 0.5, true)
	end
end

function VipActivity:setBtnEnabled()
	local max_level = tonumber(findGlobal('vip_timelimitshop_max_level').data)
	if self.cur_selected == 0 then
		self.left_arrow:setTouchEnabled(false)
		ProgramMgr.setGray(self.left_arrow)	
		self.right_arrow:setTouchEnabled(true)
		ProgramMgr.setNormal(self.right_arrow)	
	elseif self.cur_selected == max_level then
		self.left_arrow:setTouchEnabled(true)
		ProgramMgr.setNormal(self.left_arrow)	
		self.right_arrow:setTouchEnabled(false)
		ProgramMgr.setGray(self.right_arrow)
	else
		self.left_arrow:setTouchEnabled(true)
		ProgramMgr.setNormal(self.left_arrow)	
		self.right_arrow:setTouchEnabled(true)
		ProgramMgr.setNormal(self.right_arrow)
	end 
end

function VipActivity:onShow()
	self:updateData()
	self:updateRefreshTime()
	EventMgr.addList(self.event_list)
end

function VipActivity:updateData()
	self:setBuyBtn()
	self:updateString()
	self:updatePackage()
	-- self:updateRefreshTime()
end

function VipActivity:updatePackage()
	local item_list = VipActivityData.getPackage()
	-- local list = {}
	-- for i = 1, #item_list do
	-- 	local v = item_list[i]
	-- 	local item = Item:create(v)
	-- 	table.insert(list, item)
	-- end
	-- local len = #list
	-- initScrollviewWith(self.con_package, list, len, 13, 14, 19, 0)
	local len = #item_list
	local w, sw = len * 102 - 19, 488
	if not self.layer then
		self.layer = ccui.Layout:create()
		self.con_package:addChild(self.layer)
	end
	self.layer:removeAllChildren()
	local width = (102+19)*len-19
	self.layer:setSize(cc.size(width, 102))
	for i = 1, len do
		local v = item_list[i]
		local item = Item:create(v)
		self.layer:addChild(item)
		item:setPositionX((i-1)*(102+19))
	end
	self.layer:setPosition(cc.p((sw-width)/2, 14))
end

function VipActivity:updateString()
	local str = string.format('VIP%d', self.cur_selected)
	self.bg1.txt_limit_buy:setString(str)
	local level = gameData.getSimpleDataByKey('vip_level')
	if self.cur_selected > level then
		self.bg1.txt_limit_buy:setColor(cc.c3b(0xff, 0x00, 0x00))
	else
		self.bg1.txt_limit_buy:setColor(cc.c3b(0x5c, 0x24, 0x00))
	end
	local orgi_price, cur_price = VipActivityData.getPrice()
	self.orgi_price_num:setString(orgi_price)
	self.img_dia1:setPositionX(self.orgi_price_num:getPositionX()+self.orgi_price_num:getContentSize().width+3)
	self.curr_price_num:setString(cur_price)
	self.img_dia2:setPositionX(self.curr_price_num:getPositionX()+self.curr_price_num:getContentSize().width+3)
	self.txt_vip:setString(self.cur_selected)
	if self.cur_selected >= 10 then
		self.txt_vip:setPositionX(200)
	else
		self.txt_vip:setPositionX(210)
	end
end

function VipActivity:updateRefreshTime()
	-- local time = VipActivityData.getNextBuyTime()
	local time = VipActivityData.getNextRefreshTime()

	local function callfunc()
		if time <= 0 then 
			if self.tid then
				TimerMgr.killTimer(self.tid)
				self.tid = nil
			end
		else
			time = time - 1
		end
		local result = VipActivityData.getCDTime(time)
		self.bg1.txt_countdown:setString(result)
	end
	if not self.tid then
		self.tid = TimerMgr.startTimer(callfunc, 1)
	end
	callfunc()
end

function VipActivity:setBuyBtn()
	local is_meet = VipActivityData.isMeetVipLevel(self.cur_selected)
	if not is_meet then -- 等级不足
		self.img_buy:setVisible(false)
		self.bg1.btn_buy:setVisible(true)
		-- self.bg1.btn_buy:setTouchEnabled(false)
		-- ProgramMgr.setGray(self.bg1.btn_buy)	
	else
		local is_buy = VipActivityData.isBuyPackage()
		if is_buy then -- 已购买
			self.img_buy:setVisible(true)
			self.bg1.btn_buy:setVisible(false)
			-- ProgramMgr.setNormal(self.bg1.btn_buy)
		else
			self.img_buy:setVisible(false)
			self.bg1.btn_buy:setVisible(true)
			self.bg1.btn_buy:setTouchEnabled(true)
			-- ProgramMgr.setNormal(self.bg1.btn_buy)
		end
	end
end

-- 延迟加载比较大的图片
function VipActivity:delayInit()
	if self.hasDelayInit then
		return
	end
	self.hasDelayInit = true

	self.bg:loadTexture(prePath .. "va_bottom.png", ccui.TextureResType.localType)
end

function VipActivity:onClose()
	VipActivityData.setCurSelected(0)
	if self.tid then
		TimerMgr.killTimer(self.tid)
		self.tid = nil
	end
end

function VipActivity:dispose()
	EventMgr.removeList(self.event_list)
	if self.selected_box then
		self.selected_box:release()
		self.selected_box = nil
	end
	if self.img_buy then
		self.img_buy:release()
		self.img_buy = nil
	end
	if self.rid then
		TimerMgr.killTimer(self.rid)
		self.rid = nil
	end
end


local function showVipActivity()
	Command.run( 'goods list')
	local function getVipTimeWeek(data)
		EventMgr.removeListener(EventType.VipTimeWeek, getVipTimeWeek)
		local week = data.now_week
		local next_refresh_time = data.next_refresh_time
		VipActivityData.setTimeWeek(week)
		VipActivityData.setNextRefreshTime(next_refresh_time)
		Command.run('ui show', 'VipActivityUI', PopUpType.MODEL)
	end
	EventMgr.addListener(EventType.VipTimeWeek, getVipTimeWeek)
end
Command.bind('show VipActivity', showVipActivity)