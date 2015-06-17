require('lua/game/view/loadingUI/LoadingUI.lua')
require('lua/game/view/loadingUI/WaitingUI.lua')

local __scene = Scene:create()

function __scene:onShow()
end

function __scene:onClose()
end

SceneMgr.insertScene('opening', __scene)