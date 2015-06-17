require("lua/utils/base")
ChatAddCommon = {} 

function ChatAddCommon.setChatTouch(data)
    ChatCommon.initBtn(data,false)
    data.pressflag = false
    local time = 0 
    data.update = nil 
    data.reset = function()
        if data.update ~= nil then 
            TimerMgr.killPerFrame( data.update)
            data.update = nil
        end 
        time = 0 
        data.pressflag = false 
    end 
    data:addTouchBegan(function() 
        ActionMgr.save( 'UI', 'ChatAddCommon click down data' ) 
        local flag = false 
        local havetip = true 
        if data:isVisible() == false then 
           return 
        end 
        data.update = function(dt)
            time = time + dt 
            if time > 0.2 then 
                if havetip == true then 
                   data.pressflag = true 
                end 
            end 
            if data.pressflag == true and flag == false then 
                local pos = data:getParent():convertToWorldSpace( cc.p(data:getPositionX(), data:getPositionY()) )    
                if data.leixin == ChatAddData.ZHUAN then  --装备
                    EquipmentData:showEquipmentTips( data, data.data )
                elseif  data.leixin == ChatAddData.DIAO then  --雕文

                elseif  data.leixin == ChatAddData.TU then  --图腾
                    local target_id = gameData.id 
                    local totem_id =  data.data.guid
                    Command.run( 'chattotem' ,target_id,totem_id)
                elseif  data.leixin == ChatAddData.YING then  --英雄
                    local target_id = gameData.id 
                    local soldier_guid =  data.data.guid
                    Command.run( 'chatsoldier' , target_id ,soldier_guid) 
                elseif  data.leixin == ChatAddData.WU then  --物品
                    local gp = cc.p(pos.x,pos.y)
                    local item = findItem(data.data.item_id)
                    TipsMgr.showTips(gp, TipsMgr.TYPE_ITEM, item)
                end 
                flag = true 
            end 
        end 
        TimerMgr.callPerFrame(data.update)
    end)
    data:addTouchCancel(function()
        ActionMgr.save( 'UI', 'ChatAddCommon click up data' ) 
        data:setLocalZOrder(1)
        data.reset()
    end)
    
    data:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ChatAddCommon click up data' )
        if data.pressflag == false then
            if data ~= nil and data.data ~= nil then 
                if  data.leixin == ChatAddData.TU then  --图腾
                    data.data.leixin = data.leixin
                    local target_id = gameData.id 
                    local totem_id =  data.data.guid
                    local t_data = {target_id = target_id , totem_id = totem_id ,id = data.data.id,level = data.data.level ,leixin = data.data.leixin }
                    local jsonstr = table2json( t_data )
                    Command.run( 'chatother',jsonstr)
                elseif  data.leixin == ChatAddData.YING then  --英雄
                    data.data.leixin = data.leixin
                    local target_id = gameData.id 
                    local soldier_guid =  data.data.guid
                    local t_data = {target_id = target_id , soldier_guid = soldier_guid ,id = data.data.soldier_id,quality = data.data.quality ,leixin = data.data.leixin }
                    local jsonstr = table2json( t_data )
                    Command.run( 'chatother',jsonstr)
                elseif  data.leixin == ChatAddData.YING then  --英雄
                
                elseif data.leixin == ChatAddData.TAO then   -- 套装
                
                else 
                    data.data.leixin = data.leixin
                    local jsonstr = table2json( data.data )
                    Command.run( 'chatother',jsonstr)
                end 

            end 
            
        end 
        data.reset()
    end)
end 


