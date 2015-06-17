local __this = { chunk_method = {}, search_event = {} }

__this.currGid = 0

--提交探索事件
function __this.commit_event()
    -- if true then 
    --     CopyData.user.copy.posi = gameData.user.copy.posi
    --     return 
    -- end
    if #__this.search_event <= 0 then
        return
    end
    
    CopyData.strength = 0
    CopySceneUI.countCopyExp = 0

    LogMgr.log( 'copy',">>>>>>>>>>提交副本进度: length = " .. #__this.search_event)
    gameData.user.copy.posi = CopyData.user.copy.posi
    gameData.user.copy.index = CopyData.user.copy.index
    CopyRewardData.prePosi = gameData.user.copy.posi + 1

    -- LogMgr.log( 'copy',"提交探索事件： length = " .. #__this.search_event)
    for i = 1, #__this.search_event do
        local _data = __this.search_event[i]
        
        LogMgr.log( 'copy',">>>>>>>>>>" .. _data.protocol_name .. " , posi = " .. _data.posi .. " , index = " .. _data.index)
        trans.send_msg( _data.protocol_name, _data )
    end
    
    __this.search_event = {}
end

--保存副本探索事件
function __this.save_event( new_posi, new_index, fight_orders )
    local u_copy = CopyData.user.copy

    local _data = { posi = CopyData.user.copy.posi, index = new_index }
    LogMgr.debug(">>>>>>>>>>>> 保存数据 : " .. _data.posi .. " , index = " .. _data.index)
    if fight_orders == nil then
        _data.protocol_name = 'PQCopyCommitEvent'
    else
        _data.protocol_name = 'PQCopyCommitEventFight'
        _data.fight_id = u_copy.chunk[new_posi].val
        _data.order_list = fight_orders.order_list
        _data.fight_info_list = fight_orders.fight_info_list
    end
    
    local prev_posi = u_copy.posi
    local prev_index = u_copy.index

    u_copy.posi = new_posi
    u_copy.index = new_index

    Command.run("CopyProgress update")
    EventMgr.dispatch(EventType.UpdateCopyProgress)
    if #__this.search_event == 0 then
        table.insert( __this.search_event, _data )
    else
        while #__this.search_event > 0 do
            local len = #__this.search_event
            local p_name = __this.search_event[len].protocol_name
            if p_name == "PQCopyCommitEvent" then
                table.remove(__this.search_event, len)
            elseif p_name == "PQCopyCommitEventFight" then
                table.insert(__this.search_event, _data)
                break
            end
        end
        if #__this.search_event == 0 then
            table.insert(__this.search_event, _data)
        end
    end
    
    LogMgr.log( 'copy',"当前已通关进度 : pos = ".. new_posi)
    if new_posi >= #CopyData.user.copy.chunk then
        CopyData.pre_copy_id = gameData.user.copy.copy_id
        local tid = 0
        local function runLater()
            TimerMgr.killTimer(tid)
--            Command.run("loading wait show", 'copy')
            LogMgr.log( 'copy',"貌似已经完成副本了~~~")
            CopyData.isSendMsg = true
            --提交 副本 100001 commit posi 2 数据验证
            ActionMgr.save( 'copy', 'send commit runLater:' .. CopyData.pre_copy_id .. "  posi:" .. _data.posi .. "  index:" .. _data.index )
            Command.run( 'copy commit')
            --接收 副本 100001 commit posi 2 数据返回
            ActionMgr.save( 'copy', 'send close runLater:' .. CopyData.pre_copy_id )
            Command.run( 'copy close' )
        end
        tid = TimerMgr.startTimer(runLater, 1, false)

        local sid = 0
        local function showComp()
            TimerMgr.killTimer(sid)

--            gameData.user.copy.copy_id = 0

            PopMgr.checkPriorityPop(
                "CopySearchCompleteUI", 
                PopOrType.Com,
                function()
--                    Command.run("ui show", "CopySearchCompleteUI", PopUpType.MODEL)
                    Command.run("show copyComplete")
                end
            )
        end
        sid = TimerMgr.startTimer(showComp, 1.5, false)
    else
        if prev_posi < new_posi then
            CopyData.user.copy.index = 0
            
            local chunk = u_copy.chunk[ prev_posi + 1 ]
            local isNotAdd = (chunk.cate == trans.const.kCopyEventTypeFightMeet and prev_index == 0)
            if isNotAdd == false then
                CopyRewardData.showRewardAt(prev_posi + 1)
--                Command.run("CopyMgr delayDoChunk")
            end
        end

        if nil ~= fight_orders and not CopyData.isTeamUpgrade then
            --提交 副本 100001 commit posi 2 数据验证
            ActionMgr.save( 'copy', 'send commit save_event:' .. CopyData.pre_copy_id .. "  posi:" .. _data.posi .. "  index:" .. _data.index )
            Command.run("copy commit")
        end 
    end
end

-- 副本探索处理
-- 宝箱
__this.chunk_method[ trans.const.kCopyEventTypeBox ] = function(u_copy, chunk)
    -- showBox()
    LogMgr.log( 'copy',"宝箱id = " .. chunk.objid .. " , 物品id = " .. chunk.val)
    local item = findItem(chunk.val)
    if item then
        LogMgr.log( 'copy',"获得 ：" .. item.name)
    else
        LogMgr.log( 'copy',"查找不到该物品")
    end
    __this.save_event( u_copy.posi + 1, 0 )
end
-- 奖励
__this.chunk_method[ trans.const.kCopyEventTypeReward ] = function(u_copy, chunk)
    -- showPrize()
    LogMgr.log( 'copy',"物品id = " .. chunk.objid)
    local item = findItem(chunk.val)
    if item then
        LogMgr.log( 'copy',"获得 ：" .. item.name)
    else
        LogMgr.log( 'copy',"查找不到该物品")
    end
    __this.save_event( u_copy.posi + 1, 0 )
end
-- 剧情
__this.chunk_method[ trans.const.kCopyEventTypeGut ] = function(u_copy, chunk, list)
    -- showGut()
    LogMgr.log( 'copy',"剧情id = " .. chunk.objid .. " , val = " .. chunk.val)
    local gut = findGut(chunk.objid, 0)
    if nil ==  gut then
        LogMgr.log( 'copy',"查找不到该剧情")
    end

    local index = 0
    local len = #list
    if len > 0 then
        for i = 1, len, 1 do
            local posi = u_copy.posi
            if list[i] ~= nil then
                index = list[i].index
                if i == len then
                    posi = posi + 1
                    -- index = 0
                end
                if list[i].type == const.kGutTypeFight then
                    __this.save_event( posi, index , {order_list = list[i].orderList, fight_info_list = list[i].fightInfoList})
                else
                    __this.save_event( posi, index )
                end
            end
        end
    end
end
-- 商人
__this.chunk_method[ trans.const.kCopyEventTypeShop ] = function(u_copy, chunk)
    -- showShop()
    LogMgr.log( 'copy',"弹出商店")
    __this.save_event( u_copy.posi + 1, 0 )
end
-- 战斗
__this.chunk_method[ trans.const.kCopyEventTypeFight ] = function(u_copy, chunk)
    -- showFight()
    __this.save_event( u_copy.posi + 1, 0,  CopyData.fightData)

    CopyData.fightData = nil
end

__this.chunk_method[ trans.const.kCopyEventTypeFightMeet ] = function(u_copy, chunk)
    local index = CopyData.user.copy.index
    LogMgr.debug(">>>>>>> 执行遭遇战" .. index)
    if index == 0 then
        __this.save_event( u_copy.posi, 0)
        CopyData.user.copy.index = 1
    elseif index == 1 then
        __this.save_event( u_copy.posi + 1, 1,  CopyData.fightData)
        CopyData.fightData = nil
    end
end

--打开副本
Command.bind( 'copy open', function(id)
    ActionMgr.save( 'copy', 'send open: ' .. id )
    
    trans.send_msg( 'PQCopyOpen', {} )
    
    CopyData.wait_open = true;
    Command.run("loading wait show", 'copy_open', 3)
end )

--关闭副本
Command.bind( 'copy close', function()
    ActionMgr.save( 'copy', 'send close' )
    
    CopyData.wait_close = true;
    trans.send_msg( 'PQCopyClose', {} )
end )

--刷新副本数据( 在调整战斗力前需要将已探索的事件与服务器同步 )
Command.bind( 'copy refurbish', function( state )
    if not state then state = '' end
    
    ActionMgr.save( 'copy', 'send ref: state - ' .. state )

    CopyData.isNeedRefurish = false
    -- 先提交现有事件
    local count = #__this.search_event
    if count > 0 then
        -- return false
        __this.commit_event()
    end
    
    local c_copy = CopyData.user.copy
    local posi = c_copy.posi
    local len = #c_copy.chunk
    for i = posi + 1, len do
        local chunk = c_copy.chunk[i]
        if chunk.cate == const.kCopyEventTypeFightMeet or chunk.cate == 6 then
            CopyData.isSendRefurbish = true
            
            -- 如果后面的事件有战斗, 则刷新副本
            trans.sentTimeoutMsg( 'PQCopyRefurbish', {} )
            
            CopyData.wait_ref = true

            if state ~= 'enter_copy' then
                Command.run("loading wait show", 'copy')
            end
            break
        end
    end
    
    return true
end )

--离线探索
Command.bind( 'copy search', function(list)
    local u_copy = CopyData.user.copy
    if u_copy.posi < #u_copy.chunk then
        local chunk = u_copy.chunk[ u_copy.posi + 1 ]
        __this.chunk_method[ chunk.cate ]( u_copy, chunk, list)
    else
        LogMgr.log( 'copy',"该副本探索已完成")
    end
end )

Command.bind("copy fihgtBoss", function(stype, boss_id)
    LogMgr.debug(">>>>>>>>>>>挑战Boss：type = " .. stype .. " , boss_id = " .. boss_id)
    trans.send_msg("PQCopyBossFight", {mopup_type = stype, boss_id = boss_id})
end)

-- req = {order_list = {}, fight_info_list = {}}
Command.bind(("copy commitFightBoss"), function(req)
    trans.send_msg("PQCopyBossFightCommit", req)
end)

Command.bind("copy saodang", function(stype, boss_id, count)
    LogMgr.debug(">>>>>>>>>>>扫荡：type = " .. stype .. " , boss_id = " .. boss_id .. " , count = " .. count)
    trans.send_msg("PQCopyBossMopup", {mopup_type = stype, boss_id = boss_id, count = count})
end)

Command.bind("copy resetBoss", function(stype, boss_id)
    LogMgr.debug(">>>>>>>>>>>重置Boss：type = " .. stype .. " , boss_id = " .. boss_id)
    trans.send_msg("PQCopyMopupReset", {mopup_type = stype, boss_id = boss_id})
end)

Command.bind("copy takePresent", function(stype, area_id, area_attr)
    LogMgr.debug(">>>>>>>>>>>领取区域奖励：type = " .. stype .. " , area_id = " .. area_id)
    trans.send_msg("PQCopyAreaPresentTake", {mopup_type = stype, area_id = area_id, area_attr=area_attr})
end)

Command.bind("copy commit oneMonster", function(fight_id)
    local fight_orders = CopyData.fightData
    local _data = { posi = 0, index = 0 }
    LogMgr.debug(">>>>>>>>>>>> 保存数据 : " .. _data.posi .. " , index = " .. _data.index)
    
    _data.protocol_name = 'PQCopyCommitEventFight'
    _data.fight_id = fight_id
    _data.order_list = fight_orders.order_list
    _data.fight_info_list = fight_orders.fight_info_list

    table.insert( __this.search_event, _data )
    if const.kCopyMopupTypeElite == CopyData.fightBossType then
        return
    end

    CopyData.pre_copy_id = gameData.user.copy.copy_id

    CopyData.isSendMsg = true
    --提交 副本 100001 commit posi 2 数据验证
    ActionMgr.save( 'copy', 'send commit copy commit oneMonster:' .. CopyData.pre_copy_id .. '  posi:' .. _data.posi .. '  index:' .. _data.index )
    Command.run( 'copy commit')
    --接收 副本 100001 commit posi 2 数据返回
    ActionMgr.save( 'copy', 'send close copy commit oneMonster:' .. CopyData.pre_copy_id ) 
    Command.run( 'copy close' )
end)

--提交副本探索
Command.bind( 'copy commit', __this.commit_event )

Command.bind("copy load fightlog", function(monster_id)
    local data = CopyData.bossRecordData[monster_id]
    if data == nil or #data == 0 then --已经有记录就不请求了
        local time = gameData.getServerTime()
        if not CopyData.bossRecordTime[monster_id] or time - CopyData.bossRecordTime[monster_id] > 10 then
            CopyData.bossRecordTime[monster_id] = time
            trans.send_msg("PQCopyFightLogLoad", {copy_id=monster_id})
        end
    end
end)