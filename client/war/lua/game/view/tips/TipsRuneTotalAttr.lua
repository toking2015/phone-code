--TipsRuneTotalAttr = createLayoutClass("TipsRuneTotalAttr", TipsBase)
TipsRuneTotalAttr = createUIClassEx("TipsRuneTotalAttr", TipsBase, PopWayMgr.SMALLTOBIG)
--注册
TipsMgr.registerTipsRender(TipsMgr.TYPE_RUNE_TOTAL_ATTR, TipsRuneTotalAttr)

function TipsRuneTotalAttr:render()
	local attrs = self.data
	local type = self.exData
	if attrs then
		--描述
        self:addRich(TempleData.totalGlyphArrForList(attrs,"属性"))
		local cue = "[br][br]" .. fontNameString("TIP_Y") .. "神符可以在神殿中镶嵌给对应系别的英雄，对该系别的所有英雄生效。神符可以进行升级，或者作为本系别神符的升级材料。"
		self:addRich(cue)

		--标题
		local nameTxt = UIFactory.getText(TempleData.getRuneTypeName(type), self.otherCon, 0, 0, 20, cc.c3b(0xff, 0x8a, 0x00 ), FontNames.HEITI,nil,0)
		nameTxt:setAnchorPoint(0,0)
		nameTxt:setPosition(0,10)
		local nSize = nameTxt:getContentSize()
		self:setOtherSize( self.width,nSize.height + 10 )
		-- --类型
		-- local typeName = TempleData.getTypeName(jGlyph.type)
		-- local typeTxt = UIFactory.getText(typeName, self.otherCon, 0, 0, 20, cc.c3b(0xff, 0xff, 0xff ), FontNames.HEITI,nil,0)
		-- local color = TotemData.getTypeColor(jGlyph.type)
		-- typeTxt:setColor(color)
		-- typeTxt:setAnchorPoint(1,0)            
		-- typeTxt:setPosition(self.width - 50,10)
	end	
end