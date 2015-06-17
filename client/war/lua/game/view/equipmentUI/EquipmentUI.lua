EquipmentUI = createUIClass("EquipmentUI", "image/ui/EquipmentUI/EquipmentUI.ExportJson", PopWayMgr.SMALLTOBIG )
EquipmentUI.sceneName = "common"

function EquipmentUI:ctor()
	EquipmentData.info_name_list = {'生命','攻击强度','护甲','法术强度','魔法抗性','速度','暴击等级','暴击抵抗','暴击伤害','韧性','命中','躲闪','格挡','精准'}
	self.beginTime = 0
	
	function self.onTypeButtonTouch(sender, eventType)
		EquipmentData.selectType = sender.index
		self:updateData()
		ActionMgr.save( 'UI', '[EquipmentUI] click [button_type_' .. EquipmentData.selectType..']' )
	end

	function self.onLevelButtonTouch(sender, eventType)
		EquipmentData.selectLevel = sender.index
		self:updateData()
		ActionMgr.save( 'UI', '[EquipmentUI] click [button_level_' .. EquipmentData.selectType..']' )
	end

	local button = nil
	for i=1,4 do
		button = self['button_type_' .. i]
		button.index = 5 - i
		UIMgr.addTouchEnded( button, self.onTypeButtonTouch ) 

		button = self['button_level_'..i]
		button.index = i
		UIMgr.addTouchEnded( button, self.onLevelButtonTouch ) 	

		self:updateLevelButtonPostion(i)	
	end

	function self.onSubclassButtonTouchBegin(sender, EventType)
		ActionMgr.save( 'UI', '[EquipmentUI] down [item_' .. EquipmentData.selectSubclass..']' )
		EquipmentData.selectSubclass = sender.index
		self.beginTime = GameData.getServerTime()
		self.beginItem = sender
		TimerMgr.callPerFrame( self.onSubclassButtonTouchTimer )
	end

	function self.onSubclassButtonTouchEnd(sender, eventType )
		ActionMgr.save( 'UI', '[EquipmentUI] up [item_' .. EquipmentData.selectSubclass..']' )
		TimerMgr.killPerFrame(self.onSubclassButtonTouchTimer)
		if self.beginItem == sender then
			if GameData.getServerTime() - self.beginTime < 0.05 then
				if GameData.checkLevel( 20 ) then
					EquipmentData:MadeEquipment()
				end
			end
		end
	end

	function self.onSubclassButtonTouchTimer()
		if GameData.getServerTime() - self.beginTime >= 0.05 then
			TimerMgr.killPerFrame(self.onSubclassButtonTouchTimer)	

			local sender = self['item_'..EquipmentData.selectSubclass]
			local equipment = EquipmentData:getEquipmentForCondition( EquipmentData.selectType, EquipmentData.selectLevel, sender.index )
			EquipmentData:showEquipmentTips( sender, equipment)
		end
	end

	local item = nil
	for i=1,6 do
		item = self['item_'..i]
		item.index = i
		UIMgr.addTouchBegin( item, self.onSubclassButtonTouchBegin )
		UIMgr.addTouchEnded( item, self.onSubclassButtonTouchEnd ) 		
	end
		
	buttonDisable( self.button_type_1, true )
	buttonDisable( self.button_level_1, true )

	self:updateData()
end

function EquipmentUI:delayInit()
	self.infoview = getLayout( 'image/ui/EquipmentUI/EquipmentInfo.ExportJson' )
	self.infoview:retain()
	self.infoview.bg:loadTexture( 'image/ui/EquipmentUI/equipment_bg_right.jpg', ccui.TextureResType.localType )
	self.bg:addChild( self.infoview, 2 )
	self.infoview:setPosition( 410, 30 )

	function self.onButtonUserTouche(sender, EventType)
		EquipmentData:selectSuit( EquipmentData.selectType, EquipmentData.selectLevel )
		ActionMgr.save( 'UI', '[EquipmentUI] click [infoview.button_user]' )
	end

	UIMgr.addTouchBegin( self.infoview.button_user, self.onButtonUserTouche )	
	
	EquipmentData.selectLevel = GameData.user.equip_suit_level[EquipmentData.selectType]

    self:updateData()
end

