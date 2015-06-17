CardGetSoidier = {}
local prePath = "image/ui/CardUI/"
local prePath2 = "image/ui/CardUI/otherlocal/"
--声明类
local url = prePath .. "getSoldier.ExportJson"
CardGetSoidier = createUIClass("CardGetSoidier", url, PopWayMgr.SMALLTOBIG)

function CardGetSoidier:remove()
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

function CardGetSoidier:setCloseCB( func,d )
   self.getCallBack = func 
   self.soldier_id = d
   self:updateData()
end

function CardGetSoidier:onShow()
    EventMgr.addList(self.event_list)
   -- self:updateData()
end

function CardGetSoidier:onClose()
    EventMgr.removeList(self.event_list)
    self:remove() 
end

function CardGetSoidier:updateData()
    if self == nil  then
        return
    end

    local soldier = findSoldier(self.soldier_id)
    if soldier == nil then
        return
    end

    self.starNum = 1
    local serverData = SoldierData.getSoldierBySId(self.soldier_id)
    if serverData then
        self.starNum=serverData.star
    end
    
    --self.starNum = 3 --测试
    if not self.styleView then
        self.styleView = ModelMgr:useModel(soldier.animation_name)
        self.styleView:setPosition(568,270)
        if self.styleView:getParent() == nil then
            self:addChild(self.styleView,5)
        end
        self.styleView:playOne(false, "physical1")
    end
    self.name:setString( soldier.name )

    self.btn_get:setVisible(false)
    self:resetStarPosi(self.starNum)
    --已经正在动画
    if self.moveIndex and self.moveIndex > 1 then
        return
    end
    for k,v in pairs(self.starList) do
        v:setVisible(false)
    end
    self:runStarAction()
end

function CardGetSoidier:runStarAction()
    self.moveIndex = 1
    local function callBack( )
        self.moveIndex = self.moveIndex + 1
        if( self.moveIndex > self.starNum) then
            self.btn_get:setVisible(true)
            return
        end
        self:scaleOut(self.moveIndex,callBack)   
    end
    self:scaleOut(self.moveIndex,callBack)
end

function CardGetSoidier:scaleOut( index ,callBack)
    local obj = self.starList[index] 
    obj:setVisible(true)
    if index > self.starNum then
        callBack()
        return
    end
    obj:setOpacity(0)
    a_scale_fadein_bs(obj, 0.1, {x = 5, y = 5},{x = 1, y = 1}, callBack)
end

function CardGetSoidier:resetStarPosi( num )
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

function CardGetSoidier:ctor()
    self.isPlay = false
    local function update()
        self:updateData()
    end

    local function getBtnFunc(sender, eventType)
        ActionMgr.save( 'UI', 'CardGetSoidier click btn_get' )
        self:remove()
        PopMgr.removeWindow(self)  
    end
    
    self.bg:loadTexture( prePath2 .. "soldier_bg.jpg",ccui.TextureResType.localType)
    local path1 = 'image/armature/ui/cardui/dtyg-tx-01/dtyg-tx-01.ExportJson'
    local path2 = 'image/armature/ui/cardui/wjdg-tx-01/wjdg-tx-01.ExportJson'
    local path3 = 'image/armature/ui/cardui/ztxg-tx-01/ztxg-tx-01.ExportJson'
    self.bgEffect = ArmatureSprite:addArmature(path1, 'dtyg-tx-01', self.winName, self.bg, 0, 654)
    self.bgLigth = ArmatureSprite:addArmature(path2, 'wjdg-tx-01', self.winName, self.bg, 568, 380)
    self.starEffect = ArmatureSprite:addArmature(path3, 'ztxg-tx-01', self.winName, self.Image_13, 180, 56)

    self.nameBg:loadTexture( prePath2 .. "card_name_bg2.png",ccui.TextureResType.localType)
    self.btn_get = createScaleButton(self.btnGet)
    self.btn_get:setAnchorPoint(cc.p(1, 0))
    local size = self:getContentSize()
    self.center = cc.size(size.width/2,size.height/2)
    self.btn_get:setPosition(self.center.width + visibleSize.width/2 - 10,self.center.height - visibleSize.height/2 + 10)

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
    self.btn_get:addTouchEnded(getBtnFunc)
    self.event_list = {}
    self.event_list[EventType.UserCardUpdate] = update
end