local __this = 
{
    session = 1
}
__this.__index = __this

--时间轴事件======================start
local targetObject = 
{
    role = nil,         --目标方
    roleTime = nil,     --动作起始时间
    effect = nil,       --特效
    effectTime = nil    --特效起始时间
}
function targetObject:new( data )
    local data = 
    {
        role = nil,
        roleTime = 0,     --动作起始时间
        effect = 0,       --特效
        effectTime = 0    --特效起始时间
    }

    setmetatable( data, self )
    self.__index = self
    return data
end
local timeShaftAnimation = 
{
    session = nil,      --验证标识
    role = nil,         --施放方
    actionTime = nil,   --动作起始时间
    effect = nil,       --特效
    effectTime = nil,   --特效起始时间
    fire = nil,          --辅助特效
    fireTime = nil,      --辅助特效起始时间
    
    listTargetObject = {}     --目标方集合列表
}
function timeShaftAnimation:new( data )
    local data = 
    {
        session = 1,      --验证标识
        role = nil,         --施放方
        actionTime = 0,   --动作起始时间
        effect = 0,       --特效
        effectTime = 0,   --特效起始时间
        fire = 0,          --辅助特效
        fireTime = 0,      --辅助特效起始时间

        listTargetObject = {}     --目标方集合列表
    }

    setmetatable( data, self )
    self.__index = self
    return data
end

--创建时间轴事件[不包含移动]
function __this:createTimeShaft( role, skill, time )
	local action = role.body:getActionByFlag( skill.action_flag )
	if nil == action then
	   LogMgr.log('debug', "%s", "skill.action_flag error" )
	   return
	end
	
	local actionEffect = FightFileMgr:getActionEffect( action, skill.effect_index )
	if nil == actionEffect or 11 ~= #actionEffect.timeShaftDataList then
	   LogMgr.log( 'debug', "%s", "timeShaft not in" )
	   return
	end
	
    local animation = timeShaftAnimation:new()
    animation.role = role
    animation.actionTime = FightFileMgr:getTime( actionEffect, "TIME_ACK_ACTION", time )
    
    if 0 ~= actionEffect.AckEffect then
        animation.effect = actionEffect.AckEffect
        animation.effectTime = FightFileMgr:getTime( actionEffect, "TIME_ACK_EFFECT", time )
    end
    
    if 0 == actionEffect.FireEffect then
        animation.listTargetObject = __this:GetTargetList( role, action, actionEffect, time, 0 )
    else
        animation.fire = actionEffect.FireEffect
        animation.fireTime = FightFileMgr:getTime( actionEffect, "TIME_FIRE_EFFECT", time )
        animation.listTargetObject = __this:GetTargetList( role, action, actionEffect, time, 250 )
    end
end

--目标方时间
function __this:GetTargetList( role, action, actionEffect, time, fireTime--[[辅助特效时间--]] )
    --目标列表[SFightSoldier]
    local soldierList = theFight.roundSkillSoldier()
    if nil == soldierList then
        return nil
    end
    
    local list = {}
    for __, soldier in pairs( soldierList ) do
        local roleTarget = FightRoleList:getRole( soldier.guid )
        if nil == roleTarget then
            LogMgr.log( 'debug', "%s", "FightData:__this:GetTargetList error" )
        else
            local target = targetObject:new()
            target.role = roleTarget
            --没有辅助特效
            if 0 == fireTime then
                target.roleTime = FightFileMgr:getTime( actionEffect, "TIME_HURT_ACTION_START", time )
                target.effect = actionEffect.TargetEffect
                target.effectTime = FightFileMgr:getTime( actionEffect, "TIME_HURT_EFFECT", time )
            else
                target.roleTime = FightFileMgr:getTime( actionEffect, "TIME_HURT_ACTION_START", time )
                target.effect = actionEffect.TargetEffect
                target.effectTime = FightFileMgr:getTime( actionEffect, "TIME_HURT_EFFECT", time )
            end
        end
    end
    
    return list
end
--时间轴事件======================end


--动画事件结构表===========================start
function __this.newAnimation( FightAnimation )
    local animation = FightAnimation or {}
    animation.startTime = 0
    animation.endTime = 0
    return animation
