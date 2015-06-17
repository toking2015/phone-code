local __this = SoldierRecruitEffect or {}
SoldierRecruitEffect = __this
local data = SoldierData.effRecruitData
function __this:isData( )
    return not table.empty(data)
end

function __this:removeAllEffect(  )
	self:releaseEffect1()
	self:releaseEffect2()
end

function __this:releaseEffect1( )
	extRemoveChild(self.effect1)
	if self.effect1 then
		extRemoveChild(self.pClip)
		self.pClip = nil
		extRemoveChild(self.pStencil)
		self.pStencil:release()
		self.pStencil = nil
		self.effect1:release()
		self.effect1 = nil
	end
end

function __this:releaseEffect2( )
	extRemoveChild(self.effect2)
	if self.effect2 then
		self.effect2:release()
		self.effect2 = nil
	end
end

--可招募
function __this:enableRecruitEffect( )
	self:releaseEffect1()
    if not self:isData() then
        return
    end

	if self.effect2 == nil then
		local path1 = 'image/armature/ui/SoldierUI/sxk-tx-01/sxk-tx-01.ExportJson'
	    self.effect2 = ArmatureSprite:addArmature(path1, 'sxk-tx-01', "SoldierUI", data.recruitLay.btnRecruit, 70, 70)
	    self.effect2:retain()
	end
end

function __this:initItemPercent( percent )
	percent = math.min(1,percent)
	self:releaseEffect2()
    if not self:isData() then
        return
    end

    local effectBg = data.recruitLay.btnRecruit
	if self.effect1 == nil then
		--local midPoint = toScenePoint( effectBg, cc.p( effectBg:getPosition() ) )
		local midPoint = cc.p(881,383)
		local circleRadius = 53
		self.pClip=cc.ClippingNode:create()
        self.pClip:setAnchorPoint( cc.p( 0, 0 ) )
        effectBg:addChild(self.pClip)

		self.pStencil = gl.glNodeCreate()
		--effectBg:addChild(self.pStencil)
		self.pStencil:retain()
		local function primitivesDraw( ... )
		    if midPoint ~= nil then
	    	    gl.lineWidth(50)
	    	    cc.DrawPrimitives.drawColor4B(0, 255, 0, 255)
	            cc.DrawPrimitives.drawSolidCircle( midPoint, circleRadius, math.rad(90), 50, 1.0, 1.0)
	        end
		end
		self.pStencil:registerScriptDrawHandler(primitivesDraw)

		local path1 = 'image/armature/ui/SoldierUI/sxs-tx-01/sxs-tx-01.ExportJson'
	    self.effect1 = ArmatureSprite:addArmature(path1, 'sxs-tx-01', "SoldierUI", self.pClip , 67, -50 + 115)
	    self.effect1:retain()

	    --设置模板
	    self.pClip:setAlphaThreshold( 0.5 )
		self.pClip:setStencil(self.pStencil)
	end

	if percent == 0 then
		self.effect1:setPosition(67,-70)
	else
		local h = 115 * percent
		self.effect1:setPosition(67 , -50 + h )
	end
end
