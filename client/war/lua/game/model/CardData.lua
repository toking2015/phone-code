local __this = CardData or {}
CardData = __this
local dimCopyId = tonumber( findGlobal("altar_lottery_gold_copy_passed_id").data )

local info = nil
CardData.rewardData = nil  --抽奖返回
CardData.virRewardData = nil  --客户端模拟服务器数据
CardData.qLock = false
function CardData.addInfo( msg )
    info = msg.info
end

function CardData.actReward( msg )
    info = msg.info
    CardData.rewardData = msg
    --CardData.rewardProcc()
end

function CardData.getInfo()
    return info
end

function CardData.rewardProcc()
    --local rewardData = CardData.rewardData
    local rewardData = CardData.virRewardData
    if rewardData.soldier_id ~= nil and rewardData.soldier_id ~= 0 then
        SoldierData.soldierGetUI(nil,rewardData.soldier_id)
        return
    end

    local win = PopMgr.getWindow('CardGet')
    if win == nil then
        Command.run("ui show", "CardGet", PopUpType.SPECIAL)
    else
        win:updateData()
    end
end 

function CardData.Free( ... )
    local dimFree = false
    if CardData.isDimOpen() then
        if __this.getDimCdLTime() <= 0  or CardData.checkItemFreeForDim() then
            dimFree = true
        end
    end
    return __this.checkNormalFree() or dimFree or CardData.checkItemFreeForNor()
end

function CardData.checkItemFreeForNor( ... )
    local useItem = toS3UInt32( findGlobal("altar_lottery_money_onece_item_cost").data )
    local jItem = findItem(useItem.objid)
    if jItem then
        local packNum = ItemData.getItemCount(useItem.objid,const.kBagFuncCommon)
        if packNum >= useItem.val then
            return true
        end
    end
    return false
end

function CardData.checkItemFreeForDim( ... )
    local useItem = toS3UInt32( findGlobal("altar_lottery_gold_onece_item_cost").data )
    local jItem = findItem(useItem.objid)
    if jItem then
        local packNum = ItemData.getItemCount(useItem.objid,const.kBagFuncCommon)
        if packNum >= useItem.val then
            return true
        end
    end
    return false
end

function CardData.checkNormalFree()
    if info == nil then
        return false
    end
    
    local left = CardData.getNorCdLTime()
    return left <= 0 and info.free_count > 0 
end

function CardData.getNorCdLTime()
    if info == nil then
        return false
    end
    
    local serverNowTime = GameData.getServerTime()
    local cdEndTime = info.free_time + CardDefine.cdInterval
    local left = cdEndTime - serverNowTime
    return left
end

function CardData.getDimCdLTime()
    if info == nil then
        return 0
    end
    
    local serverNowTime = GameData.getServerTime()
    local cdEndTime = info.gold_free_time + CardDefine.cdDimInterval
    local left = cdEndTime - serverNowTime
    return left
end

function CardData.isDimOpen( )
    local log = CopyData.getCopyLogById(dimCopyId)
    return log and log.time > 0  
end

function CardData.getEnItem( useItem )
    local jItem = findItem(useItem.objid)
    if jItem then
        local packNum = ItemData.getItemCount(useItem.objid,const.kBagFuncCommon)
        if packNum >= useItem.val then
            return true
        end
    end
    return false
end

