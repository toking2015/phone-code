StoreUntil = {}
StoreUntil.fy = 200
StoreUntil.fx = 20
StoreUntil.tiptime = 0.29
function StoreUntil.selectCoin(type,data)
   for key ,value in pairs(data) do
        if type == const.kCoinMoney then 
            value:loadTexture("storeui_coin1.png",ccui.TextureResType.plistType)
        elseif type == const.kCoinGold then 
            value:loadTexture("storeui_zhuanshi.png",ccui.TextureResType.plistType)
        elseif type == const.kCoinMedal then 
            value:loadTexture("storeui_xunzhanstore.png",ccui.TextureResType.plistType)
        elseif type == const.kCoinTomb then  -- 大墓地
            value:loadTexture("storeui_damudi.png",ccui.TextureResType.plistType)
        end 
   end
end 

function StoreUntil.getWindow()
    return PopMgr.getWindow("Store") 
end 

function StoreUntil.button(data)
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
        ActionMgr.save( 'UI', 'StoreUntil click down data')
        local flag = false 
        data.update = function(dt)
            time = time + dt 
            if time > 0.2 then 
                data.pressflag = true 
            end 
            if data.pressflag == true and flag == false then 
                local pos = data:getParent():convertToWorldSpace( cc.p(data:getPositionX(), data:getPositionY()) )
                if data.leixin == const.kCoinTotem then  --图腾
                    LogMgr.debug("出现tip1")
                    local gp = cc.p(pos.x+ 100,pos.y+150)
                    local jTotem = findTotem(data.coin)
                    TipsMgr.showTips(gp, TipsMgr.TYPE_TOTEM, jTotem)
                elseif data.leixin == const.kCoinGlyph then 
                    local gp = cc.p(pos.x+ 100,pos.y)
                    local jGlph = findTempleGlyph(data.coin)
                    TipsMgr.showTips(gp, TipsMgr.TYPE_RUNE, jGlph)
                elseif data.leixin == const.kCoinItem then 
                    local gp = cc.p(pos.x+ 100,pos.y)
                    local item = findItem(data.coin)
                    TipsMgr.showTips(gp, TipsMgr.TYPE_ITEM, item)
                elseif  data.leixin == const.kCoinMoney then   --金币
                    local gp = cc.p(pos.x+ 100,pos.y)
                    local item = {}
                    item.cate = 1
                    item.id = 0
                    item.val = data.count1 
                    data.tipsData = item
                    TipsMgr.showTips(gp, TipsMgr.TYPE_COIN, item)
                elseif  data.leixin == const.kCoinGold then   --钻石
                    local gp = cc.p(pos.x+ 100,pos.y)
                    local item = {}
                    item.cate = 3
                    item.id = 0
                    item.val = data.count1 
                    data.tipsData = item
                    TipsMgr.showTips(gp, TipsMgr.TYPE_COIN, item)
                elseif  data.leixin == const.kCoinWater then  --圣水
                    local gp = cc.p(pos.x+ 100,pos.y)
                    local item = {}
                    item.cate = 12
                    item.id = 0 
                    item.val = data.count1 
                    TipsMgr.showTips(gp, TipsMgr.TYPE_COIN, item)
                end 
                flag = true 
            end  
        end 
        TimerMgr.callPerFrame(data.update)
        time = 0 

        data:setLocalZOrder(100)
    end)
    data:addTouchCancel(function()
        ActionMgr.save( 'UI', 'StoreUntil click up data')
        data:setLocalZOrder(1)
        data.reset()
    end)
end