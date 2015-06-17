require( "lua/game/view/fight/struct/FightData.lua" )
require( "lua/game/view/fight/misc/FightFileMgr.lua" )
require( "lua/game/view/fight/struct/FightData.lua" )
require( "lua/game/view/fight/struct/UIFightRole.lua" )

--单个参战人员结构表========================start
FightRole = 
{
    const = 
    {
        --天赋
        TALK_TALENT = 0,
        --血量低于百分比三十
        TALK_HP = 1,
        --死亡
        TALK_DEAR = 2,
        --闪避
        TALK_DODGE = 3,
        --暴击
        TALK_CRIT = 4,
        --回合
        TALK_ROUND = 5,
        --技能触发
        TALK_SKILL = 6 
    },
    
    station = nil,
    body = nil,
    
    playerInfo = nil,         --战斗团队信息
    fightSoldier = nil,       --战斗人员信息
    camp = 0,                --阵营
    guid = 0,
    
    playerView = nil,         --显示对象
	hpView = nil,
    oddList = {},            --异常列表
    
    --[[oldHp = 0,       --上一次生命值
    newHp = 0,       --当前生命值
    oldRage = 0,     --上一次怒气值
    newRage = 0,     --当前怒气值--]]
    dearActionStartTime = 0xfffff0,  --死亡动作开始时间
    dearTime = 0xfffff0,
    lastTime = 0,
    
    actionType = "stand"    --动作类型
}

--清空
function FightRole:releaseAll()
    if self.playerView then
        UIMgr.removeScriptHandler(self.playerView.playerView)
    end

    self.body = nil

    self.othersAnimationList = {}       --其它事件[1:odd_status:89换血条事件]
    self.releaseAnimationList = {}      --释放动画事件
    self.actionAnimationList = {}       --动作事件
    for __, data in pairs(self.effectAnimationList) do
        if data.uiEffect then
            data.uiEffect:removeFromParent()
        end
    end
    self.effectAnimationList = {}       --特效事件
    for __, data in pairs(self.bodyEffectAnimationList) do
        if data.uiEffect then
            data.uiEffect:removeFromParent()
        end
    end
    self.bodyEffectAnimationList = {}   --身上特效事件
    self.pathAnimationList = {}         --移动事件
    for __, data in pairs(self.hpAnimationList) do
        if data.number then
            data.number:removeFromParent()
        end
    end
    self.hpAnimationList = {}           --hp变化事件
    self.rageAnimationList = {}         --rage变化事件
    self.oddAnimationList = {}          --buf事件
    self.dearAniimationList = {}        --死亡事件
    self.soundAnimationList = {}        --声音事件
    for __, data in pairs(self.skillAnimationList) do
        if data.text then
            data.text:removeFromParent()
        end
    end
    self.skillAnimationList = {}        --技能喊招
    self.diskplayAnimationList = {}  	--振动事件
    self.powerRedAnimationList = {}     --红屏事件
    self.whiteAnimationList = {}      	--白屏事件
    self.mirrorAnimationList = {}       --镜像事件
    self.colonyAnimationList = {}       --群攻特效事件
    self.callChangeAnimationList = {}   --召唤事件
    self.sceneBlackAnimationList = {}   --场景黑屏事件
	self.filtersAnimationList = {}		--滤镜事件
    self.scaleAnimationList = {}        --缩放事件
    self.dearAnimationList = {}         --死亡事件
    self.totemValueAnimationList = {}   --图腾值事件
    self.opacityAnimationList = {}      --透明度事件
    self.pauseAnimationList = {}        --停顿事件

    self.oddList = {}

    self.playerInfo = nil         --战斗团队信息
    self.fightSoldier = nil       --战斗人员信息
    self.camp = 0                --阵营
    self.guid = 0
    self.oldHp = 0
    self.oldRage = 0
    self.dearActionStartTime = 0xfffff0
    self.dearTime = 0xfffff0

    self.lastSkillRound = 0         --最后一次使用技能回合数[图腾专用]
    self.canSkillRound = 0          --下一回合可使用技能回合数[图腾专用]
    self.totemCool = 0              --技能冷却回合数[图腾专用]
    self.actionType = "stand" 
    self.lastTime = 0               --最后出手动画结束时间
    self.state = ''                 --当前状态
    self.pause = nil                --停顿状态
    
    --图层[紧次于角色上层]   [单独释放]
    -- if self.layer then
    --     self.layer:removeFromParent()
    --     self.layer:release()
    --     self.layer = nil
    -- end

    --角色
    if self.playerView then
        -- self.playerView:releaseAll()
        ModelMgr:recoverModel(self.playerView)
        self.playerView = nil
    end

    --血条
	-- if self.hpView then
        -- FightNumberMgr:unNormalHp(self.hpView)
        self.hpView = nil
	-- end
