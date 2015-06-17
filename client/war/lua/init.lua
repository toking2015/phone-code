local function init()

WRITE_PATH = cc.FileUtils:getInstance():getWritablePath()..''
print("write_path = " .. WRITE_PATH)

-- 尺寸信息
visibleSize = cc.Director:getInstance():getVisibleSize()
origin = cc.Director:getInstance():getVisibleOrigin()

-- 游戏原始设计分辨率
gameWidth = 1136
gameHeight = 640

-- avoid memory leak
collectgarbage("setpause", 1000)
collectgarbage("setstepmul", 500)

--优先增加可写目录搜索路径
local fileUtils = cc.FileUtils:getInstance()
fileUtils:addSearchPath( WRITE_PATH .. "res/fonts")
fileUtils:addSearchPath( "fonts" )
fileUtils:addSearchPath( WRITE_PATH .. "res/image/share" )
fileUtils:addSearchPath( "image/share" )

--增加公用plist
local cache = cc.SpriteFrameCache:getInstance()
cache:addSpriteFrames("SharedSource.plist")
cache:addSpriteFrames("image/ui/MainUI/MainUI0.plist")

--加载配置
require("lua/utils/Config.lua")

--加载基础工具
require "lua/manager/EventMgr.lua"
require "lua/manager/TimerMgr.lua"
require "lua/manager/LogMgr.lua"
require "lua/manager/Command.lua"

--加载基础库
Json = require("cjson")

--加载cocos2dx必须库
require("lua/cocos2dx/Cocos2d.lua")
require("lua/cocos2dx/Cocos2dConstants.lua")
require("lua/cocos2dx/GuiConstants.lua")
require("lua/cocos2dx/extern.lua")

--加载工具库
require("lua/algorithm/Algorithm.lua")
require("lua/utils/debug.lua")
require("lua/utils/functions.lua")
require("lua/utils/Pool.lua")
require("lua/utils/DateTools.lua")
require("lua/utils/MathUtil.lua")
require("lua/utils/DrawUtils.lua")
require("lua/utils/BitmapUtil.lua")
require("lua/utils/WordFilter.lua")

--加载静态数据
require "lua/server/StaticDataMgr.lua"

--加载通讯协议
require("lua/trans/trans.lua")
require("lua/game/receive/receive.lua")

--加载lua扩展内核
require("lua/core/import.lua")
require("lua/core/class.lua")
require("lua/core/object.lua")
require "lua/core/display.lua"

-- 加载显示扩展类
require "lua/display/extend.lua"
require "lua/display/AnimateSprite.lua"
require "lua/display/ArmatureSprite.lua"
require "lua/display/BoxContainer.lua"
require "lua/display/Particle.lua"
require "lua/display/UIFactory.lua"
require "lua/display/SWFRender.lua"

--加载常用库
require "lua/utils/JsonLoad.lua"
require "lua/utils/UICommon.lua"
require "lua/utils/FontStyle.lua"
require "lua/utils/Dictionary.lua"

--加载游戏核心管理库
require "lua/manager/PopMgr.lua"
require "lua/manager/PopWayMgr.lua"
require "lua/manager/LoadMgr.lua"
require "lua/manager/UIMgr.lua"
require "lua/manager/SceneMgr.lua"
require "lua/manager/ProgramMgr.lua"
require "lua/manager/GutMgr.lua"
require "lua/manager/LocalDataMgr.lua"
require "lua/manager/SoundMgr.lua"
require "lua/manager/ShakeMgr.lua"
require "lua/manager/ModelMgr.lua"
require "lua/manager/InductMgr.lua"
require "lua/manager/ActionMgr.lua"
    
--加载数据中心
require "lua/game/model/DataCenter.lua"

--加载模块错误处理
require "lua/game/error/Error.lua"
require("lua/utils/MemoryTest.lua")

--加载模块接口文件
require "lua/game/interface/interface.lua"

--加载主场景
require "lua/game/scene/Scene.lua"

--加载http
require('lua/utils/http')
require("lua/utils/LogViewer.lua")

require("lua/game/controller/Controller.lua")

--加载平台接口
require('lua/utils/inf')
require('lua/preload/VXinYouMgr.lua')

end
-------------------------------------------------------------------------

--安全模式解析json，解析失败返回nil
function safeDecodeJson(data)
    local json = nil
    local function decodeJson()
        json = Json.decode(data)
    end
    pcall(decodeJson)
    return json
end

local function main()
    commit_device_log(12)
    init()
    commit_device_log(13)
    
    writable.unlink( 'log.txt' )
    
    if inf.init ~= nil then
        inf.init(function(msg)
            LogMgr.log( 'inf', 'inf.init: ' .. msg .. '\n' )
    
            if msg == 'succeed' then
                return
            end
    
            inf.msg_progress( msg )
        end)
    end
    
    local function initHandler()
        Command.unbind("initHandler")
        SceneMgr.enterScene('opening')
        --显示登录界面
        addToNewParent(PreLoadBg:getInstance(), SceneMgr.getCurrentScene(), visibleSize.width / 2, visibleSize.height / 2)
        Command.run("loading server_list")
        --如果安卓手机点击了返回键，弹出是否退出游戏
        local isQuitShow = false
        local function onKeyPressed(keyCode, event)
            if keyCode == 6 then
                if isQuitShow then
                    isQuitShow = false
                    local win = PopMgr.getWindow("MsgBoxUI")
                    if win then
                        win:onButtonClick(false)
                    end
                else
                    isQuitShow = true
                    local function confirmHandler()
                        ActionMgr.save('init.lua', '手动退出游戏')
                        cc.Director:getInstance():endToLua()
                    end
                    local function cancelHandler()
                        isQuitShow = false
                    end
                    ActionMgr.save('init.lua', '按了返回键')
                    showQuitConfirm("是否退出游戏？", confirmHandler, cancelHandler)
                end
            end
        end
        local dispatcher = SceneMgr.getBaseScene():getEventDispatcher()
        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_RELEASED)
        dispatcher:addEventListenerWithFixedPriority(listener, -1)

    end
    Command.bind("initHandler", initHandler)
    initHandler()

    TimerMgr.startTimer( function()
    		local kb = collectgarbage("count")
    		--print( "lua memory: " .. math.floor(kb) .. "kb" )
    		
    		if kb > 20000 then
    				collectgarbage( 'collect' )
    		end
    end, 1, false )
    
    --左下状态显示
    if Config.is_debug() then
        wdebug.open_status()
    end
    
    --调试模式功能处理
    if Config.is_debug() then
        --本地测试脚本
        if cc.FileUtils:getInstance():isFileExist( 'lua/local_test.lua' ) then
            require('lua/local_test.lua')
        end
        
        --## reload "lua/local_test.lua"
        Command.bind( 'reload', function(file)
            package.loaded[file] = nil
            require(file)
        end )
    end
    
    --战斗记录, fight cache 已在 LogMgr 中定义开启, 这里无论是不是debug版本都需要 FightBegin 时进行clear, 不然会越来越占内存
    EventMgr.addListener( EventType.FightBegin, function()
        LogMgr.clear_cache_log( 'fight' )
    end )
    EventMgr.addListener( EventType.FightEnd, function()
        if Config.is_debug() then
            local log = LogMgr.get_cache_log( 'fight' )
            LocalDataMgr.save_string( 0, 'fight/log', log )
        end
    end )
end	

function __G__TRACKBACK__(msg)
    LogMgr.error("\nLUA ERROR: " .. tostring(msg) .. "\n" .. debug.traceback() .. "\n")
end

if main then
    xpcall(main, __G__TRACKBACK__)
    main = nil
end
