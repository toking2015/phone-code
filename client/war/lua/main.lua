local function lua_main()

local function exit_game(msg, title)
    print(msg, title)
    system.msgbox(msg, title or "提示")
    local timer_id
    local function realExit()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer_id)
        --延迟一点
        cc.Director:getInstance():endToLua()
    end
    timer_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(realExit, 3, false)
end

--这里接口初始化要在热更前, 因为部分平台可能在热更前进行安装包强更
inf.init(function(msg)
    print( 'inf.init: ' .. msg .. '\n' )

    if msg == 'succeed' then
        return
    end
    
    exit_game( '初始化错误, 请与客服联系' )
end)
inf.init = nil

--初始化随机数种子，其他地方就不需要再次初始化了
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

--加载基础库
Json = require("cjson")
require('lua/utils/http')
require("lua/utils/URLLoader.lua")
require("lua/preload/PreLoadUtils.lua")

--安全模式解析json，解析失败返回nil
function safeDecodeJson(data)
    local json = nil
    local function decodeJson()
        json = Json.decode(data)
    end
    pcall(decodeJson)
    return json
end

local new_device = false

--获取设备基本信息
local device_code = seq.stream_to_string( seq.read_stream_file( cc.FileUtils:getInstance():getWritablePath() .. 'device_code' ) )
local commit_step = seq.stream_to_string( seq.read_stream_file( cc.FileUtils:getInstance():getWritablePath() .. 'commit_step' ) )
if device_code == nil or device_code == '' then
    new_device = true
    
    --生成并记录设备编码
    local info = system.device_info()
    device_code = info.device_code or ( os.time() * 1000 ) + ( os.clock() * 1000 ) .. ''
    seq.write_stream_file( 'device_code', seq.string_to_stream( device_code ) )
end
if commit_step == nil or commit_step == '' then
    commit_step = 0
else
    commit_step = tonumber( commit_step, 10 )
end
print( 'device_code: ' .. device_code .. '\n' )

local update_index = -1     --更新版本索引
local local_index = -1      --原始版本索引
local version_list = nil    --版本列表
local update_version = ''   --正在更新的版本
local local_config = nil    --原始配置
local update_config = nil   --更新配置
local isLogoDone = false    --Logo播放完成
local versionData = nil     --版本数据
local server_list = nil     --服务器列表
local is_updated = nil      --是否更新完成
local local_core = 1        --内核版本号

local platform_config = nil --平台配置

--新设备提交设备信息
local function commit_device_info()
    if not new_device then
        return
    end

    --获取设备基本信息
    local device_info = system.device_info()

    --提交设备信息
    local url = 'http://' .. update_config.host .. '/device_info_log.php?'
    local commit_key = { 'device_name', 'device_os_ver', 'device_net_info' }
    for key, var in ipairs( commit_key ) do
        url = url .. var .. '=' .. http.encodeURI( device_info[var] ) .. '&'
    end
    url = url .. 'device_code=' .. http.encodeURI( device_code ) .. '&app_core=' .. local_core

    URLLoader.new( url )
end

--加载记录提交
function commit_device_log( step )
    if step <= commit_step then
        return
    end

    commit_step = step
    seq.write_stream_file( 'commit_step', seq.string_to_stream( commit_step .. '' ) )

    local url = 'http://' .. update_config.host .. '/device_loading_log.php?device_code=' .. device_code .. '&step=' .. step  
    URLLoader.new( url )
end

--报错记录提交
function commit_error_log( content )
    local url = 'http://' .. update_config.host .. '/device_error_log.php?version=' .. http.encodeURI( update_config.version ) .. '&content=' .. http.encodeURI( content )
    URLLoader.new( url )
end

local function clear_update_resource()
    --清除可能存在的文件夹
    writable.unlink( 'res' )
    --writable.unlink( 'packet' )
end
local function enter_game()
    commit_device_log(11)
    
    PreLoadUtils.removeArmatureInfo("preload") --释放preload相关资源
    require("lua/utils/Config.lua")
    Config.init( update_config or local_config )
    Config.platform = platform_config
    require("lua/preload/VXinYouMgr.lua")
    if new_device then
        VXinYouMgr.ad_active()
    end
    require("lua/init.lua")
end

