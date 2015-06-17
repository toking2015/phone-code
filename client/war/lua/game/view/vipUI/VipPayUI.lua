require "lua/game/view/vipUI/PayRender.lua"

local Layer = {
	PAY = 1,
	RIGHTS = 2
}
local prePath = "image/ui/VipUI/"
-- local curLevel = 0


-----------------------------------------------------------------------------

--创建vip购买页面
VipPayUI = createUIClass("VipPayUI", prePath .. "VipPayUI.ExportJson", PopWayMgr.SMALLTOBIG)
VipPayUI.sceneName = "common"

function VipPayUI:ctor()
    self:configListener()
    self.switch = Layer.PAY
    self.isUpRoleTopView = true
    self.sLevel = 1 -- 查看特权的等级
end

function VipPayUI:addVipArmature()
	if self.hasAddArmature then
		return
	end
	self.hasAddArmature = true
	local img_badge = self.img_bg.img_badge
	local armPath = "image/armature/ui/VipPayUI/"
	local effect_1 = ArmatureSprite:addArmatureEx(armPath, "vip-tx-01", self.winName)
	local effect_2 = ArmatureSprite:addArmatureEx(armPath, "vip-tx-02", self.winName)

	local bSize = img_badge:getSize()
	local btnSize = self.btn_switch:getSize()
	effect_1:setPosition(cc.p(bSize.width/2, bSize.height/2 + 11))
	effect_2:setPosition(cc.p(btnSize.width/2, btnSize.height/2))

	img_badge:addChild(effect_1)
	self.btn_switch:addChild(effect_2)
end

function VipPayUI:configListener()
	local view = self
	-- -- 添加按钮属性
	local btn_switch = createScaleButton(view.btn_switch)
    local btn_prev = createScaleButton(view.right_layer.btn_prev)
    local btn_next = createScaleButton(view.right_layer.btn_next)

	local function rightHandler(ref, eventType)
        ActionMgr.save( 'UI', 'VipPayUI click btn_switch' )
		LogMgr.log( 'debug',"click right.......")
		if Layer.PAY == self.switch then
			self.switch = Layer.RIGHTS
		else
			self.switch = Layer.PAY
		end
		self:refresh()
	end
	btn_switch:addTouchEnded(rightHandler)

	local function pageClicHandler(ref, eventType)
        if ref == btn_prev then
        	ActionMgr.save( 'UI', 'VipPayUI click btn_prev' )
            -- curLevel = curLevel - 1
            self.sLevel = self.sLevel - 1
        elseif ref == btn_next then
        	ActionMgr.save( 'UI', 'VipPayUI click btn_next' )
            -- curLevel = curLevel + 1
            self.sLevel = self.sLevel + 1
        end
        view:showRightContent(self.sLevel)
        local cur_xp = findLevel(self.sLevel).vip_xp
        local vipXp = gameData.getSimpleDataByKey("vip_xp")
        local needExp = cur_xp - vipXp
        -- setUpgradeCondition(self.txtObjList, needExp, curLevel)
        self:showUpgradeCondition()
    end
    btn_prev:addTouchEnded(pageClicHandler)
    btn_next:addTouchEnded(pageClicHandler)
    -- UIMgr.addTouchEnded(btn_prev, pageClicHandler)
    -- UIMgr.addTouchEnded(btn_next, pageClicHandler)
end

function VipPayUI:showUpgradeCondition()
	local level = gameData.getSimpleDataByKey('vip_level')  -- 当前Vip等级
	local maxExp, needExp, needDay, needRMB = 0, 0, 0, 0
	if level > self.sLevel then return end
	if 0 == level and 1 ~= self.sLevel or self.sLevel > level and level ~= 0 then
		for i = 0, self.sLevel - 1 do
			maxExp = maxExp + findLevel(i).vip_xp
		end
		needExp = maxExp
		self.txtObjList[1]:setString("累计充值")
    	self.txtObjList[6]:setString('VIP' .. self.sLevel)
    	if level >= 20 then
    		self.txtObjList[6]:setString('VIP' .. 20)
    	end
	elseif 0 == level and 1 == self.sLevel or self.sLevel == level and level ~= 0 then
		self.txtObjList[1]:setString("再充值")
		self.txtObjList[6]:setString('VIP' .. self.sLevel)
		local curExp = gameData.getSimpleDataByKey('vip_xp')
		maxExp = findLevel(self.sLevel - 1).vip_xp
		if self.sLevel == level then
			self.txtObjList[6]:setString('VIP' .. self.sLevel + 1)
			maxExp = findLevel(self.sLevel).vip_xp
		end
    	if level >= 20 then
    		self.txtObjList[6]:setString('VIP' .. 20)
    	end
		needExp = maxExp - curExp
	end
	needRMB = needExp / 10
	needDay = math.ceil(needExp / 100)
    self.txtObjList[2]:setString("" .. needRMB .. '元')
    self.txtObjList[4]:setString('' .. needDay .. '天')
	if self.sLevel <= 11 then
		-- 当前等级<=11时每天登陆增加经验
		self.txtObjList[3]:setVisible(true)
        self.txtObjList[4]:setVisible(true)
    else
        self.txtObjList[3]:setVisible(false)
        self.txtObjList[4]:setVisible(false)
	end

    self:setTitelPos(self.sLevel)
    -- self:setBtnEnabled(self.sLevel, level)
