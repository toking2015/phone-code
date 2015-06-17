-- Create By Hujingjiang --

local prePath = "image/ui/CopyPresentUI/"

PresentItem = class("PresentItem", function()
	return getLayout(prePath .. "PresentItem.ExportJson")
end)
function PresentItem:ctor()
	self.txt_name:setString("")
end
function PresentItem:create(data)
	local boxItem = PresentItem:new()
	boxItem:setData(data)
	return boxItem
end
function PresentItem:setData(item)
	if nil == item then return end
	local url = CopyRewardData.getRewardIconUrl(item)
    if url == "" then LogMgr.debug("路径不存在：" .. debug.dump(item)) end
    local rType = ccui.TextureResType.plistType
    if item.cate == 4 or item.cate == 13 then
        rType = ccui.TextureResType.localType
    end
    local icon = ccui.ImageView:create(url, rType)
    self.img_bg:addChild(icon, 1)
    local size = self.img_bg:getSize()
    icon:setPosition(cc.p(size.width / 2, size.height / 2))
    local name = CopyRewardData.getRewardIconName(item)
    self.txt_name:setString(name)
    self.txt_num:setString(item.val)
    if item.cate == 4 then
    	local obj = findItem(item.objid)
    	local quality = obj.quality
    	local bgUrl = ItemData.getItemBgUrl(quality)
    	local bg = ccui.ImageView:create(bgUrl, ccui.TextureResType.localType)
    	bg:setPosition(cc.p(size.width / 2, size.height / 2))
    	self.img_bg:addChild(bg)
    	local color = ItemData.getItemColor(quality)
    	self.txt_name:setColor(color)
    end
end

local prePath = "image/ui/CopyAreaRewardUI/"
local url = prePath .. "rewardGetMain.ExportJson"
CopyPresentUI = createUIClass("CopyPresentUI", url, PopWayMgr.SMALLTOBIG)

function CopyPresentUI:ctor()

	self.h = 155
	self.pos1 = {245}
	self.pos2 = {167,318}
	self.pos3 = {94,244,394}
	self.pos4 = {65,184,301,420}

	self.itemList = {}
	for i=1,4 do
		local item = getLayout(prePath .. "item.ExportJson")
		item:setAnchorPoint(cc.p(0.5,0.5))
		self:addChild(item,10)
		table.insert(self.itemList,item)
		buttonDisable(item,true)
	end

	self:resetPostion()
end

function CopyPresentUI:onClose( ... )
	--很恶心的做法
	if self.success then
		Command.run("copy takePresent", self.showType, self.area_id, self.area_attr)	
		self.success = false
	end
end

function CopyPresentUI:resetPostion()
	if self.coinLen and self.coinLen > 0 then
		local pos = self["pos" .. self.coinLen]
		--长度大于4情况
		if pos == nil then
			pos = self.pos4
		end
		local len = #pos
		for k,v in pairs(self.itemList) do
			if k <= self.coinLen then
				v:setVisible(true)
				if k <= len then
					v:setPosition(pos[k],self.h)
				else
					LogMgr.debug("谭......CopyAreaRewardUI:::"..k)
				end
			else
				v:setVisible(false)
				v:setPosition(0,0)
			end
		end
	end
end

function CopyPresentUI:showUI(data)
	self.success = false
	self.area_id = data.area_id
	self.showType = data.showType
	self.area_attr = data.area_attr

	if const.kCopyAreaAttrPass ~= self.area_attr then
		self.bg:loadTexture("CopyAreaRewardUI/CopyAreaReward_bgstar.png", ccui.TextureResType.plistType)
		self.bg:setPositionY(166)
	end

	local curr, max = CopyData.getAreaGetStar(self.area_id, self.showType), CopyData.getAreaAllStars(self.area_id)
	local coins,isGet = CopyData.getCopyAreaReward({showType = self.showType, area_id = self.area_id}) 
        -- --可以领取，直接发协议  
	self.geted:setVisible(false)
	self.notFullStar:setVisible(false)
	self.btn_get:setVisible(false)
	buttonDisable(self.btn_get,true)
	buttonDisable(self,true)
	--星未满
	if 0 == isGet or 1 == isGet or 3 == isGet then
		self.geted:setVisible(false)
		self.notFullStar:setVisible(true)
		self.btn_get:setVisible(false)
		self.notFullStar.numStar:setString(string.format("%d/%d",curr,max))
	--可领取
	elseif 2 == isGet or 4 == isGet then
		self.success = true
		self.geted:setVisible(false)
		self.notFullStar:setVisible(false)
		self.btn_get:setVisible(true)
		buttonDisable(self.btn_get,false)
		buttonDisable(self,false)
		local btn_get = createScaleButton(self.btn_get)
		btn_get:addTouchEnded(function() 
			ActionMgr.save( 'UI', 'CopyPresentUI click btn_get')
			self.success = false
			Command.run("copy takePresent", self.showType, self.area_id, self.area_attr)		
			PopMgr.removeWindow(self)
		end)
	--已经领取
	else
		self.geted:setVisible(true)
		self.notFullStar:setVisible(false)
		self.btn_get:setVisible(false)
	end

	if coins then
		self.coinLen = #coins
		for k,coin in pairs(coins) do
			if k <= 4 then
				local item = self.itemList[k]
				local url = CoinData.getCoinUrl(coin.cate,coin.objid)
				item.icon:loadTexture(url,ccui.TextureResType.localType)
				item.icon:setVisible(true)
				local name = CoinData.getCoinName(coin.cate,coin.objid)
				item.name:setString(name .. "X" .. coin.val)
				item.num:setString(coin.val)
				if coin.cate == const.kCoinItem	then
					url = ItemData.getItemBgUrl(coin.objid)
					item.box:loadTexture(url,ccui.TextureResType.localType)
				end

				if coin.cate == const.kCoinGlyph then
					CoinData:setGlyphItem( coin,self.winName,item,"icon","box",cc.p(50,50),true )
				end

				if coin.cate == const.kCoinSoldier then
					CoinData:setSoldierItem( coin,item,"icon","box",cc.p(50,50))
				end
			end
		end
	end
	self:resetPostion()
end

Command.bind( 'CopyPresentUI show', function(data)
    local win = PopMgr.popUpWindow("CopyPresentUI", true, PopUpType.SPECIAL)
	win:showUI(data)    
end )