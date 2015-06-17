local canShow = true
local hasInit = false
local logList = {}
local lblLog = ccui.Text:create()
lblLog:setAnchorPoint(0, 0)
FontStyle.setFontNameAndSize(lblLog, nil, 20)
lblLog:setPosition(10, 110)
lblLog:retain()
addOutline(lblLog, cc.c4b(0, 0, 0, 0xff), 1)
lblLog:setTouchEnabled(false)

local function init()
	if hasInit then
		return
	end
	hasInit = true
	local layer = SceneMgr.getLayer(SceneMgr.LAYER_DEBUG)
	layer:addChild(lblLog, 1000000)
end

Command.bind("logviewer_clear", function( ... )
	logList = {}
	lblLog:setString("")
end)

Command.bind("logviewer_switch", function( ... )
	canShow = not canShow
	init()
	lblLog:setVisible(canShow)
end)
Command.bind("logviewer", function( ... )
	init()
	local content = ""
	for _,v in ipairs({...}) do
		content = content .. tostring(v) .. " "
	end
	table.insert(logList, content)
	if #logList > 20 then
		table.remove(logList, 1)
	end
	lblLog:setString(table.concat(logList, "\n"))
end)