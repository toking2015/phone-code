local const = trans.const

require( "lua/game/view/fight/struct/FightData.lua" )
--参战人员数据集合
require( "lua/game/view/fight/struct/SFightRole.lua" )

--[[
图腾动画逻辑处理原则：
    表现要求：使用图腾时除了当前图腾有动作与相关特效有表现外，其余一切角色、特效都必须定格。

    处理方式：图腾触发的一切事件以图腾自身为事件寄宿体，单独循环图腾相关事件，其余角色相关事件跳过不遍历！

    【特殊注意】：如果为非图腾添加事件，需使用原时间线
]]

--战斗动画管理
local __this = 
{
	--图腾触发技能事件
	totemAnimationList = {},

    --[[未归类事件 [开始与结束时间为一致]
        1:没有目标【文本显示】
        2:死亡蝴蝶事件【涉及所有角色】
        ]]
    othersAnimationList = {},

    --下一自动触发触发时间
    autoTime = nil,
    dearTime = 0,
    ------------station value---------------start
    --眩晕
    dizziness = 6,
    --死亡后两个回合复活
    resurrection = 54,
    --觉醒状态值
    disillusion = 128,
    --风怒
    windfury = 134,
    --震慑
    -- shockAndAwe = 152,
    --新加个变形术(变成羊)，中了这个状态不能行动,但被攻击后变羊的状态会消失。
    sheep = 195,
    --新加个变形术(变成青蛙)，中了这个状态不能行动，就算给打了变形术的状态也不会消失。
    frog = 196,
    --石化
    petrifaction = 201,
    --飓风：令随机N个目标进入飓风状态（被驱逐出场）N回合
    hurricane = 202,
    --潜行状态
    sneak = 36,
    --嘲讽
    taunt = 89,
    ------------station value---------------end

    ----------------odd id--------------------start
    --具体打断效果的buff
    oddList = {
        [1167]=true, 
        [1168]=true, 
        [1186]=true, 
        [1280]=true,
    },
    ----------------odd id--------------------end

    --特殊处理的图腾
    totemDisillList={
        [80001]=true,
        [80003]=true,
        [80005]=true,
    },
}
__this.__index = __this

function __this.newObject( time )
    local obj = 
    {
        --整体事件开始时间点
        startTime = time,
        --整体事件结束时间点
        endTime = time,
        --近身移动到目标的时间点
        pathTime = time,
        --击打目标时间点
        targetTime = time,
        --施放者攻击时间点
        ackTime = time,

        idleTime = time,
        dearTime = time,
    }
    
    return obj
end

--缩放渲染
function __this:runScale(time, role)
    local play = role.playerView
    local list = role.scaleAnimationList
    local del = {}

    for i, data in pairs(list) do
        if time > data.endTime then
            table.insert(del,i)
        elseif time > data.startTime then
            local scale = 1
            if (time - data.startTime) <= 100 then
                scale = 1 + (time - data.startTime) / 100 * (data.scale - 1)
            elseif data.endTime - time <= 100 then
                scale = 1 + (data.endTime - time) / 100 * (data.scale - 1)
            else
                scale = data.scale
            end
            play:setScale(scale)
        end
    end

    for i = #del, 1, -1 do
        table.remove(list, del[i])
        play:setScale(1)
    end
end

--动作渲染
function __this:runAnimation(time, role, mirror, infoVisible)
    local play = role.playerView
    local list = role.actionAnimationList
    local del = {}
    local flag = false
    
    for i, data in pairs(list) do
        if data.endTime > 0 and time > data.endTime then
            table.insert(del,i)
        else
            if time > data.startTime then
                flag = true
                local run = false
                if 0 == data.endTime and #list > i then
                    if time > list[i + 1].startTime then
                        run = true
                    end
                end

                if not run then
                    play:chnAction(mirror, data.type, data, role)
                    
    				--[stand]&[chuxian]
                    if "stand" == data.type or "faguang" == data.type then
                        play:stand(time)
                    else
                        local frame = FightData:getNowFrame(data, play.totalFrames, time )
                        if frame > 0 then
                            frame = frame - 1
                        end
                        if frame + 1 >= play.totalFrames then
                            frame = play.totalFrames - 1
                        end
                        play:attack(frame, data, role)
                    end
                end
            end
        end
    end
    
    for i = #del, 1, -1 do
        table.remove(list, del[i])
    end

    if not flag then
        if time > role.dearTime then
            play:chnAction(mirror, "dead")
            play:attack(play.totalFrames - 1)
			
			if role.hpView then
				role.hpView:setVisible(false)
			end
        else
            play:chnAction(mirror, "stand")
            play:stand(time)
			
			if role.hpView then
				role.hpView:setVisible(true)
			end
        end
    end
end

--特效渲染
function __this:runEffect(time, role, isMirror)
    local list = role.effectAnimationList
    local play = role.playerView
    local del = {}
	local targetRole = role

    for i, data in pairs(list) do
        if time > data.endTime then
            table.insert(del, i)

        elseif time > data.startTime then
            FightEffectMgr:useEffect(data, data.sprite, data.role)
			if not data.uiEffect then
				table.insert(del, i)
			else
				local mirror = isMirror
                if 1 == data.effectItem.mirror then
                    mirror = false
                end
				
				if data.role then
					targetRole = data.role
					play = targetRole.playerView
				else
					targetRole = role
					play = role.playerView
				end
                data.uiEffect:setMirror(mirror)
                local p = nil
                if not data.p then
                    if data.startPT and data.endPT then
                        if mirror then
                            local pFix = cc.p(targetRole.body.footX - data.uiEffect:getItemX(), targetRole.body.footY - data.uiEffect:getItemY())
                            p = cc.p(play:getPositionX() + pFix.x, play:getPositionY() + pFix.y)
                        else
                            local pFix = cc.p(-targetRole.body.footX + data.uiEffect:getItemX(), targetRole.body.footY - data.uiEffect:getItemY())
                            p = cc.p(play:getPositionX() + pFix.x, play:getPositionY() + pFix.y)
                        end
                    else
                        if mirror then
                            p = cc.p(targetRole.body.footX - data.uiEffect:getItemX(), targetRole.body.footY - data.uiEffect:getItemY())
                        else
                            p = cc.p(-targetRole.body.footX + data.uiEffect:getItemX(), targetRole.body.footY - data.uiEffect:getItemY())
                        end
                    end
                    
                    data.p = p
                end
				
				p = data.p
				local pt = p
				--移动轨迹
				if data.startPT and data.endPT then
                    data.uiEffect:setMirror(data.mirror)
					if 1 == data.line then
						if not data.paraCurve then
                            data.paraCurve = ParaCurve.new(data.p.x, data.p.y, data.p.x + data.endPT.x, data.p.y + data.endPT.y, data.endTime - data.startTime)
                            --data.paraCurve = ParaCurve.new(0, 0, data.endPT.x, data.endPT.y, data.endTime - data.startTime)
                        end
						
						pt.x = data.paraCurve:getCurrentX(time - data.startTime)
						pt.y = data.paraCurve:getCurrentY(time - data.startTime)
						data.uiEffect:setRotation(data.paraCurve:getCurrentRotation(time - data.startTime))
					else
						data.uiEffect:setRotation(data.angle)
						local frame = FightData:getNowFrame(data, 25, time) + 1
						if frame > 25 then
							frame = 25
						end
						
						pt = cc.p(data.endPT.x / 25 * frame, data.endPT.y / 25 * frame)
						pt.x = p.x + pt.x
						pt.y = p.y + pt.y
					end
    		    end
                data.uiEffect:setPosition(pt)
				
				local frame = FightData:getNowFrame(data, data.uiEffect.totalFrames or data.uiEffect.effectItem.count, time )
                if frame > 0 then
                    frame = frame - 1
                end
                if frame + 1 >= data.uiEffect.totalFrames then
                    frame = data.uiEffect.totalFrames - 1
                end
                data.uiEffect:attack(frame, data)
			end
        end
    end
    
    for i = #del, 1, -1 do
        local index = del[i]
        local data = list[index]
        FightEffectMgr:unEffect(data)
        table.remove(list, index)
    end
end