--加载配置文件
local function load_json( name )
    local filename = cc.FileUtils:getInstance():fullPathForFilename( name )
    if filename == nil or filename == '' then
        return nil
    end

    local stream = seq.read_stream_file( filename )
    if stream == nil or stream == '' then
        return nil
    end

    local data = seq.stream_to_string( stream )
    if data == nil or data == '' then
        return nil
    end

    return Json.decode( data )
end

local function uncompress_packet( file_name, version_name )
    --解压更新包到  res
    if zlib.uncompress_files( file_name, "res/" ) ~= true then
        writable.unlink( file_name )
        print( "version error: " .. version_name .. "\n" )
        exit_game("版本更新错误: " .. version_name)
        return ''
    end

    print( "version update: " .. version_name .. "\n" )

    --删除更新包
    writable.unlink( file_name )

    --重新加载配置( 有可能解压后能获得最新配置文件 )
    update_config = load_json( 'local_config.json' )

    --删除基于可写目录的配置文件
    writable.unlink( 'res/local_config.json' )

    --转换二进制文件
    local stream = seq.string_to_stream( Json.encode( update_config ) )

    --输出文件
    seq.write_stream_file( 'res/update_config.json', stream )
    
    return update_config.version
end

--搜索版本序号
local function search_version_index( ver )
    for key, var in ipairs(version_list) do        
        if var == ver then
            return key
        end
    end

    return -1
end

local function doInit(isServerList)
    commit_device_log(10)
    
    if isServerList then
        server_list = true
    else
        is_updated = true
    end
    if server_list and is_updated then
        server_list = nil
        is_updated = nil
        local timer_id
        local function realInit()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer_id)
            
            local file_name = 'packet/local.dat' 
            if cc.FileUtils:getInstance():isFileExist( cc.FileUtils:getInstance():getWritablePath() .. file_name ) then
                uncompress_packet( file_name, "local" )
            end
            
            --延迟一点
            enter_game()
        end
        timer_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(realInit, 0.5, false)
    end
end

local function lua_string_split(str, split_char)    
    local sub_str_tab = {};
    
    while (true) do        
        local pos = string.find(str, split_char);  
        if (not pos) then            
            local size_t = table.getn(sub_str_tab)
            
            if str ~= '' then
                table.insert(sub_str_tab,size_t+1,str);
            end
            break;  
        end
        
        local sub_str = string.sub(str, 1, pos - 1);              
        local size_t = table.getn(sub_str_tab)
        table.insert(sub_str_tab,size_t+1,sub_str);
        local t = string.len(str);
        str = string.sub(str, pos + 1, t);   
    end
    
    return sub_str_tab;
end

local function auto_update()
    --最新版本
    if update_index >= #version_list then
        doInit()
        return
    end
    
    --取得下个版本的版本号
    update_index = update_index + 1
    update_version = version_list[ update_index ]

    local function loadUpdateProgress(cur_size, max_size)
        --加载过程, 应该用  cur_size / max_size 进行进度条显示 
        local ui = PreLoadUI:getInstance()
        if ui then
            ui:setPercent(cur_size, max_size)
        end
        if cur_size ~= max_size then
            return
        end
    end
    
    local function loadUpdateComplete( data )
        commit_device_log(8)
        
        --更新包路径
        local filename = 'packet/' .. update_version
        
        --保存更新包
        seq.write_stream_file( filename, data )
        
        local new_version = uncompress_packet( filename, update_version )
        if not new_version or new_version == '' then
            return
        end
        
        local new_index = search_version_index( new_version )
        if new_index < 1 then
            return
        end
        
        --重置版本号和索引
        update_index = new_index
        update_version = new_version

        commit_device_log(9)
        
        --循环升级下一个版本    
        auto_update()
    end
    local function loadUpdateError()
        exit_game("加载更新数据失败！")
    end
    --请求版本资源, 这里应该显示加载进度条
    local zipUrl = string.format("http://%s/%s/%s", update_config.resource, update_config.group, update_version)
    local zipUrl2 = string.format("http://%s/%s/%s", update_config.resource2, update_config.group, update_version)
    URLLoader.new(zipUrl, loadUpdateComplete, loadUpdateProgress, loadUpdateError, nil, nil, zipUrl2)
    
    commit_device_log(7)
end

