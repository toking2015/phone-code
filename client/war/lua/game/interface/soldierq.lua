
--**谭春映
--**英雄系统
---********************---
--PQFightExtAbleList 英雄二级属性
Command.bind( 'extable list', function(_attr)
    trans.send_msg( 'PQFightExtAbleList', { attr = _attr } )
end )

--请求英雄列表
Command.bind( 'soldier list', function(type)
    trans.send_msg( 'PQSoldierList', { soldier_type = type } )
end )

--请求英雄列表
Command.bind( 'soldier add', function(id)
    trans.send_msg( 'PQSoldierAdd', { soldier_id = id } )
end )

-- @@删除英雄
Command.bind( 'soldier del', function(type, info)
    trans.send_msg( 'PQSoldierDel', { soldier_type = id ,soldier = info} )
end )

-- @@移动英雄
Command.bind( 'soldier move', function(soldierInfo, posiInfo)
    trans.send_msg( 'PQSoldierMove', { soldier = soldierInfo ,index = posiInfo} )
end )

-- @@等级升级
Command.bind( 'soldier soldierLvUp', function(soldierInfo)
    trans.send_msg( 'PQSoldierLvUp', { soldier = soldierInfo} )
end )

-- @@品质升级
Command.bind( 'soldier qualityup', function(soldierInfo)
    trans.send_msg( 'PQSoldierQualityUp', { soldier = soldierInfo} )
end )

-- @@升星
Command.bind( 'soldier starup', function(soldierInfo)
    trans.send_msg( 'PQSoldierStarUp', { soldier = soldierInfo} )
end )

-- @@英雄招募
Command.bind( 'soldier recruit', function(getId)
    trans.send_msg( 'PQSoldierRecruit', { id = getId} )
end )

-- @@装备穿戴
Command.bind( 'soldier equip', function(sInfo,iInfo)
    trans.send_msg( 'PQSoldierEquip', { soldier = sInfo, item = iInfo } )
end )

-- @@洗点
Command.bind( 'soldier skillReset', function(sInfo)
    trans.send_msg( 'PQSoldierSkillReset', { soldier = sInfo} )
end )
-- @@技能升级
Command.bind( 'soldier skillUp', function(sInfo,skillId)
    trans.send_msg( 'PQSoldierSkillLvUp', { soldier = sInfo,skill_id = skillId } )
end )

-- @@增加经验
Command.bind( 'soldier addxp', function(sInfo,scoin_list)
    trans.send_msg( 'PQSoldierQualityAddXp', { soldier = sInfo,coin_list = scoin_list } )
end )

-- @@请求武将装备二级属性
Command.bind( 'soldier equipext', function(sInfo)
    trans.send_msg( 'PQSoldierEquipExt', { soldier = sInfo} )
end )




