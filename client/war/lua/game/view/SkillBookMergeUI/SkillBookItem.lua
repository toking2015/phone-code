SkillBookItem = {}

function SkillBookItem.create(item_id, scale)
	local node = cc.Node:create()
	local jItem = findItem(item_id)
	if not jItem then
		return
	end
	local bg = UIFactory.getSprite(string.format("image/ui/bagUI/itembg/ItemBg_%d.png", jItem.quality), node)
	bg:setScale(scale)
	local item_icon = UIFactory.getSprite(ItemData.getItemUrl(item_id), node)
	item_icon:setScale(scale)
	node.item_icon = item_icon
	return node
end
