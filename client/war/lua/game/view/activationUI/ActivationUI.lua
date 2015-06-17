local prePath = "image/ui/ActivationUI/"
ActivationUI = createUIClass("ActivationUI", prePath.."ActivationUI_1.ExportJson", PopWayMgr.SMALLTOBIG)

function ActivationUI:ctor( )
	createScaleButton(self.btn_paste)
	createScaleButton(self.btn_confirm)
	self.btn_paste:addTouchEnded(function ( ... )
		local str = system.PasteString()
		self.txt_input:setText(str)
		self.txt_err:setString("")
	end)
	self.btn_confirm:addTouchEnded(function ( ... )
		local act_code = self.txt_input:getText()
		if act_code ~= "" and not self.isWaiting then
			self.isWaiting = true
			Command.run("loading login server", act_code)
		end
	end)
	TextInput:replace(self.txt_input, 50)
	self.errMap = {
        [20] = "激活码已经被使用"
	}
	-- self.btn_paste:setVisible(false) --
	-- self.Image_12:setPositionX(self.Image_12:getPositionX() + 50)
	-- self.txt_input:setPositionX(self.txt_input:getPositionX() + 50)
end

function ActivationUI:onShow()
	local function changeHandler(input)
		self.txt_err:setString("")
	end
	self.txt_input.changeHandler = changeHandler
	self.txt_input:setPlaceHolder("请输入激活码")
	self.txt_err:setString("")
	EventMgr.addListener(EventType.ActivationResult, self.onActivationResult, self)
end

function ActivationUI:onBeforeClose()
	return not inf.activated --没激活不准关闭窗口
end

function ActivationUI:onClose()
	EventMgr.removeListener(EventType.ActivationResult, self.onActivationResult)
end

function ActivationUI:onActivationResult(code)
	self.isWaiting = false
	self.txt_err:setString(self.errMap[code] or "激活码错误")
end