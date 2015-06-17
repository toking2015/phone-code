local const = trans.const

--战斗动画管理
local __this = 
{
    camp = 0,               --当前玩家当属阵营方

    leftPlayerInfo = nil,   --左方阵营
    rightPlayerInfo = nil,  --右方阵营

    leftSceneSoundRound = nil,    --左阵营场景声音
    rightSceneSoundRound = nil,   --右阵营场景声音
    delaySceneSoundRound = 3,   --场景声音间隔
    
    const = 
    {
        --清空buff特写字段
        BUFF_CLEAR = 0xf00000,
		--图腾ready特效
		TOTEM_READY = "TT-jh-tx01",
        --图腾触发技能时特效
        TOTEM_FIRE = "tt-tb-tx01",
        --蓄气特效Id*/
        POWER_EFFECTID = "tx-jinengshifang01",
        --召唤专用特效
        CALL_EFFECTID = "szf-tx-01",
        --死亡后两回合复活前专用特效
        RESURRECTION = "BUFF2-21",
        --复活专用特效
        REVIVE_EFFECTID = "YS10wageli-tx3%physical7",
        --妖术、变羊专用特效
        WITCHCRAFT = "YS17wojin-tx%physical4",

		
        --暴击专用音效*/
        CRIT_SOUND = "new_critical",
        --闪避专用音效*/
        DODGE_SOUND = "new_dodge",
        --格挡专用音效*/
        PARRY_SOUND = "new_block",
        --大招专用音效*/
        SKILL_SOUND = "new_ping",
        --boss眼神大招专用音效*/
        BOSS_SOUND = "new_bossult",
        --天气技能大风特效专用音效*/
        WEATHER_SOUND_1 = "goddessskill",
    }
}
__this.__index = __this

require( "lua/game/view/fight/struct/FightData.lua" )
--参战人员数据集合
require( "lua/game/view/fight/struct/SFightRole.lua" )

function __this.getAttrUrl(attr, style)
    return 'image/armature/fight/' .. attr .. '/' .. style .. '/' .. style .. ".ExportJson"
end

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
        passiveTime = time,
    }
    
    return obj
end

function __this:releaseAll()
    self.list_PlayerInfo = nil
    self.leftPlayerInfo = nil
    self.rightPlayerInfo = nil
    self.camp = nil
    self.leftTotemValue = 0
    self.rightTotemValue = 0
    self.leftTotemCount = 0
    self.rightTotemCount = 0
    self.boss = {monster = nil, role = nil}
    self.info_index = 3
    self.leftSceneSoundRound = nil
    self.rightSceneSoundRound = nil
end


