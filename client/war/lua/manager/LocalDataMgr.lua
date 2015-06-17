LocalDataMgr = LocalDataMgr or {}

local function path_to_name( id, path, suffix )
    path = string.lower( path )
    path = string.gsub( path, "/", "-" )
    
    if id == 0 then
        path = "local/sys-" .. path .. "." .. suffix
    else
        path = "local/usr-" .. id .. "-" .. path .. "." .. suffix
    end
    
    return path
end

function LocalDataMgr.load_string( id, path )
    local name = path_to_name( id, path, 'string' )
    local path = WRITE_PATH .. name 
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return nil
    end
    local stream = seq.read_stream_file( path )
    local object = seq.stream_to_object( 'SLocalData', stream )

    return object.data
end

function LocalDataMgr.save_string( id, path, data )
    local name = path_to_name( id, path, 'string' )
    
    local object = seq.object_to_stream( 'SLocalData', { data = data } )
    seq.write_stream_file( name, object )
end