end

local function setVipExpBar(progress, cur, max)
	cur = cur == nil or 0 and cur
	max = max == nil or 0 and max

	progress:setPercent(cur*100/max)
end

function VipPayUI:onShow()
	performNextFrame(self, self.addVipArmature, self)
	EventMgr.addListener(EventType.CheckPayOK, self.refresh, self)
	self:refresh(true)
end

function VipPayUI:onClose()
	EventMgr.removeListener(EventType.CheckPayOK, self.refresh)
end

function VipPayUI:dispose()
	PayRender:dispose()
end


function VipPayUI:refresh(delayLayout)
	local level = gameData.getSimpleDataByKey("vip_level")
	if level >= 20 then
	    LogMgr.debug("达到vip最大等级")
		level = 20
	end
	-- curLevel = level
	self.sLevel = level == 0 and 1 or level
	-- 更新VipTitle信息
	self:updateVipUpPanel(level)
	-- 更新购买,特权列表层
	local function updateVipLayout()
		self:updateVipLayout(level)
	end
	if delayLayout then
		performNextFrame(self, updateVipLayout)
	else
		updateVipLayout()
	end
end

function VipPayUI:updateVipUpPanel(level)
    local cur_xp = findLevel(level).vip_xp
	local cur_vip_xp = gameData.getSimpleDataByKey("vip_xp")
	local needExp = cur_xp - cur_vip_xp

	-- 更新徽章上Vip等级
	self.vip_num:setString('' .. level)
	-- 更新进度条
	setVipExpBar(self.exp_bar, cur_vip_xp, cur_xp)
	-- 更新Vip升级条件
	self.txtObjList = {self.txt_first, self.txt_rmb, self.txt_mid, self.txt_day, self.txt_last, self.txt_vip_lev}
	-- setUpgradeCondition(self.txtObjList, needExp, level)
	self:updateVipUpgradeTitle(needExp, level)
end

function VipPayUI:updateVipUpgradeTitle(needExp, level)
	local needRMB = needExp / 10
    local needDay = math.ceil(needExp / 100) -- 升级需要的登录的天数
	self.txtObjList[1]:setString("再充值")
    self.txtObjList[2]:setString("" .. needRMB .. '元')
    self.txtObjList[4]:setString('' .. needDay .. '天')
    self.txtObjList[6]:setString('VIP' .. level + 1)
	if level >= 20 then
		self.txtObjList[2]:setString(0 .. '元')
		self.txtObjList[6]:setString('VIP' .. 20)
	end
    if level <= 11 then
    	self.txtObjList[3]:setVisible(true)
        self.txtObjList[4]:setVisible(true)
    else
        self.txtObjList[3]:setVisible(false)
        self.txtObjList[4]:setVisible(false)
    end

    self:setTitelPos(level)
end

function VipPayUI:setTitelPos(level)
	-- 设置升级条件文本为准
	local posX = self.txtObjList[1]:getPositionX()
	local width1 = self.txtObjList[1]:getContentSize().width
	local width2 = self.txtObjList[2]:getContentSize().width
	local width3 = self.txtObjList[3]:getContentSize().width
	local width4 = self.txtObjList[4]:getContentSize().width
	local width5 = self.txtObjList[5]:getContentSize().width

	self.txtObjList[2]:setPositionX(posX + width1)
	self.txtObjList[3]:setPositionX(posX + width1 + width2)
	self.txtObjList[4]:setPositionX(posX + width1 + width2 + width3)
	if level <= 11 then
		self.txtObjList[5]:setPositionX(posX + width1 + width2 + width3 + width4)
		self.txtObjList[6]:setPositionX(posX + width1 + width2 + width3 + width4 + width5)
	else
		self.txtObjList[5]:setPositionX(posX + width1 + width2)
		self.txtObjList[6]:setPositionX(posX + width1 + width2 + width3)
	end
end

