local prePath = "image/ui/TotemUI/TotemGet/"
local prePath2 = "image/ui/CardUI/otherlocal/"

TotemGetUI = createUIClass("TotemGetUI", prePath .. "TotemGetUI.ExportJson", PopWayMgr.SMALLTOBIG)
function TotemGetUI:removeStyle()
    if self.styleView ~= nil then
        self.styleView:setScale(1)
        ModelMgr:recoverModel(self.styleView)
        self.styleView = nil
    end
end

function TotemGetUI:ctor()
    self.actDescArr = {}
    self.passDescArr = {}
    self.actIndex = 1
    self.passIndex = 1
    self._isUpLayer = true
    self.saveTime = 0
    local function getBtnFunc(sender, eventType)
        ActionMgr.save( 'UI', '[TotemGetUI] click [button]' )
        PopMgr.removeWindow(self)  
    end
    
    self.bg:loadTexture( prePath2 .. "soldier_bg.jpg",ccui.TextureResType.localType)

    UIMgr.addTouchEnded( self.button, getBtnFunc)

    local size = self:getContentSize()
    self.center = cc.size(size.width/2,size.height/2)
    self.starLay = display.newNode()
    self:addChild(self.starLay,99)
    self.starList = {}
    local star = nil
    for i=1,5 do
        star = cc.Sprite:create()
        star:setAnchorPoint(0.5,0.5)
        self.starLay:addChild(star)
        star:setTexture( prePath2 .. "card_star2.png")
        star:setVisible(false)
        table.insert( self.starList,star )
    end
end

function TotemGetUI:showArmatures()
    local path2 = 'image/armature/ui/cardui/wjdg-tx-01/wjdg-tx-01.ExportJson'
    local path3 = 'image/armature/ui/cardui/ztxg-tx-01/ztxg-tx-01.ExportJson'
    self.bgLigth = ArmatureSprite:addArmature(path2, 'wjdg-tx-01', self.winName, self.bg, 568, 380)
    self.starEffect = ArmatureSprite:addArmature(path3, 'ztxg-tx-01', self.winName, self.bg, 180 + 350, 56 + 510 )
end

function TotemGetUI:runDesc( )
    self.actDescArr = {}
    self.passDescArr = {}
    self.actIndex = 1
    self.passIndex = 1
    self:proccDescToArr(self.actDescArr,self.actDesc)
    self:proccDescToArr(self.passDescArr,self.passDesc)
    self.enDescAction = true
end

function TotemGetUI:winRunAction( )
    local function onCom( ... )
        self:runStarAction()
    end
    self:bigAndSmallOut(self.bg_name,onCom)
    self:bigAndSmallOut(self.name)
end

function TotemGetUI:bigAndSmallOut(obj,callBack)
    obj:setVisible(true)
    obj:stopAllActions()
    obj:setScale(0,0)
    --local rotate = cc.RotateBy:create(0.1, 360)
    local scaleBig = cc.ScaleTo:create(0.1,1.5,1.5)
    local span = cc.Spawn:create(scaleBig)
    local scaleSmall = cc.ScaleTo:create(0.1,1,1)
    local function onCom( ... )
        if callBack then
            callBack()
        end
    end

    local func = cc.CallFunc:create(onCom)
    local seq = cc.Sequence:create(span,scaleSmall,func)
    obj:runAction(seq)
end

function TotemGetUI:runStarAction()
    self.moveIndex = 1
    local function callBack( )
        self.moveIndex = self.moveIndex + 1
        if( self.moveIndex > self.starNum) then
            self:runDesc()
            return
        end
        self:scaleOut(self.moveIndex,callBack)   
    end
    self:scaleOut(self.moveIndex,callBack)
end

function TotemGetUI:scaleOut( index ,callBack)
    local obj = self.starList[index] 
    obj:setVisible(true)
    if index > self.starNum then
        callBack()
        return
    end
    obj:setOpacity(0)
    a_scale_fadein_bs(obj, 0.1, {x = 5, y = 5},{x = 1, y = 1}, callBack)
end

function TotemGetUI:resetStarPosi( num )
    local star = nil
    local starWidth = 0
    for i=1,5 do
        star = self.starList[i]
        if i <= num then
            star:setPosition(i * 62, 0)
            star:setVisible(true)
            starWidth = star:getPositionX() + 58
        else
            star:setPosition(0,0)
            star:setVisible(false)
        end
    end
    self.starLay:setPosition(self.center.width - starWidth/2,180)