end

function __this:getNowFrame(animation, length, time)
    local frame = length * (time - animation.startTime) / (animation.endTime - animation.startTime)
    if frame > length then
        frame = length
    end
    
    return math.ceil(frame)
end

--创建动作动画事件
function __this:createActionAnimation( action, startTime )
    local animation = self.newAnimation()
    if not action then
        animation.type = "stand"
    else
        animation.type = action.flag
    end
    animation.startTime = startTime
    animation.action = action
    animation.endTime = FightFileMgr:getActionEndTime( action, startTime )
    return animation
end

--创建全屏buff动画事件
function __this.createColonyBuffAnimation(animation, role)
    animation.mirror = role:isMirror()
    animation.role = role
    animation.proxyRole = FightRoleMgr:getByIndex(animation.mirror, 4)
    animation.proxyBody = animation.proxyRole.body or role.body
    animation.coord = animation.proxyRole.station:pos()

    return animation
end

--创建施放方身上特效动画事件
function __this:createEffectAnimation(actionEffect, startTime, effectStyle, targetRole, loop, ackRole)
    local animation = self.newAnimation()
    animation.startTime = startTime
    animation.endTime = startTime
    animation.actionEffect = actionEffect
    animation.effectStyle = effectStyle
	animation.mirror = false	--根据自己角色是否取反
	animation.sprite = FightDataMgr.layerEffect
    animation.ackRole = ackRole

    --绑定底层特效
    local bindingAnimation = nil
	
    local list = string.split(effectStyle, '%')
    if 2 ~= #list then
        return animation
    end
    animation.effectName = list[1]
    animation.effectType = list[2]
    
    animation.effect = FightFileMgr:getEffect(list[1])
    if animation.effect then
        animation.endTime = animation.effect:getEffectItemLongTime(list[2], startTime)

        animation.effectItem = animation.effect:getEffectByFlag(animation.effectType)
        if animation.effectItem and targetRole then
            if not targetRole.playerView then
                animation.sprite = nil
            elseif 0 == animation.effectItem.layer then
                animation.sprite = targetRole.playerView.sprite
            else
                animation.sprite = targetRole.playerView.backgroundLayer
            end

            --绑定底层特效
            if '' ~= animation.effectItem.binding and loop then
                bindingAnimation = self:createEffectAnimation(actionEffect, startTime, animation.effectItem.binding, targetRole)
                bindingAnimation.sprite = targetRole.playerView.backgroundLayer
            end
        end
    end

    return animation, bindingAnimation
end

--创建目标方身上特效动画事件
function __this:createTargetEffectAnimation(actionEffect, startTime, effectStyle, targetRole, ackRole)
    local animation, bindingAnimation = self:createEffectAnimation(actionEffect, startTime, effectStyle, targetRole, true, ackRole)
	animation.mirror = true		--根据自己角色是否取反
    
    return animation, bindingAnimation
end

--创建闪避位置动画事件
function __this:createDodgeDisplacement(role, time, actionEffect, max, attr)
    local animation = self.newAnimation()
	animation.startTime = time
	animation.endTime = time
	
	if actionEffect then
		local index = FightFileMgr:getMight(actionEffect, max)
		animation.startTime = time + actionEffect.timeShaftDataList[5]
		animation.endTime = time + actionEffect.timeShaftDataList[index + 3]
	end
	animation.long = 40
	animation.attr = attr
	animation.endPT = cc.p(role.station:x(), role.station:y())
	if role:isMirror() then
		animation.dodgeOffset = cc.p(50, 25)
	else
		animation.dodgeOffset = cc.p(-50, 25)
    end
    
	return animation
end

