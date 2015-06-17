--by weihao
-- 竞技场

-- 获取基本信息
Command.bind( 'arenainfo', 
    function()
        trans.send_msg( 'PQSingleArenaInfo', {})
    end 
)
-- 刷新对手
Command.bind( 'arenarefresh', 
    function()
        trans.send_msg( 'PQSingleArenaRefresh',{})
    end 
)
-- 清空挑战CD
Command.bind( 'arenaclear', 
    function()
        trans.send_msg( 'PQSingleArenaClearCD',{})
    end 
)

-- 增加挑战次数
Command.bind( 'arenaaddtimes', 
    function()
        trans.send_msg( 'PQSingleArenaAddTimes',{})
    end 
)
-- 申请最近的竞技log
Command.bind( 'arenalog', 
    function()
        trans.send_msg( 'PQSingleArenaLog',{})
    end 
)
-- 申请排行榜数据
Command.bind( 'arenarank', 
    function(index1,count1)
        trans.send_msg( 'PQSingleArenaRank', {index = index1, count = count1})
    end 
)

--用户竞技场panel数据
Command.bind("arenauserpanel", function(target_id) 
   trans.send_msg("PQUserSingleArenaPanel", {target_id=target_id})
end)

--申请用户排名
Command.bind("arenamyrank", function() 
    trans.send_msg("PQSingleArenaMyRank", {})
end)

--申请真人布阵
Command.bind("arenarealrole", function() 
    trans.send_msg("PQUserSingleArenaPre", {})
end)

--申请cd时间
Command.bind("arenacdtime", function() 
    trans.send_msg("PQSingleArenaReplyCD", {})
end)

Command.bind("arena get first reward", function() 
    trans.send_msg("PQSingleArenaGetFirstReward", {})
end)

