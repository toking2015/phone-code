local resPath = "image/ui/FriendUI/"

require("lua/game/view/bagUI/BagItem.lua")

FriendItemSend = createUILayout("FriendItemSend", resPath .. "Friend_senditem.ExportJson", "FriendUI" )

function FriendItemSend:ctor( ... )
	local function btnHandler(sender,eveType )
		if eveType ~= ccui.TouchEventType.ended then
	        return
	    end
	    local name = sender:getName()
	    ActionMgr.save( 'UI', 'FriendItemSend click '..name )
	    FriendData:btnHandler(name,self.friend_data.friend_id)
	end
	UIMgr.addTouchEnded( self.btn_send, btnHandler )


	function self.onSubclassButtonTouchBegin(sender, EventType)
		ActionMgr.save( 'UI', 'FriendItemSend down Button_28' )
		EquipmentData.selectSubclass = sender.index
		--self.beginTime = GameData.getServerTime()
		--TimerMgr.callPerFrame( self.onSubclassButtonTouchTimer )
		local postion = self.Button_28:getParent():convertToWorldSpace( cc.p(self.Button_28:getPositionX(), self.Button_28:getPositionY() - 100) )
		TipsMgr.showTips( postion , TipsMgr.TYPE_STRING, '对每个好友每天最多能送10个物品，每个玩家每天最多能接受25个物品 ' )
	end

	function self.onSubclassButtonTouchEnd(sender, eventType )
		ActionMgr.save( 'UI', 'FriendItemSend up Button_28' )
		--TimerMgr.killPerFrame(self.onSubclassButtonTouchTimer)
		TipsMgr.hideTips()
	end

	UIMgr.addTouchBegin( self.Button_28, self.onSubclassButtonTouchBegin )
	UIMgr.addTouchEnded( self.Button_28, self.onSubclassButtonTouchEnd ) 	


	self:createItemSend()
end

function FriendItemSend:createItemSend( ... )
	self.item_contat = {}
    function self.create()
        local content = display.newLayer()
        content:setAnchorPoint(cc.p(0,0))
        content:setPosition(cc.p(0, 0))
        content:setTag(1)
        content.itemList = {}
        
        for i=1,3 do
            local view = self:createItem()
            content:addChild(view)
            view:setPosition((i - 1) * 91,0)
            content.itemList[i] = view

            if self.firstItem == nil then
            	self.firstItem = view
            end
        end
        return content
    end
    
    function self.touchCell( conctent, index, itemIndex )
    	ActionMgr.save( 'UI', 'FriendItemSend click BagItem' )
    	local userItem = self.userItem_list[index]
    	 local item = conctent.itemList[itemIndex]
    	if item and userItem then
    		FriendData:addLimitSellectData(userItem,self.friend_data)
    		self:updateItemSlect(item,userItem)
    	end
    end

    function self.updateItemData(data ,constant, dataIndex, itemIndex, widhtCount )
    	constant.index = dataIndex
    	dataIndex = widhtCount * ( dataIndex - 1 ) + itemIndex
        local item = constant.itemList[itemIndex]
        local userItem = self.userItem_list[dataIndex]
        local jItem = nil
        local quality = 0
        if userItem ~= nil then
            jItem = findItem( userItem.item_id )
        end
        quality = ItemData.getQuality( jItem, userItem )

        if item then
        	item.item_select:setVisible(false)
        	item.btn_item_delect:setVisible(false)
        	item.item_num_line:setVisible(false)
        	self:updateItemSlect(item,userItem)
        	if jItem ~= nil then
	       	 item.item_quality:setVisible(true)
		    else
		    	item.item_quality:setVisible( false )
			end
	        --item.item_quality:loadTexture( ItemData.getItemBgUrl( quality ), ccui.TextureResType.localType )
	        BitmapUtil.setTexture(item.item_quality, ItemData.getItemBgUrl( quality ))
			self:setUserItem( item, userItem ) 
	  		item.index = dataIndex
        end
    end


	self.tableView = createTableView({}, self.create,self.updateItemData, cc.p( 3, 100 ),cc.size(276,295), cc.size(264,91), self, self.slider, 3 ,4)
