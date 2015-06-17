local prePath = "image/ui/TotemStarUpUI/"
local prePath2 = "image/ui/TotemStarUpUI/otherlocal/"
--local prePath3 = "image/ui/CardUI/otherlocal/"

TotemStarUpUI = createUIClass("TotemStarUpUI", prePath .. "TotemStarUpUI.ExportJson", PopWayMgr.SMALLTOBIG)
function TotemStarUpUI:removeStyle()
    if self.styleView ~= nil then
        self.styleView:setScale(1)
        ModelMgr:recoverModel(self.styleView)
        self.styleView = nil
    end
end

function TotemStarUpUI:ctor()
    self.starPosi1 = cc.p(self.panel1:getPosition())
    self.starPosi2 = cc.p(self.arrow:getPosition())
    self.starPosi3 = cc.p(self.panel2:getPosition())
    local btnPosi = cc.p(self.button:getPosition())
    btnPosi.x = btnPosi.x + 30
    btnPosi.y = btnPosi.y - 20
    self.button:setPosition(btnPosi.x,btnPosi.y)

    local function getBtnFunc(sender, eventType)
        ActionMgr.save( 'UI', '[TotemStarUpUI] click [button]' )
        PopMgr.removeWindow(self)  
    end
    
    self.bg:loadTexture( prePath2 .. "bg.jpg",ccui.TextureResType.localType)

    UIMgr.addTouchEnded( self.button, getBtnFunc)

    self.center = cc.size(self.bg_name:getPosition())
    self.starLay = display.newNode()
    self:addChild(self.starLay,99)
    self.starList = {}
    local star = nil
    for i=1,5 do
        star = cc.Sprite:create()
        star:setAnchorPoint(0.5,0.5)
        self.starLay:addChild(star)
        star:setTexture( prePath2 .. "star.png")
        star:setVisible(false)
        table.insert( self.starList,star )
    end
end

function TotemStarUpUI:showArmatures()
    local name
    local path
    ---光束
    name = "ttbjwtgz-tx-01"
    path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effectbg1 = ArmatureSprite:addArmature(path, name, self.winName, self.bg, 570, 610)
    --图腾后面的星星
    name = "ttbjxxz-tx-01"
    path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effect1 = ArmatureSprite:addArmature(path, name, self.winName, self.bg, 570, 450)

    name = "ttbjgx-tx-01"
    path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effect1 = ArmatureSprite:addArmature(path, name, self.winName, self.bg, 570, 430)
end

function TotemStarUpUI:playTopEffect( ... )
    local function removeTopEffect( ... )
        if self.effect2 then
            self.effect2:removeFromParent()
            self.effect2 = nil
        end
    end
    local function onComplete( )
        self.effect2:stop()
        self.timeId1 = TimerMgr.runNextFrame( removeTopEffect )
    end
    --图腾上面的光
    local name = "xttcxgx-tx-01"
    local path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effect2 = ArmatureSprite:addArmature(path, name, self.winName, self, 570, 400,onComplete,55)
end

function TotemStarUpUI:playOverEffect( ... )
    --技能图标上面的光
    local name = "xck-tx-04"
    local path = string.format("image/armature/ui/cardui/%s/%s.ExportJson",name,name)
    self.effect3 = ArmatureSprite:addArmature(path, name, self.winName, self.panel2, 50, 47,nil,55)
end

function TotemStarUpUI:playBottonEffect( ... )
    local name
    local path
    ---左
    name = "zdjnbjgxz-tx-01"
    path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effectbg1 = ArmatureSprite:addArmature(path, name, self.winName, self.bg, 400, 165)
    --右
    name = "zdjnbjgxz-tx-01"
    path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effect1 = ArmatureSprite:addArmature(path, name, self.winName, self.bg, 400 + 330, 165)
end

function TotemStarUpUI:playStarEffect1( _parent)
    local function removeTopEffect( ... )
        if self.effectStar1 then
            self.effectStar1:removeFromParent()
            self.effectStar1 = nil
        end
    end
    local function onComplete( )
        self.effectStar1:stop()
        self.timeId2 = TimerMgr.runNextFrame( removeTopEffect )
    end
    local name = "sxjxgx-tx-01"
    local path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effectStar1= ArmatureSprite:addArmature(path, name, self.winName, _parent, 20, 22,onComplete,55)
