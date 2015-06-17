require("lua/manager/TimerMgr.lua")
require("lua/game/view/fight/misc/FightAnimationMgr.lua")
require("lua/game/view/fight/misc/FightTotemMgr.lua")
require("lua/game/view/fight/misc/FightNumberMgr.lua")
require("lua/game/view/fight/misc/FightTextMgr.lua")
require("lua/game/view/fight/misc/FightCollaborationist.lua")
require("lua/server/BattleLogic.lua")
require("lua/game/view/fight/struct/UIFightEffect.lua")
require("lua/game/view/fight/FightUI.lua")
require("lua/algorithm/ParaCurve.lua")
require("lua/game/view/fight/misc/FightClientLog.lua")

--战斗数据管理
local __this = 
{ 
    --状态
    station = 0,
    --状态枚举
    enum = 
    {
        SLEEP = 0,
        CHECK_FIGHT_END = 1,        --检测战斗完全结束
        PARSE_ROUND_SKILL = 2,      --解释当前LOG
        PARSE_ROUND_SOLDIER = 3,    --解释下一出手者预施放表现
        PARSE_SECOND_SKILL = 5,     --秒杀
        FIGHT_END = 6,              --战斗结束
        FIGHT_WAIT_QUIT = 7,        --等待退出战斗系统
        AUTO_TOTEM = 8,             --自动战斗
        FIGHT_INIT = 9,             --战前初始化处理

        --双人战处理状态=================start
        PRO_DOUBLE_ROUND_DATA = 101,		--处理正常log
        PRO_DOUBLE_ROUND_SOLDIER = 102,	--处理下一出手
        PRO_DOUBLE_SYN = 103,			--发送确认协议
        PRO_DOUBLE_SLEEP = 104,
        --双人战处理状态=================end
    },
    --状态事件[有时间延迟才会添加事件，即时切换状态也会因为定时器循环规则而在下次循环执行状态修改后的事情处理]
    listState = {},
    
    --定时器
    timerId = nil,
    --时间
    runTime = 0,
	totemTime = 0,

    --能否使用图腾技能开关
    totem_btn_lock = nil,
    totem_btn_Enable = nil,
    totem_btn_induct_lock = nil,
    totem_btn_right_lock = nil,
    jump_frame = 1,

	--确认序列号	[vs]
	seqno = 0,

    --[[未归类事件 [开始与结束时间为一致]
        1:图腾功能锁上[不检测图腾可用状态]
        2:图腾功能解锁[检测图腾可用状态]
        3:全体非战斗状态角色降一半帧频事件[JumpFrame][待机]
        4:全体非战斗状态角色降一半帧频事件[UnJumpFrame][待机]
        5:觉醒武将插入表现锁上
        6:觉醒武将插入表现解锁
        7:图腾按钮不可用锁上[优先级高于正常状态]
        8:图腾按钮不可用解锁[优先级高于正常状态]
        9:新手引导事件派发
        ]]
    othersAnimationList = {},

    --掉落物品事件列表
    rewardItemAnimationList1 = {},
    rewardItemAnimationList2 = {},
    --掉落物品列表
    rewardItemList = {},

    --全屏buff事件
    colonyBuffAnimationList = {},

    --十字军试炼总量事件
    trialEndInfoAnimationList = {},

    --声音事件
    sceneSoundAnimationList = {},

    runStation = '',

    --指定角色引用
    special_id = 10801,
    special_role = nil,
}
__this.__index = __this

local function getUrl(attr, style, name, type)
    return "image/armature/fight/" .. attr .. "/" .. style .. '/' .. name .. '.' .. type
end

function __this:rewardPush(data)
    table.insert(self.rewardItemAnimationList1, data)
end

--[[未归类事件 [开始与结束时间为一致]
        1:图腾功能锁上[不检测图腾可用状态]
        2:图腾功能解锁[检测图腾可用状态]
        3:全体非战斗状态角色降一半帧频事件[JumpFrame][待机]
        4:全体非战斗状态角色降一半帧频事件[UnJumpFrame][待机]
        5:觉醒武将插入表现锁上
        6:觉醒武将插入表现解锁
        7:图腾按钮不可用锁上[优先级高于正常状态]
        8:图腾按钮不可用解锁[优先级高于正常状态]
        9:新手引导事件派发
        ]]
function __this:runOthers(time)
    local list = self.othersAnimationList
    local del = {}

    for i, data in pairs(list) do
        if time > data.endTime then
            table.insert(del, i)
        end
    end

    for i = #del, 1, -1 do
        local index = del[i]
        local data = list[index]
        table.remove(list, index)

        if 1 == data.attr then
            self.totem_btn_lock = true
        elseif 2 == data.attr then
            self.totem_btn_lock = nil
        elseif 3 == data.attr then
            self.jump_frame = 2
        elseif 4 == data.attr then
            self.jump_frame = 1
        elseif 5 == data.attr then
            self.disillusion_station = true
        elseif 6 == data.attr then
            self.disillusion_station = nil
        elseif 7 == data.attr then
            self.totem_btn_Enable = true
        elseif 8 == data.attr then
            self.totem_btn_Enable = nil
        elseif 9 == data.attr then
            if 3 ~= data.val or FightAnimationMgr.leftTotemValue >= 150 then
                EventMgr.dispatch(EventType.FightInduct, data.val)
                if 2061 == self.fight_induct then
                    self.fight_induct = 0
                end
            end
        end
    end
end

--物品飞往宝箱
function __this:parseRewardFlyBox()
    for __, data in pairs(self.rewardItemList) do
       if not data.itemView.enable then
            data.itemView.enable = true
            table.insert(
                self.rewardItemAnimationList2, 
                FightData:createItemRewardFloor3(
                    data.role, 
                    math.floor(FightDataMgr.runTime * 1000) + 100, 
                    -0.0015, 
                    data.offset, 
                    data.itemView
                )
            )
       end 
    end
end

--十字军试炼总量事件
function __this:runTrialEndInfo(time)
    local list = self.trialEndInfoAnimationList
    local del = {}

    for i, data in pairs(list) do
        if time > data.endTime then
            table.insert(del, i)
        end
    end

    for i = #del, 1, -1 do
        local index = del[i]
        local data = table.remove(list, index)

        if not self.test then
            self.theFightUI:setTrialValue(data.endInfo)
        end
    end
end

--群体Buff特效渲染
function __this:runColonyBuff(time)
    local list = self.colonyBuffAnimationList
    local del = {}

    for i, data in pairs(list) do
        if 0 ~= data.endTime and time >= data.endTime then
            table.insert(del, i)

        elseif time > data.startTime then
            if 1 == data.effectItem.layer then
                FightEffectMgr:useEffect(data, self:getLayerColonyEffect())
            else
                FightEffectMgr:useEffect(data, self:getLayerEffect())
            end
            if not data.uiEffect then
                table.insert(del, i)
            else
                local mirror = data.mirror
                data.uiEffect:setMirror(mirror)
                local p = nil
                if not data.p then
                    if mirror then
                        local pFix = cc.p(data.proxyBody.footX - data.uiEffect:getItemX(), data.proxyBody.footY - data.uiEffect:getItemY())
                        p = cc.p(data.coord.x + pFix.x, data.coord.y + pFix.y)
                    else
                        local pFix = cc.p(-data.proxyBody.footX + data.uiEffect:getItemX(), data.proxyBody.footY - data.uiEffect:getItemY())
                        p = cc.p(data.coord.x + pFix.x, data.coord.y + pFix.y)
                    end
                    
                    data.p = p
                end
                
                p = data.p
                data.uiEffect:setPosition(p)
                
                local frame = ((time - data.startTime) / data.uiEffect.frameRate) % data.uiEffect.totalFrames
                if frame + 1 >= data.uiEffect.totalFrames then
                    frame = data.uiEffect.totalFrames - 1
                end
                data.uiEffect:attack(frame, data)
            end
        end
    end
    
    for i = #del, 1, -1 do
        local data = table.remove(list, del[i])
        FightEffectMgr:unEffect(data)
    end
end