end

function FriendItemSend:setUserItem( item, userItem )
	self:updateItemIcon( item, userItem );
	self:updateItemCount( item, userItem );
end

function FriendItemSend:updateItemIcon( item, userItem )
	local id = 0;
	if( userItem ~= nil ) then
		id = userItem.item_id
	end
	
	item:setItemIcon( id )
end

function FriendItemSend:updateItemCount( item, userItem )
	local count = nil
	if userItem ~= nil then
		count = userItem.count
	end
	item:setItemCount( count )
end

function FriendItemSend:updateItemSlect( item ,userItem)
	if item and userItem then
		local selectCount = FriendData:getSlectItemCount(userItem)
		if selectCount and selectCount > 0 then
			item.btn_item_delect:setVisible(true)
			item.item_select:loadTexture( "image/ui/bagUI/bag_select.png", ccui.TextureResType.localType )
			item.item_select:setVisible(true)
			item.item_select:setPosition(57,57)
			item.item_num_line:setVisible(true)
			local s = item.item_num.getSize and item.item_num:getSize() or item.item_num:getContentSize()
			item.item_num_line:setPositionX(item.item_num:getPositionX() - s.width - 4)
			item.item_num_line.item_num_select:setString(selectCount)
		else
			item.btn_item_delect:setVisible(false)
			item.item_select:setVisible(false)
			item.item_num_line:setVisible(false)
		end
	end
end

function FriendItemSend:createItem()
	local item = BagItem:create( "image/ui/bagUI/Item.ExportJson" )
	item:setTouchEnabled(false)
	item:setScale(0.81,0.81)
	item:retain()
	table.insert(self.item_contat,item)
	local function btnHandler(sender,eveType )
		ActionMgr.save( 'UI', 'FriendItemSend click btn_item_delect' )
		if eveType ~= ccui.TouchEventType.ended then
	        return
	    end
	    local pitem = sender:getParent()
	    if pitem and  pitem.index then
		    local userItem = self.userItem_list[pitem.index]
	    	if userItem then
	    		FriendData:delLimitSellectData(userItem)
	    		self:updateItemSlect(pitem,userItem)
		    end
		end
	end
	UIMgr.addTouchEnded( item.btn_item_delect, btnHandler )
	return item	
end

function FriendItemSend:setFriendData( friend_data )
	self.friend_data = friend_data
	self:updateData()
end

function FriendItemSend:onShow( ... )
	self:updateData()
    EventMgr.addListener(EventType.FriendLimitChange, self.updateData,self )
    EventMgr.addListener(EventType.UserItemUpdate, self.updateData,self )
end

function FriendItemSend:dispose( ... )
	self.friend_data = nil
	if self.m_selectRect then
	 	self.m_selectRect:release()
	 	self.m_selectRect = nil
	 end
	 if #self.item_contat > 0 then
	 	for i=1,#self.item_contat do 
	 		self.item_contat[i]:release()
	 	end
	 end
end

function FriendItemSend:onClose( ... )
	TipsMgr.hideTips()
	EventMgr.removeListener(EventType.FriendLimitChange, self.updateData,self)
	EventMgr.removeListener(EventType.UserItemUpdate, self.updateData,self )
	self:dispose()
	FriendData:updateOrClearLimitSelcetData()
end

function FriendItemSend:updateData( ... )
	if self.tableView then
		self.userItem_list = ItemData.getItemListForCanExchange( const.kBagFuncCommon )
		self.dataLen = math.max(12,table.getn(self.userItem_list))
		self.tableView:reloadData()
		if self.friend_data then
			self.txt_count:setString(string.format("%d/%d",FriendData:getCanSendItemCount(self.friend_data.friend_id),FriendData:getMaxSendTimes( )))
		end
	end
end