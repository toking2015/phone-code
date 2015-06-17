--由几个颜色的字组成的一行字
LabelBatch = class("LabelBatch", function()
	return cc.Node:create()
end)

function LabelBatch:ctor(num, fontSize,c3b)
	self.txtList = {}
	for i = 1, num do
		self.txtList[i] = UIFactory.getText("", self, 0, 0, fontSize,c3b)
		self.txtList[i]:setAnchorPoint(0, 0.5)
		local function ontouch( ... )
			error("weishmen")
		end
		UIMgr.addTouchEnded(self.txtList[i], ontouch)
	end
end

function LabelBatch:getText(index)
	return self.txtList[index]
end

function LabelBatch:setFontColor(index, c3b)
	local txt = self:getText(index)
	if txt then
		txt:setColor(c3b)
	end
end

function LabelBatch:setString(...)
	local x = 0
	for i,v in ipairs({...}) do
		local txt = self:getText(i)
		if txt then
			txt:setString(v)
			txt:setPositionX(x)
			x = x + txt:getSize().width
		end
	end
end