--获取辅助特效运动轨迹
function __this:createFireDisplacementAnimation(time, effectStyle, role, targetRole, line)
    local list = string.split(effectStyle, '%')
    if 2 ~= #list then
        return nil
    end
	
    local animation = self:createPathAnimation(time)
    animation.effect = FightFileMgr:getEffect(list[1])
    if not animation.effect then
        return nil
    end
    
    local effectItem = animation.effect:getEffectByFlag(list[2])
    if not effectItem then
        return nil
    end
    animation.effectStyle = effectStyle
    animation.effectName = list[1]
    animation.effectType = list[2]
    animation.effectItem = effectItem
	animation.mirror = false	--根据自己角色是否取反
	animation.line = line
	--[[if not targetRole.playerInfo then--]]
		animation.sprite = FightDataMgr:getLayerEffect()
	--[[elseif targetRole:index() > role:index() then
        animation.sprite = targetRole.playerView.sprite
    else
        animation.sprite = role.playerView.sprite
	end--]]
	
    local fixCoord = cc.p(effectItem.coordX - role.body.bodyX, targetRole.body.bodyY - role.body.bodyY)
    local endPT = cc.p(targetRole.station:x(), targetRole.station:y() - fixCoord.y)
    local startPT = cc.p(role.station:x(), role.station:y())
    
    if not role:isMirror() then
        startPT.x = startPT.x + fixCoord.x
        
        local fix = math.abs(startPT.x - endPT.x)
        if startPT.y == endPT.y then
            animation.angle = 0
        else
            animation.angle = math.deg(math.atan((startPT.y - endPT.y)/fix))
        end
        endPT = cc.pSub(endPT, startPT)
    else
        startPT.x = startPT.x - fixCoord.x
		
        local fix = math.abs(startPT.x - endPT.x)
        if startPT.y == endPT.y then
            animation.angle = 0
        else
            -- animation.angle = math.deg(math.atan(math.abs(startPT.y - endPT.y)/fix))
            animation.angle = math.deg(math.atan((endPT.y - startPT.y)/fix))
        end
        endPT = cc.pSub(endPT, startPT)
    end

    animation.startPT = cc.p(0,0)
    animation.endPT = endPT
    animation.endTime = animation.startTime + 230
    
    return animation
end

--解释辅助特效并修正受击动作时间点
function __this:parseFire(time, role, target, action, actionEffect, interval, indexTimeShaft, soundFlag)
    --辅助特效处理
    if '' == actionEffect.fireEffect or FightFileMgr.checkSame(actionEffect.fireEffect) then
        return
    end

    local animationFrie = self:createFireDisplacementAnimation(
        actionEffect.timeShaftDataList[indexTimeShaft] + time + interval, 
        actionEffect.fireEffect, 
        role, 
        target, 
        action.line
    )
    
    if not animationFrie then
        return
    end

    animationFrie.mirror = not target:isMirror()
    --动态计算辅助特效飞行时间[以恒定速度计算]
    --基于默认时间轴修正值
    local fixAction = actionEffect.timeShaftDataList[indexTimeShaft + 2] + time - animationFrie.endTime
    --基于默认时间轴修正值
    local fixEffect = actionEffect.timeShaftDataList[indexTimeShaft + 1] + time - animationFrie.endTime
    local startCoord = animationFrie.startPT
    local endCoord = animationFrie.endPT
    local pathTime = cc.pGetDistance(startCoord, endCoord) / 55 * 25
    animationFrie.endTime = animationFrie.startTime + pathTime
    table.insert(role.effectAnimationList, animationFrie)
    
    local roleAnimation = target:getLastAction("bruise")
    if roleAnimation then
        roleAnimation.startTime = animationFrie.endTime - 50
        roleAnimation.endTime = roleAnimation.startTime 
            + (actionEffect.timeShaftDataList[indexTimeShaft + 3] - actionEffect.timeShaftDataList[indexTimeShaft + 2])
    end

    if not soundFlag and role.sound then
        self:createSound(
            role, 
            animationFrie.startTime, 
            role.sound:getActionByFlag(
                action.flag, 
                actionEffect.index, 
                FightFileMgr.sound_enum.FIRE
            )
        )
    end

    return animationFrie
end

