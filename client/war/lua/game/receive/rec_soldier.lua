--英雄列表
trans.call.PRSoldierList = function(msg)
    gameData.user.soldier_map[ msg.soldier_type ] = msg.soldier_map
    
    EventMgr.dispatch( EventType.UserSoldierUpdate )
    EventMgr.dispatch(EventType.tombUiUpdata)
end

--英雄信息 （在升级时候）
trans.call.PRSoldierSet = function(msg)
    local isAutoUp = msg.soldier.guid <= 2 and SoldierData.getSoldier(msg.soldier.guid) == nil --TASK #6263::【手游】新手阶段前两个英雄和图腾自动上阵
    gameData.changeMap( SoldierData.getTable( msg.soldier.soldier_type ), msg.soldier.guid, msg.set_type, msg.soldier )
    --升级成功
    if msg.set_path == const.kPathSoldierLvUp then
        SoundMgr.playUI("ui_rolelevelup")
       -- SoldierDefine.levelUp = true
        --钱减少
        if SoldierData.lvUpNeed then
            local top = MainUIMgr.getRoleTop()
            top:reduceValue("con_solution",SoldierData.lvUpNeed)
        end
        --LogMgr.debug("谭PRSoldierSet：：：：：" )
        EventMgr.dispatch( EventType.SoldierLevelUp, msg.soldier.level )
    end
    --升阶成功
    if msg.set_path == const.kPathSoldierQualityUp then
        SoldierData.showStepSuccessUI(msg.soldier)
    end
    --升星成功
    if msg.set_path == const.kPathSoldierStarUp then
        SoundMgr.playSoldierTalk( msg.soldier.soldier_id )
        Command.run("ui show", "SoldierStarUpSuccess", PopUpType.SPECIAL)
        local win = PopMgr.getWindow('SoldierStarUpSuccess')
        if win ~= nil then
            win:setData( msg.soldier )
        end 
    end
    EventMgr.dispatch(EventType.UserSoldierUpdate)
    if isAutoUp then
        FormationData.upByGuid(const.kFormationTypeCommon, msg.soldier.guid, const.kAttrSoldier, true) --前两个英雄自动上阵
    end

    EventMgr.dispatch(EventType.UserCopyUpdate)
end

--英雄招募
trans.call.PRSoldierRecruit = function(msg)
    local top = MainUIMgr.getRoleTop()
    local function closeCallBack( ... )
       top:setVisible(true)
    end

    local win = PopMgr.getWindow('SoldierStarUpSuccess')
    if win ~= nil then
        win:setData( msg.soldier )
    end 
    --{ 'id', 'uint32' },		-- 招募ID
    local recruitInfo = findSoldierRecruit(msg.id)
    local solierInfo = findSoldier(recruitInfo.soldier_id)
    --showMsgBox("成功招募英雄 ".. solierInfo.name )
    local win = PopMgr.getWindow('SoldierUI')
    if win ~= nil then
        top:setVisible(false)
        SoldierData.soldierGetUI(closeCallBack,recruitInfo.soldier_id )
    else
        SoldierData.soldierGetUI(nil,recruitInfo.soldier_id )
    end
    EventMgr.dispatch( EventType.UserSoldierUpdate )
    EventMgr.dispatch( EventType.UserSoldierRecruit )
end

-- @@武将装备二级属性
trans.call.PRSoldierEquipExt = function(msg)
    SoldierData.equipExt_map[msg.soldier.second] = msg.able
    EventMgr.dispatch( EventType.UserSoldierEquipExt )
end

