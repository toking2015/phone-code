local Path = "image/ui/EquipTipForItemUI/"
--TipsItem = createLayoutClass("TipsItem", TipsBase)
TipsItem = createUIClassEx("TipsItem", TipsBase,PopWayMgr.SMALLTOBIG )
--注册
TipsMgr.registerTipsRender(TipsMgr.TYPE_ITEM, TipsItem)

function TipsItem:render()
	local jItem = self.data
	local sItem= self.exData
	if jItem then
		if jItem.type == const.kItemTypeEquip then
			self.width = 412
			self:renderEquip(jItem,sItem)
		else
			self.width = 330
			self:renderNormal(jItem, sItem )
		end
	end
end

function TipsItem:renderNormal( jItem, sItem )
	if jItem then
		--描述
		local descStr = fontNameString("TIP_C") .. (jItem.desc or "")
		descStr = string.gsub(descStr, 'replace', '[br][font=ITEM_1]')
        if not GameData.checkLevel( jItem.limitlevel ) then
        	descStr = descStr..'[br][font=TIP_C_1]使用等级：'..jItem.limitlevel
        end
        if sitem and state.has( sitem.flags, const.kCoinFlagBind ) then		
        	descStr = descStr..'[br][font=TIP_C_1]该物品已绑定，不能进行交易'
        end
		self:addRich(descStr)
		--标题
		local nameTxt = UIFactory.getText(jItem.name, self.otherCon, 0, 0, 20, cc.c3b(0xff, 0x8a, 0x00 ), FontNames.HEITI,nil,0)
		nameTxt:setAnchorPoint(0,0)
		nameTxt:setPosition(0,10)
		local nSize = nameTxt:getContentSize()
		self:setOtherSize( self.width,nSize.height + 10 )
		--类型
		local typeTxt = UIFactory.getText("物品", self.otherCon, 0, 0, 20, cc.c3b(0xff, 0xd5, 0x2c ), FontNames.HEITI,nil,0)
		typeTxt:setAnchorPoint(1,0)
		typeTxt:setPosition(self.width - 50,10)
	end
end

function TipsItem:renderEquip( jItem , sItem )
	if jItem then
		local content = getLayout(Path .. "equipTip.ExportJson")
		local size = content:getSize()
		self:setOtherSize( size.width,size.height )
		self.otherCon:addChild(content)

		content.title:setString(jItem.name)
		content.levelInfo.add:setString(jItem.limitlevel)
		local typeName = EquipmentData:getEquipTypeName(jItem.equip_type)
		content.typeName:setString( string.format('T%d%s',jItem.level,typeName) )

		--一级属性
    	local info_index = 1
    	local jEffect = nil
    	local str = ''
    	for k,v in pairs(jItem.attrs) do
    		if v.first ~= 0 then
    			jEffect = findEffect( v.first )
                str = jEffect.desc..':'
                if sItem then
    				str = str .. tostring( math.floor( v.second * ( 1 + sItem.main_attr_factor / 10000 )))
    			else
    				str = str .. v.second
    			end
    			content['info_'..info_index]:setString( str )
    			content['info_'..info_index]:setVisible(true)
    			info_index = info_index + 1
    		end
    	end

    	--随机属性
    	if sItem then
	    	local slave_attr = nil
	    	for k,v in pairs(sItem.slave_attrs) do
	            if v ~= 0 then
	    		    slave_attr = jItem.slave_attrs[v]
	    			jEffect = findEffect( slave_attr.first )
	                str = jEffect.desc..':' 
	    			if sItem then
	    				str = str .. tostring( math.floor( slave_attr.second * ( 1 + sItem.slave_attr_factor / 10000 ) ) ) 
	    			else
	    				str = str .. slave_attr.second 
	    			end
			    	if content['info_'..info_index] == nil then
		    			break
		    		end
	    			content['info_'..info_index]:setString( str )
	    			content['info_'..info_index]:setVisible(true)
	    			info_index = info_index + 1
	    		end
	    	end
    	end

    	for i=info_index,6 do
    		if content['info_'..i] == nil then
    			break
    		end
    		content['info_'..i]:setVisible(false)
    	end

    	--套装属性(白装)
    	local jEquipSuit = EquipmentData:getEquipSuit( jItem.level, const.kCoinEquipWhite, jItem.equip_type )
        local suit_attr = jEquipSuit.odds[1];
    	local jOdd = findOdd( suit_attr.first, suit_attr.second )
    	local count = 0
    	content.midInfo.add:setString( '' )
    	count = EquipmentData:getEquipmentCountForQuality( jItem.equip_type, jItem.level, const.kCoinEquipWhite )
        content.midInfo:setString( string.format("T%d套装(%d/6):",jItem.level,count) )
        content.midInfo.add:setPositionX( content.midInfo:getContentSize().width + 5 )
        content.midInfo.add:setString( jOdd.description )
		if count < 6 then
			content.midInfo:setColor( cc.c3b( 0x7f, 0x7a, 0x75 ) )
			content.midInfo.add:setColor( cc.c3b( 0x7f, 0x7a, 0x75 ) )
		else
			content.midInfo:setColor( cc.c3b( 0xFF, 0xDa, 0x00 ) )
			content.midInfo.add:setColor( cc.c3b( 0xFF, 0xFF, 0xFF ) )
		end

	    --套装品质属性
    	local quality = const.kCoinEquipGreen
    	local sets = nil
    	for i=1,4 do
            sets = content['arr'..i]
            sets.add:setString( '' )
    		count = EquipmentData:getEquipmentCountForQuality( jItem.equip_type, jItem.level, quality )
    		if count < 6 then
    			sets:setColor( cc.c3b( 0x7f, 0x7a, 0x75 ) )
    			sets.add:setColor( cc.c3b( 0x7f, 0x7a, 0x75 ) )
    		else
    			sets:setColor( cc.c3b( 0xFF, 0xDa, 0x00 ) )
    			sets.add:setColor( cc.c3b( 0xFF, 0xFF, 0xFF ) )
    		end
    		local qualityName = EquipmentData:getEquipmentQualityName(quality)
    		sets:setString( string.format("T%d%s装(%d/6):",jItem.level,qualityName,count) ) 
    		sets.add:setPositionX( sets:getContentSize().width + 5 )  		
    		jEquipSuit = EquipmentData:getEquipSuit( jItem.level, quality, jItem.equip_type )
    		suit_attr = jEquipSuit.odds[1];		
    		jOdd = findOdd( suit_attr.first, suit_attr.second )	
    		sets.add:setString( jOdd.description )
            quality = quality + 1
       end
       
	end	
end