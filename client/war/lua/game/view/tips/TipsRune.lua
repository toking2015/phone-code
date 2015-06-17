--TipsRune = createLayoutClass("TipsRune", TipsBase)
TipsRune = createUIClassEx("TipsRune", TipsBase, PopWayMgr.SMALLTOBIG)
--注册
TipsMgr.registerTipsRender(TipsMgr.TYPE_RUNE, TipsRune)

function TipsRune:render()
	local jGlyph = self.data
	local sGlyph = self.exData
	if jGlyph then
		--描述
		if sGlyph then
			self:addRich(TempleData.getJGlyphArr(sGlyph))
			local lvTxt = UIFactory.getText( sGlyph.level.."级", self.otherCon, 0, 0, 20, cc.c3b(0x7e, 0xff, 0x00 ), FontNames.HEITI,nil,0)
			lvTxt:setAnchorPoint(0,0)
			lvTxt:setPosition(0,10)
		else			
			self:addRich(TempleData.getJGlyphArrByJGlyph(jGlyph))
		end
		local cue = "[br][br]" .. fontNameString("TIP_Y") .. "神符可以在神殿中镶嵌给对应系别的英雄，对该系别的所有英雄生效。神符可以进行升级，或者作为本系别神符的升级材料。"
		self:addRich(cue)
		--标题
		
		local nameTxt = UIFactory.getText( jGlyph.name, self.otherCon, 0, 0, 20, cc.c3b(0xff, 0x8a, 0x00 ), FontNames.HEITI,nil,0)
		nameTxt:setAnchorPoint(0,0)
		if sGlyph then
			nameTxt:setPosition(35,10)
		else	
			nameTxt:setPosition(0,10)
		end
		local nSize = nameTxt:getContentSize()
		self:setOtherSize( self.width,nSize.height + 10 )
		--类型
		local typeName = TempleData.getTypeName(jGlyph.type) 
		local typeTxt = UIFactory.getText(typeName, self.otherCon, 0, 0, 20, cc.c3b(0xff, 0xff, 0xff ), FontNames.HEITI,nil,0)
		local color = TempleData.getTypeColor(jGlyph.type)
		typeTxt:setColor(color)
		typeTxt:setAnchorPoint(1,0)            
		typeTxt:setPosition(self.width - 50,10)
	end	
end