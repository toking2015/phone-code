-- Create By Live --

require "lua/game/view/copyUI/CopyUIItem.lua"
-- require "lua/game/view/copyUI/CopyBoxUI.lua"
require "lua/game/view/copyUI/CopyProgressUI.lua"
-- require "lua/game/view/copyUI/CopyExpBar.lua"

local prePath = "image/ui/CopyUI/"

CopySceneUI = class("CopySceneUI", function()
	return Node:create()
end)
CopySceneUI.countCopyExp = 0

function CopySceneUI:create()
    local ui = CopySceneUI.new()

    return ui
end

function CopySceneUI:ctor()
    self.event_list = {}
    -- 副本场景主UI
    self.roleHead = MainUIMgr.getRoleHead()
    self.roleTop = MainUIMgr.getRoleTop()
    self.roleBottom = MainUIMgr.getRoleBottom()
    self.roleRight = MainUIMgr.getRoleRight()
    self.mainchat = MainUIMgr.getMainChat()
    self.paomaui = MainUIMgr.getPaomaUI()
    -- 
    local posX = visibleSize.width - self.roleTop:getBoundingBox().width - 65
    local posY = visibleSize.height - self.roleTop:getBoundingBox().height
    self.topPos = cc.p(posX, posY)
    --
    posX = visibleSize.width - self.roleRight:getBoundingBox().width - 10
    posY = 198
    self.rightPos = cc.p(posX, posY)
    
    --探索按钮及探索事件
    self.btn_search = ccui.ImageView:create( "copy_find.png", ccui.TextureResType.plistType )
    self.btn_search:setAnchorPoint( cc.p( 0, 0 ) )
    self.btn_search:setPosition( cc.p(visibleSize.width - self.btn_search:getSize().width - 30, 130))
    self.btn_search:setVisible(false)
    self.btn_search = createScaleButton(self.btn_search)
    local function clickSearch()
        self:excuteSearch()
    end
    self.btn_search:addTouchEnded(clickSearch)
    Command.bind("cmd copy search", clickSearch)

    -- 副本名称
    self.copyName = CopyName:new()
    self:addChild(self.copyName, 1)
    self.boss_pos = cc.p(self.copyName:getPosition())
    -- 右上角副本进度
    self.progress = CopyProgress:create()
    local size = self.progress:getSize()
    self.pro_pos = cc.p(visibleSize.width - size.width, visibleSize.height - size.height)
    self.progress:setPosition(self.pro_pos)
    self:addChild(self.progress, 1)
    -- 小人跑动进度条
    self.progress_bar = CopyProgressUI:create(self)
    self.progress_bar:retain()
    self.progress_bar:setPosition(visibleSize.width / 2, visibleSize.height / 2 - 150)
end
-- 执行探索动作
function CopySceneUI:excuteSearch()
    LogMgr.log("copy", ">>>>>>>>>>excuteSearch......")
    ActionMgr.save( 'UI', 'CopySceneUI click btn_search excuteSearch')
    self:addClickArea(false)
    if false == self.btn_search:isVisible() then return end
    -- self.btn_search:setVisible(false)
    Command.run("CopySceneBG showSearch", false)
    Command.run("CopySceneBG search")
end
-- 添加副本UI全屏点击区域，可任意点击执行探索
function CopySceneUI:addClickArea(bln)
    if true == bln then
        if self.clickArea == nil then
            self.clickArea = ccui.Layout:create()
--            self.clickArea:setVisible(false)
            self.clickArea:setSize(cc.size(visibleSize.width, visibleSize.height))
            self:addChild(self.clickArea, 0)
    
            function clickSearch()
                self:excuteSearch()
            end
            UIMgr.addTouchEnded(self.clickArea, clickSearch)
        end
    else
        if self.clickArea ~= nil then
            self.clickArea:setTouchEnabled(false)
            self.clickArea:removeFromParent()
            self.clickArea = nil
        end
    end