--buff特效
function __this:runBodyEffect(time, role, isMirror)
    local list = role.bodyEffectAnimationList
    local play = role.playerView
    local del = {}
	local targetRole = role
    
    for i, data in pairs(list) do
        if 0 ~= data.endTime and time >= data.endTime then
            table.insert(del, i)
        elseif time > data.startTime then
            if trans.const.kObjectDel == data.oddSet.set_type then
                table.insert(del, i)
                
                for j = i - 1, 1, -1 do
                    if data.odd.id == list[j].odd.id then
                        list[j].endTime = time
                    end
                end
            else
				if data.role then
					targetRole = data.role
				else
					targetRole = role
				end
				
                play = targetRole.playerView
                FightEffectMgr:useEffect(data, data.sprite)
                if not data.uiEffect then
                    table.insert(del, i)
                else
                    data.uiEffect:setMirror(isMirror)
					local p = nil
                    if isMirror then
                        p = cc.p(targetRole.body.footX - data.uiEffect:getItemX(), targetRole.body.footY - data.uiEffect:getItemY())
                    else
                        p = cc.p(-targetRole.body.footX + data.uiEffect:getItemX(), targetRole.body.footY - data.uiEffect:getItemY())
                    end

                    if data.odd.buff_offset and 0 ~= data.odd.buff_offset then
                        if 1 == data.odd.buff_offset then
                            p.y = p.y + targetRole.body.bodyY - targetRole.body.headY
                        else
                            p.y = p.y + targetRole.body.bodyY - targetRole.body.footY
                        end
                    end
                    data.uiEffect:setPosition(p)
                    
                    local frame = ((time - data.startTime) / data.uiEffect.frameRate) % data.uiEffect.totalFrames
                    if frame + 1 >= data.uiEffect.totalFrames then
                        frame = data.uiEffect.totalFrames - 1
                    end
                    data.uiEffect:attack(frame)
                end
            end
        end
    end
    
    for i = #del, 1, -1 do
        local index = del[i]
        local data = list[index]
        FightEffectMgr:unEffect(data)
        table.remove(list, index)
    end
end

--伤害数字
function __this:runNumber(time, role)
    local list = role.hpAnimationList
    local play = role.playerView
    local del = {}
	local targetRole = role
    local attr = false

    for i, data in pairs(list) do 
        if data.role then
            targetRole = data.role
            play = targetRole.playerView
        else
            targetRole = role
            play = role.playerView
        end
        if targetRole:checkAttr(const.kAttrMonster) and 2 == targetRole.monster.type then
            attr = true
        else
            attr = false
        end

        if time > data.endTime then
            table.insert(del, i)
			
			if data.hp and attr then
				FightDataMgr.theFightUI:setSecondBossHp(data.hp)
			end

            --大boss血条第二层事件
            if not data.hpView then
                data.hpView = true
                if targetRole.hpView then
                    if not FightDataMgr.test and attr then
                        FightDataMgr.theFightUI:setbossHp(data.fight_value)
                    end
                    targetRole.hpView:set_Hp(time, data.fight_value)
                end
            end
			
        elseif time > data.startTime then
            if targetRole.hpView and not data.hpView then
                data.hpView = true
                local soldier = FightDataMgr.theFight:findSoldier(targetRole.guid)
                if soldier then
                    for __, animation in pairs(targetRole.hpAnimationList) do
                        if not animation.hpView and math.floor(FightDataMgr.runTime * 1000) > animation.startTime then
                            targetRole.hpView:set_Hp(time, animation.fight_value)
                            if attr then
                                FightDataMgr.theFightUI:setbossHp(animation.fight_value)
                                FightDataMgr.theFightUI:setSecondBossHp(animation.hp)
                            end
                            animation.fight_value = 0
                            animation.hp = 0
                            animation.hpView = true
                        end
                    end

                    if attr then
                        FightDataMgr.theFightUI:setbossHp(data.fight_value)
                    end
                    targetRole.hpView:set_Hp(time, data.fight_value)
                end
            end

			if self.flagTotem then
				FightNumberMgr:useRedNumber(data, FightDataMgr:getLayerBlackEffect())
			else
				FightNumberMgr:useRedNumber(data, FightDataMgr:getLayerNumber())
			end
			
            if not data.coord then
                if not data.offset then
                    data.coord = cc.p(play:getPositionX() + 50, play:getPositionY() + targetRole.body.footY - targetRole.body.bodyY + 30)
                else
                    data.coord = cc.p(play:getPositionX() - 50, play:getPositionY() + targetRole.body.footY - targetRole.body.bodyY + 70)
                end

                if data.coord.x < 0 then
                    data.coord.x = 0
                end

                if data.coord.x + data.number.size.width > visibleSize.width then
                    data.coord.x = visibleSize.width - data.number.size.width
                end
            end

			data.number:idle(time, data, data.coord)
		end
	end
	
	for i = #del, 1, -1 do
		local data = list[del[i]]
		FightNumberMgr:unRedNumber(data)
		table.remove(list, del[i])
	end
	
	if role.hpView then
		role.hpView:hp_update(time)
	end

    local soldierList = FightRoleMgr:getAllSoldier()
    for __, targetRole in pairs(soldierList) do
        if targetRole.hpView then
            targetRole.hpView:hp_update(time)
        end
    end
end

--怒气更新
function __this:runRage(time, role)
    if not role then
        return
    end
    local list = role.rageAnimationList
    local del = {}

    for i, data in pairs(list) do
        if time >= data.endTime then
            table.insert(del, i)
        end
    end

    for i = #del, 1, -1 do
        local data = table.remove(list, del[i])
        if data.role.hpView then
            data.role.hpView:set_Rage(data.rage)
            data.role.hpView:hp_update(time)
        end
    end
end

--喊招
function __this:runSkill(time, role)
    local list = role.skillAnimationList
    local del = {}
    local target = role
    local play = role.playerView

    for i, data in pairs(list) do 
        if time > data.endTime then
            table.insert(del, i)
        elseif time >= data.startTime then
            local layer = FightDataMgr:getLayerBlackEffect()
            if 0 == data.attr then
                FightTextMgr:useTextIpsg(data, layer)
            elseif 1 == data.attr then
                FightTextMgr:useTextSkill(data, layer)
            elseif 2 == data.attr then
                FightTextMgr:useTextBuff(data, layer)
            elseif 3 == data.attr then
                FightTextMgr:useTextIpsgFail(data, layer)
            elseif 4 == data.attr then
                FightTextMgr:useTextOdd(data, layer)
            else
                FightTextMgr:useText(data, layer)
            end

            if data.role then
                targetRole = data.role
                play = targetRole.playerView
            end

            if not data.text then
                table.remove(del, i)
            else
                if not data.p then
                    if 4 ~= data.attr then
                        data.p = cc.p(play:getPositionX(), play:getPositionY() + targetRole.body.footY - targetRole.body.headY + 75)
                    else
                        data.p = cc.p(play:getPositionX(), play:getPositionY() + targetRole.body.footY - targetRole.body.headY)
                    end

                    if data.p.x < 0 then
                        data.p.x = 0
                    end
                    if data.p.x + data.text.size.width > visibleSize.width then
                        data.p.x = visibleSize.width - data.text.size.width
                    end
                end

                data.text:idle(time, data, data.p, targetRole)
            end
        end
    end

    for i = #del, 1, -1 do
        local data = list[del[i]]
        table.remove(list, del[i])
        FightTextMgr:unText(data)
    end
end

--音效
function __this:runSound(time, role)
    local list = role.soundAnimationList
    local del = {}
    
    for i, data in pairs(list) do
        if time >= data.startTime then
            table.insert(del, i)
        end
    end
    
    for i = #del, 1, -1 do
        local data = list[del[i]]
        table.remove(list, del[i])
        
        --播放音效接口
        local url = "sound/" .. data.sound .. ".mp3"
        SoundMgr.playEffect(url, false, FightDataMgr.speed)
    end
end

--图腾值更新
function __this:runTotemValue(time, role)
    local list = role.totemValueAnimationList
    local del = {}

    for i, data in pairs(list) do
        if time > data.endTime then
            table.insert(del, i)
        end
    end

    local flag = false
    for i = #del, 1, -1 do
        if not flag then
            FightDataMgr.theFightUI:setTotemValue(role, list[del[i]].value)
            flag = true
        end
        table.remove(list, del[i])
    end
end

function __this:runOthers(time)
    local list = self.othersAnimationList
    local del = {}

    for i, data in pairs(list) do
        if time > data.endTime then
            table.insert(del, i)
        elseif time > data.startTime then
             FightDataMgr.theFightUI.totemUI:setTotemTextVisible(data.role, true)
        end
    end

    for i = #del, 1, -1 do
        local data = table.remove(list, del[i])
        FightDataMgr.theFightUI.totemUI:setTotemTextVisible(data.role, false)
    end
end

function __this:releaseAll()
    self.totemAnimationList = {}
    self.othersAnimationList = {}
    self.autoTime = nil
    self.flagTotem = nil
    self.dearTime = 0
end

function __this:runAnythings(time, role, infoVisible)
    local mirror = role:getMirror(time)
    
    self:runScale(time, role)
    self:runAnimation(time, role, mirror, infoVisible)
	self:runEffect(time, role, mirror)
	self:runBodyEffect(time, role, mirror)
	self:runNumber(time, role)
    self:runRage(time, role)
    self:runSkill(time, role)
    self:runSound(time, role)
    self:runTotemValue(time, role)
end

--加血特效处理
function __this:addHpEffect(role, actionEffect, orderTarget, time)
    if const.kFightAddHP ~= orderTarget.fight_result then
        return
    end
    
    local animationFilter = FightData.newAnimation()
    animationFilter.attr = "white"
    animationFilter.startTime = time
    animationFilter.endTime = time + 500
    table.insert(role.filtersAnimationList, animationFilter)