--解释辅助特效并修正受击动作时间点[图腾专用]
function __this:parseFireTotem(totemTime, runTime, role, target, action, actionEffect, interval, indexTimeShaft)
    --辅助特效处理
    if '' == actionEffect.fireEffect or FightFileMgr.checkSame(actionEffect.fireEffect) then
        return
    end

    local animationFrie = self:createFireDisplacementAnimation(
        actionEffect.timeShaftDataList[indexTimeShaft] + totemTime + interval, 
        actionEffect.fireEffect, 
        role, 
        target, 
        action.line
    )
    
    if not animationFrie then
        return
    end

    animationFrie.mirror = not target:isMirror()
    --动态计算辅助特效飞行时间[以恒定速度计算]
    --基于默认时间轴修正值
    local fixAction = actionEffect.timeShaftDataList[indexTimeShaft + 2] + totemTime - animationFrie.endTime
    --基于默认时间轴修正值
    local fixEffect = actionEffect.timeShaftDataList[indexTimeShaft + 1] + totemTime - animationFrie.endTime
    local startCoord = animationFrie.startPT
    local endCoord = animationFrie.endPT
    local pathTime = cc.pGetDistance(startCoord, endCoord) / 55 * 25
    animationFrie.endTime = animationFrie.startTime + pathTime
    table.insert(role.effectAnimationList, animationFrie)
    
    local roleAnimation = target:getLastAction("bruise")
    if roleAnimation then
        roleAnimation.startTime = actionEffect.timeShaftDataList[1] + runTime + pathTime
        roleAnimation.endTime = roleAnimation.startTime 
            + (actionEffect.timeShaftDataList[indexTimeShaft + 3] - actionEffect.timeShaftDataList[indexTimeShaft + 2])
    end

    if role.sound then
        self:createSound(
            role, 
            animationFrie.startTime, 
            role.sound:getActionByFlag(
                action.flag, 
                actionEffect.index, 
                FightFileMgr.sound_enum.FIRE
            )
        )
    end

    return animationFrie
end

--场景动画boss出现专用移动动画事件
function __this:createSceneBossPathAnimation( startTime, role, endTime )
    local animation = self.newAnimation()
    animation.startTime = startTime
    animation.endTime = endTime
	animation.long = 680--math.ceil((endTime - startTime) / 10)
	animation.alpha = true

    --移动
    animation.startPT = cc.p(0,0)
    animation.startPTto = cc.p(0,0)
    animation.endPT = cc.p(0,0)
    animation.endPTto = cc.p(0,0)

	animation.startPT.x = role.station:x()
	animation.startPT.y = role.station:y() - role.body.footY * 4
	animation.startPTto.x = animation.startPT.x
	animation.startPTto.y = animation.startPT.y
	animation.endPT.x = role.station:x()
	animation.endPT.y = role.station:y()
	animation.endPTto.x = animation.startPTto.x
	animation.endPTto.y = animation.startPTto.y
    
    return animation
end

function __this.isIndex(list, ...)
    local l = {...}
    for __, v1 in pairs(list) do
        for __, v2 in pairs(l) do
            if v2 == v1 then
                return true
            end
        end
    end

    return false
end

--瞬间移动到某个坐标
function __this:createPathOffsetAnimation(time, role, pt)
    local animation = self.newAnimation()
    animation.startTime = time
    animation.endTime = time
    animation.role = role
    animation.pt = pt
    animation.long = 40
    return animation
end

