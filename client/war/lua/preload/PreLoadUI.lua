local prePath = "image/ui/LoadingUI/"
PreLoadUI = class("PreLoadUI", function()
	return getLayout(prePath.."LoadingUI.ExportJson")
end)

function PreLoadUI:ctor()
    self:removeChild(self.light)
    local url = 'image/armature/ui/loading/'
    self.light = PreLoadUtils.getArmature(url, 'jz-tx-02', "PreLoadUI", self)
    self.txt_tips1:setString(string.format("正在更新配置", current, total))
    self.txt_tips2:setString("建议在WIFI环境下更新游戏")

	self.txt_tips1:setFontSize(20)
    self.txt_tips1:setColor(cc.c3b(0xff, 0xff, 0xff))
    self.txt_tips1:getVirtualRenderer():enableOutline(cc.c4b(0x00, 0x00, 0x00, 0xff), 2)

	self.txt_tips2:setFontSize(20)
    self.txt_tips2:setColor(cc.c3b(0xff, 0xf7, 0x10))
    self.txt_tips2:getVirtualRenderer():enableOutline(cc.c4b(0x00, 0x00, 0x00, 0xff), 2)

	self.logo:setPosition(255, 512)
end

function PreLoadUI:onShow()
    self:doSetPercent(0)
    self.percent = 0
    self.maxPercent = 0
	local function updatePercent()
		local oldPercent = self.bar:getPercent()
		if self.maxPercent == 0 or (self.percent ~= self.maxPercent and math.ceil(oldPercent) == 100) then
			self.maxPercent = 0
			self:doSetPercent(0)
		else
			local newPercent = oldPercent + math.max(0.1, (self.maxPercent - oldPercent) * 0.05)
			if newPercent <= self.maxPercent then
				self:doSetPercent(newPercent)
			end
		end
		if self.percent == self.maxPercent and oldPercent >= 100 then
			if not self.tips1_str then
				self.txt_tips1:setString("正在获取更新")
			end
		end
	end
	self:scheduleUpdateWithPriorityLua(updatePercent, 0)
end

function PreLoadUI:onClose()
	self:unscheduleUpdate()
end

function PreLoadUI:doSetPercent(percent)
	self.bar:setPercent(percent)
	local pt = cc.p(self.bar:getPosition())
	local size = self.bar:getContentSize()
	self.light:setPosition(pt.x + size.width * percent / 100 - size.width / 2, pt.y)
end

function PreLoadUI:getPercent()
	return self.percent
end

function PreLoadUI:setPercent(current, total, str, str2)
	total = total or 1000
	if total < current then
		total = current
	end
	self.percent = math.floor(100 * current / total)
	self.maxPercent = math.max(self.maxPercent, self.percent)
	self.tips1_str = str
	if str then
		self.txt_tips2:setString(str2 or "游戏正在初始化，请耐心等待")
		self:doSetPercent(self.percent)
	else
		self.txt_tips2:setString("建议在WIFI环境下更新游戏")
	end
    str = str or string.format("正在更新——%skb/%skb", math.floor(current / 1024), math.floor(total / 1024) )
	self.txt_tips1:setString(str)
end

function PreLoadUI:getInstance(noCreate)
	local instance = PreLoadUI.instance
    if not instance and not noCreate then
		instance = PreLoadUI.new()
		local size = instance:getSize()
		instance:setPosition((visibleSize.width - size.width) / 2, (visibleSize.height - size.height) / 2)
		instance:onShow()
		instance:retain()
		PreLoadUI.instance = instance
	end
	return instance
end

function PreLoadUI:dispose()
	if PreLoadUI.instance then
		PreLoadUI.instance:release()
		PreLoadUtils.removeArmatureInfo("PreLoadUI")
		PreLoadUI.instance = nil
	end
end