end
-- 副本场景UI初始化
function CopySceneUI:init()
    local dis = 10
    -- 副本主界面UI初始化
    -- 头像UI
    self.roleHead:setVisible(true)
    self.roleHead:setPositionX(dis)
    self.roleHead:setPositionY(visibleSize.height - self.roleHead:getBoundingBox().height) -- - dis)
    self:addChild(self.roleHead, 1)
    -- 顶部按钮
    self.roleTop:setVisible(true)
    self.roleTop:setPosition(self.topPos)
    self:addChild(self.roleTop, 1)
    self.roleTop:onlyShowStrength()
    -- 底部按钮
    -- self.roleBottom:setPositionX(visibleSize.width - self.roleBottom:getBoundingBox().width - dis)
    -- self.roleBottom:setPositionY(dis)
    self:addChild(self.roleBottom, 1)
    -- 右侧任务按钮
    self.roleRight:onlyShowTask()
    self.roleRight:setPosition(self.rightPos)
    self:addChild(self.roleRight, 1)
    -- 聊天界面
    self.mainchat:setPositionX(135)
    self.paomaui:setPositionX(366)
    
    -- self.mainchat:setPositionY(dis)
    self:addChild(self.mainchat, 1000)
    --公告
    self:addChild(self.paomaui, 1000)
    self.paomaui:init()
    -- 副本名称
    self.copyName:setName(CopyData.user.copy.copy_id)
    self.copyName:showStart()
    -- 小人副本进度
    self.progress_bar:onShow()
    -- 添加探索按钮
    self:addChild(self.btn_search, 1)
    -- 添加左下角退出按钮
    local function exitCopy()
        CopyData.isMetBoss = false
        Command.run("copy commit")
        Command.run( "scene leave" )
        Command.run( 'NCopyUI show', math.floor(CopyData.user.copy.copy_id / 1000), const.kCopyMopupTypeNormal)
    end
    local function callback()
        showMsgBox("是否暂离当前副本？", exitCopy)
    end
    BackButton:pushBack(self, callback)
    -- 初始化命令函数
    self:initCommand()
    -- 初始化事件监听
    self:initEventConfig()
end
-- 初始化命令函数
function CopySceneUI:initCommand()
    -- 隐藏探索过程中的部分UI
    local function hidePartUI(bln)
        local isBln = bln or false
        self.roleHead:setVisible(isBln)
        self.roleTop:setVisible(isBln)
        self.copyName:setVisible(isBln)
    end
    Command.bind("CopySceneUI hideUI", hidePartUI)
    -- 现实/隐藏 探索按钮
    local function showSearch(isShow)
        local tmp = "可见"
        if isShow == false then tmp = "不可见" end
        LogMgr.debug(">>>>>>>>>>>> 调整探索按钮是否可见：" .. tmp)
        self.btn_search:setVisible(isShow)
        self:addClickArea(isShow)
        EventMgr.dispatch( EventType.CopySearchShow, isShow )
    end
    Command.bind("CopySceneBG showSearch", showSearch)
end
-- 初始化事件监听
function CopySceneUI:initEventConfig()
    local win = "BagMain_SoldierUI_TotemUI"
    -- 当现实有win包含的窗口时，隐藏copyName及progress，并显示所有的top（除遇怪）
    self.event_list[EventType.ShowWindow] = function(data)
        LogMgr.debug(">>>>>>>>> ShowWin : " .. debug.dump(data))
        if nil ~= data and nil ~= data.winName then
            if string.find(win, data.winName) ~= nil then
                self.copyName:setVisible(false)
                self.progress:setVisible(false)