end

function TotemStarUpUI:playStarEffect2( _parent)
    local function removeTopEffect( ... )
        if self.effectStar2 then
            self.effectStar2:removeFromParent()
            self.effectStar2 = nil
        end
    end
    local function onComplete( )
        self.effectStar2:stop()
        self.timeId3 = TimerMgr.runNextFrame( removeTopEffect )
    end
    local name = "sxjxgx-tx-01"
    local path = string.format("image/armature/ui/TotemStarUpUI/%s/%s.ExportJson",name,name)
    self.effectStar2= ArmatureSprite:addArmature(path, name, self.winName, _parent, 20, 25,onComplete,55)
end

function TotemStarUpUI:playArrowForeve( ... )
    self.overCount = 0
    local function onComplete( )
        self.overCount = self.overCount + 1
        if self.overCount >= 2 then
            self.arrow:stopAllActions()
        end
    end
    local posi = cc.p(20,0)
    a_forever_move(self.arrow,0.3,posi,onComplete)
end

function TotemStarUpUI:initSkillPosi( ... )
    self.panel1:setPosition(self.starPosi1.x + 160,self.starPosi1.y)
    self.arrow:setPosition(self.starPosi2.x - 50,self.starPosi2.y)
    self.arrow:setVisible(false)
    self.panel2:setPosition(self.starPosi3.x - 168,self.starPosi3.y)
end

function TotemStarUpUI:winRunAction( )
    self.isAction = true
    self:initSkillPosi()
    local function onCom( ... )
        self:runStarAction()
        self:playTopEffect()
    end
    self:bigAndSmallOut(self.title,nil)
    self:bigAndSmallOut(self.styleView,onCom)
end

function TotemStarUpUI:bigAndSmallOut(obj,callBack)
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

function TotemStarUpUI:runSkillAction( ... )
    local function onCom( ... )
       self.button:setVisible(true) 
       self:playOverEffect()
       self:playBottonEffect()
    end

    local function arrowCom( ... )
        self.arrow:setVisible(true)
        self:playArrowForeve()
    end

    local move1 = cc.MoveTo:create(0.3, self.starPosi1)
    self.panel1:runAction(move1)

    local func = cc.CallFunc:create(onCom)
    local move2 = cc.MoveTo:create(0.3, self.starPosi3)
    self.panel2:runAction(cc.Sequence:create(move2,func))

    local func_arrow = cc.CallFunc:create(arrowCom)
    local move_arrow = cc.MoveTo:create(0.1, self.starPosi2)
    self.arrow:runAction(cc.Sequence:create(move_arrow,func_arrow))
end

function TotemStarUpUI:runStarAction()
    self.moveIndex = 1
    local function callBack( )
        self.moveIndex = self.moveIndex + 1
        --播放星星上面的效果
        if self.moveIndex == self.starNum - 1 then
            self:playStarEffect1(self.starList[self.starNum-1])
        end

        if self.moveIndex == self.starNum then
            self:playStarEffect2(self.starList[self.starNum])
        end

        if( self.moveIndex > self.starNum) then
            self:runSkillAction()
            return
        end
        self:moveOut(self.moveIndex,callBack)   
    end
    if self.starNum > 2 then
        local len =self.starNum - 2 
        for i=1, len do
            if i == len then
                self:moveOut(self.moveIndex,callBack)
            else
                self:moveOut(self.moveIndex,nil)
                self.moveIndex = self.moveIndex + 1
            end
        end
    else
        self:moveOut(self.moveIndex,callBack)
    end
end

function TotemStarUpUI:moveOut( index ,callBack )
    if index <= self.starNum - 2 then
        self:moveOut1(index,callBack) 
    else
        self:moveOut2(index,callBack) 
    end
end

function TotemStarUpUI:moveOut1( index ,callBack)
    local obj = self.starList[index] 
    obj:setVisible(true)
    if callBack and index > self.starNum then
        callBack()
        return
    end
    local tar_p = cc.p(obj:getPosition())
    local src_p = cc.p(tar_p.x + 50,tar_p.y)
    obj:setOpacity(0)
    a_move_fadein_bs(obj, 0.2, src_p,tar_p, callBack)
