------------------------------伤害相关数据start
local __this = 
{
	skillList = {},		--技能喊招资源列表
    buffList = {},    	--buff资源列表
    ipsgList = {},    	--觉醒资源列表
    ipsgFailList = {},  --觉醒失败资源列表
    textOddList = {},	--文本odd资源列表
    textList = {},		--文本资源列表
    antiList = {},		--反击资源列表
    reboundPerList = {},--反弹资源列表

    itemRewardList = {},	--物品掉落资源列表

    imageList = {},			--image资源引用列表
}
__this.__index = __this

local prePath = "image/ui/FightUI/"
require("lua/utils/UICommon.lua")


local function spriteCreate(url)
	FightTextMgr.imageList[url] = FightTextMgr.imageList[url] or 0
	FightTextMgr.imageList[url] = FightTextMgr.imageList[url] + 1

	LoadMgr.loadImage(url, LoadMgr.SCENE, "fight")
	local v = Sprite:create(url)
	v:retain()

	return v
end
local function removeImage(url)
	if not url or not FightTextMgr.imageList[url] then
		return
	end

	FightTextMgr.imageList[url] = FightTextMgr.imageList[url] - 1
	if 0 == FightTextMgr.imageList[url] then
		LoadMgr.removeImage(url)
		FightTextMgr.imageList[url] = nil
	end
end
function __this.spriteCreate(url)
	return spriteCreate(url)
end
function __this:removeImage(url)
	removeImage(url)
end


--物品掉落资
FightItemReward = createLayoutClass("FightItemReward", cc.Node)
function FightItemReward:ctor()
	self:retain()
	self:setScale(0.65)

	-- self.urlBg = FightFileMgr.prePath .. "win/fight_win_box.png"
	-- local bg = spriteCreate(self.urlBg)
	-- self:addChild(bg)
	-- self.bg = bg

	-- local size = bg:getContentSize()
	-- self:setWidth(size.width)
	-- self:setHeight(size.height)
end
function FightItemReward:releaseAll()
	self.item:removeFromParent()
	self.item:release()
	removeImage(self.urlItem)

	-- self.quality:removeFromParent()
	-- self.quality:release()
	-- removeImage(self.urlQuality)

	-- self.bg:removeFromParent()
	-- self.bg:release()
	-- removeImage(self.urlBg)

	self:removeFromParent()
	self:release()
end
function FightItemReward:setData(coin)
    -- local q = 1

    self.coin = coin
 --    if const.kCoinItem == coin.cate then
 --    	local item = findItem(coin.objid)
 --    	if item then
 --    		q = item.quality
	-- 	end
	-- end

	-- self.urlQuality = ItemData.getItemBgUrl(q)
 --    local quality = spriteCreate(self.urlQuality)
 --    self:addChild(quality)
 --    self.quality = quality

    self.urlItem = CoinData.getCoinUrl(coin.cate, coin.objid)
    local item = UIFactory.getSprite(self.urlItem)
    item:retain()
    self:addChild(item)
    self.item = item
end

--文本
FightText = class("FightText", function()
	local text = UIFactory.getText(nil, nil, 0, -170, 22, cc.c3b(0xff, 0xff, 0x02))
	text:retain()
	text:setCascadeOpacityEnabled(true)
    return text
end)
function FightText:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightText:setData(s2, val)
	self.size = self:getContentSize()
	if val then
		self:setString(val)
		self.size = self:getContentSize()
		return
	end

	local effect = findEffect(s2.first)
	if not effect then
		self:setString('')
		return
	end

	if 1 == effect.PercenValue then
		self:setString(effect.desc .. '+' .. (s2.second / 100) .. '%')
	else
		self:setString(effect.desc .. '+' .. s2.second)
	end

	self.size = self:getContentSize()
end
function FightText:idle(time, data, coord, role)
	local alpha = 0
	local pt = cc.p(coord.x, coord.y)
	local t = time - data.startTime
	if t < 200 then
		alpha = t / 200 * 255
		pt.y = pt.y + t / 200 * 24
	elseif t < 1000 then
		alpha = 255
		pt.y = pt.y + 24 + (t - 200) / 800 * (71 - 24)
	else
		alpha = 255
		pt.y = pt.y + 71 + (t - 1000) / 350 * (93 - 71)
	end
	
	self:setPosition(pt)
	self:setOpacity(alpha)
