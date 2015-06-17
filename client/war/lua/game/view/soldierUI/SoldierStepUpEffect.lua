local __this = SoldierStepUpEffect or {}
SoldierStepUpEffect = __this
local data = SoldierData.effStepData 
__this.xpStar_p = cc.p(113,-157)

function __this:isData( )
	return not table.empty(data)
end

function __this:playEfect( )
	self:lightEffect()
end

function __this:dispose( ... )
	self.pClip = nil
end

function __this:removeAllEffect( )
	self:removeTimer()
	self:releaseEffect1()
	self:releaseEffect2()
	if data == nil or data.qLay == nil then
		return
	end
	
	data.qLay:stopAllActions()
	data.qLay:setScale(1,1)
	data.qLay.qn:stopAllActions()
	data.qLay.qn:setScale(1,1)
end

function __this:releaseEffect1( )
	if self.effect1 then
		self.effect1:removeNextFrame()
		self.effect1 = nil
	end
end

function __this:removeTimer( ... )
	if self.timeId ~= nil  then
        TimerMgr.killTimer(self.timeId)
        self.timeId = nil
    end
end

function __this:releaseEffect2( )
	if self.effect2 then
		self.effect2:removeNextFrame()
		self.effect2 = nil
	end
end
function __this:lightEffect( )
	self:releaseEffect2()
    if not self:isData() then
        return
    end

	local function removeEffect( ... )
   		if data.q2 > 0 then
   			self:qualifyScale()
   			data.qLay.qn:loadTexture("soldiern_qn"..data.q2..".png",ccui.TextureResType.plistType)
   		else
   			self:showStepSuccessWin()
   		end
   		local url2 = SoldierDefine.prePath2 .. "soldiern_q"..data.q1..".png"
        data.qBg:loadTexture(url2,ccui.TextureResType.localType)
   	end

	local function onComplete( )
		self:removeTimer()
		self:releaseEffect2()
		self.timeId = TimerMgr.runNextFrame( removeEffect )
	end
	local path1 = 'image/armature/ui/SoldierUI/jjgd-tx-01/jjgd-tx-01.ExportJson'
    self.effect2 = ArmatureSprite:addArmature(path1, 'jjgd-tx-01', "SoldierUI", data.styleCon, 114, 140,onComplete)
    SoundMgr.playUI("UI_rolelevelwin")
end

function __this:getXpEffectUrl( qn )
	local urlArr = {"lv-tx-01","lv-tx-02","lan-tx-01","lan-tx-02","lan-tx-03","zi-tx-01","zi-tx-02","zi-tx-03","zi-tx-04"}
	local len = table.getn(urlArr)
	local index = qn
	local name = ""
	if index <= len then
		name= urlArr[index]
	end
	return name
end

--阶效果
function __this:initXpPercent( qualify,percent )
    percent = math.min(1,percent)
    if not self:isData() then
        return
    end
	if self.qualify ~= qualify then
        self:releaseEffect1()
	end

	
   	if qualify == 0 then
   		return
   	end

   	local function actionCom( )
   	end
   	
   	--创建cliper
   	if self.pClip == nil then
		self.pClip=cc.ClippingNode:create()
        --self.pClip:setOpacityModifyRGB(true)
		self.pClip:setAnchorPoint( cc.p( 0, 0 ) )
		data.qBg:addChild(self.pClip)

		local url = SoldierDefine.prePath2 .. "soldiern_q1.png",ccui.TextureResType.localType
		self.pStencil = cc.Sprite:create(url)
		self.pStencil:setAnchorPoint( cc.p( 0, 0 ) )
        self.pStencil:setScale(0.9,0.9)
        --self.pClip:addChild(self.pStencil)
        self.pClip:setPosition(cc.p(11,15))

        --设置模板
	    self.pClip:setAlphaThreshold( 0.5 )
		self.pClip:setStencil(self.pStencil)
	end

   local name = self:getXpEffectUrl(qualify)
   if name == "" then
       return
   end

	if self.effect1 == nil then
	   local path1 = "image/armature/ui/SoldierUI/".. name .. "/" .. name .. ".ExportJson"
	   self.effect1 = ArmatureSprite:addArmature(path1, name, "SoldierUI", self.pClip, 0, 0)
	   self.effect1:setPosition(__this.xpStar_p)
	end
	local h = 270 * percent
	self.newP = cc.p(__this.xpStar_p.x,__this.xpStar_p.y + h)
	self.qualify = qualify
	self.effect1:stopAllActions()
	local moveto = cc.MoveTo:create(0.3, self.newP)
	local func = cc.CallFunc:create(actionCom)
	local seq = cc.Sequence:create(moveto, func)
	self.effect1:runAction(seq)
end

function __this:showStepSuccessWin( ... )
	if SoldierDefine.qStepQualify == 1 then
		if data.skillOpen then
			data.skillLay:setGrow(data.skillOpen,false)
		end
	else
		local function onWinClose( ... )
			if data.skillOpen then
				data.skillLay:setGrow(data.skillOpen,false)
			end
		end

		Command.run("ui show", "SoldierStepSuccess", PopUpType.SPECIAL)
	    local win = PopMgr.getWindow('SoldierStepSuccess')
	    if win ~= nil then
	        win:setData( SoldierDefine.stepUpSoldier,onWinClose )
	    end 
	end
end

function __this:qualifyScale( )
    if not self:isData() then
        return
    end

	data.qLay:setVisible(true)
	local function onComplete(  )
		self:showStepSuccessWin()
	end
	a_scale_fadein_bs(data.qLay, 0.1, {x = 3, y = 3},{x = 1, y = 1})
	a_scale_fadein_bs(data.qLay.qn, 0.1, {x = 3, y = 3},{x = 1, y = 1}, onComplete)
end