end

function TotemStarUpUI:moveOut2( index ,callBack)
    local obj = self.starList[index] 
    obj:setVisible(true)
    if callBack and index > self.starNum then
        callBack()
        return
    end
    local tar_p = cc.p(obj:getPosition())
    local src_p = cc.p(tar_p.x + 100,tar_p.y)
    obj:setOpacity(0)
    a_move_fadein_bs(obj, 0.4, src_p,tar_p, callBack)
end

function TotemStarUpUI:resetStarPosi( num )
    local star = nil
    local starWidth = 0
    for i=1,5 do
        star = self.starList[i]
        if i <= num then
            star:setPosition(i * 48, 0)
            star:setVisible(true)
            starWidth = star:getPositionX() + 50
        else
            star:setPosition(0,0)
            star:setVisible(false)
        end
    end
    self.starLay:setPosition(self.center.width - starWidth/2,180 + 55 )
end

function TotemStarUpUI:onShow()
    local function delayHandler()
        --self.bg_name:loadTexture( prePath .. "botemget_bg_name.png",ccui.TextureResType.localType)
        local url = "image/ui/TotemUI/TotemGet/botemget_button.png"
        self.button:loadTextureNormal( url, ccui.TextureResType.localType )

        self:showArmatures()
        self:updateData()
    end
    performNextFrame(self, delayHandler)
end

function TotemStarUpUI:onClose()
    self:removeStyle()
    if self.callBack ~= nil then
        self.callBack()
        self.callBack = nil
    end

    if self.gTimer ~= nil  then
        TimerMgr.killTimer(self.gTimer)
        self.gTimer = nil
    end
end

function TotemStarUpUI:setData( curTotemStarUp,callBack )
    self.curTotemStarUp = curTotemStarUp
    self.callBack = callBack
    self:updateData()
end

function TotemStarUpUI:updateData()
    --测试
    --TotemData.TotemGetId = 80201
    -- self.passSkill:setVisible(false)
    -- self.actSkill:setVisible(false)
    if self.curTotemStarUp == nil then
        return
    end

    if not self.styleView then
        self.jTotem = findTotem( self.curTotemStarUp )
        if self.jTotem then
            self.sTotem = TotemData.getTotemById(self.jTotem.id)
            if self.sTotem ~= nil then
                local style = self.jTotem.animation_name .. self.sTotem.level
                self.styleView = ModelMgr:useModel(style, const.kAttrTotem, self.jTotem.animation_name, self.sTotem.level)
                self.styleView:setScale(1.5)
                self.styleView:setPosition(568,270 + 50)
                if self.styleView:getParent() == nil then
                    self:addChild(self.styleView,5)
                end
                --self.name:setString( self.jTotem.name )
                self.starNum=self.sTotem.level
                self.button:setVisible(false)
                self:resetStarPosi(self.starNum)

                self:updateSkill()

                --已经正在
                if self.isAction then
                    return
                end

                for k,v in pairs(self.starList) do
                    v:setVisible(false)
                end
                self:winRunAction()
            end
        end
    end
end

function TotemStarUpUI:updateSkill( ... )
    local url1 = TotemData.getBigQuFrame( self.sTotem.level - 1 )
    local url2 = TotemData.getBigQuFrame( self.sTotem.level )
    self.panel1.skillIcon_1:loadTexture(url1, ccui.TextureResType.plistType)
    self.panel2.skillIcon_2:loadTexture(url2, ccui.TextureResType.plistType)
    self.panel2.arrAdd:setString("")
    UIFactory.setSpriteChild(self.panel1.skillIcon_1, "icon", false, TotemData.getAvatarUrl(self.jTotem), 49, 49)
    UIFactory.setSpriteChild(self.panel2.skillIcon_2, "icon", false, TotemData.getAvatarUrl(self.jTotem), 49, 49)
    local jTotemArr = findTotemAttr(self.jTotem.id, self.sTotem.level)
    if jTotemArr then
        if jTotemArr.skill_up_desc then
            self.panel2.arrAdd:setString(jTotemArr.skill_up_desc)
        end
    end
end