--                self.boxGet:setVisible(false)
--                self.roleTop:showAllExceptStrength()
                if CopyData.isMetBoss == true then
                    self.roleTop:setVisible(true)
                end
            end
        end
    end
    -- 关闭窗口显示必须的UI
    self.event_list[EventType.CloseWindow] = function(data)
        LogMgr.debug(">>>>>>>>> ShowWin : " .. debug.dump(data))
        if nil ~= data and nil ~= data.winName then
            if string.find(win, data.winName) ~= nil then
                if false == CopyData.isMetBoss then
                    self.copyName:setVisible(true)
                else
                    self.roleTop:setVisible(false)
                end
                    self.roleTop:onlyShowStrength()
                    self.roleTop:setPositionX(visibleSize.width - self.roleTop:getBoundingBox().width - 95)
                    self.progress:setVisible(true)
            end
        end
    end
    -- 更新右上角副本进度
    self.event_list[EventType.UpdateCopyProgress] = function()
        self.progress_bar:showProgress()
    end
    -- 显示经验进度条
    self.event_list[EventType.CopyGetExp] = function(data)
        self:showCopyExpBar(data)
        -- self.roleHead:addRoleExp(data)
        -- self:showGetExp(data)
    end
    -- 显示获得物品
    self.event_list[EventType.CopyGetList] = function(data)
        LogMgr.debug(">>>>>>>> 开始显示所得物品")
        self:showGetList(data)
    end
    -- 更新人物的部分信息显示
    self.event_list[EventType.UserCoinUpdate] = function()
        self.roleHead:updateLevel()
        self.roleTop:updateData()
        self.roleHead:updateVipLevel()
    end
    -- 更新名称
    self.event_list[EventType.TeamNameChange] = function()
        self.roleHead:updateName()
    end
    -- 更新头像
    self.event_list[EventType.UserSimpleUpdate] = function()
        self.roleHead:updateAvatar()
    end
    EventMgr.addList(self.event_list)
end
-- 显示副本经验条
function CopySceneUI:showCopyExpBar(exp)
    local level = gameData.getSimpleDataByKey('team_level')
    CopySceneUI.countCopyExp = CopySceneUI.countCopyExp + exp
    local sumCopyExp = tonumber(gameData.getSimpleDataByKey("team_xp")) + CopySceneUI.countCopyExp

    self.roleHead:addRoleExp(level, sumCopyExp, exp)
    -- expBar:updateExpData(level, sumCopyExp, exp)
    EventMgr.dispatch(EventType.showCopyExpBar, {val = exp, sumExp = sumCopyExp, level = level})
end
-- 显示获得经验文字
function CopySceneUI:showGetExp(exp)
    local txt = "获得 经验：" .. exp
    TipsMgr.showSuccess(txt, visibleSize.width / 2, visibleSize.height / 2)
end
-- 原本是获得物品跳动到一个box，已废弃
function CopySceneUI:itemJumpToBox(item, dx, h)
    local url = CopyRewardData.getRewardIconUrl(item)
    if url == "" then LogMgr.debug("路径不存在：" .. debug.dump(item)) end
    local rType = ccui.TextureResType.plistType
    if item.cate == 4 or item.cate == 13 then
        rType = ccui.TextureResType.localType
    end
    local icon = ccui.ImageView:create(url, rType)
    local px, py = visibleSize.width / 2, visibleSize.height / 2
--    local tx, ty = self.boxGet:getPositionX(), self.boxGet:getPositionY() + 50
    local tx, ty = 30, 50
    icon:setPosition(px, py)
    self:addChild(icon, 10)
    -- local dx = math.random(-100, 100)
    -- local h = math.random(50, 100)
    local jump = cc.JumpBy:create(0.8, cc.p(dx, 0), h, 1)
    local move = cc.MoveTo:create(0.5, cc.p(tx, ty))
    local function callback()
        icon:removeFromParent()
--        self.boxGet:addCount(item)
--        self.boxGet:shake()
    end
    local func = cc.CallFunc:create(callback, {})
    local seq = cc.Sequence:create(jump, move, func)
    icon:runAction(seq)
end
-- 
function CopySceneUI:showGetList(list)
    local function callback()
        Command.run("CopyMgr delayDoChunk")
    end
    local isShowItem = false
    local isShowTop = false
    if #list > 0 then
        for i = 1, #list do
            local item = list[i]
            if item.cate ~= 7 then
                isShowItem = true
            end
            if item.cate == 1 or item.cate == 3 or item.cate == 11 or item.cate == 12 then
                isShowTop = true
            end 
        end
        TipsMgr.showGetEffect(list, {const.kCoinStrength, const.kCoinItem, const.kCoinWater, const.kCoinGold, const.kCoinMoney} )
    end
    if isShowItem == true then
        performWithDelay(self, callback, 1.3)
    else
        callback()
    end
    if isShowTop == true then
        self:showTopEffect()
    end
