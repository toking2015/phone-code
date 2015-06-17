local __this = {}
__this.index = __this



function __this.monsterToFightExt(monster)
	local able = 
	{
	    hp = monster.hp,
	    physical_ack = monster.physical_ack,
	    physical_def = monster.physical_def,
	    magic_ack = monster.magic_ack,
	    magic_def = monster.magic_def,
	    speed = monster.speed,
	    critper = monster.critper,
	    critper_def = monster.critper_def,
        recover_critper = monster.recover_critper,
        recover_critper_def = monster.recover_critper_def,
	    crithurt = monster.crithurt,
	    crithurt_def = monster.crithurt_def,
	    hitper = monster.hitper,
	    dodgeper = monster.dodgeper,
	    parryper = monster.parryper,
	    parryper_dec = monster.parryper_dec,
	    stun_def = monster.stun_def,
	    silent_def = monster.silent_def,
	    weak_def = monster.weak_def,
	    fire_def = monster.fire_def,
        recover_add_fix = monster.recover_add_fix,
        recover_del_fix = monster.recover_del_fix,
        recover_add_per = monster.recover_add_per,
        recover_del_per = monster.recover_del_per,
        rage_add_fix = monster.rage_add_fix,
        rage_del_fix = monster.rage_del_fix,
        rage_add_per = monster.rage_add_per,
        rage_del_per = monster.rage_del_per,
	    rage = 100,
	}

	return able
end

function __this.getMonsterSkill(monster)
	local list = {}
    for __, s2 in pairs(monster.skills) do
        if 0 ~= s2.first then
        	local fight_skill = 
        	{
        		skill_id = s2.first,
	        	skill_level = s2.second
	        }
	        table.insert(list, fight_skill)
	    end
    end

    return list
end

function __this.getMonsterOdd(monster)
	local list = {}
	for __, s2 in pairs(monster.odds) do
        local odd = findOdd(s2.first, s2.second)
        if odd then
	        local fight_odd =
	        {
		        id = s2.first,
		        level = s2.second,
		        start_round = 0,
				begin_round = 0,
		        status_id = odd.status.cate,
		        status_value = odd.status.objid,
                ext_value = 0,
		    }
	        table.insert(list, fight_odd)
	    end
    end

    return list
end

function __this.ParsePositionParam(para)
    local list = string.split(para, '%')
    if #list < 2 then
    	return
    end

    local valList = {}

    for i = 2, #list, 1 do
    	table.insert(valList, toMyNumber(list[i]))
    end

    return toMyNumber(list[1]), valList
end

function __this.CheckTotemFormaitonAddPosition(pos_type, totem_pos, soldier_pos)
    local result = false;
    if pos_type == trans.const.kTotemFormationAddTypeFrontRow then
		result = (soldier_pos % 3 == 1)
    elseif pos_type == trans.const.kTotemFormationAddTypeBackRow then
        result = (soldier_pos % 3 == 2)
    elseif pos_type == trans.const.kTotemFormationAddTypeColumn then
        result = (math.modf(soldier_pos / 3) ==  math.modf(totem_pos / 3))
	end

    return result
end