end

function FightRole:releaseLayer()
    if self.layer then
        self.layer:removeFromParent()
        self.layer:release()
        self.layer = nil
    end
end

function FightRole:new( i )
    local soldier = {}

    soldier.station = FightData.stationList:get( i )

    soldier.othersAnimationList = {}
    soldier.releaseAnimationList = {}      --释放动画事件
    soldier.actionAnimationList = {}        --动作事件
    soldier.effectAnimationList = {}        --特效事件
    soldier.bodyEffectAnimationList = {}    --身上特效事件
    soldier.pathAnimationList = {}          --移动事件
    soldier.hpAnimationList = {}            --hp变化事件
    soldier.rageAnimationList = {}          --rage变化事件
    soldier.oddAnimationList = {}           --buf事件
    soldier.dearAniimationList = {}         --死亡事件
    soldier.soundAnimationList = {}         --声音事件
    soldier.skillAnimationList = {}         --技能喊招
    soldier.diskplayAnimationList = {}  	--振动事件
    soldier.powerRedAnimationList = {}      --红屏事件
    soldier.whiteAnimationList = {}      	--白屏事件
    soldier.mirrorAnimationList = {}        --镜像事件
    soldier.colonyAnimationList = {}       	--群攻特效事件
    soldier.callChangeAnimationList = {}    --召唤事件
    soldier.sceneBlackAnimationList = {}    --场景黑屏事件
	soldier.filtersAnimationList = {}		--滤镜事件
    soldier.scaleAnimationList = {}        --缩放事件
    soldier.dearAnimationList = {}         --死亡事件
    soldier.totemValueAnimationList = {}   --图腾值事件
    soldier.opacityAnimationList = {}      --透明度事件
    soldier.pauseAnimationList = {}        --停顿事件

    soldier.oddList = {}
    
    setmetatable(soldier,self)
    self.__index = self
    return soldier
end

--初始化
function FightRole:init(playerInfo, soldier)
    self.playerInfo = playerInfo
    self.fightSoldier = FightFileMgr:copyTab(soldier)
    self.camp = playerInfo.camp
    self.guid = soldier.guid

    self.lastSkillRound = 0         --最后一次使用技能回合数[图腾专用]
    self.canSkillRound = 0          --下一回合可使用技能回合数[图腾专用]
    self.totemCool = 0              --技能冷却回合数[图腾专用]
    self.state = ''                 --当前状态
    
    if trans.const.kAttrTotem == soldier.attr then
        self.totem = findTotem(soldier.soldier_id)
        if self.totem then
            self.animation_name = self.totem.animation_name
            self.totem_level = soldier.totem.level
            if self:isMirror() and const.kAttrPlayer ~= self.playerInfo.attr then
                self.totem_level = 5
            end
            self.body = FightFileMgr:getBody(self.totem.animation_name .. self.totem_level)
            self.skill = findSkill(soldier.skill_list[1].skill_id, soldier.skill_list[1].skill_level)
            self.totemAttr = findTotemAttr(self.totem.id, 0)
            if self.totemAttr and self.totemAttr.formation_add_attr then
                self.totemOdd = findOdd(self.totemAttr.formation_add_attr.first, self.totemAttr.formation_add_attr.second)
            end
        end
    elseif trans.const.kAttrMonster == soldier.attr then
        self.monster = findMonster(soldier.soldier_id)
        if self.monster then
            self.animation_name = self.monster.animation_name
            self.body = FightFileMgr:getBody( self.monster.animation_name )
        end
    elseif trans.const.kAttrSoldier == soldier.attr then
        self.soldier = findSoldier(soldier.soldier_id)
        if self.soldier then
            self.animation_name = self.soldier.animation_name
            self.body = FightFileMgr:getBody( self.soldier.animation_name )
        end
    end

    if not self.body then
        self.body = FightFileMgr:getBody( "YS01kaien" )
        if not self.body then
            LogMgr.log( 'debug', "%s", "FightRole:init body not in YS01kaien" )
            return
        end
    end
	
	self.sound = FightFileMgr:getSound(self.body.style)

    self.hp = self.fightSoldier.hp
    self.maxHp = self.fightSoldier.last_ext_able.hp
