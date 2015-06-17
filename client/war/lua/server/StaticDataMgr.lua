require("lua/utils/JsonLoad")

local json_table_data = {}

function toMyNumber(n)
    if "" == n then 
        return 0
    end  
                        
    if nil == n then 
        return 0
    end  
    return tonumber(n)
end

function ClearDataInList( clear_list )
    for _, key in pairs( clear_list ) do
        json_table_data[key] = nil
    end
    collectgarbage( 'collect' )
end

function InitDataList( list )
    for _, key in ipairs( list ) do
        GetDataList( key )
    end
end

function ClearDataExceptList( except_list )
    for key, v in pairs( json_table_data ) do
        local is_del = true
        for _, del_key in pairs( except_list ) do
            if del_key == key then
                is_del = false
                break
            end
        end
        if is_del then
            json_table_data[key] = nil
        end
    end
    collectgarbage( 'collect' )
end

function GetDataList( name )
    local data = json_table_data[ 'xls/' .. name ]
    if data ~= nil then
        return data
    end
    
    _G[ name .. 'LoadData' ]()
    
    return json_table_data[ 'xls/' .. name ]
end
function AchievementGoodsLoadData()
    if nil ~= json_table_data["xls/AchievementGoods.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/AchievementGoods.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        local temp_data = {}
        if nil ~= v.cond then
            local x,y = string.match(v.cond,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.cond                          = temp_data
            end
        end
        if 0 ~= toMyNumber(v.cond_level) then
            row_data.cond_level                      = toMyNumber(v.cond_level)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/AchievementGoods"] = data
    collectgarbage( 'collect' )
end

function findAchievementGoods(first)
    if nil == json_table_data["xls/AchievementGoods"] then
        AchievementGoodsLoadData()
    end
    local temp_tb = json_table_data["xls/AchievementGoods"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.cond then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.cond = temp_data
    end
    if nil == data.cond_level then
        data.cond_level = 0
    end
    return temp_tb[first]
end

function ActivityLoadData()
    if nil ~= json_table_data["xls/Activity.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Activity.json")) do
        local row_data = {}
        row_data.name                            = v.name
        if 0 ~= toMyNumber(v.cycle) then
            row_data.cycle                           = toMyNumber(v.cycle)
        end
        if nil ~= row_data.name then
            data[row_data.name] = row_data
        end
    end
    json_table_data["xls/Activity"] = data
    collectgarbage( 'collect' )
end

function findActivity(first)
    if nil == json_table_data["xls/Activity"] then
        ActivityLoadData()
    end
    local temp_tb = json_table_data["xls/Activity"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.cycle then
        data.cycle = 0
    end
    return temp_tb[first]
end

function ActivityOpenLoadData()
    if nil ~= json_table_data["xls/ActivityOpen.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/ActivityOpen.json")) do
        local row_data = {}
        row_data.name                            = v.name
        row_data.type                            = toMyNumber(v.type)
        if "" ~= v.first_time then
            row_data.first_time                      = v.first_time
        end
        if 0 ~= toMyNumber(v.second_time) then
            row_data.second_time                     = toMyNumber(v.second_time)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.name and nil ~= row_data.type then
            if nil == data[row_data.name] then 
                data[row_data.name] = {}
            end
            data[row_data.name][row_data.type] = row_data
        end
    end
    json_table_data["xls/ActivityOpen"] = data
    collectgarbage( 'collect' )
end

function findActivityOpen(first, second)
    if nil == json_table_data["xls/ActivityOpen"] then
        ActivityOpenLoadData()
    end
    local temp_tb = json_table_data["xls/ActivityOpen"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.first_time then
        data.first_time = ""
    end
    if nil == data.second_time then
        data.second_time = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first][second]
end

function AltarLoadData()
    if nil ~= json_table_data["xls/Altar.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Altar.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.lv) then
            row_data.lv                              = toMyNumber(v.lv)
        end
        local temp_data = {}
        if nil ~= v.reward then
            local x,y,z = string.match(v.reward,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.reward                        = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.extra_reward then
            local x,y,z = string.match(v.extra_reward,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.extra_reward                  = temp_data
            end
        end
        if 0 ~= toMyNumber(v.prob) then
            row_data.prob                            = toMyNumber(v.prob)
        end
        if 0 ~= toMyNumber(v.is_rare) then
            row_data.is_rare                         = toMyNumber(v.is_rare)
        end
        if 0 ~= toMyNumber(v.is_ten) then
            row_data.is_ten                          = toMyNumber(v.is_ten)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Altar"] = data
    collectgarbage( 'collect' )
end

function findAltar(first)
    if nil == json_table_data["xls/Altar"] then
        AltarLoadData()
    end
    local temp_tb = json_table_data["xls/Altar"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.lv then
        data.lv = 0
    end
    if nil == data.reward then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.reward = temp_data
    end
    if nil == data.extra_reward then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.extra_reward = temp_data
    end
    if nil == data.prob then
        data.prob = 0
    end
    if nil == data.is_rare then
        data.is_rare = 0
    end
    if nil == data.is_ten then
        data.is_ten = 0
    end
    return temp_tb[first]
end

function AlternactsLoadData()
    if nil ~= json_table_data["xls/Alternacts.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Alternacts.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.cate) then
            row_data.cate                            = toMyNumber(v.cate)
        end
        if 0 ~= toMyNumber(v.item_id) then
            row_data.item_id                         = toMyNumber(v.item_id)
        end
        if 0 ~= toMyNumber(v.item_type) then
            row_data.item_type                       = toMyNumber(v.item_type)
        end
        if 0 ~= toMyNumber(v.link_type) then
            row_data.link_type                       = toMyNumber(v.link_type)
        end
        if "" ~= v.link_data then
            row_data.link_data                       = v.link_data
        end
        if "" ~= v.icon then
            row_data.icon                            = v.icon
        end
        if 0 ~= toMyNumber(v.open_type) then
            row_data.open_type                       = toMyNumber(v.open_type)
        end
        if 0 ~= toMyNumber(v.open_term) then
            row_data.open_term                       = toMyNumber(v.open_term)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if "" ~= v.link_desc then
            row_data.link_desc                       = v.link_desc
        end
        if "" ~= v.undesc then
            row_data.undesc                          = v.undesc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Alternacts"] = data
    collectgarbage( 'collect' )
end

function findAlternacts(first)
    if nil == json_table_data["xls/Alternacts"] then
        AlternactsLoadData()
    end
    local temp_tb = json_table_data["xls/Alternacts"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.cate then
        data.cate = 0
    end
    if nil == data.item_id then
        data.item_id = 0
    end
    if nil == data.item_type then
        data.item_type = 0
    end
    if nil == data.link_type then
        data.link_type = 0
    end
    if nil == data.link_data then
        data.link_data = ""
    end
    if nil == data.icon then
        data.icon = ""
    end
    if nil == data.open_type then
        data.open_type = 0
    end
    if nil == data.open_term then
        data.open_term = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.link_desc then
        data.link_desc = ""
    end
    if nil == data.undesc then
        data.undesc = ""
    end
    return temp_tb[first]
end

function AreaLoadData()
    if nil ~= json_table_data["xls/Area.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Area.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.normal_pass_reward) then
            row_data.normal_pass_reward              = toMyNumber(v.normal_pass_reward)
        end
        if 0 ~= toMyNumber(v.elite_pass_reward) then
            row_data.elite_pass_reward               = toMyNumber(v.elite_pass_reward)
        end
        if 0 ~= toMyNumber(v.normal_full_reward) then
            row_data.normal_full_reward              = toMyNumber(v.normal_full_reward)
        end
        if 0 ~= toMyNumber(v.elite_full_reward) then
            row_data.elite_full_reward               = toMyNumber(v.elite_full_reward)
        end
        row_data.copy = {}
        for i = 1,16 do
            local temp_str = "copy" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.copy, toMyNumber(v[temp_str]))
            end
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Area"] = data
    collectgarbage( 'collect' )
end

function findArea(first)
    if nil == json_table_data["xls/Area"] then
        AreaLoadData()
    end
    local temp_tb = json_table_data["xls/Area"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.normal_pass_reward then
        data.normal_pass_reward = 0
    end
    if nil == data.elite_pass_reward then
        data.elite_pass_reward = 0
    end
    if nil == data.normal_full_reward then
        data.normal_full_reward = 0
    end
    if nil == data.elite_full_reward then
        data.elite_full_reward = 0
    end
    if nil == data.icon then
        data.icon = 0
    end
    if nil == data.level then
        data.level = 0
    end
    return temp_tb[first]
end

function AvatarLoadData()
    if nil ~= json_table_data["xls/Avatar.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Avatar.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.avatar) then
            row_data.avatar                          = toMyNumber(v.avatar)
        end
        if 0 ~= toMyNumber(v.soldier) then
            row_data.soldier                         = toMyNumber(v.soldier)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Avatar"] = data
    collectgarbage( 'collect' )
end

function findAvatar(first)
    if nil == json_table_data["xls/Avatar"] then
        AvatarLoadData()
    end
    local temp_tb = json_table_data["xls/Avatar"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.avatar then
        data.avatar = 0
    end
    if nil == data.soldier then
        data.soldier = 0
    end
    return temp_tb[first]
end

function BagCountLoadData()
    if nil ~= json_table_data["xls/BagCount.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/BagCount.json")) do
        local row_data = {}
        row_data.bag_type                        = toMyNumber(v.bag_type)
        if 0 ~= toMyNumber(v.bag_init) then
            row_data.bag_init                        = toMyNumber(v.bag_init)
        end
        if nil ~= row_data.bag_type then
            data[row_data.bag_type] = row_data
        end
    end
    json_table_data["xls/BagCount"] = data
    collectgarbage( 'collect' )
end

function findBagCount(first)
    if nil == json_table_data["xls/BagCount"] then
        BagCountLoadData()
    end
    local temp_tb = json_table_data["xls/BagCount"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.bag_type then
        data.bag_type = 0
    end
    if nil == data.bag_init then
        data.bag_init = 0
    end
    return temp_tb[first]
end

function BiasLoadData()
    if nil ~= json_table_data["xls/Bias.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Bias.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.begin_count) then
            row_data.begin_count                     = toMyNumber(v.begin_count)
        end
        if 0 ~= toMyNumber(v.must_count) then
            row_data.must_count                      = toMyNumber(v.must_count)
        end
        if 0 ~= toMyNumber(v.begin_factor) then
            row_data.begin_factor                    = toMyNumber(v.begin_factor)
        end
        if 0 ~= toMyNumber(v.add_factor) then
            row_data.add_factor                      = toMyNumber(v.add_factor)
        end
        if 0 ~= toMyNumber(v.day_count) then
            row_data.day_count                       = toMyNumber(v.day_count)
        end
        if 0 ~= toMyNumber(v.back_id) then
            row_data.back_id                         = toMyNumber(v.back_id)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Bias"] = data
    collectgarbage( 'collect' )
end

function findBias(first)
    if nil == json_table_data["xls/Bias"] then
        BiasLoadData()
    end
    local temp_tb = json_table_data["xls/Bias"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.begin_count then
        data.begin_count = 0
    end
    if nil == data.must_count then
        data.must_count = 0
    end
    if nil == data.begin_factor then
        data.begin_factor = 0
    end
    if nil == data.add_factor then
        data.add_factor = 0
    end
    if nil == data.day_count then
        data.day_count = 0
    end
    if nil == data.back_id then
        data.back_id = 0
    end
    return temp_tb[first]
end

function BuildingLoadData()
    if nil ~= json_table_data["xls/Building.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Building.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.common_open) then
            row_data.common_open                     = toMyNumber(v.common_open)
        end
        if 0 ~= toMyNumber(v.copy_open) then
            row_data.copy_open                       = toMyNumber(v.copy_open)
        end
        if 0 ~= toMyNumber(v.task_open) then
            row_data.task_open                       = toMyNumber(v.task_open)
        end
        if 0 ~= toMyNumber(v.run_open) then
            row_data.run_open                        = toMyNumber(v.run_open)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if "" ~= v.description then
            row_data.description                     = v.description
        end
        if 0 ~= toMyNumber(v.length) then
            row_data.length                          = toMyNumber(v.length)
        end
        if 0 ~= toMyNumber(v.width) then
            row_data.width                           = toMyNumber(v.width)
        end
        if 0 ~= toMyNumber(v.upgrade) then
            row_data.upgrade                         = toMyNumber(v.upgrade)
        end
        if 0 ~= toMyNumber(v.up_if) then
            row_data.up_if                           = toMyNumber(v.up_if)
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        if 0 ~= toMyNumber(v.isShow) then
            row_data.isShow                          = toMyNumber(v.isShow)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Building"] = data
    collectgarbage( 'collect' )
end

function findBuilding(first)
    if nil == json_table_data["xls/Building"] then
        BuildingLoadData()
    end
    local temp_tb = json_table_data["xls/Building"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.common_open then
        data.common_open = 0
    end
    if nil == data.copy_open then
        data.copy_open = 0
    end
    if nil == data.task_open then
        data.task_open = 0
    end
    if nil == data.run_open then
        data.run_open = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.description then
        data.description = ""
    end
    if nil == data.length then
        data.length = 0
    end
    if nil == data.width then
        data.width = 0
    end
    if nil == data.upgrade then
        data.upgrade = 0
    end
    if nil == data.up_if then
        data.up_if = 0
    end
    if nil == data.icon then
        data.icon = 0
    end
    if nil == data.isShow then
        data.isShow = 0
    end
    return temp_tb[first]
end

function BuildingCoinLoadData()
    if nil ~= json_table_data["xls/BuildingCoin.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/BuildingCoin.json")) do
        local row_data = {}
        row_data.building                        = toMyNumber(v.building)
        row_data.value = {}
        for i = 1,10 do
            local temp_str = "value" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.value, temp_data)
            end
        end
        if nil ~= row_data.building then
            data[row_data.building] = row_data
        end
    end
    json_table_data["xls/BuildingCoin"] = data
    collectgarbage( 'collect' )
end

function findBuildingCoin(first)
    if nil == json_table_data["xls/BuildingCoin"] then
        BuildingCoinLoadData()
    end
    local temp_tb = json_table_data["xls/BuildingCoin"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.building then
        data.building = 0
    end
    return temp_tb[first]
end

function BuildingCostLoadData()
    if nil ~= json_table_data["xls/BuildingCost.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/BuildingCost.json")) do
        local row_data = {}
        row_data.times                           = toMyNumber(v.times)
        local temp_data = {}
        if nil ~= v.cost2 then
            local x,y,z = string.match(v.cost2,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.cost2                         = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.cost6 then
            local x,y,z = string.match(v.cost6,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.cost6                         = temp_data
            end
        end
        if nil ~= row_data.times then
            data[row_data.times] = row_data
        end
    end
    json_table_data["xls/BuildingCost"] = data
    collectgarbage( 'collect' )
end

function findBuildingCost(first)
    if nil == json_table_data["xls/BuildingCost"] then
        BuildingCostLoadData()
    end
    local temp_tb = json_table_data["xls/BuildingCost"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.times then
        data.times = 0
    end
    if nil == data.cost2 then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.cost2 = temp_data
    end
    if nil == data.cost6 then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.cost6 = temp_data
    end
    return temp_tb[first]
end

function BuildingCritTimesLoadData()
    if nil ~= json_table_data["xls/BuildingCritTimes.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/BuildingCritTimes.json")) do
        local row_data = {}
        row_data.building_type                   = toMyNumber(v.building_type)
        row_data.times = {}
        for i = 1,10 do
            local temp_str = "times" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.times, temp_data)
            end
        end
        if nil ~= row_data.building_type then
            data[row_data.building_type] = row_data
        end
    end
    json_table_data["xls/BuildingCritTimes"] = data
    collectgarbage( 'collect' )
end

function findBuildingCritTimes(first)
    if nil == json_table_data["xls/BuildingCritTimes"] then
        BuildingCritTimesLoadData()
    end
    local temp_tb = json_table_data["xls/BuildingCritTimes"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.building_type then
        data.building_type = 0
    end
    return temp_tb[first]
end

function BuildingSpeedLoadData()
    if nil ~= json_table_data["xls/BuildingSpeed.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/BuildingSpeed.json")) do
        local row_data = {}
        row_data.level                           = toMyNumber(v.level)
        if 0 ~= toMyNumber(v.speed2) then
            row_data.speed2                          = toMyNumber(v.speed2)
        end
        if 0 ~= toMyNumber(v.speed6) then
            row_data.speed6                          = toMyNumber(v.speed6)
        end
        if nil ~= row_data.level then
            data[row_data.level] = row_data
        end
    end
    json_table_data["xls/BuildingSpeed"] = data
    collectgarbage( 'collect' )
end

function findBuildingSpeed(first)
    if nil == json_table_data["xls/BuildingSpeed"] then
        BuildingSpeedLoadData()
    end
    local temp_tb = json_table_data["xls/BuildingSpeed"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.speed2 then
        data.speed2 = 0
    end
    if nil == data.speed6 then
        data.speed6 = 0
    end
    return temp_tb[first]
end

function BuildingUpgradeLoadData()
    if nil ~= json_table_data["xls/BuildingUpgrade.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/BuildingUpgrade.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.level                           = toMyNumber(v.level)
        if 0 ~= toMyNumber(v.u_level) then
            row_data.u_level                         = toMyNumber(v.u_level)
        end
        if 0 ~= toMyNumber(v.f_level) then
            row_data.f_level                         = toMyNumber(v.f_level)
        end
        if 0 ~= toMyNumber(v.w_level) then
            row_data.w_level                         = toMyNumber(v.w_level)
        end
        if 0 ~= toMyNumber(v.s_level) then
            row_data.s_level                         = toMyNumber(v.s_level)
        end
        if nil ~= row_data.id and nil ~= row_data.level then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.level] = row_data
        end
    end
    json_table_data["xls/BuildingUpgrade"] = data
    collectgarbage( 'collect' )
end

function findBuildingUpgrade(first, second)
    if nil == json_table_data["xls/BuildingUpgrade"] then
        BuildingUpgradeLoadData()
    end
    local temp_tb = json_table_data["xls/BuildingUpgrade"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.u_level then
        data.u_level = 0
    end
    if nil == data.f_level then
        data.f_level = 0
    end
    if nil == data.w_level then
        data.w_level = 0
    end
    if nil == data.s_level then
        data.s_level = 0
    end
    return temp_tb[first][second]
end

function BuildingViewLoadData()
    if nil ~= json_table_data["xls/BuildingView.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/BuildingView.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.page) then
            row_data.page                            = toMyNumber(v.page)
        end
        if 0 ~= toMyNumber(v.depth) then
            row_data.depth                           = toMyNumber(v.depth)
        end
        if 0 ~= toMyNumber(v.x) then
            row_data.x                               = toMyNumber(v.x)
        end
        if 0 ~= toMyNumber(v.y) then
            row_data.y                               = toMyNumber(v.y)
        end
        if "" ~= v.command then
            row_data.command                         = v.command
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/BuildingView"] = data
    collectgarbage( 'collect' )
end

function findBuildingView(first)
    if nil == json_table_data["xls/BuildingView"] then
        BuildingViewLoadData()
    end
    local temp_tb = json_table_data["xls/BuildingView"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.page then
        data.page = 0
    end
    if nil == data.depth then
        data.depth = 0
    end
    if nil == data.x then
        data.x = 0
    end
    if nil == data.y then
        data.y = 0
    end
    if nil == data.command then
        data.command = ""
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function CopyLoadData()
    if nil ~= json_table_data["xls/Copy.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Copy.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.task) then
            row_data.task                            = toMyNumber(v.task)
        end
        if 0 ~= toMyNumber(v.guage) then
            row_data.guage                           = toMyNumber(v.guage)
        end
        row_data.boss_chunk = {}
        for i = 1,4 do
            local temp_str = "boss_chunk" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.boss_chunk, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.pass_reward) then
            row_data.pass_reward                     = toMyNumber(v.pass_reward)
        end
        row_data.pass_equip = {}
        for i = 1,4 do
            local temp_str = "pass_equip" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.pass_equip, temp_data)
            end
        end
        row_data.chunk = {}
        for i = 1,16 do
            local temp_str = "chunk" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.chunk, temp_data)
            end
        end
        row_data.reward = {}
        for i = 1,16 do
            local temp_str = "reward" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.reward, temp_data)
            end
        end
        local temp_data = {}
        if nil ~= v.mapid then
            local x,y = string.match(v.mapid,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.mapid                         = temp_data
            end
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        local temp_data = {}
        if nil ~= v.pos then
            local x,y = string.match(v.pos,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.pos                           = temp_data
            end
        end
        if "" ~= v.foot_sound then
            row_data.foot_sound                      = v.foot_sound
        end
        if "" ~= v.bg_sound then
            row_data.bg_sound                        = v.bg_sound
        end
        if 0 ~= toMyNumber(v.drop_item) then
            row_data.drop_item                       = toMyNumber(v.drop_item)
        end
        if 0 ~= toMyNumber(v.elitedrop_item) then
            row_data.elitedrop_item                  = toMyNumber(v.elitedrop_item)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Copy"] = data
    collectgarbage( 'collect' )
end

function findCopy(first)
    if nil == json_table_data["xls/Copy"] then
        CopyLoadData()
    end
    local temp_tb = json_table_data["xls/Copy"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.task then
        data.task = 0
    end
    if nil == data.guage then
        data.guage = 0
    end
    if nil == data.pass_reward then
        data.pass_reward = 0
    end
    if nil == data.mapid then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.mapid = temp_data
    end
    if nil == data.desc then
        data.desc = ""
    end
    if nil == data.icon then
        data.icon = 0
    end
    if nil == data.pos then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.pos = temp_data
    end
    if nil == data.foot_sound then
        data.foot_sound = ""
    end
    if nil == data.bg_sound then
        data.bg_sound = ""
    end
    if nil == data.drop_item then
        data.drop_item = 0
    end
    if nil == data.elitedrop_item then
        data.elitedrop_item = 0
    end
    return temp_tb[first]
end

function CopyChunkLoadData()
    if nil ~= json_table_data["xls/CopyChunk.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/CopyChunk.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.event = {}
        for i = 1,16 do
            local temp_str = "event" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.event, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/CopyChunk"] = data
    collectgarbage( 'collect' )
end

function findCopyChunk(first)
    if nil == json_table_data["xls/CopyChunk"] then
        CopyChunkLoadData()
    end
    local temp_tb = json_table_data["xls/CopyChunk"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    return temp_tb[first]
end

function CopyGutLoadData()
    if nil ~= json_table_data["xls/CopyGut.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/CopyGut.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        local temp_data = {}
        if nil ~= v.chunk then
            local x,y,z = string.match(v.chunk,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.chunk                         = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.win_end then
            local x,y = string.match(v.win_end,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.win_end                       = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.fail_end then
            local x,y = string.match(v.fail_end,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.fail_end                      = temp_data
            end
        end
        row_data.gut = {}
        for i = 1,16 do
            local temp_str = "gut" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.gut, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/CopyGut"] = data
    collectgarbage( 'collect' )
end

function findCopyGut(first)
    if nil == json_table_data["xls/CopyGut"] then
        CopyGutLoadData()
    end
    local temp_tb = json_table_data["xls/CopyGut"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.chunk then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.chunk = temp_data
    end
    if nil == data.win_end then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.win_end = temp_data
    end
    if nil == data.fail_end then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.fail_end = temp_data
    end
    return temp_tb[first]
end

function CopyMaterialLoadData()
    if nil ~= json_table_data["xls/CopyMaterial.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/CopyMaterial.json")) do
        local row_data = {}
        row_data.collect_level                   = toMyNumber(v.collect_level)
        if 0 ~= toMyNumber(v.active_score) then
            row_data.active_score                    = toMyNumber(v.active_score)
        end
        row_data.materials = {}
        for i = 1,4 do
            local temp_str = "materials" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.materials, toMyNumber(v[temp_str]))
            end
        end
        if 0 ~= toMyNumber(v.min_num) then
            row_data.min_num                         = toMyNumber(v.min_num)
        end
        if 0 ~= toMyNumber(v.max_num) then
            row_data.max_num                         = toMyNumber(v.max_num)
        end
        if nil ~= row_data.collect_level then
            data[row_data.collect_level] = row_data
        end
    end
    json_table_data["xls/CopyMaterial"] = data
    collectgarbage( 'collect' )
end

function findCopyMaterial(first)
    if nil == json_table_data["xls/CopyMaterial"] then
        CopyMaterialLoadData()
    end
    local temp_tb = json_table_data["xls/CopyMaterial"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.collect_level then
        data.collect_level = 0
    end
    if nil == data.active_score then
        data.active_score = 0
    end
    if nil == data.min_num then
        data.min_num = 0
    end
    if nil == data.max_num then
        data.max_num = 0
    end
    return temp_tb[first]
end

function CopyRewardLoadData()
    if nil ~= json_table_data["xls/CopyReward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/CopyReward.json")) do
        local row_data = {}
        row_data.gid                             = toMyNumber(v.gid)
        row_data.coin = {}
        for i = 1,16 do
            local temp_str = "coin" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.coin, temp_data)
            end
        end
        if nil ~= row_data.gid then
            data[row_data.gid] = row_data
        end
    end
    json_table_data["xls/CopyReward"] = data
    collectgarbage( 'collect' )
end

function findCopyReward(first)
    if nil == json_table_data["xls/CopyReward"] then
        CopyRewardLoadData()
    end
    local temp_tb = json_table_data["xls/CopyReward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.gid then
        data.gid = 0
    end
    return temp_tb[first]
end

function DayTaskValRewardLoadData()
    if nil ~= json_table_data["xls/DayTaskValReward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/DayTaskValReward.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.need_val) then
            row_data.need_val                        = toMyNumber(v.need_val)
        end
        row_data.reward = {}
        for i = 1,4 do
            local temp_str = "reward" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.reward, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/DayTaskValReward"] = data
    collectgarbage( 'collect' )
end

function findDayTaskValReward(first)
    if nil == json_table_data["xls/DayTaskValReward"] then
        DayTaskValRewardLoadData()
    end
    local temp_tb = json_table_data["xls/DayTaskValReward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.need_val then
        data.need_val = 0
    end
    return temp_tb[first]
end

function EffectLoadData()
    if nil ~= json_table_data["xls/Effect.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Effect.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.mode) then
            row_data.mode                            = toMyNumber(v.mode)
        end
        if 0 ~= toMyNumber(v.local_id) then
            row_data.local_id                        = toMyNumber(v.local_id)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if 0 ~= toMyNumber(v.PercenValue) then
            row_data.PercenValue                     = toMyNumber(v.PercenValue)
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Effect"] = data
    collectgarbage( 'collect' )
end

function findEffect(first)
    if nil == json_table_data["xls/Effect"] then
        EffectLoadData()
    end
    local temp_tb = json_table_data["xls/Effect"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.mode then
        data.mode = 0
    end
    if nil == data.local_id then
        data.local_id = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    if nil == data.PercenValue then
        data.PercenValue = 0
    end
    if nil == data.icon then
        data.icon = 0
    end
    return temp_tb[first]
end

function EquipQualityLoadData()
    if nil ~= json_table_data["xls/EquipQuality.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/EquipQuality.json")) do
        local row_data = {}
        row_data.quality                         = toMyNumber(v.quality)
        if 0 ~= toMyNumber(v.main_min) then
            row_data.main_min                        = toMyNumber(v.main_min)
        end
        if 0 ~= toMyNumber(v.main_max) then
            row_data.main_max                        = toMyNumber(v.main_max)
        end
        if 0 ~= toMyNumber(v.slave_min) then
            row_data.slave_min                       = toMyNumber(v.slave_min)
        end
        if 0 ~= toMyNumber(v.slave_max) then
            row_data.slave_max                       = toMyNumber(v.slave_max)
        end
        if 0 ~= toMyNumber(v.slave_attr_num) then
            row_data.slave_attr_num                  = toMyNumber(v.slave_attr_num)
        end
        if nil ~= row_data.quality then
            data[row_data.quality] = row_data
        end
    end
    json_table_data["xls/EquipQuality"] = data
    collectgarbage( 'collect' )
end

function findEquipQuality(first)
    if nil == json_table_data["xls/EquipQuality"] then
        EquipQualityLoadData()
    end
    local temp_tb = json_table_data["xls/EquipQuality"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.main_min then
        data.main_min = 0
    end
    if nil == data.main_max then
        data.main_max = 0
    end
    if nil == data.slave_min then
        data.slave_min = 0
    end
    if nil == data.slave_max then
        data.slave_max = 0
    end
    if nil == data.slave_attr_num then
        data.slave_attr_num = 0
    end
    return temp_tb[first]
end

function EquipSuitLoadData()
    if nil ~= json_table_data["xls/EquipSuit.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/EquipSuit.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        if 0 ~= toMyNumber(v.equip_type) then
            row_data.equip_type                      = toMyNumber(v.equip_type)
        end
        if 0 ~= toMyNumber(v.limit_level) then
            row_data.limit_level                     = toMyNumber(v.limit_level)
        end
        row_data.odds = {}
        for i = 1,3 do
            local temp_str = "odds" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.odds, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/EquipSuit"] = data
    collectgarbage( 'collect' )
end

function findEquipSuit(first)
    if nil == json_table_data["xls/EquipSuit"] then
        EquipSuitLoadData()
    end
    local temp_tb = json_table_data["xls/EquipSuit"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.equip_type then
        data.equip_type = 0
    end
    if nil == data.limit_level then
        data.limit_level = 0
    end
    return temp_tb[first]
end

function FightpowerLoadData()
    if nil ~= json_table_data["xls/Fightpower.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Fightpower.json")) do
        local row_data = {}
        row_data.type                            = toMyNumber(v.type)
        row_data.s_type                          = toMyNumber(v.s_type)
        if 0 ~= toMyNumber(v.common_open) then
            row_data.common_open                     = toMyNumber(v.common_open)
        end
        if 0 ~= toMyNumber(v.copy_open) then
            row_data.copy_open                       = toMyNumber(v.copy_open)
        end
        if 0 ~= toMyNumber(v.task_open) then
            row_data.task_open                       = toMyNumber(v.task_open)
        end
        if 0 ~= toMyNumber(v.run_open) then
            row_data.run_open                        = toMyNumber(v.run_open)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if "" ~= v.description then
            row_data.description                     = v.description
        end
        if 0 ~= toMyNumber(v.length) then
            row_data.length                          = toMyNumber(v.length)
        end
        if 0 ~= toMyNumber(v.width) then
            row_data.width                           = toMyNumber(v.width)
        end
        if 0 ~= toMyNumber(v.upgrade) then
            row_data.upgrade                         = toMyNumber(v.upgrade)
        end
        if 0 ~= toMyNumber(v.up_if) then
            row_data.up_if                           = toMyNumber(v.up_if)
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        if 0 ~= toMyNumber(v.isShow) then
            row_data.isShow                          = toMyNumber(v.isShow)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if "" ~= v.tips then
            row_data.tips                            = v.tips
        end
        if "" ~= v.s_tips then
            row_data.s_tips                          = v.s_tips
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.grate_s) then
            row_data.grate_s                         = toMyNumber(v.grate_s)
        end
        if "" ~= v.open_desc then
            row_data.open_desc                       = v.open_desc
        end
        if 0 ~= toMyNumber(v.open_type) then
            row_data.open_type                       = toMyNumber(v.open_type)
        end
        if 0 ~= toMyNumber(v.open_term) then
            row_data.open_term                       = toMyNumber(v.open_term)
        end
        if nil ~= row_data.type and nil ~= row_data.s_type then
            if nil == data[row_data.type] then 
                data[row_data.type] = {}
            end
            data[row_data.type][row_data.s_type] = row_data
        end
    end
    json_table_data["xls/Fightpower"] = data
    collectgarbage( 'collect' )
end

function findFightpower(first, second)
    if nil == json_table_data["xls/Fightpower"] then
        FightpowerLoadData()
    end
    local temp_tb = json_table_data["xls/Fightpower"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.s_type then
        data.s_type = 0
    end
    if nil == data.common_open then
        data.common_open = 0
    end
    if nil == data.copy_open then
        data.copy_open = 0
    end
    if nil == data.task_open then
        data.task_open = 0
    end
    if nil == data.run_open then
        data.run_open = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.description then
        data.description = ""
    end
    if nil == data.length then
        data.length = 0
    end
    if nil == data.width then
        data.width = 0
    end
    if nil == data.upgrade then
        data.upgrade = 0
    end
    if nil == data.up_if then
        data.up_if = 0
    end
    if nil == data.icon then
        data.icon = 0
    end
    if nil == data.isShow then
        data.isShow = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.tips then
        data.tips = ""
    end
    if nil == data.s_tips then
        data.s_tips = ""
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.grate_s then
        data.grate_s = 0
    end
    if nil == data.open_desc then
        data.open_desc = ""
    end
    if nil == data.open_type then
        data.open_type = 0
    end
    if nil == data.open_term then
        data.open_term = 0
    end
    return temp_tb[first][second]
end

function FixedEquipLoadData()
    if nil ~= json_table_data["xls/FixedEquip.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/FixedEquip.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.quality                         = toMyNumber(v.quality)
        if 0 ~= toMyNumber(v.main_factor) then
            row_data.main_factor                     = toMyNumber(v.main_factor)
        end
        if 0 ~= toMyNumber(v.slave_factor) then
            row_data.slave_factor                    = toMyNumber(v.slave_factor)
        end
        if nil ~= row_data.id and nil ~= row_data.quality then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.quality] = row_data
        end
    end
    json_table_data["xls/FixedEquip"] = data
    collectgarbage( 'collect' )
end

function findFixedEquip(first, second)
    if nil == json_table_data["xls/FixedEquip"] then
        FixedEquipLoadData()
    end
    local temp_tb = json_table_data["xls/FixedEquip"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.main_factor then
        data.main_factor = 0
    end
    if nil == data.slave_factor then
        data.slave_factor = 0
    end
    return temp_tb[first][second]
end

function FormationCopyLoadData()
    if nil ~= json_table_data["xls/FormationCopy.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/FormationCopy.json")) do
        local row_data = {}
        row_data.copy_id                         = toMyNumber(v.copy_id)
        row_data.add = {}
        for i = 1,6 do
            local temp_str = "add" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.add, temp_data)
            end
        end
        row_data.totem = {}
        for i = 1,3 do
            local temp_str = "totem" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.totem, temp_data)
            end
        end
        if nil ~= row_data.copy_id then
            data[row_data.copy_id] = row_data
        end
    end
    json_table_data["xls/FormationCopy"] = data
    collectgarbage( 'collect' )
end

function findFormationCopy(first)
    if nil == json_table_data["xls/FormationCopy"] then
        FormationCopyLoadData()
    end
    local temp_tb = json_table_data["xls/FormationCopy"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.copy_id then
        data.copy_id = 0
    end
    return temp_tb[first]
end

function FormationIndexLoadData()
    if nil ~= json_table_data["xls/FormationIndex.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/FormationIndex.json")) do
        local row_data = {}
        row_data.index                           = toMyNumber(v.index)
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if nil ~= row_data.index then
            data[row_data.index] = row_data
        end
    end
    json_table_data["xls/FormationIndex"] = data
    collectgarbage( 'collect' )
end

function findFormationIndex(first)
    if nil == json_table_data["xls/FormationIndex"] then
        FormationIndexLoadData()
    end
    local temp_tb = json_table_data["xls/FormationIndex"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.index then
        data.index = 0
    end
    if nil == data.level then
        data.level = 0
    end
    return temp_tb[first]
end

function GlobalLoadData()
    if nil ~= json_table_data["xls/Global.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Global.json")) do
        local row_data = {}
        row_data.global_name                     = v.global_name
        if "" ~= v.data then
            row_data.data                            = v.data
        end
        if "" ~= v.describe then
            row_data.describe                        = v.describe
        end
        if nil ~= row_data.global_name then
            data[row_data.global_name] = row_data
        end
    end
    json_table_data["xls/Global"] = data
    collectgarbage( 'collect' )
end

function findGlobal(first)
    if nil == json_table_data["xls/Global"] then
        GlobalLoadData()
    end
    local temp_tb = json_table_data["xls/Global"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.global_name then
        data.global_name = ""
    end
    if nil == data.data then
        data.data = ""
    end
    if nil == data.describe then
        data.describe = ""
    end
    return temp_tb[first]
end

function GuildContributeLoadData()
    if nil ~= json_table_data["xls/GuildContribute.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/GuildContribute.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        local temp_data = {}
        if nil ~= v.cost then
            local x,y,z = string.match(v.cost,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.cost                          = temp_data
            end
        end
        if 0 ~= toMyNumber(v.contribute) then
            row_data.contribute                      = toMyNumber(v.contribute)
        end
        row_data.coins = {}
        for i = 1,3 do
            local temp_str = "coins" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.coins, temp_data)
            end
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/GuildContribute"] = data
    collectgarbage( 'collect' )
end

function findGuildContribute(first)
    if nil == json_table_data["xls/GuildContribute"] then
        GuildContributeLoadData()
    end
    local temp_tb = json_table_data["xls/GuildContribute"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.cost then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.cost = temp_data
    end
    if nil == data.contribute then
        data.contribute = 0
    end
    if nil == data.name then
        data.name = ""
    end
    return temp_tb[first]
end

function GuildLevelLoadData()
    if nil ~= json_table_data["xls/GuildLevel.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/GuildLevel.json")) do
        local row_data = {}
        row_data.level                           = toMyNumber(v.level)
        if 0 ~= toMyNumber(v.levelup_xp) then
            row_data.levelup_xp                      = toMyNumber(v.levelup_xp)
        end
        if 0 ~= toMyNumber(v.member_count) then
            row_data.member_count                    = toMyNumber(v.member_count)
        end
        if 0 ~= toMyNumber(v.vendible_begin) then
            row_data.vendible_begin                  = toMyNumber(v.vendible_begin)
        end
        if 0 ~= toMyNumber(v.vendible_end) then
            row_data.vendible_end                    = toMyNumber(v.vendible_end)
        end
        if nil ~= row_data.level then
            data[row_data.level] = row_data
        end
    end
    json_table_data["xls/GuildLevel"] = data
    collectgarbage( 'collect' )
end

function findGuildLevel(first)
    if nil == json_table_data["xls/GuildLevel"] then
        GuildLevelLoadData()
    end
    local temp_tb = json_table_data["xls/GuildLevel"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.levelup_xp then
        data.levelup_xp = 0
    end
    if nil == data.member_count then
        data.member_count = 0
    end
    if nil == data.vendible_begin then
        data.vendible_begin = 0
    end
    if nil == data.vendible_end then
        data.vendible_end = 0
    end
    return temp_tb[first]
end

function GutLoadData()
    if nil ~= json_table_data["xls/Gut.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Gut.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.step                            = toMyNumber(v.step)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.target) then
            row_data.target                          = toMyNumber(v.target)
        end
        if 0 ~= toMyNumber(v.face) then
            row_data.face                            = toMyNumber(v.face)
        end
        if 0 ~= toMyNumber(v.move_face) then
            row_data.move_face                       = toMyNumber(v.move_face)
        end
        if 0 ~= toMyNumber(v.move_speed) then
            row_data.move_speed                      = toMyNumber(v.move_speed)
        end
        if 0 ~= toMyNumber(v.attr) then
            row_data.attr                            = toMyNumber(v.attr)
        end
        if "" ~= v.talk then
            row_data.talk                            = v.talk
        end
        if 0 ~= toMyNumber(v.monster) then
            row_data.monster                         = toMyNumber(v.monster)
        end
        if 0 ~= toMyNumber(v.reward) then
            row_data.reward                          = toMyNumber(v.reward)
        end
        if 0 ~= toMyNumber(v.box) then
            row_data.box                             = toMyNumber(v.box)
        end
        if "" ~= v.video then
            row_data.video                           = v.video
        end
        if "" ~= v.sound then
            row_data.sound                           = v.sound
        end
        if 0 ~= toMyNumber(v.weather) then
            row_data.weather                         = toMyNumber(v.weather)
        end
        if 0 ~= toMyNumber(v.shock) then
            row_data.shock                           = toMyNumber(v.shock)
        end
        if 0 ~= toMyNumber(v.shaking_screen) then
            row_data.shaking_screen                  = toMyNumber(v.shaking_screen)
        end
        if 0 ~= toMyNumber(v.red_screen) then
            row_data.red_screen                      = toMyNumber(v.red_screen)
        end
        if "" ~= v.special then
            row_data.special                         = v.special
        end
        local temp_data = {}
        if nil ~= v.take_coin then
            local x,y,z = string.match(v.take_coin,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.take_coin                     = temp_data
            end
        end
        if nil ~= row_data.id and nil ~= row_data.step then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.step] = row_data
        end
    end
    json_table_data["xls/Gut"] = data
    collectgarbage( 'collect' )
end

function findGut(first, second)
    if nil == json_table_data["xls/Gut"] then
        GutLoadData()
    end
    local temp_tb = json_table_data["xls/Gut"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.step then
        data.step = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.target then
        data.target = 0
    end
    if nil == data.face then
        data.face = 0
    end
    if nil == data.move_face then
        data.move_face = 0
    end
    if nil == data.move_speed then
        data.move_speed = 0
    end
    if nil == data.attr then
        data.attr = 0
    end
    if nil == data.talk then
        data.talk = ""
    end
    if nil == data.monster then
        data.monster = 0
    end
    if nil == data.reward then
        data.reward = 0
    end
    if nil == data.box then
        data.box = 0
    end
    if nil == data.video then
        data.video = ""
    end
    if nil == data.sound then
        data.sound = ""
    end
    if nil == data.weather then
        data.weather = 0
    end
    if nil == data.shock then
        data.shock = 0
    end
    if nil == data.shaking_screen then
        data.shaking_screen = 0
    end
    if nil == data.red_screen then
        data.red_screen = 0
    end
    if nil == data.special then
        data.special = ""
    end
    if nil == data.take_coin then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.take_coin = temp_data
    end
    return temp_tb[first][second]
end

function InductLoadData()
    if nil ~= json_table_data["xls/Induct.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Induct.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.index                           = toMyNumber(v.index)
        if 0 ~= toMyNumber(v.sound) then
            row_data.sound                           = toMyNumber(v.sound)
        end
        if "" ~= v.info then
            row_data.info                            = v.info
        end
        if 0 ~= toMyNumber(v.face) then
            row_data.face                            = toMyNumber(v.face)
        end
        if nil ~= row_data.id and nil ~= row_data.index then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.index] = row_data
        end
    end
    json_table_data["xls/Induct"] = data
    collectgarbage( 'collect' )
end

function findInduct(first, second)
    if nil == json_table_data["xls/Induct"] then
        InductLoadData()
    end
    local temp_tb = json_table_data["xls/Induct"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.index then
        data.index = 0
    end
    if nil == data.sound then
        data.sound = 0
    end
    if nil == data.info then
        data.info = ""
    end
    if nil == data.face then
        data.face = 0
    end
    return temp_tb[first][second]
end

function ItemLoadData()
    if nil ~= json_table_data["xls/Item.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Item.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.model) then
            row_data.model                           = toMyNumber(v.model)
        end
        if 0 ~= toMyNumber(v.locale_id) then
            row_data.locale_id                       = toMyNumber(v.locale_id)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        if "" ~= v.icon_resource then
            row_data.icon_resource                   = v.icon_resource
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.client_type) then
            row_data.client_type                     = toMyNumber(v.client_type)
        end
        if 0 ~= toMyNumber(v.subclass) then
            row_data.subclass                        = toMyNumber(v.subclass)
        end
        if 0 ~= toMyNumber(v.equip_type) then
            row_data.equip_type                      = toMyNumber(v.equip_type)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.limitlevel) then
            row_data.limitlevel                      = toMyNumber(v.limitlevel)
        end
        if 0 ~= toMyNumber(v.stackable) then
            row_data.stackable                       = toMyNumber(v.stackable)
        end
        if 0 ~= toMyNumber(v.occupation) then
            row_data.occupation                      = toMyNumber(v.occupation)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        if 0 ~= toMyNumber(v.bind) then
            row_data.bind                            = toMyNumber(v.bind)
        end
        if 0 ~= toMyNumber(v.del_bind) then
            row_data.del_bind                        = toMyNumber(v.del_bind)
        end
        if 0 ~= toMyNumber(v.due_time) then
            row_data.due_time                        = toMyNumber(v.due_time)
        end
        if 0 ~= toMyNumber(v.unique) then
            row_data.unique                          = toMyNumber(v.unique)
        end
        if 0 ~= toMyNumber(v.drop_dead) then
            row_data.drop_dead                       = toMyNumber(v.drop_dead)
        end
        if 0 ~= toMyNumber(v.drop_logout) then
            row_data.drop_logout                     = toMyNumber(v.drop_logout)
        end
        if 0 ~= toMyNumber(v.auto_buy_gold) then
            row_data.auto_buy_gold                   = toMyNumber(v.auto_buy_gold)
        end
        local temp_data = {}
        if nil ~= v.coin then
            local x,y,z = string.match(v.coin,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.coin                          = temp_data
            end
        end
        if 0 ~= toMyNumber(v.auto_sell) then
            row_data.auto_sell                       = toMyNumber(v.auto_sell)
        end
        row_data.attrs = {}
        for i = 1,4 do
            local temp_str = "attrs" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.attrs, temp_data)
            end
        end
        row_data.slave_attrs = {}
        for i = 1,6 do
            local temp_str = "slave_attrs" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.slave_attrs, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.multiuse) then
            row_data.multiuse                        = toMyNumber(v.multiuse)
        end
        local temp_data = {}
        if nil ~= v.buff then
            local x,y,z = string.match(v.buff,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.buff                          = temp_data
            end
        end
        if 0 ~= toMyNumber(v.bias_id) then
            row_data.bias_id                         = toMyNumber(v.bias_id)
        end
        if 0 ~= toMyNumber(v.can_exchange) then
            row_data.can_exchange                    = toMyNumber(v.can_exchange)
        end
        if 0 ~= toMyNumber(v.can_sell) then
            row_data.can_sell                        = toMyNumber(v.can_sell)
        end
        if 0 ~= toMyNumber(v.can_drop) then
            row_data.can_drop                        = toMyNumber(v.can_drop)
        end
        if 0 ~= toMyNumber(v.can_grant) then
            row_data.can_grant                       = toMyNumber(v.can_grant)
        end
        if 0 ~= toMyNumber(v.cooltime) then
            row_data.cooltime                        = toMyNumber(v.cooltime)
        end
        if 0 ~= toMyNumber(v.oddid) then
            row_data.oddid                           = toMyNumber(v.oddid)
        end
        if 0 ~= toMyNumber(v.marktype) then
            row_data.marktype                        = toMyNumber(v.marktype)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if 0 ~= toMyNumber(v.soul_score) then
            row_data.soul_score                      = toMyNumber(v.soul_score)
        end
        if 0 ~= toMyNumber(v.open_cost) then
            row_data.open_cost                       = toMyNumber(v.open_cost)
        end
        if 0 ~= toMyNumber(v.src_item_id) then
            row_data.src_item_id                     = toMyNumber(v.src_item_id)
        end
        row_data.sources = {}
        for i = 1,10 do
            local temp_str = "sources" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.sources, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Item"] = data
    collectgarbage( 'collect' )
end

function findItem(first)
    if nil == json_table_data["xls/Item"] then
        ItemLoadData()
    end
    local temp_tb = json_table_data["xls/Item"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.model then
        data.model = 0
    end
    if nil == data.locale_id then
        data.locale_id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.icon then
        data.icon = 0
    end
    if nil == data.icon_resource then
        data.icon_resource = ""
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.client_type then
        data.client_type = 0
    end
    if nil == data.subclass then
        data.subclass = 0
    end
    if nil == data.equip_type then
        data.equip_type = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.limitlevel then
        data.limitlevel = 0
    end
    if nil == data.stackable then
        data.stackable = 0
    end
    if nil == data.occupation then
        data.occupation = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.bind then
        data.bind = 0
    end
    if nil == data.del_bind then
        data.del_bind = 0
    end
    if nil == data.due_time then
        data.due_time = 0
    end
    if nil == data.unique then
        data.unique = 0
    end
    if nil == data.drop_dead then
        data.drop_dead = 0
    end
    if nil == data.drop_logout then
        data.drop_logout = 0
    end
    if nil == data.auto_buy_gold then
        data.auto_buy_gold = 0
    end
    if nil == data.coin then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.coin = temp_data
    end
    if nil == data.auto_sell then
        data.auto_sell = 0
    end
    if nil == data.multiuse then
        data.multiuse = 0
    end
    if nil == data.buff then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.buff = temp_data
    end
    if nil == data.bias_id then
        data.bias_id = 0
    end
    if nil == data.can_exchange then
        data.can_exchange = 0
    end
    if nil == data.can_sell then
        data.can_sell = 0
    end
    if nil == data.can_drop then
        data.can_drop = 0
    end
    if nil == data.can_grant then
        data.can_grant = 0
    end
    if nil == data.cooltime then
        data.cooltime = 0
    end
    if nil == data.oddid then
        data.oddid = 0
    end
    if nil == data.marktype then
        data.marktype = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    if nil == data.soul_score then
        data.soul_score = 0
    end
    if nil == data.open_cost then
        data.open_cost = 0
    end
    if nil == data.src_item_id then
        data.src_item_id = 0
    end
    return temp_tb[first]
end

function ItemMergeLoadData()
    if nil ~= json_table_data["xls/ItemMerge.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/ItemMerge.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.limit_level) then
            row_data.limit_level                     = toMyNumber(v.limit_level)
        end
        if 0 ~= toMyNumber(v.item_id) then
            row_data.item_id                         = toMyNumber(v.item_id)
        end
        if 0 ~= toMyNumber(v.package_id) then
            row_data.package_id                      = toMyNumber(v.package_id)
        end
        local temp_data = {}
        if nil ~= v.dst_item then
            local x,y,z = string.match(v.dst_item,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.dst_item                      = temp_data
            end
        end
        row_data.materials = {}
        for i = 1,5 do
            local temp_str = "materials" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.materials, temp_data)
            end
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/ItemMerge"] = data
    collectgarbage( 'collect' )
end

function findItemMerge(first)
    if nil == json_table_data["xls/ItemMerge"] then
        ItemMergeLoadData()
    end
    local temp_tb = json_table_data["xls/ItemMerge"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.limit_level then
        data.limit_level = 0
    end
    if nil == data.item_id then
        data.item_id = 0
    end
    if nil == data.package_id then
        data.package_id = 0
    end
    if nil == data.dst_item then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.dst_item = temp_data
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function ItemOpenLoadData()
    if nil ~= json_table_data["xls/ItemOpen.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/ItemOpen.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.open_id) then
            row_data.open_id                         = toMyNumber(v.open_id)
        end
        if 0 ~= toMyNumber(v.reward) then
            row_data.reward                          = toMyNumber(v.reward)
        end
        local temp_data = {}
        if nil ~= v.level_rand then
            local x,y = string.match(v.level_rand,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.level_rand                    = temp_data
            end
        end
        if 0 ~= toMyNumber(v.percent) then
            row_data.percent                         = toMyNumber(v.percent)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/ItemOpen"] = data
    collectgarbage( 'collect' )
end

function findItemOpen(first)
    if nil == json_table_data["xls/ItemOpen"] then
        ItemOpenLoadData()
    end
    local temp_tb = json_table_data["xls/ItemOpen"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.open_id then
        data.open_id = 0
    end
    if nil == data.reward then
        data.reward = 0
    end
    if nil == data.level_rand then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.level_rand = temp_data
    end
    if nil == data.percent then
        data.percent = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function ItemTypeLoadData()
    if nil ~= json_table_data["xls/ItemType.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/ItemType.json")) do
        local row_data = {}
        row_data.item_type                       = toMyNumber(v.item_type)
        if 0 ~= toMyNumber(v.bag_type) then
            row_data.bag_type                        = toMyNumber(v.bag_type)
        end
        row_data.bag_moves = {}
        for i = 1,4 do
            local temp_str = "bag_moves" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.bag_moves, toMyNumber(v[temp_str]))
            end
        end
        if nil ~= row_data.item_type then
            data[row_data.item_type] = row_data
        end
    end
    json_table_data["xls/ItemType"] = data
    collectgarbage( 'collect' )
end

function findItemType(first)
    if nil == json_table_data["xls/ItemType"] then
        ItemTypeLoadData()
    end
    local temp_tb = json_table_data["xls/ItemType"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.item_type then
        data.item_type = 0
    end
    if nil == data.bag_type then
        data.bag_type = 0
    end
    return temp_tb[first]
end

function LevelLoadData()
    if nil ~= json_table_data["xls/Level.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Level.json")) do
        local row_data = {}
        row_data.level                           = toMyNumber(v.level)
        if 0 ~= toMyNumber(v.team_xp) then
            row_data.team_xp                         = toMyNumber(v.team_xp)
        end
        if 0 ~= toMyNumber(v.vip_xp) then
            row_data.vip_xp                          = toMyNumber(v.vip_xp)
        end
        if 0 ~= toMyNumber(v.strength) then
            row_data.strength                        = toMyNumber(v.strength)
        end
        if 0 ~= toMyNumber(v.strength_buy) then
            row_data.strength_buy                    = toMyNumber(v.strength_buy)
        end
        if 0 ~= toMyNumber(v.strength_price) then
            row_data.strength_price                  = toMyNumber(v.strength_price)
        end
        if 0 ~= toMyNumber(v.strength_give) then
            row_data.strength_give                   = toMyNumber(v.strength_give)
        end
        if 0 ~= toMyNumber(v.formation_count) then
            row_data.formation_count                 = toMyNumber(v.formation_count)
        end
        if 0 ~= toMyNumber(v.formation_totem_count) then
            row_data.formation_totem_count            = toMyNumber(v.formation_totem_count)
        end
        if 0 ~= toMyNumber(v.soldier_lv) then
            row_data.soldier_lv                      = toMyNumber(v.soldier_lv)
        end
        if 0 ~= toMyNumber(v.active_score_max) then
            row_data.active_score_max                = toMyNumber(v.active_score_max)
        end
        if 0 ~= toMyNumber(v.building_gold_times) then
            row_data.building_gold_times             = toMyNumber(v.building_gold_times)
        end
        if 0 ~= toMyNumber(v.building_water_times) then
            row_data.building_water_times            = toMyNumber(v.building_water_times)
        end
        if 0 ~= toMyNumber(v.singlearena_times) then
            row_data.singlearena_times               = toMyNumber(v.singlearena_times)
        end
        if 0 ~= toMyNumber(v.singlearena_price) then
            row_data.singlearena_price               = toMyNumber(v.singlearena_price)
        end
        local temp_data = {}
        if nil ~= v.task_30001 then
            local x,y,z = string.match(v.task_30001,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.task_30001                    = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.task_30002 then
            local x,y,z = string.match(v.task_30002,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.task_30002                    = temp_data
            end
        end
        if 0 ~= toMyNumber(v.copy_normal_reset_times) then
            row_data.copy_normal_reset_times            = toMyNumber(v.copy_normal_reset_times)
        end
        if 0 ~= toMyNumber(v.copy_elite_reset_times) then
            row_data.copy_elite_reset_times            = toMyNumber(v.copy_elite_reset_times)
        end
        if 0 ~= toMyNumber(v.copy_normal_reset_price) then
            row_data.copy_normal_reset_price            = toMyNumber(v.copy_normal_reset_price)
        end
        if 0 ~= toMyNumber(v.copy_elite_reset_price) then
            row_data.copy_elite_reset_price            = toMyNumber(v.copy_elite_reset_price)
        end
        if "" ~= v.open_desc then
            row_data.open_desc                       = v.open_desc
        end
        if 0 ~= toMyNumber(v.tomb_ratio) then
            row_data.tomb_ratio                      = toMyNumber(v.tomb_ratio)
        end
        if "" ~= v.vip_rights_desc then
            row_data.vip_rights_desc                 = v.vip_rights_desc
        end
        if 0 ~= toMyNumber(v.glyph_lv) then
            row_data.glyph_lv                        = toMyNumber(v.glyph_lv)
        end
        if nil ~= row_data.level then
            data[row_data.level] = row_data
        end
    end
    json_table_data["xls/Level"] = data
    collectgarbage( 'collect' )
end

function findLevel(first)
    if nil == json_table_data["xls/Level"] then
        LevelLoadData()
    end
    local temp_tb = json_table_data["xls/Level"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.team_xp then
        data.team_xp = 0
    end
    if nil == data.vip_xp then
        data.vip_xp = 0
    end
    if nil == data.strength then
        data.strength = 0
    end
    if nil == data.strength_buy then
        data.strength_buy = 0
    end
    if nil == data.strength_price then
        data.strength_price = 0
    end
    if nil == data.strength_give then
        data.strength_give = 0
    end
    if nil == data.formation_count then
        data.formation_count = 0
    end
    if nil == data.formation_totem_count then
        data.formation_totem_count = 0
    end
    if nil == data.soldier_lv then
        data.soldier_lv = 0
    end
    if nil == data.active_score_max then
        data.active_score_max = 0
    end
    if nil == data.building_gold_times then
        data.building_gold_times = 0
    end
    if nil == data.building_water_times then
        data.building_water_times = 0
    end
    if nil == data.singlearena_times then
        data.singlearena_times = 0
    end
    if nil == data.singlearena_price then
        data.singlearena_price = 0
    end
    if nil == data.task_30001 then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.task_30001 = temp_data
    end
    if nil == data.task_30002 then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.task_30002 = temp_data
    end
    if nil == data.copy_normal_reset_times then
        data.copy_normal_reset_times = 0
    end
    if nil == data.copy_elite_reset_times then
        data.copy_elite_reset_times = 0
    end
    if nil == data.copy_normal_reset_price then
        data.copy_normal_reset_price = 0
    end
    if nil == data.copy_elite_reset_price then
        data.copy_elite_reset_price = 0
    end
    if nil == data.open_desc then
        data.open_desc = ""
    end
    if nil == data.tomb_ratio then
        data.tomb_ratio = 0
    end
    if nil == data.vip_rights_desc then
        data.vip_rights_desc = ""
    end
    if nil == data.glyph_lv then
        data.glyph_lv = 0
    end
    return temp_tb[first]
end

function MarketLoadData()
    if nil ~= json_table_data["xls/Market.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Market.json")) do
        local row_data = {}
        row_data.item_id                         = toMyNumber(v.item_id)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.group) then
            row_data.group                           = toMyNumber(v.group)
        end
        if 0 ~= toMyNumber(v.value) then
            row_data.value                           = toMyNumber(v.value)
        end
        if nil ~= row_data.item_id then
            data[row_data.item_id] = row_data
        end
    end
    json_table_data["xls/Market"] = data
    collectgarbage( 'collect' )
end

function findMarket(first)
    if nil == json_table_data["xls/Market"] then
        MarketLoadData()
    end
    local temp_tb = json_table_data["xls/Market"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.item_id then
        data.item_id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.group then
        data.group = 0
    end
    if nil == data.value then
        data.value = 0
    end
    return temp_tb[first]
end

function MonsterLoadData()
    if nil ~= json_table_data["xls/Monster.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Monster.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.local_id) then
            row_data.local_id                        = toMyNumber(v.local_id)
        end
        if 0 ~= toMyNumber(v.class_id) then
            row_data.class_id                        = toMyNumber(v.class_id)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.equip_type) then
            row_data.equip_type                      = toMyNumber(v.equip_type)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if "" ~= v.animation_name then
            row_data.animation_name                  = v.animation_name
        end
        if "" ~= v.music then
            row_data.music                           = v.music
        end
        if 0 ~= toMyNumber(v.avatar) then
            row_data.avatar                          = toMyNumber(v.avatar)
        end
        if 0 ~= toMyNumber(v.occupation) then
            row_data.occupation                      = toMyNumber(v.occupation)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        row_data.packets = {}
        for i = 1,5 do
            local temp_str = "packets" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.packets, toMyNumber(v[temp_str]))
            end
        end
        if 0 ~= toMyNumber(v.fight_value) then
            row_data.fight_value                     = toMyNumber(v.fight_value)
        end
        if 0 ~= toMyNumber(v.initial_rage) then
            row_data.initial_rage                    = toMyNumber(v.initial_rage)
        end
        if 0 ~= toMyNumber(v.hp) then
            row_data.hp                              = toMyNumber(v.hp)
        end
        if 0 ~= toMyNumber(v.physical_ack) then
            row_data.physical_ack                    = toMyNumber(v.physical_ack)
        end
        if 0 ~= toMyNumber(v.physical_def) then
            row_data.physical_def                    = toMyNumber(v.physical_def)
        end
        if 0 ~= toMyNumber(v.magic_ack) then
            row_data.magic_ack                       = toMyNumber(v.magic_ack)
        end
        if 0 ~= toMyNumber(v.magic_def) then
            row_data.magic_def                       = toMyNumber(v.magic_def)
        end
        if 0 ~= toMyNumber(v.speed) then
            row_data.speed                           = toMyNumber(v.speed)
        end
        if 0 ~= toMyNumber(v.critper) then
            row_data.critper                         = toMyNumber(v.critper)
        end
        if 0 ~= toMyNumber(v.crithurt) then
            row_data.crithurt                        = toMyNumber(v.crithurt)
        end
        if 0 ~= toMyNumber(v.critper_def) then
            row_data.critper_def                     = toMyNumber(v.critper_def)
        end
        if 0 ~= toMyNumber(v.crithurt_def) then
            row_data.crithurt_def                    = toMyNumber(v.crithurt_def)
        end
        if 0 ~= toMyNumber(v.hitper) then
            row_data.hitper                          = toMyNumber(v.hitper)
        end
        if 0 ~= toMyNumber(v.dodgeper) then
            row_data.dodgeper                        = toMyNumber(v.dodgeper)
        end
        if 0 ~= toMyNumber(v.parryper) then
            row_data.parryper                        = toMyNumber(v.parryper)
        end
        if 0 ~= toMyNumber(v.parryper_dec) then
            row_data.parryper_dec                    = toMyNumber(v.parryper_dec)
        end
        if 0 ~= toMyNumber(v.stun_def) then
            row_data.stun_def                        = toMyNumber(v.stun_def)
        end
        if 0 ~= toMyNumber(v.silent_def) then
            row_data.silent_def                      = toMyNumber(v.silent_def)
        end
        if 0 ~= toMyNumber(v.weak_def) then
            row_data.weak_def                        = toMyNumber(v.weak_def)
        end
        if 0 ~= toMyNumber(v.fire_def) then
            row_data.fire_def                        = toMyNumber(v.fire_def)
        end
        if 0 ~= toMyNumber(v.rebound_physical_ack) then
            row_data.rebound_physical_ack            = toMyNumber(v.rebound_physical_ack)
        end
        if 0 ~= toMyNumber(v.rebound_magic_ack) then
            row_data.rebound_magic_ack               = toMyNumber(v.rebound_magic_ack)
        end
        row_data.odds = {}
        for i = 1,7 do
            local temp_str = "odds" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.odds, temp_data)
            end
        end
        row_data.skills = {}
        for i = 1,6 do
            local temp_str = "skills" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.skills, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.money) then
            row_data.money                           = toMyNumber(v.money)
        end
        if 0 ~= toMyNumber(v.exp) then
            row_data.exp                             = toMyNumber(v.exp)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if 0 ~= toMyNumber(v.hp_layer) then
            row_data.hp_layer                        = toMyNumber(v.hp_layer)
        end
        row_data.fight_monster = {}
        for i = 1,5 do
            local temp_str = "fight_monster" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.fight_monster, toMyNumber(v[temp_str]))
            end
        end
        if 0 ~= toMyNumber(v.help_monster) then
            row_data.help_monster                    = toMyNumber(v.help_monster)
        end
        if 0 ~= toMyNumber(v.strength) then
            row_data.strength                        = toMyNumber(v.strength)
        end
        if 0 ~= toMyNumber(v.recover_critper) then
            row_data.recover_critper                 = toMyNumber(v.recover_critper)
        end
        if 0 ~= toMyNumber(v.recover_critper_def) then
            row_data.recover_critper_def             = toMyNumber(v.recover_critper_def)
        end
        if 0 ~= toMyNumber(v.recover_add_fix) then
            row_data.recover_add_fix                 = toMyNumber(v.recover_add_fix)
        end
        if 0 ~= toMyNumber(v.recover_del_fix) then
            row_data.recover_del_fix                 = toMyNumber(v.recover_del_fix)
        end
        if 0 ~= toMyNumber(v.recover_add_per) then
            row_data.recover_add_per                 = toMyNumber(v.recover_add_per)
        end
        if 0 ~= toMyNumber(v.recover_del_per) then
            row_data.recover_del_per                 = toMyNumber(v.recover_del_per)
        end
        if 0 ~= toMyNumber(v.rage_add_fix) then
            row_data.rage_add_fix                    = toMyNumber(v.rage_add_fix)
        end
        if 0 ~= toMyNumber(v.rage_del_fix) then
            row_data.rage_del_fix                    = toMyNumber(v.rage_del_fix)
        end
        if 0 ~= toMyNumber(v.rage_add_per) then
            row_data.rage_add_per                    = toMyNumber(v.rage_add_per)
        end
        if 0 ~= toMyNumber(v.rage_del_per) then
            row_data.rage_del_per                    = toMyNumber(v.rage_del_per)
        end
        row_data.sounds = {}
        for i = 1,3 do
            local temp_str = "sounds" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.sounds, v[temp_str])
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Monster"] = data
    collectgarbage( 'collect' )
end

function findMonster(first)
    if nil == json_table_data["xls/Monster"] then
        MonsterLoadData()
    end
    local temp_tb = json_table_data["xls/Monster"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.local_id then
        data.local_id = 0
    end
    if nil == data.class_id then
        data.class_id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.equip_type then
        data.equip_type = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.animation_name then
        data.animation_name = ""
    end
    if nil == data.music then
        data.music = ""
    end
    if nil == data.avatar then
        data.avatar = 0
    end
    if nil == data.occupation then
        data.occupation = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.fight_value then
        data.fight_value = 0
    end
    if nil == data.initial_rage then
        data.initial_rage = 0
    end
    if nil == data.hp then
        data.hp = 0
    end
    if nil == data.physical_ack then
        data.physical_ack = 0
    end
    if nil == data.physical_def then
        data.physical_def = 0
    end
    if nil == data.magic_ack then
        data.magic_ack = 0
    end
    if nil == data.magic_def then
        data.magic_def = 0
    end
    if nil == data.speed then
        data.speed = 0
    end
    if nil == data.critper then
        data.critper = 0
    end
    if nil == data.crithurt then
        data.crithurt = 0
    end
    if nil == data.critper_def then
        data.critper_def = 0
    end
    if nil == data.crithurt_def then
        data.crithurt_def = 0
    end
    if nil == data.hitper then
        data.hitper = 0
    end
    if nil == data.dodgeper then
        data.dodgeper = 0
    end
    if nil == data.parryper then
        data.parryper = 0
    end
    if nil == data.parryper_dec then
        data.parryper_dec = 0
    end
    if nil == data.stun_def then
        data.stun_def = 0
    end
    if nil == data.silent_def then
        data.silent_def = 0
    end
    if nil == data.weak_def then
        data.weak_def = 0
    end
    if nil == data.fire_def then
        data.fire_def = 0
    end
    if nil == data.rebound_physical_ack then
        data.rebound_physical_ack = 0
    end
    if nil == data.rebound_magic_ack then
        data.rebound_magic_ack = 0
    end
    if nil == data.money then
        data.money = 0
    end
    if nil == data.exp then
        data.exp = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    if nil == data.hp_layer then
        data.hp_layer = 0
    end
    if nil == data.help_monster then
        data.help_monster = 0
    end
    if nil == data.strength then
        data.strength = 0
    end
    if nil == data.recover_critper then
        data.recover_critper = 0
    end
    if nil == data.recover_critper_def then
        data.recover_critper_def = 0
    end
    if nil == data.recover_add_fix then
        data.recover_add_fix = 0
    end
    if nil == data.recover_del_fix then
        data.recover_del_fix = 0
    end
    if nil == data.recover_add_per then
        data.recover_add_per = 0
    end
    if nil == data.recover_del_per then
        data.recover_del_per = 0
    end
    if nil == data.rage_add_fix then
        data.rage_add_fix = 0
    end
    if nil == data.rage_del_fix then
        data.rage_del_fix = 0
    end
    if nil == data.rage_add_per then
        data.rage_add_per = 0
    end
    if nil == data.rage_del_per then
        data.rage_del_per = 0
    end
    return temp_tb[first]
end

function MonsterFightConfLoadData()
    if nil ~= json_table_data["xls/MonsterFightConf.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/MonsterFightConf.json")) do
        local row_data = {}
        row_data.index                           = toMyNumber(v.index)
        row_data.add = {}
        for i = 1,6 do
            local temp_str = "add" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.add, temp_data)
            end
        end
        row_data.totemadd = {}
        for i = 1,3 do
            local temp_str = "totemadd" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.totemadd, temp_data)
            end
        end
        if nil ~= row_data.index then
            data[row_data.index] = row_data
        end
    end
    json_table_data["xls/MonsterFightConf"] = data
    collectgarbage( 'collect' )
end

function findMonsterFightConf(first)
    if nil == json_table_data["xls/MonsterFightConf"] then
        MonsterFightConfLoadData()
    end
    local temp_tb = json_table_data["xls/MonsterFightConf"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.index then
        data.index = 0
    end
    return temp_tb[first]
end

function MonsterTalkLoadData()
    if nil ~= json_table_data["xls/MonsterTalk.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/MonsterTalk.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.talk then
            row_data.talk                            = v.talk
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/MonsterTalk"] = data
    collectgarbage( 'collect' )
end

function findMonsterTalk(first)
    if nil == json_table_data["xls/MonsterTalk"] then
        MonsterTalkLoadData()
    end
    local temp_tb = json_table_data["xls/MonsterTalk"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.talk then
        data.talk = ""
    end
    return temp_tb[first]
end

function MysteryShopLoadData()
    if nil ~= json_table_data["xls/MysteryShop.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/MysteryShop.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.min_level) then
            row_data.min_level                       = toMyNumber(v.min_level)
        end
        if 0 ~= toMyNumber(v.max_level) then
            row_data.max_level                       = toMyNumber(v.max_level)
        end
        if 0 ~= toMyNumber(v.rate) then
            row_data.rate                            = toMyNumber(v.rate)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/MysteryShop"] = data
    collectgarbage( 'collect' )
end

function findMysteryShop(first)
    if nil == json_table_data["xls/MysteryShop"] then
        MysteryShopLoadData()
    end
    local temp_tb = json_table_data["xls/MysteryShop"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.min_level then
        data.min_level = 0
    end
    if nil == data.max_level then
        data.max_level = 0
    end
    if nil == data.rate then
        data.rate = 0
    end
    return temp_tb[first]
end

function NpcLoadData()
    if nil ~= json_table_data["xls/Npc.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Npc.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.body) then
            row_data.body                            = toMyNumber(v.body)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Npc"] = data
    collectgarbage( 'collect' )
end

function findNpc(first)
    if nil == json_table_data["xls/Npc"] then
        NpcLoadData()
    end
    local temp_tb = json_table_data["xls/Npc"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.body then
        data.body = 0
    end
    return temp_tb[first]
end

function OddLoadData()
    if nil ~= json_table_data["xls/Odd.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Odd.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.level                           = toMyNumber(v.level)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.max_count) then
            row_data.max_count                       = toMyNumber(v.max_count)
        end
        if 0 ~= toMyNumber(v.condition) then
            row_data.condition                       = toMyNumber(v.condition)
        end
        if 0 ~= toMyNumber(v.immediately) then
            row_data.immediately                     = toMyNumber(v.immediately)
        end
        if 0 ~= toMyNumber(v.percent) then
            row_data.percent                         = toMyNumber(v.percent)
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.attr) then
            row_data.attr                            = toMyNumber(v.attr)
        end
        if 0 ~= toMyNumber(v.delay_round) then
            row_data.delay_round                     = toMyNumber(v.delay_round)
        end
        if 0 ~= toMyNumber(v.keep_round) then
            row_data.keep_round                      = toMyNumber(v.keep_round)
        end
        local temp_data = {}
        if nil ~= v.status then
            local x,y,z = string.match(v.status,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.status                        = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.effect then
            local x,y,z = string.match(v.effect,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.effect                        = temp_data
            end
        end
        if 0 ~= toMyNumber(v.effect_count) then
            row_data.effect_count                    = toMyNumber(v.effect_count)
        end
        if "" ~= v.description then
            row_data.description                     = v.description
        end
        if 0 ~= toMyNumber(v.target_type_skill) then
            row_data.target_type_skill               = toMyNumber(v.target_type_skill)
        end
        if 0 ~= toMyNumber(v.target_type_special) then
            row_data.target_type_special             = toMyNumber(v.target_type_special)
        end
        if 0 ~= toMyNumber(v.target_type) then
            row_data.target_type                     = toMyNumber(v.target_type)
        end
        if 0 ~= toMyNumber(v.target_range_count) then
            row_data.target_range_count              = toMyNumber(v.target_range_count)
        end
        if 0 ~= toMyNumber(v.target_range_cond) then
            row_data.target_range_cond               = toMyNumber(v.target_range_cond)
        end
        local temp_data = {}
        if nil ~= v.addodd then
            local x,y = string.match(v.addodd,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.addodd                        = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.changeodd then
            local x,y = string.match(v.changeodd,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.changeodd                     = temp_data
            end
        end
        if 0 ~= toMyNumber(v.limit_count) then
            row_data.limit_count                     = toMyNumber(v.limit_count)
        end
        if 0 ~= toMyNumber(v.limit_count_all) then
            row_data.limit_count_all                 = toMyNumber(v.limit_count_all)
        end
        if "" ~= v.onceeffect then
            row_data.onceeffect                      = v.onceeffect
        end
        if "" ~= v.buffeffect then
            row_data.buffeffect                      = v.buffeffect
        end
        if "" ~= v.buffname then
            row_data.buffname                        = v.buffname
        end
        if "" ~= v.buffeffectname then
            row_data.buffeffectname                  = v.buffeffectname
        end
        if 0 ~= toMyNumber(v.buff_offset) then
            row_data.buff_offset                     = toMyNumber(v.buff_offset)
        end
        if 0 ~= toMyNumber(v.buff_only) then
            row_data.buff_only                       = toMyNumber(v.buff_only)
        end
        if "" ~= v.passive_act then
            row_data.passive_act                     = v.passive_act
        end
        if nil ~= row_data.id and nil ~= row_data.level then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.level] = row_data
        end
    end
    json_table_data["xls/Odd"] = data
    collectgarbage( 'collect' )
end

function findOdd(first, second)
    if nil == json_table_data["xls/Odd"] then
        OddLoadData()
    end
    local temp_tb = json_table_data["xls/Odd"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.max_count then
        data.max_count = 0
    end
    if nil == data.condition then
        data.condition = 0
    end
    if nil == data.immediately then
        data.immediately = 0
    end
    if nil == data.percent then
        data.percent = 0
    end
    if nil == data.icon then
        data.icon = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.attr then
        data.attr = 0
    end
    if nil == data.delay_round then
        data.delay_round = 0
    end
    if nil == data.keep_round then
        data.keep_round = 0
    end
    if nil == data.status then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.status = temp_data
    end
    if nil == data.effect then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.effect = temp_data
    end
    if nil == data.effect_count then
        data.effect_count = 0
    end
    if nil == data.description then
        data.description = ""
    end
    if nil == data.target_type_skill then
        data.target_type_skill = 0
    end
    if nil == data.target_type_special then
        data.target_type_special = 0
    end
    if nil == data.target_type then
        data.target_type = 0
    end
    if nil == data.target_range_count then
        data.target_range_count = 0
    end
    if nil == data.target_range_cond then
        data.target_range_cond = 0
    end
    if nil == data.addodd then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.addodd = temp_data
    end
    if nil == data.changeodd then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.changeodd = temp_data
    end
    if nil == data.limit_count then
        data.limit_count = 0
    end
    if nil == data.limit_count_all then
        data.limit_count_all = 0
    end
    if nil == data.onceeffect then
        data.onceeffect = ""
    end
    if nil == data.buffeffect then
        data.buffeffect = ""
    end
    if nil == data.buffname then
        data.buffname = ""
    end
    if nil == data.buffeffectname then
        data.buffeffectname = ""
    end
    if nil == data.buff_offset then
        data.buff_offset = 0
    end
    if nil == data.buff_only then
        data.buff_only = 0
    end
    if nil == data.passive_act then
        data.passive_act = ""
    end
    return temp_tb[first][second]
end

function OpenLoadData()
    if nil ~= json_table_data["xls/Open.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Open.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.open_type) then
            row_data.open_type                       = toMyNumber(v.open_type)
        end
        if 0 ~= toMyNumber(v.open_term) then
            row_data.open_term                       = toMyNumber(v.open_term)
        end
        if 0 ~= toMyNumber(v.run_type) then
            row_data.run_type                        = toMyNumber(v.run_type)
        end
        if "" ~= v.run_data then
            row_data.run_data                        = v.run_data
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if "" ~= v.final_command then
            row_data.final_command                   = v.final_command
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Open"] = data
    collectgarbage( 'collect' )
end

function findOpen(first)
    if nil == json_table_data["xls/Open"] then
        OpenLoadData()
    end
    local temp_tb = json_table_data["xls/Open"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.open_type then
        data.open_type = 0
    end
    if nil == data.open_term then
        data.open_term = 0
    end
    if nil == data.run_type then
        data.run_type = 0
    end
    if nil == data.run_data then
        data.run_data = ""
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.desc then
        data.desc = ""
    end
    if nil == data.final_command then
        data.final_command = ""
    end
    return temp_tb[first]
end

function OpenTargetLoadData()
    if nil ~= json_table_data["xls/OpenTarget.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/OpenTarget.json")) do
        local row_data = {}
        row_data.day                             = toMyNumber(v.day)
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.a_type) then
            row_data.a_type                          = toMyNumber(v.a_type)
        end
        if 0 ~= toMyNumber(v.if_type) then
            row_data.if_type                         = toMyNumber(v.if_type)
        end
        if 0 ~= toMyNumber(v.if_value_1) then
            row_data.if_value_1                      = toMyNumber(v.if_value_1)
        end
        if 0 ~= toMyNumber(v.if_value_2) then
            row_data.if_value_2                      = toMyNumber(v.if_value_2)
        end
        row_data.item = {}
        for i = 1,2 do
            local temp_str = "item" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.item, temp_data)
            end
        end
        local temp_data = {}
        if nil ~= v.coin_1 then
            local x,y,z = string.match(v.coin_1,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.coin_1                        = temp_data
            end
        end
        row_data.reward = {}
        for i = 1,3 do
            local temp_str = "reward" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.reward, temp_data)
            end
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.day and nil ~= row_data.id then
            if nil == data[row_data.day] then 
                data[row_data.day] = {}
            end
            data[row_data.day][row_data.id] = row_data
        end
    end
    json_table_data["xls/OpenTarget"] = data
    collectgarbage( 'collect' )
end

function findOpenTarget(first, second)
    if nil == json_table_data["xls/OpenTarget"] then
        OpenTargetLoadData()
    end
    local temp_tb = json_table_data["xls/OpenTarget"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.day then
        data.day = 0
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.a_type then
        data.a_type = 0
    end
    if nil == data.if_type then
        data.if_type = 0
    end
    if nil == data.if_value_1 then
        data.if_value_1 = 0
    end
    if nil == data.if_value_2 then
        data.if_value_2 = 0
    end
    if nil == data.coin_1 then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.coin_1 = temp_data
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first][second]
end

function PacketLoadData()
    if nil ~= json_table_data["xls/Packet.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Packet.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.reward = {}
        for i = 1,16 do
            local temp_str = "reward" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.reward, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.bias_id) then
            row_data.bias_id                         = toMyNumber(v.bias_id)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Packet"] = data
    collectgarbage( 'collect' )
end

function findPacket(first)
    if nil == json_table_data["xls/Packet"] then
        PacketLoadData()
    end
    local temp_tb = json_table_data["xls/Packet"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.bias_id then
        data.bias_id = 0
    end
    return temp_tb[first]
end

function PaperCreateLoadData()
    if nil ~= json_table_data["xls/PaperCreate.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/PaperCreate.json")) do
        local row_data = {}
        row_data.item_id                         = toMyNumber(v.item_id)
        if 0 ~= toMyNumber(v.active_score) then
            row_data.active_score                    = toMyNumber(v.active_score)
        end
        if 0 ~= toMyNumber(v.level_limit) then
            row_data.level_limit                     = toMyNumber(v.level_limit)
        end
        if 0 ~= toMyNumber(v.skill_type) then
            row_data.skill_type                      = toMyNumber(v.skill_type)
        end
        if 0 ~= toMyNumber(v.paper_skill_level_limit) then
            row_data.paper_skill_level_limit            = toMyNumber(v.paper_skill_level_limit)
        end
        if nil ~= row_data.item_id then
            data[row_data.item_id] = row_data
        end
    end
    json_table_data["xls/PaperCreate"] = data
    collectgarbage( 'collect' )
end

function findPaperCreate(first)
    if nil == json_table_data["xls/PaperCreate"] then
        PaperCreateLoadData()
    end
    local temp_tb = json_table_data["xls/PaperCreate"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.item_id then
        data.item_id = 0
    end
    if nil == data.active_score then
        data.active_score = 0
    end
    if nil == data.level_limit then
        data.level_limit = 0
    end
    if nil == data.skill_type then
        data.skill_type = 0
    end
    if nil == data.paper_skill_level_limit then
        data.paper_skill_level_limit = 0
    end
    return temp_tb[first]
end

function PaperSkillLoadData()
    if nil ~= json_table_data["xls/PaperSkill.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/PaperSkill.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.skill_type) then
            row_data.skill_type                      = toMyNumber(v.skill_type)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.paper_level_limit) then
            row_data.paper_level_limit               = toMyNumber(v.paper_level_limit)
        end
        if 0 ~= toMyNumber(v.collect_skill_level) then
            row_data.collect_skill_level             = toMyNumber(v.collect_skill_level)
        end
        if 0 ~= toMyNumber(v.active_score_limit) then
            row_data.active_score_limit              = toMyNumber(v.active_score_limit)
        end
        if 0 ~= toMyNumber(v.active_score_add) then
            row_data.active_score_add                = toMyNumber(v.active_score_add)
        end
        if 0 ~= toMyNumber(v.create_cost_reduce) then
            row_data.create_cost_reduce              = toMyNumber(v.create_cost_reduce)
        end
        if 0 ~= toMyNumber(v.level_up_star) then
            row_data.level_up_star                   = toMyNumber(v.level_up_star)
        end
        if 0 ~= toMyNumber(v.level_up_money) then
            row_data.level_up_money                  = toMyNumber(v.level_up_money)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/PaperSkill"] = data
    collectgarbage( 'collect' )
end

function findPaperSkill(first)
    if nil == json_table_data["xls/PaperSkill"] then
        PaperSkillLoadData()
    end
    local temp_tb = json_table_data["xls/PaperSkill"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.skill_type then
        data.skill_type = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.paper_level_limit then
        data.paper_level_limit = 0
    end
    if nil == data.collect_skill_level then
        data.collect_skill_level = 0
    end
    if nil == data.active_score_limit then
        data.active_score_limit = 0
    end
    if nil == data.active_score_add then
        data.active_score_add = 0
    end
    if nil == data.create_cost_reduce then
        data.create_cost_reduce = 0
    end
    if nil == data.level_up_star then
        data.level_up_star = 0
    end
    if nil == data.level_up_money then
        data.level_up_money = 0
    end
    return temp_tb[first]
end

function PayLoadData()
    if nil ~= json_table_data["xls/Pay.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Pay.json")) do
        local row_data = {}
        row_data.pay                             = toMyNumber(v.pay)
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        row_data.present = {}
        for i = 1,3 do
            local temp_str = "present" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.present, toMyNumber(v[temp_str]))
            end
        end
        if nil ~= row_data.pay then
            data[row_data.pay] = row_data
        end
    end
    json_table_data["xls/Pay"] = data
    collectgarbage( 'collect' )
end

function findPay(first)
    if nil == json_table_data["xls/Pay"] then
        PayLoadData()
    end
    local temp_tb = json_table_data["xls/Pay"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.pay then
        data.pay = 0
    end
    if nil == data.icon then
        data.icon = 0
    end
    return temp_tb[first]
end

function RankCopyLoadData()
    if nil ~= json_table_data["xls/RankCopy.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/RankCopy.json")) do
        local row_data = {}
        row_data.rank                            = toMyNumber(v.rank)
        if 0 ~= toMyNumber(v.cyc) then
            row_data.cyc                             = toMyNumber(v.cyc)
        end
        if 0 ~= toMyNumber(v.delay) then
            row_data.delay                           = toMyNumber(v.delay)
        end
        if "" ~= v.time then
            row_data.time                            = v.time
        end
        if nil ~= row_data.rank then
            data[row_data.rank] = row_data
        end
    end
    json_table_data["xls/RankCopy"] = data
    collectgarbage( 'collect' )
end

function findRankCopy(first)
    if nil == json_table_data["xls/RankCopy"] then
        RankCopyLoadData()
    end
    local temp_tb = json_table_data["xls/RankCopy"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.rank then
        data.rank = 0
    end
    if nil == data.cyc then
        data.cyc = 0
    end
    if nil == data.delay then
        data.delay = 0
    end
    if nil == data.time then
        data.time = ""
    end
    return temp_tb[first]
end

function RewardLoadData()
    if nil ~= json_table_data["xls/Reward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Reward.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.coins = {}
        for i = 1,16 do
            local temp_str = "coins" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.coins, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Reward"] = data
    collectgarbage( 'collect' )
end

function findReward(first)
    if nil == json_table_data["xls/Reward"] then
        RewardLoadData()
    end
    local temp_tb = json_table_data["xls/Reward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    return temp_tb[first]
end

function RoleConfigLoadData()
    if nil ~= json_table_data["xls/RoleConfig.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/RoleConfig.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.roleName then
            row_data.roleName                        = v.roleName
        end
        if 0 ~= toMyNumber(v.width) then
            row_data.width                           = toMyNumber(v.width)
        end
        if 0 ~= toMyNumber(v.height) then
            row_data.height                          = toMyNumber(v.height)
        end
        if 0 ~= toMyNumber(v.bruiseFrame) then
            row_data.bruiseFrame                     = toMyNumber(v.bruiseFrame)
        end
        if 0 ~= toMyNumber(v.deadFrame) then
            row_data.deadFrame                       = toMyNumber(v.deadFrame)
        end
        if 0 ~= toMyNumber(v.physicalFrame) then
            row_data.physicalFrame                   = toMyNumber(v.physicalFrame)
        end
        if 0 ~= toMyNumber(v.sfFrame) then
            row_data.sfFrame                         = toMyNumber(v.sfFrame)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/RoleConfig"] = data
    collectgarbage( 'collect' )
end

function findRoleConfig(first)
    if nil == json_table_data["xls/RoleConfig"] then
        RoleConfigLoadData()
    end
    local temp_tb = json_table_data["xls/RoleConfig"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.roleName then
        data.roleName = ""
    end
    if nil == data.width then
        data.width = 0
    end
    if nil == data.height then
        data.height = 0
    end
    if nil == data.bruiseFrame then
        data.bruiseFrame = 0
    end
    if nil == data.deadFrame then
        data.deadFrame = 0
    end
    if nil == data.physicalFrame then
        data.physicalFrame = 0
    end
    if nil == data.sfFrame then
        data.sfFrame = 0
    end
    return temp_tb[first]
end

function SignAdditionalCostLoadData()
    if nil ~= json_table_data["xls/SignAdditionalCost.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SignAdditionalCost.json")) do
        local row_data = {}
        row_data.days                            = toMyNumber(v.days)
        local temp_data = {}
        if nil ~= v.cost then
            local x,y,z = string.match(v.cost,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.cost                          = temp_data
            end
        end
        if nil ~= row_data.days then
            data[row_data.days] = row_data
        end
    end
    json_table_data["xls/SignAdditionalCost"] = data
    collectgarbage( 'collect' )
end

function findSignAdditionalCost(first)
    if nil == json_table_data["xls/SignAdditionalCost"] then
        SignAdditionalCostLoadData()
    end
    local temp_tb = json_table_data["xls/SignAdditionalCost"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.days then
        data.days = 0
    end
    if nil == data.cost then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.cost = temp_data
    end
    return temp_tb[first]
end

function SignDayLoadData()
    if nil ~= json_table_data["xls/SignDay.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SignDay.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.date then
            row_data.date                            = v.date
        end
        row_data.rewards = {}
        for i = 1,4 do
            local temp_str = "rewards" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.rewards, temp_data)
            end
        end
        row_data.haohua_rewards = {}
        for i = 1,4 do
            local temp_str = "haohua_rewards" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.haohua_rewards, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SignDay"] = data
    collectgarbage( 'collect' )
end

function findSignDay(first)
    if nil == json_table_data["xls/SignDay"] then
        SignDayLoadData()
    end
    local temp_tb = json_table_data["xls/SignDay"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.date then
        data.date = ""
    end
    return temp_tb[first]
end

function SignSumLoadData()
    if nil ~= json_table_data["xls/SignSum.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SignSum.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.sum_days) then
            row_data.sum_days                        = toMyNumber(v.sum_days)
        end
        row_data.rewards = {}
        for i = 1,4 do
            local temp_str = "rewards" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.rewards, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SignSum"] = data
    collectgarbage( 'collect' )
end

function findSignSum(first)
    if nil == json_table_data["xls/SignSum"] then
        SignSumLoadData()
    end
    local temp_tb = json_table_data["xls/SignSum"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.sum_days then
        data.sum_days = 0
    end
    return temp_tb[first]
end

function SingleArenaBattleRewardLoadData()
    if nil ~= json_table_data["xls/SingleArenaBattleReward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SingleArenaBattleReward.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.field_b) then
            row_data.field_b                         = toMyNumber(v.field_b)
        end
        if 0 ~= toMyNumber(v.field_e) then
            row_data.field_e                         = toMyNumber(v.field_e)
        end
        if 0 ~= toMyNumber(v.field_r) then
            row_data.field_r                         = toMyNumber(v.field_r)
        end
        if 0 ~= toMyNumber(v.field_y) then
            row_data.field_y                         = toMyNumber(v.field_y)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SingleArenaBattleReward"] = data
    collectgarbage( 'collect' )
end

function findSingleArenaBattleReward(first)
    if nil == json_table_data["xls/SingleArenaBattleReward"] then
        SingleArenaBattleRewardLoadData()
    end
    local temp_tb = json_table_data["xls/SingleArenaBattleReward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.field_b then
        data.field_b = 0
    end
    if nil == data.field_e then
        data.field_e = 0
    end
    if nil == data.field_r then
        data.field_r = 0
    end
    if nil == data.field_y then
        data.field_y = 0
    end
    return temp_tb[first]
end

function SingleArenaDayRewardLoadData()
    if nil ~= json_table_data["xls/SingleArenaDayReward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SingleArenaDayReward.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        local temp_data = {}
        if nil ~= v.rank then
            local x,y = string.match(v.rank,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.rank                          = temp_data
            end
        end
        row_data.reward_ = {}
        for i = 1,5 do
            local temp_str = "reward_" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.reward_, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SingleArenaDayReward"] = data
    collectgarbage( 'collect' )
end

function findSingleArenaDayReward(first)
    if nil == json_table_data["xls/SingleArenaDayReward"] then
        SingleArenaDayRewardLoadData()
    end
    local temp_tb = json_table_data["xls/SingleArenaDayReward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.rank then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.rank = temp_data
    end
    return temp_tb[first]
end

function SingleArenaSoldierLoadData()
    if nil ~= json_table_data["xls/SingleArenaSoldier.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SingleArenaSoldier.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.rank) then
            row_data.rank                            = toMyNumber(v.rank)
        end
        if 0 ~= toMyNumber(v.count) then
            row_data.count                           = toMyNumber(v.count)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SingleArenaSoldier"] = data
    collectgarbage( 'collect' )
end

function findSingleArenaSoldier(first)
    if nil == json_table_data["xls/SingleArenaSoldier"] then
        SingleArenaSoldierLoadData()
    end
    local temp_tb = json_table_data["xls/SingleArenaSoldier"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.rank then
        data.rank = 0
    end
    if nil == data.count then
        data.count = 0
    end
    return temp_tb[first]
end

function SingleArenaTotemLoadData()
    if nil ~= json_table_data["xls/SingleArenaTotem.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SingleArenaTotem.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.rank) then
            row_data.rank                            = toMyNumber(v.rank)
        end
        if 0 ~= toMyNumber(v.count) then
            row_data.count                           = toMyNumber(v.count)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SingleArenaTotem"] = data
    collectgarbage( 'collect' )
end

function findSingleArenaTotem(first)
    if nil == json_table_data["xls/SingleArenaTotem"] then
        SingleArenaTotemLoadData()
    end
    local temp_tb = json_table_data["xls/SingleArenaTotem"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.rank then
        data.rank = 0
    end
    if nil == data.count then
        data.count = 0
    end
    return temp_tb[first]
end

function SkillLoadData()
    if nil ~= json_table_data["xls/Skill.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Skill.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.level                           = toMyNumber(v.level)
        if 0 ~= toMyNumber(v.locale_id) then
            row_data.locale_id                       = toMyNumber(v.locale_id)
        end
        if 0 ~= toMyNumber(v.disillusion) then
            row_data.disillusion                     = toMyNumber(v.disillusion)
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.distance) then
            row_data.distance                        = toMyNumber(v.distance)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.condition) then
            row_data.condition                       = toMyNumber(v.condition)
        end
        if 0 ~= toMyNumber(v.attr) then
            row_data.attr                            = toMyNumber(v.attr)
        end
        if 0 ~= toMyNumber(v.occupation) then
            row_data.occupation                      = toMyNumber(v.occupation)
        end
        if 0 ~= toMyNumber(v.icon) then
            row_data.icon                            = toMyNumber(v.icon)
        end
        if 0 ~= toMyNumber(v.icon_type) then
            row_data.icon_type                       = toMyNumber(v.icon_type)
        end
        if 0 ~= toMyNumber(v.buckle_blood) then
            row_data.buckle_blood                    = toMyNumber(v.buckle_blood)
        end
        if "" ~= v.vibrate then
            row_data.vibrate                         = v.vibrate
        end
        if "" ~= v.flash then
            row_data.flash                           = v.flash
        end
        row_data.mights = {}
        for i = 1,15 do
            local temp_str = "mights" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.mights, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.hurt_add) then
            row_data.hurt_add                        = toMyNumber(v.hurt_add)
        end
        if 0 ~= toMyNumber(v.break_per) then
            row_data.break_per                       = toMyNumber(v.break_per)
        end
        if 0 ~= toMyNumber(v.can_break) then
            row_data.can_break                       = toMyNumber(v.can_break)
        end
        if 0 ~= toMyNumber(v.self_addrage) then
            row_data.self_addrage                    = toMyNumber(v.self_addrage)
        end
        if 0 ~= toMyNumber(v.self_costrage) then
            row_data.self_costrage                   = toMyNumber(v.self_costrage)
        end
        if 0 ~= toMyNumber(v.def_addrage) then
            row_data.def_addrage                     = toMyNumber(v.def_addrage)
        end
        if 0 ~= toMyNumber(v.def_delrage) then
            row_data.def_delrage                     = toMyNumber(v.def_delrage)
        end
        if 0 ~= toMyNumber(v.self_addtotem) then
            row_data.self_addtotem                   = toMyNumber(v.self_addtotem)
        end
        if 0 ~= toMyNumber(v.self_costtotem) then
            row_data.self_costtotem                  = toMyNumber(v.self_costtotem)
        end
        if 0 ~= toMyNumber(v.def_addtotem) then
            row_data.def_addtotem                    = toMyNumber(v.def_addtotem)
        end
        if 0 ~= toMyNumber(v.clear_rage) then
            row_data.clear_rage                      = toMyNumber(v.clear_rage)
        end
        if 0 ~= toMyNumber(v.clear_odd) then
            row_data.clear_odd                       = toMyNumber(v.clear_odd)
        end
        if 0 ~= toMyNumber(v.suck_hp) then
            row_data.suck_hp                         = toMyNumber(v.suck_hp)
        end
        if 0 ~= toMyNumber(v.pattern) then
            row_data.pattern                         = toMyNumber(v.pattern)
        end
        if 0 ~= toMyNumber(v.target_type) then
            row_data.target_type                     = toMyNumber(v.target_type)
        end
        if 0 ~= toMyNumber(v.target_range_count) then
            row_data.target_range_count              = toMyNumber(v.target_range_count)
        end
        if 0 ~= toMyNumber(v.target_range_cond) then
            row_data.target_range_cond               = toMyNumber(v.target_range_cond)
        end
        row_data.odds = {}
        for i = 1,3 do
            local temp_str = "odds" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.odds, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.cooldown) then
            row_data.cooldown                        = toMyNumber(v.cooldown)
        end
        if 0 ~= toMyNumber(v.start_round) then
            row_data.start_round                     = toMyNumber(v.start_round)
        end
        if "" ~= v.action_flag then
            row_data.action_flag                     = v.action_flag
        end
        if 0 ~= toMyNumber(v.effect_index) then
            row_data.effect_index                    = toMyNumber(v.effect_index)
        end
        if "" ~= v.skillname then
            row_data.skillname                       = v.skillname
        end
        if 0 ~= toMyNumber(v.interval) then
            row_data.interval                        = toMyNumber(v.interval)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id and nil ~= row_data.level then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.level] = row_data
        end
    end
    json_table_data["xls/Skill"] = data
    collectgarbage( 'collect' )
end

function findSkill(first, second)
    if nil == json_table_data["xls/Skill"] then
        SkillLoadData()
    end
    local temp_tb = json_table_data["xls/Skill"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.locale_id then
        data.locale_id = 0
    end
    if nil == data.disillusion then
        data.disillusion = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.distance then
        data.distance = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.condition then
        data.condition = 0
    end
    if nil == data.attr then
        data.attr = 0
    end
    if nil == data.occupation then
        data.occupation = 0
    end
    if nil == data.icon then
        data.icon = 0
    end
    if nil == data.icon_type then
        data.icon_type = 0
    end
    if nil == data.buckle_blood then
        data.buckle_blood = 0
    end
    if nil == data.vibrate then
        data.vibrate = ""
    end
    if nil == data.flash then
        data.flash = ""
    end
    if nil == data.hurt_add then
        data.hurt_add = 0
    end
    if nil == data.break_per then
        data.break_per = 0
    end
    if nil == data.can_break then
        data.can_break = 0
    end
    if nil == data.self_addrage then
        data.self_addrage = 0
    end
    if nil == data.self_costrage then
        data.self_costrage = 0
    end
    if nil == data.def_addrage then
        data.def_addrage = 0
    end
    if nil == data.def_delrage then
        data.def_delrage = 0
    end
    if nil == data.self_addtotem then
        data.self_addtotem = 0
    end
    if nil == data.self_costtotem then
        data.self_costtotem = 0
    end
    if nil == data.def_addtotem then
        data.def_addtotem = 0
    end
    if nil == data.clear_rage then
        data.clear_rage = 0
    end
    if nil == data.clear_odd then
        data.clear_odd = 0
    end
    if nil == data.suck_hp then
        data.suck_hp = 0
    end
    if nil == data.pattern then
        data.pattern = 0
    end
    if nil == data.target_type then
        data.target_type = 0
    end
    if nil == data.target_range_count then
        data.target_range_count = 0
    end
    if nil == data.target_range_cond then
        data.target_range_cond = 0
    end
    if nil == data.cooldown then
        data.cooldown = 0
    end
    if nil == data.start_round then
        data.start_round = 0
    end
    if nil == data.action_flag then
        data.action_flag = ""
    end
    if nil == data.effect_index then
        data.effect_index = 0
    end
    if nil == data.skillname then
        data.skillname = ""
    end
    if nil == data.interval then
        data.interval = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first][second]
end

function SoldierLoadData()
    if nil ~= json_table_data["xls/Soldier.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Soldier.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.locale_id) then
            row_data.locale_id                       = toMyNumber(v.locale_id)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.star) then
            row_data.star                            = toMyNumber(v.star)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        if 0 ~= toMyNumber(v.gender) then
            row_data.gender                          = toMyNumber(v.gender)
        end
        if 0 ~= toMyNumber(v.equip_type) then
            row_data.equip_type                      = toMyNumber(v.equip_type)
        end
        if "" ~= v.animation_name then
            row_data.animation_name                  = v.animation_name
        end
        if 0 ~= toMyNumber(v.avatar) then
            row_data.avatar                          = toMyNumber(v.avatar)
        end
        if 0 ~= toMyNumber(v.occupation) then
            row_data.occupation                      = toMyNumber(v.occupation)
        end
        if 0 ~= toMyNumber(v.formation) then
            row_data.formation                       = toMyNumber(v.formation)
        end
        if 0 ~= toMyNumber(v.race) then
            row_data.race                            = toMyNumber(v.race)
        end
        if 0 ~= toMyNumber(v.source) then
            row_data.source                          = toMyNumber(v.source)
        end
        local temp_data = {}
        if nil ~= v.star_cost then
            local x,y,z = string.match(v.star_cost,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.star_cost                     = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.exist_give then
            local x,y,z = string.match(v.exist_give,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.exist_give                    = temp_data
            end
        end
        row_data.get_attr = {}
        for i = 1,6 do
            local temp_str = "get_attr" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.get_attr, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.get_score) then
            row_data.get_score                       = toMyNumber(v.get_score)
        end
        row_data.skills = {}
        for i = 1,6 do
            local temp_str = "skills" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.skills, temp_data)
            end
        end
        row_data.odds = {}
        for i = 1,4 do
            local temp_str = "odds" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.odds, temp_data)
            end
        end
        row_data.sounds = {}
        for i = 1,3 do
            local temp_str = "sounds" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.sounds, v[temp_str])
            end
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Soldier"] = data
    collectgarbage( 'collect' )
end

function findSoldier(first)
    if nil == json_table_data["xls/Soldier"] then
        SoldierLoadData()
    end
    local temp_tb = json_table_data["xls/Soldier"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.locale_id then
        data.locale_id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.star then
        data.star = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.gender then
        data.gender = 0
    end
    if nil == data.equip_type then
        data.equip_type = 0
    end
    if nil == data.animation_name then
        data.animation_name = ""
    end
    if nil == data.avatar then
        data.avatar = 0
    end
    if nil == data.occupation then
        data.occupation = 0
    end
    if nil == data.formation then
        data.formation = 0
    end
    if nil == data.race then
        data.race = 0
    end
    if nil == data.source then
        data.source = 0
    end
    if nil == data.star_cost then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.star_cost = temp_data
    end
    if nil == data.exist_give then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.exist_give = temp_data
    end
    if nil == data.get_score then
        data.get_score = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function SoldierBaseLoadData()
    if nil ~= json_table_data["xls/SoldierBase.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierBase.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.hp) then
            row_data.hp                              = toMyNumber(v.hp)
        end
        if 0 ~= toMyNumber(v.physical_ack) then
            row_data.physical_ack                    = toMyNumber(v.physical_ack)
        end
        if 0 ~= toMyNumber(v.physical_def) then
            row_data.physical_def                    = toMyNumber(v.physical_def)
        end
        if 0 ~= toMyNumber(v.magic_ack) then
            row_data.magic_ack                       = toMyNumber(v.magic_ack)
        end
        if 0 ~= toMyNumber(v.magic_def) then
            row_data.magic_def                       = toMyNumber(v.magic_def)
        end
        if 0 ~= toMyNumber(v.speed) then
            row_data.speed                           = toMyNumber(v.speed)
        end
        if 0 ~= toMyNumber(v.critper) then
            row_data.critper                         = toMyNumber(v.critper)
        end
        if 0 ~= toMyNumber(v.crithurt) then
            row_data.crithurt                        = toMyNumber(v.crithurt)
        end
        if 0 ~= toMyNumber(v.critper_def) then
            row_data.critper_def                     = toMyNumber(v.critper_def)
        end
        if 0 ~= toMyNumber(v.crithurt_def) then
            row_data.crithurt_def                    = toMyNumber(v.crithurt_def)
        end
        if 0 ~= toMyNumber(v.hitper) then
            row_data.hitper                          = toMyNumber(v.hitper)
        end
        if 0 ~= toMyNumber(v.dodgeper) then
            row_data.dodgeper                        = toMyNumber(v.dodgeper)
        end
        if 0 ~= toMyNumber(v.parryper) then
            row_data.parryper                        = toMyNumber(v.parryper)
        end
        if 0 ~= toMyNumber(v.parryper_dec) then
            row_data.parryper_dec                    = toMyNumber(v.parryper_dec)
        end
        if 0 ~= toMyNumber(v.recover_critper) then
            row_data.recover_critper                 = toMyNumber(v.recover_critper)
        end
        if 0 ~= toMyNumber(v.recover_critper_def) then
            row_data.recover_critper_def             = toMyNumber(v.recover_critper_def)
        end
        if 0 ~= toMyNumber(v.recover_add_fix) then
            row_data.recover_add_fix                 = toMyNumber(v.recover_add_fix)
        end
        if 0 ~= toMyNumber(v.recover_del_fix) then
            row_data.recover_del_fix                 = toMyNumber(v.recover_del_fix)
        end
        if 0 ~= toMyNumber(v.recover_add_per) then
            row_data.recover_add_per                 = toMyNumber(v.recover_add_per)
        end
        if 0 ~= toMyNumber(v.recover_del_per) then
            row_data.recover_del_per                 = toMyNumber(v.recover_del_per)
        end
        if 0 ~= toMyNumber(v.rage_add_fix) then
            row_data.rage_add_fix                    = toMyNumber(v.rage_add_fix)
        end
        if 0 ~= toMyNumber(v.rage_del_fix) then
            row_data.rage_del_fix                    = toMyNumber(v.rage_del_fix)
        end
        if 0 ~= toMyNumber(v.rage_add_per) then
            row_data.rage_add_per                    = toMyNumber(v.rage_add_per)
        end
        if 0 ~= toMyNumber(v.rage_del_per) then
            row_data.rage_del_per                    = toMyNumber(v.rage_del_per)
        end
        if 0 ~= toMyNumber(v.initial_rage) then
            row_data.initial_rage                    = toMyNumber(v.initial_rage)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SoldierBase"] = data
    collectgarbage( 'collect' )
end

function findSoldierBase(first)
    if nil == json_table_data["xls/SoldierBase"] then
        SoldierBaseLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierBase"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.hp then
        data.hp = 0
    end
    if nil == data.physical_ack then
        data.physical_ack = 0
    end
    if nil == data.physical_def then
        data.physical_def = 0
    end
    if nil == data.magic_ack then
        data.magic_ack = 0
    end
    if nil == data.magic_def then
        data.magic_def = 0
    end
    if nil == data.speed then
        data.speed = 0
    end
    if nil == data.critper then
        data.critper = 0
    end
    if nil == data.crithurt then
        data.crithurt = 0
    end
    if nil == data.critper_def then
        data.critper_def = 0
    end
    if nil == data.crithurt_def then
        data.crithurt_def = 0
    end
    if nil == data.hitper then
        data.hitper = 0
    end
    if nil == data.dodgeper then
        data.dodgeper = 0
    end
    if nil == data.parryper then
        data.parryper = 0
    end
    if nil == data.parryper_dec then
        data.parryper_dec = 0
    end
    if nil == data.recover_critper then
        data.recover_critper = 0
    end
    if nil == data.recover_critper_def then
        data.recover_critper_def = 0
    end
    if nil == data.recover_add_fix then
        data.recover_add_fix = 0
    end
    if nil == data.recover_del_fix then
        data.recover_del_fix = 0
    end
    if nil == data.recover_add_per then
        data.recover_add_per = 0
    end
    if nil == data.recover_del_per then
        data.recover_del_per = 0
    end
    if nil == data.rage_add_fix then
        data.rage_add_fix = 0
    end
    if nil == data.rage_del_fix then
        data.rage_del_fix = 0
    end
    if nil == data.rage_add_per then
        data.rage_add_per = 0
    end
    if nil == data.rage_del_per then
        data.rage_del_per = 0
    end
    if nil == data.initial_rage then
        data.initial_rage = 0
    end
    return temp_tb[first]
end

function SoldierEquipLoadData()
    if nil ~= json_table_data["xls/SoldierEquip.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierEquip.json")) do
        local row_data = {}
        row_data.soldier_id                      = toMyNumber(v.soldier_id)
        row_data.equip_id                        = toMyNumber(v.equip_id)
        row_data.effects = {}
        for i = 1,3 do
            local temp_str = "effects" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.effects, temp_data)
            end
        end
        if nil ~= row_data.soldier_id and nil ~= row_data.equip_id then
            if nil == data[row_data.soldier_id] then 
                data[row_data.soldier_id] = {}
            end
            data[row_data.soldier_id][row_data.equip_id] = row_data
        end
    end
    json_table_data["xls/SoldierEquip"] = data
    collectgarbage( 'collect' )
end

function findSoldierEquip(first, second)
    if nil == json_table_data["xls/SoldierEquip"] then
        SoldierEquipLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierEquip"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.soldier_id then
        data.soldier_id = 0
    end
    if nil == data.equip_id then
        data.equip_id = 0
    end
    return temp_tb[first][second]
end

function SoldierExtLoadData()
    if nil ~= json_table_data["xls/SoldierExt.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierExt.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.soldier_id) then
            row_data.soldier_id                      = toMyNumber(v.soldier_id)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.fighting) then
            row_data.fighting                        = toMyNumber(v.fighting)
        end
        if 0 ~= toMyNumber(v.star) then
            row_data.star                            = toMyNumber(v.star)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        if 0 ~= toMyNumber(v.initial_rage) then
            row_data.initial_rage                    = toMyNumber(v.initial_rage)
        end
        if 0 ~= toMyNumber(v.hp) then
            row_data.hp                              = toMyNumber(v.hp)
        end
        if 0 ~= toMyNumber(v.physical_ack) then
            row_data.physical_ack                    = toMyNumber(v.physical_ack)
        end
        if 0 ~= toMyNumber(v.physical_def) then
            row_data.physical_def                    = toMyNumber(v.physical_def)
        end
        if 0 ~= toMyNumber(v.magic_ack) then
            row_data.magic_ack                       = toMyNumber(v.magic_ack)
        end
        if 0 ~= toMyNumber(v.magic_def) then
            row_data.magic_def                       = toMyNumber(v.magic_def)
        end
        if 0 ~= toMyNumber(v.speed) then
            row_data.speed                           = toMyNumber(v.speed)
        end
        if 0 ~= toMyNumber(v.critper) then
            row_data.critper                         = toMyNumber(v.critper)
        end
        if 0 ~= toMyNumber(v.crithurt) then
            row_data.crithurt                        = toMyNumber(v.crithurt)
        end
        if 0 ~= toMyNumber(v.critper_def) then
            row_data.critper_def                     = toMyNumber(v.critper_def)
        end
        if 0 ~= toMyNumber(v.crithurt_def) then
            row_data.crithurt_def                    = toMyNumber(v.crithurt_def)
        end
        if 0 ~= toMyNumber(v.hitper) then
            row_data.hitper                          = toMyNumber(v.hitper)
        end
        if 0 ~= toMyNumber(v.dodgeper) then
            row_data.dodgeper                        = toMyNumber(v.dodgeper)
        end
        if 0 ~= toMyNumber(v.parryper) then
            row_data.parryper                        = toMyNumber(v.parryper)
        end
        if 0 ~= toMyNumber(v.parryper_dec) then
            row_data.parryper_dec                    = toMyNumber(v.parryper_dec)
        end
        if 0 ~= toMyNumber(v.stun_def) then
            row_data.stun_def                        = toMyNumber(v.stun_def)
        end
        if 0 ~= toMyNumber(v.silent_def) then
            row_data.silent_def                      = toMyNumber(v.silent_def)
        end
        if 0 ~= toMyNumber(v.weak_def) then
            row_data.weak_def                        = toMyNumber(v.weak_def)
        end
        if 0 ~= toMyNumber(v.fire_def) then
            row_data.fire_def                        = toMyNumber(v.fire_def)
        end
        if 0 ~= toMyNumber(v.rebound_physical_ack) then
            row_data.rebound_physical_ack            = toMyNumber(v.rebound_physical_ack)
        end
        if 0 ~= toMyNumber(v.rebound_magic_ack) then
            row_data.rebound_magic_ack               = toMyNumber(v.rebound_magic_ack)
        end
        row_data.odds = {}
        for i = 1,7 do
            local temp_str = "odds" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.odds, temp_data)
            end
        end
        row_data.skills = {}
        for i = 1,6 do
            local temp_str = "skills" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.skills, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.recover_critper) then
            row_data.recover_critper                 = toMyNumber(v.recover_critper)
        end
        if 0 ~= toMyNumber(v.recover_critper_def) then
            row_data.recover_critper_def             = toMyNumber(v.recover_critper_def)
        end
        if 0 ~= toMyNumber(v.recover_add_fix) then
            row_data.recover_add_fix                 = toMyNumber(v.recover_add_fix)
        end
        if 0 ~= toMyNumber(v.recover_del_fix) then
            row_data.recover_del_fix                 = toMyNumber(v.recover_del_fix)
        end
        if 0 ~= toMyNumber(v.recover_add_per) then
            row_data.recover_add_per                 = toMyNumber(v.recover_add_per)
        end
        if 0 ~= toMyNumber(v.recover_del_per) then
            row_data.recover_del_per                 = toMyNumber(v.recover_del_per)
        end
        if 0 ~= toMyNumber(v.rage_add_fix) then
            row_data.rage_add_fix                    = toMyNumber(v.rage_add_fix)
        end
        if 0 ~= toMyNumber(v.rage_del_fix) then
            row_data.rage_del_fix                    = toMyNumber(v.rage_del_fix)
        end
        if 0 ~= toMyNumber(v.rage_add_per) then
            row_data.rage_add_per                    = toMyNumber(v.rage_add_per)
        end
        if 0 ~= toMyNumber(v.rage_del_per) then
            row_data.rage_del_per                    = toMyNumber(v.rage_del_per)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SoldierExt"] = data
    collectgarbage( 'collect' )
end

function findSoldierExt(first)
    if nil == json_table_data["xls/SoldierExt"] then
        SoldierExtLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierExt"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.soldier_id then
        data.soldier_id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.fighting then
        data.fighting = 0
    end
    if nil == data.star then
        data.star = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.initial_rage then
        data.initial_rage = 0
    end
    if nil == data.hp then
        data.hp = 0
    end
    if nil == data.physical_ack then
        data.physical_ack = 0
    end
    if nil == data.physical_def then
        data.physical_def = 0
    end
    if nil == data.magic_ack then
        data.magic_ack = 0
    end
    if nil == data.magic_def then
        data.magic_def = 0
    end
    if nil == data.speed then
        data.speed = 0
    end
    if nil == data.critper then
        data.critper = 0
    end
    if nil == data.crithurt then
        data.crithurt = 0
    end
    if nil == data.critper_def then
        data.critper_def = 0
    end
    if nil == data.crithurt_def then
        data.crithurt_def = 0
    end
    if nil == data.hitper then
        data.hitper = 0
    end
    if nil == data.dodgeper then
        data.dodgeper = 0
    end
    if nil == data.parryper then
        data.parryper = 0
    end
    if nil == data.parryper_dec then
        data.parryper_dec = 0
    end
    if nil == data.stun_def then
        data.stun_def = 0
    end
    if nil == data.silent_def then
        data.silent_def = 0
    end
    if nil == data.weak_def then
        data.weak_def = 0
    end
    if nil == data.fire_def then
        data.fire_def = 0
    end
    if nil == data.rebound_physical_ack then
        data.rebound_physical_ack = 0
    end
    if nil == data.rebound_magic_ack then
        data.rebound_magic_ack = 0
    end
    if nil == data.recover_critper then
        data.recover_critper = 0
    end
    if nil == data.recover_critper_def then
        data.recover_critper_def = 0
    end
    if nil == data.recover_add_fix then
        data.recover_add_fix = 0
    end
    if nil == data.recover_del_fix then
        data.recover_del_fix = 0
    end
    if nil == data.recover_add_per then
        data.recover_add_per = 0
    end
    if nil == data.recover_del_per then
        data.recover_del_per = 0
    end
    if nil == data.rage_add_fix then
        data.rage_add_fix = 0
    end
    if nil == data.rage_del_fix then
        data.rage_del_fix = 0
    end
    if nil == data.rage_add_per then
        data.rage_add_per = 0
    end
    if nil == data.rage_del_per then
        data.rage_del_per = 0
    end
    return temp_tb[first]
end

function SoldierLvLoadData()
    if nil ~= json_table_data["xls/SoldierLv.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierLv.json")) do
        local row_data = {}
        row_data.lv                              = toMyNumber(v.lv)
        local temp_data = {}
        if nil ~= v.cost then
            local x,y,z = string.match(v.cost,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.cost                          = temp_data
            end
        end
        if 0 ~= toMyNumber(v.hp) then
            row_data.hp                              = toMyNumber(v.hp)
        end
        if 0 ~= toMyNumber(v.physical_ack) then
            row_data.physical_ack                    = toMyNumber(v.physical_ack)
        end
        if 0 ~= toMyNumber(v.physical_def) then
            row_data.physical_def                    = toMyNumber(v.physical_def)
        end
        if 0 ~= toMyNumber(v.magic_ack) then
            row_data.magic_ack                       = toMyNumber(v.magic_ack)
        end
        if 0 ~= toMyNumber(v.magic_def) then
            row_data.magic_def                       = toMyNumber(v.magic_def)
        end
        if 0 ~= toMyNumber(v.speed) then
            row_data.speed                           = toMyNumber(v.speed)
        end
        if 0 ~= toMyNumber(v.critper) then
            row_data.critper                         = toMyNumber(v.critper)
        end
        if 0 ~= toMyNumber(v.crithurt) then
            row_data.crithurt                        = toMyNumber(v.crithurt)
        end
        if 0 ~= toMyNumber(v.critper_def) then
            row_data.critper_def                     = toMyNumber(v.critper_def)
        end
        if 0 ~= toMyNumber(v.crithurt_def) then
            row_data.crithurt_def                    = toMyNumber(v.crithurt_def)
        end
        if 0 ~= toMyNumber(v.hitper) then
            row_data.hitper                          = toMyNumber(v.hitper)
        end
        if 0 ~= toMyNumber(v.dodgeper) then
            row_data.dodgeper                        = toMyNumber(v.dodgeper)
        end
        if 0 ~= toMyNumber(v.parryper) then
            row_data.parryper                        = toMyNumber(v.parryper)
        end
        if 0 ~= toMyNumber(v.parryper_dec) then
            row_data.parryper_dec                    = toMyNumber(v.parryper_dec)
        end
        if 0 ~= toMyNumber(v.recover_critper) then
            row_data.recover_critper                 = toMyNumber(v.recover_critper)
        end
        if 0 ~= toMyNumber(v.recover_critper_def) then
            row_data.recover_critper_def             = toMyNumber(v.recover_critper_def)
        end
        if 0 ~= toMyNumber(v.recover_add_fix) then
            row_data.recover_add_fix                 = toMyNumber(v.recover_add_fix)
        end
        if 0 ~= toMyNumber(v.recover_del_fix) then
            row_data.recover_del_fix                 = toMyNumber(v.recover_del_fix)
        end
        if 0 ~= toMyNumber(v.recover_add_per) then
            row_data.recover_add_per                 = toMyNumber(v.recover_add_per)
        end
        if 0 ~= toMyNumber(v.recover_del_per) then
            row_data.recover_del_per                 = toMyNumber(v.recover_del_per)
        end
        if 0 ~= toMyNumber(v.rage_add_fix) then
            row_data.rage_add_fix                    = toMyNumber(v.rage_add_fix)
        end
        if 0 ~= toMyNumber(v.rage_del_fix) then
            row_data.rage_del_fix                    = toMyNumber(v.rage_del_fix)
        end
        if 0 ~= toMyNumber(v.rage_add_per) then
            row_data.rage_add_per                    = toMyNumber(v.rage_add_per)
        end
        if 0 ~= toMyNumber(v.rage_del_per) then
            row_data.rage_del_per                    = toMyNumber(v.rage_del_per)
        end
        if nil ~= row_data.lv then
            data[row_data.lv] = row_data
        end
    end
    json_table_data["xls/SoldierLv"] = data
    collectgarbage( 'collect' )
end

function findSoldierLv(first)
    if nil == json_table_data["xls/SoldierLv"] then
        SoldierLvLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierLv"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.lv then
        data.lv = 0
    end
    if nil == data.cost then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.cost = temp_data
    end
    if nil == data.hp then
        data.hp = 0
    end
    if nil == data.physical_ack then
        data.physical_ack = 0
    end
    if nil == data.physical_def then
        data.physical_def = 0
    end
    if nil == data.magic_ack then
        data.magic_ack = 0
    end
    if nil == data.magic_def then
        data.magic_def = 0
    end
    if nil == data.speed then
        data.speed = 0
    end
    if nil == data.critper then
        data.critper = 0
    end
    if nil == data.crithurt then
        data.crithurt = 0
    end
    if nil == data.critper_def then
        data.critper_def = 0
    end
    if nil == data.crithurt_def then
        data.crithurt_def = 0
    end
    if nil == data.hitper then
        data.hitper = 0
    end
    if nil == data.dodgeper then
        data.dodgeper = 0
    end
    if nil == data.parryper then
        data.parryper = 0
    end
    if nil == data.parryper_dec then
        data.parryper_dec = 0
    end
    if nil == data.recover_critper then
        data.recover_critper = 0
    end
    if nil == data.recover_critper_def then
        data.recover_critper_def = 0
    end
    if nil == data.recover_add_fix then
        data.recover_add_fix = 0
    end
    if nil == data.recover_del_fix then
        data.recover_del_fix = 0
    end
    if nil == data.recover_add_per then
        data.recover_add_per = 0
    end
    if nil == data.recover_del_per then
        data.recover_del_per = 0
    end
    if nil == data.rage_add_fix then
        data.rage_add_fix = 0
    end
    if nil == data.rage_del_fix then
        data.rage_del_fix = 0
    end
    if nil == data.rage_add_per then
        data.rage_add_per = 0
    end
    if nil == data.rage_del_per then
        data.rage_del_per = 0
    end
    return temp_tb[first]
end

function SoldierQualityLoadData()
    if nil ~= json_table_data["xls/SoldierQuality.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierQuality.json")) do
        local row_data = {}
        row_data.lv                              = toMyNumber(v.lv)
        local temp_data = {}
        if nil ~= v.quality_effect then
            local x,y = string.match(v.quality_effect,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.quality_effect                = temp_data
            end
        end
        if 0 ~= toMyNumber(v.xp) then
            row_data.xp                              = toMyNumber(v.xp)
        end
        if 0 ~= toMyNumber(v.skill_active) then
            row_data.skill_active                    = toMyNumber(v.skill_active)
        end
        if 0 ~= toMyNumber(v.disillusion_skill_level) then
            row_data.disillusion_skill_level            = toMyNumber(v.disillusion_skill_level)
        end
        if 0 ~= toMyNumber(v.lv_limit) then
            row_data.lv_limit                        = toMyNumber(v.lv_limit)
        end
        if 0 ~= toMyNumber(v.skill_point) then
            row_data.skill_point                     = toMyNumber(v.skill_point)
        end
        row_data.costs = {}
        for i = 1,6 do
            local temp_str = "costs" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.costs, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.hp) then
            row_data.hp                              = toMyNumber(v.hp)
        end
        if 0 ~= toMyNumber(v.physical_ack) then
            row_data.physical_ack                    = toMyNumber(v.physical_ack)
        end
        if 0 ~= toMyNumber(v.physical_def) then
            row_data.physical_def                    = toMyNumber(v.physical_def)
        end
        if 0 ~= toMyNumber(v.magic_ack) then
            row_data.magic_ack                       = toMyNumber(v.magic_ack)
        end
        if 0 ~= toMyNumber(v.magic_def) then
            row_data.magic_def                       = toMyNumber(v.magic_def)
        end
        if 0 ~= toMyNumber(v.speed) then
            row_data.speed                           = toMyNumber(v.speed)
        end
        if nil ~= row_data.lv then
            data[row_data.lv] = row_data
        end
    end
    json_table_data["xls/SoldierQuality"] = data
    collectgarbage( 'collect' )
end

function findSoldierQuality(first)
    if nil == json_table_data["xls/SoldierQuality"] then
        SoldierQualityLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierQuality"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.lv then
        data.lv = 0
    end
    if nil == data.quality_effect then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.quality_effect = temp_data
    end
    if nil == data.xp then
        data.xp = 0
    end
    if nil == data.skill_active then
        data.skill_active = 0
    end
    if nil == data.disillusion_skill_level then
        data.disillusion_skill_level = 0
    end
    if nil == data.lv_limit then
        data.lv_limit = 0
    end
    if nil == data.skill_point then
        data.skill_point = 0
    end
    if nil == data.hp then
        data.hp = 0
    end
    if nil == data.physical_ack then
        data.physical_ack = 0
    end
    if nil == data.physical_def then
        data.physical_def = 0
    end
    if nil == data.magic_ack then
        data.magic_ack = 0
    end
    if nil == data.magic_def then
        data.magic_def = 0
    end
    if nil == data.speed then
        data.speed = 0
    end
    return temp_tb[first]
end

function SoldierQualityOccuLoadData()
    if nil ~= json_table_data["xls/SoldierQualityOccu.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierQualityOccu.json")) do
        local row_data = {}
        row_data.quality_id                      = toMyNumber(v.quality_id)
        row_data.occu_id                         = toMyNumber(v.occu_id)
        local temp_data = {}
        if nil ~= v.cost then
            local x,y,z = string.match(v.cost,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.cost                          = temp_data
            end
        end
        if 0 ~= toMyNumber(v.limit_lv) then
            row_data.limit_lv                        = toMyNumber(v.limit_lv)
        end
        if nil ~= row_data.quality_id and nil ~= row_data.occu_id then
            if nil == data[row_data.quality_id] then 
                data[row_data.quality_id] = {}
            end
            data[row_data.quality_id][row_data.occu_id] = row_data
        end
    end
    json_table_data["xls/SoldierQualityOccu"] = data
    collectgarbage( 'collect' )
end

function findSoldierQualityOccu(first, second)
    if nil == json_table_data["xls/SoldierQualityOccu"] then
        SoldierQualityOccuLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierQualityOccu"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.quality_id then
        data.quality_id = 0
    end
    if nil == data.occu_id then
        data.occu_id = 0
    end
    if nil == data.cost then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.cost = temp_data
    end
    if nil == data.limit_lv then
        data.limit_lv = 0
    end
    return temp_tb[first][second]
end

function SoldierQualityXpLoadData()
    if nil ~= json_table_data["xls/SoldierQualityXp.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierQualityXp.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        local temp_data = {}
        if nil ~= v.coin then
            local x,y,z = string.match(v.coin,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.coin                          = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.quality_lv then
            local x,y = string.match(v.quality_lv,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.quality_lv                    = temp_data
            end
        end
        if 0 ~= toMyNumber(v.quality_xp) then
            row_data.quality_xp                      = toMyNumber(v.quality_xp)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SoldierQualityXp"] = data
    collectgarbage( 'collect' )
end

function findSoldierQualityXp(first)
    if nil == json_table_data["xls/SoldierQualityXp"] then
        SoldierQualityXpLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierQualityXp"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.coin then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.coin = temp_data
    end
    if nil == data.quality_lv then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.quality_lv = temp_data
    end
    if nil == data.quality_xp then
        data.quality_xp = 0
    end
    return temp_tb[first]
end

function SoldierRecruitLoadData()
    if nil ~= json_table_data["xls/SoldierRecruit.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierRecruit.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.soldier_id) then
            row_data.soldier_id                      = toMyNumber(v.soldier_id)
        end
        row_data.cost_ = {}
        for i = 1,2 do
            local temp_str = "cost_" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.cost_, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/SoldierRecruit"] = data
    collectgarbage( 'collect' )
end

function findSoldierRecruit(first)
    if nil == json_table_data["xls/SoldierRecruit"] then
        SoldierRecruitLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierRecruit"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.soldier_id then
        data.soldier_id = 0
    end
    return temp_tb[first]
end

function SoldierStarLoadData()
    if nil ~= json_table_data["xls/SoldierStar.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/SoldierStar.json")) do
        local row_data = {}
        row_data.lv                              = toMyNumber(v.lv)
        if 0 ~= toMyNumber(v.cost) then
            row_data.cost                            = toMyNumber(v.cost)
        end
        local temp_data = {}
        if nil ~= v.need_money then
            local x,y,z = string.match(v.need_money,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.need_money                    = temp_data
            end
        end
        if 0 ~= toMyNumber(v.grow) then
            row_data.grow                            = toMyNumber(v.grow)
        end
        if nil ~= row_data.lv then
            data[row_data.lv] = row_data
        end
    end
    json_table_data["xls/SoldierStar"] = data
    collectgarbage( 'collect' )
end

function findSoldierStar(first)
    if nil == json_table_data["xls/SoldierStar"] then
        SoldierStarLoadData()
    end
    local temp_tb = json_table_data["xls/SoldierStar"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.lv then
        data.lv = 0
    end
    if nil == data.cost then
        data.cost = 0
    end
    if nil == data.need_money then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.need_money = temp_data
    end
    if nil == data.grow then
        data.grow = 0
    end
    return temp_tb[first]
end

function TaskLoadData()
    if nil ~= json_table_data["xls/Task.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Task.json")) do
        local row_data = {}
        row_data.task_id                         = toMyNumber(v.task_id)
        if 0 ~= toMyNumber(v.front_id) then
            row_data.front_id                        = toMyNumber(v.front_id)
        end
        if 0 ~= toMyNumber(v.copy_id) then
            row_data.copy_id                         = toMyNumber(v.copy_id)
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.team_level_min) then
            row_data.team_level_min                  = toMyNumber(v.team_level_min)
        end
        if 0 ~= toMyNumber(v.team_level_max) then
            row_data.team_level_max                  = toMyNumber(v.team_level_max)
        end
        local temp_data = {}
        if nil ~= v.cond then
            local x,y,z = string.match(v.cond,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.cond                          = temp_data
            end
        end
        if 0 ~= toMyNumber(v.begin_gut) then
            row_data.begin_gut                       = toMyNumber(v.begin_gut)
        end
        if 0 ~= toMyNumber(v.end_gut) then
            row_data.end_gut                         = toMyNumber(v.end_gut)
        end
        row_data.coins = {}
        for i = 1,4 do
            local temp_str = "coins" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.coins, temp_data)
            end
        end
        if "" ~= v.activity then
            row_data.activity                        = v.activity
        end
        if 0 ~= toMyNumber(v.auto_submit) then
            row_data.auto_submit                     = toMyNumber(v.auto_submit)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if "" ~= v.icon then
            row_data.icon                            = v.icon
        end
        if nil ~= row_data.task_id then
            data[row_data.task_id] = row_data
        end
    end
    json_table_data["xls/Task"] = data
    collectgarbage( 'collect' )
end

function findTask(first)
    if nil == json_table_data["xls/Task"] then
        TaskLoadData()
    end
    local temp_tb = json_table_data["xls/Task"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.task_id then
        data.task_id = 0
    end
    if nil == data.front_id then
        data.front_id = 0
    end
    if nil == data.copy_id then
        data.copy_id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.team_level_min then
        data.team_level_min = 0
    end
    if nil == data.team_level_max then
        data.team_level_max = 0
    end
    if nil == data.cond then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.cond = temp_data
    end
    if nil == data.begin_gut then
        data.begin_gut = 0
    end
    if nil == data.end_gut then
        data.end_gut = 0
    end
    if nil == data.activity then
        data.activity = ""
    end
    if nil == data.auto_submit then
        data.auto_submit = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    if nil == data.icon then
        data.icon = ""
    end
    return temp_tb[first]
end

function TempleGlyphLoadData()
    if nil ~= json_table_data["xls/TempleGlyph.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TempleGlyph.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        if 0 ~= toMyNumber(v.init_lv) then
            row_data.init_lv                         = toMyNumber(v.init_lv)
        end
        if 0 ~= toMyNumber(v.exp) then
            row_data.exp                             = toMyNumber(v.exp)
        end
        if "" ~= v.icon then
            row_data.icon                            = v.icon
        end
        if "" ~= v.icon2 then
            row_data.icon2                           = v.icon2
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TempleGlyph"] = data
    collectgarbage( 'collect' )
end

function findTempleGlyph(first)
    if nil == json_table_data["xls/TempleGlyph"] then
        TempleGlyphLoadData()
    end
    local temp_tb = json_table_data["xls/TempleGlyph"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.init_lv then
        data.init_lv = 0
    end
    if nil == data.exp then
        data.exp = 0
    end
    if nil == data.icon then
        data.icon = ""
    end
    if nil == data.icon2 then
        data.icon2 = ""
    end
    return temp_tb[first]
end

function TempleGlyphAttrLoadData()
    if nil ~= json_table_data["xls/TempleGlyphAttr.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TempleGlyphAttr.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.level                           = toMyNumber(v.level)
        if 0 ~= toMyNumber(v.exp) then
            row_data.exp                             = toMyNumber(v.exp)
        end
        row_data.attrs = {}
        for i = 1,6 do
            local temp_str = "attrs" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.attrs, temp_data)
            end
        end
        if nil ~= row_data.id and nil ~= row_data.level then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.level] = row_data
        end
    end
    json_table_data["xls/TempleGlyphAttr"] = data
    collectgarbage( 'collect' )
end

function findTempleGlyphAttr(first, second)
    if nil == json_table_data["xls/TempleGlyphAttr"] then
        TempleGlyphAttrLoadData()
    end
    local temp_tb = json_table_data["xls/TempleGlyphAttr"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.exp then
        data.exp = 0
    end
    return temp_tb[first][second]
end

function TempleGroupLoadData()
    if nil ~= json_table_data["xls/TempleGroup.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TempleGroup.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.init_lv) then
            row_data.init_lv                         = toMyNumber(v.init_lv)
        end
        if 0 ~= toMyNumber(v.get_score) then
            row_data.get_score                       = toMyNumber(v.get_score)
        end
        row_data.members = {}
        for i = 1,6 do
            local temp_str = "members" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.members, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TempleGroup"] = data
    collectgarbage( 'collect' )
end

function findTempleGroup(first)
    if nil == json_table_data["xls/TempleGroup"] then
        TempleGroupLoadData()
    end
    local temp_tb = json_table_data["xls/TempleGroup"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.init_lv then
        data.init_lv = 0
    end
    if nil == data.get_score then
        data.get_score = 0
    end
    return temp_tb[first]
end

function TempleGroupLevelUpLoadData()
    if nil ~= json_table_data["xls/TempleGroupLevelUp.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TempleGroupLevelUp.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.level                           = toMyNumber(v.level)
        if 0 ~= toMyNumber(v.star) then
            row_data.star                            = toMyNumber(v.star)
        end
        if 0 ~= toMyNumber(v.score) then
            row_data.score                           = toMyNumber(v.score)
        end
        row_data.attrs = {}
        for i = 1,6 do
            local temp_str = "attrs" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.attrs, temp_data)
            end
        end
        if nil ~= row_data.id and nil ~= row_data.level then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.level] = row_data
        end
    end
    json_table_data["xls/TempleGroupLevelUp"] = data
    collectgarbage( 'collect' )
end

function findTempleGroupLevelUp(first, second)
    if nil == json_table_data["xls/TempleGroupLevelUp"] then
        TempleGroupLevelUpLoadData()
    end
    local temp_tb = json_table_data["xls/TempleGroupLevelUp"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.star then
        data.star = 0
    end
    if nil == data.score then
        data.score = 0
    end
    return temp_tb[first][second]
end

function TempleHoleLoadData()
    if nil ~= json_table_data["xls/TempleHole.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TempleHole.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        row_data.cost_item = {}
        for i = 1,3 do
            local temp_str = "cost_item" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.cost_item, temp_data)
            end
        end
        row_data.cost_coin = {}
        for i = 1,3 do
            local temp_str = "cost_coin" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.cost_coin, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TempleHole"] = data
    collectgarbage( 'collect' )
end

function findTempleHole(first)
    if nil == json_table_data["xls/TempleHole"] then
        TempleHoleLoadData()
    end
    local temp_tb = json_table_data["xls/TempleHole"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    return temp_tb[first]
end

function TempleScoreRewardLoadData()
    if nil ~= json_table_data["xls/TempleScoreReward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TempleScoreReward.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.score) then
            row_data.score                           = toMyNumber(v.score)
        end
        row_data.reward = {}
        for i = 1,6 do
            local temp_str = "reward" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.reward, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TempleScoreReward"] = data
    collectgarbage( 'collect' )
end

function findTempleScoreReward(first)
    if nil == json_table_data["xls/TempleScoreReward"] then
        TempleScoreRewardLoadData()
    end
    local temp_tb = json_table_data["xls/TempleScoreReward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.score then
        data.score = 0
    end
    return temp_tb[first]
end

function TempleSuitAttrLoadData()
    if nil ~= json_table_data["xls/TempleSuitAttr.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TempleSuitAttr.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.cond_exp) then
            row_data.cond_exp                        = toMyNumber(v.cond_exp)
        end
        if 0 ~= toMyNumber(v.cond_quality) then
            row_data.cond_quality                    = toMyNumber(v.cond_quality)
        end
        if 0 ~= toMyNumber(v.cond_count) then
            row_data.cond_count                      = toMyNumber(v.cond_count)
        end
        row_data.odds = {}
        for i = 1,6 do
            local temp_str = "odds" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.odds, temp_data)
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TempleSuitAttr"] = data
    collectgarbage( 'collect' )
end

function findTempleSuitAttr(first)
    if nil == json_table_data["xls/TempleSuitAttr"] then
        TempleSuitAttrLoadData()
    end
    local temp_tb = json_table_data["xls/TempleSuitAttr"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.cond_exp then
        data.cond_exp = 0
    end
    if nil == data.cond_quality then
        data.cond_quality = 0
    end
    if nil == data.cond_count then
        data.cond_count = 0
    end
    return temp_tb[first]
end

function TombLoadData()
    if nil ~= json_table_data["xls/Tomb.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Tomb.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.monster_id) then
            row_data.monster_id                      = toMyNumber(v.monster_id)
        end
        if 0 ~= toMyNumber(v.ratio) then
            row_data.ratio                           = toMyNumber(v.ratio)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Tomb"] = data
    collectgarbage( 'collect' )
end

function findTomb(first)
    if nil == json_table_data["xls/Tomb"] then
        TombLoadData()
    end
    local temp_tb = json_table_data["xls/Tomb"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.monster_id then
        data.monster_id = 0
    end
    if nil == data.ratio then
        data.ratio = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function TombMonsterLvLoadData()
    if nil ~= json_table_data["xls/TombMonsterLv.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TombMonsterLv.json")) do
        local row_data = {}
        row_data.lv                              = toMyNumber(v.lv)
        if 0 ~= toMyNumber(v.hp) then
            row_data.hp                              = toMyNumber(v.hp)
        end
        if 0 ~= toMyNumber(v.physical_ack) then
            row_data.physical_ack                    = toMyNumber(v.physical_ack)
        end
        if 0 ~= toMyNumber(v.physical_def) then
            row_data.physical_def                    = toMyNumber(v.physical_def)
        end
        if 0 ~= toMyNumber(v.magic_ack) then
            row_data.magic_ack                       = toMyNumber(v.magic_ack)
        end
        if 0 ~= toMyNumber(v.magic_def) then
            row_data.magic_def                       = toMyNumber(v.magic_def)
        end
        if 0 ~= toMyNumber(v.speed) then
            row_data.speed                           = toMyNumber(v.speed)
        end
        if 0 ~= toMyNumber(v.critper) then
            row_data.critper                         = toMyNumber(v.critper)
        end
        if 0 ~= toMyNumber(v.crithurt) then
            row_data.crithurt                        = toMyNumber(v.crithurt)
        end
        if 0 ~= toMyNumber(v.critper_def) then
            row_data.critper_def                     = toMyNumber(v.critper_def)
        end
        if 0 ~= toMyNumber(v.crithurt_def) then
            row_data.crithurt_def                    = toMyNumber(v.crithurt_def)
        end
        if 0 ~= toMyNumber(v.hitper) then
            row_data.hitper                          = toMyNumber(v.hitper)
        end
        if 0 ~= toMyNumber(v.dodgeper) then
            row_data.dodgeper                        = toMyNumber(v.dodgeper)
        end
        if 0 ~= toMyNumber(v.parryper) then
            row_data.parryper                        = toMyNumber(v.parryper)
        end
        if 0 ~= toMyNumber(v.parryper_dec) then
            row_data.parryper_dec                    = toMyNumber(v.parryper_dec)
        end
        if 0 ~= toMyNumber(v.recover_critper) then
            row_data.recover_critper                 = toMyNumber(v.recover_critper)
        end
        if 0 ~= toMyNumber(v.recover_critper_def) then
            row_data.recover_critper_def             = toMyNumber(v.recover_critper_def)
        end
        if 0 ~= toMyNumber(v.recover_add_fix) then
            row_data.recover_add_fix                 = toMyNumber(v.recover_add_fix)
        end
        if 0 ~= toMyNumber(v.recover_del_fix) then
            row_data.recover_del_fix                 = toMyNumber(v.recover_del_fix)
        end
        if 0 ~= toMyNumber(v.recover_add_per) then
            row_data.recover_add_per                 = toMyNumber(v.recover_add_per)
        end
        if 0 ~= toMyNumber(v.recover_del_per) then
            row_data.recover_del_per                 = toMyNumber(v.recover_del_per)
        end
        if 0 ~= toMyNumber(v.rage_add_fix) then
            row_data.rage_add_fix                    = toMyNumber(v.rage_add_fix)
        end
        if 0 ~= toMyNumber(v.rage_del_fix) then
            row_data.rage_del_fix                    = toMyNumber(v.rage_del_fix)
        end
        if 0 ~= toMyNumber(v.rage_add_per) then
            row_data.rage_add_per                    = toMyNumber(v.rage_add_per)
        end
        if 0 ~= toMyNumber(v.rage_del_per) then
            row_data.rage_del_per                    = toMyNumber(v.rage_del_per)
        end
        if nil ~= row_data.lv then
            data[row_data.lv] = row_data
        end
    end
    json_table_data["xls/TombMonsterLv"] = data
    collectgarbage( 'collect' )
end

function findTombMonsterLv(first)
    if nil == json_table_data["xls/TombMonsterLv"] then
        TombMonsterLvLoadData()
    end
    local temp_tb = json_table_data["xls/TombMonsterLv"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.lv then
        data.lv = 0
    end
    if nil == data.hp then
        data.hp = 0
    end
    if nil == data.physical_ack then
        data.physical_ack = 0
    end
    if nil == data.physical_def then
        data.physical_def = 0
    end
    if nil == data.magic_ack then
        data.magic_ack = 0
    end
    if nil == data.magic_def then
        data.magic_def = 0
    end
    if nil == data.speed then
        data.speed = 0
    end
    if nil == data.critper then
        data.critper = 0
    end
    if nil == data.crithurt then
        data.crithurt = 0
    end
    if nil == data.critper_def then
        data.critper_def = 0
    end
    if nil == data.crithurt_def then
        data.crithurt_def = 0
    end
    if nil == data.hitper then
        data.hitper = 0
    end
    if nil == data.dodgeper then
        data.dodgeper = 0
    end
    if nil == data.parryper then
        data.parryper = 0
    end
    if nil == data.parryper_dec then
        data.parryper_dec = 0
    end
    if nil == data.recover_critper then
        data.recover_critper = 0
    end
    if nil == data.recover_critper_def then
        data.recover_critper_def = 0
    end
    if nil == data.recover_add_fix then
        data.recover_add_fix = 0
    end
    if nil == data.recover_del_fix then
        data.recover_del_fix = 0
    end
    if nil == data.recover_add_per then
        data.recover_add_per = 0
    end
    if nil == data.recover_del_per then
        data.recover_del_per = 0
    end
    if nil == data.rage_add_fix then
        data.rage_add_fix = 0
    end
    if nil == data.rage_del_fix then
        data.rage_del_fix = 0
    end
    if nil == data.rage_add_per then
        data.rage_add_per = 0
    end
    if nil == data.rage_del_per then
        data.rage_del_per = 0
    end
    return temp_tb[first]
end

function TombRewardLoadData()
    if nil ~= json_table_data["xls/TombReward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TombReward.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        if 0 ~= toMyNumber(v.reward) then
            row_data.reward                          = toMyNumber(v.reward)
        end
        local temp_data = {}
        if nil ~= v.level_rand then
            local x,y = string.match(v.level_rand,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.level_rand                    = temp_data
            end
        end
        if 0 ~= toMyNumber(v.percent) then
            row_data.percent                         = toMyNumber(v.percent)
        end
        if 0 ~= toMyNumber(v.extra_reward) then
            row_data.extra_reward                    = toMyNumber(v.extra_reward)
        end
        if 0 ~= toMyNumber(v.extra_percent) then
            row_data.extra_percent                   = toMyNumber(v.extra_percent)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TombReward"] = data
    collectgarbage( 'collect' )
end

function findTombReward(first)
    if nil == json_table_data["xls/TombReward"] then
        TombRewardLoadData()
    end
    local temp_tb = json_table_data["xls/TombReward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.reward then
        data.reward = 0
    end
    if nil == data.level_rand then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.level_rand = temp_data
    end
    if nil == data.percent then
        data.percent = 0
    end
    if nil == data.extra_reward then
        data.extra_reward = 0
    end
    if nil == data.extra_percent then
        data.extra_percent = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function TombRewardBaseLoadData()
    if nil ~= json_table_data["xls/TombRewardBase.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TombRewardBase.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.reward) then
            row_data.reward                          = toMyNumber(v.reward)
        end
        if 0 ~= toMyNumber(v.tomb_coin) then
            row_data.tomb_coin                       = toMyNumber(v.tomb_coin)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TombRewardBase"] = data
    collectgarbage( 'collect' )
end

function findTombRewardBase(first)
    if nil == json_table_data["xls/TombRewardBase"] then
        TombRewardBaseLoadData()
    end
    local temp_tb = json_table_data["xls/TombRewardBase"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.reward then
        data.reward = 0
    end
    if nil == data.tomb_coin then
        data.tomb_coin = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function TotemLoadData()
    if nil ~= json_table_data["xls/Totem.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Totem.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if "" ~= v.ready then
            row_data.ready                           = v.ready
        end
        if 0 ~= toMyNumber(v.init_lv) then
            row_data.init_lv                         = toMyNumber(v.init_lv)
        end
        if 0 ~= toMyNumber(v.init_attr_lv) then
            row_data.init_attr_lv                    = toMyNumber(v.init_attr_lv)
        end
        if 0 ~= toMyNumber(v.max_lv) then
            row_data.max_lv                          = toMyNumber(v.max_lv)
        end
        row_data.get_attr = {}
        for i = 1,6 do
            local temp_str = "get_attr" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.get_attr, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.get_score) then
            row_data.get_score                       = toMyNumber(v.get_score)
        end
        row_data.activate_conds = {}
        for i = 1,3 do
            local temp_str = "activate_conds" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.activate_conds, temp_data)
            end
        end
        if "" ~= v.animation_name then
            row_data.animation_name                  = v.animation_name
        end
        if "" ~= v.ready_animation then
            row_data.ready_animation                 = v.ready_animation
        end
        if "" ~= v.passive_act then
            row_data.passive_act                     = v.passive_act
        end
        if 0 ~= toMyNumber(v.avatar) then
            row_data.avatar                          = toMyNumber(v.avatar)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if "" ~= v.path then
            row_data.path                            = v.path
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Totem"] = data
    collectgarbage( 'collect' )
end

function findTotem(first)
    if nil == json_table_data["xls/Totem"] then
        TotemLoadData()
    end
    local temp_tb = json_table_data["xls/Totem"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.ready then
        data.ready = ""
    end
    if nil == data.init_lv then
        data.init_lv = 0
    end
    if nil == data.init_attr_lv then
        data.init_attr_lv = 0
    end
    if nil == data.max_lv then
        data.max_lv = 0
    end
    if nil == data.get_score then
        data.get_score = 0
    end
    if nil == data.animation_name then
        data.animation_name = ""
    end
    if nil == data.ready_animation then
        data.ready_animation = ""
    end
    if nil == data.passive_act then
        data.passive_act = ""
    end
    if nil == data.avatar then
        data.avatar = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    if nil == data.path then
        data.path = ""
    end
    return temp_tb[first]
end

function TotemAttrLoadData()
    if nil ~= json_table_data["xls/TotemAttr.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TotemAttr.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.level                           = toMyNumber(v.level)
        local temp_data = {}
        if nil ~= v.speed then
            local x,y = string.match(v.speed,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.speed                         = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.skill then
            local x,y = string.match(v.skill,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.skill                         = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.wake then
            local x,y = string.match(v.wake,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.wake                          = temp_data
            end
        end
        if "" ~= v.formation_add_position then
            row_data.formation_add_position            = v.formation_add_position
        end
        local temp_data = {}
        if nil ~= v.formation_add_attr then
            local x,y = string.match(v.formation_add_attr,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.formation_add_attr            = temp_data
            end
        end
        if "" ~= v.formation_up_desc then
            row_data.formation_up_desc               = v.formation_up_desc
        end
        if 0 ~= toMyNumber(v.energy_time) then
            row_data.energy_time                     = toMyNumber(v.energy_time)
        end
        row_data.train_cost = {}
        for i = 1,3 do
            local temp_str = "train_cost" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.train_cost, temp_data)
            end
        end
        row_data.accelerate_cost = {}
        for i = 1,3 do
            local temp_str = "accelerate_cost" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.accelerate_cost, temp_data)
            end
        end
        if 0 ~= toMyNumber(v.acc_count) then
            row_data.acc_count                       = toMyNumber(v.acc_count)
        end
        if "" ~= v.skill_up_desc then
            row_data.skill_up_desc                   = v.skill_up_desc
        end
        if "" ~= v.formation_attr_up_desc then
            row_data.formation_attr_up_desc            = v.formation_attr_up_desc
        end
        if nil ~= row_data.id and nil ~= row_data.level then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.level] = row_data
        end
    end
    json_table_data["xls/TotemAttr"] = data
    collectgarbage( 'collect' )
end

function findTotemAttr(first, second)
    if nil == json_table_data["xls/TotemAttr"] then
        TotemAttrLoadData()
    end
    local temp_tb = json_table_data["xls/TotemAttr"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.speed then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.speed = temp_data
    end
    if nil == data.skill then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.skill = temp_data
    end
    if nil == data.wake then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.wake = temp_data
    end
    if nil == data.formation_add_position then
        data.formation_add_position = ""
    end
    if nil == data.formation_add_attr then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.formation_add_attr = temp_data
    end
    if nil == data.formation_up_desc then
        data.formation_up_desc = ""
    end
    if nil == data.energy_time then
        data.energy_time = 0
    end
    if nil == data.acc_count then
        data.acc_count = 0
    end
    if nil == data.skill_up_desc then
        data.skill_up_desc = ""
    end
    if nil == data.formation_attr_up_desc then
        data.formation_attr_up_desc = ""
    end
    return temp_tb[first][second]
end

function TotemExtLoadData()
    if nil ~= json_table_data["xls/TotemExt.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TotemExt.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.totem_id) then
            row_data.totem_id                        = toMyNumber(v.totem_id)
        end
        if 0 ~= toMyNumber(v.level) then
            row_data.level                           = toMyNumber(v.level)
        end
        if 0 ~= toMyNumber(v.wake_lv) then
            row_data.wake_lv                         = toMyNumber(v.wake_lv)
        end
        if 0 ~= toMyNumber(v.formation_lv) then
            row_data.formation_lv                    = toMyNumber(v.formation_lv)
        end
        if 0 ~= toMyNumber(v.speed_lv) then
            row_data.speed_lv                        = toMyNumber(v.speed_lv)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TotemExt"] = data
    collectgarbage( 'collect' )
end

function findTotemExt(first)
    if nil == json_table_data["xls/TotemExt"] then
        TotemExtLoadData()
    end
    local temp_tb = json_table_data["xls/TotemExt"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.totem_id then
        data.totem_id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.wake_lv then
        data.wake_lv = 0
    end
    if nil == data.formation_lv then
        data.formation_lv = 0
    end
    if nil == data.speed_lv then
        data.speed_lv = 0
    end
    return temp_tb[first]
end

function TotemGlyphLoadData()
    if nil ~= json_table_data["xls/TotemGlyph.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TotemGlyph.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if 0 ~= toMyNumber(v.type) then
            row_data.type                            = toMyNumber(v.type)
        end
        if 0 ~= toMyNumber(v.quality) then
            row_data.quality                         = toMyNumber(v.quality)
        end
        row_data.attrs = {}
        for i = 1,5 do
            local temp_str = "attrs" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.attrs, temp_data)
            end
        end
        if "" ~= v.icon then
            row_data.icon                            = v.icon
        end
        if "" ~= v.icon2 then
            row_data.icon2                           = v.icon2
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TotemGlyph"] = data
    collectgarbage( 'collect' )
end

function findTotemGlyph(first)
    if nil == json_table_data["xls/TotemGlyph"] then
        TotemGlyphLoadData()
    end
    local temp_tb = json_table_data["xls/TotemGlyph"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.type then
        data.type = 0
    end
    if nil == data.quality then
        data.quality = 0
    end
    if nil == data.icon then
        data.icon = ""
    end
    if nil == data.icon2 then
        data.icon2 = ""
    end
    return temp_tb[first]
end

function TotemGlyphHideLoadData()
    if nil ~= json_table_data["xls/TotemGlyphHide.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TotemGlyphHide.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        local temp_data = {}
        if nil ~= v.attr then
            local x,y = string.match(v.attr,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.attr                          = temp_data
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TotemGlyphHide"] = data
    collectgarbage( 'collect' )
end

function findTotemGlyphHide(first)
    if nil == json_table_data["xls/TotemGlyphHide"] then
        TotemGlyphHideLoadData()
    end
    local temp_tb = json_table_data["xls/TotemGlyphHide"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.attr then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.attr = temp_data
    end
    return temp_tb[first]
end

function TrialLoadData()
    if nil ~= json_table_data["xls/Trial.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Trial.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        row_data.open_day = {}
        for i = 1,3 do
            local temp_str = "open_day" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.open_day, toMyNumber(v[temp_str]))
            end
        end
        if 0 ~= toMyNumber(v.strength_cost) then
            row_data.strength_cost                   = toMyNumber(v.strength_cost)
        end
        if 0 ~= toMyNumber(v.try_count) then
            row_data.try_count                       = toMyNumber(v.try_count)
        end
        if 0 ~= toMyNumber(v.monster_id) then
            row_data.monster_id                      = toMyNumber(v.monster_id)
        end
        if 0 ~= toMyNumber(v.trial_occu) then
            row_data.trial_occu                      = toMyNumber(v.trial_occu)
        end
        row_data.occu_odd = {}
        for i = 1,3 do
            local temp_str = "occu_odd" .. i
            local temp_data = {}
            local x,y = string.match(v[temp_str],"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                table.insert(row_data.occu_odd, temp_data)
            end
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Trial"] = data
    collectgarbage( 'collect' )
end

function findTrial(first)
    if nil == json_table_data["xls/Trial"] then
        TrialLoadData()
    end
    local temp_tb = json_table_data["xls/Trial"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.strength_cost then
        data.strength_cost = 0
    end
    if nil == data.try_count then
        data.try_count = 0
    end
    if nil == data.monster_id then
        data.monster_id = 0
    end
    if nil == data.trial_occu then
        data.trial_occu = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function TrialMonsterLvLoadData()
    if nil ~= json_table_data["xls/TrialMonsterLv.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TrialMonsterLv.json")) do
        local row_data = {}
        row_data.lv                              = toMyNumber(v.lv)
        if 0 ~= toMyNumber(v.hp) then
            row_data.hp                              = toMyNumber(v.hp)
        end
        if 0 ~= toMyNumber(v.physical_ack) then
            row_data.physical_ack                    = toMyNumber(v.physical_ack)
        end
        if 0 ~= toMyNumber(v.physical_def) then
            row_data.physical_def                    = toMyNumber(v.physical_def)
        end
        if 0 ~= toMyNumber(v.magic_ack) then
            row_data.magic_ack                       = toMyNumber(v.magic_ack)
        end
        if 0 ~= toMyNumber(v.magic_def) then
            row_data.magic_def                       = toMyNumber(v.magic_def)
        end
        if 0 ~= toMyNumber(v.speed) then
            row_data.speed                           = toMyNumber(v.speed)
        end
        if 0 ~= toMyNumber(v.critper) then
            row_data.critper                         = toMyNumber(v.critper)
        end
        if 0 ~= toMyNumber(v.crithurt) then
            row_data.crithurt                        = toMyNumber(v.crithurt)
        end
        if 0 ~= toMyNumber(v.critper_def) then
            row_data.critper_def                     = toMyNumber(v.critper_def)
        end
        if 0 ~= toMyNumber(v.crithurt_def) then
            row_data.crithurt_def                    = toMyNumber(v.crithurt_def)
        end
        if 0 ~= toMyNumber(v.hitper) then
            row_data.hitper                          = toMyNumber(v.hitper)
        end
        if 0 ~= toMyNumber(v.dodgeper) then
            row_data.dodgeper                        = toMyNumber(v.dodgeper)
        end
        if 0 ~= toMyNumber(v.parryper) then
            row_data.parryper                        = toMyNumber(v.parryper)
        end
        if 0 ~= toMyNumber(v.parryper_dec) then
            row_data.parryper_dec                    = toMyNumber(v.parryper_dec)
        end
        if 0 ~= toMyNumber(v.recover_critper) then
            row_data.recover_critper                 = toMyNumber(v.recover_critper)
        end
        if 0 ~= toMyNumber(v.recover_critper_def) then
            row_data.recover_critper_def             = toMyNumber(v.recover_critper_def)
        end
        if 0 ~= toMyNumber(v.recover_add_fix) then
            row_data.recover_add_fix                 = toMyNumber(v.recover_add_fix)
        end
        if 0 ~= toMyNumber(v.recover_del_fix) then
            row_data.recover_del_fix                 = toMyNumber(v.recover_del_fix)
        end
        if 0 ~= toMyNumber(v.recover_add_per) then
            row_data.recover_add_per                 = toMyNumber(v.recover_add_per)
        end
        if 0 ~= toMyNumber(v.recover_del_per) then
            row_data.recover_del_per                 = toMyNumber(v.recover_del_per)
        end
        if 0 ~= toMyNumber(v.rage_add_fix) then
            row_data.rage_add_fix                    = toMyNumber(v.rage_add_fix)
        end
        if 0 ~= toMyNumber(v.rage_del_fix) then
            row_data.rage_del_fix                    = toMyNumber(v.rage_del_fix)
        end
        if 0 ~= toMyNumber(v.rage_add_per) then
            row_data.rage_add_per                    = toMyNumber(v.rage_add_per)
        end
        if 0 ~= toMyNumber(v.rage_del_per) then
            row_data.rage_del_per                    = toMyNumber(v.rage_del_per)
        end
        if nil ~= row_data.lv then
            data[row_data.lv] = row_data
        end
    end
    json_table_data["xls/TrialMonsterLv"] = data
    collectgarbage( 'collect' )
end

function findTrialMonsterLv(first)
    if nil == json_table_data["xls/TrialMonsterLv"] then
        TrialMonsterLvLoadData()
    end
    local temp_tb = json_table_data["xls/TrialMonsterLv"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.lv then
        data.lv = 0
    end
    if nil == data.hp then
        data.hp = 0
    end
    if nil == data.physical_ack then
        data.physical_ack = 0
    end
    if nil == data.physical_def then
        data.physical_def = 0
    end
    if nil == data.magic_ack then
        data.magic_ack = 0
    end
    if nil == data.magic_def then
        data.magic_def = 0
    end
    if nil == data.speed then
        data.speed = 0
    end
    if nil == data.critper then
        data.critper = 0
    end
    if nil == data.crithurt then
        data.crithurt = 0
    end
    if nil == data.critper_def then
        data.critper_def = 0
    end
    if nil == data.crithurt_def then
        data.crithurt_def = 0
    end
    if nil == data.hitper then
        data.hitper = 0
    end
    if nil == data.dodgeper then
        data.dodgeper = 0
    end
    if nil == data.parryper then
        data.parryper = 0
    end
    if nil == data.parryper_dec then
        data.parryper_dec = 0
    end
    if nil == data.recover_critper then
        data.recover_critper = 0
    end
    if nil == data.recover_critper_def then
        data.recover_critper_def = 0
    end
    if nil == data.recover_add_fix then
        data.recover_add_fix = 0
    end
    if nil == data.recover_del_fix then
        data.recover_del_fix = 0
    end
    if nil == data.recover_add_per then
        data.recover_add_per = 0
    end
    if nil == data.recover_del_per then
        data.recover_del_per = 0
    end
    if nil == data.rage_add_fix then
        data.rage_add_fix = 0
    end
    if nil == data.rage_del_fix then
        data.rage_del_fix = 0
    end
    if nil == data.rage_add_per then
        data.rage_add_per = 0
    end
    if nil == data.rage_del_per then
        data.rage_del_per = 0
    end
    return temp_tb[first]
end

function TrialRewardLoadData()
    if nil ~= json_table_data["xls/TrialReward.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TrialReward.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if 0 ~= toMyNumber(v.trial_id) then
            row_data.trial_id                        = toMyNumber(v.trial_id)
        end
        if 0 ~= toMyNumber(v.reward) then
            row_data.reward                          = toMyNumber(v.reward)
        end
        local temp_data = {}
        if nil ~= v.level_rand then
            local x,y = string.match(v.level_rand,"(%w+)%%(%w+)")
            if nil ~= x and nil ~= y then
                temp_data.first,temp_data.second = toMyNumber(x),toMyNumber(y)
                row_data.level_rand                    = temp_data
            end
        end
        if 0 ~= toMyNumber(v.percent) then
            row_data.percent                         = toMyNumber(v.percent)
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/TrialReward"] = data
    collectgarbage( 'collect' )
end

function findTrialReward(first)
    if nil == json_table_data["xls/TrialReward"] then
        TrialRewardLoadData()
    end
    local temp_tb = json_table_data["xls/TrialReward"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.trial_id then
        data.trial_id = 0
    end
    if nil == data.reward then
        data.reward = 0
    end
    if nil == data.level_rand then
        local temp_data = {}
        temp_data.first,temp_data.second = 0,0
        data.level_rand = temp_data
    end
    if nil == data.percent then
        data.percent = 0
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function TrialRewardCountLoadData()
    if nil ~= json_table_data["xls/TrialRewardCount.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/TrialRewardCount.json")) do
        local row_data = {}
        row_data.trial_id                        = toMyNumber(v.trial_id)
        row_data.reward_count                    = toMyNumber(v.reward_count)
        if 0 ~= toMyNumber(v.trial_val) then
            row_data.trial_val                       = toMyNumber(v.trial_val)
        end
        local temp_data = {}
        if nil ~= v.reward_cost then
            local x,y,z = string.match(v.reward_cost,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.reward_cost                   = temp_data
            end
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.trial_id and nil ~= row_data.reward_count then
            if nil == data[row_data.trial_id] then 
                data[row_data.trial_id] = {}
            end
            data[row_data.trial_id][row_data.reward_count] = row_data
        end
    end
    json_table_data["xls/TrialRewardCount"] = data
    collectgarbage( 'collect' )
end

function findTrialRewardCount(first, second)
    if nil == json_table_data["xls/TrialRewardCount"] then
        TrialRewardCountLoadData()
    end
    local temp_tb = json_table_data["xls/TrialRewardCount"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.trial_id then
        data.trial_id = 0
    end
    if nil == data.reward_count then
        data.reward_count = 0
    end
    if nil == data.trial_val then
        data.trial_val = 0
    end
    if nil == data.reward_cost then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.reward_cost = temp_data
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first][second]
end

function UILoadData()
    if nil ~= json_table_data["xls/UI.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/UI.json")) do
        local row_data = {}
        row_data.ui                              = v.ui
        if 0 ~= toMyNumber(v.group) then
            row_data.group                           = toMyNumber(v.group)
        end
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        if "" ~= v.desc then
            row_data.desc                            = v.desc
        end
        if nil ~= row_data.ui then
            data[row_data.ui] = row_data
        end
    end
    json_table_data["xls/UI"] = data
    collectgarbage( 'collect' )
end

function findUI(first)
    if nil == json_table_data["xls/UI"] then
        UILoadData()
    end
    local temp_tb = json_table_data["xls/UI"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.ui then
        data.ui = ""
    end
    if nil == data.group then
        data.group = 0
    end
    if nil == data.name then
        data.name = ""
    end
    if nil == data.desc then
        data.desc = ""
    end
    return temp_tb[first]
end

function VarLoadData()
    if nil ~= json_table_data["xls/Var.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Var.json")) do
        local row_data = {}
        row_data.key                             = v.key
        if 0 ~= toMyNumber(v.flag) then
            row_data.flag                            = toMyNumber(v.flag)
        end
        if "" ~= v.des then
            row_data.des                             = v.des
        end
        if nil ~= row_data.key then
            data[row_data.key] = row_data
        end
    end
    json_table_data["xls/Var"] = data
    collectgarbage( 'collect' )
end

function findVar(first)
    if nil == json_table_data["xls/Var"] then
        VarLoadData()
    end
    local temp_tb = json_table_data["xls/Var"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.key then
        data.key = ""
    end
    if nil == data.flag then
        data.flag = 0
    end
    if nil == data.des then
        data.des = ""
    end
    return temp_tb[first]
end

function VendibleLoadData()
    if nil ~= json_table_data["xls/Vendible.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/Vendible.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        local temp_data = {}
        if nil ~= v.goods then
            local x,y,z = string.match(v.goods,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.goods                         = temp_data
            end
        end
        if 0 ~= toMyNumber(v.item_id) then
            row_data.item_id                         = toMyNumber(v.item_id)
        end
        if 0 ~= toMyNumber(v.count) then
            row_data.count                           = toMyNumber(v.count)
        end
        if 0 ~= toMyNumber(v.shop_type) then
            row_data.shop_type                       = toMyNumber(v.shop_type)
        end
        local temp_data = {}
        if nil ~= v.fake_price then
            local x,y,z = string.match(v.fake_price,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.fake_price                    = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.price then
            local x,y,z = string.match(v.price,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.price                         = temp_data
            end
        end
        if 0 ~= toMyNumber(v.history_limit_count) then
            row_data.history_limit_count             = toMyNumber(v.history_limit_count)
        end
        if 0 ~= toMyNumber(v.daily_limit_count) then
            row_data.daily_limit_count               = toMyNumber(v.daily_limit_count)
        end
        if 0 ~= toMyNumber(v.server_limit_count) then
            row_data.server_limit_count              = toMyNumber(v.server_limit_count)
        end
        if 0 ~= toMyNumber(v.win_times_limit) then
            row_data.win_times_limit                 = toMyNumber(v.win_times_limit)
        end
        if 0 ~= toMyNumber(v.medal_type) then
            row_data.medal_type                      = toMyNumber(v.medal_type)
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/Vendible"] = data
    collectgarbage( 'collect' )
end

function findVendible(first)
    if nil == json_table_data["xls/Vendible"] then
        VendibleLoadData()
    end
    local temp_tb = json_table_data["xls/Vendible"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.goods then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.goods = temp_data
    end
    if nil == data.item_id then
        data.item_id = 0
    end
    if nil == data.count then
        data.count = 0
    end
    if nil == data.shop_type then
        data.shop_type = 0
    end
    if nil == data.fake_price then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.fake_price = temp_data
    end
    if nil == data.price then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.price = temp_data
    end
    if nil == data.history_limit_count then
        data.history_limit_count = 0
    end
    if nil == data.daily_limit_count then
        data.daily_limit_count = 0
    end
    if nil == data.server_limit_count then
        data.server_limit_count = 0
    end
    if nil == data.win_times_limit then
        data.win_times_limit = 0
    end
    if nil == data.medal_type then
        data.medal_type = 0
    end
    return temp_tb[first]
end

function VipPrivilegeLoadData()
    if nil ~= json_table_data["xls/VipPrivilege.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/VipPrivilege.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.name then
            row_data.name                            = v.name
        end
        row_data.vip = {}
        for i = 1,20 do
            local temp_str = "vip" .. i
            if "" ~= v[temp_str] then
                table.insert(row_data.vip, toMyNumber(v[temp_str]))
            end
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/VipPrivilege"] = data
    collectgarbage( 'collect' )
end

function findVipPrivilege(first)
    if nil == json_table_data["xls/VipPrivilege"] then
        VipPrivilegeLoadData()
    end
    local temp_tb = json_table_data["xls/VipPrivilege"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.name then
        data.name = ""
    end
    return temp_tb[first]
end

function VipRightsLoadData()
    if nil ~= json_table_data["xls/VipRights.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/VipRights.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        if "" ~= v.vip then
            row_data.vip                             = v.vip
        end
        if nil ~= row_data.id then
            data[row_data.id] = row_data
        end
    end
    json_table_data["xls/VipRights"] = data
    collectgarbage( 'collect' )
end

function findVipRights(first)
    if nil == json_table_data["xls/VipRights"] then
        VipRightsLoadData()
    end
    local temp_tb = json_table_data["xls/VipRights"]   
    local data = temp_tb[first]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.vip then
        data.vip = ""
    end
    return temp_tb[first]
end

function VipTimeLimitShopLoadData()
    if nil ~= json_table_data["xls/VipTimeLimitShop.json"] then
        return
    end
    local data = {}
    for _, v in pairs(roadDataFromJson("xls/VipTimeLimitShop.json")) do
        local row_data = {}
        row_data.id                              = toMyNumber(v.id)
        row_data.level                           = toMyNumber(v.level)
        row_data.item = {}
        for i = 1,4 do
            local temp_str = "item" .. i
            local temp_data = {}
            local x,y,z = string.match(v[temp_str],"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                table.insert(row_data.item, temp_data)
            end
        end
        local temp_data = {}
        if nil ~= v.discount_price then
            local x,y,z = string.match(v.discount_price,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.discount_price                = temp_data
            end
        end
        local temp_data = {}
        if nil ~= v.real_price then
            local x,y,z = string.match(v.real_price,"(%w+)%%(%w+)%%(%w+)")
            if nil ~= x and nil ~= y and nil ~= z then
                temp_data.cate,temp_data.objid,temp_data.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                row_data.real_price                    = temp_data
            end
        end
        if nil ~= row_data.id and nil ~= row_data.level then
            if nil == data[row_data.id] then 
                data[row_data.id] = {}
            end
            data[row_data.id][row_data.level] = row_data
        end
    end
    json_table_data["xls/VipTimeLimitShop"] = data
    collectgarbage( 'collect' )
end

function findVipTimeLimitShop(first, second)
    if nil == json_table_data["xls/VipTimeLimitShop"] then
        VipTimeLimitShopLoadData()
    end
    local temp_tb = json_table_data["xls/VipTimeLimitShop"]
    if nil == temp_tb[first] then
        return nil
    end
    local data = temp_tb[first][second]
    if nil == data then
        return nil
    end
    if nil == data.id then
        data.id = 0
    end
    if nil == data.level then
        data.level = 0
    end
    if nil == data.discount_price then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.discount_price = temp_data
    end
    if nil == data.real_price then
        local temp_data = {}
        temp_data.cate,temp_data.objid,temp_data.val = 0,0,0
        data.real_price = temp_data
    end
    return temp_tb[first][second]
end