end

--图腾满怒触发相关效果
function __this:parseTotemPower(role, time, enable)
	if enable then
		local action = role.body:getActionByFlag("faguang")
		if not action then
			return
		end
		
		--创建动作动画事件
		local animationRole = FightData:createActionAnimation( action, time )
		animationRole.endTime = 0
		role:filterAction(animationRole)
		
		--添加图腾身上特效事件[代码范例]
		if role.totem.ready_animation then
			local list = string.split(role.totem.ready_animation, '%')
			if 2 == #list then
				local effect = FightFileMgr:getEffect(list[1])
				if effect then
					local oddSet = {set_type = trans.const.kObjectAdd}
					local odd = {id = list[1], buffeffect = list[1]}
                    local animation = nil
                    if #list > 1 then
                        animation = FightData:createBodyAnimation( time, oddSet, odd, effect, role, list[2] )
                    else
                        animation = FightData:createBodyAnimation( time, oddSet, odd, effect, role )
                    end
					animation.role = role
                    animation.endTime = 0
					role:filterBodyEffectAdd(animation)
				end
			end
		end

        --激活特效
        local effect = FightFileMgr:getEffect(FightAnimationMgr.const.TOTEM_READY)
        if effect then
            local effectItem = effect:getEffectNormal()
            if effectItem then
                local oddSet = {set_type = trans.const.kObjectAdd}
                local odd = {id = FightAnimationMgr.const.TOTEM_READY, onceeffect = FightAnimationMgr.const.TOTEM_READY}
                local animation = FightData:createBodyAnimation(time, oddSet, odd, effect, role)
                animation.role = role
                animation.endTime = animation.startTime + effectItem.count * 25
                role:filterBodyEffectAdd(animation)
            end
        end
		return
	end

	--删除图腾动作事件
	for __, animation in pairs(role.actionAnimationList) do
		if 0 == animation.endTime then
			animation.endTime = time
		end
	end
	
	--删除图腾身上特效事件[代码范例]
	if role.totem.ready_animation then
		local list = string.split(role.totem.ready_animation, '%')
		if 2 == #list then
			local oddSet = {set_type = trans.const.kObjectDel}
			local odd = {id = list[1], buffeffect = list[1]}
			local effect = FightFileMgr:getEffect(odd.id)
			if effect then
				local animation = FightData:createBodyAnimation( time, oddSet, odd, effect, role )
				role:filterBodyEffectAdd(animation)
			end
		end
	end
end

--身上特效处理
function __this:setBodyEffect(role, oddSet, odd, time, target)
    --单次特效
    local list = string.split(odd.onceeffect, '%')
    if #list >= 1 then
        local effect = FightFileMgr:getEffect(list[1])
        if effect then
            local newOdd = {id = odd.id, level = odd.level, onceeffect = list[1]}
            local animation = nil
            if #list > 1 then
                animation = FightData:createBodyAnimation( time, oddSet, newOdd, effect, target or role, list[2] )
            else
                animation = FightData:createBodyAnimation( time, oddSet, newOdd, effect, target or role )
            end
            animation.role = target or role
            return role:filterBodyEffectAdd(animation)
        end
    end

    --循环特效
    list = string.split(odd.buffeffect, '%')
    if #list >= 1 then
        local effect = FightFileMgr:getEffect(list[1])
        if effect then
            local newOdd = {id = odd.id, level = odd.level, buffeffect = list[1]}
            local animation = nil
            if #list > 1 then
                animation = FightData:createBodyAnimation( time, oddSet, newOdd, effect, target or role, list[2] )
            else
                animation = FightData:createBodyAnimation( time, oddSet, newOdd, effect, target or role )
            end
            animation.role = target or role
            animation.endTime = 0
            return role:filterBodyEffectBuff(animation)
        end
    end

    return time
end

--清除身上的特效
function __this:clearEffect( role, time )
    local oddSet = 
    {
        guid = role.guid,
        odd_set_type = const.kObjectDel
    }
    local odd = 
    {
        onceeffect = FightAnimationMgr.const.BUFF_CLEAR,
        buffeffect = FightAnimationMgr.const.BUFF_CLEAR,
        effect = 
        {
            id = -1
        }
    }
    
    table.insert( role.oddAnimationList, FightData:createOddAnimation( oddSet, odd, role:getLastOddEndTime( time ), 0 ) )
    self:setBodyEffect(role,oddSet,odd,time)
end

--怒气特效处理
function __this:rageEffect( role, fightSoldier, animation, time )
end

--只有攻击动作、施放方身上特效数据处理
function __this:setAck( role, action, actionEffect, skill, startTime )
    local obj = self.newObject(startTime)
	
    startTime = FightFileMgr:getTime( actionEffect, "TIME_ACK_ACTION", startTime )
	obj.ackTime = startTime

    --喊招事件[技能]
    if skill then
        local skillAnimation = FightData:createSkillName(role, tonumber(obj.ackTime) + 500, 1, skill)
        role.deferAnimation(role.skillAnimationList, skillAnimation, 50)
    end

    --固定特效
    local fix = 0
    local effect = FightFileMgr:getEffect(FightAnimationMgr.const.TOTEM_READY)
    if effect then
        local oddSet = {set_type = const.kObjectAdd}
        local odd = {id = FightAnimationMgr.const.TOTEM_READY, onceeffect = FightAnimationMgr.const.TOTEM_READY}
        local animation = FightData:createBodyAnimation(tonumber(obj.ackTime) + 500, oddSet, odd, effect, role)
        animation.role = role
        role:filterBodyEffectAdd(animation)

        fix = animation.endTime - animation.endTime
    end

    --创建动作动画事件
    local animation = FightData:createActionAnimation( action, tonumber(obj.ackTime) + 500 + fix )
	animation.role = role
	table.insert(role.actionAnimationList, animation)
    obj.endTime = animation.endTime

    --放大
    local scaleAnimation = FightData.newAnimation()
    scaleAnimation.startTime = obj.ackTime + 500 + fix
    scaleAnimation.endTime = tonumber(animation.endTime) + 250
    scaleAnimation.scale = 2.1
    table.insert(role.scaleAnimationList, scaleAnimation)
    
    --以时间轴换算特效触发时间
    obj.effectTime = FightFileMgr:getTime( actionEffect, "TIME_ACK_EFFECT", startTime )
    if actionEffect and "" ~= actionEffect.ackEffect then
		--创建施放方身上特效动画事件
		local effectAnimation, bindingAnimation = FightData:createEffectAnimation(actionEffect, obj.effectTime, actionEffect.ackEffect, role, true)
		effectAnimation.role = role
		table.insert(role.effectAnimationList,effectAnimation)
		obj.endTime = math.max(obj.endTime, effectAnimation.endTime)

        if bindingAnimation then
            table.insert(role.effectAnimationList, bindingAnimation)
        end
    end
    
	if role.sound then
		--施放方音效
		FightData:createSound(role, obj.effectTime, role.sound:getActionByFlag(action.flag, actionEffect.index, FightFileMgr.sound_enum.ACK));
	end

    --喊招音效
    if role.sound then
        local es = role.sound:getActionByFlag(action.flag, actionEffect.index, FightFileMgr.sound_enum.ACK)
        local soundAnimation = FightData:createSound(role, obj.effectTime, role.sound:getActionByFlag(action.flag, actionEffect.index, FightFileMgr.sound_enum.ACTION) );
        if soundAnimation and es then
            soundAnimation.startTime = obj.ackTime + es.time
            soundAnimation.endTime = soundAnimation.startTime
        end
    end
	
    return obj
end

--解释施放方的逻辑、表现   [目标特效、辅助特效不在此函数处理]
function __this:parseAckRole( role, action, actionEffect, startTime, skill, confusion )
    local objAck = self.newObject(startTime)
    
    local time = startTime
    
    --攻击动作、特效数据处理
    local obj = __this:setAck(role,action,actionEffect,skill,startTime)
    obj.startTime = objAck.startTime
    
    --记录近身移动结束时间点
    obj.pathTime = startTime
    
    return obj
end

