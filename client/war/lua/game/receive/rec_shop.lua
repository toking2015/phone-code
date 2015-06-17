--购买记录
trans.call.PRShopLog = function(msg)
   local log = msg.log
   StoreData.updateCount({log})
   EventMgr.dispatch(EventType.UpdataXZCount)
end

-- 购买记录（单独更新）
trans.call.PRShopLogSet = function(msg)
--    LogMgr.debug("dandugoumai")
--    LogMgr.debug(debug.dump(msg))
    local log = msg.log
    StoreData.updateCount({log})
    EventMgr.dispatch(EventType.UpdataXZCount)
end

-- 神秘商店商品列表
trans.call.PRShopMysteryGoods = function(msg)
    local log = msg.goods_list
--    LogMgr.debug("weihao_meiri")
--    LogMgr.debug(debug.dump(msg))
    StoreData.setDailyData(msg.goods_list)
    EventMgr.dispatch(EventType.UpdataXZCount)
end

-- 购买返回
trans.call.PRShopBuy = function(msg)
    if msg.status == 1 then 
       local value = findVendible(msg.id) 
       if value ~= nil and value.goods ~= nil and value.goods.cate == const.kCoinTotem then  --图腾
          TotemData.showTotemGet(value.goods.objid)
--          TipsMgr.showError("在邮箱领钻石后，可以去祭坛召唤，获得更好的英雄哦！")          
       end 
       StoreData.updateCount() 
    end 
    EventMgr.dispatch(EventType.UpdataXZCount) 
end 

