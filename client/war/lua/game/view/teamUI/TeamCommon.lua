TeamCommon = {}

TeamCommon.prePath = "image/ui/SettingUI/"

function TeamCommon.createButton(btn, fun)
	btn:setTouchEnabled(true)
	createScaleButton(btn)
	btn:addTouchEnded(fun)
end

function TeamCommon.getUIShowHandler(uiName, popType, winName, btnName)
	popType = popType or PopUpType.SPECIAL
	local fun = function(ref, eventType)
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', winName, btnName) )
		Command.run("ui show", uiName, popType)
	end
	return fun
end

require "lua/game/view/teamUI/HeadSelectUI.lua"
require "lua/game/view/teamUI/RenameUI.lua"
require "lua/game/view/teamUI/SettingUI.lua"
require "lua/game/view/teamUI/NoticeSettingUI.lua"
require "lua/game/view/teamUI/CDKeyUI.lua"