--解释受击方的逻辑、表现   [受击特效不在此函数处理]
function __this:parseTargetRole( role, actionEffect, targetRole, orderTarget, ackTime, mightMax, skill, talkFlag, lockFlag, dodeflag )
	--时间轴受击起始索引
	local indexTimeShaft = FightFileMgr:getMight(actionEffect, orderTarget.fight_might)
	if 0 == orderTarget.fight_might then
		indexTimeShaft = FightFileMgr:getMight(actionEffect, mightMax)
	else
        local opacityAnimation = FightData.newAnimation()
        opacityAnimation.startTime = ackTime
        opacityAnimation.endTime = ackTime
        opacityAnimation.opacity = 255
        table.insert(targetRole.opacityAnimationList, opacityAnimation)
    end
	
    local time = actionEffect.timeShaftDataList[indexTimeShaft + 2] + ackTime
    local obj = self.newObject(time)
    
    --当前参战人员于服务器的数据
    local fightSoldier = FightDataMgr.theFight:findSoldier( orderTarget.guid )
    if not fightSoldier then
        return obj
    end
    --如果生命值已经为0并且为扣除的情况下，不做任何处理
    --if 0 == fightSoldier.hp and const.kFightDicHP == orderTarget.fight_result then
    --    return obj
    --end
	
    local hurtHp = 0
    --受击数字动画
    if 0 ~= orderTarget.fight_result then
        local animation = FightData:createSubValueAnimation(orderTarget, time)
		animation.role = targetRole
        if
            0 == orderTarget.fight_value 
            and const.kFightAddHP ~= orderTarget.fight_result 
            and const.kFightDodge ~= orderTarget.fight_type
            and (targetRole:checkOdd(const.kFightOddInvincible) or targetRole:checkOdd(const.kFightOddDef) or targetRole:checkOdd(const.kFightOddDefFixed)) 
		then --完全吸收表现处理
            animation.fight_value = 0
        
        elseif 0 ~= orderTarget.fight_value then
            hurtHp = orderTarget.fight_value
            if const.kFightDicHP == orderTarget.fight_result then
                hurtHp = hurtHp * -1
            end
            
            self:addHpEffect(targetRole, actionEffect, orderTarget, animation.startTime)
            targetRole:setHp(hurtHp)
        end

        table.insert(role.hpAnimationList, animation)
    end

    if not targetRole:checkAttr(const.kAttrTotem) then
        local animationRage = FightData:createSubValueAnimation(orderTarget, targetRole:updateHurtTime(time))
        animationRage.rage = orderTarget.rage
        animationRage.role = targetRole
        table.insert(role.rageAnimationList, animationRage)
    end

    --图腾值更新
    if FightAnimationMgr.camp == targetRole.camp then
        local rageAnimation = FightData.newAnimation()
        rageAnimation.startTime = time
        rageAnimation.endTime = time
        rageAnimation.value = orderTarget.totem_value
        table.insert(targetRole.totemValueAnimationList, rageAnimation)
    end

    --觉醒失败
    if trans.const.kFightAttrNoDisillusion == orderTarget.fight_attr then
        local skillAnimation = FightData:createSkillName(targetRole, time, 3)
        table.insert(role.skillAnimationList, skillAnimation)
        return obj
    elseif const.kFightAttrRebound == orderTarget.fight_attr then
        local skillAnimation = FightData:createSkillName(targetRole, time, 7)
        table.insert(role.skillAnimationList, skillAnimation)
        return obj
    end

    --增加图腾值显示
    if trans.const.kFightAttrTotemValueShow == orderTarget.fight_attr then
        return obj
    end

    --异常处理
    for __, oddSet in pairs( orderTarget.odd_list ) do
        if 0 ~= oddSet.fightOdd.id then
            local odd = findOdd(oddSet.fightOdd.id, oddSet.fightOdd.level)
            if nil ~= odd then
                local target = FightRoleMgr:getRole(oddSet.guid)
                if target then
                    --喊招事件[Buff]
                    local skillAnimation = FightData:createSkillName(target, time, 2, nil, odd, oddSet.fightOdd)
                    table.insert(role.skillAnimationList, skillAnimation)
                    local srcTime = math.floor(FightDataMgr.runTime * 1000)

                    if target:checkAttr(const.kAttrTotem) then
                        -- local oddTime = role:getLastOddEndTime( time )
                        table.insert(target.oddAnimationList, FightData:createOddAnimation(oddSet, odd, time))
                        if 2 == odd.buff_only then
                            --查找对方阵营任一非图腾对象作事件媒介
                            local team = nil
                            if target:isMirror() then
                                team = FightRoleMgr:getLeft()
                            else
                                team = FightRoleMgr:getRight()
                            end
                            for __, o in pairs(team) do
                                if o.fightSoldier and not o:checkAttr(const.kAttrTotem) then
                                    self:setBodyEffect(o, oddSet, odd, math.floor(FightDataMgr.runTime * 1000))
                                    break
                                end
                            end
                        else
                            self:setBodyEffect(target, oddSet, odd, time)
                        end
                    else
                        -- local srcTime = actionEffect.timeShaftDataList[indexTimeShaft + 2] + math.floor(FightDataMgr.runTime * 1000)
                        if self.disillusion ~= odd.status.cate then
                            table.insert(target.oddAnimationList, FightData:createOddAnimation(oddSet, odd, srcTime))
                            if 2 == odd.buff_only then
                                --查找对方阵营任一非图腾对象作事件媒介
                                local team = nil
                                if target:isMirror() then
                                    team = FightRoleMgr:getLeft()
                                else
                                    team = FightRoleMgr:getRight()
                                end
                                for __, o in pairs(team) do
                                    if o.fightSoldier and not o:checkAttr(const.kAttrTotem) then
                                        self:setBodyEffect(o, oddSet, odd, srcTime)
                                        break
                                    end
                                end
                            else
                                self:setBodyEffect(target, oddSet, odd, srcTime)
                            end
                        end

                        --觉醒特殊处理
                        if self.totemDisillList[role.totem.id] then
                            if self.disillusion == odd.status.cate then
                                local skillAnimation = FightData:createSkillName(target, time, 0)
                                table.insert(role.skillAnimationList, skillAnimation)
                            end
                        end
                    end
                    
                    if self.sheep == odd.status.cate then
                        if const.kObjectAdd == oddSet.set_type then
                            FightData:createChangeModelAnimation(srcTime, target, "XG20yang")
                            self:setBodyEffect(target, oddSet, {id=FightAnimationMgr.const.WITCHCRAFT, level=1, onceeffect=FightAnimationMgr.const.WITCHCRAFT}, time)
                        else
                            FightData:createChangeModelAnimation(srcTime, target, target.body.style)
                        end

                    elseif self.frog == odd.status.cate then
                        if const.kObjectAdd == oddSet.set_type then
                            FightData:createChangeModelAnimation(srcTime, target, "XG21qingwa")
                            self:setBodyEffect(target, oddSet, {id=FightAnimationMgr.const.WITCHCRAFT, level=1, onceeffect=FightAnimationMgr.const.WITCHCRAFT}, time)
                        else
                            FightData:createChangeModelAnimation(srcTime, target, target.body.style)
                        end

                    -- elseif self.hurricane == odd.status.cate then
                    --     local opacityAnimation = FightData.newAnimation()
                    --     opacityAnimation.startTime = srcTime
                    --     opacityAnimation.endTime = srcTime + 255
                    --     opacityAnimation.odd = odd
                    --     if const.kObjectAdd == oddSet.set_type then
                    --         opacityAnimation.opacity = 0
                    --     else
                    --         opacityAnimation.opacity = 255
                    --     end

                    --     table.insert(target.opacityAnimationList, opacityAnimation)

                    elseif self.petrifaction == odd.status.cate then
                        target:filterPetrifaction(oddSet, "gray", srcTime + 10, 0)
                        target:filterPause(oddSet, srcTime + 10)

                    --嘲讽
                    elseif self.taunt == odd.status.cate then
                        local animationTaunt = FightData.newAnimation()
                        animationTaunt.startTime = srcTime
                        animationTaunt.endTime = srcTime
                        if const.kObjectAdd == oddSet.set_type then
                            animationTaunt.type = 1
                        else
                            animationTaunt.type = 2
                        end
                        table.insert(target.othersAnimationList, animationTaunt)
                    end

                    if const.kObjectAdd == oddSet.set_type then
                        if self.oddList[odd.id] and "parseFightSkillObject" == target.state then
                            -- for __, data in pairs(target.effectAnimationList) do
                            --     data.endTime = srcTime - 1
                            -- end
                            self.parseBreak(target, srcTime)
                            for __, data in pairs(target.pathAnimationList) do
                                data.endTime = srcTime - 1
                            end

                            --石化状态归位
                            if 
                                self.petrifaction == oddSet.fightOdd.status_id
                                and (target.playerView:getPositionX() ~= target.station:x() or target.playerView:getPositionY() ~= target.station:y())
                            then
                                local pathData = FightData:setPath(srcTime, 
                                    cc.p(target.playerView:getPositionX(), target.playerView:getPositionY()),
                                    target.station:pos(), target:isMirror(), true)
                                table.insert(target.pathAnimationList, pathData)
                            end
                        end

                        --战斗过程中武将被动技能[不处理受击]
                        FightAnimationMgr:parseFightingPassive(time, target, oddSet, odd)
                    end
                end
            end
        end
    end

    --触发源
    for __, s2 in pairs(orderTarget.odd_list_triggered) do
        local odd = findOdd(s2.odd_id, 1)
        if odd and '' ~= odd.buffeffectname then
            --喊招事件[Buff]
            local target = FightRoleMgr:getRole(s2.use_guid)
            if target then
                --喊招事件[Buff]
                local skillAnimation = FightData:createSkillName(target, time, 2, nil, odd)
                skillAnimation.val = "buffeffectname"
                table.insert(role.skillAnimationList, skillAnimation)

                if FightTotemMgr.windfury == odd.status.cate then
                    self:setBodyEffect(target, 
                        {guid=target.guid, set_type=const.kObjectAdd, fightOdd={}}, 
                        odd, 
                        math.floor(FightDataMgr.runTime * 1000))
                end
            end
        end
    end
    
    --施放方处理怒气
    if role == targetRole and 0 == orderTarget.fight_attr and 0 == orderTarget.fight_result then
        return obj
    end
    
    --死亡动作
    obj.dearTime = self:parseDear(fightSoldier, targetRole, math.floor(FightDataMgr.runTime * 1000))
    return obj
