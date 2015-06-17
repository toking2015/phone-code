EquipmentMadeUI = createUIClass("EquipmentMadeUI", "image/ui/EquipmentUI/EquipmentMadeUI.ExportJson", PopWayMgr.SMALLTOBIG)

function EquipmentMadeUI:ctor()
	self.isMade = true
	self.madeMatch = false

	self.leftItemViwe = getLayout( 'image/ui/EquipmentUI/EquipmentMadeInfo.ExportJson' )
	self:addChild( self.leftItemViwe )
	self.leftItemViwe:setPosition( 10, 15 ) 

	self.rightItemViwe = cloneLayout(self.leftItemViwe)
	self:addChild( self.rightItemViwe )
	self.rightItemViwe:setVisible(false)
	self.rightItemViwe:setPosition( 360, 15 )
	self.rightItemViwe.bg_two:loadTexture( 'equipment_made_bg_new.png', ccui.TextureResType.plistType )
	self.rightItemViwe.bg_one:loadTexture( 'equipment_made_bg_six.png', ccui.TextureResType.plistType )
	self.rightItemViwe.bg_one:setVisible( true )
	self.rightItemViwe.bg_four:loadTexture( 'equipment_made_item_bg_new.png', ccui.TextureResType.plistType )
	self.rightItemViwe.bg_five:loadTexture( 'equipment_made_bg_five.png', ccui.TextureResType.plistType )
	self.rightItemViwe.bg_sex:loadTexture( 'equipment_made_bg_five.png', ccui.TextureResType.plistType )
	
	self.rightItemViwe.title:loadTexture( 'equipment_made_title_new.png', ccui.TextureResType.plistType )
	self.rightItemViwe.button:loadTextureNormal( 'equipment_button_made.png', ccui.TextureResType.plistType )
	self.rightItemViwe.button.text:loadTexture( 'equipment_made_use_new.png', ccui.TextureResType.plistType )
	
	self.madeItemView = getLayout( 'image/ui/EquipmentUI/EquipmentMadeCompose.ExportJson' )
	self:addChild( self.madeItemView )
	self.madeItemView:setPosition( 360, 15 )
	self.madeItemView.text_buy:setString( '' )

	function self.onButtonTouch(sender, eventType)
		self:madeEquip()
		ActionMgr.save( 'UI', '[EquipmentMadeUI] click [madeItemView.button]' )
	end
	UIMgr.addTouchEnded( self.madeItemView.button, self.onButtonTouch )

	local function itemTouchBegin(target)
		local postion = target:getParent():convertToWorldSpace( cc.p(target:getPositionX(), target:getPositionY() - 100) )
		if self.item_1 ~= target and target.item_data then
			TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, target.item_data )
		else
			local item = EquipmentData.equipmentMadeData.jItem
			if item then
				local equipementLevel = EquipmentData.selectLevel
				local equipementType = EquipmentData:getEquipTypeName( EquipmentData.selectType )
				local equipementSubclass = EquipmentData:getEquipmentSubclassName( EquipmentData.selectSubclass )
				local equipementOccupation = EquipmentData:getEquipTypeOccupation( EquipmentData.selectType )

				local info = 'T' .. equipementLevel .. equipementType .. equipementSubclass .. ',' .. item.limitlevel .. '级以下' .. equipementOccupation .. '将自动穿戴'
				TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, info )
			end
		end
	end

	function self.boxSelectTouch(target)
		EquipmentData.isBuy = not EquipmentData.isBuy

		if EquipmentData.isBuy == false then
			self.cargos = nil
		end
		
		self:updateData()
		self:questMatch()
		ActionMgr.save( 'UI', '[EquipmentMadeUI] click [madeItemView.bg_box_select]' )
	end
	self.madeItemView.bg_box_select:setTouchEnabled( true )
	UIMgr.addTouchEnded( self.madeItemView.bg_box_select, self.boxSelectTouch )

	function self.leftButtonTouch(target)
		self.isMade = true
		local userItem = EquipmentData:getSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
		if userItem then
			local function callBack()
				Command.run( 'equip replace', 0, userItem.guid )
			end
			local isLower, quality = EquipmentData:checkNewThanOld( true )	
			if isLower then
				showMsgBox( '你当前选择的装备品质为【'..ItemData.qualityName(quality)..'色】，[br]确定放弃更高品质的装备？', callBack )
			else
				callBack()
			end
		end
		ActionMgr.save( 'UI', '[EquipmentMadeUI] click [leftItemViwe.button]' )
	end

	UIMgr.addTouchEnded( self.leftItemViwe.button, self.leftButtonTouch )

	function self.rightButtonTouch(target)
		self.isMade = true
		local userItem = EquipmentData:getSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
		if userItem then
			local function callBack()
				Command.run( 'equip replace', 1, userItem.guid )
			end
			local isLower, quality = EquipmentData:checkNewThanOld( false )	
			if isLower then
				showMsgBox( '你当前选择的装备品质为【'..ItemData.qualityName(quality)..'色】[br]，确定放弃更高品质的装备？', callBack )
			else
				callBack()
			end
		end
		ActionMgr.save( 'UI', '[EquipmentMadeUI] click [rightItemViwe.button]' )
	end

	UIMgr.addTouchEnded( self.rightItemViwe.button, self.rightButtonTouch )
