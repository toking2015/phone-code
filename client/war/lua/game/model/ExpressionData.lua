ExpressionData ={} 
-- 注意富文本前面必须有字体 如"[font=JJ_6]" 
-- [exp=WX] 表情微笑
ExpressionData.isload = false 
local list ={
        ["AM"] = "5",      --傲慢  
        ["BIZ"] = "11",    --闭嘴
        ["BS"] = "2",      --鄙视
        ["BY"] = "9",      --白眼
        ["BZ"] = "3",      --瘪嘴
        ["CH"] = "29",     --擦汗
        ["DB"] = "17",     --大兵
        ["DK"] = "10",     --大哭
        ["DY"] = "7",      --得意
        ["FD"] = "6",      --发呆
        ["FENGD"] = "2",   --奋斗
        ["GG"] = "14",     --尴尬
        ["GZ"] = "26",     --鼓掌
        ["HANX"] = "7",    --憨笑
        ["HUAIX"] = "4",   --坏笑
        ["HX"] = "16",     --害羞
        ["JX"] = "11",    --奸笑
        ["JE"] = "9",      --饥饿
        ["JK"] = "17",     --惊恐
        ["JY"] = "8",      --惊讶
        ["KA"] = "5",      --可爱
        ["KEL"] = "4",     --可怜
        ["KKL"] = "12",    --快哭了
        ["KL"] = "1",      --骷髅
        ["KB"] = "14",     --抠鼻
        ["KU"] = "2",      --酷
        ["KUN"] = "6",     --困
        ["KZ"] = "17",     --狂抓
        ["LH"] = "10",     --冷汗
        ["LIUH"] = "7",    --流汗
        ["LL"] = "10",     --流泪
        ["NG"] = "4",      --难过
        ["QD"] = "3" ,     --敲打
        ["QDL"] = "17",    --糗大了
        ["QQ"] = "2",      --亲亲
        ["QY"] = "2",      --呲牙
        ["SE"] = "4",      --色
        ["SHUAI"] = "4",   -- 衰
        ["SJ"] = "9",      --睡觉
        ["TP"] = "7",     --调皮
        ["TU"] = "17",     --吐
        ["TX"] = "2",      --偷笑
        ["WX"] = "4",      --微笑
        ["XU"] = "10",     --嘘
        ["YUN"] = "7",     --晕
        ["YW"] = "14",     --疑问
        ["ZJ"] = "2",      --再见
        ["ZM"] = "21"     --咒骂
}

local list1 ={
    [1] = "AM",      --傲慢  
    [2] = "BIZ",    --闭嘴
    [3] = "BS",      --鄙视
    [4] = "BY",      --白眼
    [5] = "BZ",      --瘪嘴
    [6] = "CH",     --擦汗
    [7] = "DB",     --大兵
    [8] = "DK",     --大哭
    [9] = "DY",      --得意
    [10] = "FD",      --发呆
    [11] = "FENGD",   --奋斗
    [12] = "GG",     --尴尬
    [13] = "GZ",     --鼓掌
    [14] = "HANX",    --憨笑
    [15] = "HUAIX",   --坏笑
    [16] = "HX",     --害羞
    [17] = "JX",    --奸笑
    [18] = "JE",      --饥饿
    [19] = "JK",     --惊恐
    [20] = "JY",      --惊讶
    [21] = "KA",      --可爱
    [22] = "KEL",     --可怜
    [23] = "KKL",    --快哭了
    [24] = "KL",      --骷髅
    [25] = "KB",     --抠鼻
    [26] = "KU",      --酷
    [27] = "KUN",     --困
    [28] = "KZ",     --狂抓
    [29] = "LH",     --冷汗
    [30] = "LIUH",    --流汗
    [31] = "LL",     --流泪
    [32] = "NG",      --难过
    [33] = "QD" ,     --敲打
    [34] = "QDL",    --糗大了
    [35] = "QQ",      --亲亲
    [36] = "QY",      --呲牙
    [37] = "SE",      --色
    [38] = "SHUAI",   -- 衰
    [39] = "SJ",      --睡觉
    [40] = "TP",     --调皮
    [41] = "TU",     --吐
    [42] = "TX",      --偷笑
    [43] = "WX",      --微笑
    [44] = "XU",     --嘘
    [45] = "YUN",     --晕
    [46] = "YW",     --疑问
    [47] = "ZJ",      --再见
    [48] = "ZM"     --咒骂
}
local list2 = {}
for i = 1 ,#list1 do
    table.insert(list2,"#" .. i .. " ")
end 

function ExpressionData.getShowList()
   return  list2
end 

function ExpressionData.getValuebyKey(key)
   return list1[key]
end 

-- 转化字符
function ExpressionData.changeString(data,beforefnt)
    local str = "" 
    str = data 
    local num = 1 
    local str2 = ""
    local str3 = data

    for i = 1 ,48 do
        local s = "#" .. i .. " "
        str = string.gsub(str, s ,"[exp=" .. list1[i]..  "]" ) 
    end   

    return str 
    
end 

function ExpressionData.getList()
    return list
end 

function ExpressionData.getNum(key)
   if list[key] ~= nil then 
      return list[key]
   end
   return nil  
end 