--瞬间移动动画事件
function __this:createPathAnimation( startTime, role, action, log, skill, isBack )
    local animation = self.newAnimation()
    animation.startTime = startTime
    animation.endTime = startTime
	animation.long = 40
    if not role then
        return animation
    end
    
    local targetRole = nil
	if 2 == skill.target_range_cond 
        or (11 == skill.target_range_cond and skill.target_range_count >= 2)
	then
		targetRole = FightRoleMgr:getByIndex(not role:isMirror(), 4)
	elseif 4 == skill.target_range_cond or 5 == skill.target_range_cond 
        or 6 == skill.target_range_cond or 7 == skill.target_range_cond 
        or 8 == skill.target_range_cond 
    then
        local ptList = {}
        for __, orderTarget in pairs(log.orderTargetList) do
            local target = FightRoleMgr:getRole(orderTarget.guid)
            if target and role:isMirror() ~= target:isMirror() then
                table.insert(ptList, role:index())
            end
        end
        table.sort(ptList)
        if self.isIndex(ptList, 0, 3, 6) then
            targetRole = FightRoleMgr:getByIndex(not role:isMirror(), 3)
        elseif self.isIndex(ptList, 1, 4, 7) then
            targetRole = FightRoleMgr:getByIndex(not role:isMirror(), 4)
        else
            targetRole = FightRoleMgr:getByIndex(not role:isMirror(), 5)
        end
	else
		for __, orderTarget in pairs(log.orderTargetList) do
			if log.order.guid ~= orderTarget.guid then
				targetRole = FightRoleMgr:getRole(orderTarget.guid)
				break
			end
		end
	end
    
    if not targetRole then
        return animation
    end

    --移动
    animation.startPT = cc.p(0,0)
    animation.startPTto = cc.p(0,0)
    animation.endPT = cc.p(0,0)
    animation.endPTto = cc.p(0,0)

    if isBack then
        animation.startPT.x = targetRole.station:destX(action.targetFocusX - role.body.bodyX)
        animation.startPT.y = targetRole.station:y() - 3
        animation.startPTto.y = animation.startPT.y
        animation.endPT.x = role.station:x()
        animation.endPT.y = role.station:y()
        animation.endPTto.y = animation.endPT.y
        
        if false == role:isMirror() then
            animation.startPTto.x = animation.startPT.x - 50
            animation.endPTto.x = animation.endPT.x + 50
        else
            animation.startPTto.x = animation.startPT.x + 50
            animation.endPTto.x = animation.endPT.x - 50
        end
    else
        animation.startPT.x = role.station:x()
        animation.startPT.y = role.station:y()
        animation.startPTto.y = animation.startPT.y
        animation.endPT.x = targetRole.station:destX(action.targetFocusX - role.body.bodyX)
        animation.endPT.y = targetRole.station:y() - 3
        animation.endPTto.y = animation.endPT.y
        
        if false == role:isMirror() then
            animation.startPTto.x = animation.startPT.x + 50
            animation.endPTto.x = animation.endPT.x - 50
        else
            animation.startPTto.x = animation.startPT.x - 50
            animation.endPTto.x = animation.endPT.x + 50
        end
    end
    
    --渐变
    animation.alphaList = {}
    for i = 1, 20, 1 do
        table.insert(animation.alphaList, 255 - 255 / 20 * i)
    end
    for i = 1, 20, 1 do
        table.insert(animation.alphaList, 255 / 20 * i)
    end
    
    animation.endTime = 300 + startTime
    return animation
end

function __this:setPath(time, startPT, endPT, mirror, isBack)
    local animation = self.newAnimation()
    animation.startPTto = cc.p(0,0)
    animation.endPTto = cc.p(0,0)
    
    animation.startTime = time
    animation.endTime = time + 300
    animation.long = 40
    animation.startPT = startPT
    animation.endPT = endPT
    animation.startPTto.y = startPT.y
    animation.endPTto.y = endPT.y
    if isBack then
        if not mirror then
            animation.startPTto.x = animation.startPT.x - 50
            animation.endPTto.x = animation.endPT.x + 50
        else
            animation.startPTto.x = animation.startPT.x + 50
            animation.endPTto.x = animation.endPT.x - 50
        end
    else
        if not mirror then
            animation.startPTto.x = animation.startPT.x + 50
            animation.endPTto.x = animation.endPT.x - 50
        else
            animation.startPTto.x = animation.startPT.x - 50
            animation.endPTto.x = animation.endPT.x + 50
        end
    end
    
    --渐变
    animation.alphaList = {}
    for i = 1, 20, 1 do
        table.insert(animation.alphaList, 255 - 255 / 20 * i)
    end
    for i = 1, 20, 1 do
        table.insert(animation.alphaList, 255 / 20 * i)
    end
    
    return animation
end
        
