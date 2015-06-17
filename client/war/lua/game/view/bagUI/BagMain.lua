--[[
	Author: 何遵祖
	date  : --
    class : BagMain
	descript:
	    背包的一级界面以及相关功能
]]
local resPath = "image/ui/bagUI/"

require("lua/game/view/bagUI/BagItem.lua")
require("lua/game/view/bagUI/BagSale.lua")
require("lua/game/view/bagUI/BagUse.lua")

BagMain = createUIClass("BagMain", resPath .. "BagMain.ExportJson", PopWayMgr.SMALLTOBIG )
BagMain.sceneName = "common"

function BagMain:ctor()
	self.isUpRoleTopView = true
	self.item_contat={}

	self.bag_label:loadTexture( 'image/ui/bagUI/bag_label.png', ccui.TextureResType.localType )

    local btnList = {self.btn_all, self.btn_consumables, self.btn_soul, self.btn_material }
    local subMenuNames = {"bag_all_", "bag_consumables_","bag_soul_", "bag_material_"}
    local function btnHandler(index)
		ItemData.select_index = index
		self:setCurrentState( index )
    end
    UIFactory.initSubMenu(btnList, subMenuNames, btnHandler, 1, ItemData.select_index )	

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
        	item.item_num_line:setVisible(false)
        	item.btn_item_delect:setVisible(false)
        	if jItem ~= nil then
	       	 	item.item_quality:setVisible(true)
		    else
		    	item.item_quality:setVisible( false )
			end
			setButtonPoint( item, ItemData:checkPackage( userItem), cc.p(100,100), 101 )
	        --item.item_quality:loadTexture( ItemData.getItemBgUrl( quality ), ccui.TextureResType.localType )
	        BitmapUtil.setTexture(item.item_quality, ItemData.getItemBgUrl( quality ))
			self:setUserItem( item, userItem ) 
	  		item.index = dataIndex
        end
    end

    function self.create()
        local content = display.newLayer()
        content:setAnchorPoint(cc.p(0,0))
        content:setPosition(cc.p(0, 0))
        content:setTag(1)
        content.itemList = {}
        
        for i=1,4 do
            local view = self:createItem()
            content:addChild(view)
            view:setPosition((i - 1) * 110,0)
            content.itemList[i] = view

            if self.firstItem == nil then
            	self.firstItem = view
            end
        end
        return content
    end
    
    function self.touchCell( conctent, index, itemIndex )
    	self:updateSelect( index, itemIndex )
        self:setSelectItemIndex( index )
        --self:updateData()
    	if ItemData.item_index <= #self.userItem_list then
        	self.userItem = self.userItem_list[ItemData.item_index]
	    else
	        self.userItem = nil
	    end
        self:updateRight()

        ActionMgr.save( 'UI', '[BagMain] click [item'..itemIndex..']' )
    end

    self.tableView = createTableView({}, self.create,self.updateItemData, cc.p( 548, 30 ),cc.size(465,460), cc.size(465,115), self, nil, 4 ,4)
end

function BagMain:onShow()
	performNextFrame(self, self.delayOnShow, self)
end

