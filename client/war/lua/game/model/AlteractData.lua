--by toking
AlteractData = {}
AlteractData.TYPE_COPY=1 -- 普通副本
AlteractData.TYPE_FIGHT_TRIAL=2 --十字征试炼
AlteractData.TYPE_AREA_STORE = 3 --竞技场商店
AlteractData.TYPE_COMON_STORE = 4 -- 普通商店
AlteractData.TYPE_RICHARGE = 5 --充值
AlteractData.TYPE_AREA = 6 --竞技场
AlteractData.TYPE_DJ_STORE = 7
AlteractData.TYPE_OTHERS = 8
AlteractData.TYPE_JINGOIN = 9
AlteractData.TYPE_DAMUDI = 10
AlteractData.TYPE_PAIMAIHAN = 11
AlteractData.TYPE_OPEN_TOTEM = 12 --打开图腾界面
AlteractData.TYPE_OPEN_SOLDIER = 13 --打开英雄界面

function AlteractData.goToFinsh(alterData, fromui)
    if alterData then
        local link_type = alterData.link_type
        if link_type == AlteractData.TYPE_COPY then
            --Command.run("NCopyUI show copy", tonumber(AlteractData.getArrStr(alterData.link_data)[1]), tonumber(AlteractData.getArrStr(alterData.link_data)[2]) )
            Command.run("BossInfoUI showWith", tonumber(AlteractData.getArrStr(alterData.link_data)[2]), tonumber(AlteractData.getArrStr(alterData.link_data)[1]))
        elseif link_type == AlteractData.TYPE_FIGHT_TRIAL then
            Command.run("ui show", "TrialMainUI")
        elseif link_type == AlteractData.TYPE_AREA_STORE then
            StoreData.SelectType = StoreData.Type.XZ
            Command.run('ui show','Store',PopUpType.SPECIAL)
        elseif link_type == AlteractData.TYPE_COMON_STORE then
            StoreData.SelectType = StoreData.Type.MR
            Command.run('ui show','Store',PopUpType.SPECIAL)
        elseif link_type == AlteractData.TYPE_RICHARGE then
            Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
        elseif link_type == AlteractData.TYPE_AREA  then
            Command.run('ui show','ArenaUI')
        elseif link_type == AlteractData.TYPE_DJ_STORE  then
            StoreData.SelectType = StoreData.Type.DJ
            StoreData.yongqiflag = true
            Command.run("ui show", "Store", PopUpType.SPECIAL)
        elseif link_type == AlteractData.TYPE_OTHERS  then
            if alterData.item_id == 30804 then
                if ActivityData.hasGetedFR() == false then
                    Command.run( 'ui show', "ActivityFRUI", PopUpType.SPECIAL )
                end
            elseif alterData.link_data then
                if alterData.link_data == "FriendUI" then
                    ChatData.isFriend = true
                    Command.run( 'ui show', "ChatUI", PopUpType.SPECIAL )
                else
                    Command.run( 'ui show', alterData.link_data, PopUpType.SPECIAL )
                end
            end
        elseif link_type == AlteractData.TYPE_JINGOIN then
            EventMgr.dispatch(EventType.showSpeedStyle, 2)
        elseif link_type == AlteractData.TYPE_DAMUDI then
            Command.run( 'ui show', 'TombMainUI' )
        elseif link_type == AlteractData.TYPE_PAIMAIHAN then
            Command.run( 'ui show', 'AuctionUI')
        elseif link_type == AlteractData.TYPE_OPEN_TOTEM then
            Command.run( "ui show", "TotemUI",PopUpType.SPECIAL )
            local win = PopMgr.getWindow('TotemUI')
            if win ~= nil then
                win:changeTotemById( AlteractData.item_id )
            end
        elseif link_type == AlteractData.TYPE_OPEN_SOLDIER then
            Command.run( "ui show", "SoldierUI",PopUpType.SPECIAL)
            local win = PopMgr.getWindow('SoldierUI')
            if win ~= nil then
                win:getSelectedItem( AlteractData.item_id )
            end
        end

    end
    Command.run( 'ui hide', fromui or "AlteractyTipsUI", PopUpType.SPECIAL )
end

function AlteractData.getName( alterData )
    local name = ""
    if alterData then
        if alterData.link_type == AlteractData.TYPE_COPY then
            name = AlteractData.getFindName(alterData)
        else
            if alterData.name and alterData.name ~= "" then
                name = alterData.name
            else
                name = AlteractData.getFindName(alterData)
            end
        end
    end
    return name
