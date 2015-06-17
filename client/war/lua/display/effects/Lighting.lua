Lighting = class("Lighting", function()
	return cc.DrawNode:create()
end)

--起始x,y，目标x,y,振幅displace
--0, 0, 200, 200, 200
function Lighting:ctor(...)
	self.curDetail = 8
	self.numberBolts = 1
	self.x1, self.y1, self.x2, self.y2, self.displace = ...
	local function doDraw()
		self:clear()
		for i = 1, self.numberBolts do
        	self:drawLighting(self.x1, self.y1, self.x2, self.y2, self.displace)
        end
	end
    self:scheduleUpdateWithPriorityLua(doDraw, 0)
end

function Lighting:drawLighting(x1, y1, x2, y2, displace)
	if (displace < self.curDetail) then
		self:drawSegment(cc.p(x1, y1), cc.p(x2, y2), 1, cc.c4f(1, 1, 1, 1))
	else
		local mid_x = (x2 + x1) / 2
		local mid_y = (y2 + y1) / 2
		mid_x = mid_x + (math.random() - 0.5) * displace
		mid_y = mid_y + (math.random() - 0.5) * displace
		self:drawLighting(x1, y1, mid_x, mid_y, displace / 2)
		self:drawLighting(x2, y2, mid_x, mid_y, displace / 2)
	end
end
