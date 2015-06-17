StoreTip = {}
local prepath = "image/ui/StoreUI/"
--StoreTip.getstr(CoinType.xunzhan)
--StoreTip.getstr(CoinType.jinbi)
--StoreTip.getstr(CoinType.zhuanshi)
function StoreTip.getstr(type)
   
    local str = "[image=tip.png][br][image=xunzhan.png][font=ZH_3]  勋章[font=ZH_5]不足,是否前往"
    if type == CoinType.xunzhan then
        TipsMgr.showError(CoinData.getCoinName(type)..'不足，打竞技场即可获取')
--        str = "[image=tip.png][br][image=xunzhan.png][font=ZH_3]  勋章[font=ZH_5]不足,是否前往"
    elseif stype == CoinType.jinbi then 
        TipsMgr.showError('金币不足')
--        str = "[image=tip.png][br][image=coin.png][font=ZH_3]  金币[font=ZH_5]不足,是否前往"
    elseif type == CoinType.zhuanshi then 
        TipsMgr.showError('钻石不足')
    elseif type == CoinType.mudi then 
        TipsMgr.showError(CoinData.getCoinName(type)..'不足，打大墓地即可获取')
--        str = "[image=tip.png][br][image=diamond.png][font=ZH_3]  钻石[font=ZH_5]不足,是否前往"
    end 
--    showMsgBox(str, confirmHandler)
    return str

end 

function StoreTip.getArenastr()
    local str = "[image=tip.png][br][image=team.png][font=ZH_3]  竞技场胜利次数不足是否前往"
    return str
end 

function StoreTip.showTip(data1)
   local data ={ name = "abc" ,level = 12 , count = 13}
   if data1 ~= nil then 
      if data1.name ~= nil and data1.level ~=nil and data1.count ~= nil then 
         data.name = data1.name
         data.level = data1.level 
         data.count = data1.count    
      end 
   end 
   local str = "[font=ZH_1]   物品名" .. data.name .."[br]"
   str = str .. "[font=ZH_1]   物品等级" .. data.level .. "[br]"
   str = str .. "[font=ZH_1]   物品数量" .. data.count 
   LogMgr.debug("str .. " .. str )
   local url1 = prepath .. "ThingTipUI_1.ExportJson"
   local node = getLayout(url1)
   RichText:addMultiLine(str, prepath, node.vector)

   return node
   
end 