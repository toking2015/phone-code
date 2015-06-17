CommonRuleUI = createUIClassEx("CommonRuleUI", cc.Node, PopWayMgr.SMALLTOBIG)

function CommonRuleUI:ctor()
	local rect = cc.rect(55, 55, 1, 1)
	local size = cc.size(518, 278)
	self:setContentSize(size.width, size.height)
	self.bg = UIFactory.getScale9Sprite("grid_rule.png", rect, size, self)
	self.richCon = UIFactory.getNode(self, 20, 20)
	self.text = UIFactory.getText("点击任意位置关闭", self, 260, 30, 18, cc.c3b(0xE8, 0xA1, 0x61))
end

function CommonRuleUI:setData(str, title, isImage)
	self.richCon:removeAllChildren(true)
	if self.title then
		self.title:removeFromParent()
		self.title = nil
	end
	title = title or ""
	if isImage then
		self.title = UIFactory.getSprite(title, self, 256, 278)
	else
		self.title = UIFactory.getText(title, self, 256, 278, 30, cc.c3b(0xFF, 0xA5, 0x00))
	end
	local content = type(str) == "table" and table.concat(str, "[br]") or str
	RichTextUtil:DisposeRichText(content, self.richCon, richText, 0, 470, 10)
	local size = self.richCon:getContentSize()
	self.richCon:setPosition(40, 220)-- - size.height
end
