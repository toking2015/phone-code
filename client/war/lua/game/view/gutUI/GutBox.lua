GutBox = {}

function GutBox:runBox(value)
    if value ~= nil then
        local function onPlayComplete()
            local function callBack()
                local reward = findReward( value.box )
                if reward then
                    -- showGetEffect(reward.coins, {const.kCoinMoney,const.kCoinStrength,const.kCoinWater, const.kCoinGold, const.kCoinItem} )
                    -- TipsMgr.showItemObtained( reward.coins )
                end
                EventMgr.dispatch( EventType.endGutBox, value )
            end

            if not GutBox:showTotmeGet( value.box, callBack ) then
                callBack()
            end
        end        
        showPrizeBox(PopMgr.getWindow( 'GutUI' ), onPlayComplete )
    end
end

function GutBox:runReward( value )
    if value ~= nil then
        local function callBack()
            local reward = findReward( value.reward )
            if reward then
                TipsMgr.showGetEffect(reward.coins, {const.kCoinMoney,const.kCoinStrength,const.kCoinWater, const.kCoinGold, const.kCoinItem} )
            end            
            EventMgr.dispatch( EventType.endGutReward, value )
        end   
        if not GutBox:showTotmeGet( value.reward, callBack ) then
            showReward( PopMgr.getWindow( 'GutUI' ), callBack )
        end
    end
end

function GutBox:showTotmeGet( value, callBackFun )
    local reward = findReward( value )
    if reward ~= nil then
        for k,v in pairs(reward.coins) do
            if v.cate == const.kCoinTotem then
                local function callBack()
                    if callBackFun~= nil then
                        callBackFun()
                    end
                end
                TotemData.showTotemGet( v.objid, callBack )  
                return true
            end
        end
    end
    return false
end
                