--播放场景语音
function __this:runSceneSound(time)
    -- body
    local list = self.sceneSoundAnimationList
    local del = {}

    for i, data in pairs(list) do
        if i ~= #list then
            table.insert(del, i)
        end
    end

    if #list > 1 then
        local data = list[#list]
        if not data.played then
            data.played = true
            data.id = SoundMgr.playEffect("sound/" .. data.file .. "/" .. data.sound .. ".mp3")
        end
    end

    for i = #del, 1, -1 do
        local data = table.remove(list, del[i])
        SoundMgr.stopEffect(data.id)
    end
end

--手动触发图腾
function __this:touchTotem(role)
    if self:checkEnd() then
        self.listState = {}
        self:check_fight_end(math.floor(self.runTime * 1000))
        
        return
    end
    local soldier = FightDataMgr.theFight:findSoldier(role.guid)
    if not soldier then
        return
    end

	--玩家 Vs 玩家
	if const.kFightTypeCommonPlayer == self.fight_type then
		if 0 == #role.fightSoldier.skill_list then
			return
		end

		local skill = role.fightSoldier.skill_list[1]
		Command.run("fight ack", self.fight_id, role.fightSoldier.guid, skill.skill_id, skill.skill_level)
		return
	end

    if #self.fight_info_list > 1 then
        ActionMgr.save( 'fight', 
            'click totem_id:' .. role.totem.id
            .. "  id:" .. self.fight_id  
            .. "  player_guid:" .. self.fight_info_list[2].player_guid
            .. "  guid:" .. self.fight_info_list[2].guid )
    end
	local time = math.floor(self.totemTime * 1000)
	FightTotemMgr:parseTotem(time, role)
end


--------------------------------------------事件循环处理start
--停顿渲染
function __this:runPause(time, role)
    local list = role.pauseAnimationList
    local del = {}
    local flag = false

    for i, data in pairs(list) do
        if 0 ~= data.endTime and time >= data.endTime then
            table.insert(del, i)

        elseif time >= data.startTime then
            flag = true
        end
    end

    for i = #del, 1, -1 do
        table.remove(list, del[i])
    end
        
    role.pause = flag
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

    if role.pause then
        -- if role.hpView then
        --     if role.hpView.maxHp == role.hpView.lastHp then
        --         role.hpView:setVisible(false)
        --     else
        --         role.hpView:setVisible(true)
        --     end
        -- end
        return
    end
    
    for i, data in pairs(list) do
        if data.endTime > 0 and time > data.endTime then
            table.insert(del,i)
        elseif time > data.startTime then
            if time > role.dearTime and "dead" ~= data.type then
                table.insert(del, i)
            else
                flag = true
                play:chnAction(mirror, data.type, data, role)
                
    			--[stand]&[chuxian]
                if "stand" == data.type or "faguang" == data then
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
    
    for i = #del, 1, -1 do
        table.remove(list, del[i])
    end
			
	-- if role.hpView then
	-- 	if role.hpView.maxHp == role.hpView.lastHp then
	-- 		role.hpView:setVisible(false)
	-- 	else
	-- 		role.hpView:setVisible(true)
	-- 	end
	-- end

    if not flag then
        if time > role.dearTime then
             play:chnAction(mirror, "dead")
             play:attack(play.totalFrames - 1)
			
			if role.hpView then
				role.hpView:setVisible(false)
			end
        else
            play:chnAction(mirror, "stand")
            play.jump_frame = self.jump_frame
            play:stand(time)

            if role.hpView then
            --     if role.hpView.maxHp == role.hpView.lastHp then
            --         role.hpView:setVisible(false)
            --     else
                    role.hpView:setVisible(true)
            --     end
            end
        end
    end
end

--轨迹渲染
function __this:runPath(time, role, mirror)
    local play = role.playerView
    local list = role.pathAnimationList
    
    local del = {}
    for i, data in pairs(list) do
        if time >= data.endTime then
            table.insert(del, i)
			
        elseif time >= data.startTime then
			local frame = FightData:getNowFrame(data, data.long, time) + 1
			if frame > data.long then
				frame = data.long
			end
			
			--普通位移
            if data.startPT and data.endPT then	
                local pt = nil
                if frame <= data.long / 2 then
                    pt = cc.pSub(data.startPTto, data.startPT)
                    pt.x = data.startPT.x + pt.x / data.long / 2 * frame
                    pt.y = data.startPT.y + pt.y / data.long / 2 * frame
                    
                    if not data.alpha then
                        play:setOpacity(255 - 255 / data.long / 2 * frame)
                    end
                else
                    frame = frame - data.long / 2
                    pt = cc.pSub(data.endPT, data.endPTto)
                    pt.x = data.endPTto.x + pt.x / (data.long / 2) * frame
                    pt.y = data.endPTto.y + pt.y / (data.long / 2) * frame
					
					if not data.alpha then
                        play:setOpacity(255 / data.long / 2 * frame)
                    end
                end
                play:setPosition(pt)
            end
			
			--闪避后移
			if data.dodgeOffset then
				if frame > 5 then
					frame = 5
				end
				local pt
				if 0 == data.attr then
					pt = cc.p(role.station:x() + data.dodgeOffset.x / 5 * frame, role.station:y() + data.dodgeOffset.y / 5 * frame)
				else
					pt = cc.p(role.station:x() + data.dodgeOffset.x - data.dodgeOffset.x / 5 * frame, role.station:y() + data.dodgeOffset.y - data.dodgeOffset.y / 5 * frame)
				end
				play:setPosition(pt)
			end

        elseif time > role.dearTime then
            table.insert(del, i)
        end
    end
    
    for i = #del, 1, -1 do
        local data = list[del[i]]
        
        if not data.endPT then
        	play:setPosition(role.station:x(), role.station:y())
        else
            play:setPosition(data.endPT)
        end
		
         play:setOpacity(255)
        table.remove(list, del[i])
    end
end

--特效渲染
function __this:runEffect(time, role, isMirror)
    local list = role.effectAnimationList
    local play = role.playerView
    local del = {}

    if role.pause then
        for __, data in pairs(list) do
            if data.actionEffect and data.actionEffect.targetEffect ~= data.effectStyle then
                data.endTime = time - 1
            end
        end
    end

    for i, data in pairs(list) do
        if time > data.endTime or time >= role.dearActionStartTime then
            table.insert(del, i)

        elseif time > data.startTime then
            FightEffectMgr:useEffect(data, data.sprite, role)
			if not data.uiEffect then
				table.insert(del, i)
			else
				local mirror = isMirror
                if 1 == data.effectItem.mirror then
                    mirror = false
                end
                data.uiEffect:setMirror(mirror)
                local p = nil
                if not data.p then
					if data.startPT and data.endPT then
                        if mirror then
							local pFix = cc.p(role.body.footX - data.uiEffect:getItemX(), role.body.footY - data.uiEffect:getItemY())
							p = cc.p(play:getPositionX() + pFix.x, play:getPositionY() + pFix.y)
                        else
							local pFix = cc.p(-role.body.footX + data.uiEffect:getItemX(), role.body.footY - data.uiEffect:getItemY())
							p = cc.p(play:getPositionX() + pFix.x, play:getPositionY() + pFix.y)
                        end
					else
                        if mirror then
							p = cc.p(role.body.footX - data.uiEffect:getItemX(), role.body.footY - data.uiEffect:getItemY())
                        else
							p = cc.p(-role.body.footX + data.uiEffect:getItemX(), role.body.footY - data.uiEffect:getItemY())
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
				
                local frame = FightData:getNowFrame(data, data.uiEffect.totalFrames, time )
                -- local frame = ((time - data.startTime) / data.uiEffect.frameRate) % data.uiEffect.totalFrames
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
        local data = table.remove(list, del[i])
        FightEffectMgr:unEffect(data)
    end
end

--buff特效
function __this:runBodyEffect(time, role, isMirror)
    local list = role.bodyEffectAnimationList
    local play = role.playerView
    local del = {}
	
    for i, data in pairs(list) do
        if 
            not data.endTime 
            or (0 ~= data.endTime and time > data.endTime)
            or (time >= role.dearActionStartTime and FightAnimationMgr.const.RESURRECTION ~= data.odd.id)
            then
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
                FightEffectMgr:useEffect(data, data.sprite)
                if not data.uiEffect then
                    --潜行状态特殊处理
                    if data.odd and data.odd.status and FightTotemMgr.sneak == data.odd.status.cate then
                        role.playerView:setOpacity(127)
                    else
                        table.insert(del, i)
                    end
                else
                    --因变身作出的兼容处理
                    if data.target then
                        local layer = nil
                        if 1 == data.effectItem.layer then
                            layer = data.target.playerView.backgroundLayer
                        else
                            layer = data.target.playerView.sprite
                        end

                        if layer ~= data.uiEffect:getParent() then
                            data.uiEffect:removeFromParent()
                            layer:addChild(data.uiEffect)
                        end
                    end

                    local mirror = isMirror
                    if 1 == data.effectItem.mirror then
                        mirror = false
                    end

                    data.uiEffect:setMirror(mirror)
					local p = nil
                    if mirror then
						p = cc.p(role.body.footX - data.uiEffect:getItemX(), role.body.footY - data.uiEffect:getItemY())
					else
						p = cc.p(-role.body.footX + data.uiEffect:getItemX(), role.body.footY - data.uiEffect:getItemY())
					end

                    if data.odd.buff_offset and 0 ~= data.odd.buff_offset then
                        if 1 == data.odd.buff_offset then
                            p.y = p.y + role.body.bodyY - role.body.headY
                        else
                            p.y = p.y + role.body.bodyY - role.body.footY
                        end
                    end

                    data.uiEffect:setPosition(p)
                    
                    local frame = ((time - data.startTime) / data.uiEffect.frameRate) % data.uiEffect.totalFrames
                    if frame + 1 >= data.uiEffect.totalFrames then
                        frame = data.uiEffect.totalFrames - 1
                    end
                    data.uiEffect:attack(frame)

                    if "call1" == role.playerView.actionType then
                    	data.uiEffect:setVisible(false)
                    else
                    	data.uiEffect:setVisible(true)
                    end

                    --飓风：令随机N个目标进入飓风状态（被驱逐出场）N回合
                    if data.odd and data.odd.status and FightTotemMgr.hurricane == data.odd.status.cate then
                        local _t = time - data.startTime
                        frame = math.floor(_t / 1200)
                        _t = 30 / 1200 * (_t % 1200) 
                        if frame % 2 == 0 then
                            play:setPosition(role.station:x(), role.station:y() + _t)
                        else
                            play:setPosition(role.station:x(), role.station:y() + 30 - _t)
                        end
                        print(play:getPositionY(), play:getOpacity())
                    end
                end
            end
        end
    end
    
    for i = #del, 1, -1 do
        local index = del[i]
        local data = list[index]
        FightEffectMgr:unEffect(data)
        table.remove(list, index)

        if data.odd and data.odd.status then
            if FightTotemMgr.sneak == data.odd.status.cate then
                play:setOpacity(255)
            --飓风：令随机N个目标进入飓风状态（被驱逐出场）N回合
            elseif FightTotemMgr.hurricane == data.odd.status.cate then
                play:setPosition(role.station:x(), role.station:y())       
            end 
        end
    end
end

--召唤、变身
function __this:runCallChange(time, role, isMirror)
    local list = role.callChangeAnimationList
	local del = {}
	
	for i, data in pairs(list) do
		if time >= data.startTime then
			table.insert(del, i)
        end
    end

    for i = #del, 1, -1 do
        local index = del[i]
        local data = list[index]
        table.remove(list, index)
		
        --变身处理
        if 1 == data.attr then
            local mirror = role:isMirror()
            if data.soldier.camp ~= role.camp then
                mirror = not mirror
            end
            local newRole = FightRoleMgr:getByIndex(true, data.soldier.fight_index)
            if newRole then
                newRole:attrChange(data.soldier, data.pt)
                self.theScene.scene:changeScene("change")
				
                --boss条件更新
                if not self.test then
                    self.theFightUI:reset_boss_hp(data.soldier.last_ext_able.hp)
                end
            end
            
        --召唤处理
        elseif 2 == data.attr then
            -- local mirror = data.isMirror
            -- for __, soldier in pairs(data.call) do
            --     local newRole = FightRoleMgr:getByIndex(mirror, soldier.fight_index)
            --     if newRole then
            --         newRole:attrCall(self:getLayerRole(), time, data.user, soldier)
            --     end
            -- end

            ModelMgr:releaseIdleness()
        --石化
        elseif 3 == data.attr then
            role:attrModel(self:getLayerRole(), data.style)
        end
    end
end

--伤害数字
function __this:runNumber(time, role)
    local list = role.hpAnimationList
    local play = role.playerView
    local del = {}
    local attr = false
    if role:checkAttr(trans.const.kAttrMonster) and 2 == role.monster.type then
    	attr = true
    end

    for i, data in pairs(list) do 
        if time > data.endTime then
            table.insert(del, i)
			
			--大boss血条第二层事件
			if not self.test and attr then
				self.theFightUI:setSecondBossHp(data.hp)
			end

			if not data.hpView then
				data.hpView = true
				if role.hpView then
					local soldier = self.theFight:findSoldier(role.guid)
					if soldier then
						if not self.test and attr then
							self.theFightUI:setbossHp(data.fight_value)
						end
						role.hpView:set_Hp(time, data.fight_value)
					end
				end
			end
			
        elseif time > data.startTime then
            if role.hpView and not data.hpView then
                data.hpView = true
                local soldier = self.theFight:findSoldier(role.guid)
                if soldier then
                    if not self.test and attr then
                        self.theFightUI:setbossHp(data.fight_value)
                    end
                        
                    role.hpView:set_Hp(time, data.fight_value)
                end
            end

            FightNumberMgr:useRedNumber(data, self:getLayerNumber())
			if not data.coord then
				if not data.offset then
					data.coord = cc.p(play:getPositionX() + 50, play:getPositionY() + role.body.footY - role.body.bodyY + 30)
				else
					data.coord = cc.p(play:getPositionX() - 50, play:getPositionY() + role.body.footY - role.body.bodyY + 70)
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
end

--红屏
function __this:runPowerRed(time, role)
    local list = role.powerRedAnimationList
	local del = {}
	
	for i, data in pairs(list) do
		if time > data.endTime then
			table.insert(del, i)

		elseif not self.test and time >= data.startTime then
            local redView = self.theFightUI:getRedView()
			local frame = math.ceil((time - data.startTime) / 25) % 2
			if 0 == frame then
				redView:setUniformData( 'u_distance', 'vec1', { 360 } )
			else
				redView:setUniformData( 'u_distance', 'vec1', { 300 } )
			end
			if not redView:getParent() then
				self:getLayerRed():addChild(redView)
			end
		end
	end
	
	for i = #del, 1, -1 do
		local data = list[del[i]]
		table.remove(list, del[i])

        if not self.test then
            self.theFightUI:getRedView():removeFromParent()
		end
	end
end

--振动
function __this:runDiskplay(time, role)
    local list = role.diskplayAnimationList
	local del = {}
	
	for i, data in pairs(list) do
		if time >= data.startTime then
			table.insert(del, i)
		end
	end
	
	for i = #del, 1, -1 do
		local data = list[del[i]]
		table.remove(list, del[i])
		self.theScene:shakeLeft((data.endTime - data.startTime) / 1000)
	end
end

--白屏
function __this:runWhite(time, role)
    local list = role.whiteAnimationList
	local del = {}
	
	for i, data in pairs(list) do
		if time > data.endTime then
			table.insert(del, i)
		
        elseif time >= data.startTime then
            local sceneWhiteView = self.theFightUI:getSceneWhiteView()
			if not self.test and not sceneWhiteView:getParent() then
				self:getLayerRed():addChild(sceneWhiteView)
			end
		end
	end
	
	for i = #del, 1, -1 do
		local data = list[del[i]]
		table.remove(list, del[i])
        if not self.test then
			self.theFightUI:getSceneWhiteView():removeFromParent()
		end
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
        SoundMgr.playEffect(url, false, self.speed)
	end
end

--场景黑屏
function __this:runSceneBlack(time, role)
    local list = role.sceneBlackAnimationList
	local del = {}
	
	for i, data in pairs(list) do
		if time > data.endTime then
			table.insert(del, i)

		elseif time >= data.startTime and not self.test then
            local sceneBlackView = self.theFightUI:getSceneBlackView()
			if not sceneBlackView:getParent() then
				self:getLayerScene():addChild(sceneBlackView)
			end
		end
	end
	
	for i = #del, 1, -1 do
		local data = list[del[i]]
		table.remove(list, del[i])
		
		if not self.test then
            self.theFightUI:getSceneBlackView():removeFromParent()
		end
	end
end

--滤镜事件
function __this:runFilter(time, role)
    local list = role.filtersAnimationList
	local del = {}
	local play = role.playerView
	local attr = false
	if role:checkAttr(trans.const.kAttrMonster) and 2 == role.monster.type then
		attr = true
	end

	for i, data in pairs(list) do
		if 0 ~= data.endTime and time > data.endTime then
			table.insert(del, i)

		elseif time >= data.startTime then
			play:setGLProgramStateChildren(data.attr)

			if attr and "paint" == data.attr and not self.test then
				local frame = math.ceil((time - data.startTime) / 100) % 2
				if 0 == frame then
					self.theFightUI:setBossHpFace("paint")
				else
					self.theFightUI:setBossHpFace("normal")
				end
			end
		end
	end
	
	for i = #del, 1, -1 do
		local data = list[del[i]]
		table.remove(list, del[i])
		play:setGLProgramStateChildren("normal")

		if attr and not self.test then
    		self.theFightUI:setBossHpFace("normal")
		end
	end
end

--喊招
function __this:runSkill(time, role)
	local list = role.skillAnimationList
	local del = {}
	local play = role.playerView

	for i, data in pairs(list) do 
		if time > data.endTime then
			table.insert(del, i)
		elseif time >= data.startTime then

            local layer = self:getLayerBlackEffect()
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
            elseif 5 == data.attr then
                FightTextMgr:useText(data, layer)
            elseif 6 == data.attr then
                FightTextMgr:useTextAnti(data, layer)
            else
                FightTextMgr:useTextReboundPer(data, layer)
            end

			if not data.text then
				table.remove(del, i)
			else
				if not data.p then
                    -- if 4 ~= data.attr then
                    --     data.p = cc.p(play:getPositionX(), play:getPositionY() + role.body.footY - role.body.headY + 75)
                    -- else
                        data.p = cc.p(play:getPositionX(), play:getPositionY() + role.body.footY - role.body.headY)
                    -- end

                    if data.p.x < 0 then
                        data.p.x = 0
                    end
                    if data.p.x + data.text.size.width > visibleSize.width then
                        data.p.x = visibleSize.width - data.text.size.width
                    end
                end

                data.text:idle(time, data, data.p, role)
			end
		end
	end

	for i = #del, 1, -1 do
		local data = list[del[i]]
		table.remove(list, del[i])
		FightTextMgr:unText(data)
	end
end

--群体特效渲染
function __this:runColony(time, role, isMirror)
    local list = role.colonyAnimationList
    local play = role.playerView
    local del = {}

    for i, data in pairs(list) do
        if not data.endTime or (0 ~= data.endTime and time > data.endTime) then
            table.insert(del, i)

        elseif time > data.startTime then
            FightEffectMgr:useEffect(data, self:getLayerEffect())
			if not data.uiEffect then
				table.insert(del, i)
			else
				local mirror = data.mirror
                data.uiEffect:setMirror(mirror)
                local p = nil
                if not data.p then
					if mirror then
						local pFix = cc.p(data.proxyBody.footX - data.uiEffect:getItemX(), data.proxyBody.footY - data.uiEffect:getItemY())
						p = cc.p(data.coord.x + pFix.x, data.coord.y + pFix.y)
					else
						local pFix = cc.p(-data.proxyBody.footX + data.uiEffect:getItemX(), data.proxyBody.footY - data.uiEffect:getItemY())
						p = cc.p(data.coord.x + pFix.x, data.coord.y + pFix.y)
					end
					
                    data.p = p
                end
				
				p = data.p
                data.uiEffect:setPosition(p)
				
				local frame = FightData:getNowFrame(data, data.uiEffect.totalFrames, time )
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

-- 释放事件
function __this:runRelease(time, role)
	local list = role.releaseAnimationList
	local del = {}

	for i, data in pairs(list) do 
		if time > data.endTime then
			table.insert(del, i)
		end
	end

	for i = #del, 1, -1 do
		table.remove(list, del[i])
		FightEffectMgr:parseBody(role.body)
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
            if not self.test then
                self.theFightUI:setTotemValue(role, list[del[i]].value)
            end

            flag = true
        end
        table.remove(list, del[i])
    end
end

--透明度更新
function __this:runOpacity(time, role)
    local list = role.opacityAnimationList
    local del = {}

    for i, data in pairs(list) do
        if 0 ~= data.endTime and time >= data.endTime then
            table.insert(del, i)
        elseif time > data.startTime then
            if 0 == data.endTime then
                role.playerView:setOpacity(data.opacity)
            else
                if 0 == data.opacity then
                    role.playerView:setOpacity(255 - (time - data.startTime))
                else
                    role.playerView:setOpacity(time - data.startTime)
                end
            end
        end
    end

    for i = #del, 1, -1 do
        local data = list[del[i]]
        table.remove(list, del[i])

        role.playerView:setOpacity(data.opacity)
    end
end

--怒气更新
function __this:runRage(time, role)
    -- body
    if not role.hpView then
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
        role.hpView:set_Rage(data.rage)
    end
    
    role.hpView:hp_update(time)
end

--角色其它事件更新
function __this.runRoleOthers(time, role)
    -- body
    if not role.hpView then
        return
    end

    local list = role.othersAnimationList
    local del = {}

    for i, data in pairs(list) do
        if time >= data.endTime then
            table.insert(del, i)
        end
    end

    for i = #del, 1, -1 do
        local data = table.remove(list, del[i])
        if 1 == data.type then
            role.hpView:setOddBg(true)
        elseif 2 == data.type then
            role.hpView:setOddBg(false)
        end
    end
end

function __this:runAnythings(time, role, infoVisible)
    local mirror = role:getMirror(time)
    
    self:runPause(time, role)
    self:runCallChange(time, role, mirror)
    self:runScale(time, role)
	self:runSkill(time, role)
    self:runOpacity(time, role)
    self:runAnimation(time, role, mirror, infoVisible)
    self:runPath(time, role, mirror)
	self:runEffect(time, role, mirror)
	self:runColony(time, role, mirror)
	self:runBodyEffect(time, role, mirror)
	self:runNumber(time, role)
    self:runRage(time, role)
	self:runDiskplay(time, role)
	self:runPowerRed(time, role)
	self:runWhite(time, role)
	self:runSceneBlack(time, role)
	self:runSound(time, role)
	self:runFilter(time, role)
    self:runTotemValue(time, role)
    self.runRoleOthers(time, role)
	-- self:runRelease(time, role)
end

--掉落物品更新
function __this:runReward(time, list)
    local del = {}

    for i, data in pairs(list) do
        if time >= data.endTime then
            table.insert(del, i)
        elseif time >= data.startTime then
            if not data.paraCurve then
                data.paraCurve = ParaCurve.new(data.startPT.x, data.startPT.y, data.endPT.x, data.endPT.y, data.endTime - data.startTime, data.gravity)
            end

            local x = data.paraCurve:getCurrentX(time - data.startTime)
            local y = data.paraCurve:getCurrentY(time - data.startTime)
            data.itemView:setPosition(x, y)

            if not data.itemView:getParent() then
                data.role.layer:addChild(data.itemView)
            end
        end
    end

    local newList = {}
    for i = #del, 1, -1 do
        local index = del[i]
        local data = list[index]
        table.remove(list, index)
        data.itemView:setPosition(data.endPT)

        --掉落在地上
        if 2 == data.attr then
            table.insert(self.rewardItemList, data)
            local itemView = data.itemView
            local role = data.role
            
            if self:checkEnd() then
                itemView.enable = true
                table.insert(
                    self.rewardItemAnimationList2, 
                    FightData:createItemRewardFloor3(
                        role, 
                        math.floor(FightDataMgr.runTime * 1000) + 100, 
                        -0.0015, 
                        data.offset, 
                        itemView
                    )
                )
            else
                local function rewardEvent(view, event)
                    if itemView.enable then
                        return
                    end

                    itemView.enable = true
                    table.insert(
                        self.rewardItemAnimationList2, 
                        FightData:createItemRewardFloor3(
                            role, 
                            math.floor(FightDataMgr.runTime * 1000) + 100, 
                            -0.0015, 
                            data.offset, 
                            itemView
                        )
                    )
                end
                UIMgr.addTouchEnded(data.itemView.item, rewardEvent)
            end
        elseif 3 == data.attr then
            FightTextMgr:unItemReward(data)

            if not self.test then
                self.theFightUI:boxCountAdd()
            end
        end
    end
end
--------------------------------------------事件循环处理end

function __this:TimerStop()
    if nil == self.timerId then
        return
    end

    TimerMgr.killTimer( self.timerId )
    self.Timer = nil
end

--战前初始化事件
function __this:fightInit(time, station)
    local init = FightData.newAnimation()
    init.startTime = time
    init.endTime = time
    init.station = station or self.enum.CHECK_FIGHT_END
    table.insert(self.listState, init)
end

--事件动画  [原则上列表只存在一个数据]
function __this:runStationList( time )
    local del = {}
    for i, data in pairs( self.listState ) do
        if data.endTime > time then
            break
        end
        
        table.insert(del, i)
    end

    for i = #del, 1, -1 do
        local data = table.remove(self.listState, del[i])
        self.station = data.station
        
        if self.enum.PARSE_ROUND_SKILL == self.station then
            self:parse_round_skill(time, data.obj)

        elseif self.enum.PARSE_ROUND_SOLDIER == self.station then
            self:parse_round_soldier(time, data.fightSkillObject)

        --玩家 Vs 玩家 [计算预出手动画]
        elseif self.enum.PRO_DOUBLE_ROUND_SOLDIER == self.station then
            local animation = self:parse_round_soldier(time, data.data, self.enum.SLEEP)
            self.vsPlayerRoundSoldier = animation.obj

            --创建事件  [确认协议发送]
            local seq = FightData.newAnimation()
            seq.station = self.enum.PRO_DOUBLE_SYN
            seq.startTime = time
            seq.endTime = time

            if animation.obj then
                seq.startTime = animation.obj.targetTime
                seq.endTime = animation.obj.targetTime
            end
            table.insert(self.listState, seq)

        --确认协议
        elseif self.enum.PRO_DOUBLE_SYN == self.station then
            self:sendSeqno()
        end
    end
end

--秒杀
function __this:check_second_skill(time)
    while (not self:checkEnd()) do
        if "parse_round_soldier" == self.runStation then
            self.theFight:roundSkillSoldier()
            self.runStation = "parse_round_skill"
        end
        self.theFight:roundSkill()
    end

    self.station = self.enum.SLEEP
    self:check_fight_end(time)
end

--检测战斗是否结束
function __this:checkEnd()
    if self.theFight:checkEnd() or self.theFight.round > self.theFight:getFightMaxRound() then
        return true
    end

    return false
end

--检测战斗完全结束
function __this:check_fight_end(time, animation)
    if not self:checkEnd() then
        if not animation then
            self.station = self.enum.PARSE_ROUND_SKILL
        else
            table.insert(self.listState, animation)
        end

        return
    end

    --TASK #6958::【手游】十字军试炼优化-1.8-涛哥
    if const.kFightTypeTrialSurvival == self.fight_type 
        or const.kFightTypeTrialStrength == self.fight_type
        or const.kFightTypeTrialAgile == self.fight_type
        or const.kFightTypeTrialIntelligence == self.fight_type
        then

        local data = FightData.newAnimation()
        data.station = self.enum.FIGHT_END
        table.insert(self.listState, data)

        if animation then
            data.startTime = animation.startTime + 2000
            data.endTime = animation.endTime + 2000
        else
            data.startTime = time + 2000
            data.endTime = data.startTime
        end
    else
    	if not animation then
	        self.station = self.enum.FIGHT_END
	    else
	    	local data = FightData.newAnimation()
	    	data.station = self.enum.FIGHT_END
	    	data.startTime = animation.startTime
	    	data.endTime = animation.endTime
	    	table.insert(self.listState, data)
	    end
    end

    if not self.record and self.gut then
        if const.kFightLeft == self.theFight:getWinCamp() then
            if self.gut.win_end then
                if 0 ~= self.gut.win_end.first then
                    EventMgr.dispatch(EventType.FightCopyGut, self.gut.win_end)
                end
            end
        else
            if self.gut.fail_end then
                if 0 ~= self.gut.fail_end.first then
                    EventMgr.dispatch(EventType.FightCopyGut, self.gut.fail_end)
                end
            end
        end
    end
end

--解释当前LOG
function __this:parse_round_skill(time, obj)
    self.station = self.enum.SLEEP
    self.runStation = "parse_round_skill"

    local list = self.theFight:roundSkill()
    LogMgr.log('FightDataMgrLog', "%s", debug.dump(list))

    --log记录
    if self.save_fight_log then
        table.insert(self.clientLog.round_data_list, SFightClientRoundData:new(math.floor(self.runTime * 1000), math.floor(self.totemTime * 1000), list))
	end

    local animation = FightData.newAnimation()
    if not self.disillusion_station then
        animation.station = self.enum.PARSE_ROUND_SOLDIER
        animation.startTime = time
        animation.endTime = animation.startTime
        table.insert(self.listState, animation)
    end

    for i, log in pairs(list) do
        local v = nil
        local role = nil
    	if 1 == i then
		    v = obj
		end

        animation.endTime, role = FightAnimationMgr:parseLog(animation.startTime, log, v)
    	animation.startTime = animation.endTime
    	self.round = log.round
    	LogMgr.log('FightDataMgr', "%s", "当前回合：" .. log.round)

        if role then
            role.lastTime = animation.endTime
        end
	end

    --解释下一出手者资源预加载处理    [************暂时功能性屏蔽，需视特效即时加载情况而定************]
    -- animation.fightSkillObject = self:parse_round_soldier_resource()
end

--获取预加载特效资源列表
local function loadResource(fightSkillObject)
    if not fightSkillObject then
        return
    end

	local list = FightAnimationMgr:parse_round_soldier_resource(fightSkillObject)
	LogMgr.log('FightDataMgr', "%s", "loading fight parse_round_soldier_resource begin")
    for __, style in pairs(list) do
        FightEffectMgr:loadAsync(style)
    end
end

function __this:roundSkillSoldier()
    if not self.order_list or table.empty(self.order_list) then
        return self.theFight:roundSkillSoldier()
    end

    --图腾自动执行【战报专用】
    local order = table.remove(self.order_list, 1)
    if 0 == order.guid then
        return self.theFight:roundSkillSoldier()
    end

    local role = FightRoleMgr:getRole(order.guid)
    if not role then
        return self.theFight:roundSkillSoldier()
    end

    if role:checkAttr(const.kAttrTotem) --[[and const.kFightLeft == role.camp]] then
        local time = math.ceil(self.totemTime * 1000)
        FightTotemMgr:parseTotem(time, role, nil, true)
        return self:roundSkillSoldier()
     end

    return self.theFight:roundSkillSoldier()
end

--解释下一出手者资源预加载处理
function __this:parse_round_soldier_resource()
	local fightSkillObject = self:roundSkillSoldier()
	loadResource(fightSkillObject)

	return fightSkillObject
end

--解释下一出手者预施放表现	[机制修改为：fightSkillObject为nil时表示战斗首回合调用，其余调用修改为roundskill之后立刻执行]
function __this:parse_round_soldier(time, fightSkillObject, station)
    self.station = self.enum.SLEEP
    self.runStation = "parse_round_soldier"

    if not fightSkillObject then
    	fightSkillObject = self:parse_round_soldier_resource()
    end
    --兼容战报系统[当触发左方图腾时则会返回空，此时需要手动添加预出手事件，而手动添加事件已经在武将觉醒时已经得到处理，故此不需要处理]
    if not fightSkillObject then
        return
    end

    --log记录
    if self.save_fight_log then
        table.insert(self.clientLog.round_soldier, SFightClientSkillObject:new(math.floor(self.runTime * 1000), math.floor(self.totemTime * 1000), fightSkillObject))
    end

    local obj = FightAnimationMgr:parseFightSkillObject(FightAnimationMgr:fixOffsetAll(time, fightSkillObject), fightSkillObject)
    local animation = FightData.newAnimation()
    
    animation.station = station or self.enum.PARSE_ROUND_SKILL
    animation.startTime = obj.pathTime
    animation.endTime = obj.pathTime

    if 0 ~= fightSkillObject.order.guid then
        animation.obj = obj
    end

    if self.disillusion_station then
        animation = nil
    end

    if not station then
	    self:check_fight_end(time, animation)
	end
	
    self.last_role_guid = fightSkillObject.order.guid
    return animation
end

--战斗结束
function __this:fight_end()
    if not self.fight_id then
        return
    end

    self.station = self.enum.FIGHT_WAIT_QUIT

    --假战斗直接退出战场
    if self.collaborationist then
        self:releaseAll()
    	return
    end

    Command.run("loading wait show", "fight")
    self.winCamp = self.theFight:getWinCamp()
    self:parseRewardFlyBox()
    --记录左方阵营阵亡数量
    self.leftDeadSoldierCount = self.theFight:getLeftDeadSoldierCount()
    
    --战报
    if self.record then
        CopyData.fightData = nil
        CopyData.getBossReward = nil

    --副本以外战斗通用逻辑
    elseif const.kFightTypeCopy ~= self.fight_type then
        local is_roundout = 0
        if self.theFight:getRound() >= self.theFight:getFightMaxRound() then
            is_roundout = 1
        end
        Command.run(
            "fight clientend",
            self.theFight.fight_id, 
            self.theFight.orderList, 
            self.theFight:getEndUserInfo(),
            self.winCamp,
            is_roundout, 
            self.theFight:getFightEndInfo()
        )
        return

    --普通未通关副本
    elseif CopyData.isFightBoss == false then
        CopyData.fightData = {
            order_list = self.theFight.orderList, 
            fight_info_list = self.theFight:getEndUserInfo(), 
            isWin = (self.theFight:getWinCamp() == trans.const.kFightLeft)}
        local u_copy = CopyData.user.copy
        if #u_copy.chunk == 1 then
            CopyMgr.commitNormalFight(self.theFight.fight_id)
        end

    --已通关副本、精英副本
    else
        if self.theFight:getWinCamp() == 1 then
            local data = 
            {
                fight_id = self.theFight.fight_id,
                order_list = self.theFight.orderList, 
                fight_info_list = self.theFight:getEndUserInfo()
            }
            Command.run("copy commitFightBoss", data)
            LogMgr.debug(">>>>>>>>>>>>>>>>>Commit Fight Boss......")
        else
            CopyData.getBossReward = nil
            LogMgr.debug(">>>>>>>>>>>>>>>>>Lose to Fight Boss......")
        end
    end

	   --  if CopyData.isFightBoss == false then
    --         if self.fight_type ~= const.kFightTypeCopy and not self.order_list then

    --             if #self.fight_info_list > 1 then
    --                 ActionMgr.save( 'fight', 
    --                     'PQCommonFightClientEnd type:' .. self.fight_type 
    --                     .. "  id:" .. self.fight_id  
    --                     .. "  player_guid:" .. self.fight_info_list[2].player_guid
    --                     .. "  guid:" .. self.fight_info_list[2].guid )
    --             end

    --             Command.run(
    --                 "fight clientend",
    --                 self.theFight.fight_id, 
    --                 self.theFight.orderList, 
    --                 self.theFight:getEndUserInfo() 
    --             )

    --             return
    --         end
    --         CopyData.fightData = {
    --             order_list = self.theFight.orderList, 
    --             fight_info_list = self.theFight:getEndUserInfo(), 
    --             isWin = (self.theFight:getWinCamp() == trans.const.kFightLeft)}
    --         local u_copy = CopyData.user.copy
    --         if #u_copy.chunk == 1 then
    --             CopyMgr.commitNormalFight(self.theFight.fight_id)
    --         end
    --     else
    --         if self.theFight:getWinCamp() == 1 then
    --             local data = {
    --                 fight_id = self.theFight.fight_id,
    --                 order_list = self.theFight.orderList, 
    --                 fight_info_list = self.theFight:getEndUserInfo()
    --             }
    --             Command.run("copy commitFightBoss", data)
    --             LogMgr.debug(">>>>>>>>>>>>>>>>>Commit Fight Boss......")
    --         else
    --             CopyData.getBossReward = nil
    --             LogMgr.debug(">>>>>>>>>>>>>>>>>Lose to Fight Boss......")
    --         end
    --     end
    -- 	-- else
    -- 		-- GutMgr:pushLog( const.kGutTypeFight, self.gut.step, self.theFight.orderList, self.theFight:getEndUserInfo() )
    -- 	-- end
    -- end

    if #self.fight_info_list > 1 then
        ActionMgr.save( 'fight', 
            'fight_end win_camp:' .. self.theFight:getWinCamp() .. ' type:' .. self.fight_type 
            .. "  id:" .. self.fight_id  
            .. "  player_guid:" .. self.fight_info_list[2].player_guid
            .. "  guid:" .. self.fight_info_list[2].guid )
    end

	self:fight_quit(0, self.theFight:getWinCamp(), self.coins)
end

--处理战斗结果和退出战斗系统
function __this:fight_quit(check_result, win_camp, coins_list)
    LogMgr.log('FightDataMgr', "%s", "check result" .. check_result)
    Command.run("loading wait hide", "fight")
    if not self.record then
        CopyData.isFightBoss = false
    end

    --验证通过
    if 0 ~= check_result then
        ActionMgr.save("fight", "check_result == 0")
        self:releaseAll()
        return
    end
    
    local function callback()
        self:releaseAll()
    end
    PopMgr.checkPriorityPop("FightResultUI", PopOrType.Com, function()
        Command.run('ui show', "FightResultUI", PopUpType.SPECIAL, true)
        local resultUI = PopMgr.getWindow("FightResultUI")
        if resultUI then
            resultUI:showResult(self.theFight:getWinCamp(), coins_list, callback)
        end
    end)

    ActionMgr.save("fight", "role release start")
    for __, role in pairs(FightRoleMgr) do
        role:releaseAll()
    end
    ModelMgr:releaseUnFormationModel()
    ActionMgr.save("fight", "role release end")
end

function __this:saveFightLog()
    if not self.save_fight_log then
        return
    end

    local date = GameData.getServerDate()
    local stream = seq.object_to_stream("SFightClientLog", self.clientLog)
    seq.write_stream_file("cbm/fight_log" .. date.month .. date.day .. date.hour .. date.min .. ".cbm", stream)
end

function __this:releaseAll()
    if not self.fight_id then
        return
    end

    Command.run("loading wait hide", "fight")
    self:TimerStop()
    self:saveFightLog()
    if self.debug then
        wdebug.stop_ccobj_log()
    end

	ActionMgr.save("fight", "releaseAll start")
    LogMgr.log('FightDataMgr', "%s", "*****************FightDataMgr:releaseAll*****************")

    ActionMgr.save("fight", "delFight")
    theFightList.delFight(self.fight_id)
    self.theScene:getEventDispatcher():removeEventListener(self.listener)

    self:TimerStop() 
    --预出手数据结构
    self.vsPlayerRoundSoldier = nil
    --未归类事件 [开始与结束时间为一致][1:图腾功能锁上   2:图腾功能解锁]
    self.othersAnimationList = {}
    --掉落物品事件列表
    self.rewardItemAnimationList1 = {}
    self.rewardItemAnimationList2 = {}
    --掉落物品列表
    self.rewardItemList = {}
    --全屏buff事件
    self.colonyBuffAnimationList = {}
    --十字军试炼总量事件
    self.trialEndInfoAnimationList = {}
    --场景语音事件
    self.sceneSoundAnimationList = {}

    ActionMgr.save("fight", "ui start")
    if self.mainchat then
        self.mainchat:onClose()
        self.mainchat:removeFromParent()
        self.mainchat = nil
    end
    if self.paomaui then 
       self.paomaui:removeFromParent()
       EventMgr.removeListener(EventType.PaomaEvent, self.showPaomaUI)  
    end
    if not self.test and self.theFightUI then
        self.theFightUI:releaseAll()
        self.theFightUI = nil
    end

    local resultUI = PopMgr.getWindow("FightResultUI")
    if resultUI then
        resultUI:removeFromParent()
    end
    ActionMgr.save("fight", "ui end")

    ActionMgr.save("fight", "view start")
    for __, role in pairs(FightRoleMgr) do
        role:releaseAll()
        role:releaseLayer()
    end

    FightAnimationMgr:releaseAll()
    FightTotemMgr:releaseAll()
    FightEffectMgr:releaseAll()
    FightTextMgr:releaseAll()
    FightTextMgr:releaseReward()
    FightNumberMgr:releaseAll()
    ActionMgr.save("fight", "view end")
    
    self.listState = {}
    self.totemTime = 0
    self.runTime = 0

    self.theScene = nil
    self.fight_id = nil
    --假战斗标识
    self.collaborationist = nil
    self.gut = nil
    --自动战斗
    self.autoFight = nil
    self.round = 0
    -- self.fight_type = 0     --战斗类型标识 [不清空，以便外部访问上一场战斗的类型]
    self.seqno = 0
    self.copy_stars = 0
    self.pause = nil
    self.coins = nil
    self.disillusion_station = nil
    self.totem_btn_lock = nil
    self.totem_btn_Enable = nil
    self.totem_btn_induct_lock = nil
    self.totem_btn_right_lock = nil
    self.load_fight_log = nil
    self.order_list = nil
    self.initFinish = nil
    self.record = nil
    --引导标识
    self.fight_induct = nil
    self.copy_id = nil
    self.monster_id = nil
    self.copy_monster_id = nil
    --帧频减半标识
    self.jump_frame = 1
    self.last_role_guid = 0
    self.copy_boss = nil
    self.copy_boss_id = nil
    self.speed = 1
    self.pauseLock = nil
    self.autoFightFlag = nil
    
    ActionMgr.save("fight", "layer start")
    if not self.testRoleShow then
        if self.layerTop then
            self.layerTop:removeFromParent()
            self.layerTop:release()
            self.layerTop = nil
        end
        if self.layerBlackRole then
            self.layerBlackRole:removeFromParent()
            self.layerBlackRole:release()
            self.layerBlackRole = nil
        end
        if self.layerBlackEffect then
            self.layerBlackEffect:removeFromParent()
            self.layerBlackEffect:release()
            self.layerBlackEffect = nil
        end
        if self.layerNumber then
            self.layerNumber:removeAllChildren()
            self.layerNumber:removeFromParent()
            self.layerNumber:release()
            self.layerNumber = nil
        end
        if self.layerUI then
            self.layerUI:removeFromParent()
            self.layerUI:release()
            self.layerUI = nil
        end
        if self.layerRed then
            self.layerRed:removeFromParent()
            self.layerRed:release()
            self.layerRed = nil
        end
        if self.layerBackground then
            self.layerBackground:removeFromParent()
            self.layerBackground:release()
            self.layerBackground = nil
        end
        if self.layerEffect then
            self.layerEffect:removeFromParent()
            self.layerEffect:release()
            self.layerEffect = nil
        end
        if self.layerHp then
            self.layerHp:removeFromParent()
            self.layerHp:release()
            self.layerHp = nil
        end
        if self.layerColonyEffect then
            self.layerColonyEffect:removeFromParent()
            self.layerColonyEffect:release()
            self.layerColonyEffect = nil
        end
        if self.layerScene then
            self.layerScene:removeFromParent()
            self.layerScene:release()
            self.layerScene = nil
        end
    end
    ActionMgr.save("fight", "layer end")

    -- 恢复是否竞技场战斗标记 By 胡景江
    SoundMgr.isArena = false

    ActionMgr.save("fight", "releaseAll end")
    TimerMgr.runNextFrame( function()
        ModelMgr:releaseUnFormationModel()
        PopMgr.releaseWin("FightDataMgr")
        
        if self.debug then
            TimerMgr.runNextFrame(function ()
                local log = wdebug.get_ccobj_log()
                LogMgr.log( 'error', "%s", 'memory leak count: ' .. #log )
                
                -- for i = 1, #log do
                --     LogMgr.log( 'error', 'memory leak at - ' .. i .. "\n" .. log[i] )
                -- end
            end)
        end

        TimerMgr.runNextFrame( function()
            EventMgr.dispatch(EventType.FightEnd)
            end)
        if SceneMgr.isSceneName('fight') then
            Command.run( 'scene leave' )
        end
    end)
end

--人物图层专用排序
function __this.sort(t)
	local list = {}
	for __, role in pairs(t) do
        if role.playerView then
            local index = #list + 1
    		for i = #list, 1, -1 do
    			local src = list[i]
                if src.playerView:getPositionY() < role.playerView:getPositionY() then
                    index = i
                end
            end
    		
            table.insert(list, index, role)
        end
	end
	
	return list
end

--战斗循环
function __this:idle( ... )
    if self.pause or not self.initFinish then
        return
    end

    local obj = {...}
    self.totemTime = self.totemTime + obj[1] * self.speed
	local time = math.floor(self.totemTime * 1000)

    if not self.test and self.theFightUI then
        self.theFightUI:idle(time)
    end

	if FightTotemMgr:idle(time, self.round) then
		return
	end
	
    self.runTime = self.runTime + obj[1] * self.speed
	time = math.floor(self.runTime * 1000)
    --未归类事件 [优先级高于全局状态事件]
    self:runOthers(time)
    --处理全局状态事件
    self:runStationList(time)
    if self.pause then
        return
    end
    
    --掉落物品
    self:runReward(time, self.rewardItemAnimationList1)
    self:runReward(time, self.rewardItemAnimationList2)
    --全屏buff事件动画
    self:runColonyBuff(time)
    --十字军试炼总量事件
    self:runTrialEndInfo(time)
    self:runSceneSound(time)
    
    if not self.testRoleShow then
        local list = FightRoleMgr:getSoldierList()
        list = self.sort(list)
    	
        for i, role in pairs(list) do
            if role.playerView then
                role.playerView:setLocalZOrder(i * 2)
                if role.layer then
                    role.layer:setLocalZOrder(i * 2 + 1)
                end
    			
    			if not role:checkAttr(trans.const.kAttrTotem) then
    				self:runAnythings(time, role, true)
    			end
            end
        end
    end

    --速战速决
    if self.autoFightFlag 
        and self.autoFight 
        and self.enum.FIGHT_END ~= self.station 
        and self.enum.FIGHT_WAIT_QUIT ~= self.station
        and not self:checkEnd()
        then
        self.listState = {}
        self.station = self.enum.PARSE_SECOND_SKILL
    end

    if self.enum.SLEEP == self.station then
        --do anything

        --玩家 Vs玩家
        return

    --检测战斗完全结束
    elseif self.enum.CHECK_FIGHT_END == self.station then
        self:check_fight_end(time)

    --解释当前LOG
    elseif self.enum.PARSE_ROUND_SKILL == self.station then
        self:parse_round_skill(time)
        
    --解释下一出手者预施放表现
    -- elseif self.enum.PARSE_ROUND_SOLDIER == self.station then
    --     self:parse_round_soldier(time)
        
    --解释图腾技能
    elseif self.enum.PARSE_SECOND_SKILL == self.station then
        --秒杀
        self:check_second_skill(time)
        
    --战斗结束
    elseif self.enum.FIGHT_END == self.station then
        self:fight_end(time)
        
    --等待退出战斗系统
    elseif self.enum.FIGHT_WAIT_QUIT == self.station then
        --quit fightscene
         -- local resultUI = PopMgr.getWindow("FightResultUI")
         -- if resultUI then
         --     resultUI:idle(time)
         -- end
    end
end

local function fight_idle(...)
    FightDataMgr:idle(...)
end

function __this:fightStart()
    --设置战斗盘古初开状态
    self.station = self.enum.SLEEP
    self.totemTime = 0
    self.runTime = 0
    self.timerId = TimerMgr.startTimer( fight_idle, 0.001, false )
end

--场景数据初始化
function __this:sceneInit()
    self:init()
	LogMgr.log('FightDataMgr', "%s", "loading fight resource finish")

    local list = FightRoleMgr:getSoldierList()
    if not self.test then
        self.theFightUI = FightUI:create(self.theFightUI)
    end
    if not self.testRoleShow then
        for __, role in pairs(list) do
            role:initView()
        end
    end

    local layerRole = self:getLayerRole()
    if not self.test then
        if self.theScene ~=  layerRole:getParent() then
            layerRole:removeFromParent()
            self.theScene:addChild(layerRole, 101)
        else
            layerRole:setLocalZOrder(101)
        end
    end
	
    if not self.testRoleShow then
        for __, role in pairs(list) do
            if layerRole ~= role.playerView:getParent() then
                role.playerView:removeFromParent()
                layerRole:addChild(role.playerView)
            end

            if role.layer and not role.layer:getParent() then
                layerRole:addChild(role.layer)
            end

    		local p = role.station:pos()
            role.playerView:setPosition(p)
-- function (touch, eventType)
                -- local index = FightRoleMgr:hitTest(touch, true, true)
                -- if role:checkAttr(const.kAttrTotem) then
                    -- UIMgr.addTouchBegin(role.playerView.playerView, function(touch)
                        -- if not role or not role.fightSoldier then
                        --     return
                        -- end

                        -- if FightRoleMgr:hitTest(touch, true, true) then
                        --     TipsMgr.showTips(role.station:pos(), TipsMgr.TYPE_TOTEM, role.totem_glyph, role.totem_glyph_list)
                        -- end
                    -- end)
                -- end
            -- end)
        end
    end
    local function touchBeginHandler(touch, eventType)
        local index = FightRoleMgr:hitTest(touch:getLocation(), true, true)
        if not index then
            return
        end

        local station = FightData.stationList:get(index)
        if not station then
            return
        end

        local role = FightRoleMgr:getByIndex(station.isMirror, station.index)
        if not role or not role:checkAttr(const.kAttrTotem) then
            return
        end

        TipsMgr.showTips(role.station:pos(), TipsMgr.TYPE_TOTEM, role.totem_glyph, role.totem_glyph_list)
    end
    UIMgr.addTouchBegin(SceneMgr.getCurrentScene(), touchBeginHandler)
    if self.osclock then
        print(os.clock())
    end

    if not self.test then
        self:getLayerUI():addChild(self.theFightUI)
        self.theFightUI:show()

        if not self.collaborationist then
            self.mainchat = MainUIMgr.getMainChat()
            UICommon.showSubUI(self.mainchat, 8, 0.5)
            MainUIMgr.checkChatShow(self.mainchat)
            if self.paomaui ~= nil then 
                self.paomaui:onShow()
            end
            self:getLayerUI():addChild(self.mainchat)
            self.mainchat:setPositionX(190)

            self.paomaui = MainUIMgr.getPaomaUI()
            self.paomaui:setPositionX(366)
            self:getLayerUI():addChild(self.paomaui, 1000)
            UICommon.showSubUI(self.paomaui, 9)
            self.paomaui:init()
            self.showPaomaUI = function(flag)
                if self.paomaui ~= nil and self.paomaui.setVisible ~= nil then 
                    self.paomaui:setVisible(flag)
                end
                self.paomaui:setPositionX(366) 
            end 
            EventMgr.addListener(EventType.PaomaEvent, self.showPaomaUI)  
            
            -- self.mainchat:setPositionY(self.mainchat:getPositionY() + 10)
        end
    end

    self.listener = cc.EventListenerTouchOneByOne:create()
    self.listener:registerScriptHandler(function (touch, event)
        self.touchBeginPt = touch:getLocation()
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    self.listener:registerScriptHandler(function (touch, event)
        if cc.pGetDistance(self.touchBeginPt, touch:getLocation()) < 50 then
            return
        end

        self:parseRewardFlyBox()
    end, cc.Handler.EVENT_TOUCH_ENDED)
    self.theScene:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self.theScene)
end

--资源预加载
function __this:loadResource()
    if self.debug then
        wdebug.clear_ccobj_log()
        wdebug.start_ccobj_log()
    end

    if #self.fight_info_list > 1 then
        ActionMgr.save( 'fight', 
            'start type:' .. self.fight_type 
            .. "  id:" .. self.fight_id  
            --.. "  player_guid:" .. self.fight_info_list[2].player_guid
            .. "  guid:" .. self.fight_info_list[2].guid )
    end

    ActionMgr.save("fight", "scene enter")
    self.theScene = SceneMgr.getCurrentScene()
    if "fight" ~= self.theScene.name then
        Command.run( 'scene enter', 'fight' )
        self.theScene = SceneMgr.getCurrentScene()
    end
    
    Command.run("loading wait hide", "copy")
    Command.run("loading wait hide", "trian")
    Command.run("loading wait hide", "tomb")
    self.theScene.bg:changeScene("normal")

    if self.osclock then
        print(os.clock())
    end

    ActionMgr.save("fight", "timer start")
    --定时器触发
    FightDataMgr:fightStart()

    ActionMgr.save("fight", "anything view init")
    --战斗场景相关操作
    FightDataMgr:sceneInit()

    ActionMgr.save("fight", "odd init")
    --战前buff初始化
    FightAnimationMgr:initOdd()

    self.speed = 1.2
    --出手顺序
    self.ackNo = 0
    self.initFinish = true
    ActionMgr.save("fight", "EventType FightBegin")
    TimerMgr.runNextFrame( function()
        EventMgr.dispatch(EventType.FightBegin)
        end)

    ActionMgr.save("fight", "releaseIdleness")
    --清除多余模型
    ModelMgr:releaseIdleness()

    --debug模式
    if self.load_fight_log then
        self:parse_debug()
    end

    if self.osclock then
        print(os.clock())
    end

    --引导
    if 1021 == self.fight_induct then
        local animation = FightData.newAnimation()
        animation.startTime = 0
        animation.endTime = 0
        animation.attr = 9
        animation.val = 5
        table.insert(self.othersAnimationList, animation)

    elseif 1041 == self.fight_induct then
        local animation = FightData.newAnimation()
        animation.startTime = 0
        animation.endTime = 0
        animation.attr = 9
        animation.val = 6
        table.insert(self.othersAnimationList, animation)

        list = FightRoleMgr:getLeft()
        for __, role in pairs(list) do
            if role:checkAttr(const.kAttrSoldier) and self.special_id == role.fightSoldier.soldier_id then
                self.special_role = role
                break
            end
        end
    end
end
function __this.addAckNo()
    -- body
    __this.ackNo = __this.ackNo + 1
end

function __this:sendSeqno()
	self.seqno = self.seqno + 1
    Command.run("fight syn", self.fight_id, self.seqno)

    LogMgr.debug("fight syn", self.seqno)
end

--服务器与客户端参战人员数据初始化
function __this:addFightUser(fight_id, seed, list)
    self.theFight = theFightList.initFight(fight_id, seed)

    for _, user in pairs(list) do
        self.theFight:addFightUser(user)
    end

    if self.save_fight_log then
        self.clientLog = SFightClientLog:new(fight_id, 0, seed, list)
    end

    return FightAnimationMgr:initPlayerInfo( list )
end

--debug入口
function __this:fightDebug()
    if not self.client_log_path or not cc.FileUtils:getInstance():isFileExist(self.client_log_path) then
        return false
    end

    self.load_fight_log = true
    self.save_fight_log = nil

    local stream = seq.read_stream_file( self.client_log_path )
    local data = seq.stream_to_object( 'SFightClientLog', stream )

    self.fight_id = data.fight_id
    self.leftHpMax = 0
    self.rightHpMax = 0
    self.fight_info_list = data.fight_info_list
    self.copy_stars = 0

    if not self:addFightUser(data.fight_id, data.fight_randomseed, data.fight_info_list) then
        return false
    end

    self.clientLog = data
    self.fight_type = data.fight_type
    self.theFight:setFightType(self.fight_type)
    self:loadResource()

    return true
end

--战斗入口
function __this:fightEnter(msg)
    if self.osclock then
        print(os.clock())
    end

    if self:fightDebug() then
        return
    end

    if not msg then
        self:firstShow()
        return
    end

    ActionMgr.save("fight", "fightEnter")
    -- self.msg = clone(msg)
    self:recordEnter(msg, true)
end

--竞技场入口
function __this:SingleArenaEnter(msg)
    self:recordEnter(
        {
            fight_id=msg.fight_id,
            fight_type=msg.fight_type,
            fight_randomseed=msg.fight_randomseed,
            fight_info_list=msg.fight_info_list,
            order_list=msg.order_list
        }
    )
end

--战报入口
function __this:recordEnter(msg, other)
    if self.fight_id then
        return
    end

	self.fight_id = msg.fight_id
	self.leftHpMax = 0
	self.rightHpMax = 0
	self.fight_info_list = msg.fight_info_list
    self.copy_stars = 0
    self.coins = {}

    local seed = {}
    seed.value = msg.fight_randomseed
    if not self:addFightUser(msg.fight_id, seed, msg.fight_info_list) then
        ActionMgr.save("fight", "addFightUser error")
        return
    end

    self.fight_type = msg.fight_type
    self.order_list = msg.order_list
    self.theFight:setFightType(self.fight_type)

    if self.order_list and #self.order_list > 0 then
        table.remove(self.order_list, 1)
    end

    --竞技场特殊处理
    if 
        const.kFightTypeSingleArenaPlayer == FightDataMgr.fight_type
        or const.kFightTypeSingleArenaMonster == FightDataMgr.fight_type
    then
        self.autoFight = true
        FightDataMgr.theFight:setAutoFight(1, const.kFightLeft)
        FightDataMgr.theFight:setAutoFight(1, const.kFightRight)
    end

    self:loadResource()

    if other then
        return
    end
    
    --战报禁用图腾按钮
    local animation = FightData.newAnimation()
    animation.startTime = 0
    animation.endTime = 0
    animation.attr = 1
    table.insert(self.othersAnimationList, animation)
end

--入口
-- function __this:gutEnter(fight_id, fight_randomseed, fight_info_list, gut)
--     if self.fight_id then
--         return
--     end

-- 	self.fight_id = fight_id
-- 	self.leftHpMax = 0
-- 	self.rightHpMax = 0
-- 	self.fight_info_list = fight_info_list
--     self.copy_stars = 0
--     self.gut = gut
--     self.coins = {}

--     local seed = {}
--     seed.value = fight_randomseed
--     if not self:addFightUser(fight_id, seed, fight_info_list) then
--         return
--     end

--     self.fight_type = const.kFightTypeCommon
--     self:loadResource()
-- end

--副本战斗入口
function __this:copyEnter(fight, fight_randomseed, coins, normal, gut)
    if self.fight_id then
        return
    end

    if self.osclock then
        print(os.clock())
    end
    
	self.fight_id = fight.fight_id
    self.fight_type = fight.fight_type
	self.leftHpMax = 0
	self.rightHpMax = 0
	self.fight_info_list = fight.fight_info_list
    self.copy_stars = CopyData.getCurCopyStars()
    self.coins = {}
    self.gut = gut
    self.copy_id = 0
    self.monster_id = 0

    local monster = findMonster(fight.def_id)
    if monster and 2 == monster.type then
        self.copy_boss_id = fight.def_id
        self.copy_boss = true
        if not table.empty(coins) then
            table.insert(self.coins, {cate=const.kCoinBox, objid=1, val=1})
        end
    else
        for __, coin in pairs(coins) do
            if const.kCoinTeamXp ~= coin.cate then
                if const.kCoinItem ~= coin.cate then
                    table.insert(self.coins, coin)
                else
                    for i = 1, coin.val, 1 do
                        table.insert(self.coins, {cate=coin.cate, objid=coin.objid, val=1})
                    end
                end
            end
        end
    end

    ActionMgr.save("fight", "copyEnter")

    local seed = {}
    seed.value = fight_randomseed
    if not self:addFightUser(fight.fight_id, seed, fight.fight_info_list) then
        ActionMgr.save("fight", "addFightUser error")
        return
    end

    if normal then
        local obj = CopyData.getCurrCopyMonster()
        if obj then
            self.copy_id = obj.copy_id
            self.monster_id = obj.monster_id

            if 1011 == self.copy_id then
                self.fight_induct = 1011

                local animation = FightData.newAnimation()
                animation.startTime = 0
                animation.endTime = 0
                animation.attr = 7
                table.insert(self.othersAnimationList, animation)
                self.pauseLock = true

            elseif 1021 == self.copy_id then
                self.fight_induct = 1021
                self.pauseLock = true

            -- elseif 1031 == self.copy_id then
            --     self.fight_induct = 1031
            --     self.pauseLock = true

            -- elseif 1041 == self.copy_id then
            --     self.fight_induct = 1041
            --     local animation = FightData.newAnimation()
            --     animation.startTime = 0
            --     animation.endTime = 0
            --     animation.attr = 7
            --     table.insert(self.othersAnimationList, animation)
            --     self.pauseLock = true

            elseif 1051 == self.copy_id then
                self.pauseLock = true

            elseif 2061 == self.copy_id then
                self.fight_induct = 2061
                local animation = FightData.newAnimation()
                animation.startTime = 0
                animation.endTime = 0
                animation.attr = 7
                table.insert(self.othersAnimationList, animation)
                self.pauseLock = true
            end
        end
    end

    self:loadResource()
end

--假战斗入口[脱机版本]
function __this:firstShow()
    self.copy_stars = 0
	local msg = self:createFirstShowData()
    if not msg then
        return
    end

	self.collaborationist = true
	self:fightEnter(msg)
end

--创建第一场假战斗数据
function __this:createFirstShowData()
    local first = findGlobal("first_show_fight_monster1")
    local second = findGlobal("first_show_fight_monster2")
    if not first and not second then
        return nil
    end

    local guid = 1
    local msg = {fight_id = 1024, fight_randomseed = 1024, fight_info_list = {}, fight_type = const.kFightTypeCommon}
    local first_monster = findMonster(tonumber(first.data))
    for _, first_id in pairs(first_monster.fight_monster) do
        local playerInfo, temp_guid = FightCollaborationistMgr:createUser(first_id, guid, trans.const.kFightLeft)
        guid = temp_guid + 1
        if not playerInfo then
            return
        end
        table.insert(msg.fight_info_list, playerInfo)
    end

    local second_monster = findMonster(tonumber(second.data))
    for _, second_id in pairs(second_monster.fight_monster) do
        local playerInfo, temp_guid = FightCollaborationistMgr:createUser(second_id, guid, trans.const.kFightRight)
        guid = temp_guid + 1
        if not playerInfo then
            return
        end
        table.insert(msg.fight_info_list, playerInfo)
    end

    return msg
end

--检测是否在战斗中
function __this:fighting()
    if self.fight_id then
        return true
    end

    return false
end

--战斗暂停
function __this:fightPause()
    ActionMgr.save("fight", "fightPause")
    if not self:fighting() then
        return
    end
    self.pause = true
    SoundMgr.pauseAllEffect()
end

--战斗继续
function __this:fightContinue()
    ActionMgr.save("fight", "fightContinue")
    if not self:fighting() then
        return
    end
    self.pause = nil
    SoundMgr.resumeAllEffect()
end

------------------剧情引导专用-----------------start
--获取图腾能量条
function __this:fightTotemPro()
    return self.theFightUI and self.theFightUI.totemUI:getPro() or nil
end

--获取当前图腾按钮[剧情引导专用]
function __this:fightTotemBtn()
    return  self.theFightUI and self.theFightUI.totemUI:getCollBtn() or nil
end

--触发当前图腾按钮[剧情引导专用]
function __this:fightTotemFire()
    return  self.theFightUI and self.theFightUI.totemUI:skillFire() or nil
end

--获取场景中老牛的显示对象
function __this:getSoldierView()
    -- body
    if not self.special_role then
        return nil
    end

    return self.special_role.playerView
end
------------------剧情引导专用-----------------end

-------------------------调试模式-------------------------start
function __this:getMiniLog()
    local attr = ''
    local totem_time = 0xfffff0
    local time = totem_time
    if not table.empty(self.clientLog.round_data_list) then
        if totem_time >= self.clientLog.round_data_list[1].totem_time then
            totem_time = self.clientLog.round_data_list[1].totem_time
            time = self.clientLog.round_data_list[1].time
            attr = "round_data_list"
        end
    end

    if not table.empty(self.clientLog.round_soldier) then
        if totem_time >= self.clientLog.round_soldier[1].totem_time then
            totem_time = self.clientLog.round_soldier[1].totem_time
            time = self.clientLog.round_soldier[1].time
            attr = "round_soldier"
        end
    end

    if not table.empty(self.clientLog.totem_skill_list) then
        if totem_time >= self.clientLog.totem_skill_list[1].totem_time then
            totem_time = self.clientLog.totem_skill_list[1].totem_time
            time = self.clientLog.totem_skill_list[1].time
            attr = "totem_skill_list"
        end
    end

    return time, totem_time, attr
end
function __this:parse_debug()
    while (
        not table.empty(self.clientLog.round_data_list) 
        or not table.empty(self.clientLog.round_soldier)
        or not table.empty(self.clientLog.totem_skill_list)
        ) do
        local time, totem_time, attr = self:getMiniLog()
        self.totemTime = totem_time / 1000
        self.runTime = time / 1000
        if '' ~= attr then
            local data = table.remove(self.clientLog[attr], 1)
            if "totem_skill_list" == attr then
                local __time = totem_time
                -- for __, log in pairs(data.log_list) do
                    local role = FightRoleMgr:getRole(data.log_list[1].order.guid)

                    FightTotemMgr:parseTotem(__time, role, data.log_list)
                    -- FightTotemMgr.round = log.round
                -- end
            elseif "round_soldier" == attr then
                self.client_round_soldier = FightAnimationMgr:parseFightSkillObject(time, data.skill_object)
            elseif "round_data_list" == attr then
                local __time = time
                for __, log in pairs(data.log_list) do
                    local role = FightRoleMgr:getRole(log.order.guid)
                    if not role or not role:checkAttr(const.kAttrTotem) then
                        __time, role = FightAnimationMgr:parseLog(__time, log, self.client_round_soldier)
                        self.client_round_soldier = nil
                        self.round = log.round

                        if role then
                            role.lastTime = __time
                        end
                    end
                end
            end
        end
    end

    self.totemTime = 0
    self.runTime = 0
end
-------------------------调试模式-------------------------end

-------------------------PVP执行逻辑-------------------------start
--战斗技能返回	[obj:施放方预出手数据]
function __this:roundDataPro(msg)
	LogMgr.debug("roundDataPro")
	if msg.fight_id ~= self.fight_id or 0 == #msg.fightlog then
		return
	end

	self.station = self.enum.SLEEP
	local time = math.ceil(self.runTime * 1000)

    -- LogMgr.log( 'FightDataMgr', debug.dump(SFightLog) )

    --图腾技能特殊处理
    if 0 ~= msg.fightlog[1].order.guid then
    	local role = FightRoleMgr:getRole(msg.fightlog[1].order.guid)
    	if role and role:checkAttr(const.kAttrTotem) then
    		FightTotemMgr:parseTotem(time, role, msg.fightlog)
    		return
    	end
    end
	
    local animation = FightData.newAnimation()
    animation.station = self.enum.PRO_DOUBLE_ROUND_DATA
    animation.startTime = time
    animation.endTime = time

    for i, log in pairs(msg.fightlog) do
    	if 1 == i then
		    animation.endTime = FightAnimationMgr:parseLog(animation.startTime, log, self.vsPlayerRoundSoldier)
		else
			animation.endTime = FightAnimationMgr:parseLog(animation.endTime + 100, log, self.vsPlayerRoundSoldier)
		end

    	self.round = log.round
    	LogMgr.log('FightDataMgr',"当前回合：", "%s", log.round)
	end

    table.insert(self.listState, animation)
end

function __this:roundSoldierPro(msg)
	LogMgr.debug("roundSoldierPro")
	if msg.fight_id ~= self.fight_id or msg.seqno ~= self.seqno + 1 or not msg.skill_obj then
		return
	end

	self.station = self.enum.SLEEP
	local time = math.ceil(self.runTime * 1000)

	local animation = FightData.newAnimation()
	animation.station = self.enum.PRO_DOUBLE_ROUND_SOLDIER
	animation.startTime = time
	animation.endTime = time
	animation.data = msg.skill_obj

	table.insert(self.listState, animation)

	--预出手资源预加载
	loadResource(msg.skill_obj)
end
-------------------------PVP执行逻辑-------------------------end

function __this:init()
	self.round = 0
	--预出手数据结构
	self.vsPlayerRoundSoldier = nil

    if not self.testRoleShow then
        self:getLayerRole()
    end
end
function __this:getLayerTop()
    -- body
    if not self.layerTop then
        self.layerTop = cc.Node:create()
        self.layerTop:retain()
        self.theScene:addChild(self.layerTop, 1000)
    end

    return self.layerTop
end
function __this:getLayerBlackRole()
    if not self.layerBlackRole then
        self.layerBlackRole = cc.Node:create()
        self.layerBlackRole:retain()
        self.theScene:addChild(self.layerBlackRole, 202)
    end

    return self.layerBlackRole
end
function __this:getLayerBlackEffect()
    if not self.layerBlackEffect then
        self.layerBlackEffect = cc.Node:create()
        self.layerBlackEffect:retain()
        self.theScene:addChild(self.layerBlackEffect, 203)
    end

    return self.layerBlackEffect
end
function __this:getLayerNumber()
    if not self.layerNumber then
        self.layerNumber = cc.Node:create()
        self.layerNumber:retain()
        self.theScene:addChild(self.layerNumber, 201)
    end

    return self.layerNumber
end

function __this:getLayerUI()
    if not self.layerUI then
        self.layerUI = cc.Node:create()
        self.layerUI:retain()
        self.theScene:addChild(self.layerUI, 109)
    end

    return self.layerUI
end
--红屏层
function __this:getLayerRed()
    if not self.layerRed then
        self.layerRed = cc.Node:create()
        self.layerRed:retain()
        self.theScene:addChild(self.layerRed, 108)
    end

    return self.layerRed
end
--黑屏层[包含黑屏下显示的角色、特效……]
function __this:getLayerBlackground()
    if not self.layerBackground then
        self.layerBackground = cc.Node:create()
        self.layerBackground:retain()
        self.theScene:addChild(self.layerBackground, 105)
    end

    return self.layerBackground
end
function __this:getLayerEffect()
    if not self.layerEffect then
        self.layerEffect = cc.Node:create()
        self.layerEffect:retain()
        self.theScene:addChild(self.layerEffect, 103)
    end

    return self.layerEffect
end
function __this:getLayerHp()
    if not self.layerHp then
        self.layerHp = cc.Node:create()
        self.layerHp:retain()
        self.theScene:addChild(self.layerHp, 102)
    end

    return self.layerHp
end
function __this:getLayerColonyEffect()
    if not self.layerColonyEffect then
        self.layerColonyEffect = cc.Node:create()
        self.layerColonyEffect:retain()
        self.theScene:addChild(self.layerColonyEffect, 100)
    end

    return self.layerColonyEffect
end
function __this:getLayerScene()
    if not self.layerScene then
        self.layerScene = cc.Node:create()
        self.layerScene:retain()
        self.theScene:addChild(self.layerScene, 99)
    end

    return self.layerScene
end

--获取角色图层
function __this:getLayerRole()
    if not self.layerRole then
        self.layerRole = cc.Node:create()
        self.layerRole:retain()
    end

    return self.layerRole
end

--释放角色图层
function __this:releaseLayerRole()
    if not self.layerRole then
        return
    end

    self.layerRole:removeFromParent()
    self.layerRole:release()
    self.layerRole = nil
end

function __this:isNotFight()
    return self.fight_id == nil
end

FightDataMgr = __this