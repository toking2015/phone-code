--TipsTotem = createLayoutClass("TipsTotem", TipsBase)
TipsTotem = createUIClassEx("TipsTotem", TipsBase, PopWayMgr.SMALLTOBIG)
--注册
TipsMgr.registerTipsRender(TipsMgr.TYPE_TOTEM, TipsTotem)

function TipsTotem:render()
	local sTotem
	local jTotem
	local level
	if self.data.guid then
		sTotem = self.data
		jTotem = findTotem(sTotem.id)
		level = sTotem.level
	elseif self.data.totem_id then
		sTotem = self.data
		jTotem = findTotem(sTotem.totem_id)
		level = sTotem.level
	else
		jTotem = self.data
		level = jTotem.init_lv
	end
	local title = UIFactory.getLabel(jTotem.name, nil, 0, 35, 20, QualityData.getColor(level), cc.TEXT_HALIGNMENT_LEFT)
	title:setAnchorPoint(cc.p(0, 0))
	self:addNode(title)
	title = UIFactory.getLabel(TotemData.getTypeName(jTotem.type), nil, 320, 36, 18, TotemData.getTypeColor(jTotem.type), cc.TEXT_HALIGNMENT_RIGHT)
	title:setAnchorPoint(cc.p(1, 0))
	self:addNode(title)
	for i = 1, level do
		local icon = UIFactory.getSpriteFrame("start_bright.png")
		icon:setScale(0.5)
		self:addNode(icon, 15 + 30 * (i - 1), 20)
	end
	self:setOtherSize(320, 60)
	self:renderText(sTotem, jTotem, level)
	self:renderGlyph(sTotem, self.exData)
end

function TipsTotem:renderText(sTotem, jTotem, level)
	local color1 = cc.c3b(0xff, 0xda, 0x00)
	local color2 = cc.c3b(0xff, 0xff, 0xff)
	local skillAttr = findTotemAttr(jTotem.id, level)
	self:addText("{主动技能：}", color1, 20)
	local skillOdd = findSkill(skillAttr.skill.first, skillAttr.skill.second)
	self:addTextBr(TotemData.getSkillDesc(skillOdd), color2, 18)
	local speedAttr = findTotemAttr(jTotem.id, sTotem and sTotem.speed_lv or jTotem.init_attr_lv)
	self:addText("{速度加成：}", color1, 20)
	local speedOdd = findOdd(speedAttr.speed.first, speedAttr.speed.second)
	self:addTextBr(TotemData.getSpeedDesc(speedOdd), color2, 18)
	local formationAttr = findTotemAttr(jTotem.id, sTotem and sTotem.formation_add_lv or jTotem.init_attr_lv)
	self:addText("{阵法加成：}", color1, 20)
	local formationOdd = findOdd(formationAttr.formation_add_attr.first, formationAttr.formation_add_attr.second)
	self:addTextBr(TotemData.getFormationDesc(formationOdd), color2, 18)
	local wakeAttr = findTotemAttr(jTotem.id, sTotem and sTotem.wake_lv or jTotem.init_attr_lv)
	local wakeDesc = TotemData.getWakeDesc(jTotem.type, wakeAttr, TotemData.isWakeDouble)
	if wakeDesc ~= "" then
		self:addText("{觉醒几率：}", color1, 20)
		self:addTextBr(wakeDesc, color2, 18)
	end
end

function TipsTotem:renderGlyph(sTotem, glyphList)
	if not glyphList or not sTotem then
		return
	end
	local color1 = cc.c3b(0xff, 0xda, 0x00)
	local color2 = cc.c3b(0x31, 0xff, 0x16)
	local count = 1
	for _,v in pairs(glyphList) do
		if v.totem_guid == sTotem.guid then
			local list = TotemData.getGlyphBaseDescList(v)
			list = TotemData.getGlyphHidenDescList(v, list)
			local jGlyph = findTempleGlyph(v.id)
			self:addText((TotemData.getGlyphName(v, jGlyph)).."：", color1, 18)
			self:addTextBr(table.concat(list, ";"), color2, 18)
			count = count + 1
		end
	end
end
