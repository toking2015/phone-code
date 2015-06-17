--**谭春映
--**英雄系统【升阶成功】
---********************---
local prePath = "image/ui/SoldierStepUI/"
--声明类
local url = prePath .. "stepSuccess.ExportJson"
SoldierStepSuccess = createUIClass("SoldierStepSuccess", url, PopWayMgr.SMALLTOBIG)

function SoldierStepSuccess:onShow()
    if SoldierDefine.stepUpSoldier then
        SoundMgr.playSoldierTalk( SoldierDefine.stepUpSoldier.soldier_id )
    end
    self:removeTimer()
    self.enClose = false
    local function time( ... )
        self:setTime()
    end
    EventMgr.addList(self.event_list)
    self:updateData()
    self.gTimer = TimerMgr.startTimer( time, 0.01, false )
    self.saveTime = DateTools.getMiliSecond()
end

function SoldierStepSuccess:removeTimer( ... )
    if self.gTimer ~= nil  then
        TimerMgr.killTimer(self.gTimer)
        self.gTimer = nil
    end
end

function SoldierStepSuccess:onClose()
    EventMgr.removeList(self.event_list)
    self:removeTimer()
end

function SoldierStepSuccess:onBeforeClose()
    return not true
    --return not self.enClose
end

function SoldierStepSuccess:setTime( ... )
    if not self.descArr then
        return
    end

    local len = #self.descArr 
    if len <= 0 then
        return
    end

    if self.descIndex > len then
        if self.closeCallBack then
            self.closeCallBack()
        end
        --self.Label_21:setVisible(true)
        --self.btnOk:setVisible(true)
        self.enClose = true
        return
    end

    local dTime = DateTools.getMiliSecond() - self.saveTime
    if dTime > 0.01 then
        self.openKillLay.desc:setString(self.descArr[self.descIndex]) 
        self.descIndex = self.descIndex + 1
        self.saveTime = DateTools.getMiliSecond()
    end
end

function SoldierStepSuccess:updateData()
    if self.serverData ~= nil then
        local soldierInfo = findSoldier(self.serverData.soldier_id)
       -- local soldierBase = findSoldierBase(self.serverData.soldier_id)
        local soldierQualityPre = findSoldierQuality(SoldierDefine.qStepQualify)
        local soldierQualityCur = findSoldierQuality(SoldierDefine.qStepQualify + 1)
        if soldierInfo then
            for k=1,2 do
                local headView = self.headList[k]
                --满阶
                if k == 2 and not soldierQualityCur then
                    headView:setVisible(false)
                    break
                end

                url = SoldierData.getAvatarUrl(soldierInfo)
                headView.style:loadTexture( url, ccui.TextureResType.localType )
                headView.name:setString(soldierInfo.name)
                local color = QualityData.getColor(SoldierData.getQualityAndNum( SoldierDefine.qStepQualify + 1 ))
                headView.name:setColor(color)
                local starNum = self.serverData.star
                local qualityD = soldierQualityPre
                if k == 2 then
                    qualityD = soldierQualityCur
                end

                local q1 = qualityD.quality_effect.first
                local q2 = qualityD.quality_effect.second
                url = prePath .. "soldierstep_q"..q1..".png"
                headView.style_bg:loadTexture( url, ccui.TextureResType.localType )

                if q2 > 0 then
                    headView.numLay:setVisible(true)
                    url = "soldierstep_qn"..q2..".png"
                    headView.numLay.qNum:loadTexture( url, ccui.TextureResType.plistType )
                else
                    headView.numLay:setVisible(false)
                end

                for i=1,6 do
                    if i <= starNum then
                        headView["star" .. i ]:loadTexture("star_2.png", ccui.TextureResType.plistType)
                    else
                        headView["star" .. i ]:loadTexture("star_1.png", ccui.TextureResType.plistType)
                    end
                end

            end
            local actSkill = 0
            local addPoint = 0
            if soldierQualityCur then
                actSkill = soldierQualityCur.skill_active - soldierQualityPre.skill_active
                addPoint = soldierQualityCur.skill_point - soldierQualityPre.skill_point
            end
            --新开技能
            if ( actSkill  > 0 or soldierQualityCur.lv == 2 ) then
                local newSkillId = 0
                local skillLv= 0
                if soldierQualityCur.lv == 2 then
                    newSkillId = soldierInfo.skills[2].first
                    skillLv = SoldierData.getLevel( self.serverData.skill_list,newSkillId )
                    local skillInfo = findSkill( newSkillId,skillLv)
                    self:setActSKillInfo(skillInfo)
                else
                    newSkillId = soldierInfo.odds[soldierQualityCur.skill_active]
                    skillLv= SoldierData.getLevel(self.serverData.skill_list,newSkillId)
                    oddInfo = findOdd(newSkillId.first,skillLv)
                    self:setPassSKillInfo(oddInfo)
                end
                self.skillOpen = true
            else
                self.skillOpen = false
            end
        end
        local preValue = SoldierDefine.upPreFight
        local curValue = SoldierData.getFightValue(self.serverData.guid,const.kAttrSoldier)
        self.openFightLay.bg1.fightNum:setString(preValue)
        self.openFightLay.bg2.fightNum:setString(curValue)
    end
