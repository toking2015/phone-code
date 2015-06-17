-- Create By Hujingjiang --
require "lua/game/view/mainUI/commonUI/RoleBottomView.lua"
require "lua/game/view/mainUI/commonUI/RoleTopView.lua"
require "lua/game/view/mainUI/commonUI/RoleHeadView.lua"
require "lua/game/view/mainUI/commonUI/RoleRightView.lua"
require "lua/game/view/mainUI/commonUI/RoleSignView.lua"
require "lua/game/view/taskUI/TaskTrackUI.lua"
require "lua/game/view/mainUI/commonUI/CopyExpBar.lua"
require "lua/game/view/chatUI/MainChatUI.lua"
require "lua/game/view/paomaUI/PaomaUI.lua"

MainUIMgr = {}

local isInit = false
local roleBottom = nil
local roleTop = nil
local roleHead = nil
local roleRight = nil
local roleSign = nil
local chatBottom = nil
local paomaui = nil 
MainUIMgr.chatUi = nil

function MainUIMgr.init()
	if false == isInit then
		isInit = true

		local prevPath = "image/ui/MainUI/"
        cc.SpriteFrameCache:getInstance():addSpriteFrames(prevPath .. "MainUI0.plist")

		roleBottom = RoleBottomView:create()
		roleBottom:setPositionX(visibleSize.width - roleBottom:getBoundingBox().width - 15)
		roleBottom:setPositionY(2)
		roleBottom:retain()

		roleTop = RoleTopView:create()
		roleTop:configureEventList()
		roleTop:retain()

		roleHead = RoleHeadView:create()
		roleHead:configureEventList()
		roleHead:retain()

		roleRight = RoleRightView:create()
		roleRight:retain()

		roleSign = RoleSignView:create()
		roleSign:retain()
		
        chatBottom = MainChatUI:createView()
		-- chatBottom:setPositionX(160)
		chatBottom:setPositionY(2)
        chatBottom:retain()
        
        -- 跑马灯
        paomaui = PaomaUI:createView()
        paomaui:setPositionY(530)
        paomaui:setPositionX(366)
        paomaui:retain()
        EventMgr.addListener(EventType.UserSimpleUpdate, MainUIMgr.checkChatShow)  
	end
end

function MainUIMgr.getMainChat()
	MainUIMgr.init()
    return chatBottom
end 

function MainUIMgr.getRoleBottom()
	MainUIMgr.init()
	return roleBottom
end

function MainUIMgr.getRoleTop()
	MainUIMgr.init()
	return roleTop
end

function MainUIMgr.getRoleHead()
	MainUIMgr.init()
	return roleHead
end

function MainUIMgr.getRoleRight()
	MainUIMgr.init()
	return roleRight
end

function MainUIMgr.getRoleSign()
	MainUIMgr.init()
	return roleSign
end

function MainUIMgr.getPaomaUI()
    MainUIMgr.init()
    return paomaui
end 

function MainUIMgr.checkChatShow(chatUi,depth)
	if chatUi then
		MainUIMgr.chatUi = chatUi
	end 
	--聊天是可开启
    if MainUIMgr.chatUi ~= nil then 
       	if OpenFuncData.checkIsOpen( 0,OpenFuncData.ID_CHAT) then
       		MainUIMgr.chatUi:setVisible(true)
       		MainUIMgr.chatUi:onShow()
       	else
       		MainUIMgr.chatUi:setVisible(false)
       		MainUIMgr.chatUi:onClose()
       	end
    end 
end