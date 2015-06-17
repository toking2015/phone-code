trans.call.PRCoinData = function(msg)
    gameData.user.coin = msg.data

    EventMgr.dispatch( EventType.UserCoinUpdate )
end
