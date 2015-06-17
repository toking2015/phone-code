ReportPostData = {}
local time = 0 

-- 对谁禁言
function ReportPostData.sendReportMessage(target_id)
    local zdlevel = gameData.getSimpleDataByKey("team_level")
    if zdlevel >= 20 then 
       Command.run( 'Jubao', target_id)
    else 
       TipsMgr.showError("战队等级达到20级开放")
    end 
end 

-- 设置禁言时间
function ReportPostData.setTime(endtime)
    if endtime == nil then 
       time = 0 
    else 
       time = endtime  
    end 
end 

-- 获取时间
function ReportPostData.getTime()
    return time 
end 
