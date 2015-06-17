PreLoadBg = class('PreLoadBg', function()
	return cc.Node:create()
end)

function PreLoadBg:ctor()
	local prePath = 'image/ui/LoadingUI/'
	self.bg = PreLoadUtils.getSprite(prePath..'bg_loading.jpg', self)
    -- self.particle = PreLoadUtils.getParticle('loading.plist', 150, -50, nil, self)
	-- self.boss = PreLoadUtils.getSprite(prePath..'boss.png', self)
	-- self.cow = PreLoadUtils.getSprite(prePath..'cow.png', self, 342, 15.5)

	local prePath = "image/armature/ui/loading/"
	self.jn = PreLoadUtils.getArmature(prePath, 'xmjz-tx-01', "PreLoadBg", self, -568, 320)
	self.ld = PreLoadUtils.getArmature(prePath, 'xmjz-tx-02', "PreLoadBg", self, -340, 320)

	self.mask = PreLoadUtils.getLayerColor(cc.c4b(0, 0, 0, 0x80), visibleSize.width, visibleSize.height, self, -visibleSize.width / 2, -visibleSize.height / 2)
	self:changeLoading(true)
end

function PreLoadBg:onShow()
	-- if self.action_tag then
	-- 	if self.boss:getActionByTag(self.action_tag) then
	-- 		return
	-- 	end
	-- end
	-- self.boss:stopAllActions()
	-- self.boss:setPosition(280, 150)
	-- local moveUp = cc.MoveTo:create(1, cc.p(280, 170))
	-- local moveDown = cc.MoveTo:create(1, cc.p(280, 150))
	-- local action = self.boss:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
	-- action:setTag(1)
	-- self.action_tag = action:getTag()
end

function PreLoadBg:changeLoading(isLoading)
	self.mask:setVisible(not isLoading)
end

function PreLoadBg:getInstance(noCreate)
	local instance = PreLoadBg.instance
	if not instance and not noCreate then
		instance = PreLoadBg.new()
		instance:setPosition(visibleSize.width / 2, visibleSize.height / 2)
		instance:onShow()
		instance:retain()
		PreLoadBg.instance = instance
	end
	return instance
end

function PreLoadBg:dispose()
	if PreLoadBg.instance then
		PreLoadBg.instance:release()
		PreLoadUtils.removeArmatureInfo("PreLoadBg")
		PreLoadBg.instance = nil
	end
end
