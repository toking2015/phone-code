--@author zengxianrong
require "lua/game/view/formationUI/FormationView.lua"
require "lua/game/view/formationUI/FormationUI.lua"

local prePath = "image/ui/FormationUI/"

FormationWin = createUIClassEx('FormationWin', cc.Layer)

function FormationWin:ctor()
    LoadMgr.loadPlist(prePath.."FormationBG.plist", nil, LoadMgr.WINDOW, self.winName)

    self.conBtn = cc.Node:create()
    self.conBtn:setVisible(false)
    self:addChild(self.conBtn, 2)

    function self.confirmHandler()
        if self.style == FormationData.STYLE_ONE then
            self.closeResult = true
        end
        self:doBack(true)
    end

    self.btn_fight = UIFactory.getButton("formation_btn_fight.png", self.conBtn, visibleSize.width - 190, 6)
    function self.fightHandler()
        ActionMgr.save( 'UI', '[FormationWin] click [btn_fight]' )
        self.closeResult = true
        self:doBack(true)
        SoundMgr.playEffect("sound/ui/startcombat.mp3")
        self.isClickFight = true
        EventMgr.dispatch( EventType.FormationBtnFight )
    end
    self.btn_fight:addTouchEnded(self.fightHandler)

    self.event_list = {}
    self.event_list[EventType.UserFormationUpdate] = function() self:updateData() end
    local function upHandler(data)
        self:updateData()
        self.view:playSpecialAction(data)
    end
    self.event_list[EventType.UserFormationUp] = upHandler
    self.event_list[EventType.UserFormationDown] = function() self:updateData() end
    local function fightRecordGetHandler()
        FormationData.reopen = true
        Command.run("ui hide", self.winName)
    end
    self.event_list[EventType.FightRecordGet] = fightRecordGetHandler
end

function FormationWin:initFormationBtn()
    if not self.btn_formation then
        local btnPath = "image/ui/MainUI/RoleSetView.ExportJson"
        analyseExportJson(self.winName, btnPath)
        local btn_formation = getLayout(btnPath)
        createScaleButton(btn_formation)
        local function showUIHandler()
            ActionMgr.save( 'UI', '[FormationWin] click [btn_formation]' )
            self:showUI()
        end
        btn_formation:addTouchEnded(showUIHandler)
        btn_formation:removeFromParent()
        btn_formation:setPosition(visibleSize.width - 300, 10)
        self.conBtn:addChild(btn_formation)
        self.btn_formation = btn_formation
    end
    return self.btn_formation
end

function FormationWin:initRecordBtn()
    if not self.btn_record then
        local btn_record = UIFactory.getLayout(90, 100, self.conBtn)
        UIFactory.getSpriteFrame("bottom_icon2.png", btn_record, 44, 21)
        UIFactory.getSpriteFrame("formation_txt_record.png", btn_record, 44, 21)
        UIFactory.getSpriteFrame("formation_btn_record.png", btn_record, 44, 62)
        createScaleButton(btn_record)
        local function showUIHandler()
            ActionMgr.save( 'UI', '[FormationWin] click [btn_record]' )
            --请求数据
            if FormationData.isMonsterBoss and FormationData.monsterId then
                CopyData.bossRecordID = FormationData.monsterId
                Command.run("copy load fightlog", FormationData.monsterId)
                Command.run("ui show", "BossRecordUI", PopUpType.SPECIAL)
            end
        end
        btn_record:addTouchEnded(showUIHandler)
        btn_record:setPosition(visibleSize.width - 400, 10)
        self.btn_record = btn_record
    else
        self.btn_record:setVisible(true)
    end
    return self.btn_record
end

