FightExtAble = {

}

local const = trans.const

function FightExtAble:new()
    local o = 
    {
        hp              =  0,    --气血
        physical_ack    =  0,    --物理攻击
        physical_def    =  0,    --物理防御
        magic_ack       =  0,    --法术攻击
        magic_def       =  0,    --法术防御
        speed           =  0,    --速度
        critper         =  0,    --暴击率
        critper_def     =  0,    --暴击抵抗
        recover_critper =  0,    --回血暴击率
        recover_critper_def =  0,    --回血暴击抵抗 
        crithurt        =  0,    --暴击伤害
        crithurt_def    =  0,    --暴击减免
        hitper          =  0,    --命中
        dodgeper        =  0,    --闪避
        parryper        =  0,    --格挡
        parryper_dec    =  0,    --格挡减少
        rage            =  0,    --蓄力值
        stun_def        =  0,    --眩晕抗性
        silent_def      =  0,    --沉默抗性
        weak_def        =  0,    --虚弱抗性
        fire_def        =  0,    --烧伤抗性
        recover_add_fix =  0,    --回血固定值
        recover_del_fix =  0,    --回血固定值
        recover_add_per =  0,    --回血百分比
        recover_del_per =  0,    --回血百分比        
        rage_add_fix    =  0,    --怒气固定值
        rage_del_fix    =  0,    --怒气固定值
        rage_add_per    =  0,    --怒气百分比
        rage_del_per    =  0     --怒气百分比
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

FightExtAble.__add = function( o1, o2 )
    local temp = FightExtAble:new()

    temp.hp = o1.hp + o2.hp
    temp.physical_ack = o1.physical_ack + o2.physical_ack
    temp.physical_def = o1.physical_def + o2.physical_def
    temp.magic_ack = o1.magic_ack + o2.magic_ack
    temp.magic_def = o1.magic_def + o2.magic_def
    temp.speed = o1.speed + o2.speed
    temp.critper = o1.critper + o2.critper
    temp.critper_def = o1.critper_def + o2.critper_def
    temp.recover_critper = o1.recover_critper + o2.recover_critper
    temp.recover_critper_def = o1.recover_critper_def + o2.recover_critper_def
    temp.crithurt = o1.crithurt + o2.crithurt
    temp.crithurt_def = o1.crithurt_def + o2.crithurt_def
    temp.hitper = o1.hitper + o2.hitper
    temp.dodgeper = o1.dodgeper + o2.dodgeper
    temp.parryper = o1.parryper + o2.parryper
    temp.parryper_dec = o1.parryper_dec + o2.parryper_dec
    temp.rage = o1.rage + o2.rage
    temp.stun_def = o1.stun_def + o2.stun_def
    temp.silent_def = o1.silent_def + o2.silent_def
    temp.weak_def = o1.weak_def + o2.weak_def
    temp.fire_def = o1.fire_def + o2.fire_def
    temp.recover_add_fix = o1.recover_add_fix + o2.recover_add_fix
    temp.recover_del_fix = o1.recover_del_fix + o2.recover_del_fix
    temp.recover_add_per = o1.recover_add_per + o2.recover_add_per
    temp.recover_del_per = o1.recover_del_per + o2.recover_del_per
    temp.rage_add_fix = o1.rage_add_fix + o2.rage_add_fix
    temp.rage_del_fix = o1.rage_del_fix + o2.rage_del_fix
    temp.rage_add_per = o1.rage_add_per + o2.rage_add_per
    temp.rage_del_per = o1.rage_del_per + o2.rage_del_per
    

    return temp
end

function getSubExt(o1,o2)
    if o1 > o2 then
        return o1 - o2
    else
        return 0
    end
end

FightExtAble.__sub = function( o1, o2 )
    local temp = FightExtAble:new()

    temp.hp = getSubExt( o1.hp, o2.hp )
    temp.physical_ack = getSubExt( o1.physical_ack, o2.physical_ack )
    temp.physical_def = getSubExt( o1.physical_def, o2.physical_def )
    temp.magic_ack = getSubExt( o1.magic_ack, o2.magic_ack )
    temp.magic_def = getSubExt( o1.magic_def, o2.magic_def )
    temp.speed = getSubExt( o1.speed, o2.speed )
    temp.critper = getSubExt( o1.critper, o2.critper )
    temp.critper_def = getSubExt( o1.critper_def, o2.critper_def )
    temp.recover_critper = getSubExt( o1.recover_critper, o2.recover_critper )
    temp.recover_critper_def = getSubExt( o1.recover_critper_def, o2.recover_critper_def )
    temp.crithurt = getSubExt( o1.crithurt, o2.crithurt )
    temp.crithurt_def = getSubExt( o1.crithurt_def, o2.crithurt_def )
    temp.hitper = getSubExt( o1.hitper, o2.hitper )
    temp.dodgeper = getSubExt( o1.dodgeper, o2.dodgeper )
    temp.parryper = getSubExt( o1.parryper, o2.parryper )
    temp.parryper_dec = getSubExt( o1.parryper_dec, o2.parryper_dec )
    temp.rage = getSubExt( o1.rage, o2.rage )
    temp.stun_def = getSubExt( o1.stun_def, o2.stun_def )
    temp.silent_def = getSubExt( o1.silent_def, o2.silent_def )
    temp.weak_def = getSubExt( o1.weak_def, o2.weak_def )
    temp.fire_def = getSubExt( o1.fire_def, o2.fire_def )
    temp.recover_add_fix = getSubExt( o1.recover_add_fix, o2.recover_add_fix )
    temp.recover_del_fix = getSubExt( o1.recover_del_fix, o2.recover_del_fix )
    temp.recover_add_per = getSubExt( o1.recover_add_per, o2.recover_add_per )
    temp.recover_del_per = getSubExt( o1.recover_del_per, o2.recover_del_per )
    temp.rage_add_fix = getSubExt( o1.rage_add_fix, o2.rage_add_fix )
    temp.rage_del_fix = getSubExt( o1.rage_del_fix, o2.rage_del_fix )
    temp.rage_add_per = getSubExt( o1.rage_add_per, o2.rage_add_per )
    temp.rage_del_per = getSubExt( o1.rage_del_per, o2.rage_del_per )
    

    return temp
end

function getValue( v, mode, b )
    if 0 == mode then
        return v
    else
        return math.modf( v * b / 10000 )
    end
end

function ToFightExtAble( id, base, v, count )
    if nil == count or 0 == count then
        count = 1
    end
    
    v = v * count

    local able = FightExtAble:new()
    local effect = findEffect( id )
    if nil == effect then
        return able
    end

    local _mode = 0
    if id > 127 then
        id = id - 127
        _mode = 1
    end

    if id == const.kEffectHP then
        able.hp = getValue(v, _mode, base.hp)
    elseif id == const.kEffectPhysicalAck then
        able.physical_ack = getValue(v, _mode, base.physical_ack)
    elseif id == const.kEffectPhysicalDef then
        able.physical_def = getValue(v, _mode, base.physical_def)
    elseif id == const.kEffectMagicAck then
        able.magic_ack = getValue(v, _mode, base.magic_ack)
    elseif id == const.kEffectMagicDef then
        able.magic_def = getValue(v, _mode, base.magic_def)
    elseif id == const.kEffectSpeed then
        able.speed = getValue(v, _mode, base.speed)
    elseif id == const.kEffectCrit then
        able.critper = getValue(v, _mode, base.critper)
    elseif id == const.kEffectCritDef then
        able.critper_def = getValue(v, _mode, base.critper_def)
    elseif id == const.kEffectRecoverCrit then
        able.recover_critper = getValue(v, _mode, base.recover_critper)
    elseif id == const.kEffectRecoverCritDef then
        able.recover_critper_def = getValue(v, _mode, base.recover_critper_def)
    elseif id == const.kEffectCritHurt then
        able.crithurt = getValue(v, _mode, base.crithurt)
    elseif id == const.kEffectCritHurtDef then
        able.crithurt_def = getValue(v, _mode, base.crithurt_def)
    elseif id == const.kEffectHit then
        able.hitper = getValue(v, _mode, base.hitper)
    elseif id == const.kEffectDodge then
        able.dodgeper = getValue(v, _mode, base.dodgeper)
    elseif id == const.kEffectParry then
        able.parryper = getValue(v, _mode, base.parryper)
    elseif id == const. kEffectParryDec then
        able.parryper_dec = getValue(v, _mode, base.parryper_dec)
    elseif id == const.kEffectStunDef then
        able.stun_def = getValue(v, _mode, base.stun_def)
    elseif id == const.kEffectSilentDef then
        able.silent_def = getValue(v, _mode, base.silent_def)
    elseif id == const.kEffectWeakDef then
        able.weak_def = getValue(v, _mode, base.weak_def)
    elseif id == const.kEffectFireDef then
        able.fire_def = getValue(v, _mode, base.fire_def)
    elseif id == const.kEffectRecoverAddFix then
        able.recover_add_fix = getValue(v, _mode, base.recover_add_fix)
    elseif id == const.kEffectRecoverDelFix then
        able.recover_del_fix = getValue(v, _mode, base.recover_del_fix)
    elseif id == const.kEffectRecoverAddPer then
        able.recover_add_per = getValue(v, _mode, base.recover_add_per)
    elseif id == const.kEffectRecoverDelPer then
        able.recover_del_per = getValue(v, _mode, base.recover_del_per)
    elseif id == const.kEffectRageAddFix then
        able.rage_add_fix = getValue(v, _mode, base.rage_add_fix)
    elseif id == const.kEffectRageDelFix then
        able.rage_del_fix = getValue(v, _mode, base.rage_del_fix)
    elseif id == const.kEffectRageAddPer then
        able.rage_add_per = getValue(v, _mode, base.rage_add_per)
    elseif id == const.kEffectRageDelPer then      
        able.rage_del_per = getValue(v, _mode, base.rage_del_per)   
    elseif id == const.kEffectAllAttr then
        --able.hp = getValue(v, _mode, base.hp)
        able.physical_ack = getValue(v, _mode, base.physical_ack)
        able.physical_def = getValue(v, _mode, base.physical_def)
        able.magic_ack = getValue(v, _mode, base.magic_ack)
        able.magic_def = getValue(v, _mode, base.magic_def)
        able.speed = getValue(v, _mode, base.speed)
    elseif id == const.kEffectDef then
        able.physical_def = getValue(v, _mode, base.physical_def)
        able.magic_def = getValue(v, _mode, base.magic_def)
    elseif id == const.kEffectAck then
        able.physical_ack = getValue(v, _mode, base.physical_ack)
        able.magic_ack = getValue(v, _mode, base.magic_ack)
    elseif id == const.kEffectPhysical then
        able.physical_ack = getValue(v, _mode, base.physical_ack)
        able.magic_ack = getValue(v, _mode, base.magic_ack)
    elseif id == const.kEffectAckSpeed then
        able.physical_ack = getValue(v, _mode, base.physical_ack)
        able.magic_ack = getValue(v, _mode, base.magic_ack)
        able.speed = getValue(v, _mode, base.speed)
	elseif id == const.kEffectTrialBuff then
		able.hp = getValue(v, _mode, base.hp)
        able.physical_ack = getValue(v, _mode, base.physical_ack)
        able.physical_def = getValue(v, _mode, base.physical_def)
        able.magic_ack = getValue(v, _mode, base.magic_ack)
        able.magic_def = getValue(v, _mode, base.magic_def)
        able.speed = getValue(v, _mode, base.speed)
		able.critper = getValue( v, _mode, base.critper )
        able.critper_def = getValue( v, _mode, base.critper_def )
        able.recover_critper = getValue( v, _mode, base.recover_critper )
        able.recover_critper_def = getValue( v, _mode, base.recover_critper_def )
        able.crithurt = getValue( v, _mode, base.crithurt )
        able.crithurt_def = getValue( v, _mode, base.crithurt_def )
        able.hitper = getValue( v, _mode, base.hitper )
        able.dodgeper = getValue( v, _mode, base.dodgeper )
        able.parryper = getValue( v, _mode, base.parryper )
        able.parryper_dec = getValue( v, _mode, base.parryper_dec )	
    end
    return able
end

