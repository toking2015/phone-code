trans.call.PRStarData = function(msg)
    gameData.user.star = msg.data
    
    EventMgr.dispatch( EventType.UserStarUpdate )
end