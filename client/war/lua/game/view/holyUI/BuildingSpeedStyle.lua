require "lua/game/view/holyUI/BuildingCritWord.lua"
local prePath = "image/ui/HolyUI/"

local MaxBuildLevel = 10
local building_type = nil

local isUICenter = true

BuildingSpeedStyle = createUIClass("BuildingSpeedStyle",prePath .. "BuildingSpeedStyle.ExportJson")

local function judgeSpeedCondition()
    local curTimes = BuildingData.obtainSpeedTimes(building_type)  -- 获取当前加速次数
    local maxCount = BuildingData.getMaxSpeedTimes(building_type)
    local bLevel = BuildingData.getBuildingLevel(building_type)
    if curTimes >= maxCount then
        TipsMgr.showError('超过最大加速次数')
        return  false
    end
    local cost = BuildingData.consumeDiamond(building_type)
    local dim = CoinData.getCoinByCate(const.kCoinGold)
    if dim < cost then
        TipsMgr.showError('钻石不足')
        return false
    end
    if bLevel < 0 or bLevel > MaxBuildLevel then
        TipsMgr.showError('建筑等级错误')
        return false
    end
    return true
end

function BuildingSpeedStyle:ctor()
    self.event_list = {}
    if BuildingData.checkBuildingExist(building_type) then
        self.canSpeed = true
        self.timeId = nil
        self:initWithType(building_type)
        self:configureTouchListener()
        self:configureEventListener()
    end
end

function BuildingSpeedStyle:initWithType(type)
    type = type or 6
    if 6 == type then
        self.bg2.note.sunwell:setString("太阳井")
        self.bg2.box.building:loadTexture("building_holy_icon.png", ccui.TextureResType.plistType)
        self.bg2.box.building:setScale(1)
        self.bg3.oneBg.frame.holy:loadTexture("building_holy.png", ccui.TextureResType.plistType)
        self.bg3.moreBg.frame.holy:loadTexture("building_holy.png", ccui.TextureResType.plistType)
    else
        self.bg2.note.sunwell:setString("金矿")
        self.bg2.box.building:loadTexture("building_coin_icon.png", ccui.TextureResType.plistType)
        self.bg2.box.building:setScale(0.7)
        self.bg3.oneBg.frame.holy:loadTexture("building_coin.png", ccui.TextureResType.plistType)
        self.bg3.moreBg.frame.holy:loadTexture("building_coin.png", ccui.TextureResType.plistType)
    end
end

function BuildingSpeedStyle:onShow()
    self:initSpeedStyle()
    self:showOpenCondition()
    EventMgr.addList(self.event_list)
    -- self:styleShow()
end

function BuildingSpeedStyle:configureEventListener()
    self.event_list[EventType.BuildingCritUpdate] = function(data)
        self.canSpeed = true
        -- self.building_type = data.building_type
        self.critTimesList = data.list_crit_times
        self.sumValue = data.add_value
        for i = 1, #(self.critTimesList) do
            self.critTimesList[i] = 1
        end
        self:buildingSpeedResult(self.critTimesList)
    end
end

function BuildingSpeedStyle:buildingSpeedResult()
    local j = 0
    if "TenUp" == self.speedStyle then
        EventMgr.dispatch(EventType.showProdCount, {type = building_type, list = self.critTimesList, sum = self.sumValue})
        -- Command.run( 'ui show', 'HolyProdCount', PopUpType.SPECIAL, true )
    end
    for i = 1, #(self.critTimesList) do
        self:updatePanel()
        local v = self.critTimesList[i]
        if j == 0 then
            self:showCritWord(v)
        else
            performWithDelay(self, function() self:showCritWord(v) end, 0.8 * j)
        end
        j = j + 1
    end
end

function BuildingSpeedStyle:showCritWord(critTimes)
    if not self.critWord then
        self.critWord = CritWord:createCritWord(building_type)  -- 创建暴击字
        self.critWord:retain()
        self:addChild(self.critWord)
    end

    local count = BuildingData.obtainCoinCount(building_type)
    self.critWord:updateCritWord(critTimes, count)
    local critWordSize = self.critWord:getSize()
    local pos = nil
    if "OneUp" == self.speedStyle then
        pos = cc.p(self:getSize().width - critWordSize.width + 60, 190)
    else
        pos = cc.p(self:getSize().width - critWordSize.width + 60, 50)
    end
    self.critWord:setPosition(pos)
    local moveAction = cc.MoveBy:create(1, cc.p(0, 50))
    self.critWord:runAction(cc.Sequence:create(moveAction, cc.RemoveSelf:create()))
end

function BuildingSpeedStyle:showOpenCondition()
    -- 连续加速开发条件
    local posX = self.bg3.moreBg.more:getPositionX()
    local txt = UIFactory.getText('VIP2开启', self.bg3.moreBg, posX, 63, 22, cc.c3b(0xff, 0x00, 0x00))
    local vip_level = gameData.getSimpleDataByKey('vip_level')
    if vip_level < 2 then
        txt:setVisible(true)
        self.bg3.moreBg.more:setVisible(false)
        self.bg3.moreBg.expend:setVisible(false)
        self.bg3.moreBg.dia:setVisible(false)
        self.bg3.moreBg.diaNum:setVisible(false)
    else
        txt:setVisible(false)
        self.bg3.moreBg.more:setVisible(true)
        self.bg3.moreBg.expend:setVisible(true)
        self.bg3.moreBg.dia:setVisible(true)
        self.bg3.moreBg.diaNum:setVisible(true)
    end
