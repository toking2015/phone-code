--获取物品 -- 谭春映
local prePath = "image/ui/CardUI/CardGetUI/"
local prePath2 = "image/ui/CardUI/otherlocal/"

--声明类
local url = prePath .. "getItem.ExportJson"
CardGet = createUIClass("CardGet", url, PopWayMgr.SMALLTOBIG)
local TYPE_ITEM = 1
local TYPE_SOLDIER= 2
local TYPE_ITEMS = 3
function CardGet:onShow()
	EventMgr.addList(self.event_list)
    local function addEffects()
        self:addBgEffect()
        self:addTitleEffect()
        self:addAgainEffect()
    end
    local function initItems()
        self:initItems()
        addEffects()
    end
    performNextFrame(self, initItems)
    self:updateData()
end
function CardGet:onClose()
    EventMgr.removeList(self.event_list)
	self:removeStyleView()
    self.isRunAction = false
    --CardDefine.showStepItem = false
end

function CardGet:updateData() 
    self:initItems()
    --local rewardData = CardData.rewardData
    local rewardData = CardData.virRewardData
    if rewardData == nil or rewardData.reward_list == nil then
        return
    end
    
    self:removeStyleView()
	self:removeItemsContent()
    self:updateBottomInfo()

	local len = #rewardData.reward_list
	local type = 0

	if len == 1 then
        local altarId = rewardData.id_list[1]
        local reward = rewardData.reward_list[1]
        local infoData = findAltar(altarId)
        if infoData then
            --一定是英雄
            if reward.cate == const.kCoinSoldier then
                type = TYPE_SOLDIER
                self.oneSoldier_id = reward.objid
                self:playStyleView() 
            else
                type = TYPE_ITEM  
                self:setData(self.oneItem,reward,altarId)
            end
        end
	else
        type = TYPE_ITEMS
		for k,v in pairs(rewardData.reward_list) do
			self:setData(self.itemList[k],v,rewardData.id_list[k])
		end
	end
    
    if not self.isRunAction then
    	self:reRunActions(type)
        self.isRunAction = true
    end
end

function CardGet:updateBottomInfo( )
    --最下边按钮
    if CardDefine.qInfo.type ~= 0 then
        local url = string.format("%scardgetitems_%d.png",prePath2,CardDefine.qInfo.times)
        self.again.btnAgain.img:loadTexture(url,ccui.TextureResType.localType)

        local need = CardDefine.qInfo.need
        local leftStr = ''
        local useItem = nil
        self.again.needIcon:setScale(1)
        if CardDefine.qInfo.type == trans.const.kAltarLotteryByGold then
            url = "diamond.png"
            self.again.needIcon:loadTexture(url,ccui.TextureResType.plistType)
            useItem = toS3UInt32( findGlobal("altar_lottery_gold_onece_item_cost").data )
        else
            url = "coin.png"
            self.again.needIcon:loadTexture(url,ccui.TextureResType.plistType)
            useItem = toS3UInt32( findGlobal("altar_lottery_money_onece_item_cost").data )
        end

        if CardDefine.qInfo.times == 1 and useItem then
            local itemN,desc = self:updateUserItem(useItem)
            if itemN then
                need = itemN
                leftStr = desc
            end
        end
        self.again.count:setString( need .. leftStr )
    end
end

function CardGet:updateUserItem( useItem )
    local jItem = findItem(useItem.objid)
    if jItem then
        local packNum = ItemData.getItemCount(useItem.objid,const.kBagFuncCommon)
        if packNum >= useItem.val then
            local url = ItemData.getItemUrl(jItem.id)
            local need = useItem.val
            self.again.needIcon:loadTexture(url,ccui.TextureResType.localType)
            self.again.needIcon:setScale(0.4)
            local leftStr = string.format("（剩余%s）",packNum)
            return need,leftStr
        end
    end
end

function CardGet:setData( obj,reward,altarId)
    local infoData = findAltar(altarId)
    if infoData == nil then
        return
    end

    obj.is_rare = infoData.is_rare
    local itemFlag = false
    if infoData.reward.cate == const.kCoinSoldier then
        obj.soldier_id = infoData.reward.objid
        obj.playSoldier = true
        --被替换为灵魂石
        if reward.cate ~= const.kCoinSoldier then
            itemFlag = true
            obj.replaceReward = reward
            obj.is_rect = 1
        else
            obj.replaceReward = nil
        end
        self:setSoldier(obj,reward)
    else
        itemFlag = true
    end

    if itemFlag then
        if reward.cate == const.kCoinGlyph then
            self:setGlyph(obj,reward)
        else
            self:setItem(obj,reward)
        end
    end

    self:setRareEffect(obj)