end
-- 以下三个函数都是显示top的一些隐藏/显示动画
function CopySceneUI:showUIOut(target, pos, posType, duration)
    local toPos = UICommon.getSubOutPoint(target, pos, posType)
    UICommon.showTargetAction(target, toPos, duration)
end
function CopySceneUI:showUIIn(target, toPos, duration)
    UICommon.showTargetAction(target, toPos, duration)
end
function CopySceneUI:showTopEffect()
    local toPos = cc.p(self.roleTop:getPosition())
    local pos = UICommon.getSubOutPoint(self.roleTop, toPos, 2)
    local top = RoleTopView:create()
    top:showAllExceptStrength()
    top:setPosition(pos)
    
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_UP_WINDOW)
    layer:addChild(top)
    
    local function hideTop()
        local function callback()
            self.roleTop:resetShow()
            top:setVisible(false)
        end
        performWithDelay(self.roleTop, callback, 0.5)
        local boss_pos = cc.p(self.boss_pos.x, self.boss_pos.y + 25)
        self:showUIOut(self.copyName, boss_pos, 2, 0.5)
        self:showUIOut(self.progress, self.pro_pos, 2, 0.5)
        self:showUIIn(top, toPos, 0.5)
    end
    local function showTop()
        self.roleTop:onlyShowStrength()
        top:setVisible(true)
        self:showUIIn(top, pos, 0.5)
        self:showUIIn(self.copyName, self.boss_pos, 0.5)
        self:showUIIn(self.progress, self.pro_pos, 0.5)
        local function callback()
            top:removeFromParent()
        end
        performWithDelay(self.roleTop, callback, 0.5)
    end
    performWithDelay(self, hideTop, 1)
    performWithDelay(self, showTop, 2.2)
end
-- 初始化onShow
function CopySceneUI:onShow()
    self:init()
    UICommon.showSubUI(self.roleHead, 2, 0.5)
    UICommon.showSubUI(self.roleTop, 2, 0.5)
    UICommon.showSubUI(self.copyName, 2, 0.5)
    UICommon.showSubUI(self.progress, 2, 0.5)
    UICommon.showSubUI(self.roleBottom, 8, 0.5)
    UICommon.showSubUI(self.roleRight, 6, 0.5)
    UICommon.showSubUI(self.btn_search, 6, 0.5)
    
    UICommon.showSubUI(self.mainchat, 8 , 0.5)
    
    UICommon.showSubUI(self.paomaui, 9,0.5)
    MainUIMgr.checkChatShow(self.mainchat)
    
    self.showPaomaUI = function(flag)
        if self.paomaui ~= nil and self.paomaui.setVisible ~= nil then 
            self.paomaui:setVisible(flag)
        end 
        self.paomaui:setPositionX(366)
    end 
    EventMgr.addListener(EventType.PaomaEvent, self.showPaomaUI)  
    
end
-- 关闭
function CopySceneUI:onClose()
    EventMgr.removeList(self.event_list)
    if self.mainchat ~= nil then 
        self.mainchat:onClose()
    end 
    self:removeChild(self.mainchat)
    
    self:removeChild(self.roleHead)
    self.roleHead:setVisible(true)
    self:removeChild(self.roleTop)
    self.roleTop:setVisible(true)
    self.roleTop:resetShow()
    self:removeChild(self.roleBottom)
    self:removeChild(self.roleRight)
    self.roleRight:resetShow()
    self.roleRight:setPositionY(self.roleRight:getPositionY() - 100)
    
    self:removeChild(self.paomaui)
    EventMgr.removeListener(EventType.PaomaEvent, self.showPaomaUI)
    BackButton:pop(self)

    Command.unbind("CopySceneUI hideUI")
    Command.unbind("CopySceneBG showSearch")
end