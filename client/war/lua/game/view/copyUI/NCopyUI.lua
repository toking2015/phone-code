-- Create By Hujingjiang --

require "lua/game/view/copyUI/NCopyItem.lua"
require "lua/game/view/copyUI/BossInfoUI.lua"
require "lua/game/view/saodangUI/SaoDangUI.lua"
require "lua/game/view/copyPresentUI/CopyPresentUI.lua"
require "lua/game/view/copyUI/ExpBarUI.lua"
require "lua/game/view/copyUI/BossRecordUI.lua"

local prePath = "image/ui/NCopyUI/"

-- 创建副本界面
local url = prePath .. "NCopyUI.ExportJson"

-- NCopyUI = createUIClass("NCopyUI", url, PopWayMgr.SMALLTOBIG)
NCopyUI = class("NCopyUI", function()
    return getLayout(url)
end)

function NCopyUI:ctor()
    self.event_list = {}
    self.areaList = nil
    
    self.buildPool = {}

    self.starReward = nil
    self.moveDir = 0
    self.isMove = false

    -- UI界面的其他栏目
    self.top = MainUIMgr.getRoleTop()
    self.bottom = MainUIMgr.getRoleBottom()
    self.right = MainUIMgr.getRoleRight()
    self.head = MainUIMgr.getRoleHead()
    self.mainchat = MainUIMgr.getMainChat()
    self.paomaui = MainUIMgr.getPaomaUI()
    self:initAreaName()
    self:initAreaSelect()
    self:initAreaStar()
    self:initCopyLayer()
    self:initTurnBtns()

    self:initCommand()
end
-- 区域名称
function NCopyUI:initAreaName()
    self.areaName = CopyAreaName:new()
    local areaSize = self.areaName:getSize()
    self.areaName:setPosition(cc.p((visibleSize.width - areaSize.width) / 2, visibleSize.height - areaSize.height - 6))
    self:addChild(self.areaName, 1)
end
 -- 区域的类型选择，普通副本，精英副本及材质副本
function NCopyUI:initAreaSelect()
    self.copySelect = NCopySelect:create()
    self.copySelect:setPosition(25, 510)
    self:addChild(self.copySelect, 2)
    local function handler(data)
        local index = data.data

        ----- 测试代码 -----
        if index == const.kCopyMaterial then
            if PaperSkillData.getSkillId() == 0 then
                TipsMgr.showError('学习手工技能后开放')
                self.copySelect:setSelect(CopyData.curSelectUI)
                return
            end
            self:resetUI()
            self:showMaterialUI()
            CopyData.curSelectUI = const.kCopyMaterial
            return
        end

        self:showCopyInfo()
        
        if self.areaList == nil then
            self.areaList = CopyData.getAllAreaCopyList()
        end
        local copyId = CopyData.getNextCopyId(index)
        local a_id = math.floor(copyId / 1000)
        -- local a_id = #self.areaList[index]
        if CopyData.checkOpenArea(a_id) == false then 
            a_id = a_id - 1 
        end
        CopyData.setCurrAreaInfo(a_id, index)

        if CopyData.curSelectUI == const.kCopyMaterial then
            self:releaseMaterialUI()
            CopyData.curSelectUI = index
        end        
        
        self:showUI()
        
        if index == const.kCopyMopupTypeElite then
            self.copySelect:setSelect(const.kCopyMopupTypeElite)
        else
            self.copySelect:setSelect(const.kCopyMopupTypeNormal)
        end
        ----- 测试代码 --------
    end
    self.copySelect:addEventListener(handler)
    self.copySelect:setVisible(false)
end
-- 当前区域所获得的星数界面
function NCopyUI:initAreaStar()
    self.star = CopyStar:new()
    self.star:setPositionX(visibleSize.width - self.star:getSize().width)
    self.star:setPositionY(visibleSize.height - 65 - self.star:getSize().height)
    self:addChild(self.star, 3)
end
-- 左右移动按钮
function NCopyUI:initTurnBtns()
    local btn_left = ccui.Button:create("copy_btn_left_down.png", "copy_btn_left.png", "copy_btn_left_down.png", ccui.TextureResType.plistType)
    btn_left:setPosition(cc.p(50, visibleSize.height / 2))
    btn_left:setVisible(false)
    self:addChild(btn_left, 32)
    self.btn_left = btn_left
    local btn_right = ccui.Button:create("copy_btn_left_down.png", "copy_btn_left.png", "copy_btn_left_down.png", ccui.TextureResType.plistType)
    btn_right:setPosition(cc.p(visibleSize.width - 50, visibleSize.height / 2))
    btn_right:setScaleX(-1)
    btn_right:setVisible(false)
    self:addChild(btn_right, 32)
    self.btn_right = btn_right
    function self.clickToArea(ref, eventType)
        if self.isMove == true then return end
        local srcArea_id = CopyData.area_id
        local toArea = CopyData.area_id - 1
        self.moveDir = -1
        if ref == btn_right then
            toArea = CopyData.area_id + 1
            self.moveDir = 1
            ActionMgr.save( 'UI', 'NCopyUI click btn_right toArea:' .. toArea)
        else
            ActionMgr.save( 'UI', 'NCopyUI click btn_left toArea:' .. toArea)
        end
                
        SoundMgr.playEffect("sound/ui/sfx_roll.mp3")
        CopyData.area_id = toArea
        self:moveCopyLayer(srcArea_id)

        EventMgr.dispatch( EventType.CopyPage )
    end
    UIMgr.addTouchEnded(btn_left, self.clickToArea)
    UIMgr.addTouchEnded(btn_right, self.clickToArea)
