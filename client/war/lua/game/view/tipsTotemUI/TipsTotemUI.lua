--声明类
local prePath = "image/ui/TipsTotemUI/"
local url = prePath .. "TipsSoldierUI.ExportJson"
TipsTotemUI = createUIClass("TipsTotemUI", url, PopWayMgr.SMALLTOBIG)
--TipsTotemUI.sceneName = "common"
TipsMgr.registerTipsRender(TipsMgr.TYPE_TOTEM_WIN, TipsTotemUI)
function  TipsTotemUI:onShow()
	-- local totemid = 80101
	-- local jTotem = findTotem(totemid)
	-- local sTotem = TotemData.getTotemById(totemid)
	-- TipsMgr.showWinTips(nil,TipsMgr.TYPE_TOTEM_WIN,jTotem,sTotem)
end

function  TipsTotemUI:onClose()
	self:removeView()
end

function TipsTotemUI:addView()
	self:removeView()
	local style = self.jTotem.animation_name
	if style ~= nil or style ~= "" then
		local level = self.level
		if level > 4 then
			level = 4
		end
		local _totemRole = ModelMgr:useModel(style .. level, const.kAttrTotem, style, level)
		if _totemRole then
			local posi = cc.p(self.style_bg:getPosition())
			posi.y = posi.y - 50
			_totemRole:setPosition(posi)
			_totemRole:playOne(false, "stand")
			self:addChild(_totemRole, 10)
			self._totemRole = _totemRole
		end
	end
end

function TipsTotemUI:removeView()
	if self._totemRole then
		ModelMgr:recoverModel(self._totemRole)
		self._totemRole = nil
	end
end

function TipsTotemUI:updatedata()
	if self.jTotem and self.sTotem then
		self.level = self.sTotem.level
		local url = string.format(prePath.."bg/bg_%s.png", self.level)
		self.style_bg:loadTexture(url,ccui.TextureResType.localType)
		self.name:setString(self.jTotem.name)
		self.name:setColor(TotemData.getColor(self.level))
		self:addView()
		self.type:loadTexture(string.format("TipsTotemUI/type_%s.png",tostring(self.jTotem.type)),ccui.TextureResType.plistType) 
		for i=1,5 do
			if i <= self.level then
				self["star"..i]:loadTexture("TipsTotemUI/star1.png",ccui.TextureResType.plistType) 
			else
				self["star"..i]:loadTexture("TipsTotemUI/star2.png",ccui.TextureResType.plistType) 
			end
		end

		--技能
		local spaces = "　　　　　 "
        local jskill = TotemData.getTotemInitSkill(self.jTotem)
        if jskill then
            self.txt1:setString( spaces .. filterDesc(jskill.desc))
        end

        local jodd = TotemData.getTotemInitOdd(self.jTotem)
        if jodd then
            self.txt2:setString( spaces .. filterDesc(jodd.description) )
        end

        local addArr1,value1 = TotemData.getBlessAdd(self.jTotem.id,self.sTotem.speed_lv,const.kTotemSkillTypeSpeed)
        local addArr2,value2 = TotemData.getBlessAdd(self.jTotem.id,self.sTotem.wake_lv,const.kTotemSkillTypeWake)
        local typeName = ""
        local totemAttr = findTotemAttr(self.jTotem.id, self.sTotem.wake_lv)
        if totemAttr then
        	jOdd = findOdd(totemAttr.wake.first, totemAttr.wake.second)
        	if jOdd then
        		typeName = TotemData.getTargetRangeName(jOdd)
        	end
        end
        self.txt3:setString(value1)
        self.txt4:setString(value2)
        self.txt_title3:setString(string.format("%s英雄觉醒几率:",typeName))
	end
end
-- data jTotem,exData1 sTotem
function TipsTotemUI:setData( data,exData1,exData2 )
	self.jTotem = data
	self.sTotem = exData1
	self:updatedata()
end

function TipsTotemUI:ctor()
	local function exit( ... )
		ActionMgr.save( 'UI', 'TipsTotemUI click btn_close' )
        PopMgr.removeWindow(self)
	end

	buttonDisable(self.btn_close,false)
    createScaleButton(self.btn_close,true)
    self.btn_close:addTouchEnded(exit)
end