end

function EquipmentMadeUI:delayInit()
	if self.madeItemView then
		self.madeItemView.bg_two:loadTexture( 'image/ui/EquipmentUI/equipment_made_bg_materia_two.png', ccui.TextureResType.localType )
	end
end

function EquipmentMadeUI:onShow()
	performNextFrame(self, self.questMatch, self)
	performNextFrame(self, self.updateData, self)

	EventMgr.addListener( EventType.UserEquipMerge, self.updateMade, self )
	EventMgr.addListener( EventType.UserMergeReplace, self.updateReplace, self )
	EventMgr.addListener( EventType.MarketBatchMatch, self.updateBatchMatch, self )
	EventMgr.addListener( EventType.MarketBatchBuy, self.updateBatchBuy, self )
end 

function EquipmentMadeUI:onClose()

	if self.waitBuyId ~= nil then
		TimerMgr.killTimer( self.waitBuyId )
		self.waitBuyId = nil
	end

	EventMgr.removeListener( EventType.UserEquipMerge, self.updateMade )
	EventMgr.removeListener( EventType.UserMergeReplace, self.updateReplace )
	EventMgr.removeListener( EventType.MarketBatchMatch, self.updateBatchMatch )
	EventMgr.removeListener( EventType.MarketBatchBuy, self.updateBatchBuy )
end

