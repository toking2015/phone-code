-- create by 胡核南
require "lua/game/view/msgboxUI/RichText.lua"
require "lua/game/view/msgboxUI/QuitConfirmUI.lua"

local prePath = "image/ui/MsgBoxUI/"
local rich = nil
local layout = nil
local dataList = {}
local currentData = nil
local leftPosX = nil
local rightPosX = nil

MsgBoxUI = createUIClass("MsgBoxUI", prePath .. "MsgBoxUI.ExportJson", PopWayMgr.SMALLTOBIG)

function MsgBoxUI:onShow()
    self:updateData()
end

function MsgBoxUI:updateData()
    if self.bg.layout ~= nil then
        self.bg.layout:removeAllChildren()
    end
    local index = 0

    local srcStr = currentData and currentData.srcStr or ""
    
    local function initBtnPosX()
        self.bg.green:setVisible(true)
        self.bg.orange:setPositionX(leftPosX)
        self.bg.green:setPositionX(rightPosX)
    end

    while srcStr ~= '' do
        rich = ccui.RichText:create()
        rich:setAnchorPoint(cc.p(0.5, 0.5))
        srcStr = RichText:DisposeRichText(srcStr, prePath, rich)
        if '' ~= srcStr or 0 ~= index then
            rich:setPosition(cc.p(self.bg.layout:getSize().width/2, self.bg.layout:getSize().height/2+20-50*index))
        else
            rich:setPosition(cc.p(self.bg.layout:getSize().width/2, self.bg.layout:getSize().height/2))
        end
        index = index + 1
        self.bg.layout:addChild( rich )
    end
    
    if RichText.btnCount ~= nil then
        if "two" == RichText.btnCount then
            initBtnPosX()
            self.bg.green.concel:loadTexture(RichText.leftBtn, ccui.TextureResType.plistType)
            self.bg.orange.confirm:loadTexture(RichText.rightBtn, ccui.TextureResType.plistType)
        else
            self.bg.green:setVisible(false)
            self.bg.orange:setPositionX(self:getSize().width/2)
            self.bg.orange.confirm:loadTexture(RichText.btnImage, ccui.TextureResType.plistType)
        end
        RichText.btnCount = nil
    else
--        view.bg.green:setVisible(true)
--        view.bg.orange:setPositionX(leftPosX)
        initBtnPosX()
        self.bg.orange.confirm:loadTexture("confirm.png", ccui.TextureResType.plistType)
        self.bg.green.concel:loadTexture("cancel.png", ccui.TextureResType.plistType)
    end    
end

function showMsgBox( str, confirm, cancel )
    local data = {}
    data.srcStr = str
    data.confirmFunc = confirm
    data.cancelFunc = cancel
    table.insert(dataList, data)
    currentData = data
    local view = PopMgr.getWindow("MsgBoxUI")
    if view ~= nil and view:isShow() then
        view:updateData()
        return
    end
    PopMgr.popUpWindow('MsgBoxUI', true, PopUpType.MODEL, false, 20000)
end
Command.bind("showMsgBox", showMsgBox)

function showConfirmMsgBox(str, confirm, cancel)
    local msg = str .. "[btn=one]confirm.png"
    showMsgBox(msg, confirm, cancel)
end
Command.bind("showConfirmMsgBox", showConfirmMsgBox)

function MsgBoxUI:ctor()
    local function msgBoxBtnFunc(sender, eventType)
        local result = false
        if "orange" == sender:getName() then
            result = true
            ActionMgr.save( 'UI', 'MsgBoxUI click orange' )
        elseif "green" == sender:getName() then
            ActionMgr.save( 'UI', 'MsgBoxUI click green' )
        end
        self:onButtonClick(result)
    end
    leftPosX = self.bg.orange:getPositionX()
    rightPosX = self.bg.green:getPositionX()
    UIMgr.addTouchEnded(self.bg.orange, msgBoxBtnFunc)
    UIMgr.addTouchEnded(self.bg.green, msgBoxBtnFunc)
end

function MsgBoxUI:onButtonClick(result)
    if currentData ~= nil then
        local confirmFunc = currentData.confirmFunc
        local cancelFunc = currentData.cancelFunc
        table.remove(dataList)
        currentData = dataList[#dataList]
        if currentData then
            self:updateData()
        elseif nil ~= PopMgr.getWindow("MsgBoxUI") then
            PopMgr.removeWindow(self)
        end
        if result and nil ~= confirmFunc then
            confirmFunc()
        end
        if not result and nil ~= cancelFunc then
            cancelFunc()
        end
    elseif nil ~= PopMgr.getWindow("MsgBoxUI") then
        PopMgr.removeWindow(self)
    end
end

function MsgBoxUI:onClose()
    dataList = {}
end