function EquipmentUI:onShow()
	EventMgr.addListener( EventType.UserMergeReplace, self.updateData, self )
    EventMgr.addListener( EventType.UserEquipMerge, self.updateData, self )
	EventMgr.addListener( EventType.UserItemMerge, self.updateData, self )
	EventMgr.addListener( EventType.UserItemUpdate, self.updateData, self )
end 

function EquipmentUI:onClose()
	EventMgr.removeListener( EventType.UserMergeReplace, self.updateData )
    EventMgr.removeListener( EventType.UserEquipMerge, self.updateData )
    EventMgr.removeListener( EventType.UserItemMerge, self.updateData )
	EventMgr.removeListener( EventType.UserItemUpdate, self.updateData )

    TipsMgr.hideTips()
end 

function EquipmentUI:updateData()
	self:updateLeft()
	self:updateRight()
end

function EquipmentUI:updateLeft()
	self:levelButtonListDisable()
	self:typeButtonListDisable()
	for i=1,4 do
		if 5 - EquipmentData.selectType == i then
			buttonDisable( self['button_type_'..i], true )
		end

		if (5- i ) == EquipmentData.selectType then
			setButtonPoint( self['button_type_'..i], EquipmentData:CheckSolderEquipTempForType( 5-i ), cc.p( -15, 70 ) )
		else
			setButtonPoint( self['button_type_'..i], EquipmentData:CheckSolderEquipTempForType( 5-i ), cc.p( 0, 70 ) )
		end

		self['button_level_'..i].icon:setVisible( GameData.user.equip_suit_level[EquipmentData.selectType] == i )
		if i == EquipmentData.selectLevel then
			buttonDisable( self['button_level_'..i], true )
			self['button_level_'..i].icon:setPosition( 25, 24)
			setButtonPoint( self['button_level_'..i], EquipmentData:CheckSolderEquipTempForLevel( i ), cc.p( 110, 40 ) )
		else
			self['button_level_'..i].icon:setPosition( 25, 13 )
			setButtonPoint( self['button_level_'..i], EquipmentData:CheckSolderEquipTempForLevel( i ), cc.p( 100, 30 ) )
		end

		self:updateLevelButtonPostion( i )
	end

	local item = nil
	local equipment = nil
	local unEquipmentList = nil
	local quality = 1
	local jItem = nil
	for i=1,6 do
		item = self['item_'..i]
		-- item.icon:setVisible( true )
		quality = 1
		equipment = EquipmentData:getEquipmentForCondition( EquipmentData.selectType, EquipmentData.selectLevel, i )
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
			item.text_name:setString( 'T'..EquipmentData.selectLevel..EquipmentData:getEquipTypeName(EquipmentData.selectType)..EquipmentData:getEquipmentSubclassName(i) )
		end
		
		item:loadTexture( 'equipment_bg_item_' .. quality .. '.png', ccui.TextureResType.plistType ) 
		setButtonPoint( item, EquipmentData:checkSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, i ), cc.p( 115, 135 ), 10 )
	end

	local level = 0
	local equipSuit = EquipmentData:getEquipSuit( EquipmentData.selectLevel, const.kCoinEquipWhite, EquipmentData.selectType )
	if equipSuit ~= nil then 
		level = equipSuit.limit_level 
	end

	self.info.level:setString( level )
	self.info.type:loadTexture( 'equipment_t' .. EquipmentData.selectLevel .. '.png', ccui.TextureResType.plistType )
end

