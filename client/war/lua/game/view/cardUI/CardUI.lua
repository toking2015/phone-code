-- create by 谭春映 --
require "lua/utils/action.lua"
require "lua/game/view/getUI/SoldierGetUI.lua"
require "lua/game/view/cardUI/CardDefine.lua"
require "lua/game/view/cardUI/CardGet.lua"

local prePath = "image/ui/CardUI/"
local prePath2 = "image/ui/CardUI/otherlocal/"

--声明类
local url = prePath .. "bg.ExportJson"
CardUI = createUIClass("CardUI", url, PopWayMgr.SMALLTOBIG)
--CardUI.sceneName = "common" --显示这个UI要切换到common场景
--CardUI.sceneMap = "" --如果要指定特定的背景图片

function CardUI:addEvent( )
    EventMgr.addList(self.event_list)
end

function CardUI:stopSound()
    if self.sound_id then
        SoundMgr.stopEffect(self.sound_id)
        self.sound_id = nil
    end
    
    if self.sound_timer then
        TimerMgr.killTimer(self.sound_timer)
        self.sound_timer = nil
    end
end

function CardUI:playSound()
    self:stopSound()
    self.sound_id = SoundMgr.playEffect("sound/Ambiences/Ambiences_jitan.mp3")
    local function loopSound()
        self:playSound()
    end

    self.sound_timer = TimerMgr.startTimer( loopSound, 9)
end

function CardUI:onShow()
    self:starTimer()
    self:playSound()
    --Command.run( 'altar info' )

    --测试
    --SoldierData.soldierGetUI(nil,10801)
    --TotemData.showTotemGet(80201)\
    --TotemData.TotemGetId = 80201
    --Command.run( 'ui show', 'TotemGetUI',nil,true)
end

function CardUI:onClose()
    self:stopSound()
    EventMgr.removeList(self.event_list)
    self:removeTimer()
    ModelMgr:releaseUnFormationModel()
    --解除请求相关
    CardData.qLock = false
    Command.run("loading wait hide", "cardq")
end

function CardUI:updateData( )
    if self.top then
        self.top:updateData()
    end
    --普通
    if self.norBack then
        self.nor_one_cost = tonumber( findGlobal("altar_lottery_money_onece_cost").data )
        self.nor_ten_cost = tonumber( findGlobal("altar_lottery_money_ten_cost").data )
        local norOne = self.norBack.btnOne
        norOne.useItem:setVisible(false)
        norOne.useMoney:setVisible(true)
        norOne.useFree:setString("")

        norOne.useMoney.need:setString(string.format("X%d", self.nor_one_cost))
        local norTen = self.norBack.btnTen
        norTen.need:setString(string.format("X%d", self.nor_ten_cost))
        self:setTxtLabel_Nor()
    end

    --钻石
    if self.dimBack then
        self.dim_one_cost = tonumber( findGlobal("altar_lottery_gold_onece_cost").data )
        self.dim_ten_cost = tonumber( findGlobal("altar_lottery_gold_ten_cost").data )
        local dimOne = self.dimBack.btnOne
        dimOne.useItem:setVisible(false)
        dimOne.useGold:setVisible(true)
        dimOne.useFree:setString("")

        dimOne.useGold.need:setString(string.format("X%d", self.dim_one_cost))
        local dimTen = self.dimBack.btnTen
        dimTen.need:setString(string.format("X%d", self.dim_ten_cost))
        self:setTxtLabel_Dim()
    end
end

function CardUI:setTxtLabel_Nor()
    if self.norBack then
        local sCount = VarData.getVar("altar_lottery_money_count")
        local times = sCount%10
        local leftCount = 10 - times
        if times == 9 then
            --最后一次
            self.norBack.txt:loadTexture("cardui_nor_txt3.png",ccui.TextureResType.plistType)
            self.norBack.count:setVisible(false)
        else
            self.norBack.txt:loadTexture("cardui_nor_txt2.png",ccui.TextureResType.plistType)
            self.norBack.count:setVisible(true)
            self.norBack.count:setString( leftCount - 1 )
        end
    end
end