local function checkVersionData()
    if not versionData or not isLogoDone then
        return
    end
    local data = versionData
    versionData = nil
    isLogoDone = nil
    --加载版本数据失败, 直接进入登录页
    if data == '' then
        doInit()
        return
    end
    
    version_list = lua_string_split( data, "\n" )
    
    --版本数据为空, 直接进入登录页
    if #version_list <= 0 then
        doInit()
        return
    end

    local_index = search_version_index(local_config.version)
    update_index = search_version_index(update_config.version)
    
    --不应该出现的版本索引错误, 这里应该建议重新下载app, 或清理可写目录
    if update_index <= 0 then
        -- doInit()
        exit_game("加载更新失败，如果多次出现，请重新下载APP")
        return
    end
    
    --如果原始版本号比更新版本号高即清除配置
    if local_index > update_index then
        clear_update_resource()
        
        update_config = local_config
        update_index = local_index
    end
    
    --开始自动更新, 应该进入loading页
    auto_update()
end

local function onVersionData( data, cur_size, max_size )
    --加载过程
    if cur_size ~= max_size then
        return
    end
    data = seq.stream_to_string( data )
    versionData = data
    checkVersionData()
end

local function onLogoComplete()
    commit_device_log(5)
    
    isLogoDone = true
    checkVersionData()
    
    commit_device_log(6)
end

--容错删除资源路径下的 local_config.json
writable.unlink( 'res/local_config.json' )

--加载配置
local_config    = load_json( 'local_config.json' )      --原始安装版配置
update_config   = load_json( 'update_config.json' )     --更新后使用配置

platform_config = load_json( 'platform_config.json' )   --平台配置

--更新配置不存在或版本号一致即清除资源本使用原始配置
if update_config == nil or local_config.version == update_config.version then
    clear_update_resource()

    update_config = local_config
end

--设置本地内核版本号
local_core = local_config.core

--提交首个记录
commit_device_log(1)

--提交设备信息
commit_device_info()

commit_device_log(2)

print( "\nversion local: " .. update_config.version .. "\n" )

local function onServerListData(data)
    seq.write_stream_file( 'res/server_list.json', data )
    doInit(true)
end

local function onVersionDataError()
    exit_game("获取版本更新信息失败！")
end
local function onServerListDataError()
    exit_game("获取服务器列表失败！")
end
local noticeContent = ""
--请求公告信息
local function onNoticeComplete(content)
    content = seq.stream_to_string( content )
    --设置公告
    noticeContent = content
end
URLLoader.new( string.format("http://%s/platform/%s/notice.txt", update_config.resource, platform_config.name), onNoticeComplete)
function getNoticeContent( ... )
    return noticeContent
end

local function onCoreData( data, cur_size, max_size )
    --加载过程
    if cur_size ~= max_size then
        return
    end
    
    local new_core = tonumber( seq.stream_to_string( data ), 10 )
    if local_core < new_core then
        exit_game("请从官网重新下载App")
        return
    end

    --加载版本列表, 这里一般很快， 不用显示
    local versionUrl = string.format("http://%s/%s/version.idx", update_config.resource, update_config.group)
    local versionUrl2 = string.format("http://%s/%s/version.idx", update_config.resource2, update_config.group)
    URLLoader.new(versionUrl, onVersionData, nil, onVersionDataError, 300, 5, versionUrl2)
    URLLoader.new('http://' .. update_config.host .. '/get_server_list.php?platform=' .. platform_config.name, onServerListData, nil, onServerListDataError)
end

--先加载核心版本号
local coreUrl1 = string.format("http://%s/platform/%s/core", update_config.resource, platform_config.name)
local coreUrl2 = string.format("http://%s/platform/%s/core", update_config.resource2, platform_config.name)
URLLoader.new(coreUrl1, onCoreData, nil, onVersionDataError, 300, 5, coreUrl2)

commit_device_log(3)
require("lua/preload/PreLoadMgr.lua")
commit_device_log(4)
PreLoadMgr:start(onLogoComplete, false) --true=>显示LOGO, false=>不显示
end

local function main_traceback(msg)
    print("\n")
    print("error: " .. tostring(msg) .. "\n")
    print(debug.traceback())
end

if lua_main then
    xpcall(lua_main, main_traceback)
    lua_main = nil
end