function FormationWin:initTrial()
    local trailType = TrialMgr.formationTrailType[self.type]
    if trailType then
        local lastTime = LocalDataMgr.load_string(0, "formation_trail_rule")
        local nowTime = DateTools.getDay(gameData.getServerTime())
        if not lastTime or nowTime ~= toint(lastTime) then
            Command.run("ui show", "TrialRuleUI", PopUpType.SPECIAL)
            LocalDataMgr.save_string(0, "formation_trail_rule", tostring(nowTime))
        end
        if not self.trail_title then
            self.trail_title = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_bg_title.png", self, visibleSize.width / 2, visibleSize.height - 30.5, 2)
            self.trail_title_txt = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_"..trailType..".png", self.trail_title, 112, 35)
        else
            self.trail_title_txt:setTexture(TrialMgr.prePath .. "TrialMainUI/TrialMain_"..trailType..".png")
        end
        if not self.btn_rule then
            self.btn_rule = UIFactory.getLayout(90, 100, self.conBtn, visibleSize.width - 415, 8)
            createScaleButton(self.btn_rule)
            UIFactory.getSpriteFrame("bottom_icon2.png", self.btn_rule, 45, 20, 1)
            UIFactory.getSpriteFrame("txt_ui_rule.png", self.btn_rule, 45, 20, 2)
            UIFactory.getSpriteFrame("icon_rule.png", self.btn_rule, 45, 67, 3)
            self.btn_rule:addTouchEnded(function()
                ActionMgr.save( 'UI', '[FormationWin] click [btn_rule]' )
                Command.run("ui show", "TrialRuleUI", PopUpType.SPECIAL)
            end)
        end
    end
    if self.trail_title then
        self.btn_rule:setVisible(trailType ~= nil)
    end
    if self.btn_rule then
        self.btn_rule:setVisible(trailType ~= nil)
    end
end

function FormationWin:askSaveQuit(isSave, notCheckCount, notCheckEmptyHp)
    if self:checkNoneSoldier() then
        self.closeResult = false
        return
    end
    if not notCheckCount and self.style == FormationData.STYLE_TWO and self.closeResult and self:checkSoldierCount(isSave, nil) then
        return
    end
    if not notCheckEmptyHp and self:hasDeadSoldier() then
        return
    end
    if not FormationData.compare(FormationData.backupData, FormationData.getTypeData(self.type)) then 
        local function okFun()
            FormationData.sendToServer(self.type)
            self:doHide()
        end
        local function cancelFun()
            FormationData.setTypeData(self.type, FormationData.backupData)
            self:doHide()
        end
        if true or isSave then --TASK #6793::【手游12月版】副本中的战斗的撤退后，退到布阵界面
            okFun()
        else
            showMsgBox("是否保存当前布阵？", okFun, cancelFun)
        end
    else
        self:doHide()
    end
end

function FormationWin:checkNoneSoldier()
    if self.type == const.kFormationTypeTomb then --大墓地退出不判断是否有英雄
        if not self.closeResult then
            return false
        end
    end
    local count = FormationData.getCount(self.type, const.kAttrSoldier)
    if count == 0 then
        showMsgBox("至少需要上阵一个英雄")
        return true
    end
end

function FormationWin:hasDeadSoldier()
    --检测我方阵营是否有空血武将
    if not notCheckEmptyHp and self.type == const.kFormationTypeTomb then
        local list = FormationData.getTypeData(self.type)
        for _, v in pairs(list) do
            if const.kAttrSoldier == v.attr then
                if FormationData.checkIsTombDead(v.guid) then
                    if not silent then
                        showMsgBox("阵上有已经阵亡的英雄，请更换。[btn=one]")
                    end
                    self.closeResult = false
                    return true
                end
            end
        end
    end
end

function FormationWin:checkSoldierCount(isSave, silent, notCheckEmptyHp)
    local function okFun()
        self:askSaveQuit(isSave, true)
    end
    local function cancelFun()
        self.closeResult = false
    end

    if FormationData.checkCanUpSoldier(self.type) then
        if not silent then
            showMsgBox("你还有英雄可以上阵，是否直接开战？", okFun, cancelFun)
        end
        return true
    end
    if FormationData.checkCanUpTotem(self.type) then
        if not silent then
            showMsgBox("你还有图腾可以上阵，是否直接开战？", okFun, cancelFun)
        end
        return true
    end
