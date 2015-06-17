EquipmentTips = createUIClass("EquipmentTips", "image/ui/EquipmentUI/EquipmentTips.ExportJson", PopWayMgr.SMALLTOBIG )

function EquipmentTips:ctor()
	function self.onButtonTouch(sender, eventType)
		PopMgr.removeWindow( self )
	end
	UIMgr.addTouchEnded( self.btn_close, self.onButtonTouch ) 
end

function EquipmentTips:onShow()
	self:updateData()
end 

function EquipmentTips:onClose()
end 

function EquipmentTips:updateData()
	self:updateLeft()
	self:updateRight()
end

function EquipmentTips:updateLeft()
	local item = nil
	local equipment = nil
	local unEquipmentList = nil
	local quality = 1
	local jItem = nil
	for i=1,6 do
		item = self['item_'..i]
		-- item.icon:setVisible( true )
		quality = 1
		equipment = EquipmentData:getEquipmentForCondition( EquipmentData:getTipsType(), EquipmentData:getTipsLevel(), i, true )
		local jitem = nil
		if equipment == nil then
			item.icon:loadTexture("image/ui/EquipmentUI/equipment_equip_no.png",ccui.TextureResType.localType)
			quality = 1
			item.text_name:setString('')
		else
			jitem = findItem( equipment.item_id )
			quality = ItemData.getQuality( jitem, equipment )
			ItemData.setItemUlr( item.icon, jitem.id )
			item.text_name:setColor( ItemData.getItemColor(quality, 1 ) )
			item.text_name:setString( 'T'..EquipmentData:getTipsLevel()..EquipmentData:getEquipTypeName(EquipmentData:getTipsType())..EquipmentData:getEquipmentSubclassName(i) )
		end
		
		item:loadTexture( 'equipment_bg_item_' .. quality .. '.png', ccui.TextureResType.plistType ) 
	end
end

function EquipmentTips:updateRight()
	self.info_all.info:setString( 'T'..EquipmentData:getTipsLevel()..EquipmentData:getEquipTypeName( EquipmentData:getTipsType())..'套装' )
	local infoData = EquipmentData:getEquipmentAllInfo( EquipmentData:getTipsType(), EquipmentData:getTipsLevel(), true )
	local infoIndex = 1
	for i,v in ipairs(EquipmentData.info_name_list) do
		if infoData[v] ~= nil then
			self.info_all['info_'..infoIndex]:setString( v..':')
			self.info_all['info_'..infoIndex].value:setString( infoData[v] )
			self.info_all['info_'..infoIndex]:setVisible(true)
			infoIndex = infoIndex + 1
		end
	end

	for i=infoIndex,14 do
		self.info_all['info_'..i]:setVisible(false)
	end

	self.info_suit:setPositionY( self.info_all:getPositionY() - math.floor( infoIndex / 2 + 2 ) * 21 + 90 )
	--套装属性
	local sets = nil
	local jEquipSuit = EquipmentData:getEquipSuit( EquipmentData:getTipsLevel(), const.kCoinEquipWhite, EquipmentData:getTipsType() )
	local suit_attr = jEquipSuit.odds[1];
	local jOdd = findOdd( suit_attr.first, suit_attr.second )
	local count = 0
	sets = self.info_suit.sets_1
	sets.text_info:setString( jOdd.description )
	count = EquipmentData:getEquipmentCountForQuality( EquipmentData:getTipsType(), EquipmentData:getTipsLevel(), const.kCoinEquipWhite, true )
	local color = nil
	if count < 6 then
		color = cc.c3b( 0x83, 0x77, 0x6d )
	else
		color = cc.c3b( 0xb4, 0xfe, 0x15 )
	end
	sets:setString( 'T'..EquipmentData:getTipsLevel()..'套装(  /6):' )
	sets.text_info:setColor( color )    
	sets:setColor( color )
	sets.text_count:setColor( color )	
    sets.text_count:setString( count )   	

	self.info_all.info:setVisible( count ~= 0 )
    if count == 0 then
    	self.info_suit:setPositionY( 60 )
    end

	--套装品质属性
	local quality = const.kCoinEquipGreen
	for i=2,4 do
		sets = self.info_suit['sets_'..i]
		count = EquipmentData:getEquipmentCountForQuality( EquipmentData:getTipsType(), EquipmentData:getTipsLevel(), quality )
		local color = nil
		if count < 6 then
			color = cc.c3b( 0x83, 0x77, 0x6d )
		else
			color = cc.c3b( 0xb4, 0xfe, 0x15 )
		end
		sets.text_info:setColor( color )    
		sets:setColor( color )
		sets.text_count:setColor( color )	

		sets.text_count:setString( count )
		jEquipSuit = EquipmentData:getEquipSuit( EquipmentData:getTipsLevel(), quality, EquipmentData:getTipsType() )
		suit_attr = jEquipSuit.odds[1];		
		jOdd = findOdd( suit_attr.first, suit_attr.second )	
		sets.text_info:setString( jOdd.description )
        quality = quality + 1
	end	
end

function EquipmentTips:dispose()

end