function EquipmentMadeUI:updateData()
	if EquipmentData.equipmentMadeData.noEquipment ~= nil then
		local equipment = EquipmentData:getEquipmentForCondition( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
		EquipmentMadeUI:updateDataInfo( self.leftItemViwe, equipment )
		
		local right_equipment = EquipmentData:getSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
		local left_score = EquipmentData:getEquipmentScore(equipment, EquipmentData.selectLevel)
		local right_score = EquipmentData:getEquipmentScore(right_equipment, EquipmentData.selectLevel)
		if right_equipment and left_score < right_score then
			self.leftItemViwe.score_num_2:setVisible( true )
			self.leftItemViwe.score_num_2:setString( left_score )
			self.leftItemViwe.score_num_1:setVisible( false )
		else
			self.leftItemViwe.score_num_1:setVisible( true )
			self.leftItemViwe.score_num_1:setString( left_score )
			self.leftItemViwe.score_num_2:setVisible( false )
		end
			
		local jItem = EquipmentData.equipmentMadeData.jItem
		if self.isMade == true and EquipmentData:getSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass ) == nil then
			self.leftItemViwe.button:setVisible( false )
			self.madeItemView:setVisible( true )
			self.rightItemViwe:setVisible( false )

			self.madeItemView.box_select:setVisible( EquipmentData.isBuy )

	        ItemData.setItemUlr( self.madeItemView.item_1.icon, EquipmentData.equipmentMadeData.jItem.id )
	        self.madeItemView.texts_name_1:setString( jItem.name )

			local index = 2
			local item = nil
			local item_data = 1
			local userCount = 0
			local cost_price = 0
			for k,v in pairs(EquipmentData.equipmentMadeData.noEquipment.materials) do
				userCount = 0
				if v["cate"] == trans.const.kCoinItem then
					item = self.madeItemView['item_'..index ]
					item_data = findItem( v.objid )
					userCount = ItemData.getItemCount( v.objid, const.kBagFuncCommon )
					ItemData.setItemUlr( item.icon, v.objid )

					if self.cargos and userCount < v.val then
						userCount = v.val
					end
	                
					if userCount >= v.val then
                        item.text_count:setColor( cc.c3b( 0x6C, 0xFF, 0x00 ) )
					else
                        item.text_count:setColor( cc.c3b( 0xFF, 0x00, 0x00 ) )
					end
					item.buy = userCount < v.val

                    item.text_count:setString( userCount ..'/'.. v.val )
					item.item_data = item_data

					index = index + 1
				else
					cost_price = cost_price + v.val
				end
			end

			if self.cargos then
				local market = nil
				local percent = 250
				for k,v in pairs(self.cargos) do
					market = findMarket( v.coin.objid )
					if market then
						if v.cargo_id ~= 0 then
							percent = v.percent
						else
							percent = 250
						end
						cost_price = cost_price + math.floor( market.value * v.coin.val * percent / 100 )
					end
				end
			end

			self.madeItemView.text_price:setString( cost_price )			
		else
			self.leftItemViwe.button:setVisible( true )
			self.madeItemView:setVisible( false )
			self.rightItemViwe:setVisible( true )

			right_equipment = EquipmentData:getSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
            EquipmentMadeUI:updateDataInfo( self.rightItemViwe, right_equipment )
			
            left_score = EquipmentData:getEquipmentScore(equipment, EquipmentData.selectLevel)
            right_score = EquipmentData:getEquipmentScore(right_equipment, EquipmentData.selectLevel)
			if left_score <= right_score then
				self.rightItemViwe.score_num_1:setVisible( true )
                self.rightItemViwe.score_num_1:setString( right_score )
				self.rightItemViwe.score_num_2:setVisible( false )
			else
				self.rightItemViwe.score_num_2:setVisible( true )
                self.rightItemViwe.score_num_2:setString( right_score )
				self.rightItemViwe.score_num_1:setVisible( false )
			end
		end
	end
end

function EquipmentMadeUI:updateDataInfo( info, userItem )
	info.text_name:setString( 'T'.. EquipmentData.selectLevel..EquipmentData:getEquipTypeName( EquipmentData.selectType )..'套装' )
	info.text_type:setString( '(' .. EquipmentData:getEquipmentSubclassName( EquipmentData.selectSubclass ) .. EquipmentData.selectLevel .. '阶)' )

	local jItem = nil
	local quality = 1
	if userItem == nil then
		jItem = EquipmentData:getNoEquipment( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass )
	else
		jItem= findItem( userItem.item_id )
		quality = ItemData.getQuality( jItem, userItem )
	end

	ItemData.setItemUlr( info.item.icon, jItem.id )
	info.item:loadTexture( 'image/ui/bagUI/itembg/ItemBg_' .. quality ..'.png', ccui.TextureResType.localType ) 

	local info_index = 1
	if userItem then
		--一级属性
		local jEffect = nil
		for k,v in pairs(jItem.attrs) do
			if v.first ~= 0 then
				jEffect = findEffect( v.first )
				if jEffect then
	                info['info_'..info_index]:setString( jEffect.desc..':' )
	    			info['info_'..info_index].value:setString( math.floor( v.second * ( 1 + userItem.main_attr_factor / 10000 ) ) )
	    			info['info_'..info_index]:setVisible(true)
	    			info_index = info_index + 1
	    		end
			end
		end

		--随机属性
		local slave_attr = nil
		for k,v in pairs(userItem.slave_attrs) do
	        if v ~= 0 then
			    slave_attr = jItem.slave_attrs[v]
			    if slave_attr then
	    			jEffect = findEffect( slave_attr.first )
	    			if jEffect and info_index < 6 then
	                    info['info_'..info_index]:setString( jEffect.desc..':' )
	        			info['info_'..info_index].value:setString( math.floor( slave_attr.second * ( 1 + userItem.slave_attr_factor / 10000 ) ) )
	        			info['info_'..info_index]:setVisible(true)
	        			info_index = info_index + 1
	        		end
	    		end
			end
		end	
	end

	for i=info_index,5 do
		info['info_'..i]:setVisible(false)
	end
