require "lua/game/view/soldierUI/SoldierDefine.lua"
require "lua/game/view/tipsSoldierUI/TipsSoldierSkill.lua"
require "lua/game/view/tipsSoldierUI/TipsSoldierArr.lua"
--声明类
local prePath = "image/ui/TipsSoldierUI/"
local url = prePath .. "main.ExportJson"
TipsSoldierUI = createUIClass("TipsSoldierUI", url, PopWayMgr.SMALLTOBIG)
--TipsSoldierUI.sceneName = "common"
TipsMgr.registerTipsRender(TipsMgr.TYPE_SOLDIER_WIN, TipsSoldierUI)
function  TipsSoldierUI:onShow()
    -- local soldierId = 10801
    -- local jSoldier = findSoldier(soldierId)
    -- local sSoldier = SoldierData.getSoldierBySId(soldierId)
    -- local sFightExtAble1 = SoldierData.getSoldierFightExtAble(sSoldier.guid)
    -- local data = {}
    -- data.jSoldier = jSoldier
    -- data.sSoldier = sSoldier
    -- data.sFightExtAble1 = sFightExtAble1
    -- TipsMgr.showTips(nil,TipsMgr.TYPE_SOLDIER_WIN,data)
end

function  TipsSoldierUI:onClose()
	self:removeStyleView() 
    ModelMgr:releaseUnFormationModel()
    if self.skillLay then
    	self.skillLay:release()
    end
    if self.arrLay then
    	self.arrLay:release()
    end
end

function TipsSoldierUI:setData( data )
	self.jSoldier = data.jSoldier
	self.sSoldier = data.sSoldier
    self.sFightExtAble1 = data.sFightExtAble1
    if self.sSoldier then
        self.jSoldierQuality = findSoldierQuality(self.sSoldier.quality)
    end
	self:updateData()
    if self.skillLay then
	   self.skillLay:setData(self.sSoldier,self.jSoldier,self.jSoldierQuality)
    end
    if self.arrLay then
       self.jLvInfo = findSoldierLv(self.sSoldier.level)
	   self.arrLay:setData(self.sSoldier,self.jSoldier,self.jLvInfo,self.sFightExtAble1)
    end
end

function TipsSoldierUI:updateData()
	if self.jSoldier and self.sSoldier then
		self:updataStyle()
		self:updateQualify()
		if self.skillLay then
	        self.skillLay:updateData()
	    end
	    if self.arrLay then
	        self.arrLay:updateData()
	    end
	end
end

function TipsSoldierUI:updataStyle( )
    if self.jSoldier ~= nil then
	    local color = QualityData.getColor(SoldierData.getQualityAndNum(self.sSoldier.quality))
	    self.styleCon.name:setColor(color)
	    self.styleCon.name:setString(self.jSoldier.name)
	    for K=1,6 do
	        if K <= self.sSoldier.star then
	            self.styleCon["star_" .. K ]:loadTexture("TipsSoldierUI/soldierd_star.png", ccui.TextureResType.plistType)
	        else
	            self.styleCon["star_" .. K ]:loadTexture("TipsSoldierUI/soldierd_starn.png", ccui.TextureResType.plistType)
	        end
	    end

	    if self.styleView == nil then
	        self.styleView = ModelMgr:useModel(self.jSoldier.animation_name)
	        self.styleView:setPositionX(self.styleCon.style:getPositionX())
	        self.styleView:setPositionY(self.styleCon.style:getPositionY() - 50)
	        self.styleCon:addChild(self.styleView)
	        self.styleView:playOne(false, "stand")
	    end
        local typeName = SoldierData.getEquipTypeName(self.jSoldier)
        local occName = SoldierData.getOccName( self.jSoldier )
        self.type_name:setString(string.format("【%s】%s",typeName,occName))
    end
end

function TipsSoldierUI:updateQualify( )
	local qLay = self.styleCon.quality
    qLay:setVisible(false)
    --品质与品质+
    if self.jSoldierQuality then
        local q1 = self.jSoldierQuality.quality_effect.first
        local q2 = self.jSoldierQuality.quality_effect.second
        local url2 = SoldierDefine.prePath2 .. "soldiern_q"..q1..".png"
        self.styleCon.qBg:loadTexture(url2,ccui.TextureResType.localType)
        if q2 > 0 then
            qLay.qn:loadTexture("TipsTotemUI/soldiern_qn"..q2..".png",ccui.TextureResType.plistType)
        end
    end
end

function TipsSoldierUI:changeRightSub( )
	if(self.curBtn ~= nil) then
        self:setBtn(self.curBtn,true)
    end
    --变更子项
    self:changeByIndex()
    self:setBtn(self.btnList[self.index],false)
    self.curBtn = self.btnList[self.index]
end