end
-- 因为有滑动效果，因此做成两个副本点层
function NCopyUI:initCopyLayer()
    self.currLayerBg = nil
    self.layer_3 = Node:create()
    self:addChild(self.layer_3, 0)
    self.layer_4 = Node:create()
    self:addChild(self.layer_4, 0)

    self.currLayer = nil
    self.layer_1 = Node:create()
    self.layer_1.list = {}
    self:addChild(self.layer_1, 1)
    self.layer_1.bg = Node:create()
    self.layer_1:addChild(self.layer_1.bg)

    self.layer_2 = Node:create()
    self.layer_2.list = {}
    self:addChild(self.layer_2, 1)
    self.layer_2.bg = Node:create()
    self.layer_2:addChild(self.layer_2.bg)
end
function NCopyUI:initCommand()
     Command.bind("cmd DesWin show", function(copyId)
        local copy = findCopy( copyId )
        local boss = CopyData.getCopyBoss(copy.id)
        PopMgr.checkPriorityPop( 
         "BossInfoUI", 
         PopOrType.Com, 
         function()
             Command.run("BossInfoUI show", {type = const.kCopyMopupTypeNormal, copy_id = copy.id, boss_id = boss.boss_id})             
         end
         )        
    end)
    Command.bind("cmd CopySelect", function()
        self.copySelect:setSelect(const.kCopyMopupTypeElite)
        if not self.areaList then
            return
        end
        CopyData.setCurrAreaInfo(#self.areaList[const.kCopyMopupTypeElite], const.kCopyMopupTypeElite)
        self:showUI()
    end)
end
-- 第一次显示
function NCopyUI:firstShow()
    self.moveDir = 0
    self.isMove = false
    self.currLayer = self.layer_1
    self.currLayerBg = self.layer_3

    self.layer_1:setPosition(0, 0)
    self.layer_3:setPosition(0, 0)
    
    self:addConfig()
    self:showExUI()

    -- 判断是否有得到星星
    self.starReward = CopyData.starReward

    ----- 测试代码 -----
    if  CopyData.curSelectUI == const.kCopyMaterial then
        -- 遗忘技能可能在副本内也可能在副本外
        if PaperSkillData.getSkillId() == 0 then
            CopyData.curSelectUI = kCopyMopupTypeNormal
            self:showUI()
        else
            self:showMaterialUI()
        end
    else
        self:showUI()
    end
    
    UICommon.showSubUI(self.areaName, 2, 0.3)
    UICommon.showSubUI(self.top, 2, 0.3)
    UICommon.showSubUI(self.star, 2, 0.3)
    UICommon.showSubUI(self.right, 6, 0.3)
    UICommon.showSubUI(self.bottom, 8, 0.3)
    UICommon.showSubUI(self.mainchat, 8,0.3)
    UICommon.showSubUI(self.paomaui, 9,0.3)
    MainUIMgr.checkChatShow(self.mainchat)
    if self.paomaui ~= nil then 
        self.paomaui:onShow()
    end 
    self.showPaomaUI = function(flag)
        if self.paomaui ~= nil and self.paomaui.setVisible ~= nil then 
            self.paomaui:setVisible(flag)
            self.paomaui:setPositionX(366)
        end 
    end 
    EventMgr.addListener(EventType.PaomaEvent, self.showPaomaUI)  
end
-- 添加事件监听
function NCopyUI:addConfig()
    self.event_list = {}
    self.event_list[EventType.UserCopyUpdate] = function()
        self:onUpdate()
    end
    self.event_list[EventType.GetPresent] = function(data)
        -- self.star:setPresent(2)
        self.star:setAreaStar(CopyData.area_id, CopyData.area_type)
        TipsMgr.showSuccess("领取成功") 
    end
    self.event_list[EventType.CopyPtViewItem] = function ()
        for __, building in pairs(self.currLayer.list) do
            building:setData(building.data)
        end
    end
    self.event_list[EventType.TeamLevelUp] = function (...)
        local level = gameData.user.simple.team_level
        self.copySelect:setVisible(level >= CopyData.elite_open_level)
    end
    --[[
    self.event_list[EventType.UpdateMaterial] = function()
        local b_list = self.currLayer.list
        for _, v in pairs(b_list) do
            v:updateMaterial()
        end
    end
    self.event_list[EventType.CollectMaterial] = function(material)
        local b_list = self.currLayer.list
        for _, v in pairs(b_list) do
            v:updateMaterial()
        end
        local list = {{cate = const.kCoinItem, objid = material.material_id, val = material.num}}
        TipsMgr.showItemObtained(list)
    end
    --]]
    self.event_list[EventType.UserCoinUpdate] = function(data)
        self.top:updateData()
        self.head:updateVipLevel()
        self.head:updateLevel()
        if data.coin.cate == trans.const.kCoinTeamXp then
            -- self.head:obtainExpAction(data)
            -- self.head:updateExp(data)
        end
    end
    self.event_list[EventType.CloseWindow] = function()
        self.top:updateData()
        self.head:updateExp()
        self.head:updateLevel()
        self.head:updateVipLevel()
    end 
    EventMgr.addList(self.event_list)
end
-- 查找area_id区域stype类型是否有开放副本列表
function NCopyUI:hasAreaList(area_id, stype)
    local curList = self.areaList[stype][area_id]
    if nil == curList or #curList == 0 then return false end
    return true
end
-- 隐藏副本的一些UI，应该是材料显示界面需要隐藏
function NCopyUI:hideCopyInfo()
    self.btn_left:setVisible(false)
    self.btn_right:setVisible(false)
    self.star:setVisible(false)
end
-- 显示副本的一些UI
function NCopyUI:showCopyInfo()
    self.btn_left:setVisible(true)
    self.btn_right:setVisible(true)
    self.star:setVisible(true)
end
function NCopyUI:checkJumpRight()
    local copy_id = CopyData.getNextCopyId(CopyData.area_type)
    local list = self.areaList[CopyData.area_type][CopyData.area_id + 1]
    if #list > 0 and list[1] == copy_id then
        local moveLeft = cc.MoveBy:create(1, cc.p(-20, 0))
        local moveRight = cc.MoveBy:create(1, cc.p(20, 0))
        self.right:setPositionX(visibleSize.width - self.right:getBoundingBox().width - 10)
        self.btn_right.action = self.btn_right:runAction(cc.RepeatForever:create(cc.Sequence:create(moveLeft, moveRight)))
    elseif self.btn_right.action then
        self.btn_right:stopAllActions()
        self.right:setPositionX(visibleSize.width - self.right:getBoundingBox().width - 10)
    end
end
-- 显示左右按钮
function NCopyUI:showLeftRight()
    -- 显示左边按钮
    self.btn_left:setVisible(CopyData.area_id > 1)
    -- 显示右边按钮
    if self:hasAreaList(CopyData.area_id + 1, CopyData.area_type) then
        self.btn_right:setVisible(true)
        self:checkJumpRight()
    else
        self.btn_right:setVisible(false)
        
        if self.btn_right.action then
            self.btn_right:stopAllActions()
            self.right:setPositionX(visibleSize.width - self.right:getBoundingBox().width - 10)
        end
    end
end
-- 显示副本UI界面的主UI
function NCopyUI:showExUI()
    local parent = self.top:getParent()
    if parent ~= self then
        if parent ~= nil then self.top:removeFromParent() end
        self.top:onlyShowStrength()
        self.top:setPositionX(visibleSize.width - 220)
        self.top:setPositionY(visibleSize.height - self.top:getBoundingBox().height)
        self:addChild(self.top, 1)

        if self.star then
            self.star:setPositionY(visibleSize.height - 65 - self.star:getSize().height)
        end        
    end
    parent = self.right:getParent()
    if parent ~= self then
        if nil ~= parent then self.right:removeFromParent() end
        self.right:onlyShowTask()
        self:addChild(self.right, 31)
        self.right:setPositionX(visibleSize.width - self.right:getBoundingBox().width - 10)
        self.right:setPositionY(20)
    end
    parent = self.bottom:getParent()
    if parent ~= self then
        if nil ~= parent then self.bottom:removeFromParent() end
        self:addChild(self.bottom, 50)
        -- self.bottom:setPositionX(visibleSize.width - self.bottom:getBoundingBox().width - 20)
    end
    self.bottom:setPositionY(2)
    
    parent = self.mainchat:getParent()
    if parent ~= self then
        if nil ~= parent then self.mainchat:removeFromParent() end
        self:addChild(self.mainchat, 1000)
        -- self.mainchat:setPosition(cc.p(160, 10))
        self.mainchat:setPositionX(160)
    end
    parent = self.paomaui:getParent()
    if parent ~= self then
        if nil ~= parent then self.paomaui:removeFromParent() end
        self:addChild(self.paomaui, 1000)
        self.paomaui:setPositionX(366)
        self.paomaui:init()
    end

end
-- 判断是否获得经验
function NCopyUI:judgeExpReward(list)
    if not list then list = {} end
    local exp = 0
    for _, v in pairs(list) do
        if 7 == v.cate then
            exp = v.val
            break
        end
    end
    return exp 
end
-- 显示经验条
function NCopyUI:showExpBarUI(val)
    local level = gameData.getSimpleDataByKey('team_level')
    local curExp = gameData.getSimpleDataByKey('team_xp')
    local maxExp = findLevel(level).team_xp
    local surplus = val - curExp
    while surplus >= 0 do
        level = level - 1
        maxExp = findLevel(level).team_xp
        surplus = surplus - maxExp
    end
    local preExp = -surplus
    local sumExp = preExp + val
    EventMgr.dispatch(EventType.showExpBarUI, {val = val, sumExp = sumExp, level = level})
end
-- 显示获得奖励
function NCopyUI:showBossReward()
    local list = CopyData.getBossReward
    if list ~= nil then
        local exp = self:judgeExpReward(list)
        if exp > 0 then
            self:showExpBarUI(exp)
            self.head:updateExp()
        end
        -- showGetEffect(list, {const.kCoinStrength, const.kCoinItem, const.kCoinWater, const.kCoinGold, const.kCoinMoney} )
        -- TipsMgr.showItemObtained(list)
        CopyData.getBossReward = nil
    end
end
-- 显示UI，显示流程：类型选择，UI背景，左右按钮，副本点显示
function NCopyUI:showUI()
--    if true then return end
    if self.areaList == nil then
        self.areaList = CopyData.getAllAreaCopyList()
    end
    
    local curList = self.areaList[CopyData.area_type][CopyData.area_id]
    if nil == curList or #curList == 0 then CopyData.area_id = #self.areaList[CopyData.area_type] end
    
    local level = gameData.user.simple.team_level
    self.copySelect:setVisible(level >= CopyData.elite_open_level)
    self.copySelect:setSelect(CopyData.area_type)
    -- 添加背景
    self:addCopyBg()
    -- 显示左右箭头
    self:showLeftRight()
    -- 更新
    self:onUpdate()
    -- 更新数据
    self.top:updateData()

    CopyMgr.equipShow()
end
-- 木有用
-- function NCopyUI:getFindAreaID()
--     local u_copy = CopyData.user.copy
--     local area_id = math.floor( u_copy.copy_id / 1000 )
--     if area_id > CopyData.area_id then
--         return CopyData.area_id
--     end
--     return area_id
-- end
-- 创建副本点
function NCopyUI:createBuild(data, dx, dy)
    local len = #self.buildPool
    local building = nil
    if len > 0 then
        building = table.remove(self.buildPool, 1)
        building:setData(data)
    else
        building = NCopyView:create(data)
        building:retain()
    end
    building:setPosition(cc.p(dx, dy))
    return building
end
--根据副本id获取副本建筑物
function NCopyUI:getBuilding(copy_id)
    if not self.currLayer or not self.currLayer.list then
        return nil
    end

    for __, building in pairs(self.currLayer.list) do
        if copy_id == building.data.copy.id then
            return building
        end
    end

    return nil
end

-- 更新副本点
function NCopyUI:onUpdate()
    -- 判断是否应该请求open副本
	local u_copy = gameData.user.copy
	
    if u_copy.copy_id == 0 then
        local copy_id = CopyData.getNextCopyId()
        
        if copy_id ~= 0 then
            if CopyData.checkOpenAreaBy(copy_id) == true then
            
                if CopyData.wait_open ~= true then
                    Command.run( 'copy open', copy_id )
                end
                
                return
            end
        end
    end
    
    self:resetUI()

    if CopyData.curSelectUI == const.kCopyMaterial then
        self:showMaterialUI()
        return
    end
    
    -- 查找区域数据
    local showType = CopyData.area_type
    local s_area = findArea( CopyData.area_id )
    if s_area ~= nil then        
        self.areaName:setData(CopyData.area_id)
        self.star:setAreaStar(CopyData.area_id, showType)
    
        -- 显示区域副本
        --TimerMgr.runNextFrame(function()
            if self ~= nil and self.showAreaCopy ~= nil then
                -- 显示副本点
                self:showAreaCopy(CopyData.area_id, showType)
                -- 显示获得星星数
                self:showStarsEffect(self.currLayer.list)
                -- 显示攻打boss奖励
                self:showBossReward()
            end
        --end)
    end
end
-- 重置UI
function NCopyUI:resetUI()
    ----- 测试代码 -----
    if CopyData.curSelectUI == const.kCopyMaterial then
        self:releaseMaterialUI()
    end
    -- 移除之前的副本
    self.currLayer.bg:removeAllChildren()
    self.copyLine = nil
    local list = self.currLayer.list
    while #list > 0 do
       local obj = table.remove(list, 1)
       obj:setSelected()
       table.insert(self.buildPool, obj)
    end
    -- 暂停选中效果
    if self.effect ~= nil and self.effect:getParent() ~= nil then
        self.effect:removeFromParent()
    end
    -- self.effect:setVisible(false)
end
--获取连接线
function NCopyUI:setLine(area_id, stype, count)
    if self.copyLine and (area_id ~= self.copyLine.area_id or stype ~= self.copyLine.stype) then
        self.copyLine:removeFromParent()
        self.copyLine = nil
    end

    if self.copyLine then
        return
    end
    local CopyLine = nil
    local id = ((area_id - 1) % 4) + 1
    if const.kCopyMopupTypeElite == stype then
        if 1 == area_id then
            self.copyLine = CopyLineElite0.new()
        elseif 1 == id then
            self.copyLine = CopyLineElite1.new()
        elseif 2 == id then
            self.copyLine = CopyLineElite2.new()
        elseif 3 == id then
            self.copyLine = CopyLineElite3.new()
        elseif 4 == id then
            self.copyLine = CopyLineElite4.new()
        end
    else
        if 1 == area_id then
            self.copyLine = CopyLineNormal0.new()
        elseif 1 == id then
            self.copyLine = CopyLineNormal1.new()
        elseif 2 == id then
            self.copyLine = CopyLineNormal2.new()
        elseif 3 == id then
            self.copyLine = CopyLineNormal3.new()
        elseif 4 == id then
            self.copyLine = CopyLineNormal4.new()
        end
    end

    self.copyLine:setTouchEnabled(false)
    self.copyLine.area_id = area_id
    self.copyLine.stype = stype
    if not self.copyLine:getParent() then
        self.currLayer.bg:addChild(self.copyLine, 0)
    end

    local max = #self.areaList[stype][area_id] - 1
    if not count then
        count = 0
    end
    for i = 1, 20 do
        if self.copyLine["line_" .. i] then
            self.copyLine["line_" .. i]:setOpacity(0)
        else
        end
    end
    for i = 1, max do
        if i <= count then
            self.copyLine["line_" .. i]:setOpacity(255)
        else
            self.copyLine["line_" .. i]:setOpacity(0)
        end
    end
end
-- 显示副本区域
function NCopyUI:showAreaCopy(area_id, stype)
    local copy_id = CopyData.getNextCopyId(stype)
    if const.kCopyMopupTypeElite == stype then
        if area_id > math.floor(copy_id / 1000) and CopyData.area_id - 1 > 0 then
            CopyData.area_id = CopyData.area_id - 1
            self:onUpdate()
            return
        end
    end

    -- 绘画副本点及线条
    -- local list = self.areaList[stype][area_id]
    -- local listPass = CopyData.getAreaCopyList(area_id, stype, true)
    local list = CopyData.getAreaCopyList(area_id, stype, true)
    local listPass = list
    local len = #list
    local building = nil
    local lastBuilding = nil
    local line = nil
    local posList = {}
    self:setLine(area_id, stype, #listPass - 1)

    for i = 1, len do
        local cid = list[i]
        local copyData = findCopy(cid)
        
        local dx = copyData.pos.first or 100
        local dy = copyData.pos.second or 100
        
        table.insert(posList, cc.p(dx, dy))
        building = self:createBuild({type = stype, copy = copyData}, dx, dy)
        
        self["building"..i] = building
        building.build_index = i
        self.currLayer.bg:addChild(building, 1)
        table.insert(self.currLayer.list, building)
        building:showOpenReadyView(stype, false)
        if copy_id == cid then
            local moveUp = cc.MoveBy:create(1, cc.p(0, 20))
            local moveDown = cc.MoveBy:create(1, cc.p(0, -20))
            building.cp:resetNameBgPt()
            building.action = building.cp.img_copy_name_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
        else
            if building.action then
                building.cp.img_copy_name_bg:stopAllActions()
                building.cp:resetNameBgPt()
            end
        end

        building:setOpenView(not (copy_id >= cid))
    end

    for i = 1, len do
        self["building"..i]:setLocalZOrder(visibleSize.height - self["building"..i]:getPositionY())
    end

    if #listPass - 1 > 0 then
        line = self.copyLine["line_" .. (#listPass - 1)]
        lastBuilding = self["building"..(#listPass - 1)]
    end
    building = self["building"..#listPass]

    if false == self:showNewCopy(area_id, building, line, lastBuilding, stype) then
        for i = 1, #list, 1 do
            building = self["building" .. i]
            if copy_id == building.data.copy.id then
                building:showOpenReadyView(stype, true)
                break
            end
        end
    end
end
-- 是否显示新副本点，若有新副本点，则执行showNewEffect
function NCopyUI:showNewCopy(area_id, building, line, lastBuilding, stype)
    local flag = false
    if stype == const.kCopyMopupTypeElite then
        local obj = CopyData.getNewBoss(CopyData.area_id, stype) -- {copy_id = 2031} -- 
        if obj ~= nil and math.floor(obj.copy_id / 1000) == CopyData.area_id then
            if (math.floor(obj.copy_id / 10) % 10) > 1 then
                flag = self:showNewEffect(area_id, building, line, lastBuilding, stype)
            end
            CopyData.newAreaBossList[CopyData.area_id][stype] = nil
        end
    else
        local copy_id = CopyData.getNextCopyId(stype)
        local area_id = math.floor( copy_id / 1000 )
        if area_id == CopyData.area_id then
            local c_copy_id = copy_id
            local pre_copy_id = CopyData.pre_copy_id
            local p_area = math.floor(pre_copy_id / 1000)
            local c_area = math.floor(c_copy_id / 1000)
            local p_copy = math.floor(pre_copy_id / 10)
            local c_copy = math.floor(c_copy_id / 10)
            if (pre_copy_id ~= 0) and (p_area == c_area) and (p_copy < c_copy) then
                CopyData.pre_copy_id = copy_id
                flag = self:showNewEffect(area_id, building, line, lastBuilding, stype)
            end
        end
    end

    return flag
end
-- 显示线条动画并显示副本点
function NCopyUI:showNewEffect(area_id, building, line, lastBuilding, stype)
    -- LogMgr.debug(">>>>>>>>> 显示线条动画")
    if not line or not building or not lastBuilding then
        return false
    end

    -- building:setVisible(false)
    -- line:setOpacity(0)
    -- building.cp.img_copy_name_bg:setVisible(false)
    -- building.cp:setTouchEnabled(false)
    -- a_fadein(line, 1, nil, function ()
    --     building:setOpenView(true, stype)
    --     building:setVisible(true)
    --     building:openEffectPlay(stype)
    -- end)

    return true
end
--重播新副本出现动画
function NCopyUI:ReplayNewCopy(building, stype)
    -- Command.run( 'ui hide', 'BossInfoUI' )

    if building then
        if not self.copyLine or 1 == building.build_index then
            building:setOpenView(true, stype)
            building:openEffectPlay(stype)
            return
        end

        Command.run("loading wait show", 'copy_newbuilding', 3)
        building:setVisible(false)
        building:setOpenView(true, stype)
        local line = self.copyLine["line_" .. (building.build_index - 1)]
        line:setOpacity(0)
        building.cp.img_copy_name_bg:setVisible(false)
        building.cp:setTouchEnabled(false)
        a_fadein(line, 1, nil, function ()
            building:setVisible(true)
            building:openEffectPlay(stype)
        end)
    end
end
-- 显示获得星数效果
function NCopyUI:showStarsEffect(b_list)
   -- self.starReward = {copy_id = 1031, star = 3}
    if nil ~= self.starReward then
        local copy_id = self.starReward.copy_id
        local star = self.starReward.star
        
        for k, v in pairs(b_list) do
            local c_id = v.data.copy.id
            if copy_id == c_id then
                for i = 1, star do
                    local starView = ccui.ImageView:create("copy_star_light.png", ccui.TextureResType.plistType)
                    starView:setScale(2)
                    starView:setPosition(cc.p(v:getPositionX(), v:getPositionY()))
                    local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
                    layer:addChild(starView, 5)
                    local move1 = cc.MoveBy:create(0.2, cc.p(math.random(-50, 50), math.random(-50, 50)))
                    local delay = cc.DelayTime:create(0.2)
                    local move2 = cc.MoveTo:create(0.5, cc.p(self.star:getPositionX(), self.star:getPositionY() + 100))
                    local function callback()
                        starView:removeFromParent(true)
                        showScaleEffect(self.star.image)
                    end
                    starView:runAction(cc.Sequence:create(move1, delay, move2, cc.CallFunc:create(callback)))
                end
                break
            end
        end
        
        self.starReward = nil
    end
end
-- 添加副本背景
function NCopyUI:addCopyBg()
    local area = findArea(CopyData.area_id)
    if area ~= nil then
        -- local page = math.floor(area.icon / 1000)
        -- if nil ~= self.bg_copy then
        --     if self.bg_copy.page ~= page then
        --         self.bg_copy:removeFromParent()
        --         self.bg_copy = nil
        --     end
        -- end
        if self.currLayerBg.bg_copy and self.currLayerBg.bg_copy.area_id ~= CopyData.area_id then
            self.currLayerBg.bg_copy:removeFromParent()
            self.currLayerBg.bg_copy = nil
        end

        if nil == self.currLayerBg.bg_copy then
            --local texture = LoadMgr.getRefMapTexture(prePath .. "copyBg/copy_select_bg_" .. page .. ".jpg")
            --self.bg_copy = Sprite:createWithTexture(texture)
            self.currLayerBg.bg_copy = Sprite:create(prePath .. "copyBg/copy_select_bg_" .. (((CopyData.area_id - 1) % 4) + 1) .. ".jpg")
            self.currLayerBg.bg_copy.area_id = CopyData.area_id
            self.currLayerBg.bg_copy:setAnchorPoint(0, 0)
            self.currLayerBg:addChild(self.currLayerBg.bg_copy)
            self:addBgConfig(self.currLayerBg.bg_copy)


            local size = self.currLayerBg.bg_copy:getContentSize()
            self.currLayerBg.bg_copy:setPosition((visibleSize.width - size.width) / 2, (visibleSize.height - size.height) / 2)
            self.currLayer.bg:setPosition((visibleSize.width - size.width) / 2, (visibleSize.height - size.height) / 2)
        end
    end
end
-- 添加背景点击事件
function NCopyUI:addBgConfig(view)
    local prev_x = nil
    local function touchBegan(touch, eventType)
        prev_x = touch:getLocation().x
        return true
    end
    local function touchEnded(touch, eventType)
        if self.copySelect.index == const.kCopyMaterial then 
            return 
        end

        if self.isMove == true then return end
        local next_x = touch:getLocation().x
        local dx = next_x - prev_x
        if math.abs(dx) >= 280 then
            if dx > 0 then
                if CopyData.area_id > 1 then 
                    CopyData.area_id = CopyData.area_id - 1
                    self.moveDir = -1
                    self:moveCopyLayer()
                end
            elseif dx < 0 then
                if self:hasAreaList(CopyData.area_id + 1, CopyData.area_type) == true then
                    CopyData.area_id = CopyData.area_id + 1
                    self.moveDir = 1
                    self:moveCopyLayer()
                end
            end
        end
    end
    UIMgr.addTouchBegin(view, touchBegan)
    UIMgr.addTouchEnded(view, touchEnded)
end
-- 移动副本Layer
function NCopyUI:moveCopyLayer(srcArea_id)
    local area_id = CopyData.area_id

    local result, str = CopyData.checkOpenArea(area_id)
    if not result then
        -- CopyData.area_id = CopyData.area_id - 1
        -- local area = findArea(area_id)
        CopyData.area_id = srcArea_id or CopyData.area_id
        --TipsMgr.showError(str)
        local area = findArea(area_id)
        if area then
            AlteractData.need_level = area.level
        end
        AlteractData.showByData(const.kCoinTeamXp)
        return
    end

    -- if self.isMove == false then
    self.isMove = true
    local prev_layer = self.currLayer
    self.currLayer = self.layer_1
    if prev_layer == self.layer_1 then 
        self.currLayer = self.layer_2 
    end

    local prev = self.currLayerBg
    self.currLayerBg = self.layer_3
    if prev == self.layer_3 then
        self.currLayerBg = self.layer_4
    end
    
    local prev_x = visibleSize.width
    local curr_x = 0
    if self.moveDir == -1 then 
        self.currLayer:setPosition(-visibleSize.width, 0)
        self.currLayerBg:setPositionX(-visibleSize.width)
    else
        self.currLayer:setPosition(visibleSize.width, 0)
        self.currLayerBg:setPositionX(visibleSize.width)
        prev_x = -visibleSize.width
        curr_x = 0
    end
    self:showUI()
    
    local delay =  0.5

    local prev_action = cc.MoveTo:create(delay, cc.p(prev_x, 0))
    prev_layer:runAction(prev_action)
    
    local curr_action = cc.MoveTo:create(delay, cc.p(curr_x, 0))
    self.currLayer:runAction(curr_action)

    prev_action = cc.MoveTo:create(delay, cc.p(prev_x, 0))
    prev:runAction(prev_action)
    
    curr_action = cc.MoveTo:create(delay, cc.p(curr_x, 0))
    self.currLayerBg:runAction(curr_action)

    local function callback()
        self.isMove = false
    end
    performWithDelay(self, callback, delay)
    -- end
end

function NCopyUI:onClose()
    EventMgr.removeList(self.event_list)

    ----- 测试代码 -----
    if CopyData.curSelectUI == const.kCopyMaterial then
        self:releaseMaterialUI()
    end
    if self.effect ~= nil and self.effect.stop ~= nil then
        self.effect:stop()
        if self.effect:getParent() ~= nil then
            self.effect:removeFromParent(true)
        end
    end
    if self.mainchat ~= nil then 
        self.mainchat:onClose()
        self.mainchat:removeFromParent()
    end 

    if self.top ~= nil then
        self.top:resetShow()
    end
    if self.right ~= nil then
        self.right:resetShow()
    end

    local list = self.layer_1.list
    while #list > 0 do
        local obj = table.remove(list, 1)
        obj:setSelected()
        table.insert(self.buildPool, obj)
    end
    list = self.layer_2.list
    while #list > 0 do
        local obj = table.remove(list, 1)
        obj:setSelected()
        table.insert(self.buildPool, obj)
    end
    while #self.buildPool > 0 do
        local obj = table.remove(self.buildPool, 1)
        TimerMgr.releaseLater(obj)
        -- obj:release()
    end
    self:removeChild(self.paomaui)
    EventMgr.removeListener(EventType.PaomaEvent, self.showPaomaUI)  
    -- if nil ~= self.bg_copy then
    --     self.bg_copy:removeFromParent()
    --     self.bg_copy = nil
    -- end
--    EventMgr.dispatch( EventType.NCopyUIHide )
end

function NCopyUI:dispose()
    if self.effect ~= nil and self.effect.stop ~= nil then
        self.effect:stop()
        if self.effect:getParent() ~= nil then
            self.effect:removeFromParent(true)
        end
        self.effect:release()
    end
    self.effect = nil
end

Command.bind("cmd enter copy", function()
    CopyRewardData.prePosi = gameData.user.copy.posi + 1
    Command.run( 'scene enter', 'copy' )
end)
------------------------------------ 副本资源采集 --------------------------------
NCopyUI.material_pos = {
    cc.p(244, 351),
    cc.p(473, 487),
    cc.p(504, 247),
    cc.p(757, 239),
    cc.p(906, 351),
    cc.p(744, 470)
}
function NCopyUI:updateMaterialList()
    if not self.material_points then
        LogMgr.error("updateMaterialList failed")
        return
    end
    for i = 1, 6 do
        self.material_points[i]:update(gameData.user.copy_material_list[i])
    end
end

function NCopyUI:updateMaterialPoint(materialPoint)
    if not self.material_points then
        LogMgr.error("updateMaterialPoint failed")
        return
    end
    self.material_points[materialPoint.collect_level]:update(materialPoint)
end

function NCopyUI:onPaperSkillChange()
    local cur_skill = PaperSkillData.getSkillId()
    if cur_skill == 0 then
        SceneMgr.leaveScene()
        CopyData.curSelectUI = const.kCopyMopupTypeNormal
    end
end

function NCopyUI:showMaterialUI()
    local function collectCallback(level)
        local star_x, star_y = self.skillArea.active_score_bg:getPosition()
        local world_pos = self.skillArea:convertToWorldSpace(cc.p(star_x, star_y))
        local node_pos = self.currLayer:convertToNodeSpace(world_pos)
        local star = ccui.ImageView:create()
        star:loadTexture("image/ui/PaperSkillUI/xin2.png", ccui.TextureResType.localType)
        star:setPosition(node_pos)
        self.currLayer.bg:addChild(star)
        local point_pos = NCopyUI.material_pos[level]
        if not self.material_points then
            LogMgr.error("paper material collect callback failed")
            return
        end
        local item_x, item_y = self.material_points[level].item_icon:getPosition()
        a_move_SpeedDown(star, self.currLayer.bg, 80, 0.5, 4, {x = point_pos.x + item_x, y = point_pos.y + item_y}, nil, function ()
            local need_score = PaperSkillData.getCollectCost(level)
            TipsMgr.showGreen(string.format("手工活力-%d", need_score))
            trans.send_msg("PQPaperCollect", {collect_level = level})
            self.material_points[level]:setTouchEnabled(true)
        end)
    end

    self.areaName:setImage("material_name.png")
    
    self:hideCopyInfo()
    self.copySelect:setVisible(true)
    self.copySelect:setSelect(const.kCopyMaterial)

    -- 删掉旧背景
    if self.currLayerBg.bg_copy then
        self.currLayerBg.bg_copy:removeFromParent()
        self.currLayerBg.bg_copy = nil
    end

    self.currLayerBg.bg_copy = Sprite:create(prePath .. "copyBg/material_collect_bg.jpg")
    self.currLayerBg.bg_copy:setAnchorPoint(0, 0)
    self.currLayerBg:addChild(self.currLayerBg.bg_copy)

    local size = self.currLayerBg.bg_copy:getContentSize()
    self.currLayerBg.bg_copy:setPosition((visibleSize.width - size.width) / 2, (visibleSize.height - size.height) / 2)
    self.currLayer.bg:setPosition((visibleSize.width - size.width) / 2, (visibleSize.height - size.height) / 2)

    self.material_points = {}
    for i = 1, 6 do
        local material = NCopyMaterial.new()
        material:setLevel(i, collectCallback)
        material:init()
        material:setPosition(self.material_pos[i])
        if i > #gameData.user.copy_material_list then
            material:setUnable()
        else
            material:update(gameData.user.copy_material_list[i])
        end
        self.currLayer.bg:addChild(material)
        self.material_points[i] = material
        self['material_points_'..i] = material 
    end

    local skillArea = NCopyActiveScore.new()
    skillArea:updateScore()
    skillArea:setPositionX(visibleSize.width - skillArea:getSize().width)
    local bg_y = self.currLayer.bg:getPositionY()
    skillArea:setPositionY(self.top:getPositionY() - skillArea:getSize().height - bg_y)
    self.currLayer.bg:addChild(skillArea)
    self.skillArea = skillArea

    EventMgr.dispatch( EventType.ShowMaterialUI )

    EventMgr.addListener(EventType.UpdateMaterial, self.updateMaterialList, self)
    EventMgr.addListener(EventType.UpdateMaterialPoint, self.updateMaterialPoint, self)
    EventMgr.addListener(EventType.UserOther, self.onPaperSkillChange, self)
end

function NCopyUI:releaseMaterialUI()
    EventMgr.removeListener(EventType.UpdateMaterial, self.updateMaterialList)
    EventMgr.removeListener(EventType.UpdateMaterialPoint, self.updateMaterialPoint)
    EventMgr.removeListener(EventType.UserOther, self.onPaperSkillChange)
    if self.material_points then
        for _, v in ipairs(self.material_points) do
            v:destroy()
            v:removeFromParent()
        end
        self.material_points = nil
    end
    self.skillArea:destroy()
    self.skillArea:removeFromParent()
    self.skillArea = nil
end