end

function FightRole:initView()
    if self.playerView then
        self.playerView:releaseHp()
    end
    self.hpView = nil
    if self.playerView then
        ModelMgr:recoverModel(self.playerView)
    end
    
    if const.kAttrTotem == self.fightSoldier.attr then
        self.playerView = ModelMgr:useModel(self.body.style, self.fightSoldier.attr, self.animation_name, self.totem_level)
    else
        self.playerView = ModelMgr:useModel(self.body.style, self.fightSoldier.attr)
    end
    self.playerView:init(self.body, self.station.isMirror)
	
	if trans.const.kAttrTotem == self.fightSoldier.attr then
		return
	end
	
    if const.kAttrMonster == self.fightSoldier.attr then
    	self.hpView = self.playerView:initHp(const.kQualityGreen)
    else
        self.hpView = self.playerView:initHp(self.fightSoldier.quality)
    end
    self.hpView.maxHp = self.fightSoldier.last_ext_able.hp
    self.hpView.hp = self.fightSoldier.hp
    self.hpView.lastHp = self.fightSoldier.hp

    self.hpView.maxRage = 100
    self.hpView.rage = self.fightSoldier.rage
    self.hpView.lastRage = self.fightSoldier.rage

    self.layer = cc.Node:create()
    self.layer:retain()
end

--变身专用[针对已有数据]
function FightRole:attrChange(soldier, pt)
    self.fightSoldier = FightFileMgr:copyTab(soldier)
    self.guid = soldier.guid
    self.dearTime = 0xfffff0
    self.dearActionStartTime = 0xfffff0
    
    if trans.const.kAttrTotem == soldier.attr then
        self.totem = findTotem(soldier.soldier_id)
        if self.totem then
            self.body = FightFileMgr:getBody( self.totem.animation_name .. self.totem_level )
        end
    elseif trans.const.kAttrMonster == soldier.attr then
        self.monster = findMonster(soldier.soldier_id)
        if self.monster then
            self.body = FightFileMgr:getBody( self.monster.animation_name )
        end
    elseif trans.const.kAttrSoldier == soldier.attr then
        self.soldier = findSoldier(soldier.soldier_id)
        if self.soldier then
            self.body = FightFileMgr:getBody( self.soldier.animation_name )
        end
    end
    
    if not self.body then
        self.body = FightFileMgr:getBody( "BS01bdanzong" )
        if not self.body then
            LogMgr.log( 'debug', "%s", "oddChange body not in YS01kaien" )
            return
        end
    end

    self.playerView:change(self.body, self.station.isMirror)
    self.playerView:setPosition(pt)
end

