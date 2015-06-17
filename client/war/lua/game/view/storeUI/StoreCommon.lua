StoreCommon = {}

function StoreCommon.intoVip()
    Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
end 

function StoreCommon.intoArena()
    local build = findBuilding(20)  -- 竞技场
    local level = 100
    if build ~= nil then 
        level = build.common_open
    end 
    local now_level = gameData.getSimpleDataByKey("team_level")
    if now_level >= level then 
        Command.run( 'ui show', "ArenaUI", PopUpType.SPECIAL )
    else  
        TipsMgr.showError(level .. "级开放")
    end 
    
end 

function StoreCommon.intoMudi()
    local build = findBuilding(22)  -- 大墓地
    local level = 100
    if build ~= nil then 
       level = build.common_open
    end 
    local now_level = gameData.getSimpleDataByKey("team_level")
    if now_level >= level then 
       Command.run("ui hide" , "Store" )
       Command.run("ui show", "TombMainUI", PopUpType.SPECIAL)
    else  
       TipsMgr.showError(level .. "级开放")
    end 
end 

function StoreCommon:addOutline(item, rgb, px)
    local txt = item:getVirtualRenderer()
    txt:enableOutline(rgb, px)
end
