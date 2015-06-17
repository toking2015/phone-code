
local prePath = "image/ui/HolyUI/HolyProductCount/"
ProdItem = class("ProdItem", function()
	return ccui.Layout:create()
end)

function ProdItem:ctor()
end

function ProdItem:create(type, crit_num)
	local item = ProdItem:new()
	item:setSize(cc.size(346, 40))
	item:updateData(type, crit_num)

	return item
end

function ProdItem:updateData(type, crit_num)
	local coin_num = BuildingData.obtainCoinCount(type)
	local img_list = {[2] = "building_coin.png", [6] = "building_holy.png"}
	local frameName = img_list[type]

    local divideLine = ccui.ImageView:create("holy_divide_line.png",ccui.TextureResType.plistType)
    divideLine:setPosition(cc.p(divideLine:getSize().width/2 + 5, 0))
    self:addChild(divideLine)
    local coin_txt = UIFactory.getText(coin_num, self, 90, 2, 20, cc.c3b(137,67,48), FontNames.HEITI)
    coin_txt:setAnchorPoint(cc.p(0, 0))
    local icon = ccui.ImageView:create(frameName,ccui.TextureResType.plistType)  
    self:addChild(icon)
    icon:setAnchorPoint(cc.p(0, 0))
    icon:setPosition(cc.p(90 + coin_txt:getContentSize().width + 31, 0))
    if crit_num >= 2 then
	    local crit_txt = UIFactory.getText(crit_num, self, nil, nil, 20, cc.c3b(165,48,8), FontNames.HEITI)
	    crit_txt:setAnchorPoint(cc.p(0, 0))
	    crit_txt:setPosition(cc.p(90 + icon:getPositionX() + 30 + 31, 2))
	end
end