function FightRole:attrCall(layer, time, user, soldier)
    for __, animation in pairs(self.actionAnimationList) do
        animation.endTime = time - 10
    end
    for __, animation in pairs(self.pauseAnimationList) do
        animation.endTime = time - 10
    end
    for __, animation in pairs(self.effectAnimationList) do
        animation.endTime = time - 10
    end
    for __, animation in pairs(self.bodyEffectAnimationList) do
        animation.endTime = time - 10
    end
    for __, animation in pairs(self.hpAnimationList) do
        FightNumberMgr:unRedNumber(animation)
    end
    self.callChangeAnimationList = {}
    self.hpAnimationList = {}

    self:init(user, soldier)
    self:initView()
    self.dearTime = 0xfffff0
    self.dearActionStartTime = 0xfffff0
    layer:addChild(self.playerView)
    self.playerView:setPosition(self.station:pos())

    if time then
        local l = string.split(FightAnimationMgr.const.REVIVE_EFFECTID, '%')
        if #l > 0 then
            local effect = FightFileMgr:getEffect(l[1])
            if effect then
                local oddSet = {set_type = trans.const.kObjectAdd}
                local odd = {id = l[1], level = 1, onceeffect = l[1]}
                local callAnimation = FightData:createBodyAnimation(time, oddSet, odd, effect, self)
                callAnimation.role = self
                self:filterBodyEffectAdd(callAnimation)
            end
        end
    end

    if self.hpView and not self.hpView:getParent() then
        self.playerView:addChild(self.hpView)
        local pt = cc.p(-self.hpView.size.width / 2, self.body.footY - self.body.headY)
        self.hpView:setPosition(pt)
    end
end

--只更新形象
function FightRole:attrModel(layer, style)
    if self.playerView then
        if style == self.playerView.body.style then
            return
        end

        if self.hpView and self.hpView:getParent() then
            self.hpView:removeFromParent()
        end
        
        ModelMgr:recoverModel(self.playerView)
        self.playerView = nil
    end

    self.playerView = ModelMgr:useModel(style)
    self.playerView:setPosition(self.station:x(), self.station:y())
    self.playerView:chnAction(self.station.isMirror, "stand")

    if self.hpView and not self.hpView:getParent() then
        self.playerView:addChild(self.hpView)
        local pt = cc.p(-self.hpView.size.width / 2, self.body.footY - self.body.headY)
        self.hpView:setPosition(pt)
    end

    layer:addChild(self.playerView)
end

function FightRole:checkAttr(attr)
    if not self.fightSoldier or attr ~= self.fightSoldier.attr then
        return false
    end

    return true
end

function FightRole:dear()
    if 0xfffff0 == self.dearTime then
        return false
    end

    return true
end

--检测并恢复当前形象是否为原形
function FightRole:recoverStyle(time)
    if not self.playerView or not self.fightSoldier or self.body.style == self.playerView.body.style then
        return
    end

    FightData:createChangeModelAnimation(time, self, self.body.style)
end

function FightRole:getLastOddEndTime( time )
--    if 0 == #self.oddAnimationList or oddAnimationList[#oddAnimationList].startTime < time then
        return time
--    end
    