end

--处理打断释放特效
function __this.parseBreak(role, time)
    if FightDataMgr.last_role_guid ~= role.guid or "parseFightSkillObject" ~= role.state then
        return
    end

    local list = FightRoleMgr:getAllSoldier()
    for __, target in pairs(list) do
        for __, data in pairs(target.effectAnimationList) do
            data.endTime = time - 1
        end
    end
end

--死亡相关处理[图腾不存在死亡]
function __this:parseDear(soldier, role, time)
    if role:checkAttr(trans.const.kAttrTotem) or (0 ~= soldier.hp and not FightDataMgr.load_fight_log) or role.hp > 0 or 0xfffff0 ~= role.dearTime then
        return time
    end

    --强制修改当前处理死亡的时间
    local sTime = math.floor(FightDataMgr.runTime * 1000)
    self.parseBreak(role, sTime)

    --变身后的死亡需要恢复原状
    FightData:createChangeModelAnimation(sTime, role, role.body.style)
    
    role.opacityAnimationList = {}
    local opacityAnimation = FightData.newAnimation()
    opacityAnimation.startTime = sTime
    opacityAnimation.endTime = sTime
    opacityAnimation.opacity = 255
    table.insert(role.opacityAnimationList, opacityAnimation)

    local del = {}
    for i, data in pairs(role.actionAnimationList) do
        if "dead" == data.type then
            table.insert(del, i)
        end
    end
    if #del > 0 then
        for i = #del, 1, -1 do
            table.remove(role.actionAnimationList, i)
        end
    end

    --检测死亡之前需要回到原位死亡
    -- if #role.pathAnimationList > 0 then
    --     local data = role.pathAnimationList[#role.pathAnimationList]
    --     if sTime <= data.startTime then
    --         if data.endPT 
    --             and (data.endPT.x ~= role.station:x() or data.endPT.y ~= role.station:y())
    --         then
    --             local pathData = FightData:setPath(sTime, data.endPT, role.station:pos(), role:isMirror(), true)
    --             table.insert(role.pathAnimationList, pathData)
    --             sTime = pathData.endTime
    --         end
    --     end
    -- end
    
    -- sTime = role:getLastActionEndTime( sTime )
    --死亡音效
    if role.sound then
        FightData:createSound(role, sTime, role.sound:getOtherSound(FightFileMgr.sound_enum.DEAD));
    end

    for __, data in pairs(role.actionAnimationList) do
        data.endTime = sTime - 100
    end

    --死亡动作
    local animation = FightData:createActionAnimation( role.body:getActionByFlag( "dead" ), sTime )
    role:filterAction(animation)
    role.dearTime = animation.endTime
    role.dearActionStartTime = animation.startTime
    
    --移除暂停状态
    local oddSet = {guid=role.guid, set_type=const.kObjectDel, fightOdd={}}
    role:filterPause(oddSet, animation.startTime)
    role:filterPetrifaction(oddSet, "gray", animation.startTime, animation.startTime)
       
    --在些移除满怒气特效
    self:clearEffect( role, sTime )

    --释放相关特效
    animation = FightData.newAnimation()
    animation.startTime = role.dearTime + 1000
    animation.endTime = animation.startTime
    table.insert(role.releaseAnimationList, animation)

    --掉落物品动画事件
    if FightAnimationMgr.camp ~= role.camp and FightAnimationMgr.monsterCount > 0 then
        local coins = FightAnimationMgr:getCoin(role)
        if coins then
            for i, coin in pairs(coins) do
                local _time = sTime + (i - 1) * 100
                if const.kCoinItem == coin.cate and coin.val > 1 then
                    for j = 1, coin.val, 1 do
                        _time = time + (j - 1) * 100
                        local animation = FightData:createItemRewardFloor1(role, _time, -0.008, (j - 1) * math.random(10, 20), {cate = const.kCoinItem, objid = coin.objid, val = 1})
                        FightDataMgr:rewardPush(animation)
                        FightDataMgr:rewardPush(FightData:createItemRewardFloor2(role, animation.endTime + 100, -0.003, animation.offset, animation.itemView))
                    end
                else
                    local animation = FightData:createItemRewardFloor1(role, _time, -0.008, (i - 1) * math.random(10, 20), coin)
                    FightDataMgr:rewardPush(animation)
                    FightDataMgr:rewardPush(FightData:createItemRewardFloor2(role, animation.endTime + 100, -0.003, animation.offset, animation.itemView))
                end    
            end
        end
    end

    --如果此时战斗可以结束，则修正结束时间
    -- if FightDataMgr:checkEnd() then
    --     for __, data in pairs(FightDataMgr.listState) do
    --         if data.endTime < role.dearTime then
    --             data.startTime = role.dearTime
    --             data.endTime = role.dearTime
    --         end
    --     end
    -- end

    self.dearTime = math.max(self.dearTime, role.dearTime)
    return role.dearTime
end

--全体技能特效处理
function __this:parseEffectColony(ackRole, action, actionEffect, time, skill)
    local obj = self.newObject(time)
    local targetRole = nil
    if 1 == skill.target_type then
        targetRole = FightRoleMgr:getByIndex(not ackRole:isMirror(), 5)
    else
        targetRole = FightRoleMgr:getByIndex(not ackRole:isMirror(), 5)
    end
    
    if not targetRole or not actionEffect then
        return obj
    end
    
    if "" ~= actionEffect.fireEffect and not FightFileMgr.checkSame(actionEffect.fireEffect) then
        local animation = FightData:createEffectAnimation(actionEffect, FightFileMgr:getTime(actionEffect, "TIME_FIRE_EFFECT", time), actionEffect.fireEffect)
        animation.endTime = animation.startTime + 230
        table.insert(ackRole.effectAnimationList, animation)
        obj.endTime = math.max(obj.endTime, animation.endTime)
    end
    
    if "" ~= actionEffect.targetEffect and not FightFileMgr.checkSame(actionEffect.targetEffect) then
        local timeEffect = FightFileMgr:getTime(actionEffect, "TIME_HURT_EFFECT", time)
        local animation = FightData:createTargetEffectAnimation(actionEffect, timeEffect, actionEffect.targetEffect)
        animation.proxyFightRole = targetRole
        animation.coord = cc.p(targetRole.station:x(), targetRole.station:y())
        table.insert(ackRole.colonyAnimationList, animation)
        obj.endTime = math.max(obj.endTime, animation.endTime)

        --音效
        if ackRole.sound then
            --目标方音效
            FightData:createSound(ackRole, timeEffect, ackRole.sound:getActionByFlag(skill.action_flag, skill.effect_index, FightFileMgr.sound_enum.TARGET));
        end
    end
    
    return obj
end

--解释辅助特效、受击特效
function __this:parseEffect(ackRole, action, actionEffect, log, time, skill, mightMax, confusion)
    local obj = self.newObject(time)
    
    --图腾不使用全体受击特效处理
    -- if 6 == skill.target_range_count and 2 == skill.target_range_cond then
    --     return self:parseEffectColony(ackRole, action, actionEffect, time, skill)
    -- end

    for __, orderTarget in pairs(log.orderTargetList) do
        if --[[0 ~= orderTarget.fight_result and]] log.order.guid ~= orderTarget.guid then
            local targetRole = FightRoleMgr:getRole(orderTarget.guid)
            if targetRole then
                if 1 == skill.target_type and ackRole:isMirror() == targetRole:isMirror() and 0 == confusion then
                    --continue
                else
                    local interval = FightAnimationMgr.parseInterval(skill, log.order.guid, orderTarget.guid, {})
                    local indexTimeShaft = FightFileMgr:getMight(actionEffect, orderTarget.fight_might)
                    local animationFrie = FightData:parseFire(time, ackRole, targetRole,
                        action, actionEffect, interval, indexTimeShaft)

                    --受伤特效处理
                    if '' == actionEffect.targetEffect or FightFileMgr.checkSame(actionEffect.targetEffect) then
                        obj.endTime = actionEffect.timeShaftDataList[4] + time
                    else
                        local timeEffect = actionEffect.timeShaftDataList[4] + time
                        local animation = FightData:createTargetEffectAnimation(actionEffect, timeEffect, actionEffect.targetEffect, targetRole)
                        animation.role = targetRole
                        table.insert(ackRole.effectAnimationList, animation)

                        obj.endTime = math.max(obj.endTime, animation.endTime)

                        --音效
                        if ackRole.sound then
                            --目标方音效
                            FightData:createSound(ackRole, timeEffect, ackRole.sound:getActionByFlag(skill.action_flag, skill.effect_index, FightFileMgr.sound_enum.TARGET));
                        end
                    end
                end
            end
        else
            for __, oddSet in pairs(orderTarget.odd_list) do
                if oddSet.guid ~= log.order.guid then
                    local odd = findOdd(oddSet.fightOdd.id, oddSet.fightOdd.level)
                    if odd then
                        if self.totemDisillList[ackRole.totem.id] and self.disillusion == odd.status.cate then
                            local targetRole = FightRoleMgr:getRole(oddSet.guid)
                            if targetRole then
                                if '' == actionEffect.targetEffect or FightFileMgr.checkSame(actionEffect.targetEffect) then
                                    obj.endTime = actionEffect.timeShaftDataList[4] + time
                                else
                                    local timeEffect = actionEffect.timeShaftDataList[4] + time
                                    local animation = FightData:createTargetEffectAnimation(actionEffect, timeEffect, actionEffect.targetEffect, targetRole)
                                    animation.role = targetRole
                                    table.insert(ackRole.effectAnimationList, animation)

                                    obj.endTime = math.max(obj.endTime, animation.endTime)
                                    --音效
                                    if ackRole.sound then
                                        --目标方音效
                                        FightData:createSound(ackRole, timeEffect, ackRole.sound:getActionByFlag(skill.action_flag, skill.effect_index, FightFileMgr.sound_enum.TARGET));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return obj
end

--觉醒特殊处理
function __this:parseDisillusion(time, role, log, skill)
    local newTime = time
    if not role:checkAttr(const.kAttrTotem) or self.totemDisillList[role.totem.id] then
        return newTime
    end

    local soundFlag = false
    for __, orderTarget in pairs(log.orderTargetList) do
        for __, oddSet in pairs(orderTarget.odd_list) do
            if const.kObjectAdd == oddSet.set_type then
                local odd = findOdd(oddSet.fightOdd.id, oddSet.fightOdd.level)
                if odd and self.disillusion == odd.status.cate then
                    local target = FightRoleMgr:getRole(oddSet.guid)
                    if target then
                        table.insert(target.oddAnimationList, FightData:createOddAnimation(oddSet, odd, time))
                        newTime = math.max(newTime, self:setBodyEffect(role, oddSet, odd, time, target))

                        --音效
                        if not soundFlag and '' ~= odd.onceeffect then
                            --目标方音效
                            FightData:createSound(role, time, {attr=1, time=0, sound="TT-feng03"});
                            soundFlag = true
                        end

                        local skillAnimation = FightData:createSkillName(target, time, 0)
                        table.insert(role.skillAnimationList, skillAnimation)
                    end
                end
            end
        end
    end

    return newTime
end

--获取受击次数最大值
function __this.getMightMax(log)
	local count = 0
	for __, orderTarget in pairs(log.orderTargetList) do
		if 0 ~= orderTarget.fight_might and count < orderTarget.fight_might then
			count = orderTarget.fight_might
		end
	end
	
	return count
end

--根据技能击打目标获取数量
function __this.getSkillTargetCount(role, skill, log)
    local count = 0
    local mirror = role:isMirror()
    if 1 == skill.target_type then
        mirror = not mirror
    end
    for __, orderTarget in pairs(log.orderTargetList) do
        if role.guid ~= orderTarget.guid then
            local target = FightRoleMgr:getRole(orderTarget.guid)
            if target and mirror == target:isMirror() then
                count = count + 1
            end
        else
            for __, oddSet in pairs(orderTarget.odd_list) do
                local target = FightRoleMgr:getRole(oddSet.guid)
                if target and mirror == target:isMirror() then
                    count = count + 1
                end
            end
        end
    end

    return count
end

--完整处理
function __this:parseLog(time, log)
    local obj = self.newObject( time )
    
    local soldier = FightDataMgr.theFight:findSoldier(log.order.guid)
    if not soldier then
        LogMgr.log( 'debug', "%s", "parseLog:findSoldier not" .. log.order.guid )
        return obj.endTime
    end
    
    local role = FightRoleMgr:getRole( log.order.guid )
    if nil == role then
		LogMgr.log( 'debug', "%s", "parseLog:getRole not" .. log.order.guid )
        return obj.endTime
    end 
    
    local skill = findSkill( log.order.order_id, log.order.order_level )
    if nil == skill then
		LogMgr.log( 'debug', "%s", "parseLog:findSkill not" .. log.order.order_id, log.order.order_level )
        return obj.endTime
    end

    local action = role.body:getActionByFlag( skill.action_flag )
    if nil == action then
		LogMgr.log( 'debug', "%s", "parseLog:getActionByFlag not" .. skill.action_flag )
        return obj.endTime
    end
    
    local actionEffect = FightFileMgr:getActionEffect( action, skill.effect_index )
    if nil == actionEffect then
		LogMgr.log( 'debug', "%s", "parseLog getActionEffect not" .. skill.effect_index )
        return obj.endTime
    end

    --图腾值更新
    -- FightAnimationMgr:parseTotemValue(log, math.floor(FightDataMgr.runTime * 1000) + 10)
    
    local objHurt = self.newObject( time )
    local objAck = self:parseAckRole(role,action,actionEffect,time,skill,0)
    
    local newLog = FightAnimationMgr.getLogByAttr(
        log, 
        0, 
        const.kFightAttrConfusion, 
        const.kFightAttrNoDisillusion,
        const.kFightAttrRebound
    )
    local mightMax = self.getMightMax(newLog)
	local currentMight = 1
    for __, orderTarget in pairs( newLog.orderTargetList ) do
        local targetRole = FightRoleMgr:getRole( orderTarget.guid )
        if nil ~= targetRole then
            -- if 0 ~= orderTarget.fight_result and 1 == skill.target_type and FightRoleMgr:checkBombByLog( newLog ) and role:isMirror() == targetRole:isMirror() then
				--do something
			-- else
				if 0 ~= orderTarget.fight_might then
					currentMight = orderTarget.fight_might
				end
                objHurt = self:parseTargetRole(role, actionEffect, targetRole, orderTarget, objAck.ackTime, currentMight, skill, false, false, true)
            -- end
        end
    end
    
    local objEffect = self:parseEffect(role,action,actionEffect,newLog,objAck.ackTime, skill, mightMax, 0)
    
    --根据技能击打目标获取数量
    if 0 == self.getSkillTargetCount(role, skill, log) then
        local other = FightData.newAnimation()
        other.startTime = objAck.ackTime
        other.endTime = objAck.ackTime + 2000
        other.attr = 1
        other.role = role
        table.insert(self.othersAnimationList, other)
    end

    --觉醒特殊处理
    time = self:parseDisillusion(objEffect.endTime, role, log, skill)

    --解释击杀对方时增加的图腾值
    FightAnimationMgr:parseKillTarget(objAck.endTime, role, log)

    local fixTime = math.max( objAck.endTime, objHurt.endTime, time)--, objEffect.endTime - 100 )
    local objTalent = self.newObject(fixTime)
    
    return objTalent.endTime