--血量变化动画事件
function __this:createSubValueAnimation( orderTarget, time )
    local animation = self.newAnimation()
	animation.orderTarget = orderTarget
    animation.fight_result = orderTarget.fight_result
    animation.fight_value = orderTarget.fight_value * -1
    animation.fight_type = orderTarget.fight_type
    animation.hp = orderTarget.fight_value * -1
    if trans.const.kFightAddHP == orderTarget.fight_result then
        animation.fight_value = orderTarget.fight_value
        animation.hp = orderTarget.fight_value
    end

    animation.rage = orderTarget.rage
    animation.startTime = time
    animation.endTime = animation.startTime + 850;
	if trans.const.kFightCommon == animation.fight_type then
		if trans.const.kFightDicHP == animation.fight_result then
			if 0 ~= animation.orderTarget.fight_might then
				animation.endTime = animation.startTime + 1050--750;
			end
		end
	elseif trans.const.kFightCrit == animation.fight_type then
		animation.endTime = animation.startTime + 1350
	end
    
    animation.startPT = cc.p(0,0)
    animation.endPT = cc.p(0,150)
    
    return animation;
end

--身上特效动画事件
function __this:createBodyAnimation( time, oddSet, odd, effect, role, flag )
    local animation = self.newAnimation()
    animation.startTime = time
    animation.oddSet = oddSet
    animation.odd = odd
    animation.sprite = role.playerView.sprite

    if effect then
        animation.effect = effect
        if flag then
            animation.effectItem = effect:getEffectByFlag(flag)
        else
            animation.effectItem = effect:getEffectNormal()
        end
        if not animation.effectItem then
            return animation
        end
        animation.effectType = animation.effectItem.flag

        if 1 == animation.effectItem.layer then
            animation.sprite = role.playerView.backgroundLayer
        end
    end
    return animation
end

--buff动画事件
function __this:createOddAnimation( oddSet, odd, time, state )
    local animation = self.newAnimation()
    animation.startTime = time
    animation.odd = odd
    animation.type = oddSet.odd_set_type
    animation.state = state
    return animation
end

--召唤事件[包含召唤、应召相关动作事件]
function __this:createCallAnimation(time, orderTarget, role, attr)
    local animation = self.newAnimation()
    animation.startTime = time
    animation.endTime = time + 10
    animation.call = {}
    animation.isMirror = role:isMirror()
    animation.user = role.playerInfo
    animation.attr = attr
    
    local fightSoldier1 = nil
    local fightSoldier2 = nil
    if 0 ~= orderTarget.fight_value then
        fightSoldier1 = FightDataMgr.theFight:findSoldier( orderTarget.fight_value )
        if fightSoldier1 then
            -- table.insert(animation.call, fightSoldier1)
            local newRole = FightRoleMgr:getByIndex(mirror, fightSoldier1.fight_index)
            if newRole then
                newRole:attrCall(FightDataMgr:getLayerRole(), time, role.playerInfo, fightSoldier1)
            end
        end
    end
    if orderTarget.fight_value2 and 0 ~= orderTarget.fight_value2 then
        fightSoldier2 = FightDataMgr.theFight:findSoldier( orderTarget.fight_value2 )
        if fightSoldier2 then
            -- table.insert(animation.call, fightSoldier2)
            local newRole = FightRoleMgr:getByIndex(mirror, fightSoldier2.fight_index)
            if newRole then
                newRole:attrCall(FightDataMgr:getLayerRole(), time, role.playerInfo, fightSoldier2)
            end
        end
    end
    table.insert(role.callChangeAnimationList, animation)
    local newTime = animation.endTime

    --添加召唤动作事件[应召动作事件放于动画循环处实时添加]
    local action = role.body:getActionByFlag("call1")
    if action then
        local actionEffect = FightFileMgr:getActionEffect(action, 0)
        if actionEffect then
            FightAnimationMgr:parseAckRole(role, action, actionEffect, nil, time, nil, 0)
            animation.startTime = actionEffect.timeShaftDataList[5] + time
            animation.endTime = animation.startTime + 10
            newTime = animation.endTime

            if '' ~= actionEffect.targetEffect then
                local list = string.split(actionEffect.targetEffect, '%')
                if 2 == #list then
                    local effect = FightFileMgr:getEffect(list[1])
                    if effect then
                        if fightSoldier1 then
                            local newRole = FightRoleMgr:getByIndex(role:isMirror(), fightSoldier1.fight_index)
                            if newRole then
                                local oddSet = {set_type = trans.const.kObjectAdd}
                                local odd = {id = list[1], onceeffect = list[1]}
                                local callAnimation = FightData:createBodyAnimation(animation.startTime, oddSet, odd, effect, newRole)
                                callAnimation.role = newRole
                                newRole:filterBodyEffectAdd(callAnimation)
                            end
                        end

                        if fightSoldier2 then
                            local newRole = FightRoleMgr:getByIndex(role:isMirror(), fightSoldier2.fight_index)
                            if newRole then
                                local oddSet = {set_type = trans.const.kObjectAdd}
                                local odd = {id = list[1], onceeffect = list[1]}
                                local callAnimation = FightData:createBodyAnimation(animation.startTime, oddSet, odd, effect, newRole)
                                callAnimation.role = newRole
                                newRole:filterBodyEffectAdd(callAnimation)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return newTime
