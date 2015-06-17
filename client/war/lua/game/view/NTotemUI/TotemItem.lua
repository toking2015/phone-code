local prePath = "image/ui/NTotemUI/"
TotemItem = createLayoutClass("TotemItem", cc.Node)

function TotemItem:ctor()
	self.img_bg = UIFactory.getSprite("", self, 118, 50, 1)
	self.img_icon = UIFactory.getSprite("", self, 52, 52, 2)
	self.txt_name = UIFactory.getText("", self, 162, 76, 3)
	self.con_star = UIFactory.getNode("", self, 98, 16, 4)
end

function TotemItem:setData(jTotem)
	if not jTotem then
		self:setVisible(false)
		return
	end
	self:setVisible(true)
	local sTotem = TotemData.getTotemById(jTotem.id)
	local qu = 0
	if sTotem then
		qu = sTotem.level
	end
	local path = prePath..string.format("bg/bg_item_%s.png", qu)
	self.img_bg:setTexture(path)
	BitmapUtil.setTexture(self.img_icon, TotemData.getAvatarUrl(jTotem))
	self.txt_name:setString(jTotem.name)
	self.txt_name:setColor(QualityData.getColor(self.level))
	self:setStar(qu)
end

function TotemItem:setStar(level)
	for i = 1, TotemData.MAX_LEVEL do
		local url = i <= level and "TotemUI/totem_res_11.png" or "TotemUI/totem_res_10.png"
		local x = i * 28 - 10
		UIFactory.setSpriteChild(self.con_star, "star"..i, true, url, x, 10)
	end
end