function CardUI:setTxtLabel_Dim()
    if self.dimBack then
        local sCount = VarData.getVar("altar_lottery_gold_count")
        local times = sCount%10
        local leftCount = 10 - times
        if times == 9 then
            --最后一次
            self.dimBack.txt:loadTexture("cardui_dim_txt3.png",ccui.TextureResType.plistType)
            self.dimBack.count:setVisible(false)
        else
            self.dimBack.txt:loadTexture("cardui_dim_txt2.png",ccui.TextureResType.plistType)
            self.dimBack.count:setVisible(true)
            self.dimBack.count:setString( leftCount - 1 )
        end
    end
end

function CardUI:moneyFree( ... )
    if self.norBack then
        local norOne = self.norBack.btnOne
        norOne.useItem:setVisible(false)
        norOne.useMoney:setVisible(false)
        norOne.useFree:setString("免费抽取")
    end
end

function CardUI:goldFree( ... )
    if self.dimBack then
        local dimOne = self.dimBack.btnOne
        dimOne.useItem:setVisible(false)
        dimOne.useGold:setVisible(false)
        dimOne.useFree:setString("免费抽取")
    end
end

function CardUI:starTimer()
    if self == nil then 
        return
    end

    local function idle()
        if self.timerCount <= 5 then
            self.timerCount = self.timerCount + 1
            if self.timerCount == 1 then
                self:InitNorFront()
            elseif self.timerCount == 2 then
                self:InitDimFront()
            elseif self.timerCount == 3 then
                self:initBgEffect()
            elseif self.timerCount == 4 then
                self:InitDimFrontEffect()
            elseif self.timerCount == 5 then
                -- self:InitTop()
                self:addEvent()
                self:updateData()
            end
        else
            local info = CardData.getInfo()
            if info == nil then
                return
            end
            self:refrueNormalTime(info)
            self:refrueDimTime(info)
        end
    end

    self:removeTimer()
    self.timerCount = 0
    self.timeVal = TimerMgr.startTimer( idle, 0.05, false )
end

function CardUI:updateUseItemForNor( ... )
    local isRedShow = false
    local norOne = nil
    if self.norBack then
        norOne = self.norBack.btnOne
    end

    local useItem = toS3UInt32( findGlobal("altar_lottery_money_onece_item_cost").data )
    local jItem = findItem(useItem.objid)
    if jItem then
        local packNum = ItemData.getItemCount(useItem.objid,const.kBagFuncCommon)
        if packNum >= useItem.val then
            isRedShow = true
            if norOne then
                norOne.useItem:setVisible(true)
                norOne.useMoney:setVisible(false)
                norOne.useItem.icon:loadTexture( ItemData.getItemUrl(jItem.id), ccui.TextureResType.localType )
                norOne.useItem.need:setString("X" .. useItem.val)
                norOne.useItem.left:setString(packNum)
            end
        end
    end
    return isRedShow
end

--钻石抽卡使用抽卡卷
function CardUI:updateUseItemForDim( ... )
    local isRedShow = false
    local dimOne = nil
    if self.dimBack then
        dimOne = self.dimBack.btnOne
    end

    local useItem = toS3UInt32( findGlobal("altar_lottery_gold_onece_item_cost").data )
    local jItem = findItem(useItem.objid)
    if jItem then
        local packNum = ItemData.getItemCount(useItem.objid,const.kBagFuncCommon)
        if packNum >= useItem.val then
            isRedShow = true
            if dimOne then
                dimOne.useItem:setVisible(true)
                dimOne.useGold:setVisible(false)
                dimOne.useItem.icon:loadTexture( ItemData.getItemUrl(jItem.id), ccui.TextureResType.localType )
                dimOne.useItem.need:setString("X" .. useItem.val)
                dimOne.useItem.left:setString(packNum)
            end
        end
    end
    return isRedShow
end

function CardUI:refrueNormalTime( info )

    if self.norFront ~= nil then
        local leftTime = CardData.getNorCdLTime()
        local txtLay = self.norFront.txtLay
        txtLay.cd:setString( string.format( "今日免费次数：%d/5", info.free_count ))
        local isRedShow = false
        txtLay.cd2:setString( "")
        if info.free_count > 0 and leftTime <= 0  then
            txtLay.cd2:setString( "当前可抽取")
            self:moneyFree()
            isRedShow = true
        else
            if info.free_count > 0 then
                txtLay.cd2:setString( CardData.secondToString(leftTime) .."后可抽取")
            end
            isRedShow = self:updateUseItemForNor()
        end

        if self.norFrontGo then
            local size = self.norFrontGo:getSize()
            local off = cc.p(size.width - 8,size.height - 8)
            setButtonPoint( self.norFrontGo, isRedShow ,off)
        end

        if self.norOneBtn then
            local _size = self.norOneBtn:getSize()
            local _off = cc.p(_size.width - 8,_size.height - 8)
            setButtonPoint( self.norOneBtn, isRedShow ,_off)
        end 
    end