end

--物品
function CardGet:setItem( obj,reward )
    -- self:setSoldier(obj,reward)
    -- do return end

    local itemId = reward.objid
    local item = findItem( itemId )
    if item then
        local name1,name2 = splitName(item.name)
        obj.icon:loadTexture( ItemData.getItemUrl(item.id), ccui.TextureResType.localType )
        obj.name:setString( name1 )
        local color = QualityData.getColor(item.quality)
        obj.name:setColor(color)
        if name2 then
            obj.namesp:setString("("..name2..")")
        end
        obj.icon.jItem = item
        if reward.val > 1 then
            obj.count:setString(reward.val)
        end

        --灵魂石
        if item.type == 4 then
            obj.is_rect = 1
        end
    end
end

--神符
function CardGet:setGlyph( obj,reward)
    -- local data = {}
    -- data.jGlyph = findTempleGlyph( 70101 )
    -- data.sGlyph = TotemData.getGlyph(1)
    -- TipsMgr.showTips(sender:getTouchStartPos(),TipsMgr.TYPE_GLYPH,data )
    local glyph_id = reward.objid
    local jGlyph = findTempleGlyph( glyph_id )
    if jGlyph then
        obj.icon:setVisible(false)
    	local dw = TotemData.getGlyphObject(jGlyph.id, self.winName, obj.bg, 0, 0)
    	dw:setScale(1.5,1.5)
        obj.name:setString(jGlyph.name)
        local color = QualityData.getColor(jGlyph.quality)
        obj.name:setColor(color)
        obj.namesp:setString("(神符)")
        obj.icon.jGlyph = jGlyph
        if reward.val > 1 then
            obj.count:setString(reward.val)
        end
    end
end

--英雄
function CardGet:setSoldier( obj,reward)
    local soldier_id = reward.objid
    --soldier_id = 10001
    local jSoldier = findSoldier( soldier_id )
    local url = ""
    if jSoldier then
    	url = SoldierData.getQualityFrameName(1)
    	obj.bg:loadTexture( url, ccui.TextureResType.plistType  )
        url = SoldierData.getAvatarUrl(jSoldier)
        obj.icon:loadTexture( url, ccui.TextureResType.localType )
        obj.name:setString(string.format("%s",jSoldier.name ))
        local color = QualityData.getColor(jSoldier.quality)
        obj.name:setColor(color)
        obj.namesp:setString("(新英雄)")
        local off = TeamData.AVATAR_OFFSET
        obj.icon:setPosition(self.iconPosi.x,self.iconPosi.y + off.y)
    end
end

--特殊物品特效
function CardGet:setRareEffect(obj)
    if obj.is_rare == 0 then
        return
    end

    if obj.is_rect == 1 then
        --xck-tx-03
        local path1 = 'image/armature/ui/cardui/xck-tx-03/xck-tx-03.ExportJson'
        self.lightEffect1 = ArmatureSprite:addArmature(path1, 'xck-tx-03', self.winName, obj.effect, 0, 0)
    else
        --xck-tx-04
        local path1 = 'image/armature/ui/cardui/xck-tx-04/xck-tx-04.ExportJson'
        self.lightEffect1 = ArmatureSprite:addArmature(path1, 'xck-tx-04', self.winName, obj.effect, 0, 0)
    end
end

function CardGet:removeItemsContent( )
    self.oneSoldier_id = 0
	self:resetItem(self.oneItem)
	for k,v in pairs(self.itemList) do
		self:resetItem(v)
	end
end
function CardGet:resetItem( obj )
	obj.bg:removeAllChildren()
	obj.icon:removeAllChildren()
    obj.effect:removeAllChildren()
	obj.bg:loadTexture("empty.png",ccui.TextureResType.plistType)
	obj.icon:loadTexture("empty.png",ccui.TextureResType.plistType)
	obj.name:setString("")
    obj.namesp:setString("")
    obj.count:setString("")
	obj.soldier_id = 0 
	obj.playSoldier =  false
	obj.is_rare = 0
    obj.is_rect = 0
    obj.replaceReward = nil
    obj.icon:setPosition(self.iconPosi)
    obj.icon.jItem = nil
    obj.icon.jGlyph = nil
    obj.icon:setVisible(true)
	--self:setText(obj)