end

function BuildingSpeedStyle:onClose()
end

function BuildingSpeedStyle:initSpeedStyle()
    self.bLevel = BuildingData.getBuildingLevel(building_type)
    self.maxCount =  BuildingData.getMaxSpeedTimes(building_type)

    self.bg2.levleNote.level:setString('' .. self.bLevel)
    self:updatePanel()
end

-- 初始化面板
function BuildingSpeedStyle:updatePanel()
    self.bg3.oneBg.diaNum:setString('X' .. BuildingData.consumeDiamond(building_type))
    self.bg3.moreBg.diaNum:setString('X' .. BuildingData.tenConsumeDiamond(building_type))
    self.bg3.oneBg.frame.num:setString('' .. BuildingData.obtainCoinCount(building_type))
    self.bg3.moreBg.frame.num:setString('' .. tonumber(BuildingData.obtainCoinCount(building_type)) * 10)
end

function BuildingSpeedStyle:configureTouchListener()
    local function oneSpeedTouchFunc(ref, eventType)
        ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'one') )
        if  false == self.canSpeed or not building_type or false == judgeSpeedCondition() then
            LogMgr.debug("加速失败")
            return
        end
        self.canSpeed = false
        self.speedStyle = "OneUp"
        Command.run('building output', building_type, 1)
    end
    local function tenSpeedTouchFunc(ref, eventType)
        ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, 'more') )
        if false == self.canSpeed or not building_type or false == judgeSpeedCondition() then
            LogMgr.debug("加速失败")
            return
        end
        self.canSpeed = false
        self.speedStyle = "TenUp"
        touchMore = true
        Command.run('building output', building_type, 10)
    end
    UIMgr.addTouchEnded(self.bg3.oneBg.one, oneSpeedTouchFunc)
    UIMgr.addTouchEnded(self.bg3.moreBg.more, tenSpeedTouchFunc)
end

function BuildingSpeedStyle:dispose()
    TimerMgr.killTimer(self.timeId)
    EventMgr.removeList(self.event_list)
    if self.critWord then
        self.critWord:release()
        self.critWord = nil
    end
end

local function showBuildingSpeedup(type)
    building_type = type
    LogMgr.debug("building_type", building_type)
    Command.run('ui show', 'BuildingSpeedStyle', PopUpType.SPECIAL)
end
EventMgr.addListener(EventType.showSpeedStyle, showBuildingSpeedup)

------------------------------------------------

function BuildingSpeedStyle:backHandler()
    self:styleClose()
end

function BuildingSpeedStyle:styleShow()
    self:setVisible(true)
        local midX, midY = visibleSize.width/2, visibleSize.height/2
        local winSize = self:getSize()
        if false == self:isCascadeOpacityEnabled() then
            self:setCascadeOpacityEnabled(true)
        end
        setUiOpacity(self, 45)
        self:setAnchorPoint(cc.p(0.5, 0.5))

        local mAction = nil
        local sAction = nil
        local scaleBack = nil
        if false == isUICenter then
            self:setPosition(cc.p(midX+winSize.width*0.5-3, midY))
            sAction = cc.ScaleTo:create(0.1, 1.05)
            scaleBack = cc.ScaleTo:create(0.08, 1)
            setUIFade(self, cc.FadeIn, 0.18)
        else
            self:setPosition(cc.p(midX, midY))
            sAction = cc.ScaleTo:create(0.1, 1.05)
            scaleBack = cc.ScaleTo:create(0.08, 1)
            setUIFade(self, cc.FadeIn, 0.18)
        end

        local function showUiPanelFunc()
            PopMgr.setUiAminal(false)
        end
        local animFunc = cc.CallFunc:create(showUiPanelFunc)
        local action = cc.Sequence:create(sAction, scaleBack, animFunc)

        self:runAction(action)
end

function BuildingSpeedStyle:styleClose()
    local midX, midY = visibleSize.width/2, visibleSize.height/2
        local winSize = self:getSize()

        local sAction = cc.ScaleTo:create(0.14, 1.05)
        -- local mAction = nil
        if false == isUICenter then
            isUICenter = true
            setUIFade(self, cc.FadeOut, 0.14)
        else
            setUIFade(self, cc.FadeOut, 0.14)
        end

        local function showUiPanelFunc()
            PopMgr.removeWindow(self)
            -- self:removeFromParent()
        end
        local animFunc = cc.CallFunc:create(showUiPanelFunc)
        local action = cc.Sequence:create(sAction, animFunc)

        self:runAction(action)

        EventMgr.dispatch( EventType.HolyBuildingSet )
end

-- local function showSpeedStyle(data)
--     isUICenter = data.isCenter
--     PopMgr.popUpWindow("BuildingSpeedStyle", false, PopUpType.SPECIAL)
-- end
-- EventMgr.addListener(EventType.showSpeedStyle, showSpeedStyle)