end

function EquipmentMadeUI:updateMade( item_id )
	self.isMade = false
	self:showEffectMade( item_id )
    
    -- self:updateData()
	-- self:questMatch()
end

function EquipmentMadeUI:showEffectMade( item_id )
	local effectName = 'dat-tx-01'
	local prePath = "image/armature/ui/equipmentUI/" .. effectName .. "/"  
	local jItem = findItem( item_id )
	local effect = nil

	local complete = function()
		-- local flyComplete = function()
		-- 	TipsMgr.showSuccess( '锻造'.. jItem.name .. '成功' )
		-- end

		TipsMgr.floatingNode( cc.Sprite:create( 'image/ui/EquipmentUI/equipment_made_success.png' ) )

		local remove = function()
			self:updateData()
		end		
		effect:removeNextFrame( remove )
	end 

	effect = ArmatureSprite:addArmature(prePath .. effectName .. ".ExportJson", effectName, 'EquipmentMadeUI', self, self:getSize().width/2, self:getSize().height/2, complete, 2, 1 )
end

function EquipmentMadeUI:showEffectSearch( item )
	local effectName = 'ss-tx-01'
	local prePath = "image/armature/ui/equipmentUI/" .. effectName .. "/"
    local effect = nil
	LoadMgr.loadArmatureFileInfo(prePath .. effectName .. ".ExportJson", LoadMgr.SCENE, "main")  
	effect = ArmatureSprite:addArmature(prePath .. effectName .. ".ExportJson", effectName, 'EquipmentMadeUI', item, 35, 35, nil, 100, 100 )
	effect:setScaleX( 0.7 )
	effect:setScaleY( 0.7 )
	item.effect = effect
end 

function EquipmentMadeUI:updateReplace( is_replace )
	self.isMade = true

	self:updateData()
	self:questMatch()

	self.madeItemView.button:setTouchEnabled( true )

	if is_replace == 1 and EquipmentData.autoTips and EquipmentData.selectLevel > 1 then
		EquipmentData:selectSuit( EquipmentData.selectType, EquipmentData.selectLevel )
		EquipmentData.autoTips = false
	end
end

function EquipmentMadeUI:updateBatchMatch( data )
	self:removeAllSeachEffect()

	if data.result == 0 then
		self.cargos = data.cargos

		if self.madeMatch then
            self:madeEquip()
		end
	else
		self.cargos = nil
		self.madeMatch = false
		TipsMgr.showError(  '拍卖行材料不够' )
	end
	self:updateData()

	self.madeItemView.button:setTouchEnabled( not self.madeMatch )
	self.madeMatch = false
end

function EquipmentMadeUI:removeAllSeachEffect()
	if self.madeItemView.item_2.effect then
		self.madeItemView.item_2.effect:removeFromParent()
		self.madeItemView.item_2.effect = nil
	end

	if self.madeItemView.item_3.effect then
		self.madeItemView.item_3.effect:removeFromParent()
		self.madeItemView.item_3.effect = nil
	end	