end

function CardGet:reRunActions(type)
	local function onCom(  )
		self.btnGet:setVisible(true)
		self.again:setVisible(true)
        self.isRunAction = false
        CardData.virRewardData = nil
        --TipsMgr.showGetEffect(CardData.rewardData.extra_reward_list)
	end

	--一个英雄
	local function soldierWinCom2( )
		self:scaleOut(self.styleView,onCom)
	end

    --英雄替换为灵魂
    local function soldierWinCom3( )
       self:scaleOut(self.oneItem,onCom)
    end

    --十次抽
    local function soldierWinCom( )
        LogMgr.debug("谭，，，，十次抽" .. self.mIndex)
        local item = self.itemList[self.mIndex]
        if item then
            item.playSoldier = false
            self:actionMoreItem(onCom,soldierWinCom)
        end
    end

	self.pause = false
	self.mIndex = 1
	self.title:setVisible(false)
	self.moreLay:setVisible(false)
	self.oneItem:setVisible(false)
	self.btnGet:setVisible(false)
	self.again:setVisible(false)
	if self.styleView then
		self.styleView:setVisible(false)
	end
	self:actionTitle()
	if type == 1 then --一个普通物品
        if self.oneItem.replaceReward then
            SoldierData.soldierGetUI(soldierWinCom3,self.oneItem.soldier_id,self.oneItem.replaceReward)
        else
            SoundMgr.playUI("card_item")
            self:scaleOut(self.oneItem,onCom)
        end
	elseif type == 2 then --一个英雄
		SoldierData.soldierGetUI(soldierWinCom2,self.oneSoldier_id,nil)
	elseif type == 3 then --多个物品
		self.moreLay:setVisible(true)
		for k,v in pairs(self.itemList) do
			v:setVisible(false)
		end
		self:actionMoreItem(onCom,soldierWinCom)
	end
end

function CardGet:actionTitle( )
	self:scaleOut(self.title)
end

function CardGet:actionMoreItem( onCom , soldierWinCom )
	local showItem = nil
	local callBack = nil

	showItem = function( item )
		if item.playSoldier then
    		SoldierData.soldierGetUI(soldierWinCom,item.soldier_id,item.replaceReward)
	    else
            SoundMgr.playUI("card_item")
	    	self:scaleOut(item,callBack)
	    end
	end

	callBack = function( )
        self.mIndex = self.mIndex + 1
	    if self.mIndex > #self.itemList then
	    	onCom()
	    	return
	    end
        local objNew = self.itemList[self.mIndex]
        showItem(objNew)
    end

    local obj = self.itemList[self.mIndex]
    showItem(obj)
end

function CardGet:scaleOut(obj,callBack)
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

function CardGet:playStyleView( ... )
	local jsoldier = findSoldier( self.oneSoldier_id )
    if jsoldier == nil then
		return
	end

	if not self.styleView then
        self.styleView = ModelMgr:useModel(jsoldier.animation_name)
        --self.styleView = ModelMgr:useModel("YS03hamiaoer")
        self.styleView:setPosition(568,270)
        if self.styleView:getParent() == nil then
            self.spLay:addChild(self.styleView,5)
        end
        self.styleView:playOne(false, "physical1")
    end
end

function CardGet:removeStyleView( ... )
	if self.styleView ~= nil then
        ModelMgr:recoverModel(self.styleView)
        self.styleView = nil
    end
end

function CardGet:dispose()

end

function CardGet:addBgEffect( ... )
    if self.bgEffect then
        return
    end

    local path1 = 'image/armature/ui/cardui/xck-tx-01/xck-tx-01.ExportJson'
    self.bgEffect = ArmatureSprite:addArmature(path1, 'xck-tx-01', self.winName, self.bg, 0, 680)
end

function CardGet:addTitleEffect( ... )
    if self.titleEffect then
        return
    end

    local path1 = 'image/armature/ui/cardui/xck-tx-02/xck-tx-02.ExportJson'
    self.titleEffect = ArmatureSprite:addArmature(path1, 'xck-tx-02', self.winName, self.title, 0, 65)
end

function CardGet:addAgainEffect( ... )
    if self.againEffect then
        return
    end

    local path1 = 'image/armature/ui/share/ljkg-tx-01/ljkg-tx-01.ExportJson'
    self.againEffect = ArmatureSprite:addArmature(path1, 'ljkg-tx-01', self.winName, self.againBtn, 82, 28)
