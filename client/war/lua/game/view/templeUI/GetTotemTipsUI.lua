local prepath = "image/ui/AlternativesTipsUI/"
local url = prepath .. "AlternativesTipsUI_1.ExportJson"
GetTotemTipsUI = createUIClass("GetTotemTipsUI", url, PopWayMgr.SMALLTOBIG)

function GetTotemTipsUI:ctor( ... )
	self.title_txt:loadTexture("image/ui/AlternativesTipsUI/moreimg/".."txt_title.png", ccui.TextureResType.localType )
	self.itemList = {}

end

function GetTotemTipsUI:onShow( ... )
	-- body
end

function GetTotemTipsUI:onClose( ... )
	-- body
end

function GetTotemTipsUI:updateData( ... )
	local cate = AlteractData.cate
	local item_id = AlteractData.item_id
	local item_type = 1 item_type = AlteractData.item_type

	if not cate and not item_id and not item_type then
		return
	end
	local count = CoinData.getCoinByCate(cate,item_id)
	local jItem = nil
	local name = CoinData.getCoinName(cate,item_id)
	local quality = 4

	if item_id and item_id > 0 then
		jItem = findItem( item_id )
	end
	if jItem then
		quality = ItemData.getQuality( jItem )
	end

	self.bg_item:loadTexture(ItemData.getItemBgUrl(quality), ccui.TextureResType.localType )
	self.bg_item.icon_item:loadTexture(CoinData.getCoinUrl(cate,item_id), ccui.TextureResType.localType )

	self.bg_item.icon_item:setPosition(cc.p(self.bg_item:getContentSize().width/2,self.bg_item:getContentSize().height/2))

	self.bg_name:loadTexture( 'image/ui/bagUI/itembg/bg_name_' ..quality .. '.png', ccui.TextureResType.localType )
	self.bg_name.txt_name:setColor(CoinData.getCoinC3B(cate,item_id))		
	self.bg_name.txt_name:setString(name)
	self.bg_name.txt_name:setPosition(cc.p(self.bg_name:getContentSize().width/2,self.bg_name:getContentSize().height/2))
	self.item_count:setString( count )
end

-- function AlteractyTipsUI:getItem( index ,alterdata)
-- 	local item = nil
-- 	if index < #self.itemList then
-- 		item = self.itemList[index]
-- 	else
-- 		item = AlteractyTipsItem:new()

-- 		local function touchEndedHandler(target)
-- 			 ActionMgr.save( 'UI', 'AlteractyTipsUI click AlteractyTipsItem' )
-- 			if target.data and AlteractData.cheakOpen(target.data) then
-- 		        AlteractData.goToFinsh(target.data, self.mainUI)
-- 			elseif not AlteractData.cheakOpen(target.data) then
-- 				TipsMgr.showError(AlteractData.getLinkDesc(target.data))
-- 			end
-- 		end

-- 		createScaleButton(item,nil,nil,nil,nil,1.05)
-- 		item:addTouchEnded(touchEndedHandler)
-- 		--UIMgr.addTouchEnded(item, touchEndedHandler)
-- 		-- item:ctor()
-- 		item:retain()
-- 		self.itemList[index] = item
-- 	end

-- 	return item
-- end