--[[
	Author  : 何遵祖
	date    : --
    class   : BagSale
	descript: 背包的出售界面以及相关功能
]]

local resPath = "image/ui/bagUI/"
BagSale = createUIClass("BagSale", resPath .. "BagSale.ExportJson", PopWayMgr.SMALLTOBIG, true)
BagSale.TypeSale = 'TypeSale'
BagSale.TypeUse = 'TypeUse'

function BagSale:ctor()
	self.maxCount = 20
	self.saleCount = 1

	local function addFunc(sender, eventType)
		if self.saleCount ~= self.maxCount then 
			self.saleCount = self.saleCount + 1
			self:renderUpdate()
		end  
		ActionMgr.save( 'UI', '[BagMain] click [sale.add]' )
	end
	UIMgr.addTouchEnded( self.add, addFunc )

	local function subFunc(sender, eventType)
		if self.saleCount ~= 1 then
			self.saleCount = self.saleCount - 1
			self:renderUpdate()
		end 
		ActionMgr.save( 'UI', '[BagMain] click [sale.sub]' )
	end 
    UIMgr.addTouchEnded( self.sub, subFunc )

	local function maxFunc(sender, eventType)
		self.saleCount = self.maxCount
		self:renderUpdate()
		ActionMgr.save( 'UI', '[BagMain] click [sale.max_panel]' )
	end 
	UIMgr.addTouchEnded( self.max_panel, maxFunc )

	local function saleFunc(sender, eventType)
		if self.userItem ~= nil then
			if self.type == BagSale.TypeSale then
		    	value = {}
	   			value.first = self.userItem.guid
	   			value.second = self.saleCount
			 	Command.run( 'item sell', self.userItem.bag_type, {value} )  
			else
				local jItem = findItem( self.userItem.item_id )
				if jItem.coin.cate == const.kCoinStrength then
					if StrengthData.isStrengthFull() then
						TipsMgr.showError( '体力太多，先消耗一些吧' )
						return 
					end
				end 
			 	Command.run( 'item use', const.kBagFuncCommon, self.userItem.guid, self.saleCount )
			end

			Command.run( 'ui hide', 'BagSale' )
		 end 
		 ActionMgr.save( 'UI', '[BagMain] click [sale.sale_panel]' )
	end 
	UIMgr.addTouchEnded( self.sale_panel, saleFunc )

	local function itemBox( sender, eventType )
		local postion = sender:getParent():convertToWorldSpace( cc.p(sender:getPositionX(), sender:getPositionY() - 100) )
		local item = findItem( self.userItem.item_id )
		TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, item )

		ActionMgr.save( 'UI', '[BagMain] click [ sale.itemBox ]' )		
	end
	UIMgr.addTouchEnded( self.item_icon, itemBox )

	self.bg_1.title_bg:loadTexture( 'image/ui/bagUI/bag_item_bg.png', ccui.TextureResType.localType )
end

function BagSale:updateData()
	if self.userItem ~= nil then
		local item = findItem( self.userItem.item_id )
		self.item_icon:loadTexture( ItemData.getItemUrl(self.userItem.item_id), ccui.TextureResType.localType )
		self.maxCount = self.userItem.count
		
		if self.type == BagSale.TypeSale then
			self.sale_panel.sale_btn:loadTextureNormal( 'bag_sale.png', ccui.TextureResType.plistType )

			self.sale_label_num:setString( '出售数量' )

			self.sale_panel:setPositionX( 96 )

			self.price:setVisible( true )
			self.price_num:setVisible( true )
			self.sum:setVisible( true )
			self.sum_num:setVisible( true )		

			self.salePrice = item.coin.val
			self.price_num:setString(string.format("%d", self.salePrice))	

			self:renderUpdate()
		else
			self.sale_panel.sale_btn:loadTextureNormal( 'bag_user.png', ccui.TextureResType.plistType )
			self.sale_panel:setPositionX( -36 )

			self.sale_label_num:setString( '使用数量' )

			self.price:setVisible( false )
			self.price_num:setVisible( false )
			self.sum:setVisible( false )
			self.sum_num:setVisible( false )	
		end
	end
end

function BagSale:onShow()
	self.saleCount = 1

	self:updateData()
	self.saleCount = self.maxCount
	self:renderUpdate()
end

function BagSale:onClose()
    a = 1
end

function BagSale:setData( value, type )
	if self.userItem ~= value then
		self.userItem = value
	end
	self.type = type
end 

function BagSale:renderUpdate()
	self.sale_num:setString( self.saleCount )
	if self.type == BagSale.TypeSale then
		self.sum_num:setString( self.salePrice * self.saleCount )
	end
end