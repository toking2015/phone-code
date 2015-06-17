--解析JSON文件,返回的是LUA表结构
tableJsonList = {}
function roadDataFromJson(fileName)
    --先判断是否存在
    if nil ~= tableJsonList[fileName] then
        return tableJsonList[fileName]
    end
    --读取文件内容
    local dataTable = loadJsonFromFile(fileName)
    if dataTable == nil then 
        LogMgr.log( 'error', "+++++roadDataFromJson function error+++++ fail to get data from json")
    end
    --tableJsonList[fileName] = dataTable.Array 
    LogMgr.log( 'json', "+++++++++++++++" .. fileName .. " load")
    return dataTable.Array
end

function loadJsonFromFile(fileName)
    local fileFullName
    local fileData
    if nil == g_filePath then
        --server client
        fileFullName = cc.FileUtils:getInstance():fullPathForFilename(fileName)
        
        fileData = cc.FileUtils:getInstance():getStringFromFile( fileFullName )
        if fileData == '' then
            LogMgr.log( 'error', 'loadJsonFromFile null string: ' .. fileFullName .. '\n' )
            return nil
        end
    else
        --client server
        fileFullName = g_filePath .. fileName
        
        local file = io.open(fileFullName, "r")
        fileData = file:read("*a")
        file:close()
    end
    local dataTable = Json.decode(fileData)
    return dataTable
end