--    return oddAnimationList[#oddAnimationList].startTime + 1
end

function FightRole:setHp(v)
    self.hp = self.hp + v
    if self.hp > self.maxHp then
        self.hp = self.maxHp
    elseif self.hp < 0 then
        self.hp = 0
    end
end

function FightRole:cloneFrom( role )
    role.cloneTo( self )
end

function FightRole:cloneTo( role )
    role.Body = self.Body;
    role.playerInfo = self.playerInfo;
    role.playerView.playerInfo = self.playerInfo;
    role.playerView.HorseStyle = self.playerView.HorseStyle;
    role.playerView.MainStyle = self.playerView.MainStyle;
    role.playerView.ArmsStyle = self.playerView.ArmsStyle;
    role.playerView.WingStyle = self.playerView.WingStyle;
    role.HumanModel = self.HumanModel;
    role.Monster = self.Monster;
    role.RentSoldier = self.RentSoldier;
    role.Model = self.Model;
    role.BodySound = self.BodySound;
    role.NameStyle = self.NameStyle;
    role.playerView.HpSpriteUpdate();
    role.HpMax = this.HpMax;
    -- role.SetHp( this.Hp );
    role.playerView.SetTitleForKey( GameDefine.kRoleTitleName, role.NameStyle, GetRoleNameForFight() );
    role.playerView.SetTitleForKey( GameDefine.kRoleTitleTitle, TextStyle.SSD_12, GetPlatformName() );
end

--站位
function FightRole:index()
    return self.station.index
end

--镜像
function FightRole:isMirror()
    return self.station.isMirror
end

--获得对应技能
function FightRole:getNormalSkill(i)
    if nil == self.fightSoldier or 0 == #self.fightSoldier.skill_list or i > #self.fightSoldier.skill_list then
        return nil
    end
    
    local fightSkill = self.fightSoldier.skill_list[i]
    return findSkill( fightSkill.skill_id, fightSkill.skill_level )
end

function FightRole:setOdd(oddSet)
    if not self.fightSoldier then
        return false
    end

    local del = {}
    for i, fightOdd in pairs(self.fightSoldier.odd_list) do
        if oddSet.fightOdd.id == fightOdd.id then
            if oddSet.set_type == const.kObjectDel then
                table.insert(del, i)
                break
            end
        end
    end

    for i = #del, 1, -1 do
        table.remove(self.fightSoldier.odd_list, del[i])
    end
end

--检测是否有匹配odd
function FightRole:isOdd(odd_id, odd_level)
    if not self.fightSoldier then
        return false
    end

    for __, fightOdd in pairs(self.fightSoldier.odd_list) do
        if odd_id == fightOdd.id and (not odd_level or odd_level == fightOdd.level) then
            return true
        end
    end

    return false
end

--检测是否有匹配status
function FightRole:isStatus(status_id)
    if not self.fightSoldier then
        return false
    end

    for __, fightOdd in pairs(self.fightSoldier.odd_list) do
        if status_id == fightOdd.status_id then
            return true
        end
    end

    return false
end

--检测状态
function FightRole:checkOdd(state)
--    for i = #self.oddAnimationList, 1, -1 do
--        local animation = self.oddAnimationList[i]
--        if state == animation.odd.status.Value1 then
--            if trans.const.kObjectAdd == animation.type then
--                return true
--            end
--            
--            break
--        end
--    end
    
    return false
end

--设置新异常
-- function FightRole:setOdd(newOddList)
--    for __, newOdd in pairs(newOddList) do
--        local flag = false
--        for __, odd in pairs(self.oddList) do
--            if odd.odd_id == newOdd.odd_id then
--                if odd.odd_level < newodd.odd_level then
--                    odd.start_round = newOdd.start_round
--                end
--                flag = true
--                break
--            end
--        end
--        
--        if not flag then
--            table.insert(self.oddList, newOdd)
--        end
--    end
-- end

--获取最新受击动作时间
function FightRole:updateHurtTime(time)
    if 0 == #self.hpAnimationList or time > self.hpAnimationList[#self.hpAnimationList].startTime then
        return time
    end
    
    return self.hpAnimationList[#self.hpAnimationList].startTime + 100
end

--添加位移类型
function FightRole:filterHp(animation)
	if 0 == #self.hpAnimationList then
		animation.offset = nil
	elseif not self.hpAnimationList[#self.hpAnimationList].offset then
		animation.offset = true
	else
		animation.offset = nil
	end
	
	table.insert(self.hpAnimationList, animation)
end

--获取最后动作
function FightRole:getLastAction(type)
    if 0 == #self.actionAnimationList then
        return nil
    end

    for i = #self.actionAnimationList, 1, -1 do
        local animation = self.actionAnimationList[i]
        if animation.type == type then
            return animation
        end
    end

    return nil
end

--获取最后动作的结束时间
function FightRole:getLastActionEndTime(time)
    if 0 == #self.actionAnimationList then
        return time
    end
    
    local max = time
    for i = #self.actionAnimationList, 1, -1 do
        local animation = self.actionAnimationList[i]
        max = math.max(max, animation.endTime)
    end
    
    return max + 50
end

--删除某个动作事件
function FightRole:delAction(action, count)
    local del = {}
    for i, data in pairs(self.actionAnimationList) do
        if action == data.type then
            table.insert(del, i)
            if 0 == count then
                break
            end
        end
    end
    
    for i = #del, 1, -1 do
        table.remove(self.actionAnimationList, del[i])
    end
end

--筛选动作动画数据
function FightRole:filterAction(animation)
    for i = #self.actionAnimationList, 1, -1 do
        local data = self.actionAnimationList[i]
        if data.type == animation.type and (animation.startTime <= data.endTime or data.endTime == animation.endTime) then
            return false
        end
    end
    
    table.insert(self.actionAnimationList, animation)
    return true
end

--顺延动画
--@param list 列表
--@param animation 动画事件结构体
--@param delay 时间间隔
function FightRole.deferAnimation(list, animation, delay)
    delay = 200
    local time = animation.startTime
    for i = #list, 1, -1 do
        if time - delay < list[i].startTime then
            time = list[i].startTime + delay
        end
        break
    end

    animation.endTime = animation.endTime - animation.startTime + time
    animation.startTime = time

    table.insert(list, animation)
end

--筛选重复怒气动画数据
function FightRole:setRage(animation, ackRole)
    if 0 == #self.rageAnimationList then
        table.insert(self.rageAnimationList, animation)
        return
    end

    local len = #self.rageAnimationList
    local rage = self.rageAnimationList[len]
    if animation.rage == rage.rage then
        return
    end
    
    if animation.startTime <= rage.startTime then
        animation.startTime = rage.startTime + 300
        animation.endTime = animation.startTime + 600
    end
end

--获取当前时间镜像
function FightRole:getMirror(time)
    local length = #self.mirrorAnimationList
    for i = 1, length, 1 do
        local animation = self.mirrorAnimationList[i]
        if time >= animation.endTime then
            table.remove(table,i)
        else
            if nil ~= animation.type then
                if time < animation.startTime then
                    return self.station.isMirror
                end
                
                if time < data.endTime then
                    return not self.station.isMirror 
                end
                break;
            else
                if time < animation.startTime then
                   return not self.station.isMirror 
                end
            end
            
            break
        end
    end
    
    return self.station.isMirror
end

function FightRole:getBodyEffectLastTime(time)
    local t = time
    for i = #self.bodyEffectAnimationList, 1, -1 do
        if time <= self.bodyEffectAnimationList[i].startTime then
            return time + 10
        end
    end
    
    return time
end

--单次buff特效处理
function FightRole:filterBodyEffectOnce(animation)
    local lastTime = animation.endTime + 1
    if 0 == animation.endTime then
        lastTime = animation.startTime
    end

    --全屏buff特殊处理
    if animation.odd.buff_only and 0 ~= animation.odd.buff_only then
        animation = FightData.createColonyBuffAnimation(animation, self)

        --清除相同
        if trans.const.kObjectDel == animation.oddSet.set_type then
            for __, data in pairs(FightDataMgr.colonyBuffAnimationList) do
                if data.odd.id == animation.odd.id and data.mirror == animation.mirror then
                    data.endTime = lastTime
                end
            end
            return lastTime
        end

        --一次性
        if animation.odd.onceeffect and '' ~= animation.odd.onceeffect then
            animation.startTime = lastTime
            animation.endTime = animation.effectItem.count * 25 + lastTime
            table.insert(FightDataMgr.colonyBuffAnimationList, animation)
            lastTime = animation.endTime
            return lastTime
        end
    end

    --清空
    if not animation.odd.buffeffect and not animation.odd.onceeffect then
        for __, data in pairs(self.bodyEffectAnimationList) do
            data.endTime = lastTime
        end
        return lastTime
    end

    if not animation.effect or not animation.effectItem then
        return animation.startTime
    end
    
    --清除相同
    if trans.const.kObjectDel == animation.oddSet.set_type then
        for __, data in pairs(self.bodyEffectAnimationList) do
            if data.odd.id == animation.odd.id then
                data.endTime = lastTime
            end
        end
        return lastTime
    end

    for __, data in pairs(FightDataMgr.colonyBuffAnimationList) do
        if data.odd.id == animation.odd.id and self:isMirror() == animation.mirror then
            return lastTime
        end
    end
    
    --一次性
    if animation.odd.onceeffect and "" ~= animation.odd.onceeffect then
        animation.startTime = lastTime
        animation.endTime = animation.effectItem.count * 25 + lastTime
        table.insert(self.bodyEffectAnimationList, animation)
        lastTime = animation.endTime
    end

    return lastTime
end

--重复buff特效添加筛选
function FightRole:filterBodyEffectAdd(animation)
    if animation.odd.onceeffect and "" ~= animation.odd.onceeffect then
        return self:filterBodyEffectOnce(animation)
    elseif animation.odd.buffeffect and "" ~= animation.odd.buffeffect then
        return self:filterBodyEffectBuff(animation)
    else
        return animation.startTime
    end
end

function FightRole:filterBodyEffectBuff(animation)
    local lastTime = animation.endTime + 1
    if 0 == animation.endTime then
        lastTime = animation.startTime
    end

    --全屏buff特殊处理
    if animation.odd.buff_only and 0 ~= animation.odd.buff_only then
        animation = FightData.createColonyBuffAnimation(animation, self)

        --清除相同
        if trans.const.kObjectDel == animation.oddSet.set_type then
            for __, data in pairs(FightDataMgr.colonyBuffAnimationList) do
                if data.odd.id == animation.odd.id and data.mirror == animation.mirror then
                    data.endTime = lastTime
                end
            end
            return lastTime
        end

        --重复buff
        for i = #FightDataMgr.colonyBuffAnimationList, 1, -1 do
            local data = FightDataMgr.colonyBuffAnimationList[i]
            if data.odd.id == animation.odd.id and data.mirror == animation.mirror then
                if data.oddSet.set_type ~= animation.oddSet.set_type then
                    break
                else
                    return animation.startTime
                end
            end
        end
        
        animation.startTime = lastTime
        animation.endTime = 0
        table.insert(FightDataMgr.colonyBuffAnimationList, animation)

        if 0 == animation.endTime then
            return animation.startTime
        end
        return animation.endTime
    end

    --清空
    if not animation.odd.buffeffect and not animation.odd.onceeffect then
        for __, data in pairs(self.bodyEffectAnimationList) do
            data.endTime = lastTime
        end
        return lastTime
    end

    if not animation.effect or not animation.effectItem then
        return animation.startTime
    end
    
    --清除相同
    if trans.const.kObjectDel == animation.oddSet.set_type then
        for __, data in pairs(self.bodyEffectAnimationList) do
            if data.odd.id == animation.odd.id and 0 == animation.endTime then
                data.endTime = lastTime
            end
        end
        return lastTime
    end

    for __, data in pairs(FightDataMgr.colonyBuffAnimationList) do
        if data.odd.id == animation.odd.id and self:isMirror() == animation.mirror then
            return animation.startTime
        end
    end
    
    --重复buff
    for i = #self.bodyEffectAnimationList, 1, -1 do
        local data = self.bodyEffectAnimationList[i]
        if data.odd.id == animation.odd.id and 0 == data.endTime then
            if data.oddSet.set_type ~= animation.oddSet.set_type then
                break
            else
                return animation.startTime
            end
        end
    end
    
    animation.startTime = lastTime
    animation.endTime = 0
    table.insert(self.bodyEffectAnimationList, animation)
    
    if 0 == animation.endTime then
        return animation.startTime
    end
    return animation.endTime
end

function FightRole:getSkillIndex(skill_id, skill_level)
    for i, skill in pairs(self.fightSoldier.skill_list) do
        if skill_id == skill.skill_id and skill_level == skill.skill_level then
            return i
        end
    end

    return 0
end

--滤镜事件
function FightRole:filterPetrifaction(oddSet, attr, startTime, endTime)
    if const.kObjectDel == oddSet.set_type then
        for __, data in pairs(self.filtersAnimationList) do
            if attr == data.attr and 0 == data.endTime then
                data.endTime = startTime
            end
        end

        return
    end

    local animationFilter = FightData.newAnimation()
    animationFilter.attr = attr
    animationFilter.startTime = startTime
    animationFilter.endTime = endTime
    table.insert(self.filtersAnimationList, animationFilter)
end

--停顿事件
function FightRole:filterPause(oddSet, time)
    if const.kObjectDel == oddSet.set_type then
        for __, data in pairs(self.pauseAnimationList) do
            data.endTime = time
        end

        return
    end

    local pauseAnimation = FightData.newAnimation()
    pauseAnimation.startTime = time
    table.insert(self.pauseAnimationList, pauseAnimation)
end

--过滤相同事件
function FightRole:filterEffect(animation)
    for __, data in pairs(self.effectAnimationList) do
        if animation.effectStyle == data.effectStyle and animation.startTime == data.startTime then
            return
        end
    end

    table.insert(self.effectAnimationList, animation)
end
--单个参战人员结构表========================================end



local FightRoleList = 
{
}
function FightRoleList:init( list )
    local list = list or {}
    for i = 0, 17 do
        table.insert(list, FightRole:new( i ))
    end

    setmetatable( list, self )
    self.__index = self
    return list
end

function FightRoleList:getRole( guid )
    for __, role in pairs( self ) do
        if nil ~= role.fightSoldier and guid == role.fightSoldier.guid then
            return role
        end
    end
    
    return nil
end

function FightRoleList:getByCampIndex(camp, index)
    for __, role in pairs( self ) do
        if camp == role.camp and index == role.station.index then
            return role
        end
    end

    return nil
end

function FightRoleList:getByIndex( mirror, index )
    for __, role in pairs( self ) do
        if mirror == role.station.isMirror and index == role.station.index then
            return role
        end
    end
    
    return nil
end

--获取左阵营
function FightRoleList:getLeft()
    local list = {}
    for i = 1, #self do
        if false == self[i].station.isMirror then
            table.insert(list, self[i])
        end
    end
    
    return list
end

--获取右阵营
function FightRoleList:getRight()
    local list = {}
    for i = 1, #self do
        if true == self[i].station.isMirror then
            table.insert(list, self[i])
        end
    end

    return list
end

--获取指定阵营和角色类型的参战人员列表    [camp、attr 可为 nil]
function FightRoleList:getSoldierList(camp, attr)
    local list = {}
    for __, role in pairs(self) do
        if role.fightSoldier then
            if (not camp or camp == role.camp)
                and (not attr or attr == role.fightSoldier.attr)
            then
                table.insert(list, role)
            end
        end
    end

    return list
end

--获取参战人员列表[不包含图腾]
function FightRoleList:getAllSoldier()
	local list = {}
    for __, role in pairs(self) do
        if role.fightSoldier and trans.const.kAttrTotem ~= role.fightSoldier.attr then
            table.insert(list, role)
        end
    end
    
    return list
end

--异常状态【爆炸】专用检测接口
function FightRoleList:checkBombByLog(log)
    local role = self:getRole(log.order.guid)
    if not role or role:checkOdd(trans.const.kFightOddSneak) then
        return false
    end
    
    for __, orderTarget in pairs(log.orderTargetList) do
        role = self:getRole(orderTarget.role_id)
        if role and role:checkOdd(trans.const.kFightOddBomb) then
            return true
        end
    end
    
    return false
end


local a1, b1 = 55, 80
local function hitTestMethod1(location, station)
    local a, b = a1, b1
    local x0 = location.x - station.vX
    local y0 = location.y - station.vY - a
    if x0 * x0 / (a * a) + y0 * y0 / (b * b) <= 1 then
        return true
    end
end

local a2 = (FightData.stationList:get(0).vX - FightData.stationList:get(2).vX) / 4
local b2 = (FightData.stationList:get(1).vY - FightData.stationList:get(7).vY) / 4
local function hitTestMethod2(location, station)
    local a, b = a2, b2
    local x0 = location.x - station.vX
    local y0 = location.y - station.vY
    if -a < x0 and x0 < a and -b < y0 and y0 < b then
        return true
    end
end

function FightRoleList:hitTest(location, hasRole, hasRight) --@return 
    location.x = toint(location.x)
    location.y = toint(location.y)
    for __, role in pairs(self) do
        if role.playerView then
            if hitTestMethod1(location, role.station) then
                if role:isMirror() then
                    return role:index() + 9
                end
                return role:index()
            end
        else
            if hitTestMethod2(location, role.station) then
                if role:isMirror() then
                    return role:index() + 9
                end
                return role:index()
            end
        end
    end
    return nil
end

FightRoleMgr = FightRoleList:init()