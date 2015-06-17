PaomaData = {} 
local pd_data = {}
--pd_data = {{flag = const.kPlacardFlagScene,order = 0 , text = "[font=GG_NAME]玩家名字[font=GG_NORMAL] 将 [font=GG_WHITE] 英雄名字[font=GG_NORMAL] 升到了 [font=GG_WHITE]3星！松岛枫减肥的身份" },
--    {flag = const.kPlacardFlagScene,order = 0 , text = "[font=GG_NAME]#17 玩家名字[font=GG_NORMAL] 将 [font=GG_GREEN] 英雄名字[font=GG_NORMAL] 升到了 [font=GG_GREEN]3星！松岛枫减肥的身份京津冀" },
--    {flag = const.kPlacardFlagScene,order = 0 , text = "[font=GG_NAME]玩家名字[font=GG_NORMAL] 将 [font=GG_BLUE] 英雄名字[font=GG_NORMAL] 升到了 [font=GG_BLUE]3星！松岛枫减" },
--    {flag = const.kPlacardFlagScene,order = 0 , text = "[font=GG_NAME]玩家名字[font=GG_NORMAL] 将 [font=GG_PURPLE] 英雄名字[font=GG_NORMAL] 升到了 [font=GG_PURPLE]3星！松岛枫减肥的身份" },
--    {flag = const.kPlacardFlagScene,order = 0 , text = "[font=GG_NAME]玩家名字[font=GG_NORMAL] 将 [font=GG_YELLOW] 英雄名字[font=GG_NORMAL] 升到了 [font=GG_YELLOW]3星！松岛枫减肥的京津冀" }
--}
local showview = {}
function PaomaData.receiveData(data)
   local text = string.split(data.text , "]")
   data.text = "[font=GG_NAME]" .. data.text
   if text[2] == nil or text[2] == "" then 
       data.text = ExpressionData.changeString(data.text,"[font=GG_NAME]")
   else 
       data.text = ExpressionData.changeString(data.text)
   end 
   -- 得知道表情前面的字体 然后再表情后面继续加那种字体
   if data.order == 0 then 
        data.text = "[font=GG_NAME]" .. data.text
        table.insert(pd_data,data)
   elseif data.order > 0 then 
        data.text = "[font=GG_NAME]" .. data.text
        if showview == nil or #showview == 0 then 
            table.insert(pd_data,1,data)
        else 
            table.insert(pd_data,2,data)
        end 
   end 
   if showview == nil or #showview == 0 then 
      PaomaData.setShowData()
   end 
end 

function PaomaData.setShowData()
   showview = {}
   if pd_data ~= nil then 
      if pd_data[1] ~= nil then 
         table.insert(showview,pd_data[1])
      end
   end 
end 

function PaomaData.getData()
    return showview 
end 

function PaomaData.repeatData()
   table.insert(pd_data,1,pd_data[1])
end 

function PaomaData.reduceData()
   table.remove(pd_data,1)
end 