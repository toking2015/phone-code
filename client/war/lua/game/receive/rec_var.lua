trans.call.PRVarMap = function(msg)
    gameData.user.var_map[msg.var_map] = msg.var_map
    EventMgr.dispatch( EventType.UserVarUpdate )
end

trans.call.PRVarSet = function(msg)
    VarData.changeMapForVar( VarData.getVarData(), msg.var_key, msg.set_type, { value = msg.var_value, timelimit = msg.timelimit } )
    EventMgr.dispatch( EventType.UserVarUpdate ,msg.var_key)
end