end

function AlteractData.getFindName( alterData )
    local name = ""
    if alterData then
        if alterData.link_type == AlteractData.TYPE_COPY then
            local copy = findCopy(tonumber(AlteractData.getArrStr(alterData.link_data)[2]))
            if copy then
                name = copy.name
            end
        elseif alterData.link_type == AlteractData.TYPE_FIGHT_TRIAL then
            name = "十字军东征"
        elseif alterData.link_type == AlteractData.TYPE_AREA_STORE then
            name = "竞技场商店"
        elseif alterData.link_type == AlteractData.TYPE_COMON_STORE then
            name = "普通商店"
        elseif alterData.link_type == AlteractData.TYPE_RICHARGE then
            name = "充值"
        elseif alterData.link_type == AlteractData.TYPE_AREA then
            name = "竞技场"
        else
            if alterData.name then
                name = alterData.name
            end
        end
    end
    return name
end

function AlteractData.getArrStr( str )
    local arr = nil
    if str and str ~= "" then
        arr = string.split(str,"%")
    end

    for _,v in ipairs(arr) do
        arr[_] = tonumber(arr[_])
    end
    return arr
end

function AlteractData.cheakOpen( alterData )
    local isOpen = false
    local openTips = nil
    if alterData then
        if alterData.link_type == AlteractData.TYPE_COPY then
            local type = const.kCopyMopupTypeNormal
            if AlteractData.getArrStr(alterData.link_data)[1] == 2 then
                type = const.kCopyMopupTypeElite
            end
            isOpen = CopyData.checkOpenCopyBy(tonumber(AlteractData.getArrStr(alterData.link_data)[2]),type)
        else
            if alterData.open_type == OpenFuncData.TYPE_BUILDING or alterData.open_type == 2 then
                isOpen,openTips= OpenFuncData.checkIsOpen(alterData.open_type,alterData.open_term,false)
                if OpenTargetData.getCurOpenDay(true) <= 1 then
                    isOpen = false
                    openTips = "开服第一天不开放"
                end
            elseif alterData.open_type == 3 then
                isOpen = gameData.getSimpleDataByKey("team_level") >= alterData.open_term
            elseif alterData.open_type == 5 then
                isOpen = (TaskData.getTask(alterData.open_term) ~= nil or TaskData.hasLogTask(alterData.open_term))
            elseif alterData.open_type == 6 then
                isOpen = TaskData.hasLogTask(alterData.open_term)
            elseif alterData.open_type == 7 then
                isOpen = TaskData.hasLogTask(alterData.open_term)
            elseif alterData.open_type == AlteractData.TYPE_OTHERS then
                if alterData.item_id and alterData.item_id == 30804 then
                    if ActivityData.hasGetedFR() == false then
                        isOpen = true
                    end
                end
            elseif alterData.open_type == nil or alterData.open_type == "" then
                isOpen = true
            end
        end
    end
    return isOpen,openTips
end

function AlteractData.getLeftNum( alterData )
    local leftNum = nil
    local enough = false
    local curtimes = nil
    local  maxtimes = nil
    if alterData and AlteractData.cheakOpen(alterData) then
        if alterData.link_type == AlteractData.TYPE_COPY then
            curtimes =  SaoDangData.getLeftSaoTimesByCopyId(tonumber(AlteractData.getArrStr(alterData.link_data)[1]), tonumber(AlteractData.getArrStr(alterData.link_data)[2]))
            maxtimes = SaoDangData.getTotalSaoTimes(tonumber(AlteractData.getArrStr(alterData.link_data)[1]))
            leftNum = string.format("（%d/%d）",curtimes,maxtimes)
        elseif alterData.link_type == AlteractData.TYPE_FIGHT_TRIAL then
            local data = GetDataList("Trial")
            local sdate = GameData.getServerDate()
            for i, trial in pairs(data) do
                if TrialMainItem.checkWday(sdate, trial) then
                    maxtimes = trial.try_count
                    curtimes = trial.try_count
                    local userTrial = TrialMgr.getTrial(trial.id)
                    if userTrial then
                        curtimes = maxtimes - userTrial.try_count
                    end
                    leftNum = string.format("（%d/%d）",curtimes,maxtimes)
                end
            end
        elseif alterData.link_type == AlteractData.TYPE_AREA_STORE then
        elseif alterData.link_type == AlteractData.TYPE_COMON_STORE then
        elseif alterData.link_type == AlteractData.TYPE_RICHARGE then
        elseif alterData.link_type == AlteractData.TYPE_AREA then
            local list = ArenaData.getRolelist()[1]
            if not list then
            else
                curtimes = list.left
                maxtimes = list.all
                leftNum = string.format("（%d/%d）",curtimes,maxtimes)
            end
        end
    end
    if curtimes and curtimes > 0 then enough = true end
    return leftNum,enough