end

--变身事件
function __this:createAttrChangeAnimation(time, soldier, attr)
    local animation = self.newAnimation()
    animation.startTime = time
    animation.endTime = time + FightDataMgr.theScene.scene:getChangeTime() * 1000
    animation.soldier = soldier
    animation.attr = 1

    return animation
end

--石化
function __this:createChangeModelAnimation(time, role, style)
    local animation = self.newAnimation()
    animation.startTime = time
    animation.endTime = time
    animation.style = style
    animation.attr = 3

    table.insert(role.callChangeAnimationList, animation)
    return animation
end

--添加音效
function __this:createSound(role, time, effectSound)
	if not effectSound then
		return nil
	end
		
	local animation = self.newAnimation()
	animation.attr = effectSound.attr
	animation.sound = effectSound.sound
	animation.startTime = time + effectSound.time
    animation.endTime = animation.startTime
	table.insert(role.soundAnimationList, animation)

    return animation
end

--添加场景语音事件
function __this.createSceneSound(time, sound, file)
    local animation = FightData.newAnimation()
    animation.file = file or "talk"
    animation.sound = sound

    table.insert(FightDataMgr.sceneSoundAnimationList, animation)
end

--[[喊招事件  
    [attr-- 0:觉醒    1:技能    2:buff  
        3:觉醒失败  4:文本odd 5:纯文本   
        6:反击        7:反弹]
    ]]
function __this:createSkillName(role, time, attr, skill, odd, fightOdd, s2, val)
    local animation = self.newAnimation()
    animation.attr = attr
    animation.startTime = time
    animation.skill = skill
    animation.odd = odd
    animation.role = role
    animation.fightOdd = fightOdd
    animation.s2 = s2
    animation.val = val

    if 0 == attr then
        animation.endTime = time + 1225
    else
        animation.endTime = time + 1350
    end

    return animation
end

--奖励事件
function __this:createItemRewardFloor1(role, time, gravity, offset, coin)
    local animation = self.newAnimation()
    animation.attr = 1
    animation.gravity = gravity
    animation.offset = offset
    animation.startTime = time
    animation.endTime = time + 400
    animation.role = role
    animation.startPT = role.station:pos()
    if role:isMirror() then
        animation.endPT = cc.p(role.station:x() + 50 + offset, role.station:y() + 10)
    else
        animation.endPT = cc.p(role.station:x() - 50 - offset, role.station:y() + 10)
    end

    animation.itemView = FightTextMgr:useItemReward(coin)

    return animation
end
function __this:createItemRewardFloor2(role, time, gravity, offset, itemView)
    local animation = self.newAnimation()
    animation.attr = 2
    animation.gravity = gravity
    animation.offset = offset
    animation.startTime = time
    animation.endTime = time + 300
    animation.role = role
    if role:isMirror() then
        animation.startPT = cc.p(role.station:x() + 50 + offset, role.station:y() + 10)
        animation.endPT = cc.p(animation.startPT.x + 20 + offset, role.station:y() + 10)
    else
        animation.startPT = cc.p(role.station:x() - 50 - offset, role.station:y() + 10)
        animation.endPT = cc.p(animation.startPT.x - 20 - offset, role.station:y() + 10)
    end

    animation.itemView = itemView

    return animation
