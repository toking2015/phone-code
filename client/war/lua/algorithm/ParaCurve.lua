-- ParaCurve.lua
-- 抛物线

ParaCurve = class("ParaCurve", function ()
	return {}
end)

ParaCurve.gravity = -0.02 -- 重力

function ParaCurve:ctor(startX, startY, endX, endY, time, gravity)
	self.gravity = gravity or -0.02
	self.startX = startX
	self.startY = startY
	self.endX = endX
	self.endY = endY
	self.time = time
	self.speedX = (endX - startX) / time
	self.speedY = (endY - startY - self.gravity * time * time / 2) / time
end

function ParaCurve:getCurrentX(time)
	return self.startX + self.speedX * time
end

function ParaCurve:getCurrentY(time)
	return self.startY + self.speedY * time + self.gravity * time * time / 2
end

function ParaCurve:getCurrentSpeedY(time)
	return self.speedY + ParaCurve.gravity * time
end

--当前速度的方向，现在返回角度，如果要返回弧度就去掉math.deg
function ParaCurve:getCurrentRotation(time)
	return math.deg(math.atan(self:getCurrentSpeedY(time) / self.speedX))
end