end

function AlteractData.getalterDatalist( cate,item_id,item_type )
    local all_list = GetDataList( 'Alternacts' )
    local alter_list = {}

    for k, v in pairs(all_list) do
        if cate >=0 and cate ~= const.kCoinItem then
            if v.cate == cate then
                table.insert(alter_list, v)
            end
        elseif item_id > 0 then
            if v.item_id == item_id then
                table.insert(alter_list, v)
            end
        elseif item_type > 0 then
            if v.item_type == item_type then
                table.insert(alter_list, v)
            end
        end
    end
    return alter_list
end

function AlteractData.canShow( cate,item_id,item_type )
    local alter_list = AlteractData.getalterDatalist(cate,item_id,item_type)
    if item_id then
        local itemData = findItem(item_id)
        if itemData then item_type = itemData.type end
    end
    if const.kItemTypeSoulStone == item_type then
        if #alter_list >= 0 then
            return true
        else
            return false
        end
    end
    if #alter_list > 0 then
        if cate == const.kCoinMoney then
            if gameData.checkLevel(15) == true then
                return true
            else
                return false
            end
        end
        return true
    else
        return false
    end
end

function AlteractData.showByData( cate,item_id,item_type )
    if AlteractData.canShow(cate,item_id,item_type) then
        AlteractData.item_id = item_id
        AlteractData.cate = cate
        AlteractData.item_type = item_type
        Command.run( 'ui show', "AlteractyTipsUI", PopUpType.SPECIAL )
    end
end

function AlteractData.clearn( ... )
    AlteractData.item_id = nil
    AlteractData.cate = nil
    AlteractData.item_type = nil
end

function AlteractData.getLinkDesc( alterData )
    local linkdesc = "未开启"
    if alterData then
        local isOpen = false
        local openTips = nil
        isOpen,openTips = AlteractData.cheakOpen(alterData)
        if isOpen then
            if alterData.link_desc then
                linkdesc = alterData.link_desc
            else
                if alterData.link_type == AlteractData.TYPE_COPY then
                    linkdesc = "点击进入"
                elseif alterData.link_type == AlteractData.TYPE_FIGHT_TRIAL then
                    linkdesc = "点击进入"
                elseif alterData.link_type == AlteractData.TYPE_AREA_STORE then
                    linkdesc = "点击进入购买"
                elseif alterData.link_type == AlteractData.TYPE_COMON_STORE then
                    linkdesc = "点击进入购买"
                elseif alterData.link_type == AlteractData.TYPE_RICHARGE then
                    linkdesc = "去充值"
                elseif alterData.link_type == AlteractData.TYPE_AREA then
                    linkdesc = "去竞技"
                end
            end
        else
            if openTips then
                linkdesc = openTips
            elseif alterData.undesc and alterData.undesc~="" then
                linkdesc = alterData.undesc
            else
                if alterData.link_type == AlteractData.TYPE_COPY then
                    linkdesc = "未开启"
                else
                    if alterData.open_type == OpenFuncData.TYPE_BUILDING or alterData.open_type == 2 then
                        local _,v = OpenFuncData.checkIsOpen(alterData)
                        linkdesc = v
                    elseif alterData.open_type == 3 then
                        linkdesc = string.format("战队%s级开放", alterData.open_term)
                    elseif alterData.open_type == 5 then
                        linkdesc = string.format("接受%s任务后开放", alterData.open_term)
                    elseif alterData.open_type == 6 then
                        linkdesc = string.format("完成%s任务后开放", alterData.open_term)
                    elseif alterData.open_type == AlteractData.TYPE_OTHERS then
                        if alterData.item_id and alterData.item_id == 30804 then
                            if ActivityData.hasGetedFR() == true then
                                linkdesc = "已领取"
                            end
                        end
                    end
                end
            end
        end
    end
    return linkdesc
end