end
function __this:createItemRewardFloor3(role, time, gravity, offset, itemView)
    local animation = self.newAnimation()
    animation.attr = 3
    animation.gravity = gravity
    animation.offset = offset
    animation.startTime = time
    animation.endTime = time + 500
    animation.role = role
    animation.endPT = cc.p(FightDataMgr.theFightUI.box:getPositionX() + FightDataMgr.theFightUI.box.size.width / 2, FightDataMgr.theFightUI.box:getPositionY() + FightDataMgr.theFightUI.box.size.height / 2)
    if role:isMirror() then
        animation.startPT = cc.p(role.station:x() + 70 + offset, role.station:y())
    else
        animation.startPT = cc.p(role.station:x() - 70 - offset, role.station:y())
    end

    animation.itemView = itemView

    return animation
end
--动画事件结构表===========================end


--坐标结构表===========================start
local FightStation = 
{
    index = 0,
    vX = 0,
    vY = 0,
    isMirror = false
}
function FightStation:new( FightStation, i )
    local station = FightStation or {}
    
    station.index = i % 9   --位置索引
    if i < 9 then
        station.isMirror = false    --镜像标识
    else
        station.isMirror = true
    end

    setmetatable(station, self)
    self.__index = self
    return station
end

function FightStation:x()
    return self.vX
end

function FightStation:y()
    return self.vY
end

function FightStation:pos()
    return cc.p(self:x(), self:y())
end

--获取敌人近身攻击当前人物时, 敌人的站位
function FightStation:destX( distance )
    if 0 == distance then
        if false == self.isMirror then
            return self:x() + 130
        else
            return self:x() - 130
        end
    end
    
    if false == self.isMirror then
        return self:x() + distance
    else
        return self:x() - distance
    end
end
--坐标结构表===========================end


--坐标列表===========================start
local FightStationList = {}
function FightStationList:setPos(index, x, y)
    self[index].vX = x
    self[index].vY = y
end

function FightStationList:init( FightStationList )
    local listStation = FightStationList or {}
    for i = 0, 17 do
        local station = FightStation:new( nil, i )
        station.vX = 0
        station.vY = 0
        table.insert(listStation, station)
    end
    
    setmetatable(listStation,self)
    self.__index = self
    return listStation
end

function FightStationList:initPos()
    --单边阵型最大宽度 370
    local leftFix = 50
    local rightFix = 50
    if visibleSize.width - 390 * 2 < 100 then
        leftFix = 0
        rightFix = 0
    end
    local heightFix = (768 - visibleSize.height) / 2
 
    self:setPos(1, leftFix + 444, 392 - heightFix)
    self:setPos(2, leftFix + 303, 394 - heightFix)
    self:setPos(3, leftFix + 162, 393 - heightFix)
    self:setPos(4, leftFix + 399, 302 - heightFix)
    self:setPos(5, leftFix + 258, 304 - heightFix)
    self:setPos(6, leftFix + 117, 303 - heightFix)
    self:setPos(7, leftFix + 353, 212 - heightFix)
    self:setPos(8, leftFix + 212, 214 - heightFix)
    self:setPos(9, leftFix +  71, 213 - heightFix)

    self:setPos(10, visibleSize.width - (rightFix + 443), 392 - heightFix)
    self:setPos(11, visibleSize.width - (rightFix + 302), 394 - heightFix)
    self:setPos(12, visibleSize.width - (rightFix + 161), 393 - heightFix)
    self:setPos(13, visibleSize.width - (rightFix + 398), 302 - heightFix)
    self:setPos(14, visibleSize.width - (rightFix + 257), 304 - heightFix)
    self:setPos(15, visibleSize.width - (rightFix + 116), 303 - heightFix)
    self:setPos(16, visibleSize.width - (rightFix + 352), 212 - heightFix)
    self:setPos(17, visibleSize.width - (rightFix + 211), 214 - heightFix)
    self:setPos(18, visibleSize.width - (rightFix +  70), 213 - heightFix)
end

function FightStationList:get( i )
    if i + 1 > #self then
        return nil
    else
        return self[i + 1]
    end
end
--坐标列表===========================end

FightData = __this
FightData.stationList = FightStationList:init()
FightData.stationList:initPos()