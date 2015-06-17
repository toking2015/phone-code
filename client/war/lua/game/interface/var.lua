Command.bind( 'var set', function( key, value, timelimit )
    if key == nil or key == '' then
        return
    end 
    
    local set_type = const.kObjectUpdate
    if value == 0 or value == '0' then
        set_type = const.kObjectDel
    end
    
    if type( timelimit ) ~= 'number' then
        timelimit = 0
    end
    
    trans.send_msg( 'PQVarSet', { set_type = set_type, var_key = key, var_value = value, timelimit = timelimit } )
end )