end

--处理图腾 [list:如果有值，意味着处理的是 "玩家 Vs 玩家"]
function __this:parseTotem(time, role, list, unCheck)
	local startTime = time
	local obj = self.newObject(time)
	local soldier = FightDataMgr.theFight:findSoldier(role.guid)
	
	if not soldier or (not unCheck and not role:isMirror() and role.totemCool > 0 and not FightDataMgr.load_fight_log) then
        return obj.endTime
    end

    local round = 0
	if not list then
        list = FightDataMgr.theFight:useTotemSkill(soldier)
    end
    if not list or 0 == #list then
        return obj.endTime
    end

    --log记录
    if FightDataMgr.save_fight_log then
        table.insert(FightDataMgr.clientLog.totem_skill_list, SFightClientRoundData:new(math.floor(FightDataMgr.runTime * 1000), math.floor(FightDataMgr.totemTime * 1000), list))
    end

    for __, log in pairs(list) do
    	obj.endTime = math.max(obj.endTime, self:parseLog(obj.endTime, log))
        round = log.round

        --清空已有图腾值事件，因为图腾时间轴优先级高于英雄时间轴
        for __, orderTarget in pairs(log.orderTargetList) do
            local target = FightRoleMgr:getRole(orderTarget.guid)
            if target then
                local roleList = nil
                if not target:isMirror() then
                    roleList = FightRoleMgr:getLeft()
                else
                    roleList = FightRoleMgr:getRight()
                end
                for __, tt in pairs(roleList) do
                    tt.totemValueAnimationList = {}
                end
            end
        end
	end

    --图腾值更新 [恢复由服务器端更新  2014.11.21]
    if role.camp == FightAnimationMgr.camp then
        local rageAnimation = FightData.newAnimation()
        rageAnimation.startTime = time
        rageAnimation.endTime = time
        rageAnimation.value = FightAnimationMgr.leftTotemValue - role.skill.self_costtotem
        table.insert(role.totemValueAnimationList, rageAnimation)
    end

    --创建图腾放技能事件
	local animation = FightData.newAnimation()
	animation.startTime = startTime
	animation.endTime = obj.endTime
    animation.role = role
	table.insert(self.totemAnimationList, animation)
	
    animation.log = list
    animation.disillusion = 0
    --记录图腾技能受击相关角色
	animation.list = {}
    --记录觉醒相关角色
    animation.disillusionList = {}
    for __, log in pairs(list) do
        animation.order = log.order

    	for __, orderTarget in pairs(log.orderTargetList) do
            --记录图腾技能受击相关角色
            animation.list[orderTarget.guid] = FightRoleMgr:getRole(orderTarget.guid)

            for __, oddSet in pairs(orderTarget.odd_list) do
                animation.list[oddSet.guid] = FightRoleMgr:getRole(oddSet.guid)

                --觉醒特殊处理
                if self.disillusion == oddSet.fightOdd.status_id then
                    animation.disillusionList[oddSet.guid] = 1
                    animation.disillusion = animation.disillusion + 1
                end
            end
    	end
    end

    --更新图腾技能相关数据
    role.lastSkillRound = round
    self.updateTotemCoolRound(role, round)
	
	LogMgr.log( 'debug', "%s", "图腾使用技能：" .. soldier.name)
	return obj.endTime