function TipsSoldierUI:setBtn( btn,state)
	local index = btn.index
	local btnS = self.subBtnS
    if not state then
        --选中
        btn:setVisible(false)
		btnS:setVisible(true)

		btnS.icon:loadTexture(string.format("TipsSoldierUI/soldierd_subts%d.png",index), ccui.TextureResType.plistType)
    	local btnPosi = cc.p( btn:getPosition() )
    	local parentPosi = cc.p(self.subBtns:getPosition())
    	btnPosi.x = btnPosi.x - 6
    	btnPosi.y = btnPosi.y - 4
    	btnS:setPosition(parentPosi.x + btnPosi.x, parentPosi.y + btnPosi.y)
    else
    	btn:setVisible(true)
    end
end

function TipsSoldierUI:changeByIndex( )
	extRemoveChild(self.skillLay)
	extRemoveChild(self.arrScrollView)
	if self.index == 1 then
		  extAddChild(self,self.skillLay,20)
          self.skillLay:updateData()
	elseif self.index == 2 then
        self:initSubArr()
		extAddChild(self,self.arrScrollView,20)
        self.arrLay:updateData()
	end
end

function TipsSoldierUI:removeStyleView( ... )
    if self.styleView ~= nil then
        ModelMgr:recoverModel(self.styleView)
        self.styleView = nil
    end
end

function TipsSoldierUI:ctor( )
	local function exit( ... )
		ActionMgr.save( 'UI', 'TipsSoldierUI click btn_close' )
        PopMgr.removeWindow(self)
	end
	self.subDefault = 1
	self:initStyle()
	local conPosi = cc.p(self.bg2:getPosition())
	self:initSubSkill(conPosi)
	self:initSubArr(conPosi)
	self:initSelectedBtn()
	self:initSubBtn()
	local bottomLine = cc.Sprite:createWithSpriteFrameName("TipsSoldierUI/line1.png")
	bottomLine:setAnchorPoint(0,0)
    self:addChild(bottomLine,555)
    bottomLine:setPosition(conPosi.x,conPosi.y)

	buttonDisable(self.btn_close,false)
    createScaleButton(self.btn_close,true)
    self.btn_close:addTouchEnded(exit)
end

function TipsSoldierUI:initStyle( )
	local function playAction( )
        --ActionMgr.save( 'UI', 'SoldierInfo click styleCon' )
        if self.styleView then
            self.styleView:playOne(false, "physical1")
        end
    end
    
	self.styleCon = getLayout(prePath .. "styleCon.ExportJson")
	self:addChild(self.styleCon)
	self.styleCon.qBg:loadTexture( SoldierDefine.prePath2 .. "soldiern_q1.png",ccui.TextureResType.localType)
	self.styleCon:setPosition(16,65)
	buttonDisable(self.styleCon,false)
	UIMgr.addTouchEnded( self.styleCon, playAction)
end

function TipsSoldierUI:initSubSkill(conPosi)
	self.skillLay = TipsSoldierSkill.new()
	self.skillLay:retain()
	self.skillLay:setPosition(conPosi.x + 3,conPosi.y)
end

function TipsSoldierUI:initSubArr(conPosi)
    if self.arrLay then
        return
    end

	self.arrLay = TipsSoldierArr.new()
    self.arrLay:retain()
    self.arrScrollView = ccui.ScrollView:create()
    self.arrScrollView:setSize(cc.size(364, 330)) 
    self.arrScrollView:retain() 
    self.arrScrollView:setPosition(conPosi.x,conPosi.y + 10)
    self:setScrollViewContent()
    if self.arrLay and self.sSoldier then
       self.arrLay:setData(self.sSoldier,self.jSoldier,self.jLvInfo)
    end
end

function TipsSoldierUI:setScrollViewContent( )
    local scSize = self.arrScrollView:getSize()
    local inner = self.arrScrollView:getInnerContainer()
    self.arrScrollView:removeAllChildren()
    local innerSize = self.arrLay:gSize() 
    self.arrScrollView:setInnerContainerSize(innerSize) 
    self.arrScrollView:addChild(self.arrLay)
end

--按钮初始化
function TipsSoldierUI:initSubBtn( )
    local function btnFunc(sender,type)
        ActionMgr.save( 'UI', 'TipsSoldierUI click subBtn_obj' .. sender.index )
    	if type ~= ccui.TouchEventType.ended then
	        return
	    end

        self.index = sender.index
        self:changeRightSub()
    end
 
 	self.btnList = {}
    for i=1,2 do
        local offX = 96 * ( i -1 )
        local obj = getLayout(prePath .. "subBtn.ExportJson")
        self.subBtns:addChild(obj)
        obj:setPosition(offX,-2)
        self.btnList[i]  = obj
        obj.icon:loadTexture(string.format("TipsSoldierUI/soldierd_subt%d.png",i), ccui.TextureResType.plistType )
        obj.index = i
        createScaleButton(obj,false)
    	obj:addTouchEnded(btnFunc)
	end

	self.index = self.subDefault
	self:changeRightSub()
end

function TipsSoldierUI:initSelectedBtn( )
	self.subBtnS = getLayout(prePath .. "subBtns.ExportJson")
	self:addChild(self.subBtnS)
	self.subBtnS:setVisible(false)
end