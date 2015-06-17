--**谭春映
--**英雄系统【升阶成功】
---********************---
local prePath = "image/ui/SoldierStarUI/"
--声明类
local url = prePath .. "starSuccess.ExportJson"
SoldierStarUpSuccess = createUIClass("SoldierStarUpSuccess", url, PopWayMgr.SMALLTOBIG)

function SoldierStarUpSuccess:onShow()
    self.Label_21:setVisible(false)
    self.enClose = false
    EventMgr.addList(self.event_list)
    self:updateData()
end

function SoldierStarUpSuccess:onClose()
    EventMgr.removeList(self.event_list)
end

function SoldierStarUpSuccess:onBeforeClose()
    return not true
    --return not self.enClose
end


function SoldierStarUpSuccess:updateData()
    if self.serverData ~= nil then
        local soldierInfo = findSoldier(self.serverData.soldier_id)
        local soldierQuality = findSoldierQuality(self.serverData.quality)
        if soldierInfo then
            for k=1,2 do
                local headView = self.headList[k]
                url = SoldierData.getAvatarUrl(soldierInfo)
                headView.style:loadTexture( url, ccui.TextureResType.localType )
                headView.name:setString(soldierInfo.name)
                local color = QualityData.getColor(SoldierData.getQualityAndNum(self.serverData.quality))
                headView.name:setColor(color)

                local q1 = soldierQuality.quality_effect.first
                local q2 = soldierQuality.quality_effect.second
                url = prePath .. "soldierstar_q"..q1..".png"
                headView.style_bg:loadTexture( url, ccui.TextureResType.localType )
                if q2 > 0 then
                    headView.numLay:setVisible(true)
                    url = "soldiersstar_qn"..q2..".png"
                    headView.numLay.qNum:loadTexture( url, ccui.TextureResType.plistType )
                else
                    headView.numLay:setVisible(false)
                end

                local starNum = self.serverData.star
                if k == 1 then 
                    starNum = starNum -1
                end
                for i=1,6 do
                    if i <= starNum then
                        if k == 2 and i == starNum then
                            self.newStar = headView["star" .. i ]
                        else
                            headView["star" .. i ]:loadTexture("soldierstar_star2.png", ccui.TextureResType.plistType)
                        end
                    else
                        headView["star" .. i ]:loadTexture("soldierstar_star1.png", ccui.TextureResType.plistType)
                    end
                end 
            end
        end
        local preValue = SoldierDefine.upPreFight
        local curValue = SoldierData.getFightValue(self.serverData.guid,const.kAttrSoldier)
        self.openFightLay.bg1.fightNum:setString(preValue)
        self.openFightLay.bg2.fightNum:setString(curValue)
    end
end

function SoldierStarUpSuccess:setData( data )
    self.descArr = {}
    self.serverData = data
    self:updateData()
    self:runTitleEffect()
    self:runActionView()
end

function SoldierStarUpSuccess:runTitleEffect( ... )
    local function effectComplete( ... )
        --self.titleEffect:removeNextFrame()
        --self.titleEffect = nil
        self.titleEffect:stop()
        self.titleEffect:removeNextFrame()
        self.titleEffect = nil
    end
    local path1 = 'image/armature/ui/SoldierUI/sxg-tx-01/sxg-tx-01.ExportJson'
    self.titleEffect = ArmatureSprite:addArmature(path1, 'sxg-tx-01', self.winName, 
                          self, self.title:getPositionX(),self.title:getPositionY(),effectComplete)
end

function SoldierStarUpSuccess:runNewStarEffect( ... )
    local function removeEffect( ... )
        self.newStar:loadTexture("soldierstar_star2.png", ccui.TextureResType.plistType)
        self.enClose = true
        self.btnOk:setVisible(true)
        --self.Label_21:setVisible(true)
    end
    local function effectComplete( ... )
        self.newStarEffect:stop()
        self.newStarEffect:removeNextFrame()
        self.newStarEffect = nil
        performNextFrame(self, removeEffect)
    end
    if self.newStar == nil then
        return
    end
    local path1 = 'image/armature/ui/SoldierUI/xzxx-tx-01/xzxx-tx-01.ExportJson'
    self.newStarEffect = ArmatureSprite:addArmature(path1, 'xzxx-tx-01', self.winName, 
                          self.headList[2], self.newStar:getPositionX(),self.newStar:getPositionY(),effectComplete)
end


function SoldierStarUpSuccess:runFightAction( )
    -- local function com(  )
    --     self.enClose = true
    -- end
    self.openFightLay:setVisible(true)
    setUiOpacity(self.openFightLay,0)

    -- local func = cc.CallFunc:create(com)
    -- local deLay = cc.DelayTime:create(0.1)
    -- local exAction = cc.Sequence:create(deLay,func)
    setUIFade(self.openFightLay,cc.FadeIn,0.1)
    
    
end

function SoldierStarUpSuccess:runActionTxt( )
    self.descArr = {}
    self.descIndex = 1
    local str = self.desc
    len = string.len(str)
    for i=1,len do
        local resultStr = str.sub(str,1,i)
        table.insert(self.descArr,resultStr)
    end
end

function SoldierStarUpSuccess:runActionView( )
    local objList = { self.headList[1],self.arrow ,self.headList[2] }
    self.moveIndex = 1
    for k,v in pairs(objList) do
        v:setVisible(false)
    end
    local function callBack( )
        self.moveIndex = self.moveIndex + 1
        if( self.moveIndex > #objList) then
            self:runNewStarEffect()
            self:runFightAction()
            return
        end

        local objNew = objList[self.moveIndex]
        self:moveApha_Out(objNew,callBack)
        
    end

    local obj = objList[self.moveIndex]
    self:moveApha_Out(obj,callBack)
end

function SoldierStarUpSuccess:moveApha_Out( obj ,callBack)
    obj:setVisible(true)
    self:moveOut(obj,callBack)
    setUiOpacity(obj,0)
    setUIFade(obj,cc.FadeIn,0.1)
end

function SoldierStarUpSuccess:moveOut(obj,callBack)
    local a_move1 = cc.MoveTo:create(0.1, obj.posi)
    local a_delay1 = cc.DelayTime:create( 0.2 )
    local func = cc.CallFunc:create(callBack)
    local se = cc.Sequence:create(a_move1,func)
    obj:runAction(se)
end

function SoldierStarUpSuccess:ctor( )
    self.headList = {}
    self.arrList = {}
    local function update( )
        self:updateData()
    end

    self.Label_21:setVisible(false)
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
    end

    local function exit( sender,type )
        ActionMgr.save( 'UI', 'SoldierStarUpSuccess click bg' )
        PopMgr.removeWindow(self)
    end
    buttonDisable(self.bg,false)
    UIMgr.addTouchEnded( self.bg,exit )

    local function exitByOk( sender,type )
        ActionMgr.save( 'UI', 'SoldierStarUpSuccess click btnOk' )
        PopMgr.removeWindow(self)
    end

    buttonDisable(self.btnOk,false)
    createScaleButton(self.btnOk,false)
    self.btnOk:addTouchEnded(exitByOk)
    self.btnOk:setVisible(false)

    self.event_list = {}
    self.event_list[EventType.UserSoldierUpdate] = update
end