end

--处理图腾自动化
function __this:parseTotemAuto(time)
    local startTime = time;
    local obj = self.newObject(time)
    local list = FightRoleMgr:getSoldierList(FightAnimationMgr.leftPlayerInfo.camp, const.kAttrTotem)
    for __, role in pairs(list) do
        if 
            0 == role.totemCool 
            and FightAnimationMgr.leftTotemValue >= role.skill.self_costtotem
            and FightDataMgr.theFightUI.totemUI:isTouchEnabled(role)
        then
            obj.endTime = math.max(obj.endTime, self:parseTotem(time, role))
            if obj.endTime > time then
                break
            end
        end
    end
    
    if obj.endTime > time then
        return obj.endTime
    else
        return nil
    end
end

function __this:idle(time, round)
    local del = {}
    --使用图腾技能标识
    self.flagTotem = false
    FightDataMgr.totem_btn_right_lock = nil

    self:runOthers(time)

    if FightDataMgr.test then
        return self.flagTotem
    end

    --自动战斗处理
    -- if not FightDataMgr.autoFightFlag and true == FightDataMgr.autoFight then
    --     if not self.autoTime or time > self.autoTime then
    --         self.autoTime = self:parseTotemAuto(time)
    --     end
    -- end

    --处理图腾全局事件[效果层、角色层转移]
    for i, data in pairs(self.totemAnimationList) do
        if time > data.endTime then
            table.insert(del, i)

        elseif time >= data.startTime then
            self.flagTotem = true

            --敌方图腾表现时，我方图腾不能触发
            --[[if data.role.camp ~= FightAnimationMgr.camp then
                FightDataMgr.totem_btn_right_lock = true
            end]]
            FightDataMgr.totem_btn_right_lock = true
            local totemBlackView = FightDataMgr.theFightUI:getTotemBlackView()
            if not totemBlackView:getParent() then
                FightDataMgr:getLayerBlackground():addChild(totemBlackView)
            end
            for guid, role in pairs(data.list) do
                if FightDataMgr:getLayerBlackRole() ~= role.playerView:getParent() then
                    role.playerView:removeFromParent()
                    FightDataMgr:getLayerBlackRole():addChild(role.playerView)
                end
            end
        end
    end
    
    local list = FightRoleMgr:getSoldierList(nil, const.kAttrTotem)
	list = FightDataMgr.sort(list)
	--单独处理图腾事件
	for i, role in pairs(list) do
		if role.playerView then
			role.playerView:setLocalZOrder(i)
			self:runAnythings(time, role, true)
            self.updateTotemCoolRound(role, round)
		end
	end
	
    --事件结束处理    [1.恢复效果层、角色层的所属关系   2.觉醒事件处理]
	for i = #del, 1, -1 do
		local data = self.totemAnimationList[del[i]]
		table.remove(self.totemAnimationList, del[i])
        --1.恢复效果层、角色层的所属关系==============start
        local totemBlackView = FightDataMgr.theFightUI:getTotemBlackView()
		totemBlackView:removeFromParent()
        
        for __, role in pairs(data.list) do
            role.playerView:removeFromParent()
            FightDataMgr:getLayerRole():addChild(role.playerView)
        end
        --1.恢复效果层、角色层的所属关系=============end

        --2.觉醒事件处理
        self:parseDisillusionAnimation(data)
	end
	
	return self.flagTotem
end

