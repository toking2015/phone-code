local __this = SkillFlyEffect or {}
SkillFlyEffect = __this
--[[
 * 技能释放飞行粒子特效
 * 起点xy, 终点xy, 持续时间(s)
]]

function __this:createByPoint(p1, p2, time)
	return __this:create(p1.x, p1.y, p2.x, p2.y, time)
end

function __this:create(sx, sy, dx, dy, time)
	time = time or 2 -- 默认2秒
	local part = Particle:create("fight_skill_fly.plist", 0, 0, cc.POSITION_TYPE_GROUPED)
	local node = cc.Node:create()
	node:addChild(part)
	local angle = MathUtil.getAngleByXY(sx, sy, dx, dy)
	part:setAngle(180 + angle)
	node:setPosition(sx, sy)
	local function remove()
		if node:getParent() then
			node:removeFromParent()
		end
	end
	local function stop()
		part:stopSystem()
		local speed = 400
		local adTime = 1
		local cx = dx + speed * adTime * math.cos(math.rad(angle))
		local cy = dy + speed * adTime * math.sin(math.rad(angle))
		node:runAction(cc.MoveTo:create(adTime, cc.p(cx, cy)))
		performWithDelay(node, remove, adTime)
	end
	node:runAction(cc.MoveTo:create(time, cc.p(dx, dy)))
	performWithDelay(node, stop, time)
	return node
end