end

function CardUI:refrueDimTime(info)

    if self.dimFront ~= nil then
        local leftTime = CardData.getDimCdLTime()
        local txtLay = self.dimFront.txtLay
        txtLay.cd:setString( string.format( "免费次数： %s", 1 ))
        local isRedShow = false
        if leftTime > 0  then
            --没有免费
            txtLay.cd:setString( string.format( "免费次数： %s", 0 ))
            txtLay.cd2:setString( CardData.secondToString(leftTime) .. "后可获得1次免费" )
            --使用道具情况
            isRedShow = self:updateUseItemForDim()
        else
            self:goldFree()
            txtLay.cd:setString( string.format( "免费次数： %s", 1 ))
            txtLay.cd2:setString( "")
            if CardData.getDimCdLTime() <= 0 then
                isRedShow = true
            end
        end

        if not CardData.isDimOpen() then
            isRedShow = false
        end
        
        if self.dimFrontGo then
            local size = self.dimFrontGo:getSize()
            local off = cc.p(size.width - 8,size.height - 8)
            setButtonPoint( self.dimFrontGo, isRedShow ,off)
        end
        
        if self.dimOneBtn then
            local _size = self.dimOneBtn:getSize()
            local _off = cc.p(_size.width - 8,_size.height - 8)
            setButtonPoint( self.dimOneBtn, isRedShow ,_off)
        end 
    end
end

function CardUI:removeTimer()
    if self == nil then
        return
    end

    if self.timeVal ~= 0  then
        TimerMgr.killTimer(self.timeVal)
    end
end

function CardUI:dispose( )
    self:removeTimer()
end

function CardUI:ctor()
    self.isUpRoleTopView = true
    local function update()
        self:updateData()
    end
    self.bg:loadTexture( prePath2 .. "main_bg.jpg",ccui.TextureResType.localType)
    CardDefine.size = self:getContentSize()
    CardDefine.center = cc.size(CardDefine.size.width/2,CardDefine.size.height/2)

    self.event_list = {}
    self.event_list[EventType.UserCardUpdate] = update
    self.event_list[EventType.UserVarUpdate] = update
end

function CardUI:initBgEffect( )
    if self.bgEffect then
        return
    end

    local path1 = 'image/armature/ui/cardui/ckdg-tx-01/ckdg-tx-01.ExportJson'
    self.bgEffect = ArmatureSprite:addArmature(path1, 'ckdg-tx-01', self.winName, self.bg, 0, 680)
end

function CardUI:norToBack( )
    SoundMgr.playEffect("sound/ui/card.mp3")
    self:InitNorBack()
    local function toBack2( ... )
        self:isShowFront_Nor(false)
        self:runSecond(self.norBack,1)
    end

    if self.norFront.small then
        self:dimToFront()
        return
    end
    self:isShowFront_Nor(true)
    self.norFront.txtLay:setVisible(false)
    self:runFirst(self.norFront,-1,toBack2)
    self:toSmall(self.dimFront)
end

function CardUI:norToFront( ... )
    SoundMgr.playEffect("sound/ui/card.mp3")
    local function OnCom( )
        self.norFront.txtLay:setVisible(true)
        self:toBig(self.dimFront)
    end

    local function tofront2( ... )
        self:isShowFront_Nor(true)
        self:runSecond(self.norFront,-1,OnCom)
    end

    self:isShowFront_Nor(false)
    self:runFirst(self.norBack,1,tofront2)
end

