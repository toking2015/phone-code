-- create by Hujingjiang --

local prevPath = "image/ui/MainUI/"

RoleSignView = class("RoleSignView", function()
	return getLayout(prevPath .. "RoleSignView.ExportJson")
end)

function RoleSignView:create()
	local ui = RoleSignView.new()

	ui.isMarkShow = false -- 签到特效是否显示
	ui.mid = nil

	-- 把所需对象绑定成一个点击可以缩放的按钮
	local btn_sign = createScaleButton(ui.btn_sign)
	local btn_pay = createScaleButton(ui.btn_pay)

	local function markHandler(ref, eventType)
        ActionMgr.save( 'UI', 'SignUI click btn_sign' )
        Command.run( 'ui show', 'SignUI', PopUpType.SPECIAL )
	end
	local function payHandler(ref, eventType)
        ActionMgr.save( 'UI', 'VipPayUI click btn_pay' )
        Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
	end
	--注册绑定后的按钮事件
	btn_sign:addTouchEnded(markHandler)
	btn_pay:addTouchEnded(payHandler)
	ui:initSignBtn()
	ui:updateFRData()

	-- ui:updateSignData()
	local function updateRedPoint()
		if ui:getParent() then
			ui:updateSignData()
			if ui.vip_activity and ui.vip_activity:getParent() then
				local isShow = VipActivityData.isShowRedPoint()
				setButtonPoint(ui.vip_activity, isShow, cc.p(46, 46))
			end
		end
	end
	local function scriptHandler(event)
		if "enter" == event then
			ui.sign_time_id = TimerMgr.startTimer(updateRedPoint, 1)
		elseif "exit" == event then
			TimerMgr.killTimer(ui.sign_time_id)
		end
	end
	ui:registerScriptHandler(scriptHandler)
	return ui
end

function RoleSignView:initSignBtn()
	local function vipActivityHandler()
		ActionMgr.save('UI', 'vipActivityUI click vip_activity')
        -- Command.run('ui show', 'VipActivityUI', PopUpType.SPECIAL)
        Command.run('show VipActivity')
	end

	local function frHandler(ref, eventType)
        ActionMgr.save( 'UI', 'VipPayUI click btn_fr' )
        Command.run( 'ui show', "ActivityFRUI", PopUpType.SPECIAL )
	end
	
	local vip_activity = self:createSignBtn('main_vip_package.png', vipActivityHandler)
	self.vip_activity = vip_activity

	local btn_fr = self:createSignBtn('activity_fr.png', frHandler,nil,83)
	self.btn_fr = btn_fr

end

function RoleSignView:createSignBtn(frameName, onTouchFunc, load_type,sizew)
	local btn = ccui.ImageView:create(frameName, load_type or ccui.TextureResType.plistType)
	btn:setAnchorPoint(cc.p(0, 0))
	local size = self:getContentSize()
	btn:setPosition(cc.p(size.width + 20, 3))
	self:addChild(btn)
	self:setSize(cc.size(size.width + (sizew or 57 ) + 20, size.height))
	createScaleButton(btn)

	local function callfunc()
		if onTouchFunc then onTouchFunc() end
	end
	btn:addTouchEnded(callfunc)

	return btn
end

function RoleSignView:updateSignData()
	self:updateMarkData()
	-- self:updateVipData()
end

function RoleSignView:updateFRData( )
	if ActivityData.hasGetedFR() == true then
		self.btn_fr:setVisible(false)
	else
		self.btn_fr:setVisible(true)
		setButtonPoint( self.btn_fr, ActivityData.isCanGet(), cc.p(46, 46) )
	end
end

function RoleSignView:updateMarkData()
	-- local function showMarkRedPoint()
		setButtonPoint( self.btn_sign, SignData.getCanGet(), cc.p(46, 46) )
		-- self:checkMarkEffect()
	-- end
	-- if nil == self.mid then
	-- 	self.mid = TimerMgr.startTimer(showMarkRedPoint, 1)
	-- end
end

function RoleSignView:createBtnEffect( tar_btn )
	if tar_btn then
		if tar_btn.markEff == nil then
			local bSize = tar_btn:getSize()
			tar_btn.markEff = self:signEffectAction("zjmqd-tx-01", bSize.width/2, bSize.height/2 - 3, tar_btn)
		end
	end
end

function RoleSignView:checkMarkEffect()
	if true == MarkData.getCanGet() and false == self.isMarkShow then
		self.isMarkShow = true
		local bSize = self.btn_sign:getSize()
		self.markEff = self:signEffectAction("zjmqd-tx-01", bSize.width/2, bSize.height/2 - 3, self.btn_sign)
	elseif false == MarkData.getCanGet() and true == self.isMarkShow then
		self.isMarkShow = false
		self.markEff:stop()
    	self.markEff:removeNextFrame()
	end
end

function RoleSignView:updateVipData()
	local btnSize = self.btn_pay:getSize()
	self:signEffectAction("zjmcz-tx-01", btnSize.width/2 + 11, btnSize.height/2 + 11, self.btn_pay)
end

function RoleSignView:signEffectAction(name, x, y, parent)
	local url = "image/armature/ui/MainUI/" .. name .. "/" .. name ..".ExportJson"
	LoadMgr.loadArmatureFileInfo(url, LoadMgr.SCENE, "main")
	local effect = ArmatureSprite:create(name, 0)

	effect:setPosition(cc.p(x, y))

	parent:addChild(effect)

	return effect
end