end

function FormationWin:doBack(isSave, notCheckEmptyHp)
    -- if self.isUIMoving then
    --     return
    -- end
    if self.style == FormationData.STYLE_ONE then
        self:askSaveQuit(isSave, nil, notCheckEmptyHp)
    elseif self.style == FormationData.STYLE_TWO then
        if self.isUIShow then
            self:hideUI()
        else
            self:askSaveQuit(isSave, nil, notCheckEmptyHp)
        end
    end
end

function FormationWin:initBottomButtons()
    if self.style == FormationData.STYLE_TWO then
        self:initFormationBtn()
        if self.type == const.kFormationTypeCommon and FormationData.isMonsterBoss and gameData.getSimpleDataByKey("team_level") > 20 then
            self:initRecordBtn()
        else
            if self.btn_record then
                self.btn_record:setVisible(false)
            end
        end
        self.conBtn:setVisible(true)
    else
        self.conBtn:setVisible(false)
    end
end

function FormationWin:onShow()
    EventMgr.addList(self.event_list)

    CopyMgr.isChange = false
    self.style = FormationData.style
    self.type = FormationData.type
    self.closeResult = false
    self.isClickFight = false
    self.canFormation = FormationData.getCanFormation(self.type)
    if not self.canFormation then --设置推荐布阵
        FormationData.setRecommendFormation()
    end
    FormationData.downIllegalRole(self.type) --把非法的角色下阵
    performNextFrame(self, self.initBottomButtons, self)

    self:addView()
    self:initTrial()
    if self.style == FormationData.STYLE_ONE then
        performNextFrame(self, self.showUI, self)
    end
   	self:updateData(true)
    Command.bind("formation show ui", function() self:showUI() end)
    Command.bind("formation hide ui", function() self:hideUI() end)
    Command.bind("formation confirm", self.confirmHandler)
    local function setUIAttrIndex(index)
        self.ui:setAttrIndex(index)
    end
    Command.bind("formation ui changetab", setUIAttrIndex)
    Command.bind("formation fight", self.fightHandler)
end

function FormationWin:addView()
    local scene = SceneMgr.getCurrentScene()
    local bg = FightBackground:getInstance()
    if not bg:getParent() then
        scene:addChild(bg, 5) --背景层
        self.bg = bg
    end
    self.view = FormationView.new()
    scene:addChild(self.view, 6) --圈层
    scene:addChild(self.view.con, 7) --人物层
    local vSize = self.view:getContentSize()
    self.view:setPosition((visibleSize.width - vSize.width) / 2, (visibleSize.height - vSize.height) / 2)
    self.view:setType(self.type)
    self.view:setOppFormation(FormationData.oppFormation)
end

function FormationWin:removeView()
    if self.view then
        self.view:dispose()
        self.view:removeFromParent()
        self.view = nil
    end
    if self.bg then
        self.bg:dispose()
        self.bg:removeFromParent()
        self.bg = nil
    end
end

function FormationWin:backHandler()
    self:doBack(nil, true)
end

function FormationWin:doHide()
    CopyData.fightData = nil
    if self.isUIShow then
        self:hideUI(true)
    else
        PopMgr.removeWindow(self)
    end
end

function FormationWin:showUI()
    if self.isUIMoving then
        return
    end
    --创建UI
    if not self.ui then
        self.ui = FormationUI.new()
        self:addChild(self.ui, 3)
        local size = self.ui:getContentSize()
        self.ui:setPosition(visibleSize.width + size.width, (visibleSize.height - size.height) / 2)
        self.ui:setType(self.type)
        self.ui:setStyle(self.style)
        self.ui:updateData()
    end
    self.ui:setAttr(FormationData.attr) --设置选中的标签页
    --动画
    local size = self.ui:getContentSize()
    local dy = (visibleSize.height - size.height) / 2
    local moveToLeft = cc.MoveTo:create(0.3, cc.p(visibleSize.width - size.width, dy))
    self.isUIShow = true
    self.isUIMoving = true
    local function completeHandler()
        self.isUIMoving = false
        EventMgr.dispatch( EventType.FormationUIShow )
    end
    self.ui:runAction(cc.Sequence:create(moveToLeft, cc.CallFunc:create(completeHandler)))