end

--skill[1000ms]
FightTextSkill = class("FightTextSkill", function(skill)
	local url = "image/skillname/skill/" .. skill.skillname .. ".png"
	local node = UIFactory.getSprite(url)
	node:retain()
	node:setCascadeOpacityEnabled(true)
	node.url = url
	node.size = node:getContentSize()

	node.skill = skill
    return node
end)
function FightTextSkill:releaseAll()
	self.skill = nil

	self:removeFromParent()
	removeImage(self.url)
	self:release()
end
function FightTextSkill:idle(time, data, coord, role)
	local alpha = 0
	local pt = cc.p(coord.x, coord.y)
	local t = time - data.startTime
	local fix = 1
	if role:isMirror() then
		fix = -1
	end
	if t < 225 then
		alpha = t / 225 * 255
		pt.x = pt.x + t / 225 * 30 * fix
	elseif t < 1000 then
		alpha = 255
		pt.x = pt.x + (30 + (t - 225) / 775 * (51 - 30)) * fix
	else
		alpha = 255
		pt.x = pt.x + (51 + (t - 1000) / 350 * (82 - 51) )* fix
	end
	
	self:setPosition(pt)
	self:setOpacity(alpha)
end

--buff[1000ms]
FightTextBuff = class("FightTextBuff", function(odd, val)
	val = val or "buffname"
	local url = "image/skillname/buff/" .. odd[val] .. ".png"
	local node = UIFactory.getSprite(url)
	node:retain()
	node:setCascadeOpacityEnabled(true)
	node.url = url

	node.odd = odd
    return node
end)
function FightTextBuff:releaseAll()
	self.odd = nil

	if self.number then
		FightNumberMgr:unBuffLayer(self.number)
	end

	self:removeFromParent()
	removeImage(self.url)
	self:release()
end
function FightTextBuff:setData(fightOdd)
	self.size = self:getContentSize()
	if not fightOdd or fightOdd.now_count <= 1 then
		if self.number then
			self.number.number:setVisible(false)
		end
		return
	end

	if not self.number then
		if 1 == self.odd.attr then
			self.number = FightNumberMgr:useBuffLayer1()
		else
			self.number = FightNumberMgr:useBuffLayer2()
		end
	end

	self.size = self:getContentSize()
	self:addChild(self.number)
	self.number.number:setString('/' .. fightOdd.now_count)
	self.number:setPosition(self.size.width + self.number:getContentSize().width / 4, 0)
end
function FightTextBuff:idle(time, data, coord)
	local alpha = 0
	local pt = cc.p(coord.x, coord.y)
	local t = time - data.startTime
	if t < 200 then
		alpha = t / 200 * 255
		pt.y = pt.y + t / 200 * 24
	elseif t < 1000 then
		alpha = 255
		pt.y = pt.y + 24 + (t - 200) / 800 * (71 - 24)
	else
		alpha = 255
		pt.y = pt.y + 71 + (t - 1000) / 350 * (93 - 71)
	end
	
	self:setPosition(pt)
	self:setOpacity(alpha)
end

--觉醒[875ms]
FightTextIpsg = class("FightTextIpsg", function()
	local url = "image/skillname/skill/juexing.png"
	local node = UIFactory.getSprite(url)
	node:retain()
	node:setCascadeOpacityEnabled(true)
	node.url = url
	node.size = node:getContentSize()

    return node
end)
function FightTextIpsg:releaseAll()
	self:removeFromParent()
	removeImage(self.url)
	self:release()
end
function FightTextIpsg:idle(time, data, coord)
	local alpha = 0
	local scale = 2
	local t = time - data.startTime
	if t < 200 then
		alpha = t / 200 * 255
		scale = 2 - t / 200 
	elseif t < 1000 then
		alpha = 255
		scale = 1
	else
		alpha = 255 - (t - 1000) / 225
		scale = 1 + (t - 1000) / 225
	end
	
	self:setScale(scale)
	self:setPosition(coord)
	self:setOpacity(alpha)
end

