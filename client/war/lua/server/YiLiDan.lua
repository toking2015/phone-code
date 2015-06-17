local YiLiDan= {}

function YiLiDan:setOrder(soldier,fightOrder)
    local theFight = theFightList[soldier.selfFightId]
    local last_round = soldier.lastOrderRound[soldier.skill_list[3].skill_id]
    local skill = findSkill(soldier.skill_list[3].skill_id, soldier.skill_list[3].skill_level)
    
    if nil == skill then
        return
    end
    
    if nil == last_round and theFight.round == skill.start_round then
        fightOrder.order_id = soldier.skill_list[3].skill_id
        fightOrder.order_level = soldier.skill_list[3].skill_level
    else
        if 0 ~= skill.cooldown and nil ~= last_round and (theFight.round - last_round)%skill.cooldown == 0 then
            fightOrder.order_id = soldier.skill_list[3].skill_id
            fightOrder.order_level = soldier.skill_list[3].skill_level
        elseif soldier.rage >= 100 then
            fightOrder.order_id = soldier.skill_list[2].skill_id
            fightOrder.order_level = soldier.skill_list[2].skill_level
        else
            fightOrder.order_id = soldier.skill_list[1].skill_id
            fightOrder.order_level = soldier.skill_list[1].skill_level
        end
    end
end

return YiLiDan