end

function SoldierStepSuccess:getSpace( width )
    local space = ''
    local len = math.ceil(width/self.spaceW)
    for i=1,len do
        space = space .. '　'
    end
    return space
end

function SoldierStepSuccess:setActSKillInfo(skillInfo )
    if skillInfo ~= nil then
        --技能图标
        local skillUrl = SkillData.killUrlByJson(skillInfo)
        self.openKillLay.icon:loadTexture( skillUrl, ccui.TextureResType.localType )
        self.openKillLay.skillName:setString(skillInfo.name .. "：")
        local width = self.openKillLay.skillName:getContentSize().width
        local sp = self:getSpace(width)
        self.desc = filterDesc( sp .. skillInfo.desc )
    end
end

function SoldierStepSuccess:setPassSKillInfo( oddInfo )
    if oddInfo ~= nil then
        --技能图标
        local skillUrl = SkillData.oddUrlByJson(oddInfo)
        self.openKillLay.icon:loadTexture( skillUrl, ccui.TextureResType.localType )
        self.openKillLay.skillName:setString(oddInfo.name.. "：")
        local width = self.openKillLay.skillName:getContentSize().width
        local sp = self:getSpace(width)
        self.desc = filterDesc( sp .. oddInfo.description )
    end
end

function SoldierStepSuccess:setData( data , callBack)
    self.descArr = {}
    self.serverData = data
    self:updateData()
    self:runActionView()
    self.closeCallBack = callBack
end

function SoldierStepSuccess:runFightAction( )
    self.enClose = true
    --self.Label_21:setVisible(true)
    self.openFightLay:setVisible(true)
    setUiOpacity(self.openFightLay,0)
    setUIFade(self.openFightLay,cc.FadeIn,0.1)
end

function SoldierStepSuccess:runActionTxt( )
    self.descArr = {}
    self.descIndex = 1
    local str = self.desc
    if str then
        len = string.len(str)
        for i=1,len do
            local resultStr = str.sub(str,1,i)
            table.insert(self.descArr,resultStr)
        end
    end
end