--觉醒失败[875ms]
FightTextIpsgFail = class("FightTextIpsg", function()
	local url = "image/skillname/skill/juexing_fail.png"
	local node = UIFactory.getSprite(url)
	node:retain()
	node:setCascadeOpacityEnabled(true)
	node.url = url
	node.size = node:getContentSize()

    return node
end)
function FightTextIpsgFail:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightTextIpsgFail:idle(time, data, coord)
	local alpha = 0
	local scale = 2
	local t = time - data.startTime
	if t < 200 then
		alpha = t / 200 * 255
		scale = 2 - t / 200 
	elseif t < 1000 then
		alpha = 255
		scale = 1
	else
		alpha = 255 - (t - 1000) / 225
		scale = 1 + (t - 1000) / 225
	end
	
	self:setScale(scale)
	self:setPosition(coord)
	self:setOpacity(alpha)
end

--反击[875ms]
FightTextAntiAttack = class("FightTextAntiAttack", function()
	local url = "image/skillname/buff/counterstrike_buffname.png"
	local node = UIFactory.getSprite(url)
	node:retain()
	node:setCascadeOpacityEnabled(true)
	node.url = url
	node.size = node:getContentSize()

    return node
end)
function FightTextAntiAttack:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightTextAntiAttack:idle(time, data, coord)
	local alpha = 0
	local scale = 2
	local t = time - data.startTime
	if t < 200 then
		alpha = t / 200 * 255
		scale = 2 - t / 200 
	elseif t < 1000 then
		alpha = 255
		scale = 1
	else
		alpha = 255 - (t - 1000) / 225
		scale = 1 + (t - 1000) / 225
	end
	
	self:setScale(scale)
	self:setPosition(coord)
	self:setOpacity(alpha)
end

--反弹[875ms]
FightTextReboundPer = class("FightTextReboundPer", function()
	local url = "image/skillname/buff/reboundper_buff.png"
	local node = UIFactory.getSprite(url)
	node:retain()
	node:setCascadeOpacityEnabled(true)
	node.url = url
	node.size = node:getContentSize()

    return node
end)
function FightTextReboundPer:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightTextReboundPer:idle(time, data, coord)
	local alpha = 0
	local scale = 2
	local t = time - data.startTime
	if t < 200 then
		alpha = t / 200 * 255
		scale = 2 - t / 200 
	elseif t < 1000 then
		alpha = 255
		scale = 1
	else
		alpha = 255 - (t - 1000) / 225
		scale = 1 + (t - 1000) / 225
	end
	
	self:setScale(scale)
	self:setPosition(coord)
	self:setOpacity(alpha)
end

--技能喊招[专用]
function __this:useTextSkill(data, sprite)
	if data.text or not data.skill or "" == data.skill.skillname then
		return
	end

	-- for __, text in pairs(self.skillList) do
	-- 	if not text.use and text.skill == data.skill then
	-- 		text.use = true
	-- 		data.text = text
	-- 		sprite:addChild(text)
	-- 		return
	-- 	end
	-- end

	local text = FightTextSkill.new(data.skill)
	table.insert(self.skillList, text)

	text.skill = data.skill
	text.use = true
	data.text = text
	data.list = self.skillList
	sprite:addChild(text)
end

--buff[专用]
function __this:useTextBuff(data, sprite)
	local key = data.val
	if not data.val then
		key = "buffname"
	end
	if data.text or not data.odd or "" == data.odd[key] then
		return
	end

	-- for __, text in pairs(self.buffList) do
	-- 	if not text.use and text.odd == data.odd then
	-- 		text.use = true
	-- 		text:setData(data.fightOdd)
	-- 		data.text = text
	-- 		sprite:addChild(text)
	-- 		return
	-- 	end
	-- end

	local text = FightTextBuff.new(data.odd, data.val)
	table.insert(self.buffList, text)

	text.odd = data.odd
	text:setData(data.fightOdd)
	text.use = true
	data.text = text
	data.list = self.buffList
	sprite:addChild(text)
end

--觉醒[专用]
function __this:useTextIpsg(data, sprite)
	if data.text then
		return
	end

	-- for __, text in pairs(self.ipsgList) do
	-- 	if not text.use then
	-- 		text.use = true
	-- 		data.text = text
	-- 		sprite:addChild(text)
	-- 		return
	-- 	end
	-- end

	local text = FightTextIpsg.new()
	table.insert(self.ipsgList, text)

	text.use = true
	data.text = text
	data.list = self.ipsgList
	sprite:addChild(text)