function __this.getTotemFormationMonsterAddOdd(conf, fight_index, odd_list)
	for __, s2 in pairs(conf.totemadd) do
        local conf_data = findTotemExt(s2.first)
        if conf_data then
	        local totem_data = findTotem(conf_data.totem_id)
	        if totem_data then
		        local attr_data = findTotemAttr(totem_data.id, conf_data.formation_lv)
		        if attr_data then
			        local pos_type, position_list = __this.ParsePositionParam(attr_data.formation_add_position)
			        if 0 ~= #position_list then
				        local is_add = false;
				        if pos_type == trans.const.kTotemFormationAddPosition then
				        	for __, val in pairs(#position_list) do
				                if val == fight_index then
				                    is_add = true;
				                    break;
				                end
				            end
				        elseif pos_type == trans.const.kTotemFormationAddType then
                            is_add = __this.CheckTotemFormaitonAddPosition(position_list[1], s2.second, fight_index);
				        end

				        if is_add then
				            local odd_data = findOdd(attr_data.formation_add_attr.first, attr_data.formation_add_attr.second);
				            if odd_data then
				                local odd =
				                {
					                id           = odd_data.id,
					                level        = odd_data.level,
					                status_id    = odd_data.status.cate,
					                status_value = odd_data.status.objid,
					                ext_value = 0,
					                start_round  = 0,
									begin_round = 0,
					            }

				                table.insert(odd_list, odd)
				            end
				    	end
				    end
			    end
		    end
	    end
    end
end

function __this.getTotemFightInfo(totem_data, wake_lv, speed_lv, fight_soldier)
    local attr_data = findTotemAttr(totem_data.id, wake_lv)
    if not attr_data then
        return
    end

    --skill
    if attr_data.skill.first ~= 0 then
        local skill =
        {
	        skill_id    = attr_data.skill.first,
	        skill_level = attr_data.skill.second
	    }
        
        table.insert(fight_soldier.skill_list, skill)
    end
    
    --odd
    if attr_data.wake.first ~= 0 then       
        local odd = findOdd(attr_data.wake.first, attr_data.wake.second)
        if odd then
            local fight_odd =
                {
                    id = attr_data.wake.first,
                    level = attr_data.wake.second,
                    start_round = 0,
					begin_round = 0,
                    status_id = odd.status.cate,
                    status_value = odd.status.objid,
                    ext_value = 0,
                }
            table.insert(fight_soldier.odd_list, fight_odd)
        end
    end

    --extable
    fight_soldier.fight_ext_able.speed = attr_data.speed
    fight_soldier.fight_ext_able.hp = 0 
    fight_soldier.fight_ext_able.physical_ack = 0 
    fight_soldier.fight_ext_able.physical_def = 0 
    fight_soldier.fight_ext_able.magic_ack = 0 
    fight_soldier.fight_ext_able.magic_def = 0 
    fight_soldier.fight_ext_able.speed = 0 
    fight_soldier.fight_ext_able.critper = 0 
    fight_soldier.fight_ext_able.critper_def = 0 
    fight_soldier.fight_ext_able.recover_critper = 0 
    fight_soldier.fight_ext_able.recover_critper_def = 0 
    fight_soldier.fight_ext_able.crithurt = 0 
    fight_soldier.fight_ext_able.crithurt_def = 0 
    fight_soldier.fight_ext_able.hitper = 20000    
    fight_soldier.fight_ext_able.dodgeper = 0 
    fight_soldier.fight_ext_able.parryper = 0    
    fight_soldier.fight_ext_able.parryper_dec = 0 
    fight_soldier.fight_ext_able.stun_def = 0    
    fight_soldier.fight_ext_able.silent_def = 0 
    fight_soldier.fight_ext_able.weak_def = 0    
    fight_soldier.fight_ext_able.fire_def = 0 
    fight_soldier.fight_ext_able.recover_add_fix = 0 
    fight_soldier.fight_ext_able.recover_del_fix = 0 
    fight_soldier.fight_ext_able.recover_add_per = 0 
    fight_soldier.fight_ext_able.recover_dep_per = 0 
    fight_soldier.fight_ext_able.rage_add_fix = 0 
    fight_soldier.fight_ext_able.rage_del_fix = 0 
    fight_soldier.fight_ext_able.rage_add_per = 0 
    fight_soldier.fight_ext_able.rage_del_per = 0 
    
end

function __this.createSoldier()
	local soldier = 
	{
		guid = 0,		-- 唯一标识
        soldier_guid = 0,		-- 英雄的guid 服务端使用
        attr = 0,		-- 人物标识 玩家/怪物
        hp = 0,		-- 英雄当前血量
        rage = 0,		-- 玩家怒气
		soldier_id = 0,		-- 英雄ID,怪物ID,战宠Id
        fame = 0,		-- 声望
        name = '',		-- 英雄名称
        platform_str = '',		-- 平台名字
        platform = 0,		-- 平台id+服务器id
        avatar = 0,		-- 玩家头像
        occupation = 0,		-- 玩家职业
        gender = 0,		-- 玩家性别
        horse_id = 0,		-- 马id
        level = 0,		-- 玩家等级
        fight_index = 0,		-- 当前位置
        fight_ext_able = 
        {
		    hp = 0,
		    physical_ack = 0,
		    physical_def = 0,
		    magic_ack = 0,
		    magic_def = 0,
		    speed = 0,
		    critper = 0,
		    critper_def = 0,
            recover_critper = 0,
            recover_critper_def = 0,
		    crithurt = 0,
		    crithurt_def = 0,
		    hitper = 0,
		    dodgeper = 0,
		    parryper = 0,
		    parryper_dec = 0,
		    stun_def = 0,
		    silent_def = 0,
		    weak_def = 0,
		    fire_def = 0,
		    recover_add_fix = 0,
		    recover_del_fix = 0,
		    recover_add_per = 0,
		    recover_del_per = 0,
		    rage_add_fix = 0,
		    rage_del_fix = 0,
		    rage_add_per = 0,
		    rage_del_per = 0,
		    rage = 100,
		},		-- 英雄二级属性
        item_list = {},		-- 角色装备
        skill_list = {},		-- 技能列表
        odd_list = {},		-- BUFF列表
        order = 
        {
			guid = 0,		-- 角色ID
        	order_id = 0,		-- 技能ID
        	order_level = 0,		-- 等级  
        },		-- 使用技能
        last_ext_able = 
        {
		    hp = 0,
		    physical_ack = 0,
		    physical_def = 0,
		    magic_ack = 0,
		    magic_def = 0,
		    speed = 0,
		    critper = 0,
		    critper_def = 0,
            recover_critper = 0,
            recover_critper_def = 0,
		    crithurt = 0,
		    crithurt_def = 0,
		    hitper = 0,
		    dodgeper = 0,
		    parryper = 0,
		    parryper_dec = 0,
		    stun_def = 0,
            silent_def = 0,
            weak_def = 0,
            fire_def = 0,
            recover_add_fix = 0,
            recover_del_fix = 0,
            recover_add_per = 0,
            recover_del_per = 0,
            rage_add_fix = 0,
            rage_del_fix = 0,
            rage_add_per = 0,
            rage_del_per = 0,
		    rage = 100,
		},		-- 当前英雄二级属性
        lastOrderRound = {},		-- 上次使用技能的时间
        limitCountAll = {},		-- 使用BUFF的次数
        state_list = {},		-- 状态信息
        delFlag = 0,		-- 删除标志
        selfUserGuid = 0,		-- UserGuid
        selfFightId = 0,		-- 战斗ID
        isPlay = 0,		-- 是否在播放前置动画阶段
        deadFlag = 0,   --死亡标志
        totem = {},     --图腾信息
        totem_glyph_list = {}, --图腾镶嵌的雕文列表
	}

	return soldier
end

--创建参战人员数据
function __this:createUser(monster_id, guid, camp)
	local conf = findMonsterFightConf(monster_id)
	if not conf then
		return nil
	end

	local playerInfo = 
	{
		guid = guid, 
		camp = camp,
		totem_value = 0,
		isAutoFight = 0,
		attr = trans.const.kAttrMonster,
		soldier_list = {}
	}

	for __, s2 in pairs(conf.add) do
		if 0 ~= s2.first then
			local monster = findMonster(s2.first)
			if monster then
				local fight_soldier = self.createSoldier()
				fight_soldier.guid = guid
				fight_soldier.soldier_id = monster.id
				fight_soldier.fight_index = s2.second
				fight_soldier.name = monster.name
				fight_soldier.attr = trans.const.kAttrMonster
				fight_soldier.rage = monster.initial_rage
				fight_soldier.occupation = monster.occupation
				fight_soldier.fight_ext_able = self.monsterToFightExt(monster)
				fight_soldier.skill_list = self.getMonsterSkill(monster)
				fight_soldier.odd_list = self.getMonsterOdd(monster)

				fight_soldier.hp = fight_soldier.fight_ext_able.hp
        		self.getTotemFormationMonsterAddOdd(conf, s2.second, fight_soldier.odd_list)

				guid = guid + 1
				table.insert(playerInfo.soldier_list, fight_soldier)
			end
		end
	end

	for __, s2 in pairs(conf.totemadd) do
		local conf_data = findTotemExt(s2.first)
        if conf_data then
	        local totem_data = findTotem(conf_data.totem_id)
	        if totem_data then
		        --设置图腾属性
		        local fight_soldier = self.createSoldier()
				fight_soldier.guid = guid
				fight_soldier.soldier_id = totem_data.id
				fight_soldier.fight_index = s2.second
				fight_soldier.name = totem_data.name
				fight_soldier.attr = trans.const.kAttrTotem
				fight_soldier.occupation = 0
				fight_soldier.fight_ext_able = {}
				fight_soldier.skill_list = {}
				fight_soldier.odd_list = {}

		        self.getTotemFightInfo(totem_data, conf_data.wake_lv, conf_data.speed_lv, fight_soldier)

				guid = guid + 1
				table.insert(playerInfo.soldier_list, fight_soldier)
		    end
	    end
	end

	return playerInfo, guid
end

FightCollaborationistMgr = __this