end

function FormationWin:hideUI(isCloseWin)
    -- if self.isUIMoving then
    --     return
    -- end
    local size = self.ui:getContentSize()
    local dy = (visibleSize.height - size.height) / 2
    local moveToRight = cc.MoveTo:create(0.3, cc.p(visibleSize.width + size.width, dy))
    self.isUIMoving = true
    local function removeFunc()
        self.isUIMoving = false
        self.isUIShow = false
        if isCloseWin then
            self:doHide()
        end
    end
    self.ui:runAction(cc.Sequence:create(moveToRight, cc.CallFunc:create(removeFunc)))
end

function FormationWin:onClose()
    EventMgr.removeList(self.event_list)
    Command.unbind("formation show ui")
    Command.unbind("formation hide ui")
    Command.unbind("formation confirm")
    Command.unbind("formation ui changetab")
    Command.unbind("formation fight")
    if not FormationData.reopen then
        local exitScene = not self.closeResult
        if exitScene or self.style ~= FormationData.STYLE_TWO then
            if SceneMgr.isSceneName("fight") then
                Command.run('scene leave')
            end
        end
        self:doCallBack()
    else
        FightDataMgr:releaseLayerRole()
    end
    self:removeView()
end

function FormationWin:doCallBack()
    local okFun = FormationData.okFun
    local cancelFun = FormationData.cancelFun
    FormationData.clear()
    
    if self.closeResult then
        if okFun ~= nil then
            if self.style == FormationData.STYLE_TWO then
                self.view:recoverModel()
            else
                FightDataMgr:releaseLayerRole()
            end
            okFun()
            return
        end
    else
        if cancelFun ~= nil then
            cancelFun()
        end
    end
    FightDataMgr:releaseLayerRole()
end

function FormationWin:updateData(first)
    self:updateFightValue()
    if self.ui then
        self.ui:updateData()
    end
    if first then
        -- LoadMgr.clearAsyncCache()
        local function delayCall()
            self.view:updateData(first)
            self:updateRedPoint(first)
        end
        self:runAction(cc.CallFunc:create(delayCall))
    else
        self.view:updateData(first)
        self:updateRedPoint(first)
    end
end

function FormationWin:updateFightValue(first)
    local fightValue = FormationData.getFightValueByType(self.type)
    if not first and FormationData.lastFightValue then
        if FormationData.lastUpIndex and fightValue > FormationData.lastFightValue then
            local layer = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
            local pos = FormationData.getRolePos(FormationData.lastUpIndex)
            pos.y = pos.y + 120
            TipsMgr.showFightAdd(pos, layer, fightValue - FormationData.lastFightValue)
        end
    end
    FormationData.lastFightValue = fightValue
end

function FormationWin:updateRedPoint(first)
    if self.style == FormationData.STYLE_TWO then
        if self.btn_formation then
            setButtonPoint(self.btn_formation, self:checkSoldierCount(false, true))
        end
    end
end

function FormationWin:updateArena()
    local function delayCall()
        self.view:updateArena()
    end
    self:runAction(cc.CallFunc:create(delayCall))
end

function FormationWin:getSoldierNodeForId( soldierId )
    return self.ui and self.ui:getSoldierNodeForId( soldierId )
end

function FormationWin:getShenMingTotemNode()
    return self.ui and self.ui:getShenMingTotemNode()
end

function FormationWin:getBtnFight()
    local win = PopMgr.getWindow("FormationWin")
    if win and FormationData.getCount(const.kFormationTypeSingleArenaDef, const.kAttrSoldier) > 0 then
        return win.btn_fight
    end
    return nil 
end