--金币模块初始化(正面)
function CardUI:InitNorFront( )
    if self.norFront then
        return
    end

    local function toBack( sender )
        ActionMgr.save( 'UI', 'CardUI click norFrontGo '.. sender:getName() )
        self:norToBack()
    end

    self.norFront = getLayout(prePath .. "norFront.ExportJson")
    self.norFront.bg:loadTexture( prePath2 .. "selectNor.png",ccui.TextureResType.localType)
    self.norFront:setAnchorPoint(0.5,0.5)
    self:addChild(self.norFront)
    self.norFront:setPosition(CardDefine.center.width - 230,CardDefine.center.height)
    self.norFront.small = false
    self.norFront.txtLay.cd:setString('')
    self.norFront.txtLay.cd2:setString('')

    self.norFrontGo = createScaleButton(self.norFront.btnGo)
    self.norFrontGo:addTouchEnded(toBack)
    UIMgr.addTouchBegin(self.norFront.bg,toBack)
end

--金币模块初始化(反面)
function CardUI:InitNorBack( )
    if self.norBack then
        return
    end

    --普通召唤
    local function normalQ( sender, eveType )
        ActionMgr.save( 'UI', 'CardUI click norQ ' .. sender:getName() )
        if eveType ~= ccui.TouchEventType.ended then
            return
        end
        self.nor_one_cost = tonumber( findGlobal("altar_lottery_money_onece_cost").data )
        self.nor_ten_cost = tonumber( findGlobal("altar_lottery_money_ten_cost").data )
        local name = sender:getName()
        if name == "btnOne" then
            self.norQTime = 1
        else
            self.norQTime = 10 
        end
        CardData.norQ(self.norQTime,self.nor_one_cost,self.nor_ten_cost)
    end

    local function tofront( sender )
        ActionMgr.save( 'UI', 'CardUI click norBack ' .. sender:getName())
        self:norToFront()
    end

    self.norBack = getLayout(prePath .. "norBack.ExportJson")
    self.norBack.bg:loadTexture( prePath2 .. "carduio_normalb.png",ccui.TextureResType.localType)
    self.norBack:setAnchorPoint(0.5,0.5)
    self:addChild(self.norBack)
    self.norBack:setPosition(CardDefine.center.width - 230,CardDefine.center.height)
    self.norBack:setVisible(false)
    self.norBack.btnOne.useItem.icon:setScale(0.4)

    UIMgr.addTouchBegin(self.norBack.bg,tofront)
    self.norOneBtn = createScaleButton(self.norBack.btnOne)
    self.norOneBtn:addTouchEnded(normalQ)
    self.norTenBtn = createScaleButton(self.norBack.btnTen)
    self.norTenBtn:addTouchEnded(normalQ)
    self:setTxtLabel_Nor()

    -- local path2 = 'image/armature/ui/cardui/mfts-tx-01/mfts-tx-01.ExportJson'
    -- self.freeEffectNor = ArmatureSprite:addArmature(path2, 'mfts-tx-01', self.winName, self.norBack.btnOne, 0, 0)
    -- self.freeEffectNor:retain()

    self:updateData()
end

function CardUI:dimToBack( ... )
    SoundMgr.playEffect("sound/ui/card.mp3")
    self:InitDimBack()
    local function toBack2( ... )
        self:isShowFront_Dim(false)
        self:runSecond(self.dimBack,1)
    end
    if self.dimFront.small then
        self:norToFront()
        return
    end
    self:isShowFront_Dim(true)
    self.dimFront.txtLay:setVisible(false)
    self:runFirst(self.dimFront,-1,toBack2)
    self:toSmall(self.norFront)
end

function CardUI:dimToFront( ... )
    SoundMgr.playEffect("sound/ui/card.mp3")
    local function OnCom( )
        self.dimFront.txtLay:setVisible(true)
        self:toBig(self.norFront)
    end
    local function tofront2( ... )
        self:isShowFront_Dim(true)
        self:runSecond(self.dimFront,-1,OnCom)
    end
    self:isShowFront_Dim(false)
    self:runFirst(self.dimBack,1,tofront2)
end

function CardUI:InitDimFrontEffect( ... )
    local path1 = 'image/armature/ui/cardui/kg-tx-01/kg-tx-01.ExportJson'
    self.effect1 = ArmatureSprite:addArmature(path1, 'kg-tx-01', "CardUI", self.dimFront.bg, 50, 420)
end

function CardUI:InitTop( ... )
    self.top = RoleTopView:create()
    self.top:setPositionX(visibleSize.width - self.top:getBoundingBox().width - 10)
    self.top:setPositionY(visibleSize.height - self.top:getBoundingBox().height)
    self:addChild(self.top, 1)
end

