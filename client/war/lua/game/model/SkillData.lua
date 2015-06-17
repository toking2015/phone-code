local __this = {}
SkillData = __this
-----------------------描述------------
function __this.getTipsInfoOdd( odds )
    local str = ""
    local exist = {}
    local find = nil
    for k,v in pairs(odds) do
        find = false
        for kk,vv in pairs(exist) do
            if vv == v.first then
                find = true
                break
            end
        end
        if not find then
            str = str .."[br]"
            local oddInfo = findOdd(v.first,v.second)
            if oddInfo then
                table.insert(exist,v.first)
                local subTitle = fontNameString("TIP_S") ..oddInfo.name.. "[br]"
                local subContent = fontNameString("TIP_C") .. oddInfo.description
                str = str .. subTitle .. subContent
            end
        end
    end
    return str
end

--主动技能描述
function __this.getTipsInfoAct(skillInfo)
    local str = ''
    local mainTitle = fontNameString("TIP_T") ..skillInfo.name.. "[br]"
    local mainContent = fontNameString("TIP_C") .. skillInfo.desc
    str = mainTitle .. mainContent
    local oddStr = __this.getTipsInfoOdd(skillInfo.odds)
    if oddStr ~= "" then
        str = str .. oddStr
    end
    return str
end
--被动技能描述
function __this.getTipsInfoPass(oddInfo) 
    local str = ''
    local mainTitle = fontNameString("TIP_T") ..oddInfo.name.. "[br]"
    local mainContent = fontNameString("TIP_C") .. oddInfo.description
    str = mainTitle .. mainContent
    local list = {}
    table.insert(list,oddInfo.addodd)
    local oddStr = __this.getTipsInfoOdd(list)
    if oddStr ~= "" then
        str = str .. oddStr
    end
    return str
end

function __this.killUrlByJson(skillInfo)
    if skillInfo then
        local icon = skillInfo.icon
        if icon == nil or icon == 0 then
            icon = 1000101
        end
        return string.format( "image/icon/skill/%d.png", icon)
    end
end

function __this.oddUrlByJson(oddInfo)
    if oddInfo then
        local icon = oddInfo.icon
        if icon == nil or icon == 0 then
            icon = 1000101
        end
        return string.format( "image/icon/skill/%d.png",icon )
    end
end