end

function TotemGetUI:onShow()
    local function time( ... )
        self:showDescIdle()
    end

    self.enDescAction = false
    self.gTimer = TimerMgr.startTimer( time, 0.01, false )
    self.saveTime = DateTools.getMiliSecond()
    local function delayHandler()
        SoundMgr.playUI("ui_getrole")
        self.bg_name:loadTexture( prePath .. "botemget_bg_name.png",ccui.TextureResType.localType)
        self.title:loadTexture( prePath .. "botemget_icon_get.png",ccui.TextureResType.localType)
        self.button:loadTextureNormal( prePath..'botemget_button.png', ccui.TextureResType.localType )

        self:showArmatures()
        self:updateData()
    end
    performNextFrame(self, delayHandler)
end

function TotemGetUI:onClose()
    self:removeStyle()
    TotemData.runToTemGetCallBack()
    if self.gTimer ~= nil  then
        TimerMgr.killTimer(self.gTimer)
        self.gTimer = nil
    end
end

function TotemGetUI:showDescIdle(  )
    if not self.enDescAction then
        return
    end
    local dTime = DateTools.getMiliSecond() - self.saveTime
    if dTime > 0.04 then
        local isAct = self:runActDesc()
        if not isAct then
            local isPass = self:runPassDesc()
            if not isPass then
                self.enDescAction = false
                self.button:setVisible(true)
            end
        end
        self.saveTime = DateTools.getMiliSecond()
    end
end

function TotemGetUI:runActDesc( ... )
    local len = #self.actDescArr 
    if len <= 0 then
        return false
    end

    if self.actIndex > len then
        return false
    end

    self.actSkill.desc:setString(self.actDescArr[self.actIndex]) 
    self.actIndex = self.actIndex + 1
    return true
end

function TotemGetUI:runActDesc( )
    local len = #self.actDescArr 
    if len <= 0 then
        return false
    end

    if self.actIndex > len then
        self.actSkill.desc:setString(self.actDesc)
        return false
    end

    self.actSkill:setVisible(true)
    self.actSkill.desc:setString(self.actDescArr[self.actIndex]) 
    self.actIndex = self.actIndex + 1
    return true
end

function TotemGetUI:runPassDesc( )
    local len = #self.passDescArr 
    if len <= 0 then
        return false
    end

    if self.passIndex > len then
        self.passSkill.desc:setString(self.passDesc)
        return false
    end

    self.passSkill:setVisible(true)
    self.passSkill.desc:setString(self.passDescArr[self.passIndex]) 
    self.passIndex = self.passIndex + 1
    return true
end

function TotemGetUI:proccDescToArr( arr,str)
    local len = string.len(str)
    for i=1,len do
        local resultStr = str.sub(str,1,i)
        table.insert(arr,resultStr)
    end
end

function TotemGetUI:updateData()
    --测试
    --TotemData.TotemGetId = 80201
    self.passSkill:setVisible(false)
    self.actSkill:setVisible(false)
    if not self.styleView then
        local totem = findTotem( TotemData.TotemGetId )
        if totem ~= nil then
            local level = 1
            local sTotem = TotemData.getTotemById(totem.id)
            if sTotem then
                level = sTotem.level
            end
            self.styleView = ModelMgr:useModel(totem.animation_name .. level, const.kAttrTotem, totem.animation_name, level)
            self.styleView:setScale(1.5)
            self.styleView:setPosition(568,270)
            if self.styleView:getParent() == nil then
                self:addChild(self.styleView,5)
            end
            self.name:setString( totem.name )
            self.starNum=totem.init_lv
            self.button:setVisible(false)
            self:resetStarPosi(self.starNum)
            self.actDesc = ''
            self.passDesc = ''
            self.actSkill.desc:setString('')
            self.passSkill.desc:setString('')
            --技能
            local jskill = TotemData.getTotemInitSkill(totem)
            if jskill then
                self.actSkillFlag = true
                self.actDesc = filterDesc(jskill.desc)
            end

            local jodd = TotemData.getTotemInitOdd(totem)
            if jodd then
                self.passSkillFlag = true
                self.passDesc = filterDesc(jodd.description)
            end

            --已经正在动画PassDesc()
            if self.moveIndex and self.moveIndex > 1 then
                return
            end

            for k,v in pairs(self.starList) do
                v:setVisible(false)
            end
            self:winRunAction()
        end
    end
end