end

function CardGet:ctor()
    local function update()
        self:updateBottomInfo()
    end
    
	self.bg:loadTexture( prePath2 .. "get_item.jpg",ccui.TextureResType.localType)
	self.size = self:getContentSize()
    self.center = cc.p(self.size.width/2,self.size.height/2)
    --local path2 = 'image/armature/ui/cardui/wkdg-tx-01/wkdg-tx-01.ExportJson'
    --self.lightEffect2 = ArmatureSprite:addArmature(path2, 'wkdg-tx-01', self.winName, self.bg, self.center.x, self.center.y)
    local url = string.format("%scardgetitems_%d.png",prePath2,1)
	self.again.btnAgain.img:loadTexture(url,ccui.TextureResType.localType)

    local function qAgain( sender,type )
        ActionMgr.save( 'UI', 'CardGet click againBtn ' .. CardDefine.qInfo.type .."__".. CardDefine.qInfo.times)

        local qSuccess = false
    	if CardDefine.qInfo.type == trans.const.kAltarLotteryByGold then
    		qSuccess = CardData.dimQ( CardDefine.qInfo.times,CardDefine.qInfo.need, CardDefine.qInfo.need)
    	else
    		qSuccess = CardData.norQ( CardDefine.qInfo.times,CardDefine.qInfo.need, CardDefine.qInfo.need)
    	end
    end

    self.againBtn = createScaleButton(self.again.btnAgain)
    self.againBtn:addTouchEnded(qAgain)
    self.okBtn = createScaleButton(self.btnGet)
    local function exit(sender, type)
        ActionMgr.save( 'UI', 'CardGet click okBtn' )
        PopMgr.removeWindow(self)
    end
    self.okBtn:addTouchEnded(exit)

    self.title:setPositionX(self.center.x)

    self.event_list = {}
    self.event_list[EventType.UserCardUpdate] = update
end

function CardGet:initItems()
    if self.hasInitItems then
        return
    end
    self.hasInitItems = true
    --多物品
    self.itemList = {}
    local sampleItem = getLayout(prePath .. "item.ExportJson")
	local index = 1
	for j = 1, 2, 1 do
    	for i=1,5,1 do
            index = (j-1) * 5 + i
            local item = cloneLayout(sampleItem)
            item.index = index
            item:setAnchorPoint(0.5,0.5)
            item:setPosition( 260 + (i - 1) * 154 , 570 - ( j * 158 ))
            self.iconPosi = cc.p(item.icon:getPosition())
            extAddChild(self.moreLay, item)
            table.insert(self.itemList,item)
            self:setText(item)
            self:itemAddEvent(item)
        end
    end
    self.moreLay:setVisible(false)

    --一个物品
    self.oneItem = cloneLayout(sampleItem)
    self.oneItem.index = 100
    self.oneItem:setAnchorPoint(0.5,0.5)
    self.oneItem:setPosition(self.center)
    extAddChild(self.spLay,self.oneItem)
    self.oneItem:setVisible(false)
	self:setText(self.oneItem)
    self:itemAddEvent(self.oneItem)
end

function CardGet:setText( item)
    item.name = UIFactory.getText("", item, 0, 0, 18, cc.c3b(0xff, 0xff, 0xff ), FontNames.HEITI,nil,0)
    item.namesp = UIFactory.getText("", item, 0, 0, 18, cc.c3b(0xF8, 0xff, 0xAF ), FontNames.HEITI,nil,0)
    item.name:setPosition(43,-19)
    item.namesp:setPosition(43,-43)
    self:addOutline(item.name,cc.c4b(0x6b,0x2c,0x08,255),1)
    self:addOutline(item.namesp,cc.c4b(0x6b,0x2c,0x08,255),1)
end

function CardGet:addOutline(item, rgb, px)
    local txt = item:getVirtualRenderer()
    txt:enableOutline(rgb, px)
end

function CardGet:itemAddEvent( item )
    local  function onBegin( sender,type )
        local pos = sender:getTouchStartPos()
        if sender.jItem then
            TipsMgr.showTips(sender:getTouchStartPos(),TipsMgr.TYPE_ITEM,sender.jItem)
        end

        -- if sender.jGlyph then
        --     TipsMgr.showTips(sender:getTouchStartPos(),TipsMgr.TYPE_RUNE,sender.jGlyph)
        -- end
    end

    buttonDisable(item.icon,false)
    UIMgr.addTouchBegin(item.icon,onBegin)
end