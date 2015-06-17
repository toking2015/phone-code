local __this = VarData or {}
VarData = __this

function __this.getVarData()
    local map = gameData.user.var_map
    if not map then
        map = {}
        gameData.user.var_map = map
    end
    return map
end

function __this.changeMapForVar( map, key, set_type, data )
    if set_type == trans.const.kObjectUpdate then
        map[ key ] = data
    elseif  set_type == trans.const.kObjectAdd then
        map[ key ] = data
    elseif set_type == trans.const.kObjectDel then
        map[ key ] = nil
    end
end

function __this.getVar( key )
    local val = __this.getVarData()[ key ]
    if val ~= nil then
        return val.value
    end
    
    return 0
end

function __this.setVar( key, value, timelimit )
    if timelimit == nil then
        timelimit = 0
    end
    
    --先保存到本地, 然后再发送修改命令
    __this.getVarData()[ key ] = { value = value, timelimit = timelimit }
    Command.run( 'var set', key, value, timelimit )
end