--钻石模块初始化(正面)
function CardUI:InitDimFront( )
    if self.dimFront then
        return
    end
    --钻石召唤
    local function toBack( sender )
        ActionMgr.save( 'UI', 'CardUI click dimFrontGo ' .. sender:getName() )
        self:dimToBack()
    end

    self.dimFront = getLayout(prePath .. "dimFront.ExportJson")
    self.dimFront.bg:loadTexture( prePath2 .. "selectDim.png",ccui.TextureResType.localType)
    self.dimFront:setAnchorPoint(0.5,0.5)
    self:addChild(self.dimFront)
    self.dimFront:setPosition(CardDefine.center.width + 230,CardDefine.center.height)
    self.dimFront.small = false
    self.dimFront.txtLay.cd:setString('')
    self.dimFront.txtLay.cd2:setString('')

    self.dimFrontGo = createScaleButton(self.dimFront.btnGo)
    self.dimFrontGo:addTouchEnded(toBack)
    UIMgr.addTouchBegin(self.dimFront.bg,toBack)
end

--钻石模块初始化(正面)
function CardUI:InitDimBack( )
    if self.dimBack then
        return
    end

    --钻石召唤
    local function dimQ( sender, eveType )
        ActionMgr.save( 'UI', 'CardUI click dimQ ' .. sender:getName() )
        self.dim_one_cost = tonumber( findGlobal("altar_lottery_gold_onece_cost").data )
        self.dim_ten_cost = tonumber( findGlobal("altar_lottery_gold_ten_cost").data )
        local name = sender:getName()
        if name == "btnOne" then
            self.dimQTime = 1
        else
            self.dimQTime = 10 
        end
        CardData.dimQ(self.dimQTime,self.dim_one_cost, self.dim_ten_cost)
    end
    local function tofront( ... )
        ActionMgr.save( 'UI', 'CardUI click dimBack' )
        self:dimToFront()
    end

    self.dimBack = getLayout(prePath .. "dimBack.ExportJson")
    self.dimBack.bg:loadTexture( prePath2 .. "carduio_dimb.png",ccui.TextureResType.localType)
    self.dimBack:setAnchorPoint(0.5,0.5)
    self:addChild(self.dimBack)
    self.dimBack:setPosition(CardDefine.center.width + 230,CardDefine.center.height)
    self.dimBack:setVisible(false)
    local path2 = 'image/armature/ui/cardui/kg-tx-02/kg-tx-02.ExportJson'
    self.effect2 = ArmatureSprite:addArmature(path2, 'kg-tx-02', "CardUI", self.dimBack.bg, -25, 415)
    self.dimBack.btnOne.useItem.icon:setScale(0.4)

    UIMgr.addTouchBegin(self.dimBack.bg,tofront)
    self.dimOneBtn = createScaleButton(self.dimBack.btnOne)
    self.dimOneBtn:addTouchEnded(dimQ)
    self.dimTenBtn = createScaleButton(self.dimBack.btnTen)
    self.dimTenBtn:addTouchEnded(dimQ)
    self:setTxtLabel_Dim()
        
    self:updateData()
end

function CardUI:runSecond( obj,dir,Com )
    local angle = dir * 75
    local orbit = cc.OrbitCamera:create(0.05,1, 0, 0, angle, 0, 0)
    local function OnCom( )
        if Com then
            Com()
        end
    end
    local callBack = cc.CallFunc:create(OnCom)
    local action = cc.Sequence:create(orbit:reverse(),callBack)
    obj:runAction(action)
end

function CardUI:runFirst( obj,dir,next )
    local angle = dir * 105
    local orbit = cc.OrbitCamera:create(0.05,1, 0, 0, angle, 0, 0)
    local callBack = cc.CallFunc:create(next)
    local action = cc.Sequence:create(orbit,callBack)
    obj:runAction(action)
end

function CardUI:toSmall( obj )
    obj.small = true
    local action = cc.ScaleTo:create(0.01,0.5, 0.5)
    obj:runAction(action)
end
function CardUI:toBig( obj )
    obj.small = false
    local action = cc.ScaleTo:create(0.01,1, 1)
    obj:runAction(action)
end

function CardUI:isShowFront_Nor( b )
    self.norFront:setVisible(b)
    self.norBack:setVisible(not b)
end

function CardUI:isShowFront_Dim( b )
    self.dimFront:setVisible(b)
    self.dimBack:setVisible(not b)
end
