local prePath = "image/ui/ActivationUI/"
CDKeyUI = createUIClass("CDKeyUI", prePath.."ActivationUI_1.ExportJson", PopWayMgr.SMALLTOBIG)

function CDKeyUI:ctor()
	createScaleButton(self.btn_paste)
	createScaleButton(self.btn_confirm)
	self.btn_paste:addTouchEnded(function ( ... )
		local str = system.PasteString()
		self.txt_input:setText(str)
		self.txt_err:setString("")
	end)
	self.btn_confirm:addTouchEnded(function ( ... )
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'btn_confirm') )
		local cdKey = self.txt_input:getText()
		if cdKey == nil or cdKey == "" then
			TipsMgr.showError("请输入激活码")
			return
		end
		if cdKey ~= "" and not self.isWaiting then
			self.isWaiting = true
			Command.run("team cdkey take", cdKey)
		end
	end)
	TextInput:replace(self.txt_input)
	self.errMap = {
		[err.kErrPresentCodeEmpty] = "激活码不能为空",
		[err.kErrPresentTaken] = "激活码已经被使用",
		[err.kErrPresentSame] = "已经领取过相同的礼包"
	}
	-- self.btn_paste:setVisible(false) --屏蔽粘贴按钮
	-- self.Image_12:setPositionX(self.Image_12:getPositionX() + 50)
	-- self.txt_input:setPositionX(self.txt_input:getPositionX() + 50)
end

function CDKeyUI:onShow()
	local function changeHandler(input)
		self.txt_err:setString("")
	end
	self.txt_input.changeHandler = changeHandler
	self.txt_input:setPlaceHolder("请输入激活码")
	self.txt_err:setString("")
	EventMgr.addListener(EventType.TeamCDKeyTakeRusult, self.onCdKeyResult, self)
end

function CDKeyUI:onClose()
	EventMgr.removeListener(EventType.TeamCDKeyTakeRusult, self.onCdKeyResult)
end

function CDKeyUI:onCdKeyResult(msg)
	self.isWaiting = nil
	if msg.err_code == 0 then
		TipsMgr.showSuccess("礼包兑换成功")
		Command.run("ui hide", self.winName)
	else
		self.txt_err:setString(self.errMap[msg.err_code] or "激活码错误")
	end
end