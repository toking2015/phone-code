--**获得英雄**谭春映
------------------------------------
SoldierGetUI = {}
local prePath = "image/ui/GetUI/SoldierGetUI/"
local prePath2 = "image/ui/CardUI/otherlocal/"
--声明类
local url = prePath .. "getSoldier.ExportJson"
SoldierGetUI = createUIClass("SoldierGetUI", url, PopWayMgr.SMALLTOBIG)

function SoldierGetUI:remove()
    self._isUpLayer = true
    if self.getCallBack ~= nil then
    	self:getCallBack()
    end
    self.getCallBack = nil
    self.soldier_id = 0
    self.isPlay = false
    if self.styleView ~= nil then
        ModelMgr:recoverModel(self.styleView)
        self.styleView = nil
    end
end

function SoldierGetUI:setCloseCB( func,d ,replaceReward)
   self.getCallBack = func 
   self.soldier_id = d
   self.replaceReward = replaceReward
   self:updateData()
end

function SoldierGetUI:onShow()
    SoundMgr.playUI("ui_getrole")
    EventMgr.addList(self.event_list)
    self:ctorSplit()
   -- self:updateData()
end

function SoldierGetUI:onClose()
    EventMgr.removeList(self.event_list)
    
    local soldierId =  self.soldier_id
    EventMgr.dispatch( EventType.SoldierGetUIClose, soldierId )
        
    self:remove() 
    self:removeTimer()
    self.isRunAction = false
    --ModelMgr:releaseUnFormationModel()
end

function SoldierGetUI:updateData()
    if self.isInitSplit then
        return
    end

    local soldier = findSoldier(self.soldier_id)
    if soldier == nil then
        return
    end
    if not self.playSound then
        SoundMgr.playSoldierTalk(self.soldier_id)
        self.playSound = true
    end
    --已经正在动画
    if not self.isRunAction then
        if not self.replaceReward then
            --SoundMgr.playUI("card_soldier")
            self.isGet:setVisible(false)
        else
            --SoundMgr.playUI("card_item")
            self.isGet:setVisible(true)
            self.isGet.txt:setString(string.format("已有此英雄，转化为%s灵魂石",self.replaceReward.val))
            self.isGet.icon:loadTexture( ItemData.getItemUrl(self.replaceReward.objid), ccui.TextureResType.localType )
        end

        self.starNum = soldier.star
        -- local serverData = SoldierData.getSoldierBySId(self.soldier_id)
        -- if serverData then
        --     self.starNum=serverData.star
        -- end
        
        --self.starNum = 3 --测试
        if not self.styleView then
            self.styleView = ModelMgr:useModel(soldier.animation_name)
            self.styleView:setPosition(568,270 - 30)
            if self.styleView:getParent() == nil then
                self:addChild(self.styleView,5)
            end
            self.styleView:setScale(1.5)
            self.styleView:playOne(false, "physical1")
        end
        self.name:setString( soldier.name )

        self.btn_get:setVisible(false)
        self:resetStarPosi(self.starNum)
        for k,v in pairs(self.starList) do
            v:setVisible(false)
        end
        self.isRunAction = true
        self:winRunAction()
    end
end

function SoldierGetUI:winRunAction( )
    local function onCom( ... )
        self:runStarAction()
    end
    self:bigAndSmallOut(self.nameBg,onCom)
    self:bigAndSmallOut(self.name)
end

function SoldierGetUI:runStarAction()
    self.moveIndex = 1
    local function callBack( )
        self.moveIndex = self.moveIndex + 1
        if( self.moveIndex > self.starNum) then
            self.btn_get:setVisible(true)
            return
        end
        SoundMgr.playUI("star")
        self:scaleOut(self.moveIndex,callBack)   
    end
    SoundMgr.playUI("star")
    self:scaleOut(self.moveIndex,callBack)
end

function SoldierGetUI:scaleOut( index ,callBack)
    local obj = self.starList[index] 
    obj:setVisible(true)
    if index > self.starNum then
        callBack()
        return
    end
    obj:setOpacity(0)
    a_scale_fadein_bs(obj, 0.1, {x = 5, y = 5},{x = 1, y = 1}, callBack)
end

function SoldierGetUI:bigAndSmallOut(obj,callBack)
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

function SoldierGetUI:resetStarPosi( num )
    local star = nil
    local starWidth = 0
    for i=1,6 do
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

function SoldierGetUI:removeTimer( )
    if self.gTimer ~= nil  then
        TimerMgr.killTimer(self.gTimer)
        self.gTimer = nil
    end
end

function SoldierGetUI:ctorSplit( )
    if self.gTimer then
    	return
    end

    local function loop()
        self.gCount = self.gCount +1
        if self.gCount == 1 then
            self:ctorStar()
        elseif self.gCount == 3 then
            self:ctorEffect1()
        elseif self.gCount == 5 then
            self:ctorEffect2()
            self.isInitSplit = false
            self:removeTimer()
            self:updateData()
        end
    end
    self.gCount = 0
    self.gTimer = TimerMgr.startTimer( loop, 0.05, false )
end

function SoldierGetUI:ctorStar( ... )
    self.starLay = display.newNode()
    self:addChild(self.starLay,99)
    self.starList = {}
    local star = nil
    for i=1,6 do
        star = cc.Sprite:create()
        star:setAnchorPoint(0.5,0.5)
        self.starLay:addChild(star)
        star:setTexture( prePath2 .. "card_star2.png")
        star:setVisible(false)
        table.insert( self.starList,star )
    end
end

function SoldierGetUI:ctorEffect1( )
    local path1 = 'image/armature/ui/cardui/dtyg-tx-01/dtyg-tx-01.ExportJson'
    self.bgEffect = ArmatureSprite:addArmature(path1, 'dtyg-tx-01', self.winName, self.bg, 0, 654)
end

function SoldierGetUI:ctorEffect2( )
    local path2 = 'image/armature/ui/cardui/wjdg-tx-01/wjdg-tx-01.ExportJson'
    local path3 = 'image/armature/ui/cardui/ztxg-tx-01/ztxg-tx-01.ExportJson'
    self.bgLigth = ArmatureSprite:addArmature(path2, 'wjdg-tx-01', self.winName, self.bg, 568, 380)
    self.starEffect = ArmatureSprite:addArmature(path3, 'ztxg-tx-01', self.winName, self.Image_13, 180, 56)
end

function SoldierGetUI:ctor()
    self.isInitSplit = true
    self.isPlay = false
    self.playSound = false
    local function update()
        self:updateData()
    end

    local function getBtnFunc(sender, eventType)
        performNextFrame(self, function() PopMgr.removeWindowByName('SoldierGetUI') end)
    end
    self.isGet:setVisible(false)
    self.isGet.icon:setScale(0.4)
    self.bg:loadTexture( prePath2 .. "soldier_bg.jpg",ccui.TextureResType.localType)

    self.nameBg:loadTexture( prePath2 .. "card_name_bg2.png",ccui.TextureResType.localType)
    self.btn_get = createScaleButton(self.btnGet)
    self.btn_get:setAnchorPoint(cc.p(1, 0))
    local size = self:getContentSize()
    self.center = cc.size(size.width/2,size.height/2)
    self.btn_get:setPosition(self.center.width + visibleSize.width/2 - 10,self.center.height - visibleSize.height/2 + 10)
    self.btn_get:setVisible(false)

    self.btn_get:addTouchEnded(getBtnFunc)
    self.event_list = {}
    self.event_list[EventType.UserCardUpdate] = update
end