function BagMain:delayOnShow()
    EventMgr.addListener(EventType.UserItemUpdate, self.updateData,self)

    self.infoview = getLayout( 'image/ui/bagUI/BagInfo.ExportJson' )
	self.infoview:retain()
	self:addChild( self.infoview, 1 )
	self.infoview:setPosition( 128, 10 )
	self.infoview.bg_right:loadTexture( 'image/ui/bagUI/bg_info.png', ccui.TextureResType.localType )
	
    self.infoview.item_info_down.item_descript:setString('')
    self.infoview.item_info_down.item_descript:setPosition( cc.p( 0, 300 ) )
    
	--右边界面处理
	local function saleFunc(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.userItem then
				BagSale:setData( self.userItem, BagSale.TypeSale )
				PopMgr.popUpWindow("BagSale", false, PopUpType.SPECIAL)
				-- EventMgr.dispatch( EventType.bagSaleUpdate, self.userItem )
			end
			ActionMgr.save( 'UI', '[BagMain] click [infoview.btn_sale]' )
		end 
	end
	self.infoview.btn_sale:addTouchEventListener( saleFunc )

	local function gainFunc(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.userItem then
                local jItem = findItem( self.userItem.item_id )
				if(AlteractData.canShow(const.kCoinItem,self.userItem.item_id)) then
					CoinData.checkLackCoin(const.kCoinItem,nil,self.userItem.item_id)
				elseif jItem then
					if jItem.buff.cate == const.kItemUseAddRewardRandom then
						BagSale:setData( self.userItem, BagSale.TypeUse )
						PopMgr.popUpWindow("BagSale", false, PopUpType.SPECIAL )
					elseif jItem.buff.cate == const.kItemUseAddRewardIndex then
						BagUse:setData( self.userItem )
						PopMgr.popUpWindow("BagUse", false, PopUpType.SPECIAL )
					end
				end
			end
			ActionMgr.save( 'UI', '[BagMain] click [infoview.btn_gain]' )
		end 
	end 
	self.infoview.btn_gain:addTouchEventListener(gainFunc)		

	performNextFrame(self, self.updateData, self)
end 

function BagMain:onClose()
    EventMgr.removeListener(EventType.UserItemUpdate, self.updateData)
end 

function BagMain:setNoneBg( value )

    if nil == self.noneBg and value then 
        self.noneBg = ccui.ImageView:create( "image/ui/bagUI/bg_none.png", ccui.TextureResType.localType )
        self.noneBg:setAnchorPoint( cc.p( 0, 0 ) )
        self.noneBg:retain()
        self.infoview:addChild(self.noneBg)
        self.noneBg:setPosition(12,359)
	end
	if nil == self.noneTips and value then  
        self.noneTips = UIFactory.getText("亲！你还要继续努力哦", self, 215, 65, 22, cc.c3b(0xff, 0xc2, 0x74), nil, nil, 2)
        self.noneTips:setAnchorPoint( cc.p( 0, 0 ) )
        self.noneTips:retain()
        self.infoview.item_info_down:addChild(self.noneTips)
        self.noneTips:setPosition(160,315)
	end
	if self.noneBg~= nil then
  		self.noneBg:setVisible(value)
	end
	if self.noneTips ~= nil then
		self.noneTips:setVisible(value)
	end
	if value then
		self.infoview.item_info_up:setVisible(false)
	else
		self.infoview.item_info_up:setVisible(true)
	end
	
end

function BagMain:updateData()
	self.userItem_list = ItemData.getItemListForType( const.kBagFuncCommon, ItemData.select_state )
	setButtonPoint( self.btn_consumables, ItemData:checkBagPackage(), cc.p( 5, 70 ), 10 )
	self.dataLen = math.max(16,table.getn(self.userItem_list))
    if #self.userItem_list > 0 then
        if ItemData.item_index > #self.userItem_list then
            ItemData.item_index = #self.userItem_list
        end
        self:setNoneBg(false)
    else
        ItemData.item_index = 1
        self:setNoneBg(true)
    end

    if ItemData.item_index <= #self.userItem_list then
        self.userItem = self.userItem_list[ItemData.item_index]
    else
        self.userItem = nil
    end
    	
    self:updateRight()
	self:updateLeft()
end

function BagMain:dispose()
 	if self.m_selectRect then
	 	self.m_selectRect:release()
	 	self.m_selectRect = nil
	 end
	 if self.noneTips then
	 	self.noneTips:release()
	 	self.noneTips = nil
	 end
	 if self.noneBg then
	 	self.noneBg:release()
	 	self.noneBg = nil
	 end
	 if #self.item_contat > 0 then
	 	for i=1,#self.item_contat do 
	 		self.item_contat[i]:release()
	 	end
	 end
	 self.item_contat = nil
 	self.select_item_ui = nil
 	self.userItem = nil

 	if self.infoview then
 		self.infoview:release()
 	end
 end

function BagMain:createItem()
	local item = BagItem:create( resPath .. "Item.ExportJson" )
	item:setTouchEnabled(false)
	item:retain()
	table.insert(self.item_contat,item)
	return item	
end 

function BagMain:updateRight()
	if self.infoview ~= nil then
		local count = 0
		local price = 0
		local jItem = nil
		local name = nil
		local desc = ''
		local id = 0
		local quality = 1

		if self.userItem ~= nil then
			count = self.userItem.count
			id = self.userItem.item_id
			jItem = findItem( id )
            quality = ItemData.getQuality( jItem, self.userItem )
		end

		if jItem ~= nil then
			price = jItem.coin.val
			name = jItem.name
			desc = jItem.desc
		end

		if quality > 1 then
			self.infoview.item_info_up.item_icon_bg:setVisible(true)
			self.infoview.item_info_up.item_icon_bg:loadTexture( ItemData.getItemBgUrl( quality ), ccui.TextureResType.localType )
		else
			self.infoview.item_info_up.item_icon_bg:setVisible(false)
		end
		self.infoview.item_info_up.item_name_bg:loadTexture( 'image/ui/bagUI/itembg/bg_name_' ..quality .. '.png', ccui.TextureResType.localType )

		self.infoview.item_info_up.item_count:setString( count )
		self.infoview.item_info_up.item_price:setString( price )	
    	self.infoview.item_info_up.item_name:setColor(ItemData.getItemColor(quality))		
		self.infoview.item_info_up.item_name:setString(name)
	    -- self.infoview.item_info_down.item_descript:setString(desc)	
        -- desc = '[font=ITEM_1]'..desc..'replace'..desc	
        desc = '[font=ITEM_1]'..desc
        desc = string.gsub(desc, 'replace', '[br][font=ITEM_1]')
        if jItem and not GameData.checkLevel( jItem.limitlevel ) then
        	desc = desc..'[br][font=ITEM_2]使用等级：'..jItem.limitlevel
        end
        if self.userItem and state.has( self.userItem.flags, const.kCoinFlagBind ) then		
        	desc = desc..'[br][font=TIP_C_1]该物品已绑定，不能进行交易'
        end        
	    self.infoview.item_info_down.item_descript:removeAllChildren()
        RichTextUtil:DisposeRichText( desc, self.infoview.item_info_down.item_descript, nil, 33, 350 )
		ItemData.setItemUlr( self.infoview.item_info_up.item_icon, id )

	    if self.userItem == nil then
	    	self.infoview.btn_gain:setTouchEnabled( false )
	    	self.infoview.btn_sale:setTouchEnabled( false )
	    	self.infoview.btn_sale:setVisible(false)
	    else
	    	self.infoview.btn_sale:setVisible(true)
			self.infoview.btn_gain:setTouchEnabled( true )
			self.infoview.btn_sale:setTouchEnabled( true )

			local title_url = 'bag_get.png'
			if jItem and jItem.buff ~= 0 then
				title_url = 'bag_user.png'
			end

			self.infoview.btn_gain:loadTextureNormal( title_url, ccui.TextureResType.plistType )
	    end

	    if self.userItem and AlteractData.canShow(const.kCoinItem,self.userItem.item_id) or jItem and (jItem.buff.cate == const.kItemUseAddRewardRandom or jItem.buff.cate == const.kItemUseAddRewardIndex ) then
	    	self.infoview.btn_gain:setVisible( true )
	    	self.infoview.btn_sale:setPositionX(271)
	    else
	    	self.infoview.btn_gain:setVisible( false )
	    	self.infoview.btn_sale:setPositionX(207)
	    end

	    -- if self.userItem == nil then
	    	-- self.infoview.btn_sale:setVisible(true)
	    	-- self.infoview.btn_gain:setVisible( true )
	    	-- self.infoview.btn_sale:setPosition(271,40)
	    -- end

	 	local info_index = 1
    	local jEffect = nil
    	if jItem ~= nil then
	    	for k,v in pairs(jItem.attrs) do
	    		if v.first ~= 0 then
	    			jEffect = findEffect( v.first )
	    			if jEffect then
		                self.infoview.item_info_down['info_'..info_index]:setString( jEffect.desc..':' )
		    			self.infoview.item_info_down['info_'..info_index].value:setString( '+'..math.floor(v.second * ( 1 + self.userItem.main_attr_factor / 10000) ) )
		    			self.infoview.item_info_down['info_'..info_index]:setVisible(true)
		    			info_index = info_index + 1
		    		end
	    		end
	    	end
	    end
    
    	--随机属性
    	if self.userItem ~= nil then
	    	local slave_attr = nil
	    	for k,v in pairs(self.userItem.slave_attrs) do
	            if v ~= 0 then
	    		    slave_attr = jItem.slave_attrs[v]
	    		    if slave_attr then
		    			jEffect = findEffect( slave_attr.first )
		    			if jEffect then
			                self.infoview.item_info_down['info_'..info_index]:setString( jEffect.desc..':' )
                            self.infoview.item_info_down['info_'..info_index].value:setString( '+'..math.floor( slave_attr.second * ( 1 + self.userItem.slave_attr_factor / 10000 ) ) )
			    			self.infoview.item_info_down['info_'..info_index]:setVisible(true)
			    			info_index = info_index + 1
			    		end
		    		end
	    		end
	    	end
	    end
    
    	for i=info_index,6 do
    		self.infoview.item_info_down['info_'..i]:setVisible(false)
    	end    	
	end
end

function BagMain:updateLeft()
	self.tableView:reloadData()
	if #self.userItem_list <= 16 then
		self:setSliderCell(0)
	else
		self:setSliderCell(100)
	end
	if self.unSetPercent == true then
		self.unSetPercent = nil
	else
		-- self.sliderPosition = self.slider:getPercent()
	 --   	if self.sliderPosition ~= nil then
	 --   		self.slider:setPercent( self.sliderPosition )	
	 --   	end
	   	-- self:valueChanged(self.slider)
	end 	
	self:updateSelect()     	
end

function BagMain:setUserItem( item, userItem )
	item.userItem = userItem

	self:updateItemIcon( item, userItem );
	self:updateItemCount( item, userItem );
end

function BagMain:updateItemIcon( item, userItem )
	local id = 0;
	if( userItem ~= nil ) then
		id = userItem.item_id
	end
	
	item:setItemIcon( id )
end

function BagMain:updateItemCount( item, userItem )
	local count = nil
	if userItem ~= nil then
		count = userItem.count
	end
	item:setItemCount( count )
end

function BagMain:getSelect()
    if nil == self.m_selectRect then 
        self.m_selectRect = ccui.ImageView:create( "image/ui/bagUI/bag_select.png", ccui.TextureResType.localType )
        self.m_selectRect:setAnchorPoint( cc.p( 0, 0 ) )
        self.m_selectRect:retain()
	end
	return self.m_selectRect
end

function BagMain:updateSelect( index )
	if index == nil then
		if self.userItem then
			index = table.indexOf( self.userItem_list, self.userItem )
		end
	end

	local cell = nil
    local itemIndex = 1
    local cellIndex = 0
	if index ~= nil then
    	itemIndex = index % 4
    	cellIndex = math.floor( index / 4 )
    	if itemIndex == 0 then
    		itemIndex = 4
    		cellIndex = cellIndex - 1
    	end
        cell = self.tableView:cellAtIndex( cellIndex )
    end

    local item = nil 
    if cell then
    	item = cell:getChildByTag(1).itemList[itemIndex]
    end

    if item and item.userItem ~= nil then
		self:getSelect():setVisible( true )
	    self:getSelect():setPosition( -3, -2 )
	    if self:getSelect():getParent() ~= item then
            if self:getSelect():getParent() then
                self:getSelect():removeFromParent()
         	end
            item:addChild(self:getSelect(), 100)
	    end
   else
   		self:getSelect():setVisible( false )
   end
end

function BagMain:setCurrentState(value)
    ItemData.select_state = value
    self.unSetPercent = true

    self:updateData()
end

function BagMain:setSelectItemIndex( value )
	ItemData.item_index = value
end