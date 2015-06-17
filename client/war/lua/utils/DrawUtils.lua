DrawUtils = DrawUtils or {}

local ProgressPoints = {
	[45]={1,1},
	[135]={-1,1},
	[225]={-1,-1},
	[315]={1,-1}
}

--获取矩形上面的点
local function getSquarePoint(degree, halfA, zeroP)
	local rad = math.rad(degree)
	local sin = math.sin(rad)
	local cos = math.cos(rad)
	local radius = nil
	if math.abs(sin) < math.abs(cos) then
		radius = math.abs(halfA / cos)
	else
		radius = math.abs(halfA / sin)
	end
	return cc.p(zeroP.x + radius * cos, zeroP.y + radius * sin)
end

--绘制顺时针扇形外接多边形
function DrawUtils.drawSector(drawNode, starDegree, endDegree, radius, c4f, centerP)
	centerP = centerP or cc.p(0, 0)
	if starDegree > endDegree then
		endDegree = endDegree + 360
	end
	local pointTable = {centerP}
	table.insert(pointTable, getSquarePoint(starDegree, radius, centerP))
	local start = math.floor(starDegree / 45) * 45
	local count = math.floor((endDegree - start) / 45)
	for i = 1, count do
		local degree = start + i * 45
		table.insert(pointTable, getSquarePoint(degree, radius, centerP))
	end
	table.insert(pointTable, getSquarePoint(endDegree, radius, centerP))
	drawNode:clear()
	if starDegree < endDegree then
		drawNode:drawPolygon(pointTable, #pointTable, c4f, 0, cc.c4f(0, 0, 0, 0))
	end
end