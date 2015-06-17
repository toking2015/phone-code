require "Cocos2d"

--cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
--cc.FileUtils:getInstance():addSearchResolutionsOrder("src/scene");

require "lua/game/scene/RotateCircle.lua"
require "lua/game/scene/MainScene.lua"

-- cclog
function cclog(...)
    print(string.format(...))
end

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
    cclog("init_new_game+++++++++++++++++++vesion:%s", getAssetsManager():getVersion())
    --cclog("checkHotUpdate++++++++++++++++++canUpdate:%c", canUpdate)
    if canUpdate then
        --cclog("++++++11+++++++++++checkHotUpdate");
        showUpdateScene()
    else
        showMainScene()
    end
    ]]
end

function enter_foreground()
    --[[
    local canUpdate = getAssetsManager():checkUpdate()
    cclog("enter_foreground+++++++++++++++++++vesion:%s", getAssetsManager():getVersion())
    --cclog("checkHotUpdate++++++++++++++++++canUpdate:%c", canUpdate)

    if canUpdate then
        --cclog("++++++11+++++++++++checkHotUpdate");
        showUpdateScene()
    else
        cclog("++++++++++++++do nothing");
    end
]]
end
    