function SoldierStepSuccess:runActionApha( objList )

    self.aphaIndex = 1
    local function callBack( )
        self.aphaIndex = self.aphaIndex + 1
        if( self.aphaIndex > #objList) then
            self:runActionTxt()
            return
        end
        local objNew = objList[self.aphaIndex]
        objNew:setVisible(true)
        self:AphaOut(objNew,callBack)
    end

    local obj = objList[self.aphaIndex]
    obj:setVisible(true)
    self:AphaOut(obj,callBack)
end

function SoldierStepSuccess:AphaOut(obj,callBack)
    local base = 0.1
    local FadeIn1 = cc.FadeIn:create(base)
    local a_delay1 = cc.DelayTime:create( 0.3 )
    local func = cc.CallFunc:create(callBack)

    local se = cc.Sequence:create(FadeIn1,a_delay1,func)
    obj:runAction(se)
end

function SoldierStepSuccess:runOpenSkillAction( )
    self.openKillLay:setVisible(true)
    self.openKillLay.desc:setString("")
    local objList = { self.openKillLay.skillName}
    for k,v in pairs(objList) do
        v:setVisible(false)
    end
    local function callBack( )
        self:runActionApha(objList)
    end
    a_scale_fadein( self.openKillLay.skillBg,0.3,{x = 1,y = 1},callBack)
    a_scale_fadein( self.openKillLay.icon,0.3,{x = 1,y = 1})
    a_scale_fadein( self.openKillLay.new,0.3,{x = 1,y = 1})
end

function SoldierStepSuccess:runActionView( )
    self.openKillLay:setVisible(false)
    local objList = { self.headList[1],self.arrow ,self.headList[2] }
    self.moveIndex = 1
    for k,v in pairs(objList) do
        v:setVisible(false)
    end
    local function callBack( )
        self.moveIndex = self.moveIndex + 1
        if( self.moveIndex > #objList) then
            if self.skillOpen then
                self:runOpenSkillAction()
            else
                self:runFightAction()
            end
            return
        end

        local objNew = objList[self.moveIndex]
        self:moveApha_Out(objNew,callBack)
        
    end

    local obj = objList[self.moveIndex]
    self:moveApha_Out(obj,callBack)
end

function SoldierStepSuccess:moveApha_Out( obj ,callBack)
    obj:setVisible(true)
    self:moveOut(obj,callBack)
    setUiOpacity(obj,0)
    setUIFade(obj,cc.FadeIn,0.1)
end

function SoldierStepSuccess:moveOut(obj,callBack)
    local a_move1 = cc.MoveTo:create(0.1, obj.posi)
    local a_delay1 = cc.DelayTime:create( 0.2 )
    local func = cc.CallFunc:create(callBack)
    local se = cc.Sequence:create(a_move1,func)
    obj:runAction(se)
end

function SoldierStepSuccess:ctor( )
    -- local function test( ... )
    --     PopMgr.removeWindowByName("SoldierInfo")
    --     PopMgr.removeWindowByName("SoldierUI")
    -- end
    self.headList = {}
    self.arrList = {}
    self.saveTime = 0
    local function update( )
        self:updateData()
    end
    self.openKillLay.skillName:setString('　')
    self.spaceW = self.openKillLay.skillName:getContentSize().width
    self.openKillLay:setVisible(false)
    self.openFightLay:setVisible(false)
    self.arrow.posi = cc.p( self.arrow:getPosition() )
    self.arrow:setPosition(self.arrow.posi.x - 50,self.arrow.posi.y  )

    for i=1,2 do
        local headView = getLayout(prePath .. "soldierHead.ExportJson")
        self:addChild(headView)
        headView:setPosition(34 + (i-1) * 289,170)
        self.headList[i] = headView
        headView.sPosi = cc.p( headView.style:getPosition() )
        headView.style:setPosition(headView.sPosi.x, headView.sPosi.y + 16 )
        headView.posi = cc.p( headView:getPosition() )
        headView:setPosition(headView.posi.x - 50,headView.posi.y  )
        --buttonDisable(headView,false)
        --UIMgr.addTouchEnded(headView,test)
    end

    local function exit( sender,type )
        ActionMgr.save( 'UI', 'SoldierStepSuccess click bg' )
        PopMgr.removeWindow(self)
    end
    buttonDisable(self.bg,false)
    UIMgr.addTouchEnded( self.bg,exit )

    local function exitByOk( sender,type )
        ActionMgr.save( 'UI', 'SoldierStepSuccess click btnOk' )
        PopMgr.removeWindow(self)
    end

    buttonDisable(self.btnOk,false)
    createScaleButton(self.btnOk,false)
    self.btnOk:addTouchEnded(exitByOk)
    self.btnOk:setVisible( true )

    self.Label_21:setVisible(false)
    self.event_list = {}
    self.event_list[EventType.UserSoldierUpdate] = update
end