--参战人员数据初始化 【战斗系统数据入口】
function __this:initPlayerInfo( list_PlayerInfo )
    self.info_index = 3
    if 2 > #list_PlayerInfo then
        ActionMgr.save("fight", "initPlayerInfo start")
        LogMgr.log( 'FightDataMgr', "%s", "playerInfo length not 2" .. #list_PlayerInfo )
        return false
    end
    
    self.list_PlayerInfo = list_PlayerInfo
    LogMgr.log( 'FightDataMgr', "%s", "FightAnimationMgr:initPlayerInfo start" )
    if not FightDataMgr.collaborationist then
        for i, user in pairs(list_PlayerInfo) do
            if i == self.info_index then
                break
            end
            
            if GameData.id == user.player_guid then
                self.leftPlayerInfo = user
                self.camp = user.camp
            else
                self.rightPlayerInfo = user
            end
        end
    end

    if not self.leftPlayerInfo or not self.rightPlayerInfo then
        for __, user in pairs(list_PlayerInfo) do
            if const.kFightLeft == user.camp then
                self.leftPlayerInfo = user
                self.camp = user.camp
            else
                self.rightPlayerInfo = user
            end
        end
    end
    self.leftTotemValue = 0
    self.rightTotemValue = 0
    self.leftTotemCount = 0
    self.rightTotemCount = 0

    --记录boss
    self.boss = {monster = nil, role = nil}

    local glyphCount = 0
    local map = {}
    for i, user in pairs( list_PlayerInfo ) do
        if i >= self.info_index then
            break
        end
        
        local mirror = false
        if user.camp ~= self.leftPlayerInfo.camp then
            mirror = true
        end
        
        for __, s in pairs( user.soldier_list ) do
            local role = FightRoleMgr:getByIndex( mirror, s.fight_index )
            if nil == role then
                LogMgr.log( 'FightDataMgr', "%s", "soldier station error" .. s.fight_index )
            else
                local soldier = FightDataMgr.theFight:findSoldier(s.guid)

                role:init(user, soldier)

				if mirror then
					FightDataMgr.rightHpMax = math.max(FightDataMgr.rightHpMax, soldier.hp)
                    if const.kAttrTotem == soldier.attr then
                        self.rightTotemCount = self.rightTotemCount + 1
                    end
				else
					FightDataMgr.leftHpMax = math.max(FightDataMgr.rightHpMax, soldier.hp)
                    if const.kAttrTotem == soldier.attr then
                        self.leftTotemCount = self.leftTotemCount + 1
                    end
				end

                --[[--战前buff添加
                for __, odd in pairs(soldier.odd_list) do
                    -- if FightTotemMgr.sneak == odd.status_id then
                        local o = findOdd(odd.id, odd.level)
                        if o and 0 == o.start_round and 0 == o.delay_round then
                            local opacityAnimation = FightData.newAnimation()
                            opacityAnimation.odd = odd
                            opacityAnimation.startTime = 0
                            opacityAnimation.endTime = 0
                            opacityAnimation.opacity = 127

                            table.insert(role.opacityAnimationList, opacityAnimation)
                        end

                        self:setBodyEffect(role, 
                            {guid=role.guid, set_type=const.kObjectAdd, {}}, 
                            o, 0)
                    -- end
                end]]

                if role:checkAttr(const.kAttrTotem) then
                    role.totem_glyph_list = {}
                    if soldier.totem_glyph_list then
                        for __, glyph in pairs(soldier.totem_glyph_list) do
                            local g = FightFileMgr:copyTab(glyph)
                            g.totem_guid = soldier.guid
                            table.insert(role.totem_glyph_list, g)
                        end
                    end

                    role.totem_glyph = FightFileMgr:copyTab(soldier.totem)
                    role.totem_glyph.guid = soldier.guid
                    role.totem_glyph.totem_id = role.totem.id
                    role.totem_glyph.level = role.totem_glyph.level or role.totem.init_lv
                end
            end
        end
    end

    local totemList = FightRoleMgr:getSoldierList(nil, const.kAttrTotem)
    

    for i, user in pairs(list_PlayerInfo) do
        if i >= self.info_index then
            break
        end

        for __, soldier in pairs(user.soldier_list) do
            local role = FightRoleMgr:getRole(soldier.guid)
            if role and not role:checkAttr(const.kAttrTotem) then
                map[soldier.guid] = {}
                --图腾战前二级属性加成
                if soldier.glyph_list then
                    for __, s2 in pairs(soldier.glyph_list) do
                        map[soldier.guid][s2.first] = map[soldier.guid][s2.first] or 0
                        map[soldier.guid][s2.first] = map[soldier.guid][s2.first] + s2.second or s2.second
                    end
                end

                --十字军试炼
                local json = nil
                if const.kFightTypeTrialSurvival == FightDataMgr.fight_type then
                    json = findTrial(1)
                elseif const.kFightTypeTrialStrength == FightDataMgr.fight_type then
                    json = findTrial(2)
                elseif const.kFightTypeTrialAgile == FightDataMgr.fight_type then
                    json = findTrial(3)
                else
                    json = findTrial(4)
                end

                for __, fightOdd in pairs(soldier.odd_list) do
                    local flag = false
                    for __, totemRole in pairs(totemList) do
                        if totemRole.totemOdd and role:isMirror() == totemRole:isMirror() then
                            if totemRole.totemAttr.formation_add_attr.first == fightOdd.id
                                or totemRole.totemAttr.speed.first == fightOdd.id then
                                flag = true
                                break
                            end
                        end
                    end

                    --十字军试炼检测
                    if not flag and json and (fightOdd.id == json.occu_odd[1].first or fightOdd.id == json.occu_odd[2].first) then
                        flag = true
                    end

                    if flag then
                        local odd = findOdd(fightOdd.id, fightOdd.level)
                        if odd and 0 ~= odd.effect.cate then
                            map[soldier.guid][odd.effect.cate] = map[soldier.guid][odd.effect.cate] or 0
                            map[soldier.guid][odd.effect.cate] = map[soldier.guid][odd.effect.cate] + odd.effect.objid or odd.effect.objid
                        end
                    end
                end

                local j = 0
                for key, value in pairs(map[soldier.guid]) do
                    j = j + 1
                    role.deferAnimation(
                        role.skillAnimationList, 
                        FightData:createSkillName(
                            role, 
                            j * 300, 
                            4, 
                            nill, 
                            nill, 
                            nill, 
                            {first = key, second = value}
                        ),
                        50
                    )
                end
                glyphCount = math.max(glyphCount, j)
            end
        end
    end

    for i, user in pairs(list_PlayerInfo) do
        if i >= self.info_index then
            break
        end

        local flag = false
        for __, soldier in pairs( user.soldier_list ) do
            if trans.const.kAttrSoldier == soldier.attr then
                local role = FightRoleMgr:getRole(soldier.guid)
                if role then
                    for __, fightOdd in pairs(soldier.odd_list) do
                        FightAnimationMgr:parseRoundPassive(0, {first = soldier.guid, second = fightOdd.id}, role)
                    end

                    --图腾值更新
                    if not flag and self.camp == user.camp then
                        flag = true
                        local rageAnimation = FightData.newAnimation()
                        rageAnimation.startTime = 0
                        rageAnimation.endTime = 0
                        rageAnimation.value = user.totem_value
                        table.insert(role.totemValueAnimationList, rageAnimation)
                    end
                end

            --记录boss
            elseif trans.const.kAttrMonster == soldier.attr then
                local monster = findMonster(soldier.soldier_id)
                if monster and 2 == monster.type then
                    self.boss.monster = monster
                    self.boss.role = FightRoleMgr:getRole(soldier.guid)
                    break
                end
            end
        end
    end

    local station = nil
    --调试模式
    if FightDataMgr.load_fight_log then
        station = FightDataMgr.enum.SLEEP
    end

    --添加战前初始化事件
    if 0 == glyphCount then
        FightDataMgr:fightInit(0, station)
    else
        FightDataMgr:fightInit(1000 + 300 * glyphCount, station)
    end

    --计算怪物数量[用于物品掉落]===========start
    self.monsterCount = 0
    for __, user in pairs(list_PlayerInfo) do
        if self.camp ~= user.camp and trans.const.kAttrMonster == user.attr then
            for __, soldier in pairs( user.soldier_list ) do
                self.monsterCount = self.monsterCount + 1
            end
        end
    end
    --计算怪物数量[用于物品掉落]===========end

    LogMgr.log( 'FightDataMgr', "%s", "FightAnimationMgr:initPlayerInfo finish" )
    ActionMgr.save("fight", "initPlayerInfo end")
    return true
end

--战前buff添加
function __this:initOdd()
    --不处理
    if self then
        return
    end

    for __, user in pairs(self.list_PlayerInfo) do
        for __, soldier in pairs(user.soldier_list) do
            local role = FightRoleMgr:getRole(soldier.guid)
            if role and not role:checkAttr(const.kAttrTotem) then
                for __, odd in pairs(soldier.odd_list) do
                    local o = findOdd(odd.id, odd.level)
                    if o and 0 == o.delay_round then
                        if FightTotemMgr.sneak == odd.status_id then
                            local opacityAnimation = FightData.newAnimation()
                            opacityAnimation.odd = odd
                            opacityAnimation.startTime = 0
                            opacityAnimation.endTime = 0
                            opacityAnimation.opacity = 127

                            table.insert(role.opacityAnimationList, opacityAnimation)
                        end

                        self:setBodyEffect(role, {guid=role.guid, set_type=const.kObjectAdd, {}}, o, 0)
                    end
                end
            end
        end
    end
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

--身上特效处理    [odd为原型数据，创建动画需创建动画专用odd数据结构]
function __this:setBodyEffect(role, oddSet, odd, time, target)
    --单次特效
    local lastTime = time
    if odd.onceeffect and '' ~= odd.onceeffect then
        local list = string.split(odd.onceeffect, '%')
        if #list >= 1 then
            local effect = FightFileMgr:getEffect(list[1])
            if effect then
                local newOdd = odd or {id = odd.id, level = odd.level, onceeffect = list[1]}
                local animation = nil
                if #list > 1 then
                    animation = FightData:createBodyAnimation( time, oddSet, newOdd, effect, role, list[2] )
                else
                    animation = FightData:createBodyAnimation( time, oddSet, newOdd, effect, role )
                end
                animation.role = role
                animation.target = target
                lastTime = role:filterBodyEffectOnce(animation)
            end
        end
    end

    --循环特效
    if odd.buffeffect and '' ~= odd.buffeffect then
        local list = string.split(odd.buffeffect, '%')
        if #list >= 1 then
            local effect = FightFileMgr:getEffect(list[1])
            if effect then
                local newOdd = odd or {id = odd.id, level = odd.level, buffeffect = list[1]}
                local animation = nil
                if #list > 1 then
                    animation = FightData:createBodyAnimation(lastTime, oddSet, newOdd, effect, role, list[2])
                else
                    animation = FightData:createBodyAnimation(lastTime, oddSet, newOdd, effect, role)
                end
                animation.role = role
                animation.target = target
                animation.endTime = 0
                role:filterBodyEffectBuff(animation)
            end
        end
    end

    if odd.status and FightTotemMgr.sneak == odd.status.cate then
        if trans.const.kObjectDel == oddSet.set_type then
            for __, animation in pairs(role.opacityAnimationList) do
                if animation.odd and animation.odd.id == odd.id then
                    animation.endTime = time
                    animation.opacity = 255
                    break
                end
            end

            return
        end

        local opacityAnimation = FightData.newAnimation()
        opacityAnimation.startTime = time
        opacityAnimation.endTime = 0
        opacityAnimation.opacity = 127

        table.insert(role.opacityAnimationList, opacityAnimation)
    end
end

--清除身上的特效
function __this:clearEffect( role, time )
    local oddSet = 
    {
        guid = role.guid,
        set_type = const.kObjectDel
    }
    local odd = {}
    
    local animation = FightData:createBodyAnimation(time, oddSet, odd, nil, role)
    animation.endTime = animation.startTime
    role:filterBodyEffectBuff(animation)
    role:filterBodyEffectOnce(animation)
end

--怒气特效处理
function __this:rageEffect( role, fightSoldier, animation, time )
    --[[local fightOddSet = 
    {
        guid = 0,
        set_type = 0,       -- kObjectDel, kObjectAdd, kObjectUpdate
        odd =    -- odd状态
        {
            id = 0,        -- 异常ID                                                
            level = 0,       -- 异常等级                                              
            start_round = 0,        -- 异常开始回合
            status_id = 0,      -- 产生状态ID
            status_value = 0,      -- 产生状态ID对应的Value
            use_count = 0,      -- 使用次数
            delFlag = 0,        -- 删除标记
        }
    }
    
    if animation.rage >= role.oldRage then
        fightOddSet.set_type = const.kObjectAdd
    else
        fightOddSet.set_type = const.kObjectDel
    end
    
    local odd = 
    {
        buffeffect = self.const.RAGE_EFFECTID,   --满怒气专用特效id
        onceeffect = 0
    }
    
    for i = #role.bodyEffectAnimationList, 1, -1 do
        if self.const.RAGE_EFFECTID ~= role.bodyEffectAnimationList[i].odd.buffeffect then
            break
        end
        
        if fightOddSet.set_type == role.bodyEffectAnimationList[i].oddSet.set_type then
            return 
        end
        
        break
    end
        
    self:setBodyEffect( role, fightOddSet, odd, time )--]]
end

--受击数字动画
function __this:parseHpValue( time, role, orderTarget )
    --[[if 0 == orderTarget.fight_value or orderTarget.fight_result then
        return
    end
    
    local animation = FightData:createSubValueAnimation( orderTarget, time )
    role:filterHp(animation)
    
    --加血特效处理
    
    local fightSoldier = FightDataMgr.theFight:findSoldier( orderTarget.guid )
    if nil == fightSoldier then
        return
    end
    
    --复活相关处理
    if role.oldHp <= 0 and fightSoldier.hp > 0 then
        animation = FightData:createPathAnimation(time)
        animation.endTime = time + 40
        animation.alphaList = {1}
        table.insert( role.pathAnimationList, animation )
        
        animation = FightData:createActionAnimation( role.body:getActionByFlag( "stand" ), time )
        role:filterAction(animation) 
		
        role.dearTime = nil
    end
    
    role.oldHp = fightSoldier.hp]]
end

--变身
function __this:parseAttrChange(time, role, log, obj)
    local newLog = self.getLogByAttr(log, const.kFightAttrChange)
	if 0 == #newLog.orderTargetList then
		return obj
	end
	
	for __, orderTarget in pairs(newLog.orderTargetList) do
		local soldier = FightDataMgr.theFight:findSoldier(orderTarget.fight_value)
		if soldier then
            local newRole = FightRoleMgr:getRole(orderTarget.guid)
            if newRole then
                newRole:delAction("dead", 99)
                
                local action = newRole.body:getActionByFlag("dead")
                --创建动作动画事件
                local animation = FightData:createActionAnimation( action, time )
                newRole:filterAction(animation)
                newRole.dearTime = animation.endTime
                newRole.dearActionStartTime = animation.startTime

                --清空所有buff事件
                self:clearEffect(newRole, newRole.dearTime)
                
                --添加变身事件
                animation = FightData:createAttrChangeAnimation(animation.endTime, FightDataMgr.theFight:findSoldier(orderTarget.fight_value), 1)
                table.insert(newRole.callChangeAnimationList, animation)
				
                obj.endTime = math.max(obj.endTime, animation.endTime)
                
                --添加移动轨迹
                local pathAnimation = FightData:createSceneBossPathAnimation(animation.startTime - 100, newRole, animation.endTime)
                animation.pt = pathAnimation.startPT
                
                table.insert(newRole.pathAnimationList, pathAnimation)

                --释放相关特效
                local animation = FightData.newAnimation()
                animation.startTime = newRole.dearTime + 1000
                animation.endTime = animation.startTime
                table.insert(newRole.releaseAnimationList, animation)
            end
		end
	end
	
	return obj
end

--第二技能爆power特效
function __this:parsePowerEffect(role, skill, time)
    if not skill or 2 ~= role:getSkillIndex(skill.id, skill.level) then
        return time
    end

    local effect = FightFileMgr:getEffect(self.const.POWER_EFFECTID)
    if not effect then
        return time
    end

    local oddSet = {set_type = const.kObjectAdd}
    local odd = {id = self.const.POWER_EFFECTID, onceeffect = self.const.POWER_EFFECTID}
    local animation = FightData:createBodyAnimation(time, oddSet, odd, effect, role)
    role:filterBodyEffectAdd(animation)

    return animation.endTime
end

--只有攻击方特效与相匹配音效
function __this:setAckEffect(role, action, actionEffect, startTime, skill, log)
    local time = startTime

    --施放方特效
    if actionEffect and "" ~= actionEffect.ackEffect then
        --创建施放方身上特效动画事件
        local effectAnimation, bindingAnimation = FightData:createEffectAnimation(actionEffect, startTime, actionEffect.ackEffect, role, true)
        role:filterEffect(effectAnimation)
        time = effectAnimation.endTime

        if bindingAnimation then
            role:filterEffect(bindingAnimation)
        end
    end

    --施放方音效
    if role.sound then
        FightData:createSound(role, startTime, role.sound:getActionByFlag(action.flag, actionEffect.index, FightFileMgr.sound_enum.ACK))
    end

    --场景语音
    if log then
        if role:checkAttr(const.kAttrSoldier) 
            and not role:isMirror() 
            and 0 ~= #role.soldier.sounds 
        then
            if not self.leftSceneSoundRound or log.round - self.leftSceneSoundRound > self.delaySceneSoundRound then
                local random = math.random(0, 100)
                if const.kattrPlayer == self.rightPlayerInfo.attr then
                    if random <= 10 then
                        FightData.createSceneSound(startTime, role.soldier.sounds[math.random(1, #role.soldier.sounds)])
                        self.leftSceneSoundRound = log.round
                    end
                else
                    if random <= 20 then
                        FightData.createSceneSound(startTime, role.soldier.sounds[math.random(1, #role.soldier.sounds)])
                        self.leftSceneSoundRound = log.round
                    end
                end
            end

        elseif role:checkAttr(const.kAttrMonster) 
            and role:isMirror() 
            and 0 ~= #role.monster.sounds
            and 0 ~= skill.self_costrage 
            and 0 == skill.disillusion
        then
            if not self.rightSceneSoundRound or log.round - self.rightSceneSoundRound >= 3 then
                self.rightSceneSoundRound = log.round
                FightData.createSceneSound(startTime, role.monster.sounds[math.random(1, #role.monster.sounds)])
            end
        end
    end

    return time
end

--只有攻击动作、施放方身上特效数据处理
function __this:setAck(role, action, actionEffect, skill, startTime, effectFlag, log)
    local obj = self.newObject(startTime)
    role:recoverStyle(startTime)

    local opacityAnimation = FightData.newAnimation()
    opacityAnimation.startTime = startTime
    opacityAnimation.endTime = startTime
    opacityAnimation.opacity = 255
    table.insert(role.opacityAnimationList, opacityAnimation)

    startTime = FightFileMgr:getTime( actionEffect, "TIME_ACK_ACTION", startTime )
	obj.ackTime = startTime
	
    --创建动作动画事件
    local animation = FightData:createActionAnimation( action, obj.ackTime )
	role:filterAction(animation)
    obj.endTime = animation.endTime
    
    if #actionEffect.timeShaftDataList < 6 then
        LogMgr.log("FightDataMgr", "%s", "时间轴配置不完整，模型：" .. role.body.style)
    end

    --记录受击时间
    obj.targetTime = FightFileMgr:getFirstHurtTime(actionEffect, startTime)
    
    --以时间轴换算特效触发时间
    obj.effectTime = FightFileMgr:getTime( actionEffect, "TIME_ACK_EFFECT", startTime )
    
    --施放方特效
    if not effectFlag then
        obj.endTime = math.max(obj.endTime, self:setAckEffect(role, action, actionEffect, obj.effectTime, skill, log))
    end

    --喊招音效
    if role.sound and 0 == math.random(0, 1) then
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
function __this:parseAckRole(role, action, actionEffect, log, startTime, skill, effectFlag)
    local objAck = self.newObject(startTime)
    
    local time = startTime
    local scaleAnimation = nil
    --英雄触发第三个技能的唯一条件“觉醒”buff
    if skill and 1 == skill.disillusion then
        scaleAnimation = FightData.newAnimation()
        scaleAnimation.startTime = time
        scaleAnimation.endTime = time
        scaleAnimation.scale = 1.8

        startTime = scaleAnimation.startTime + 200
    end

    --爆power
    startTime = self:parsePowerEffect(role, skill, startTime)

    --技能喊招数据处理
    if 
        skill
        and #role.fightSoldier.skill_list > 1 
        and role:getSkillIndex(skill.id, skill.level) > 1
    then
        --喊招事件[技能]
        local skillAnimation = FightData:createSkillName(role, startTime, 1, skill)
        role.deferAnimation(role.skillAnimationList, skillAnimation, 50)
    end

    --近身处理
    if skill and log and 1 == action.attribute then
        --瞬间移动动画事件
        local pathAnimation = FightData:createPathAnimation( startTime, role, action, log, skill, false )
        table.insert( role.pathAnimationList, pathAnimation )
        
        startTime = pathAnimation.endTime
    end
    
    --攻击动作、特效数据处理
    local obj = __this:setAck(role,action,actionEffect,skill,startTime, effectFlag, log)
    obj.startTime = objAck.startTime
    
    --记录近身移动结束时间点
    obj.pathTime = obj.targetTime

    --缩放处理
    if scaleAnimation then
        scaleAnimation.endTime = obj.endTime
        table.insert(role.scaleAnimationList, scaleAnimation)
    end
    
    --处理回程动画
    if skill and log and 1 == action.attribute then
        --瞬间移动动画事件
        local backPathAnimation = FightData:createPathAnimation( startTime, role, action, log, skill, true )
        obj.pathAnimation = backPathAnimation
    end
    
    return obj
end

--战斗过程中武将被动技能[不处理受击]
function __this:parseFightingPassive(time, target, fightOddTriggered, odd)
    if not odd.passive_act or '' == odd.passive_act then
        return time
    end

    local role = FightRoleMgr:getRole(fightOddTriggered.use_guid)
    if not role then
        return time
    end

    local flag = false
    for __, o in pairs(role.fightSoldier.odd_list) do
        if fightOddTriggered.odd_id == o.id then
            flag = true
            break
        end
    end

    if not flag then
        return time
    end

    local l = string.split(odd.passive_act, '%')
    if 0 == #l then
        return time
    end

    local action = role.body:getActionByFlag(l[1])
    if not action then
        return time
    end

    local index = 0
    if #l > 1 then
        index = l[2]
    end

    local actionEffect = FightFileMgr:getActionEffect(action, index)
    if not actionEffect then
        return time
    end

    local skill = role:getNormalSkill(1)
    local objAck = self:parseAckRole(role, action, actionEffect, nil, time, skill)
    if 0 ~= #fightOddTriggered.targetList then
        for __, t in pairs(fightOddTriggered.targetList) do
            target = FightRoleMgr:getRole(t.guid)
            if target then
                local animationFire = FightData:parseFire(time, role, target, action, actionEffect, 0, 3)

                if '' ~= actionEffect.targetEffect then
                    local timeEffect = actionEffect.timeShaftDataList[5] + time
                    if animationFire then
                        timeEffect = animationFire.endTime
                    end
                    target:filterEffect(FightData:createTargetEffectAnimation(actionEffect, timeEffect, actionEffect.targetEffect, target))

                    --音效
                    if role.sound then
                        --目标方音效
                        FightData:createSound(role, timeEffect, role.sound:getActionByFlag(action.flag, 0, FightFileMgr.sound_enum.TARGET))
                    end
                end
            end
        end

    --对自己
    else
        local animationFire = FightData:parseFire(time, role, role, action, actionEffect, 0, 3)

        if '' ~= actionEffect.targetEffect then
            local timeEffect = actionEffect.timeShaftDataList[5] + time
            if animationFire then
                timeEffect = animationFire.endTime
            end

            role:filterEffect(FightData:createTargetEffectAnimation(actionEffect, timeEffect, actionEffect.targetEffect, role))

            --音效
            if role.sound then
                --目标方音效
                FightData:createSound(role, timeEffect, role.sound:getActionByFlag(action.flag, 0, FightFileMgr.sound_enum.TARGET))
            end
        end
    end

    return objAck.endTime
end

--解释受击方的逻辑、表现   [受击特效不在此函数处理]
function __this:parseTargetRole(role, actionEffect, targetRole, orderTarget, ackTime, mightMax, skill)
	--时间轴受击起始索引
	local indexTimeShaft = FightFileMgr:getMight(actionEffect, orderTarget.fight_might)
	if 0 == orderTarget.fight_might then
		indexTimeShaft = 3
    else
        local opacityAnimation = FightData.newAnimation()
        opacityAnimation.startTime = ackTime
        opacityAnimation.endTime = ackTime
        opacityAnimation.opacity = 255
        table.insert(targetRole.opacityAnimationList, opacityAnimation)
	end
    
    if #actionEffect.timeShaftDataList < 6 then
        LogMgr.log("FightDataMgr", "%s", "时间轴配置不完整，模型：" .. role.body.style)
    end

    local time = actionEffect.timeShaftDataList[indexTimeShaft + 2] + ackTime
    local obj = self.newObject(time)
    obj.dearTime = time
    
    --当前参战人员于服务器的数据
    local fightSoldier = FightDataMgr.theFight:findSoldier( orderTarget.guid )
    --如果生命值已经为0并且为扣除的情况下，不做任何处理
    --if 0 == fightSoldier.hp and const.kFightDicHP == orderTarget.fight_result then
    --    return obj
    --end

    --觉醒失败
    if trans.const.kFightAttrNoDisillusion == orderTarget.fight_attr then
        local skillAnimation = FightData:createSkillName(targetRole, time, 3)
        targetRole.deferAnimation(targetRole.skillAnimationList, skillAnimation, 50)
        return obj
    elseif const.kFightAttrRebound == orderTarget.fight_attr then
        targetRole.deferAnimation(targetRole.skillAnimationList, FightData:createSkillName(targetRole, time, 7))
        return obj

    --增加图腾值显示
    elseif trans.const.kFightAttrTotemValueShow == orderTarget.fight_attr then
        return obj
    end
    
    local hurtHp = 0
    --受击数字动画
    if 0 ~= orderTarget.fight_result then
        local animation = FightData:createSubValueAnimation(orderTarget, targetRole:updateHurtTime(time))
        animation.odd_id = orderTarget.odd_id
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
            
        targetRole:filterHp(animation)
    end

    local animationRage = FightData:createSubValueAnimation(orderTarget, targetRole:updateHurtTime(time))
    animationRage.rage = orderTarget.rage
    animationRage.role = targetRole
    table.insert(targetRole.rageAnimationList, animationRage)

    --异常处理
    for __, oddSet in pairs( orderTarget.odd_list ) do
        if 0 ~= oddSet.fightOdd.id then
            local odd = findOdd( oddSet.fightOdd.id, oddSet.fightOdd.level )
            if nil ~= odd then
                -- if const.kObjectDel ~= oddSet.set_type then
                --     if orderTarget.guid ~= oddSet.guid then
                --         --喊招事件[Buff]
                --         local skillAnimation = FightData:createSkillName(role, time, 2, nil, odd, oddSet.fightOdd)
                --         role.deferAnimation(role.skillAnimationList, skillAnimation, 50)
                --     else
                --         --喊招事件[Buff]
                --         local skillAnimation = FightData:createSkillName(targetRole, time, 2, nil, odd, oddSet.fightOdd)
                --         targetRole.deferAnimation(targetRole.skillAnimationList, skillAnimation, 50)
                --     end
                -- end

                local target = FightRoleMgr:getRole(oddSet.guid)
                if target then
                    if const.kObjectDel ~= oddSet.set_type then
                        --喊招事件[Buff]
                        local skillAnimation = FightData:createSkillName(target, time, 2, nil, odd, oddSet.fightOdd)
                        target.deferAnimation(target.skillAnimationList, skillAnimation, 50)
                    end

                    if const.kObjectUpdate ~= oddSet.set_type then
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
                                    self:setBodyEffect(o, oddSet, odd, time)
                                    break
                                end
                            end
                        else
                            local __time = 0
                            if 1130 == odd.id then
                                __time = -1000
                            end

                            self:setBodyEffect(target, oddSet, odd, time + __time)
                        end

                        --新加个变形术(变成羊)，中了这个状态不能行动,但被攻击后变羊的状态会消失。
                        if FightTotemMgr.sheep == odd.status.cate then
                            if const.kObjectAdd == oddSet.set_type then
                                FightData:createChangeModelAnimation(time, target, "XG20yang")
                                self:setBodyEffect(target, oddSet, {id=self.const.WITCHCRAFT, level=1, onceeffect=self.const.WITCHCRAFT}, time, target)

                                local soundAnimation = FightData.newAnimation()
                                soundAnimation.sound = "sheep"
                                soundAnimation.startTime = time
                                soundAnimation.endTime = soundAnimation.startTime
                                table.insert(role.soundAnimationList, soundAnimation)
                            else
                                FightData:createChangeModelAnimation(time, target, target.body.style)
                            end

                        --新加个变形术(变成青蛙)，中了这个状态不能行动，就算给打了变形术的状态也不会消失。
                        elseif FightTotemMgr.frog == odd.status.cate then
                            if const.kObjectAdd == oddSet.set_type then
                                FightData:createChangeModelAnimation(time, target, "XG21qingwa")
                                self:setBodyEffect(target, oddSet, {id=self.const.WITCHCRAFT, level=1, onceeffect=self.const.WITCHCRAFT}, time, target)
                                
                                local soundAnimation = FightData.newAnimation()
                                soundAnimation.sound = "frog"
                                soundAnimation.startTime = time
                                soundAnimation.endTime = soundAnimation.startTime
                                table.insert(role.soundAnimationList, soundAnimation)
                            else
                                FightData:createChangeModelAnimation(time, target, target.body.style)
                            end

                        --飓风：令随机N个目标进入飓风状态（被驱逐出场）N回合
                        -- elseif FightTotemMgr.hurricane == odd.status.cate then
                        --     local opacityAnimation = FightData.newAnimation()
                        --     opacityAnimation.startTime = time
                        --     opacityAnimation.endTime = time + 255
                        --     opacityAnimation.odd = odd
                        --     if const.kObjectAdd == oddSet.set_type then
                        --         opacityAnimation.opacity = 0
                        --     else
                        --         opacityAnimation.opacity = 255
                        --     end

                        --     table.insert(target.opacityAnimationList, opacityAnimation)
                        
                        --石化
                        elseif FightTotemMgr.petrifaction == odd.status.cate then
                            target:filterPetrifaction(oddSet, "gray", time, 0)
                            target:filterPause(oddSet, time)

                        --检测是否有复活状态
                        elseif FightTotemMgr.resurrection == odd.status.cate 
                            and 0xfffff0 ~= target.dearTime 
                            and const.kObjectAdd == oddSet.set_type 
                        then
                            local newOdd = {id=self.const.RESURRECTION, level=1, buffeffect=self.const.RESURRECTION}
                            self:setBodyEffect(target, oddSet, newOdd, target.dearTime)

                        --嘲讽
                        elseif FightTotemMgr.taunt == odd.status.cate then
                            local animationTaunt = FightData.newAnimation()
                            animationTaunt.startTime = time
                            animationTaunt.endTime = time
                            if const.kObjectAdd == oddSet.set_type then
                                animationTaunt.type = 1
                            else
                                animationTaunt.type = 2
                            end
                            table.insert(target.othersAnimationList, animationTaunt)
                        end
                    end

                    if const.kObjectAdd == oddSet.set_type then
                        if FightTotemMgr.oddList[odd.id] and "parseFightSkillObject" == target.state then
                            for __, data in pairs(target.effectAnimationList) do
                                data.endTime = time
                            end
                        end

                        --战斗过程中武将被动技能[不处理受击]
                        -- self:parseFightingPassive(time, target, oddSet, odd)
                    end
                end
            end
        end
    end

    --图腾值更新
    if FightAnimationMgr.camp == targetRole.camp then
        local rageAnimation = FightData.newAnimation()
        rageAnimation.startTime = time
        rageAnimation.endTime = time
        rageAnimation.value = orderTarget.totem_value
        table.insert(targetRole.totemValueAnimationList, rageAnimation)
    end

    --触发源
    for __, triggered in pairs(orderTarget.odd_list_triggered) do
        local odd = findOdd(triggered.odd_id, 1)
        if odd then
            local target = FightRoleMgr:getRole(triggered.use_guid)

            if '' ~= odd.buffeffectname then
                --喊招事件[Buff]
                if target then
                    --喊招事件[Buff]
                    local skillAnimation = FightData:createSkillName(target, time, 2, nil, odd)
                    skillAnimation.val = "buffeffectname"
                    target.deferAnimation(target.skillAnimationList, skillAnimation, 50)

                    if FightTotemMgr.windfury == odd.status.cate then
                        self:setBodyEffect(target, 
                            {guid=target.guid, set_type=const.kObjectAdd, fightOdd={}}, 
                            odd, 
                            time)
                    end  
                end

                --被动技能动作表现
                if 0 ~= triggered.use_guid and orderTarget.guid ~= triggered.use_guid then
                    self:parseRoundPassive(time, triggered, targetRole)
                end
            end
            
            if target then
                --战斗过程中武将被动技能[不处理受击]
                obj.passiveTime = self:parseFightingPassive(time, target, triggered, odd)
            end
        end
    end
    
    --施放方处理怒气
    if role == targetRole and 0 == orderTarget.fight_attr and 0 == orderTarget.fight_result then
        return obj
    end
    
    --受击动作
    if const.kFightDodge == orderTarget.fight_type then
        --已与服务器约定好，一山不能藏二虎  2014.08.25.
        local max = FightFileMgr.getMaxMight(actionEffect)
        local dodgeAnimation = FightData:createDodgeDisplacement(targetRole, ackTime, actionEffect, max, 0)
        table.insert(targetRole.pathAnimationList, dodgeAnimation)
        for i = 1, max, 1 do
            local timeDodge = actionEffect.timeShaftDataList[FightFileMgr:getMight(actionEffect, i) + 2] + ackTime
            local animation = FightData:createSubValueAnimation(orderTarget, targetRole:updateHurtTime(timeDodge))
            targetRole:filterHp(animation)

            --受伤特效处理
            if '' ~= actionEffect.targetEffect then
                local dodgeEffectAnimation = FightData:createTargetEffectAnimation(actionEffect, timeDodge, actionEffect.targetEffect, targetRole)
                targetRole:filterEffect(dodgeEffectAnimation)
            end
        end
		
		local dodgeBackAnimation = FightData:createDodgeDisplacement(targetRole, dodgeAnimation.endTime, nil, nil, 1)
		dodgeBackAnimation.endTime = dodgeBackAnimation.startTime + 50
		table.insert(targetRole.pathAnimationList, dodgeBackAnimation)
		obj.endTime = dodgeBackAnimation.endTime
		
    elseif hurtHp < 0 and role ~= targetRole then
        local bruiseAnimation = FightData:createActionAnimation(targetRole.body:getActionByFlag("bruise"), time)
		
        table.insert(targetRole.actionAnimationList, bruiseAnimation)
        obj.endTime = bruiseAnimation.endTime
		
        if 0 ~= orderTarget.fight_might then
            --振动
            if skill.vibrate then
                local vibrate = string.split(skill.vibrate, '%')
                for __, value in pairs(vibrate) do
                    if tonumber(value) == orderTarget.fight_might then
                        local diskplayAnimation = FightData.newAnimation()
                        diskplayAnimation.startTime = bruiseAnimation.startTime
                        diskplayAnimation.endTime = bruiseAnimation.endTime
                        table.insert(role.diskplayAnimationList, diskplayAnimation)
                        break
                    end
                end
            end
             --振动
            if trans.const.kFightCrit == orderTarget.fight_type then
                local diskplayAnimation = FightData.newAnimation()
                diskplayAnimation.startTime = bruiseAnimation.startTime
                diskplayAnimation.endTime = bruiseAnimation.endTime
                table.insert(role.diskplayAnimationList, diskplayAnimation)
            end
			
            --红屏
            if not targetRole:isMirror() then
                if (const.kFightCrit == orderTarget.fight_type and orderTarget.fight_value >= FightDataMgr.leftHpMax * 0.06)
					or (100 == skill.self_costrage and self.leftPlayerInfo.camp == targetRole.playerInfo.camp)
				then
                    local powerRedAnimation = FightData.newAnimation()
                    powerRedAnimation.startTime = bruiseAnimation.startTime
                    powerRedAnimation.endTime = bruiseAnimation.endTime
                    table.insert(role.powerRedAnimationList, powerRedAnimation)
                end
            end
			
			--白屏
			if skill.flash then
                local flash = string.split(skill.flash, '%')
                for __, value in pairs(flash) do
                    if tonumber(value) == orderTarget.fight_might then
                        local diskplayAnimation = FightData.newAnimation()
                        diskplayAnimation.startTime = bruiseAnimation.startTime
                        diskplayAnimation.endTime = bruiseAnimation.startTime + 50
						
						if mightMax == orderTarget.fight_might then
							diskplayAnimation.endTime = bruiseAnimation.startTime + 80
						end
						
                        table.insert(role.whiteAnimationList, diskplayAnimation)
                        break
                    end
                end
            end
        end
    end
    
	time = obj.endTime
	
    --死亡动作
    obj.dearTime = self:parseDear(fightSoldier, targetRole, time)
    return obj
end

--全体技能特效处理
function __this:parseEffectColony(ackRole, action, actionEffect, time, skill)
    local obj = self.newObject(time)
    local targetRole = nil
    if 1 == skill.target_type then
        targetRole = FightRoleMgr:getByIndex(not ackRole:isMirror(), 4)
    else
        targetRole = FightRoleMgr:getByIndex(ackRole:isMirror(), 4)
    end
    
    if not targetRole or not actionEffect then
        return obj
    end
    
    if '' ~= actionEffect.fireEffect and not FightFileMgr.checkSame(actionEffect.fireEffect) then
        local animation = FightData:createEffectAnimation(actionEffect, FightFileMgr:getTime(actionEffect, "TIME_FIRE_EFFECT", time), actionEffect.fireEffect)
        animation.endTime = animation.startTime + 230
        ackRole:filterEffect(animation)
        obj.endTime = math.max(obj.endTime, animation.endTime)
    end
    
    if '' ~= actionEffect.targetEffect and not FightFileMgr.checkSame(actionEffect.targetEffect) then
        local timeEffect = FightFileMgr:getTime(actionEffect, "TIME_HURT_EFFECT", time)
        local animation = FightData:createTargetEffectAnimation(actionEffect, timeEffect, actionEffect.targetEffect, nil, nil, ackRole)
        animation.proxyFightRole = targetRole
        animation.proxyBody = targetRole.body or ackRole.body
        animation.mirror = targetRole:isMirror()
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
function __this:parseEffect(ackRole, action, actionEffect, log, time, skill, mightMax, confusion, targetEffectFlag)
    local obj = self.newObject(time)
    
    if 6 == skill.target_range_count and 2 == skill.target_range_cond then
        return self:parseEffectColony(ackRole, action, actionEffect, time, skill)
    end
	
	local hurtEffectFixTime = actionEffect.timeShaftDataList[4] - actionEffect.timeShaftDataList[5]
    local intervalList = {}
    local fireSoundFlag, targetSoundFlag = false
    for __, orderTarget in pairs(log.orderTargetList) do
        local flag = false
        for __, oddSet in pairs(orderTarget.odd_list) do
            if const.kObjectAdd == oddSet.set_type then
                flag = true
                break
            end
        end

        if 0 ~= orderTarget.fight_result or flag then
            local targetRole = FightRoleMgr:getRole(orderTarget.guid)
            if targetRole then
                if 1 == skill.target_type and ackRole:isMirror() == targetRole:isMirror() and 0 == confusion then
					--continue
                else
                    local interval = self.parseInterval(skill, log.order.guid, orderTarget.guid, intervalList, orderTarget)

					local timeShaft = FightFileMgr.timeShaft
					local indexTimeShaft = FightFileMgr:getMight(actionEffect, orderTarget.fight_might)
                    local animationFire = FightData:parseFire(time, 
                            ackRole, targetRole, action, actionEffect,
                            interval, indexTimeShaft, fireSoundFlag)
                    if animationFire then
                        obj.endTime = math.max(animationFire.endTime, obj.endTime)
                        fireSoundFlag = true
                    end

                    --受伤特效处理
                    if targetEffectFlag or '' == actionEffect.targetEffect or 0 == orderTarget.fight_might or FightFileMgr.checkSame(actionEffect.targetEffect) then
                        obj.endTime = actionEffect.timeShaftDataList[indexTimeShaft + 3] + obj.endTime
                    else
						local timeEffect = actionEffect.timeShaftDataList[indexTimeShaft + 2] + time + hurtEffectFixTime + math.random(0, 200) + interval
						if animationFire and (not skill or 1 ~= skill.disillusion) and "YS08leikesa" ~= ackRole.body.style then
                            timeEffect = animationFire.endTime
							-- timeEffect = animationFire.endTime + actionEffect.timeShaftDataList[indexTimeShaft + 1] - actionEffect.timeShaftDataList[indexTimeShaft + 2]
						end
                        local animation = FightData:createTargetEffectAnimation(actionEffect, timeEffect, actionEffect.targetEffect, targetRole, nil, ackRole)
                        targetRole:filterEffect(animation)
                        -- table.insert(targetRole.effectAnimationList, animation)
                        obj.endTime = math.max(obj.endTime, actionEffect.timeShaftDataList[indexTimeShaft + 3] + time)

                        --音效
                        if not targetSoundFlag and ackRole.sound then
                            --目标方音效
                            FightData:createSound(ackRole, timeEffect, ackRole.sound:getActionByFlag(skill.action_flag, skill.effect_index, FightFileMgr.sound_enum.TARGET))
                            targetSoundFlag = true
                        end
                    end
                end
            end
        end
    end
    
    return obj
end

--死亡相关处理
function __this:parseDear( soldier, role, time )
    if role:checkAttr(trans.const.kAttrTotem) or (0 ~= soldier.hp and not FightDataMgr.load_fight_log) or role.hp > 0 or 0xfffff0 ~= role.dearTime then
        -- role.dearTime = 0xfffff0
        return time
    end

    --变身后的死亡需要恢复原状
    FightData:createChangeModelAnimation(time, role, role.body.style)

    role.opacityAnimationList = {}
    local opacityAnimation = FightData.newAnimation()
    opacityAnimation.startTime = time
    opacityAnimation.endTime = time
    opacityAnimation.opacity = 255
    table.insert(role.opacityAnimationList, opacityAnimation)
	
	local del = {}
	for i, data in pairs(role.actionAnimationList) do
		if "dead" == data.type then
			table.insert(del, i)
		end
	end
	for i = #del, 1, -1 do
		table.remove(role.actionAnimationList, del[i])
	end

    --检测死亡之前需要回到原位死亡
    -- if #role.pathAnimationList > 0 then
    --     local data = role.pathAnimationList[#role.pathAnimationList]
    --     if time <= data.startTime then
    --         if data.endPT 
    --             and (
    --                 data.endPT.x ~= role.station:x() 
    --                 or data.endPT.y ~= role.station:y()
    --             )
    --         then
    --             local pathData = FightData:setPath(data.endTime, data.endPT, role.station:pos(), role:isMirror(), true)
    --             table.insert(role.pathAnimationList, pathData)
    --             time = pathData.endTime
    --         end
    --     end

    -- elseif role.station:x() ~= role.playerView:getPositionX() or role.station:y() ~= role.playerView:getPositionY() then
    --     local pathData = FightData:setPath(time, 
    --         cc.p(role.playerView:getPositionX(), role.playerView:getPositionY()),
    --         role.station:pos(), role:isMirror(), true)
    --     table.insert(role.pathAnimationList, pathData)
    --     time = pathData.endTime
    -- end
    
    time = role:getLastActionEndTime( time )
    --死亡音效
    if role.sound then
        FightData:createSound(role, time, role.sound:getOtherSound(FightFileMgr.sound_enum.DEAD));
    end

    --死亡动作
    local animation = FightData:createActionAnimation( role.body:getActionByFlag( "dead" ), time )
    role:filterAction(animation)
    role.dearTime = animation.endTime
    role.dearActionStartTime = animation.startTime

    --移除暂停状态
    local oddSet = {guid=role.guid, set_type=const.kObjectDel, fightOdd={}}
    role:filterPause(oddSet, animation.startTime)
    role:filterPetrifaction(oddSet, "gray", animation.startTime, animation.startTime)
                        
    --移除满怒气特效
    self:clearEffect(role, time)

    --释放相关特效
    animation = FightData.newAnimation()
    animation.startTime = role.dearTime + 1000
    animation.endTime = animation.startTime
    table.insert(role.releaseAnimationList, animation)

    --检测是否有复活状态
    if role:isStatus(FightTotemMgr.resurrection) then
        local newOdd = {id=self.const.RESURRECTION, level=1, buffeffect=self.const.RESURRECTION}
        local oddSet = {set_type=const.kObjectAdd}
        self:setBodyEffect(role, oddSet, newOdd, role.dearTime)
    end

    --掉落物品动画事件
    if self.camp ~= role.camp and self.monsterCount > 0 then
        local coins = self:getCoin(role)
        if coins then
            for i, coin in pairs(coins) do
                local _time = time + (i - 1) * 100
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
        
        self.monsterCount = self.monsterCount - 1
    end

	return role.dearTime
end

function __this:getCoin(role)
    if role.monster and FightDataMgr.copy_boss then
        if FightDataMgr.copy_boss_id == role.monster.id then
            return  {table.remove(FightDataMgr.coins, 1)}
        end

        return nil
    end

    local list = FightDataMgr.coins

    --测试代码
    if FightDataMgr.reward_test and not list then
        FightDataMgr.coins = {{cate = const.kCoinMoney, objid = 1, val = 1}, {cate = const.kCoinMoney, objid = 1, val = 1}}
        list = FightDataMgr.coins
    end

    if not list or 0 == #list then
        return nil
    end

    if 1 == self.monsterCount or 1 == #list then
        FightDataMgr.coins = {}
        return list
    end

    --测试代码
    if FightDataMgr.reward_test then
        return {table.remove(list, 1), table.remove(list, 1)}
    end

    local count = 0
    if 0 == math.random(0, 1) then
        if 0 == math.random(0, 1) then
            count = 1
        else
            count = 2
        end
    else
        return nil
    end

    local del = {}
    if count > 0 then
        for i, coin in pairs(list) do
            if const.kCoinItem == coin.cate then
                local item = findItem(coin.objid)
                if item and const.kItemTypeSoulStone ~= item.type then
                    table.insert(del, i)
                end
            else
                table.insert(del, i)
            end

            count = count - 1
            if 0 == count then
                break
            end
        end
    end

    local newList = {}
    for i = #del, 1, -1 do
        table.insert(newList, table.remove(list, del[i]))
    end

    return newList
end

--根据相同的fight_attr的log
function __this.getLogByAttr( log, ... )
    local newLog = FightFileMgr:copyTab(log)
    local args = {...}
	local del = {}
    for i, orderTarget in pairs( newLog.orderTargetList ) do
		local flag = false
        for j, value in pairs(args) do
            if value == orderTarget.fight_attr then
				flag = true
                break
            end
        end
		
		if not flag then
			table.insert(del, i)
		end
    end
	
	for i = #del, 1, -1 do
		table.remove(newLog.orderTargetList, del[i])
	end

    return newLog
end

--反击动作、特效处理
function __this:parseTalentAntiAttack( role, log, time )
    local obj = self.newObject( time )
    local newLog = self.getLogByAttr( log, const.kFightAttrAntiAttack, const.kFightAttrCounter )
    if 0 == #newLog.orderTargetList then
        return obj
    end
    
    local roleRage = nil
    for __, orderTarget in pairs( log.orderTargetList ) do
        if log.order.guid == orderTarget.guid then
            roleRage = orderTarget.rage
            break
        end
    end

    local map = {}
    for __, orderTarget in pairs( newLog.orderTargetList ) do
        local newAckRole = FightRoleMgr:getRole( orderTarget.guid )
        if nil ~= newAckRole then
            local skill = newAckRole:getNormalSkill(1)

            if nil ~= skill then
                local action = newAckRole.body:getActionByFlag( skill.action_flag )

                if nil ~= action then
                    local actionEffect = FightFileMgr:getActionEffect( action, skill.effect_index )

                    if nil ~= actionEffect then
                        if not map[orderTarget.guid] then
                            --反击行为
                            obj = self:setAck(newAckRole,action,actionEffect,skill,time)
                            map[orderTarget.guid] = true
                            local animation = FightData:createSkillName(newAckRole, obj.ackTime, 6)
                            newAckRole.deferAnimation(newAckRole.skillAnimationList, animation, 50)
                        end

                        --原施放方行为
                        local newOrderTarget = 
                        {
                            guid = role.guid,
                            attr = role.fightSoldier.attr,       -- 人物标识 玩家/怪物/宠物
                            rage = roleRage,       -- 当前玩家怒气值
                            hp = orderTarget.hp,     -- 血量
                            fight_might = orderTarget.fight_might,
                            fight_attr = 0,     -- 连击 反击 追击 客户端表现用
                            fight_result = const.kFightDicHP,       -- 战斗结果 扣血 加血等
                            fight_type = const.kFightCommon,     -- 战斗类型 暴击 格挡等
                            fight_value = orderTarget.fight_value,        -- 战斗值
                            totem_value = orderTarget.totem_value,
                            odd_list = orderTarget.odd_list,        -- 当前玩家ODD变更列表
                            odd_list_triggered = orderTarget.odd_list_triggered,      -- 触发的guid和oddid
                        }
                        self:parseTargetRole(newAckRole, actionEffect,role,newOrderTarget,time, 0, skill)

                        --辅助特效、受击特效处理
                        local newAckLog = 
                        {
                            round = log.round,     -- 战斗回合
                            order =      -- 战斗技能
                            {
                                guid = orderTarget.guid,      -- 角色ID
                                order_id = skill.id,       -- 技能ID
                                order_level = skill.level,        -- 等级 
                            },
                            orderTargetList = {newOrderTarget},        -- 战斗结果
                        }
                        self:parseEffect(newAckRole, action, actionEffect, newAckLog, obj.ackTime, skill, 0, 0)
                    end
                end
            end
        end
    end
    
    return obj
end

--连击动作、特效处理
function __this:parseTalentDouleHit(role, skill, log, time)
    local obj = self.newObject(time)
    local newLog = self.getLogByAttr(log,const.kFightAttrDoubleHit)
    if 0 == #newLog.orderTargetList then
        return obj
    end
    
    local skill = role.getNormalSkill()
    if not skill then
        return obj
    end
    local action = role.body:getActionByFlag( skill.action_flag )
    if not action then
        return obj
    end
    
    local actionEffect = FightFileMgr:getActionEffect( action, skill.effect_index )
    if not actionEffect then
        return obj
    end
    
    obj = self:setAck(role,action,actionEffect,skill,FightFileMgr:getTime(actionEffect, "TIME_ACK_ACTION", time))
    for __, orderTarget in pairs(newLog.orderTargetList) do
        local roleHurt = FightRoleMgr:getRole( orderTarget.guid )
        if roleHurt then
            self:parseTargetRole(role, actionEffect,roleHurt,orderTarget,time, 0, skill)
        end
    end
    
    self:parseEffect(role,action,actionEffect,newLog,obj.ackTime, skill)
    return obj
end

--三连击动作、特效处理[模拟两次二连击，故需手动修改fight_attr值为constant.kFightAttrDoubleHit]
function __this:parseTalentTripleHit(role, skill, log, time)
    local obj = self.newObject(time)
    local newLog = self.getLogByAttr(log,const.kFightAttrTripleHit)
    if 0 == #newLog.orderTargetList or 2 ~= newlog.orderTargetList then
        return obj
    end
    
    table.remove(newLog.orderTargetList,2)
    
    local newLog2 = self.getLogByAttr(log,const.kFightAttrTripleHit)
    table.remove(newLog2.orderTargetList,1)
    
    for __, orderTarget in pairs(newLog.orderTargetList) do
        orderTarget.fight_attr = const.kFightAttrDoubleHit
    end
    for __, orderTarget in pairs(newLog2.orderTargetList) do
        orderTarget.fight_attr = const.kFightAttrDoubleHit
    end
    obj = self:parseTalentDouleHit(role,skill,newLog,time)
    obj = self:parseTalentDouleHit(role,skill,newLog2,obj.endTime)
    
    return obj
end

--非闪避状态下的闪红[只限于左阵营的主将]
function __this:parseRed( role, actionEffect, time, objHurt, log, skill, bombEnable )
    if role then
        return
    end
    
    if not objHurt then
        return
    end
    
    local selfRole = nil
    local countLeft = 0
    local countRight = 0
    local bombFlag = false
    for __, orderTarget in pairs( log.orderTargetList ) do
        if const.kFightDicHP == orderTarget.fight_result then
            local hurtRole = FightRoleMgr:getRole( orderTarget.guid )
            if hurtRole then
                if not selfRole and const.kFightPlayer == orderTarget.attr and User.Instance().RoleId == orderTarget.guid then
                    selfRole = hurtRole
                end
                
                if false == hurtRole.station.isMorror then
                    countLeft = countLeft + 1
                else
                    countRight = countRight + 1
                end
                
                if true == hurtRole:checkOdd( const.kFightOddBomb ) then
                    bombFlag = true
                end
            end
        end
    end
    
    if 0 == countLeft and 0 == countRight then
        return
    end
    
    if true == bombEnable and true == bombFlag and false == role:checkOdd( const.kFightOddSneak ) then
        return
    end
    
    local animation = FightData:newAnimation()
    animation.startTime = objHurt.actionStartTime
    animation.endTime = objHurt.actionStartTime + FightFileMgr:getHurtActionLongTime( actionEffect )
    
    if nil ~= selfRole then
        if 100 == skil.self_costrage or selfRole.newHp < FigthDataMgr.selfHpMax * 0.25 then
            table.insert( selfRole.powerRedAnimationList, animation )
            return
        end
    end
    
    if countLeft > 0 or countRight > 0 then
        table.insert( selfRole.powerRedAnimationList, animation )
    end
end

--抖屏处理
function __this:parseDisplay( time, role, actionEffect, log, skill )
    local animation = FightData:newAnimation()
    animation.startTime = time
    animation.endTime = time + FightFileMgr:getHurtActionLongTime( actionEffect )
    
end

--偷袭处理
function __this:parseSneak(startTime, endTime, role, log)
    local obj = self.newObject(time)
    if not role:checkOdd(const.kFightOddSneak) then
        return obj
    end
    
    local flag = false
    for __, orderTarget in pairs(log.orderTargetList) do
        if role.guid ~= orderTarget.guid then
            local hurtRole = FightRoleMgr:getRole(orderTarget.guid)
            if hurtRole then
                if hurtRole:checkOdd(const.kFightOddBomb) then
                    flag = true
                    break
                end
            end
        end
    end
    
    if not flag then
        return obj
    end
    
    local animation = FightData.newAnimation()
    animation.startTime = startTime
    animation.endTime = endTime + 200
    animation.alphaList = {}
    for i = 0, i < 20, 1 do
        table.insert( animation.alphaList, 0.5 )
    end
    for i = 0, i < 20, 1 do
        table.insert( animation.alphaList, 1 )
    end
    table.insert(role.pathAnimationList, animation)
    
    return obj
end

--爆炸处理
function __this:parseTalentBomb(srcStartTime, time, role, log)
    local obj = self.newObject(time)
end

--追击处理
function __this:parseTalentPursuit(role, action, skill, log, time, objAck)
    local obj = self.newObject(time)
    local newLog = self.getLogByAttr(log,const.kFightAttrPursuit)
    if 0 == #newLog.orderTargetList then
        return obj
    end
    
    local newSkill = role.getNormalSkill()
    if not newSkill then
        return obj
    end
    
    local newAction = role.body:getActionByFlag(newSkill.action_flag)
    if not newAction then
        return obj
    end
    
    local actionEffect = FightFileMgr:getActionEffect(newAction, newSkill.effect_index)
    if not actionEffect then
        return obj
    end
    
    obj = self:parseAckRole(role, newAction, actionEffect, newLog, time, skill)
    --移动特殊处理[判断原动作是否为近身]
    if 1 == action.attribute and #role.pathAnimationList >= 2 then
        local fron = role.pathAnimationList[#role.pathAnimationList - 1]
        local path = role.pathAnimationList[#role.pathAnimationList]
        local length = #fron.pathList
        local count = length / 2;
        for i = 1, count, 1 do
            path.pathList[i] = fron.pathList[count + 1]
        end
        for i = count + 1, length, 1 do
            path.pathList[i] = path.pathList[length]
        end
        
        local back = objAck.pathAnimation
        for i = 1, count, 1 do
            back.pathList[i] = path.pathList[count + 1]
        end
    --判断新动作是否为近身
    elseif 1 == newAction.attribute then
        objAck.backAnimation = obj.backAnimation
        objAck.pathAnimation = obj.pathAnimation
    end
    --受击方处理
    local objHurt = self.newObject(time)
    for __, orderTarget in pairs(newLog.orderTargetList) do
        local hurtRole = FightRoleMgr:getRole( orderTarget.guid )
        if hurtRole then
            objHurt = self:parseTargetRole(role,actionEffect,hurtRole,orderTarget,obj.ackTime, 0, newSkill)
            orderTarget.fight_attr = 0
        end
    end
    --辅助特效、受击特效处理
    self:parseEffect(role,newAction,actionEffect,newLog,obj.ackTime, newSkill)
    obj.endTime = math.max(objHurt.endTime, obj.endTime)
    
    return obj
end

--反震处理器
function __this:parseTalentAttactReboundPer( role, log, time )
    local obj = self.newObject(time)
    local newLog = self.getLogByAttr(log,const.kFightAttrAttackReboundPer)
    if 0 == #newLog.orderTargetList then
        return obj
    end
    
    local newAckRole = nil
    for __, orderTarget in paris( newLog.orderTargetList ) do
        newAckRole = FightRoleMgr:getRole( orderTarget.guid )
        if nil ~= newAckRole then
            break
        end
    end
    
    if nil == newAckRole then
        return obj
    end
    
    local action = newAckRole.body:getActionByFlag( 'physical1' )
    if nil == action then
        return obj
    end
    
    local skill = newAckRole.getNormalSkill()
    if not skill then
        return obj
    end
    
    local actionEffect = FightFileMgr:getActionEffect( action, 0 )
    if not actionEffect then
        return obj
    end
    
    for __, orderTarget in pairs( newLog.orderTargetList ) do
        obj = self:parseTargetRole(newAckRole, actionEffect, role,orderTarget,time, 0, skill)
    end
    
    self:parseEffect(newAckRole,action,actionEffect,newLog,time, skill)
    return obj
end

--神佑、假死处理
function __this:parseTalentRevive(role, actionEffect, log, time)
    local obj = self.newObject(time)
    local newLog = self.getLogByAttr(log,const.kFightAttrDeadCall)
    if 0 == #newLog.orderTargetList then
        return obj
    end
    
    for __, orderTarget in pairs(newLog.orderTargetList) do
        local hurtRole = FightRoleMgr:getRole(orderTarget.guid)
        if hurtRole then
            -- if 0xfffff0 ~= hurtRole.dearTime then
                local animation = FightData.newAnimation()
                animation.startTime = hurtRole.dearTime
                animation.endTime = hurtRole.dearTime
                animation.dearTime = 0xfffff0
                animation.dearActionStartTime = 0xfffff0
                table.insert(hurtRole.pathAnimationList, animation)
                hurtRole.dearAnimationList = {}

                local effect = FightFileMgr:getEffect(self.const.CALL_EFFECTID)
                if effect then
                    local newOdd = {id = self.const.CALL_EFFECTID, level = 1, onceeffect = self.const.CALL_EFFECTID}
                    local oddSet = {set_type = trans.const.kObjectAdd}
                    local animation = FightData:createBodyAnimation( time, oddSet, newOdd, effect, hurtRole )
                    animation.role = hurtRole
                    hurtRole:filterBodyEffectAdd(animation)
                end
                
                --[[animation = FightData:createActionAnimation(hurtRole.body:getActionByFlag( "stand" ), time)
                hurtRole:filterAction(animation)
				hurtRole:filterAction(animation)--]]
                hurtRole.dearTime = 0xfffff0
                hurtRole.dearActionStartTime = 0xfffff0
            -- end
            obj = self:parseTargetRole(role,actionEffect,hurtRole,orderTarget,time, 0)
        end
    end

    return obj
end

--自爆处理
function __this:parseTalentMeBomb(role, log)

end

function __this:parseRedHurt(time, log, actionEffect)
	local list = {}
	local animation = FightData.newAnimation()
    animation.attr = "paint"
	animation.startTime = time + actionEffect.timeShaftDataList[5]
	animation.endTime = time + actionEffect.timeShaftDataList[FightFileMgr:getMight(actionEffect, 99) + 3]
	for __, orderTarget in pairs(log.orderTargetList) do
		if 0 ~= orderTarget.fight_might and const.kFightAddHP ~= orderTarget.fight_result then
			local role = FightRoleMgr:getRole(orderTarget.guid)
			if role then
				local flag = false
				for __, target in pairs(list) do
					if target == role then
						flag = true
					end
				end
				if not flag then
					table.insert(role.filtersAnimationList, animation)
				end
			end
		end
	end
end

--变换阵营[由于战斗系统架构设计问题此功能只允许在第零回合进行    涛--2012.12.12.]
function __this:parseFightChange(time, role, orderTarget, obj)
    if const.kFightChange ~= orderTarget.fight_result then
        return obj
    end

    local roleTarget = FightRoleMgr:getByIndex( not role:isMirror(), orderTarget.fight_value )
    if nil == roleTarget then
        return obj
    end

    roleTarget:cloneFrom( role )
    role.clear()

    --[[
    UIFightWindow.Instance().InIntFightRole( hurtRole ),
    UIFightWindow.Instance().InIntFightRole( targetRole ),
    
    //添加心灵控制特效
    fightOddSet = new SFightOddSet,
    fightOddSet.odd_set_type = constant.kObjectAdd,
    odd = new JOdd,
    odd.buffeffect.Value1 = HEART_EFFECTID,
    odd.buffeffect.Value2 = HEART_EFFECTID,
    setBodyEffect( targetRole, fightOddSet, odd, time ),
    --]]
    
    obj.endTime = time + 200
    return obj
end

--解释十字军试炼总量事件
function __this:parseFightEndInfo(time)
    local animation = FightData.newAnimation()
    animation.startTime = time
    animation.endTime = time
    animation.endInfo = FightDataMgr.theFight:getFightEndInfo()

    table.insert(FightDataMgr.trialEndInfoAnimationList, animation)
end

--检测指令是否为buff指令 [每回合动画开始之前的处理，例如每回合加状态]
function __this:parseOdd(time, role, orderTarget)
    local obj = self.newObject(time)
    obj.dearTime = time
    if nil == role then
        return obj
    end
    
    --变换阵营
    --[[obj = self:parseFightChange(time, role, orderTarget, obj)
    if time ~= obj.endTime then 
        return obj
    end--]]
    
    obj = self.newObject(time)
    --当前参战人员于服务器的数据
    local fightSoldier = FightDataMgr.theFight:findSoldier( orderTarget.guid )
    if not fightSoldier then
        LogMgr.log( 'FightDataMgr', "%s", "parseOdd not fightSoldier")
        return obj
    end
    
    local startTime = time
    --异常处理
    for __, oddSet in pairs(orderTarget.odd_list) do
        local odd = findOdd( oddSet.fightOdd.id, oddSet.fightOdd.level )
        if nil ~= odd then
            table.insert( role.oddAnimationList, FightData:createOddAnimation( oddSet, odd, startTime ) )
            
            --被动技能动作表现
            if const.kObjectAdd == oddSet.set_type and 0 ~= oddSet.fightOdd.use_guid and orderTarget.guid ~= oddSet.fightOdd.use_guid then
                local totemRole = FightRoleMgr:getRole(oddSet.fightOdd.use_guid)
                if totemRole and totemRole:checkAttr(trans.const.kAttrTotem) and '' ~= totemRole.totem.passive_act then
                    local totemAckAction = totemRole.body:getActionByFlag( totemRole.totem.passive_act )
                    if totemAckAction then
                        local totemActionEffect = FightFileMgr:getActionEffect( totemAckAction, 0 )
                        if totemActionEffect and totemActionEffect.timeShaftDataList[5] then
                            local objAck = self:parseAckRole(totemRole, totemAckAction, totemActionEffect, nil, startTime)

                            time = math.max(totemActionEffect.timeShaftDataList[5] + startTime, time)

                            if '' ~= totemActionEffect.targetEffect then
                                role:filterEffect(FightData:createTargetEffectAnimation(totemActionEffect, totemActionEffect.timeShaftDataList[5] + startTime, totemActionEffect.targetEffect, role))
                            end
                        end
                    end
                end
            end

            local target = FightRoleMgr:getRole(oddSet.guid)
            if target then
                if const.kObjectDel == oddSet.set_type then
                    if FightTotemMgr.resurrection == oddSet.fightOdd.status_id then
                        role:setOdd(oddSet)
                        local newOdd = {id=self.const.RESURRECTION, level=1, buffeffect=self.const.RESURRECTION}
                        self:setBodyEffect(role, oddSet, newOdd, startTime)
                    end
                end

                if const.kObjectUpdate ~= oddSet.set_type then
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
                                self:setBodyEffect(o, oddSet, odd, startTime)
                                break
                            end
                        end
                    else
                        local __time = 0
                        if 1130 == odd.id then
                            __time = -1000
                        end

                        self:setBodyEffect(target, oddSet, odd, startTime + __time)
                    end

                    if FightTotemMgr.sheep == odd.status.cate then
                        if const.kObjectAdd == oddSet.set_type then
                            FightData:createChangeModelAnimation(time, target, "XG20yang")
                        else
                            FightData:createChangeModelAnimation(time, target, target.body.style)
                        end

                    elseif FightTotemMgr.frog == odd.status.cate then
                        if const.kObjectAdd == oddSet.set_type then
                            FightData:createChangeModelAnimation(time, target, "XG21qingwa")
                        else
                            FightData:createChangeModelAnimation(time, target, target.body.style)
                        end

                    -- elseif FightTotemMgr.hurricane == odd.status.cate then
                    --     local opacityAnimation = FightData.newAnimation()
                    --     opacityAnimation.startTime = time
                    --     opacityAnimation.endTime = time + 255
                    --     opacityAnimation.odd = odd
                    --     if const.kObjectAdd == oddSet.set_type then
                    --         opacityAnimation.opacity = 0
                    --     else
                    --         opacityAnimation.opacity = 255
                    --     end
                    --     table.insert(target.opacityAnimationList, opacityAnimation)
                    
                    elseif FightTotemMgr.sneak == odd.status.cate then
                        local opacityAnimation = FightData.newAnimation()
                        opacityAnimation.odd = odd
                        opacityAnimation.startTime = 0
                        opacityAnimation.endTime = 0
                        opacityAnimation.opacity = 255

                        table.insert(role.opacityAnimationList, opacityAnimation)
                    
                    elseif FightTotemMgr.petrifaction == odd.status.cate then
                        role:filterPetrifaction(oddSet, "gray", time, 0)
                        role:filterPause(oddSet, time)

                    --嘲讽
                    elseif FightTotemMgr.taunt == odd.status.cate then
                        local animationTaunt = FightData.newAnimation()
                        animationTaunt.startTime = time
                        animationTaunt.endTime = time
                        if const.kObjectAdd == oddSet.set_type then
                            animationTaunt.type = 1
                        else
                            animationTaunt.type = 2
                        end
                        table.insert(role.othersAnimationList, animationTaunt)
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
                target.deferAnimation(target.skillAnimationList, skillAnimation, 50)
            end
        end
    end

    local totemTime, actionTime = time
    if 0 ~= orderTarget.odd_id then
        totemTime, actionTime = self:parseRoundPassive(time, {use_guid = orderTarget.guid, odd_id = orderTarget.odd_id}, role)
        obj.endTime = actionTime
    end
    -- self:parseHpValue(time,role,orderTarget)
	
	--受击数字动画
    local hurtHp = 0
    if 0 ~= orderTarget.fight_result and actionTime then
        local animation = FightData:createSubValueAnimation(orderTarget, actionTime)
        animation.odd_id = orderTarget.odd_id
        animation.rage = orderTarget.rage
        if
            0 == orderTarget.fight_value 
            and const.kFightAddHP ~= orderTarget.fight_result 
            and const.kFightDodge ~= orderTarget.fight_type
            --and (role:checkOdd(const.kFightOddInvincible) or role:checkOdd(const.kFightOddDef) or role:checkOdd(const.kFightOddDefFixed)) 
		then --完全吸收表现处理
            animation.fight_value = 0
        else
            hurtHp = orderTarget.fight_value
            if const.kFightDicHP == orderTarget.fight_result then
                hurtHp = hurtHp * -1
            end
            
            -- self:addHpEffect(targetRole, actionEffect, orderTarget, animation.startTime)
            role:setHp(hurtHp)
        end
        
		table.insert(role.hpAnimationList, animation)
        time = actionTime
    end
    
    -- --在此添加满怒气的特效
    -- if fightSoldier.hp > 0 then
    --     self:rageEffect( role, fightSoldier, animation, animation.startTime )
    -- end
    
    --添加召唤小怪特效
    if const.kFightAttrCall == orderTarget.fight_attr then
		time = FightData:createCallAnimation(time, orderTarget, role, 2)
        obj.endTime = time
    --添加复活特效
    elseif const.kFightAttrRevive == orderTarget.fight_attr then
        role.dearTime = 0xfffff0
        role.dearActionStartTime = 0xfffff0

        local l = string.split(self.const.REVIVE_EFFECTID, '%')
        local effect = FightFileMgr:getEffect(l[1])
        if effect then
            --复活特效
            local odd = {id = self.const.REVIVE_EFFECTID, level = 1, onceeffect = self.const.REVIVE_EFFECTID}
            local oddSet = {set_type = trans.const.kObjectAdd}
            self:setBodyEffect(role, oddSet, odd, time)
            
            if #l >= 2 then
                local effectItem = effect:getEffectByFlag(l[2])
                obj.endTime = time + effectItem.count * 25
            end
        end

        local newOdd = {id=self.const.RESURRECTION, level=1, buffeffect=self.const.RESURRECTION}
        local oddSet = {set_type=const.kObjectDel}
        self:setBodyEffect(role, oddSet, newOdd, time)
    end
    
    obj.dearTime = self:parseDear( fightSoldier, role, obj.endTime )
    obj.endTime = math.max(obj.endTime, totemTime)
    return obj
end

--每回合被动技能表现处理
function __this:parseRoundPassive(time, s2, role)
    local targetRole = FightRoleMgr:getRole(s2.use_guid) 
    if not targetRole then
        return time, time
    end

    local totemList = FightRoleMgr:getSoldierList(nil, const.kAttrTotem)
    local maxTime = time
    local actionTime = time
    -- local soldierList = FightRoleMgr:getAllSoldier()
    for __, totemRole in pairs(totemList) do 
        if totemRole.totemOdd and '' ~= totemRole.totem.passive_act then
            local totemAckAction = totemRole.body:getActionByFlag( totemRole.totem.passive_act )
            if totemAckAction then
                local totemActionEffect = FightFileMgr:getActionEffect( totemAckAction, 0 )
                if totemActionEffect then

                    if s2.odd_id == totemRole.totemAttr.formation_add_attr.first then
                        --施放相关绑定在图腾时间轴
                        self:parseAckRole(totemRole, totemAckAction, totemActionEffect, nil, math.floor(FightDataMgr.totemTime * 1000))

                        --辅助特效绑定在图腾时间轴
                        FightData:parseFireTotem(math.floor(FightDataMgr.totemTime * 1000), time, totemRole, targetRole, 
                            totemAckAction, totemActionEffect, 0, 3)

                        if '' ~= totemActionEffect.targetEffect then
                            role:filterEffect(FightData:createTargetEffectAnimation(totemActionEffect, totemActionEffect.timeShaftDataList[5] + time, totemActionEffect.targetEffect, targetRole))
                            --音效
                            if totemRole.sound then
                                --目标方音效
                                FightData:createSound(totemRole, 
                                    totemActionEffect.timeShaftDataList[5] + math.floor(FightDataMgr.totemTime * 1000), 
                                    totemRole.sound:getActionByFlag(totemAckAction.flag, 0, FightFileMgr.sound_enum.TARGET));
                            end
                        end

                        maxTime = math.max(totemActionEffect.timeShaftDataList[6] + time, maxTime)
                        actionTime = math.max(totemActionEffect.timeShaftDataList[5] + time, actionTime)
                    end
                end
            end

        end
    end

    return maxTime, actionTime
end

--检测指令是否为buff指令 [每回合动画开始之前的处理，例如每回合加状态]
function __this:checkOrder( time, log )
    if 0 ~= log.order.guid then
        return time
    end
    
    local obj = self.newObject( time )
	local maxTime = time
    local startTime = maxTime

    local endFlag = false
    
    for i, orderTarget in pairs( log.orderTargetList ) do
        obj = self:parseOdd( startTime, FightRoleMgr:getRole( orderTarget.guid ), orderTarget )
        maxTime = math.max(maxTime, startTime, obj.endTime, obj.dearTime)
    end
    
    return maxTime
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

--近身攻击时预出手与出手技能不符的兼容处理
function __this:compatibleSoldierSkill(time, role, obj)
    if not obj.pathAnimation  then
        return time
    end

    obj.pathAnimation.startTime = time
    obj.pathAnimation.endTime = time + 300
    table.insert(role.pathAnimationList, obj.pathAnimation)
    
    if obj.mirrorAnimation then
        obj.mirrorAnimation.startTime = time + ((obj.pathAnimation.endTime - obj.pathAnimation.startTime) / 2)
        obj.mirrorAnimation.endTime = obj.pathAnimation.endTime
        table.insert(role.mirrorAnimationList, obj.mirrorAnimation)
    end

    return time + 300
end

--解释技能间隔打击时间差
function __this.parseInterval(skill, ack, guid, list, orderTarget)
    if ack == guid or '' == skill.interval or 0 == skill.interval or 0 == orderTarget.fight_result then
        return 0
    end

    -- for i, v in pairs(list) do
    --     if guid == v then
    --         return (i - 1) * skill.interval
    --     end
    -- end

    table.insert(list, guid)
    return (#list - 1) * skill.interval
end

--图腾值更新 [迁移至parselog前优化处理]
-- function __this:parseTotemValue(log, time)
--     for __, orderTarget in pairs(log.orderTargetList) do
--         local role = FightRoleMgr:getRole(orderTarget.guid)
--         if role and role.camp == self.camp then
--             local rageAnimation = FightData.newAnimation()
--             rageAnimation.startTime = time
--             rageAnimation.endTime = time
--             rageAnimation.value = orderTarget.totem_value
--             table.insert(role.totemValueAnimationList, rageAnimation)
--         end
--     end
-- end

--修复眩晕时的坐标
function __this.fixDizziness(time, log)
    for __, orderTarget in pairs(log.orderTargetList) do
        for __, oddSet in pairs(orderTarget.odd_list) do
            local odd = findOdd(oddSet.fightOdd.id, oddSet.fightOdd.level)
            if  FightTotemMgr.dizziness == odd.status.cate then
                if oddSet.set_type ~= const.kObjectDel then
                    local target = FightRoleMgr:getRole(oddSet.guid)
                    if target then
                        table.insert(target.pathAnimationList, FightData:createPathOffsetAnimation(time + 500, target, target.station:pos()))
                    end
                end
            end
        end
    end
end

--解释击杀对方时增加的图腾值
function __this:parseKillTarget(time, role, log)
    if role:isMirror() or 0 == self.leftTotemCount then
        return time
    end

    local newLog = self.getLogByAttr(log, const.kFightAttrTotemValueShow)
    if 0 == #newLog.orderTargetList then
        return time
    end

    local target = nil
    local totem_value = self.leftTotemValue
    for __, orderTarget in pairs(log.orderTargetList) do
        if const.kFightAttrTotemValueShow == orderTarget.fight_attr then
            if target then
                target.deferAnimation(target.skillAnimationList, FightData:createSkillName(role, time, 5, nil, nil, nil, nil, "图腾能量+" .. math.floor(orderTarget.fight_value / 10)), 50)
            end
            break
        end
        totem_value = orderTarget.totem_value
        target = FightRoleMgr:getRole(orderTarget.guid)
    end

    return time
end

--完整处理
function __this:parseLog( time, log, objRoundSoldier--[[施放方]] )
    local obj = self.newObject( time )
    
    local checkOrderTime = self:checkOrder( time, log )
    if checkOrderTime > time or 0 == log.order.guid then
        return checkOrderTime
    end
    
    local soldier = FightDataMgr.theFight:findSoldier(log.order.guid)
    if not soldier then
		LogMgr.log( 'FightDataMgr', "%s", "parseLog:findSoldier not" .. log.order.guid )
        return obj.endTime
    end
    
    local role = FightRoleMgr:getRole( log.order.guid )
    if nil == role then
		LogMgr.log( 'FightDataMgr', "%s", "parseLog:getRole not" .. log.order.guid )
        return obj.endTime
    end 

    --图腾技能处理
    if role:checkAttr(const.kAttrTotem) then
        FightTotemMgr:parseTotem(math.floor(FightDataMgr.totemTime * 1000), role, {log})
        
        return time + 100
    end
    
    local skill = findSkill(log.order.order_id, log.order.order_level)
    if nil == skill then
		LogMgr.log( 'FightDataMgr', "%s", "parseLog:findSkill not" .. log.order.order_id, log.order.order_level )
        return obj.endTime
    end

    local action = role.body:getActionByFlag( skill.action_flag )
    if nil == action then
		LogMgr.log( 'FightDataMgr', "%s", "parseLog:getActionByFlag not" .. skill.action_flag )
        return obj.endTime
    end
    
    local actionEffect = FightFileMgr:getActionEffect( action, skill.effect_index )
    if nil == actionEffect then
		LogMgr.log( 'FightDataMgr', "%s", "parseLog getActionEffect not" .. skill.effect_index )
        return obj.endTime
    end

    --右阵营觉醒技能锁上
    if 1 == skill.disillusion --[[and role:isMirror()]] and not FightDataMgr.order_list then
        local animation = FightData.newAnimation()
        animation.startTime = time
        animation.endTime = time
        animation.attr = 1
        table.insert(FightDataMgr.othersAnimationList, animation)
    end
    
	local sceneAnimation = FightData.newAnimation()
	
    local objHurt = self.newObject( time )
    local objAck = objRoundSoldier
    --近身攻击时预出手与出手技能不符的兼容处理
    if objAck then
        if objAck.pathAnimation 
            and log.order.order_id ~= self.fightSkillObject.order.order_id 
            and role.guid == self.fightSkillObject.order.guid 
        then
            time = self:compatibleSoldierSkill(time, role, objAck)
            objHurt = self.newObject(time)
            objRoundSoldier = nil
        end

        if objAck.order_guid ~= log.order.guid then
            objRoundSoldier = nil
        end
    end

    if not objRoundSoldier then
        objAck = self:parseAckRole(role, action, actionEffect, log, time, skill)
    else
        objAck = objRoundSoldier
        time = objAck.idleTime or objAck.startTime
    end
    sceneAnimation.startTime = objAck.ackTime

    --图腾值更新
    -- self:parseTotemValue(log, time)
    
    local intervalList = {}
    local newLog = self.getLogByAttr(
        log, 
        0, 
        const.kFightAttrConfusion, 
        const.kFightAttrNoDisillusion,
        const.kFightAttrRebound
    )
	local mightMax = self.getMightMax(newLog)
	local currentMight = mightMax
    --死亡时间
    local dearMaxTime = objAck.ackTime
    --武将被动技能时间
    local passiveMainTime = objAck.ackTime
    for __, orderTarget in pairs( newLog.orderTargetList ) do
        local targetRole = FightRoleMgr:getRole( orderTarget.guid )
        if nil ~= targetRole then
            -- if 0 ~= orderTarget.fight_result --[[and 1 == skill.target_type and role:isMirror() == targetRole:isMirror()]] then
				--do something
			-- else
                local interval = self.parseInterval(skill, newLog.order.guid, orderTarget.guid, intervalList, orderTarget)
                objHurt = self:parseTargetRole(role, actionEffect, targetRole, orderTarget, objAck.ackTime + interval, currentMight, skill)
                dearMaxTime = math.max(dearMaxTime, objHurt.dearTime)
                passiveMainTime = math.max(passiveMainTime, objHurt.passiveTime)
            -- end
        end
    end
    
    local objEffect = self:parseEffect(role, action, actionEffect, newLog, objAck.ackTime, skill, mightMax, 0)
	
	--创建受击红色滤镜事件
	self:parseRedHurt(objAck.ackTime, log, actionEffect)
    
    --抖屏处理
    self:parseDisplay( FightFileMgr:getTime( actionEffect, "TIME_HURT_ACTION_START", time ), role, actionEffect, newLog, skill)
    
    --红屏处理[已移至parseTargetRole]
    --self:parseRed( role, actionEffect, time, objHurt, newLog, skill, true )
    
    --解释十字军试炼总量事件
    self:parseFightEndInfo(objAck.ackTime)

    local fixTime = math.max( objAck.endTime, objHurt.endTime )
    --反击处理
    local objTalent = self:parseTalentAntiAttack(role, log, fixTime)
    --[[--反震处理
    objTalent = self:parseTalentAttactReboundPer( role, log, objTalent.endTime )
    --连击处理
    objTalent = self:parseTalentDouleHit(role, skill, log, objTalent.endTime)
    --三连击处理
    objTalent = self:parseTalentTripleHit(role, skill, log, objTalent.endTime)
    --追击处理
    objTalent = self:parseTalentPursuit(role, action, skill, log, objTalent.endTime, objAck)
    --爆炸处理
    --objTalent = self:parseTalentBomb(time, objTalent.endTime, role, newLog)]]
    --神佑、假死处理
    objTalent = self:parseTalentRevive(role, actionEffect, log, objTalent.endTime)
    --自爆处理
    --[[self:parseTalentMeBomb(role, log)--]]
	
    --[[小马要求暂时屏蔽    2014.09.26
	if 100 == skill.self_costrage then
		sceneAnimation.endTime = objTalent.endTime
		table.insert(role.sceneBlackAnimationList, sceneAnimation)
	end]]
	
    if objAck.pathAnimation and not role:checkAttr(trans.const.kAttrTotem) then
        objAck.pathAnimation.startTime = objTalent.endTime
        objAck.pathAnimation.endTime = objTalent.endTime + 300
        table.insert(role.pathAnimationList, objAck.pathAnimation)
        
        if objAck.mirrorAnimation then
            objAck.mirrorAnimation.startTime = objTalent.endTime + ((objAck.pathAnimation.endTime - objAck.pathAnimation.startTime) / 2)
            objAck.mirrorAnimation.endTime = objAck.pathAnimation.endTime
            table.insert(role.mirrorAnimationList, objAck.mirrorAnimation)
        end
        
        objAck.endTime = objAck.pathAnimation.endTime
        objTalent.endTime = objAck.endTime
        
        --非怪物死亡站位修正
        if 0xfffff0 ~= role.dearTime then
            table.remove(role.actionAnimationList,#role.actionAnimationList - 1)
            role.dearTime = 0xfffff0
            role.dearActionStartTime = 0xfffff0
            self:parseDear(soldier, role, objAck.endTime)
        end
    end
    
    --偷袭处理
    self:parseSneak(time, objTalent.endTime, role, log)
	--变身处理
	objTalent = self:parseAttrChange(objTalent.endTime, role, log, objTalent)
    
    local endTime = math.max(passiveMainTime, objTalent.endTime)
    if true == FightDataMgr.theFight:checkEnd() or FightDataMgr.theFight.round > 30 then
        endTime = math.max(objTalent.endTime, dearMaxTime)
    end

    --修复眩晕时的坐标
    self.fixDizziness(time, log)

    --解释击杀对方时增加的图腾值
    self:parseKillTarget(objAck.endTime, role, log)

    --右阵营觉醒技能解锁
    if 1 == skill.disillusion --[[and role:isMirror()]] and not FightDataMgr.order_list then
        local animation = FightData.newAnimation()
        animation.startTime = endTime
        animation.endTime = endTime
        animation.attr = 2
        table.insert(FightDataMgr.othersAnimationList, animation)
    end

    role.state = "parselog"
    return endTime, role
end

--下一波怪物出现
function __this:parseRoundEnd(time, log)
    local obj = self.newObject(time)
    if trans.const.kFightRoundEnd ~= log.order.order_id or true == FightDataMgr.theFight:checkEnd() or 0 == FightDataMgr.round then
        return obj
    end

    if #FightDataMgr.fight_info_list < self.info_index then
        return obj
    end

    local user = FightDataMgr.fight_info_list[self.info_index]
    self.info_index = self.info_index + 1
    local mirror = false
    if user.camp ~= self.leftPlayerInfo.camp then
        mirror = true
    end
    local effect = FightFileMgr:getEffect(self.const.CALL_EFFECTID)
    if not effect then
        return obj
    end

    local list = FightRoleMgr:getSoldierList(self.leftPlayerInfo.camp, const.kAttrSoldier)
    if 0 == #list then
        list = FightRoleMgr:getSoldierList(self.leftPlayerInfo.camp, const.kAttrMonster)
        if 0 == #list then
            return obj
        end
    end

    local role = list[1]
    local animation = FightData.newAnimation()
    animation.startTime = time
    animation.endTime = animation.startTime
    animation.call = {}
    animation.isMirror = mirror
    animation.user = user
    animation.attr = 2
    table.insert(role.callChangeAnimationList, animation)
    for __, soldier in pairs(user.soldier_list) do
        -- table.insert(animation.call, soldier)
        local newRole = FightRoleMgr:getByIndex(mirror, soldier.fight_index)
        if newRole then
            newRole:attrCall(FightDataMgr:getLayerRole(), time, user, soldier)
        end
    end

    obj.endTime = obj.startTime + 1500
    obj.pathTime = obj.endTime
    return obj
end

--预处理施放方动画
function __this:parseFightSkillObject(time, log)
    self.fightSkillObject = log

    local obj = self.newObject(time)
    obj.order_guid = log.order.guid
    if 0 == log.order.guid or table.empty(log.targetList) then
        --4:全体非战斗状态角色降一半帧频事件[UnJumpFrame]
        local lockAnimation = FightData.newAnimation()
        lockAnimation.startTime = time
        lockAnimation.endTime = time
        lockAnimation.attr = 4
        table.insert(FightDataMgr.othersAnimationList, lockAnimation)
        
       return self:parseRoundEnd(time, log)
    end
    
    local role = FightRoleMgr:getRole(log.order.guid)
    --图腾不作预处理
    if not role or role:checkAttr(const.kAttrTotem) then
        return obj
    end

    --副本剧情触发
    self:copyGut(log)
    local skill = findSkill(log.order.order_id, log.order.order_level)
    if not skill then
        return obj
    end
    ActionMgr.save("fight", role.fightSoldier.name .. " skillid:" .. log.order.order_id .. "skilllevel:" ..  log.order.order_level)
    
    local action = role.body:getActionByFlag(skill.action_flag)
    if not action then
        return obj
    end
    
    local actionEffect = FightFileMgr:getActionEffect(action, skill.effect_index)
    if not actionEffect then
        return obj
    end

    --右阵营觉醒技能锁上
    if 1 == skill.disillusion and role:isMirror() and not FightDataMgr.order_list then
        local animation = FightData.newAnimation()
        animation.startTime = time
        animation.endTime = time
        animation.attr = 1
        table.insert(FightDataMgr.othersAnimationList, animation)
    end

    --3:全体非战斗状态角色降一半帧频事件[JumpFrame]
    local lockAnimation = FightData.newAnimation()
    lockAnimation.startTime = time
    lockAnimation.endTime = time
    lockAnimation.attr = 3
    table.insert(FightDataMgr.othersAnimationList, lockAnimation)
    
    local newLog = {}
    newLog.order = log.order
    newLog.round = log.round
    newLog.orderTargetList = {}
    for __, fightSoldier in pairs(log.targetList) do
        local orderTarget = 
        {
            guid = fightSoldier.guid,
            attr = fightSoldier.attr,
            rage = fightSoldier.rage,
            hp = fightSoldier.hp,
            fight_attr = 0,
            fight_might = 1,
            fight_result = 1,
            fight_type = 0,
            fight_value = 0,
            odd_list = {},
            odd_list_triggered = {}
        }
        
        table.insert(newLog.orderTargetList, orderTarget)
    end
    obj = self:parseAckRole(role,action,actionEffect,newLog,time,skill)
    obj.idleTime = time
    obj.order_guid = log.order.guid

    self:parseEffect(role, action, actionEffect, newLog, obj.ackTime, skill, 1, 0)

    self:loadMediaSoundList(newLog)
    self:induct(log, obj, role, skill)
    
    role.state = "parseFightSkillObject"
    return obj
end

function __this:induct(log, obj, role, skill)
    if 1011 == FightDataMgr.fight_induct then
        if self.leftTotemValue >= 150 and role:isMirror() then
            local animation = FightData.newAnimation()
            animation.startTime = obj.pathTime - 100
            animation.endTime = obj.pathTime - 100
            animation.attr = 8
            table.insert(FightDataMgr.othersAnimationList, animation)

            animation = FightData.newAnimation()
            animation.startTime = obj.pathTime - 110
            animation.endTime = obj.pathTime - 110
            animation.attr = 9
            animation.val = 1
            table.insert(FightDataMgr.othersAnimationList, animation)
        end

    -- elseif 1031 == FightDataMgr.fight_induct then
    --     if self.leftTotemValue >= 150 and role:isMirror() and 7 == role:index() then
    --         animation = FightData.newAnimation()
    --         animation.startTime = obj.ackTime - 50
    --         animation.endTime = obj.ackTime - 50
    --         animation.attr = 9
    --         animation.val = 3
    --         table.insert(FightDataMgr.othersAnimationList, animation)
    --     end

    -- elseif 1041 == FightDataMgr.fight_induct then
    --     if self.leftTotemValue >= 300 and role:isMirror() and 5 == role:index() then
    --         local animation = FightData.newAnimation()
    --         animation.startTime = obj.pathTime - 50
    --         animation.endTime = obj.pathTime - 50
    --         animation.attr = 8
    --         table.insert(FightDataMgr.othersAnimationList, animation)

    --         animation = FightData.newAnimation()
    --         animation.startTime = obj.pathTime - 60
    --         animation.endTime = obj.pathTime - 60
    --         animation.attr = 9
    --         animation.val = 4
    --         table.insert(FightDataMgr.othersAnimationList, animation)
    --     end

    elseif 2061 == FightDataMgr.fight_induct then
        if self.leftTotemValue >= 300 and role:isMirror() and 8 == role:index() and skill.self_costrage > 0 then
            local animation = FightData.newAnimation()
            animation.startTime = obj.pathTime - 80
            animation.endTime = obj.pathTime - 80
            animation.attr = 8
            table.insert(FightDataMgr.othersAnimationList, animation)

            animation = FightData.newAnimation()
            animation.startTime = obj.pathTime - 90
            animation.endTime = obj.pathTime - 90
            animation.attr = 9
            animation.val = 7
            table.insert(FightDataMgr.othersAnimationList, animation)
        end
    end
end
    
--副本剧情触发
function __this:copyGut(log)
    FightDataMgr.addAckNo()
    if not FightDataMgr.gut then
        return
    end

    if not self.gut or log.round ~= self.gut.round then
        self.gut = {round = log.round, list={}}
    end

    local chunk = nil
    for i, chunk in pairs(FightDataMgr.gut.gut) do
        if chunk.cate == FightDataMgr.ackNo then
            if not self.gut.list[log.order.guid] then
                self.gut.list[log.order.guid] = 1
                EventMgr.dispatch(EventType.FightCopyGut, {first=chunk.objid, second=chunk.val})
            end

            table.remove(FightDataMgr.gut, i)
            break
        end
    end
end

--音效资源预加载
function __this:loadMediaSoundList(log)
    if 0 == log.order.guid then
        return
    end

    local role = FightRoleMgr:getRole(log.order.guid)
    if not role or not role.sound then
        return
    end

    local skill = findSkill(log.order.order_id, log.order.order_level)
    if not skill then
        return
    end

    SoundMgr.setEffectsVolume(0)
    self.preloadSound(role.guid, role.sound)

    for __, orderTarget in pairs(log.orderTargetList) do
        if role.guid ~= orderTarget.guid and 1 == skill.target_type then
            local target = FightRoleMgr:getRole(orderTarget.guid)
            if target then
                for __, es in pairs(role.sound.soundList) do
                    if '' ~= es.sound then
                        local url = "sound/" .. es.sound .. ".mp3"
                        SoundMgr.preloadEffect(url)
                    end
                end
            end
        end
    end
    SoundMgr.setEffectsVolume()
end

--外部预加载音效
--@param style  [形象]
--@param sound  [音效数据]
function __this.preloadSound(style, sound)
    local sound = sound or FightFileMgr:getSound(style)
    if not sound then
        return
    end

    for __, es in pairs(sound.soundList) do
        if '' ~= es.sound then
            local url = "sound/" .. es.sound .. ".mp3"
            SoundMgr.preloadEffect(url)
        end
    end

    for __, ts in pairs(sound.dataList) do
        for __, es in pairs(ts.list) do
            if '' ~= es.sound then
                local url = "sound/" .. es.sound .. ".mp3"
                SoundMgr.preloadEffect(url)
            end
        end
    end
end

function __this.updateList(list, key)
    local strList = string.split(key, '%')
    if 0 == #strList then
        return
    end

    for __, v in pairs(list) do
        if v == strList[1] then
            return
        end
    end

    table.insert(list, strList[1])
end

--解释下一出手者资源预加载处理
function __this:parse_round_soldier_resource(log)
    local list = {}
    if 0 == log.order.guid then
        if trans.const.kFightRoundEnd ~= log.order.order_id or true == FightDataMgr.theFight:checkEnd() or 0 == FightDataMgr.round then
            return list
        end

        table.insert(list, self.const.CALL_EFFECTID)
        return list
    end

    local role = FightRoleMgr:getRole(log.order.guid)
    if not role then
        return list
    end

    local skill = findSkill(log.order.order_id, log.order.order_level)
    if not skill then
        return list
    end
    
    local action = role.body:getActionByFlag(skill.action_flag)
    if not action then
        return list
    end
    
    local actionEffect = FightFileMgr:getActionEffect(action, skill.effect_index)
    if not actionEffect then
        return list
    end

    if '' ~= actionEffect.ackEffect then
        self.updateList(list, actionEffect.ackEffect)
    end
    if '' ~= actionEffect.fireEffect then
        self.updateList(list, actionEffect.fireEffect)
    end
    if '' ~= actionEffect.targetEffect then
        self.updateList(list, actionEffect.targetEffect)
    end

    if 2 == role:getSkillIndex(skill.id, skill.level) then
        table.insert(list, self.const.POWER_EFFECTID)
    end

    return list
end

--修正全体站位
function __this:fixOffsetAll(time, log)
    local maxTime = time
    local list = FightRoleMgr:getAllSoldier()
    for __, role in pairs(list) do
        if log.order.guid ~= role.guid and not role:dear() then
            if #role.pathAnimationList > 0 then
                local data = role.pathAnimationList[#role.pathAnimationList]
                if time <= data.startTime then
                    if data.endPT 
                        and (
                            data.endPT.x ~= role.station:x() 
                            or data.endPT.y ~= role.station:y()
                        )
                    then
                        local pathData = FightData:setPath(data.endTime, data.endPT, role.station:pos(), role:isMirror(), true)
                        table.insert(role.pathAnimationList, pathData)
                        time = pathData.endTime
                    end
                end
            elseif math.abs(role.station:x() - role.playerView:getPositionX()) > 50 or math.abs(role.station:y() - role.playerView:getPositionY()) > 50 then
                local pathData = FightData:setPath(time, 
                    cc.p(role.playerView:getPositionX(), role.playerView:getPositionY()),
                    role.station:pos(), role:isMirror(), true)
                table.insert(role.pathAnimationList, pathData)
                maxTime = math.max(time, pathData.endTime)
            end
        end
    end

    return time
end


FightAnimationMgr = __this