function VipPayUI:updateVipLayout(level)
	if Layer.PAY == self.switch then
		-- 购买界面
		self.btn_switch:loadTexture('vip_btn_privilege.png', ccui.TextureResType.plistType)
		self.pay_layer:setVisible(true)
		self.right_layer:setVisible(false)
		local iList = PayData.getPayDataList()
		self:showPayItem(iList)
	else
		-- 特权显示界面
		self.btn_switch:loadTexture('vip_btn_recharge.png', ccui.TextureResType.plistType)
		self.pay_layer:setVisible(false)
		self.right_layer:setVisible(true)
		self:showRightContent(level)
	end
end
-- 显示购买列表
function VipPayUI:showPayItem(list)
	local con_pay = self.pay_layer.con_pay
	-- 获取滚动区域的size
	local size_sc = con_pay:getSize()
	-- 滚动界面的x偏移值 ，y偏移值 ，x间距 ，y间距 , item宽度 ，item高度
	local offX, offY, disX, disY, w, h = 12, 16, 11, 0, 225, 335
	
	local length = #list
    -- local maxRows = math.ceil(length / 3)
    local maxWidth = offX * 2 + (disX + w) * length - disX
    if maxWidth < size_sc.width then
      	maxWidth = size_sc.width
    end

	for k, v in pairs(list) do
		local px = offX + ( w + disX ) * ( k - 1 )
		local py = offY
		local item = PayRender:create()
		item:setRender(v)
		item:setPosition(cc.p(px, py))
		con_pay:addChild(item)
	end
	con_pay:setInnerContainerSize(cc.size(maxWidth, size_sc.height))
	con_pay:jumpToLeft()
end

-- 显示特权列表
function VipPayUI:showRightContent(level)
    if level == 0 then level = 1 end
    local img_privilege = self.right_layer.img_privilege
    local vip_lev = self.right_layer.vip_lev
    local sc_right = self.right_layer.con_right
    sc_right:removeAllChildren()

    local disY, h = 16, 35
    local size_sc = sc_right:getSize()
    vip_lev:setString(level)
    local vipLevSize = vip_lev:getContentSize()
    img_privilege:setPositionX(vip_lev:getPositionX() + vipLevSize.width)
    local vipLevel = gameData.getSimpleDataByKey("vip_level")
    -- local list = obtainPrivilegeList(level)  -- 根据VIP等级获取特权列表
    local list = PayData.obtainPrivilegeList(level)
    self:setBtnEnabled(level, vipLevel)

    local i, maxRows = 1, #list
    local maxHeight = (disY + h) * maxRows - disY
    if maxHeight < 263 then
    	sc_right:setPositionY(42 + 263 - maxHeight)
    	sc_right:setSize(cc.size(size_sc.width, maxHeight))
    else
    	sc_right:setPositionY(42)
    	sc_right:setSize(cc.size(size_sc.width, 263))
    end
    for i = 1, maxRows do
        local px = 0
        local py = maxHeight - (i - 1) * (h + disY)
        if list[i].icon == 0 then
        	-- vip等级特有的特权
	        local txt = UIFactory.getText(i .. ". " .. list[i].rights, sc_right, px, py, 26, cc.c3b(0x00, 0xff, 0x00))
	        txt:setAnchorPoint(cc.p(0, 1))
        else
	        local txt = UIFactory.getText(i .. ". " .. list[i].rights, sc_right, px, py, 26, cc.c3b(0xff, 0xdb, 0x9d))
	        txt:setAnchorPoint(cc.p(0, 1))
        end
    end
    sc_right:setInnerContainerSize(cc.size(size_sc.width, maxHeight))
    sc_right:jumpToTop()
end

function VipPayUI:setBtnEnabled(level,vipLevel)
    if vipLevel < 9 and level == 10 then
        self.right_layer.btn_next:setVisible(false)
    elseif level == 1 then
        self.right_layer.btn_prev:setVisible(false)
    elseif level == 20 then
        self.right_layer.btn_prev:setVisible(true)
        self.right_layer.btn_next:setVisible(false)
    -- elseif level == vipLevel then
    --     self.right_layer.btn_prev:setVisible(false)
    elseif vipLevel >= 10 then
    	self.right_layer.btn_prev:setVisible(true)
    	if level == vipLevel + 1 then
    		self.right_layer.btn_next:setVisible(false)
    	else
    		self.right_layer.btn_next:setVisible(true)
    	end
    else
        self.right_layer.btn_prev:setVisible(true)
        self.right_layer.btn_next:setVisible(true)
    end
    if vipLevel == 20 then
        self.right_layer.btn_prev:setVisible(true)
        self.right_layer.btn_next:setVisible(false)
    end
end
