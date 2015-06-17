
-- 返回记录排行榜数据
trans.call.PRRankLoad = function(msg)
--   print(debug.dump(msg))
end

-- 返回指定id在排行榜中的位置
trans.call.PRRankIndex = function(msg)
--    print(debug.dump(msg))
    RankData.setRankUs(msg)
end

-- 返回排行榜列表
trans.call.PRRankList = function(msg)
    RankData.setRankList(msg.list)
--    print(debug.dump(msg))
    Command.run("loading wait hide","rankui")
end

trans.call.PRRankClearData = function(msg)
--    print(debug.dump(msg))
end
