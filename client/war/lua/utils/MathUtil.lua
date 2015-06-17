--数学工具
local __this = MathUtil or {}
MathUtil = __this

local ONE_RADIANS = 180 / math.pi
local ONE_ANGLE = math.pi / 180

--[[
 * 获取p1到p2的弧度
 * @param p1
 * @param p2
 * @return
]]
function __this.getRadiansByPoint(p1, p2)
	return math.atan2(p2.y - p1.y, p2.x - p1.x);
end

--[[
 * 获取两点角度  x1 到 x2的弧度
 * @param x1
 * @param y1
 * @param x2
 * @param y2
 * @return
]]
function __this.getRadiansByXY(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1);
end

--[[
 * 获取两点的角度 p1到p2的角度
 * @param	p1
 * @param	p2
 * @return
]]
function __this.getAngleByPoint(p1, p2)
	return __this.getAngle(__this.getRadiansByXY(p1.x, p1.y, p2.x, p2.y));
end

--[[
 * 获取两点的角度 p1 到 p2的角度
 * @param	x1
 * @param	y1
 * @param	x2
 * @param	y2
 * @return
]]
function __this.getAngleByXY(x1, y1, x2, y2)
	return __this.getAngle(__this.getRadiansByXY(x1, y1, x2, y2));
end

--[[
 * 角度转换成弧度
 * @param radians
 * @return
]]
function __this.getRadians(angle)
	return angle * ONE_ANGLE;
end

--[[
 * 弧度转换成角度
 * @param degrees
 * @return
]]
function __this.getAngle(radians)
	return radians * ONE_RADIANS;
end

--[[
 * 获取两点之间的距离
 * @param x1
 * @param y1
 * @param x2
 * @param y2
 * @return
]]
function __this.getDistance(x1, y1, x2, y2)
	local x = x2 - x1;
	local y = y2 - y1;
	return math.sqrt(x * x + y * y);
end

function __this.getPowDisByPoint(p1, p2)
	return __this.getPowDistance(p1.x, p1.y, p2.x, p2.y);
end

function __this.getPowDistance(x1, y1, x2, y2)
	local x = x2 - x1;
	local y = y2 - y1;
	return x * x + y * y;
end

--[[
 * 随机 min 到 max 的数 [min, max]
 * @param min
 * @param max
 * @return
]]
function __this.random(min, max)
	local num = max - min + 1;
	local result = math.floor(math.random() * num) + min;
	return result > max and max or result
end
