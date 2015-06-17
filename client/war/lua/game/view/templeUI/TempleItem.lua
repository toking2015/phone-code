TempleItem = class("TempleItem", function()
	return cc.Sprite:createWithSpriteFrameName("bg_role_new.png")
end)

local prePath = "image/ui/TempleUI/"
local boxSize = cc.p(86, 90)
local totemOffset = cc.p(0, -3)

function TempleItem:setData(data)
	local sData = nil
	local jdata = nil
	if data.first == const.kCoinSoldier then
		attr = const.kAttrSoldier
		jdata = findSoldier(data.second)
		sData = SoldierData.getSoldierBySId(data.second)
	else
		attr = const.kAttrTotem
		jdata = findTotem(data.second)
		sData = TotemData.getTotemById(data.second)
	end
	self.attr = attr
	if jdata == nil then
		-- self:setVisible(false)
		self.quality = nil
		BitmapUtil.setTexture(self.item, nil)
		self.item = nil
		self.mark = nil
		self.recommend = nil
		self.progress_health = nil
		self.progress_power = nil
		self.img_dead = nil
		self.star_bg = nil
		for i = 1, 5 do
			self["t_star_"..i] = nil
		end
		self:removeAllChildren()
		return
	end
	-- self:setVisible(true)
	local url
	local qurl
	local isRecommend = false
	local avatarOffset = TeamData.AVATAR_OFFSET
	if attr == const.kAttrSoldier then
	    if sData ~= nil then 
	       qurl = SoldierData.getQualityFrameName(sData.quality)
        end
		local soldier = FormationData.getJson(data.second, attr)
		if soldier then
			url = SoldierData.getAvatarUrl(soldier)
		else
			LogMgr.error("英雄数据不存在：", data.second)
		end
	elseif attr == const.kAttrTotem then
		avatarOffset = totemOffset
		local totem = FormationData.getJson(data.second, attr)
		url = TotemData.getAvatarUrl(totem)
		if sData ~= nil then
			qurl = TotemData.getQualityFrameName(sData.level)
		end
	end
	self:addSprite("quality", boxSize.x / 2, boxSize.y / 2)
	self.quality:setSpriteFrame(qurl)
	self:addSprite("item", boxSize.x / 2 + avatarOffset.x, boxSize.y / 2 + avatarOffset.y + 3)
	BitmapUtil.setTexture(self.item, url)
	self.item:setScale(attr == const.kAttrTotem and TotemData.AVATAR_SCALE or 1)
	local function touchHandler( ... )
		if self.attr == const.kAttrSoldier and not sData then
			-- local jSoldierRecruit= SoldierData.getRecruitInfo(data.second)
			-- local costItem = jSoldierRecruit.cost_[1]
			-- if (CoinData.checkLackCoin(const.kCoinItem, costItem.val, costItem.objid)) then
			--  	return
			-- end
			AlteractData.showByData(18,data.second,data.first)
		elseif self.attr == const.kAttrTotem and not sData then
	  		-- TotemData.checkCanActivate(totem,true,false)
	  		AlteractData.showByData(17,data.second,data.first)
		end
	end
	UIMgr.addTouchEnded(self.item, touchHandler)
	--local rcUrl = isRecommend and "formation_recommend.png" or nil
	--UIFactory.setSpriteChild(self, "recommend", true, rcUrl, 15, 85, 5)
	UIFactory.setSpriteChild(self, "star_bg", false, prePath.."star_bg.png", boxSize.x / 2, -10, 4)
	if sData ~= nil then
		self:setStar(self.star_bg, attr == const.kAttrTotem and sData.level or sData.star)
		self:remove("unget")
	else
		-- self:setStar(self.star_bg,attr == const.kAttrTotem and jdata.init_lv or jdata.star)
		self:addSprite("unget", boxSize.x / 2, boxSize.y / 2 - 55, 10)
		self.unget:setTexture(prePath.."unget.png")
		ProgramMgr.setGray(self)
	end
end

function TempleItem:remove(name)
	if self[name] then
		self[name]:removeFromParent()
		self[name] = nil
	end
end

function TempleItem:setStar(con, level)
	local pos = cc.p(boxSize.x / 2 - 11 - (level - 1) * 6, 15)
	local url = prePath .. "star.png"
	for i = 1, 6 do
		if i <= level then
			local star = UIFactory.setSpriteChild(con, "t_star_"..i, false, url, pos.x + 12 * i, pos.y)
		else
			UIFactory.setSpriteChild(con, "t_star_"..i, false)
		end
	end
end

function TempleItem:addSprite(name, dx, dy, depth)
	local sp = self[name]
	if (sp == nil) then
		sp = cc.Sprite:create()
		self:addChild(sp, depth or 0)
		self[name] = sp
	end
	dx = dx or 0
	dy = dy or 0
	sp:setPosition(dx, dy)
end