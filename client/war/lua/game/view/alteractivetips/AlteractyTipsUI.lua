-- write by toking 

require "lua/game/view/alteractivetips/AlteractyTipsItem.lua"

local prepath = "image/ui/AlternativesTipsUI/"
local url = prepath .. "AlternativesTipsUI_1.ExportJson"

local item_id = nil

AlteractyTipsUI = createUIClass("AlteractyTipsUI", url, PopWayMgr.SMALLTOBIG)

function AlteractyTipsUI:ctor( ... )
	self.title_txt:loadTexture("image/ui/AlternativesTipsUI/moreimg/".."txt_title.png", ccui.TextureResType.localType )
	self.itemList = {}

	local size = self:getSize()
	size.height = size.height + 46
	self:setSize(size)
	self:addSprite(self.bg_item,"quality", 48, 45)
end

function AlteractyTipsUI:onShow( ... )
	self:updateData()
end

function AlteractyTipsUI:onClose( ... )
end

function AlteractyTipsUI:updateData( ... )
	local cate = AlteractData.cate
	local item_id = AlteractData.item_id
	local item_type = 1 item_type = AlteractData.item_type
	self.bg_num.txt_num:setString("拥有数量：")
	self.item_count:setColor(cc.c3b(0xfc, 0xff, 0x00))

	if not cate and not item_id and not item_type then
		return
	end

	local count = CoinData.getCoinByCate(cate,item_id)
	local jItem = nil
	local name = CoinData.getCoinName(cate,item_id)
	if cate == const.kCoinTeamXp then
		self.bg_num.txt_num:setString("当前等级：")
		if AlteractData.need_level then
			count = gameData.getSimpleDataByKey("team_level") .. '/' ..AlteractData.need_level
			name = AlteractData.need_level .. "级开启下个区域"
			AlteractData.need_level = nil
		else
			name = "下个区域未开启"
			count = gameData.getSimpleDataByKey("team_level")
		end
		self.item_count:setColor(cc.c3b(0xff, 0x00, 0x00))
	end
	local quality = 4
	local qurl = ""

	if item_id and item_id > 0 then
		jItem = findItem( item_id )
	end
	if jItem then
		quality = ItemData.getQuality( jItem )
	end
	
	local icon_url = CoinData.getCoinUrl(cate,item_id)
	if item_type == const.kCoinTotem then
		local totem = findTotem(item_id)
		icon_url = TotemData.getAvatarUrl(totem)
		name = CoinData.getCoinName(item_type,item_id)
		count = "未获得"
		qurl = TotemData.getQualityFrameName(1)
		self.quality:setSpriteFrame(qurl)
		self.quality:setPositionY(48)
	elseif item_type == const.kCoinSoldier then
		local soldier = findSoldier(item_id)
		name = CoinData.getCoinName(item_type,item_id)
		if soldier then
			icon_url = SoldierData.getAvatarUrl(soldier)
		end
		qurl = SoldierData.getQualityFrameName(1)
		self.quality:setSpriteFrame(qurl)
		self.quality:setPositionY(36)
	end
	self.bg_item.icon_item:setScale(item_type == const.kCoinTotem and TotemData.AVATAR_SCALE or 1)
	self.bg_item:loadTexture(ItemData.getItemBgUrl(quality), ccui.TextureResType.localType )
	self.bg_item.icon_item:loadTexture(icon_url, ccui.TextureResType.localType )
	self.bg_item.icon_item:setPosition(cc.p(self.bg_item:getContentSize().width/2,self.bg_item:getContentSize().height/2))

	self.bg_name:loadTexture( 'image/ui/bagUI/itembg/bg_name_' ..quality .. '.png', ccui.TextureResType.localType )
	self.bg_name.txt_name:setColor(CoinData.getCoinC3B(cate,item_id))		
	self.bg_name.txt_name:setString(name)
	self.bg_name.txt_name:setPosition(cc.p(self.bg_name:getContentSize().width/2,self.bg_name:getContentSize().height/2))
	self.item_count:setString( count )

	local alterDatalist = AlteractData.getalterDatalist(AlteractData.cate,AlteractData.item_id,AlteractData.item_type)
	if #alterDatalist > 0 then
		local list = {}
		local index = 1
		 for k,v in pairs(alterDatalist) do
	    	local item = self:getItem( index ,v)
			item:updateData( v )
			table.insert(list, item)
			self['item'..index] = item
			index = index + 1
		end
		initScrollviewWith(self.ScrollView, list, 1, -5, 2, 0, 4)
	else
		local size = self.ScrollView:getContentSize()
		UIFactory.getText('该灵魂石还没有副本获取途径', self.ScrollView, size.width/2, size.height/2, 20)
	end
end

function AlteractyTipsUI:dispose()
    local parent = nil
	for i,v in pairs(self.itemList) do
	    v:removeFromParent()
		v:release()
	end
	self.itemList = {}
end

function AlteractyTipsUI:getItem( index ,alterdata)
	local item = nil
	if index < #self.itemList then
		item = self.itemList[index]
	else
		item = AlteractyTipsItem:new()

		local function touchEndedHandler(target)
			 ActionMgr.save( 'UI', 'AlteractyTipsUI click AlteractyTipsItem' )
			if target.data and AlteractData.cheakOpen(target.data) then
		        AlteractData.goToFinsh(target.data, self.mainUI)
			elseif not AlteractData.cheakOpen(target.data) then
				TipsMgr.showError(AlteractData.getLinkDesc(target.data))
			end
		end

		createScaleButton(item,nil,nil,nil,nil,1.05)
		item:addTouchEnded(touchEndedHandler)
		--UIMgr.addTouchEnded(item, touchEndedHandler)
		-- item:ctor()
		item:retain()
		self.itemList[index] = item
	end

	return item
end

function AlteractyTipsUI:setMainUI(ui)
	self.mainUI = ui
end

function AlteractyTipsUI:addSprite(parent,name, dx, dy, depth)
	local sp = self[name]
	if (sp == nil) then
		sp = cc.Sprite:create()
		parent:addChild(sp, depth or 0)
		self[name] = sp
	end
	dx = dx or 0
	dy = dy or 0
	sp:setPosition(dx, dy)
end
