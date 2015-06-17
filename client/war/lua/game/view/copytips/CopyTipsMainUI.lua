
CopyTipsMainUI = createUIClass("CopyTipsMainUI", "image/ui/CopyTipsMain/CopyTipsMain.ExportJson", PopWayMgr.SMALLTOBIG)

function CopyTipsMainUI:ctor()
	local function enter()
		TipsMgr.showFightAdd(cc.p(visibleSize.width / 2, visibleSize.height / 2), SceneMgr.getCurrentScene(), self.fight_value)
		Command.run("ui hide", "CopyTipsMainUI")
	end
	createScaleButton(self.button)
	self.button:addTouchEnded(enter)
end

function CopyTipsMainUI:setData(list)
	local userItem = list[1]
	local srcUserItem = list[2]
	local item = findItem(userItem.item_id)
	if not item then
		return
	end

	local quality = EquipmentData:getEquipmentQuality(userItem.main_attr_factor) - const.kCoinEquipWhite + 1
	if const.kQualityWhite == quality then
		self.right.text:setColor(cc.c3b(0xff, 0xff, 0xff))
	elseif const.kQualityGreen == quality then
		self.right.text:setColor(cc.c3b(0x2d, 0x35, 0x0e))
	elseif const.kQualityBlue == quality then
		self.right.text:setColor(cc.c3b(0x00, 0x28, 0x50))
	elseif const.kQualityPurple == quality then
		self.right.text:setColor(cc.c3b(0x53, 0x00, 0xa9))
	else
		self.right.text:setColor(cc.c3b(0xff, 0xdf, 0x2b))
	end
	self.left.text:setString(item.name)
	self.left:loadTexture("copytips_img" .. quality .. '.png', ccui.TextureResType.plistType)
	self.left_item = UIFactory.getSprite(CoinData.getCoinUrl(const.kCoinItem, userItem.item_id))
	self.left_item:setPosition(59, 85)
	self.left:addChild(self.left_item)

	--头 +164   身+164   腿 +85  肩+215 手套+285 鞋子+50  
	self.fight_value = 164
	if 3 == item.subclass then
		self.fight_value = 85
	elseif 4 == item.subclass then
		self.fight_value = 215
	elseif 5 == item.subclass then
		self.fight_value = 285
	elseif 6 == item.subclass then
		self.fight_value = 50
	end

	if not srcUserItem then
		self.right.text:setString("无装备")
		return
	end

	item = findItem(srcUserItem.item_id)
	if not item then
		self.right.text:setString("无装备")
		return
	end

	quality = EquipmentData:getEquipmentQuality(srcUserItem.main_attr_factor) - const.kCoinEquipWhite + 1
	if const.kQualityWhite == quality then
		self.right.text:setColor(cc.c3b(0xff, 0xff, 0xff))
	elseif const.kQualityGreen == quality then
		self.right.text:setColor(cc.c3b(0x2d, 0x35, 0x0e))
	elseif const.kQualityBlue == quality then
		self.right.text:setColor(cc.c3b(0x00, 0x28, 0x50))
	elseif const.kQualityPurple == quality then
		self.right.text:setColor(cc.c3b(0x53, 0x00, 0xa9))
	else
		self.right.text:setColor(cc.c3b(0xff, 0xdf, 0x2b))
	end
	self.right.text:setString(item.name)
	self.right:loadTexture("copytips_img" .. quality .. '.png', ccui.TextureResType.plistType)
	self.right_item = UIFactory.getSprite(CoinData.getCoinUrl(const.kCoinItem, r_item.item_id))
	self.right_item:setPosition(59, 85)
	self.right:addChild(self.right_item)
end

function CopyTipsMainUI:onShow()
	EventMgr.addListener(EventType.CopyTipsEquip, self.setData, self)
end

function CopyTipsMainUI:onClose()
	EventMgr.removeListener(EventType.CopyTipsEquip, self.setData)
	TimerMgr.runNextFrame( function()
        EventMgr.dispatch(EventType.CopyTipsShow)
        end)
	InductMgr:replayerCopyOpen()
end
