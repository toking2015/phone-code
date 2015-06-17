local prePath = 'image/ui/VipActivityUI/'
Item = createLayoutClass('Item', ccui.Layout)

function Item:create(data, size)
	local view = Item.new(data, size)

	view:updateData(data)
	view:showTips(data)

	return view
end

function Item:ctor(coin, size)
	size = size or cc.size(102, 102)
	local scale = size.width/102 -- 缩放比例
	local width, height = 102 * scale, 102 * scale
	self:setSize(cc.size(width, height))
	self.scale = scale

	if not self.w then

	end

	self:init()

	self:setTouchEnabled(false)
	local function showItemTips()
	    ActionMgr.save( 'UI', 'Item click showTips' )
	    if coin then
	        local postion = self:getParent():convertToWorldSpace( cc.p(self:getPositionX(), self:getPositionY() - 100) )
	        if coin.cate == const.kCoinItem then
	            local item = findItem( coin.objid )
	            TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, item )
	        else
	            local info = CoinData.getCoinName( coin.cate, coin.objid )
	            TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, info .. '*' ..coin.val )
	        end
	    end
    end
	UIMgr.registerScriptHandler(self, showItemTips, cc.Handler.EVENT_TOUCH_BEGAN, true)

end

function Item:init()
	local scale = self.scale
	local width, height = 102 * scale, 102 * scale
	local bg = ccui.ImageView:create("image/ui/bagUI/itembg/ItemBg_1.png")
	bg:setScale(scale)
	bg:setPosition(cc.p(width/2, height/2))
	bg:setTouchEnabled(false)
	self:addChild(bg)
	self.bg = bg

	local icon = ccui.ImageView:create()--prePath .. "white_item_bg.png"
	icon:setPosition(cc.p(width/2, height/2))
	icon:setScale(scale)
	icon:setTouchEnabled(false)
	self:addChild(icon)
	self.icon = icon

	local num_url = "image/ui/bagUI/bag_num.png"
	local num = UIFactory.getTextAtlas(self, "0123456789", num_url, 19, 19, '0', 0)
	num:setAnchorPoint(cc.p(1, 0.5))
	num:setPosition(cc.p(96, 15))
	num:setTouchEnabled(false)
	self.num = num

	self:other()
end

function Item:other()
end

function Item:updateData(coin)
	local url = CoinData.getCoinUrl(coin.cate,coin.objid)
	self.icon:loadTexture(url,ccui.TextureResType.localType)

	local val = coin.val
	if val/10000 >= 1 then
		local size = self.num:getContentSize()
		local posX, posY = self.num:getPositionX(), self.num:getPositionY()
		local w = UIFactory.getSpriteFrame('W.png', self, posX, posY-2)
		w:setAnchorPoint(cc.p(1, 0.5))
		self.num:setString(val/10000)
		self.num:setPositionX(posX - w:getBoundingBox().width)
	else
		self.num:setString(val)
	end
	if coin.cate == const.kCoinItem	then
		url = ItemData.getItemBgUrl(coin.objid)
		self.bg:loadTexture(url,ccui.TextureResType.localType)
	end
end

function Item:showTips(coin)
	
end