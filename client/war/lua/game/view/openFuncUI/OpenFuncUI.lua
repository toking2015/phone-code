local prePath = "image/ui/OpenFuncUI/"
OpenFuncUI = createUIClass("OpenFuncUI", prePath.."OpenFuncUI.ExportJson", PopWayMgr.SAMLLTOBIG)

function OpenFuncUI:ctor()
	createScaleButton(self.btn_open)
	function self.onOpenClick(sender, eventType)
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'btn_open') )
		PopMgr.removeWindow(self)
	end
	self.btn_open:addTouchEnded(self.onOpenClick)
	self.url = nil
end

function OpenFuncUI:onShow()
	self:updateData()
end

function OpenFuncUI:onClose()
	if self.data then
		local callback = self.data.callback
		local pos = cc.p(0, 0)
		if self.con.icon then
			pos = self.con.icon:convertToWorldSpace(pos)
		end
		local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
		local icon = nil
		if self.data.id ~= 9 then
			icon = UIFactory.getSprite(self.url, layer, pos.x, pos.y, 1000)
		end

		if callback then
			callback(icon)
		end
	end
	TimerMgr.callLater(OpenFuncMgr.checkPriorityShow, 0.2) --检查下一个开启的
end

function OpenFuncUI:updateData()
	local data = OpenFuncData.removeUIData()
	if not data then
		return
	end
	if data.onBeginHandler ~= nil then
		data.onBeginHandler()
	end
	self.data = data
	local openData = OpenFuncData.getOpenData(data.type, data.id)
	if data.type == OpenFuncData.TYPE_BUILDING then
		self.txt_title:loadTexture("OpenFuncUI/txt_building.png", ccui.TextureResType.plistType)
		self.url = string.format("image/ui/OpenFuncUI/1/%s.png", openData.icon)
		UIFactory.setSpriteChild(self.con, "icon", false, self.url, 180, 250)
	else
		self.txt_title:loadTexture("OpenFuncUI/txt_func.png", ccui.TextureResType.plistType)
		self.url = string.format("image/ui/OpenFuncUI/2/%s.png", data.id)
		UIFactory.setSpriteChild(self.con, "icon", false, self.url, 180, 250)
	end
	self.txt_name:setString(openData.name)
end
