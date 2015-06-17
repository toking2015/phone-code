-- Create By Hujingjiang --

local prePath = "image/ui/CopyUI/"
-- 右上角副本进度
CopyProgress = class("CopyProgress", function()
	return getLayout(prePath .. "CopyProgress.ExportJson")
end)
function CopyProgress:create()
	local ui = CopyProgress.new()

	ui:update()

	Command.bind("CopyProgress update", function ()
			ui:update(true)
		end)

	return ui
end
function CopyProgress:ctor()
	self.copy = CopyData.user.copy
	self.atl_progress:setLocalZOrder(1)
	local effectPath = "image/armature/scene/copy/jdg-tx-01/jdg-tx-01.ExportJson"
--    LoadMgr.loadArmatureFileInfo(effectPath, LoadMgr.SCENE, "copy")
	self.effect = ArmatureSprite:addArmatureTo(self, effectPath, "jdg-tx-01", 190, 60)
	self:setEffect(false)
	self.prevNum = 0
end
function CopyProgress:setEffect(bln)
	if false == bln then
		self.effect:setVisible(false)
		self.effect:stop()
	else
		self.effect:setVisible(true)
		self.effect:play()
	end
end
-- 更新进度，isShow为true播放动画
function CopyProgress:update(isShow)
	local copy_id = self.copy.copy_id
	-- local guage, count = CopyData.getCurrCopyGuage() --CopyData.getCopyGuageBy(copy_id)
	local posi = CopyData.user.copy.posi
	local len = #CopyData.user.copy.chunk
    local percent = math.min(100, math.floor(100 * posi / len))
	-- local percent = math.min(100, math.floor(guage * 100 / count))
	if true == isShow then
		local function callback()
			self:setEffect(false)
			self.prevNum = percent
		end
		self:setEffect(true)
		showAnimateText(self.atl_progress, 0.5, self.prevNum, percent, "%d/", callback)
	else
		self.prevNum = percent
		self.atl_progress:setString(percent .. "/")
	end
end

-- boss名称
CopyBossName = class("CopyBossName", function()
	return getLayout(prePath .. "CopyBossName.ExportJson")
end)
function CopyBossName:ctor()
	-- self.txt_boss_name:setTouchEnable(false)
	self:setAnchorPoint(0.5, 0.5)
	-- self:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
end
function CopyBossName:setName(bossName)
	self.txt_boss_name:setString(bossName)
end

-- 副本名称
CopyName = class("CopyName", function()
	-- return getLayout(prePath .. "CopyName.ExportJson")
	return ccui.Layout:create()
end)
function CopyName:ctor()
	self.bg = ccui.ImageView:create("copy_img_boss_bg.png", ccui.TextureResType.plistType)
	-- self.bg:setPosition(self.bg:getSize().width / 2, self.bg:getSize().height / 2)
	self:addChild(self.bg)

	self:setSize(self.bg:getSize())

	self.copyName = ccui.ImageView:create()
	self.copyName:setPositionY(5)
	self:addChild(self.copyName)
	-- self.fontSize = 20--self.txt_copy_name:getFontSize()
	-- self.pos = cc.p(self.txt_copy_name:getPositionX(), self.txt_copy_name:getPositionY())
	-- self:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))

	self:setPosition(cc.p(680, 600))
end
function CopyName:setName(copy_id)
	self.copyName:loadTexture("image/copyName/" .. math.floor(copy_id / 10) .. ".png", ccui.TextureResType.localType)
end
-- 副本名称动画
function CopyName:showStart()
	-- self:setScale(1.3)

	if SceneMgr.prev_scene_name == "copyUI" then
		self.copyName:setScale(3)
		self.copyName:setPosition(cc.p(-120, -300))

		performWithDelay(self.copyName, function()
			a_scale_moveto(self.copyName, 0.5, {x = 1, y = 1}, cc.p(0, 5))
		end, 1)
		-- a_move_scale(self.copyName, 0.5, 0, 5, 1)
	else
		self.copyName:setScale(1)
		self.copyName:setPosition(cc.p(0, 5))
	end
end