end

--觉醒失败[专用]
function __this:useTextIpsgFail(data, sprite)
	if data.text then
		return
	end

	-- for __, text in pairs(self.ipsgFailList) do
	-- 	if not text.use then
	-- 		text.use = true
	-- 		data.text = text
	-- 		sprite:addChild(text)
	-- 		return
	-- 	end
	-- end

	local text = FightTextIpsgFail.new()
	table.insert(self.ipsgFailList, text)

	text.use = true
	data.text = text
	data.list = self.ipsgFailList
	sprite:addChild(text)
end

--反击[专用]
function __this:useTextAnti(data, sprite)
	if data.text then
		return
	end

	local text = FightTextAntiAttack.new()
	table.insert(self.antiList, text)

	text.use = true
	data.text = text
	data.list = self.antiList
	sprite:addChild(text)
end

--反弹[专用]
function __this:useTextReboundPer(data, sprite)
	if data.text then
		return
	end

	local text = FightTextReboundPer.new()
	table.insert(self.reboundPerList, text)

	text.use = true
	data.text = text
	data.list = self.reboundPerList
	sprite:addChild(text)
end

--文本
function __this:useTextOdd(data, sprite)
	if data.text then
		return
	end

	-- for __, text in pairs(self.textList) do
	-- 	if not text.use then
	-- 		text.use = true
	-- 		data.text = text
	-- 		text:setData(data.s2)
	-- 		sprite:addChild(text)
	-- 		return
	-- 	end
	-- end

	local text = FightText.new()
	table.insert(self.textOddList, text)

	text.use = true
	data.text = text
	data.list = self.textOddList
	text:setData(data.s2)
	sprite:addChild(text)
end

--文本
function __this:useText(data, sprite)
	if data.text then
		return
	end

	-- for __, text in pairs(self.textList) do
	-- 	if not text.use then
	-- 		text.use = true
	-- 		data.text = text
	-- 		text:setData(data.s2)
	-- 		sprite:addChild(text)
	-- 		return
	-- 	end
	-- end

	local text = FightText.new()
	table.insert(self.textList, text)

	text.use = true
	data.text = text
	data.list = self.textList
	text:setData(nil, data.val)
	sprite:addChild(text)
end

--释放喊招
function __this:unText(data)
	if not data.text then
		return
	end

	for i, text in pairs(data.list) do
		if text == data.text then
			table.remove(data.list, i)
			break
		end
	end

	data.text:removeFromParent()

	if data.text.number then
		FightNumberMgr:unBuffLayer(data.text.number)
		data.text.number = nil
	end

	data.text:releaseAll()
	data.use = false
	data.text = nil
	data.odd = nil
	data.skill = nil
end

--物品掉落
function __this:useItemReward(coin)
	local item = FightItemReward.new()
	table.insert(self.itemRewardList, item)

	item.use = true
	item:setData(coin)
	return item
end
--物品掉落
function __this:unItemReward(data)
	if not data.itemView then
		return
	end

	-- for i, view in pairs(self.itemRewardList) do
	-- 	if view == data.itemView then
	-- 		table.remove(self.itemRewardList, i)
	-- 		break
	-- 	end
	-- end

	data.itemView.use = false
	data.itemView:removeFromParent()
	data.itemView = nil
end

function __this.releaseList(list)
	for __, value in pairs(list) do
		value:releaseAll()
	end

	return {}
end

function __this:releaseAll()
	-- LogMgr.log( 'debug',"*****************FightTextMgr:releaseAll*****************")

	--技能喊招资源列表
    self.skillList = self.releaseList(self.skillList)
    --buff资源列表
    self.buffList = self.releaseList(self.buffList)
    --觉醒资源列表
    self.ipsgList = self.releaseList(self.ipsgList)
    --觉醒失败资源列表
    self.ipsgFailList = self.releaseList(self.ipsgFailList)
    --文本资源列表
    self.textList = self.releaseList(self.textList)

	self.antiList = self.releaseList(self.antiList)
	self.reboundPerList = self.releaseList(self.reboundPerList)

	self.imageList = {}
end

function __this:releaseReward()
    --物品掉落资源列表
	self.itemRewardList = self.releaseList(self.itemRewardList)
end
------------------------------伤害数据end


FightTextMgr = __this