function CardData.cardQ( type, count, use_type)
    CardData.virRewardData = nil
    __this.qLock = true
    __this.virRewardData = __this.Lottery(type, count, use_type)
    if __this.virRewardData.reward_list then
        LogMgr.log( 'action',"CardData.cardQ：：" .. #__this.virRewardData.reward_list )
    end
    __this.rewardProcc()

    local str = ""
    if type and count and use_type then
        str = string.format("type:%d   count:%d  use_type:%d",type,count,use_type)
    end
    LogMgr.log( 'action',"CardData.cardQ_data******" .. str )
    Command.run( 'altar lottery',type, count, use_type)
end

function CardData.norQ( times,nor_one_cost, nor_ten_cost)
    if CardData.qLock then
        Command.run("loading wait show", 'cardq')
        return false
    end
    
    local money= CoinData.getCoinByCate(const.kCoinMoney)
    local level = gameData.getSimpleDataByKey("team_level")
    local limit_level = tonumber( findGlobal("altar_lottery_open_lv").data )
    if (CoinData.checkLackCoin(const.kCoinTeamLevel, limit_level, 0)) then
        return false
    end

    CardDefine.qInfo.type = trans.const.kAltarLotteryByMoney
    CardDefine.qInfo.times = times
    local useType = const.kAltarLotteryUseDefault
    --金币请求
    if times == 1 then
        CardDefine.qInfo.need = nor_one_cost 
        --用免费次数
        if __this.checkNormalFree() then
            __this.cardQ(trans.const.kAltarLotteryByMoney,times,const.kAltarLotteryUseFree)
            return false
        end
        
        --用道具
        local useItem = toS3UInt32( findGlobal("altar_lottery_money_onece_item_cost").data )
        if not CardData.getEnItem(useItem) then
            if (CoinData.checkLackCoin(const.kCoinMoney, nor_one_cost, 0)) then
                return false
            end
        else
            useType = const.kAltarLotteryUseItem
        end
    else
        CardDefine.qInfo.need = nor_ten_cost
        if (CoinData.checkLackCoin(const.kCoinMoney, nor_ten_cost, 0)) then
            return false
        end
    end

    __this.cardQ(trans.const.kAltarLotteryByMoney,times,useType)
    return true
end

function CardData.dimQ( times,dim_one_cost, dim_ten_cost)
    if CardData.qLock then
        Command.run("loading wait show", 'cardq')
        return false
    end

    local dim = CoinData.getCoinByCate(const.kCoinGold)
    local level = gameData.getSimpleDataByKey("team_level")
    local limit_level = tonumber( findGlobal("altar_lottery_open_lv").data )
    if (CoinData.checkLackCoin(const.kCoinTeamLevel, limit_level, 0)) then
        return false
    end

    if not CardData.isDimOpen()  then
        TipsMgr.showError("亲别急，先开荒副本吧")
        return false
    end

    local useType = const.kAltarLotteryUseDefault
    CardDefine.qInfo.type = const.kAltarLotteryByGold
    CardDefine.qInfo.times = times
    if times == 1 then
        CardDefine.qInfo.need = dim_one_cost
        local free = CardData.getDimCdLTime()
        if  free > 0 then
            local useItem = toS3UInt32( findGlobal("altar_lottery_gold_onece_item_cost").data )
            if not CardData.getEnItem(useItem) then
                if CoinData.checkLackCoin(const.kCoinGold, dim_one_cost, 0) then
                    return false
                end
            else
                useType = const.kAltarLotteryUseItem
            end
        else
            useType = const.kAltarLotteryUseFree
        end
    else
        CardDefine.qInfo.need = dim_ten_cost
        if (CoinData.checkLackCoin(const.kCoinGold, dim_ten_cost, 0)) then
            return false
        end
    end
    
    __this.cardQ(const.kAltarLotteryByGold,times,useType)
    return true
end

--trans.base.rand(0,n,fightSeed)

function CardData.secondToString( time  )
    local str = ""
    if(time < 0) then
        time = 0
    end
    
    local second = math.mod(time , 60)   
    local minute = math.floor( time / 60 )
    local hour =  math.floor( minute / 60 ) 
    local minute =math.mod(minute , 60) 
    
    if ( hour ~= 0 ) then
        if( hour < 10 ) then
            str = str .. "0" .. hour
        else 
            str =str .. hour
        end
        str = str ..":"
    end
    
    if(minute < 10) then
        str =str .. "0" .. minute
    else 
        str =str ..  "" .. minute
    end
    
    if( second < 10) then
        str = str .. ":0" .. second
    else 
        str =str ..  ":" .. second
    end
    
    return str
    
end

--{{{{{{{{{{{{{{{{{{{--------------------------------抽卡客户端模拟服务器数据-------------------------
local CANDICATE_ALL = 0 -- 所有
local CANDICATE_RARE = 1 -- 稀有物品
local CANDICATE_TEN = 2 -- 累计十次
function CardData.GetSeed( type , count)
    if info == nil then
        return nil
    end
    LogMgr.debug("card：client seed ---",info.money_seed_1,info.money_seed_10,info.gold_seed_1,info.gold_seed_10)
    local seed = {}
    if type == const.kAltarLotteryByMoney then
        if count == 1 then
            seed.value = info.money_seed_1
            return seed
        elseif count == 10 then
            seed.value = info.money_seed_10
            return seed
        end
    elseif type == const.kAltarLotteryByGold then
        if count == 1 then
            seed.value = info.gold_seed_1
            return seed
        elseif count == 10 then
            seed.value = info.gold_seed_10
            return seed
        end
    end
    return nil
end

function CardData.GetCandicates(user_lv, altar_type, candicate_type, is_first_cost_gold )
    local list = {}
    local all_list = GetDataList("Altar")
    for k,altar in pairs(all_list) do
        if altar.type == altar_type and altar.lv <= user_lv then
            local filterS = false
            if is_first_cost_gold then
                if altar.reward.objid == 10701 or altar.reward.objid == 10804 then -- 钻石的首抽，不允许抽到女刺客/ 小牛尊长
                    filterS = true
                end
            end

            local is_add = false
            if not filterS then
                if candicate_type == CANDICATE_RARE then
                    if altar.is_rare and altar.is_rare ~= 0 then
                        is_add = true
                    end
                elseif candicate_type == CANDICATE_TEN then
                    if altar.is_ten and altar.is_ten ~= 0 then
                        is_add = true
                    end
                elseif candicate_type == CANDICATE_ALL then
                    is_add = true
                end
            end

            if is_add then
                table.insert(list,altar)
            end
        end
    end
    return list
end

function CardData.RandomRewards( id_list, reward_list, extra_reward_list, user_lv, type, count, total_count,is_first_cost_gold)

    local candicate_list =CardData.GetCandicates(user_lv, type, CANDICATE_ALL, is_first_cost_gold)
    if( #candicate_list < count) then
    
        LogMgr.debug("抽卡系统：altar表数据有问题")
        return false
    end

    local seed = CardData.GetSeed( type, count)

    if(seed == nil or seed.value == nil) then
    
        LogMgr.debug("抽卡系统：种子有问题")
        return false
    end

    LogMgr.debug("抽卡：客户端最终使用种子 ---", seed.value )
    local selected_list = CardData.Random(candicate_list, count, seed)
    if #selected_list ~= count then
    
        LogMgr.debug("抽卡系统：生成数量出错")
        return false
    end

    local candicate_type = -1
    if(count == 1) then
        if(is_first_cost_gold) then-- 第一次消耗钻石的抽卡，必抽中稀有
            candicate_type = CANDICATE_RARE
        elseif (total_count % 10 == 0) then -- 每十次出必出的物品
            local has_ten = false
            for k,v in pairs(selected_list) do
                if( v.is_ten and v.is_ten ~= 0) then
                    has_ten = true
                    break
                end
            end
            if not has_ten then
                candicate_type = CANDICATE_TEN
            end
        end
    else
        -- 十次必出稀有
        local contains_rare = false
        for k,v in pairs(selected_list) do
            if v.is_rare and v.is_rare ~= 0 then
                contains_rare = true
                break
            end
        end
        if not contains_rare then 
            candicate_type = CANDICATE_RARE
        end
    end

    if(candicate_type >= 0) then
        local clist = CardData.GetCandicates(user_lv, type, candicate_type, is_first_cost_gold)
        local slist = CardData.Random(clist, 1, seed)
        if(#slist == 1) then
        
            selected_list[count] = slist[1]
        else
            return false
        end
    end

    -- 赋值返回数据
    for i = 1, #selected_list do
        local altar_data = selected_list[i]
        table.insert(id_list,altar_data.id)
        if(altar_data.reward.cate ~= const.kCoinSoldier) then -- 抽到物品
            table.insert(reward_list,altar_data.reward)
        else -- 抽到武将
        
            local soldier_data = findSoldier(altar_data.reward.objid)
            if soldier_data then
                if(  SoldierData.getSoldierBySId(altar_data.reward.objid) ) then
                
                    table.insert(reward_list,soldier_data.exist_give)
                else
                
                    -- 可能抽到几个现在没拥有的相同英雄
                    local pre_exist = false
                    for x=1,i - 1 do
                        if(selected_list[x].reward.objid == altar_data.reward.objid) then
                            pre_exist = true
                            break
                        end
                    end

                    if(pre_exist) then
                        table.insert(reward_list,soldier_data.exist_give)
                    else
                        table.insert(reward_list,altar_data.reward)
                    end
                end
            end
        end
        table.insert(extra_reward_list,altar_data.extra_reward)
    end

    return true
end

function CardData.Random( candicate_list,count, seed)
    local list = {}
    local total_probs = 0
    for i=1,#candicate_list do
        total_probs = total_probs + candicate_list[i].prob
    end

    for i=1,count do
        local ran_value = trans.base.rand(0,total_probs,seed)
        for j=1,#candicate_list do
            local data = candicate_list[j]
            if(ran_value <= data.prob) then
                table.insert(list,data)
                break
            else
                ran_value = ran_value - data.prob
            end
        end
    end
    return list
end


function CardData.Lottery( type, count, use_type)
    --检测祭坛是否已开放(略)
    --检测抽卡次数与类型(略)
    --检测钻石抽卡，玩家需通关第2个副本（略）
    local is_first_cost_gold = false --第一次消耗钻石

    -- 判断货币
    local first_soldier_id = 0
    local total_count      = 0
    local cost_coin ={} --S3UInt32
    local cost_item ={} --S3UInt32
    cost_item.cate = 0
    if(type == const.kAltarLotteryByMoney) then
        cost_coin.cate = const.kCoinMoney
        if(count == 1) then
        
            if(use_type == const.kAltarLotteryUseFree) then
            
                --服务重置、保存数据（时间记录）
            elseif(use_type == const.kAltarLotteryUseItem) then
            
                cost_item = toS3UInt32( findGlobal("altar_lottery_money_onece_item_cost").data )
            
            elseif(use_type == const.kAltarLotteryUseDefault) then
            
                cost_coin.val = tonumber( findGlobal("altar_lottery_money_onece_cost").data )
            
            end
            -- 总次数
            total_count = VarData.getVar("altar_lottery_money_count") + 1
            if(total_count == 1) then
                first_soldier_id = tonumber( findGlobal("altar_lottery_money_first_get").data )
            end
        else
            cost_coin.val = tonumber( findGlobal("altar_lottery_money_ten_cost").data )
        end
    elseif type == const.kAltarLotteryByGold  then
        cost_coin.cate = const.kCoinGold
        if(count == 1) then
        
            if(use_type == const.kAltarLotteryUseFree) then
            
                --服务重置、保存数据（时间记录）
            
            elseif(use_type == const.kAltarLotteryUseItem) then
            
                cost_item = toS3UInt32( findGlobal("altar_lottery_gold_onece_item_cost").data )
            
            elseif(use_type == const.kAltarLotteryUseDefault) then
            
                cost_coin.val = tonumber( findGlobal("altar_lottery_gold_onece_cost").data )
                if VarData.getVar("altar_lottery_first_cost_gold_time") == 0 then
                
                    is_first_cost_gold = true
                    --var::set(user, "altar_lottery_first_cost_gold_time", ts_now)
                end
            end
            

            -- 总次数
            total_count = VarData.getVar("altar_lottery_gold_count")+ 1
            if(total_count == 1) then
            
                first_soldier_id = tonumber( findGlobal("altar_lottery_gold_first_get").data )
                -- 特殊处理了，为了下一次必出英雄
                total_count = 9
                --var::set(user, "altar_lottery_gold_count", total_count)
            end
        
        else
        
            cost_coin.val = tonumber( findGlobal("altar_lottery_gold_ten_cost").data )

            if VarData.getVar("altar_lottery_first_ten_count_time") == 0 then
            
                is_first_cost_gold = true
                --var::set(user, "altar_lottery_first_ten_count_time", ts_now)
            end
        end
    end

    local PR= {}
    PR.id_list = {} --vector<uint32> 
    PR.reward_list = {} -- vector<S3UInt32> 
    PR.extra_reward_list = {} -- vector<S3UInt32>
    -- 第一次给武将
    if(first_soldier_id > 0) then
    
        PR.soldier_id = first_soldier_id
        return PR
        --soldier::Add(user, first_soldier_id, kPathAltar)
    else
        -- 随机物品
        local teamLevel = gameData.getSimpleDataByKey("team_level")
        local randomDataFlag = CardData.RandomRewards( PR.id_list, PR.reward_list, PR.extra_reward_list,
                                                      teamLevel, type, count, total_count, is_first_cost_gold)
        if not randomDataFlag then
            LogMgr.debug("客户端生成抽卡数据有问题")
            return nil
        end
        return PR
    end
end
----------------------------------抽卡客户端模拟服务器数据-------------------------}}}}}}}}}}}}}}}}}}}}}