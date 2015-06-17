RankData = {} 
RankData.index = 1 -- 第一个排名
local typecount = 8 
RankData.type = const.kRankingTypeTeamLevel -- 申请类型
RankData.time = const.kRankAttrReal  -- 哪个时间段
local ranklist = {} --实时排名
local myrank = {} -- 自己的排名
local myflag = false  --我排名的flag
local listflag = false  --list排名的flag
for i = 1 , typecount do 
    ranklist[i] = {}
    myrank[i] = {}
    for j = 1 , 2 do
        ranklist[i][j] = {}
        myrank[i][j] = {}
    end 
end 
function RankData.getTypeCount()
   return typecount
end 

function RankData.setTypeCount(count)
    typecount = count
end 

function RankData.setRankUs(msg)
    myrank[RankData.index][RankData.time] = msg 
    myflag = true 
    if listflag == true  then 
        if PopMgr.getIsShow("RankUI") then 
            EventMgr.dispatch(EventType.RankList )
        end 
        myflag = false  --我排名的flag
        listflag = false  
    end
end 

function RankData.getRankUs()
    return  myrank[RankData.index][RankData.time]
end 

function RankData.setRankList(msg)
   ranklist[RankData.index][RankData.time] = msg 
   listflag = true 
   if myflag == true  then 
       if PopMgr.getIsShow("RankUI") then 
          EventMgr.dispatch(EventType.RankList )
       end  
       myflag = false  --我排名的flag
       listflag = false  
   end 
end 

function RankData.getRankList()
   return ranklist[RankData.index][RankData.time]
end 

function RankData.sendRankList(flag)
    if flag == nil then 
       if ranklist[RankData.index][RankData.time] == nil or #ranklist[RankData.index][RankData.time] == 0 then  
           Command.run( 'ranklisttype', nil ,RankData.type ,RankData.time,0,50)
           Command.run("loading wait show","rankui")
           RankData.sendRankUs()
       else 
            if PopMgr.getIsShow("RankUI") then 
                EventMgr.dispatch(EventType.RankList )
            end 
       end
    else 
        RankData.sendRankUs()
        Command.run( 'ranklisttype', nil ,RankData.type ,RankData.time,0,50)
        Command.run("loading wait show","rankui")
    end 
end 

function RankData.sendRankUs()
    Command.run( 'rankindex', nil,RankData.type,RankData.time,gameData.id)
end 