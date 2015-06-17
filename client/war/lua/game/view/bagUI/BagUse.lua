local resPath = "image/ui/bagUI/"
BagUse = createUIClass("BagUse", resPath .. "BagUse.ExportJson", PopWayMgr.SMALLTOBIG)

function BagUse:ctor()
	local function okFun(sender, eventType)
        if self.index and self.index > 0 then
    		Command.run( 'item use', const.kBagFuncCommon, self.userItem.guid, 1, self.index ) 
    		ActionMgr.save( 'UI', '[BagMain] click [BagUse.button_ok]' )
            TimerMgr.runNextFrame( function () PopMgr.removeWindowByName( 'BagUse' ) end )
        else
            TipsMgr.showError("请选择奖励")
        end
	end 
    UIMgr.addTouchEnded( self.button_ok, okFun )

    local function itemBeginHandler(sender, eventType )
    	self.index = sender.index
    	ActionMgr.save( 'UI', '[BagMain] click [BagUse.item_'..self.index ..']')
    	self.m_selectRect:setVisible( true )
    	self.m_selectRect:setPosition( cc.p( sender:getPositionX()- 3, sender:getPositionY() - 1 ) )

        if sender.data then
            local postion = sender:getParent():convertToWorldSpace( cc.p(sender:getPositionX(), sender:getPositionY() - 100) )
            if sender.data.cate == const.kCoinItem then
                local item = findItem( sender.data.objid )
                TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, item )
            else
                local info = CoinData.getCoinName( sender.data.cate, sender.data.objid )
                TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, info .. '*' ..sender.data.val )
            end
        end
    end 

    self.itemList = {}
    local item = nil
    local itemName = nil
    for i=1,4 do
    	item = BagItem:create( resPath .. "Item.ExportJson" )
        item:setTouchEnabled( true )
    	self:addChild( item )
    	item:setScaleX( 75/105 )
    	item:setScaleY( 75/105 )
    	item:retain()
    	-- UIMgr.addTouchEnded( item, itemFun )
        UIMgr.addTouchBegin(item, itemBeginHandler)
    	table.insert( self.itemList, item )

        itemName = UIFactory.getLabel('', item, 0, 0, 26, cc.c3b(255, 221, 179), nil, cc.TEXT_ALIGNMENT_RIGHT, 1000)
        item.itemName = itemName
        itemName:setPosition( cc.p( 50, -10 ) )
    end

    self.m_selectRect = ccui.ImageView:create( "bag_select_user_.png", ccui.TextureResType.plistType )
    self.m_selectRect:setAnchorPoint( cc.p( 0, 0 ) )
	self.m_selectRect:setScaleX( 75/105 )
	self.m_selectRect:setScaleY( 75/105 )   
	self:addChild( self.m_selectRect ) 
    self.m_selectRect:setVisible( false )
end

function BagUse:updateData()
	if self.userItem then
		local itemOpenList = {}
		local list = GetDataList( 'ItemOpen' )
		for k,v in pairs(list) do
			if v.open_id == self.userItem.item_id then
                table.insert( itemOpenList, v )
			end
		end

        for k,v in pairs(self.itemList) do
            v:setVisible( false )
        end

        local item = nil
	    local reward = nil
		local coin = nil
        local itemIndex = 1
        local quality = 1
        local jItem = nil
        for i=1,4 do
            item = self.itemList[i]
            item.index = i
            if i <= #itemOpenList  then
                reward = findReward( itemOpenList[i].reward )
                coin = reward.coins[1]
	        	item.item_num_line:setVisible(false)
	        	item.btn_item_delect:setVisible(false)						
				item:setItemCount(coin.val)
				item.item_icon:loadTexture( CoinData.getCoinUrl( coin.cate, coin.objid ), ccui.TextureResType.localType )
				item:setVisible( true )
                item.data = coin
                if coin.cate >= const.kCoinEquipWhite and coin.cate <= const.kCoinEquipOrange then
                    quality = coin.cate - const.kCoinEquipWhite + 1
                elseif coin.cate == const.kCoinItem then
                    jItem = findItem( coin.objid )
                    quality = jItem.quality    
                end

                item.itemName:setColor(ItemData.getItemColor(quality)) 
                item.itemName:setString( CoinData.getCoinName( coin.cate, coin.objid ) )
			end

            item:setPosition( -75 + i* 135 , 130 )          
        end
	end
end

function BagUse:onShow()
	self:updateData()
end

function BagUse:dispose()
	for k,v in pairs(self.itemList) do
		v:release()
	end
	self.itemList = nil
end

function BagUse:setData( value )
	self.userItem = value
end 