--图腾事件结束后续处理    2.觉醒事件处理
function __this:parseDisillusionAnimation(data)
    if FightDataMgr.record then
        return
    end

    if 0 == data.disillusion or FightDataMgr.load_fight_log then
        --战报系统需要补充预出手事件
        if FightDataMgr.order_list and 0 == #FightDataMgr.listState then
            --创建新预出手状态事件
            local animation = FightData.newAnimation()
            animation.station = FightDataMgr.enum.PARSE_ROUND_SOLDIER
            animation.startTime = math.floor(FightDataMgr.runTime * 1000)
            animation.endTime = animation.endTime
            table.insert(FightDataMgr.listState, animation)

        else
            --恰好是每回合开始【特殊情况】
            if FightDataMgr:checkEnd() then
                FightDataMgr.listState = {}
                local state_end = FightData.newAnimation()
                state_end.startTime = math.max(self.dearTime, math.floor(FightDataMgr.runTime * 1000))
                state_end.endTime = state_end.startTime
                state_end.station = FightDataMgr.enum.CHECK_FIGHT_END
                table.insert(FightDataMgr.listState, state_end)
                return
            end
            
            if 0 ~= #FightDataMgr.listState then
                local animation = FightDataMgr.listState[1]
                if FightDataMgr.enum.PARSE_ROUND_SKILL == animation.station then
                    --更新服务器预出手逻辑[客户端不处理]
                    local fightSkillObject = FightDataMgr:roundSkillSoldier()
                    --恰好是每回合开始【特殊情况】
                    if FightDataMgr:checkEnd() then
                        FightDataMgr.listState = {}
                        local state_end = FightData.newAnimation()
                        state_end.startTime = math.max(self.dearTime, math.floor(FightDataMgr.runTime * 1000))
                        state_end.endTime = state_end.startTime
                        state_end.station = FightDataMgr.enum.CHECK_FIGHT_END
                        table.insert(FightDataMgr.listState, state_end)
                        return
                    end

                    local _time = math.floor(FightDataMgr.runTime * 1000) - 1
                    if 0 == fightSkillObject.order.guid then
                        FightAnimationMgr:parseFightSkillObject(math.floor(FightDataMgr.runTime * 1000), fightSkillObject)

                        local lastRole = FightRoleMgr:getRole(FightDataMgr.last_role_guid)
                        if lastRole then
                            for __, animation in pairs(lastRole.actionAnimationList) do
                                animation.endTime = _time
                            end
                            for __, animation in pairs(lastRole.effectAnimationList) do
                                animation.endTime = _time
                            end
                            for __, animation in pairs(lastRole.pathAnimationList) do
                                animation.endTime = _time
                            end
                            --坐标修正
                            if lastRole.playerView:getPositionX() ~= lastRole.station:x() then
                                local pathData = FightData:setPath(_time, 
                                    cc.p(lastRole.playerView:getPositionX(), lastRole.playerView:getPositionY()),
                                    lastRole.station:pos(), lastRole:isMirror(), true)
                                table.insert(lastRole.pathAnimationList, pathData)
                            end
                        end

                    elseif fightSkillObject.order.guid ~= FightDataMgr.last_role_guid then
                        local lastRole = FightRoleMgr:getRole(FightDataMgr.last_role_guid)
                        if lastRole then
                            local listRole = FightRoleMgr:getSoldierList()
                            for __, role in pairs(listRole) do
                                if not role:checkAttr(const.kAttrTotem) then
                                    for __, animation in pairs(role.actionAnimationList) do
                                        animation.endTime = _time
                                    end
                                    for __, animation in pairs(role.effectAnimationList) do
                                        animation.endTime = _time
                                    end
                                    for __, animation in pairs(role.pathAnimationList) do
                                        animation.endTime = _time
                                    end
                                end
                            end
                            --坐标修正
                            if lastRole.playerView:getPositionX() ~= lastRole.station:x() then
                                local pathData = FightData:setPath(_time, 
                                    cc.p(lastRole.playerView:getPositionX(), lastRole.playerView:getPositionY()),
                                    lastRole.station:pos(), lastRole:isMirror(), true)
                                table.insert(lastRole.pathAnimationList, pathData)
                            end
                        end

                        FightDataMgr.listState = {}
                        FightDataMgr.station = FightDataMgr.enum.SLEEP
                        FightDataMgr:parse_round_soldier(_time, fightSkillObject)
                    end

                end
            end
        end

        return
    else
        if FightDataMgr:checkEnd() then
            FightDataMgr.listState = {}
            local state_end = FightData.newAnimation()
            state_end.startTime = math.max(self.dearTime, math.floor(FightDataMgr.runTime * 1000))
            state_end.endTime = state_end.startTime
            state_end.station = FightDataMgr.enum.CHECK_FIGHT_END
            table.insert(FightDataMgr.listState, state_end)
            return
        end
    end

    --修正原状态时间点
    local stationAnimation = nil
    for i = #FightDataMgr.listState, 1, -1 do
        if FightDataMgr.enum.PARSE_ROUND_SKILL == FightDataMgr.listState[i].station 
            or FightDataMgr.enum.PARSE_ROUND_SOLDIER == FightDataMgr.listState[i].station 
        then
            stationAnimation = FightDataMgr.listState[i]
            break
        end
    end

    --觉醒技能表现结束时间
    local disTime = math.floor(FightDataMgr.runTime * 1000)
    local maxTime = disTime
    --觉醒武将插入动画事件
    local disillusionAnimatnionLock = FightData.newAnimation()
    disillusionAnimatnionLock.attr = 5
    disillusionAnimatnionLock.startTime = disTime
    disillusionAnimatnionLock.endTime = disTime

    local disillusionAnimatnionUnLock = FightData.newAnimation()
    disillusionAnimatnionUnLock.attr = 6
    disillusionAnimatnionUnLock.startTime = disTime + 200
    disillusionAnimatnionUnLock.endTime = disTime + 200

    --更新服务器预出手逻辑[客户端不处理]
    local fightSkillObject = FightDataMgr:roundSkillSoldier()
    if FightDataMgr:checkEnd() then
        return
    end

    if fightSkillObject then
        --获取预出手 [如果是每回合开始处理，则战斗全局状态必定是"parse_round_skill"]
        if 0 == fightSkillObject.order.guid then
            local obj = nil
            if stationAnimation then
                obj = FightAnimationMgr:parseFightSkillObject(stationAnimation.endTime, fightSkillObject)
            else
                obj = FightAnimationMgr:parseFightSkillObject(disTime, fightSkillObject)
            end
            disillusionAnimatnionUnLock.startTime, disillusionAnimatnionUnLock.endTime, maxTime, disTime = obj.endTime

            --log记录
            if FightDataMgr.save_fight_log then
                table.insert(FightDataMgr.clientLog.round_soldier, SFightClientSkillObject:new(disTime, math.floor(FightDataMgr.totemTime * 1000), fightSkillObject))
            end

        else
            local role = FightRoleMgr:getRole(fightSkillObject.order.guid)
            if not role then
                return
            end

            --觉醒武将与当前出手为同一人
            if FightDataMgr.last_role_guid == role.guid then
                --预出手状态立即替换为觉醒技能，清除相关动画
                if "parseFightSkillObject" == role.state then
                    for __, animation in pairs(role.actionAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    for __, animation in pairs(role.effectAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    for __, animation in pairs(role.pathAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    --坐标修正
                    local pathData = FightData:setPath(disTime, 
                        cc.p(role.playerView:getPositionX(), role.playerView:getPositionY()),
                        role.station:pos(), role:isMirror(), true)
                    table.insert(role.pathAnimationList, pathData)

                --正在出手状态，需等待表现完成后再表现觉醒技能，故退出特殊处理流程
                else
                    return
                end

            --觉醒武将与当前出手为非同一人
            else
                --正在出手的人未造成目标伤害，故删除已出手相关事件
                local lastRole = FightRoleMgr:getRole(FightDataMgr.last_role_guid)
                if lastRole and "parseFightSkillObject" == lastRole.state then
                    for __, animation in pairs(lastRole.actionAnimationList) do
                        if "dead" ~= animation.type then
                            animation.endTime = disTime - 1
                        end
                    end
                    for __, animation in pairs(lastRole.effectAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    for __, animation in pairs(lastRole.pathAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    --坐标修正
                    if lastRole.playerView:getPositionX() ~= lastRole.station:x() or lastRole.playerView:getPositionY() ~= lastRole.station:y() then
                        local pathData = FightData:setPath(disTime, 
                            cc.p(lastRole.playerView:getPositionX(), lastRole.playerView:getPositionY()),
                            lastRole.station:pos(), lastRole:isMirror(), true)
                        table.insert(lastRole.pathAnimationList, pathData)
                    end
                end
            end
        end
    end

    local logList = FightDataMgr.theFight:roundSkill()

    --log记录
    if FightDataMgr.save_fight_log then
        table.insert(FightDataMgr.clientLog.round_data_list, SFightClientRoundData:new(disTime, math.floor(FightDataMgr.totemTime * 1000), logList))
    end
    
    --原则上忽视多次出手
    for __, log in pairs(logList) do
        maxTime = math.max(FightAnimationMgr:parseLog(disTime, log), maxTime)
        break
    end

    if maxTime == disTime then
        maxTime = disTime + 200
    end
    disillusionAnimatnionUnLock.startTime = maxTime
    disillusionAnimatnionUnLock.endTime = maxTime
    table.insert(FightDataMgr.othersAnimationList, disillusionAnimatnionLock)
    table.insert(FightDataMgr.othersAnimationList, disillusionAnimatnionUnLock)

    --对当前出手者进行异常判断
    local target = FightRoleMgr:getRole(FightDataMgr.last_role_guid)
    if target then
        if 1 == data.disillusionList[FightDataMgr.last_role_guid] or data.disillusion > 1 then
            if "parseFightSkillObject" == target.state then
                if stationAnimation then
                    --预出手状态立即替换为觉醒技能，清除相关动画
                    for __, animation in pairs(target.actionAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    for __, animation in pairs(target.effectAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    for __, animation in pairs(target.pathAnimationList) do
                        animation.endTime = disTime - 1
                    end
                    --坐标修正
                    local pathData = FightData:setPath(disTime, 
                        cc.p(target.playerView:getPositionX(), target.playerView:getPositionY()),
                        target.station:pos(), target:isMirror(), true)
                    table.insert(target.pathAnimationList, pathData)

                    table.remove(FightDataMgr.listState, #FightDataMgr.listState)
                    stationAnimation = nil
                end
            end

        end
    end

    --清空已添加下一预出手事件
    -- if stationAnimation and FightDataMgr.enum.PARSE_ROUND_SOLDIER == stationAnimation.station then
    if not table.empty(FightDataMgr.listState) then
        table.remove(FightDataMgr.listState, #FightDataMgr.listState)
    end

    local list = FightRoleMgr:getSoldierList()
    for __, role in pairs(list) do
        if not role:checkAttr(const.kAttrTotem) then
            maxTime = math.max(maxTime, role.lastTime)
        end
    end

    -- if table.empty(FightDataMgr.listState) or not stationAnimation or maxTime + 1 > stationAnimation.endTime then
    if table.empty(FightDataMgr.listState) then
        --创建新预出手状态事件
        local animation = FightData.newAnimation()
        animation.station = FightDataMgr.enum.PARSE_ROUND_SOLDIER
        animation.startTime = maxTime + 1
        animation.endTime = maxTime + 1
        table.insert(FightDataMgr.listState, animation)

    --恢复原状态 [插入觉醒技能的结束时间比当前武将表现结束时间早才会出现，理论上不会出现这种情况]
    elseif "parse_round_soldier" == FightDataMgr.runStation then
        --更新服务器预出手逻辑[客户端不处理]
        FightDataMgr.theFight:roundSkillSoldier()
    end
end

--获取涉事英雄最后出手动画结束时间点
function __this.getSoldierLastTime(list, runTime)
    if "parse_round_soldier" == FightDataMgr.runStation then
        return runTime
    end

    for __, guid in pairs(list) do
        local role = FightRoleMgr:getRole(guid)
        if role then
            if runTime < role.lastTime then
                runTime = role.lastTime
            end
        end
    end

    return runTime
end

--根据当前回合更新冷回合数
function __this.updateTotemCoolRound(role, round)
    if not role.fightSoldier or trans.const.kAttrTotem ~= role.fightSoldier.attr or not role.skill then
        role.totemCool = 0
        return role.totemCool
    end

    if const.kFightTypeCommonPlayer ~= FightDataMgr.fight_type then
        local soldier = FightDataMgr.theFight:findSoldier(role.guid)
        if not soldier or soldier:checkTotemSkill() then
            role.totemCool = 0
            return role.totemCool
        end
    end

    --战斗首次可使用技能的回合判断
    if 0 == role.lastSkillRound then
        if round < role.skill.start_round then
            role.totemCool = role.skill.start_round - round
        else
            role.totemCool = 0
        end
        
        role.canSkillRound = role.skill.start_round
        return role.totemCool
    end

    role.canSkillRound = role.lastSkillRound + role.skill.cooldown
    role.totemCool = role.canSkillRound - round
    if role.totemCool < 0 then
        role.totemCool = 0
    end

    return role.totemCool
end

FightTotemMgr = __this