end

function EquipmentMadeUI:updateBatchBuy( data )
	if self.waitBuyId ~= nil then
		TimerMgr.killTimer( self.waitBuyId )
		self.waitBuyId = nil
		self.madeItemView.text_buy:setString( '' )
	end
	
    if data.result == 0 then
		self:sendMade()
	else
	   	local info = ''
	   	if data.result == err.kErrCoinLack then
	   		if AlteractData.canShow(const.kCoinMoney) then
           		info = ''
            	AlteractData.showByData(const.kCoinMoney)
	   		else
	           info = '金币不足'
	   		end
	   	else
	       info = '材料已经出售'
	   	end
		TipsMgr.showError( info )
		self.madeItemView.button:setTouchEnabled( true )
		self.cargos = nil
		self:updateData()
--		self:questMatch()
	end
end

function EquipmentMadeUI:questMatch()
	if EquipmentData.isBuy then
		self.madeItemView.button:setTouchEnabled( false )
		if not ( self.isMade == true and EquipmentData:getSoldierEquipTemp( EquipmentData.selectType, EquipmentData.selectLevel, EquipmentData.selectSubclass ) ) then
			local searchList = self:checkMade()
			Command.run( 'auction match list', searchList )
			if self.madeItemView.item_2.buy then
				self:showEffectSearch( self.madeItemView.item_2 )
			end

			if self.madeItemView.item_3.buy then
				self:showEffectSearch( self.madeItemView.item_3 )
			end
		end			
	else
		self.madeItemView.button:setTouchEnabled( true )
		self:removeAllSeachEffect()
	end	
end

function EquipmentMadeUI:madeEquip()
	self:removeAllSeachEffect()
	if EquipmentData.equipmentMadeData.noEquipment ~= nil then
		local limit_level = EquipmentData.equipmentMadeData.noEquipment.limit_level
        if GameData.checkLevel( limit_level ) then
        	local searchList = self:checkMade()
    		self.madeItemView.button:setTouchEnabled( false )
			if #searchList == 0 then
				EquipmentMadeUI:sendMade()
            elseif EquipmentData.isBuy then
            	if self.cargos then
	                Command.run( 'auction buy list', self.cargos, const.kPathMarketAutoBuy )

					local function waitBuy()
						local pointCount = DateTools.getMiliSecond() / 1000 % 3
						local info = '材料购买中'
						for i=1, pointCount do
							info = info .. '.'
						end
						
						if self.madeItemView then
							self.madeItemView.text_buy:setString( info )
						end
					end     

	            	self.waitBuyId = TimerMgr.startTimer(waitBuy,1)
	            else
	            	self.madeMatch = true
					self:questMatch()
	            end
            else
            	TipsMgr.showError( '合成材料不够' )
            end
        else
			TipsMgr.showError( '需要战队等级'..limit_level )
        end
	end
end

function EquipmentMadeUI:checkMade()
	local userCount = 0
	local list = {}
	for k,v in pairs(EquipmentData.equipmentMadeData.noEquipment.materials) do
		if v["cate"] == trans.const.kCoinItem then
			userCount = ItemData.getItemCount( v.objid, const.kBagFuncCommon )
			if userCount < v.val then
				table.insert( list, { cate=v.cate,objid=v.objid, val=v.val - userCount} )
			end
		end
	end
	return list
end

function EquipmentMadeUI:sendMade()
	SoundMgr.playEffect("sound/ui/cast.mp3")
    Command.run( 'equip merge', EquipmentData.equipmentMadeData.noEquipment.id )
    if self.madeItemView then
    	self.madeItemView.button:setTouchEnabled( false )
    end
    self.cargos = nil
end


function EquipmentMadeUI:getRightButton()
	if self.rightItemViwe and self.rightItemViwe:isVisible() then 
		return self.rightItemViwe.button
	end
	return nil
end