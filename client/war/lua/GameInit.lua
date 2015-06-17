require "Cocos2d"

--cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
--cc.FileUtils:getInstance():addSearchResolutionsOrder("src/scene");

LogMgr.debug(".............")

require "lua/game/scene/RotateCircle.lua"
require "lua/game/scene/MainScene.lua"

sceneWidth = 3072
sceneHeight = 2304
visibleSize = cc.Director:getInstance():getVisibleSize()
origin = cc.Director:getInstance():getVisibleOrigin()

-- avoid memory leak
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

function init_new_game()
    showMainScene()
    --[[
    local canUpdate = getAssetsManager():checkUpdate()
    LogMgr.debug("init_new_game+++++++++++++++++++vesion:%s", getAssetsManager():getVersion())
    --LogMgr.debug("checkHotUpdate++++++++++++++++++canUpdate:%c", canUpdate)
    if canUpdate then
        --LogMgr.debug("++++++11+++++++++++checkHotUpdate");
        showUpdateScene()
    else
        showMainScene()
    end
    ]]
end

function enter_foreground()
    --[[
    local canUpdate = getAssetsManager():checkUpdate()
    LogMgr.debug("enter_foreground+++++++++++++++++++vesion:%s", getAssetsManager():getVersion())
    --LogMgr.debug("checkHotUpdate++++++++++++++++++canUpdate:%c", canUpdate)

    if canUpdate then
        --LogMgr.debug("++++++11+++++++++++checkHotUpdate");
        showUpdateScene()
    else
        LogMgr.debug("++++++++++++++do nothing");
    end
]]
end
    


