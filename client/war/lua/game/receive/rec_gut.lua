--返回剧情
trans.call.PRGutInfo = function(msg)
    gameData.user.gut = msg.data
    
    EventMgr.dispatch( EventType.GutInfo, GutType.GutInfo )
end 