function EquipmentUI:updateRight()
	if self.infoview ~= nil then		
		self.infoview.info_all.info.value:setString( 'T'..EquipmentData.selectLevel )
		local infoData = EquipmentData:getEquipmentAllInfo( EquipmentData.selectType, EquipmentData.selectLevel )
		local infoIndex = 1
		for i,v in ipairs(EquipmentData.info_name_list) do
			if infoData[v] ~= nil then
				self.infoview.info_all['info_'..infoIndex]:setString( v..':')
				self.infoview.info_all['info_'..infoIndex].value:setString( infoData[v] )
				self.infoview.info_all['info_'..infoIndex]:setVisible(true)
				infoIndex = infoIndex + 1
			end
		end

		for i=infoIndex,14 do
			self.infoview.info_all['info_'..i]:setVisible(false)
		end

		self.infoview.info_suit:setPositionY( self.infoview.info_all:getPositionY() - math.floor( infoIndex / 2 + 2 ) * 21 + 90 )
		self.infoview.title_score_num:setString( EquipmentData:getEquipmentScoreForSuit( EquipmentData.selectType, EquipmentData.selectLevel ) )
		--套装属性
		local sets = nil
		local jEquipSuit = EquipmentData:getEquipSuit( EquipmentData.selectLevel, const.kCoinEquipWhite, EquipmentData.selectType )
		local suit_attr = jEquipSuit.odds[1];
		local jOdd = findOdd( suit_attr.first, suit_attr.second )
		local count = 0
		sets = self.infoview.info_suit.sets_1
		sets.text_info:setString( jOdd.description )
		count = EquipmentData:getEquipmentCountForQuality( EquipmentData.selectType, EquipmentData.selectLevel, const.kCoinEquipWhite )
		local color = nil
		if count < 6 then
			color = cc.c3b( 0x41, 0x3b, 0x36 )
		else
			color = cc.c3b( 0x31, 0xff, 0x16 )
		end
		sets:setString( 'T'..EquipmentData.selectLevel..'套装(  /6):' )
		sets.text_info:setColor( color )    
		sets:setColor( color )
		sets.text_count:setColor( color )	
        sets.text_count:setString( count )   	

		self.infoview.info_no:setVisible( count == 0 )
		self.infoview.info_all.info:setVisible( count ~= 0 )
        if count == 0 then
        	self.infoview.info_suit:setPositionY( 60 )
        end

		--套装品质属性
		local quality = const.kCoinEquipGreen
		for i=2,4 do
			sets = self.infoview.info_suit['sets_'..i]
			count = EquipmentData:getEquipmentCountForQuality( EquipmentData.selectType, EquipmentData.selectLevel, quality )
			local color = nil
			if count < 6 then
				color = cc.c3b( 0x41, 0x3b, 0x36 )
			else
				color = cc.c3b( 0x31, 0xff, 0x16 )
			end
			sets.text_info:setColor( color )    
			sets:setColor( color )
			sets.text_count:setColor( color )	

			sets.text_count:setString( count )
			jEquipSuit = EquipmentData:getEquipSuit( EquipmentData.selectLevel, quality, EquipmentData.selectType )
			suit_attr = jEquipSuit.odds[1];		
			jOdd = findOdd( suit_attr.first, suit_attr.second )	
			sets.text_info:setString( jOdd.description )
	        quality = quality + 1
		end

		if GameData.user.equip_suit_level[EquipmentData.selectType] ~= EquipmentData.selectLevel then
			local level = 0
			local equipSuit = EquipmentData:getEquipSuit( EquipmentData.selectLevel, const.kCoinEquipWhite, EquipmentData.selectType )
			if equipSuit ~= nil then 
				level = equipSuit.limit_level 
			end

			if GameData.getSimpleDataByKey("team_level") >= level and EquipmentData:checkSelectSuit( EquipmentData.selectType, EquipmentData.selectLevel ) then
				self.infoview.button_user:setVisible( true )
			else
				self.infoview.button_user:setVisible( false )
			end
			self.infoview.ico_useing:setVisible( false )
		else
			self.infoview.button_user:setVisible( false )
			self.infoview.ico_useing:setVisible( true )		
		end		
	end
end

function EquipmentUI:dispose()
	if self.infoview ~= nil then
		self.infoview:release()
	end
end

function EquipmentUI:updateLevelButtonPostion( i )
	self['button_level_'..i]:setPositionY( 470 )
	if i < EquipmentData.selectLevel then
		self['button_level_'..i]:setPositionX( 210 + 125 * ( i - 1 ) )
	elseif i == EquipmentData.selectLevel then
		self['button_level_'..i]:setPositionX( 210 + 125 * ( i - 1 ) + 10 )
		self['button_level_'..i]:setPositionY( 465 )
	else
        self['button_level_'..i]:setPositionX( 210 + 140 + 125 * ( i - 2 )  )  
	end
end

function EquipmentUI:typeButtonListDisable()
	for i=1,4 do
		buttonDisable( self['button_type_' .. i], false )
	end
end

function EquipmentUI:levelButtonListDisable()
	for i=1,4 do
		buttonDisable( self['button_level_' .. i], false )
	end
end