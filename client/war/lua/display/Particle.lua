Particle =  {}

local prePath = "image/particle/"

--创建粒子，位于image/particle/下面的
--plist plist文件名
--x 坐标
--y 坐标
--posType 位置类型，默认按组
--parent 父对象
--zOrder 层次
function Particle:create(plist, x, y, posType, parent, zOrder)
	local part = cc.ParticleSystemQuad:create(prePath..plist)
	part:setPosition(x, y)
	part:setPositionType(posType or cc.POSITION_TYPE_GROUPED)
	if parent then
		parent:addChild(part, zOrder or 0)
	end
	return part
end
--["POSITION_TYPE_FREE"]  0   
--["POSITION_TYPE_RELATIVE"]  1   
--["POSITION_TYPE_GROUPED"]    2   
