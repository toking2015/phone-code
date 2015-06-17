-- Create By Live --

local prePath = "image/ui/CopyUI/"

CopyBossMet = class("CopyBossMet", function()
	return Node:create()
end)

function CopyBossMet:ctor()
	self:setAnchorPoint(0, 0)
	self.bossPos = cc.p(visibleSize.width / 2 - 30, visibleSize.height / 2 + 35)
	-- boss名称
	local bossName = CopyBossName:new()
	bossName:setPosition(cc.p(visibleSize.width / 2, visibleSize.height))
	self:addChild(bossName, 1)
	self.bossName = bossName
	-- 顶部横条
	local upView = Sprite:create(prePath .. "copyBossBg/copy_up_view.png")
	upView:setAnchorPoint(0, 0)
	upView:setPositionY(visibleSize.height)
	self:addChild(upView)
	self.upView = upView
	-- 底部横条
	local botView = Sprite:create(prePath .. "copyBossBg/copy_bottom_view.png")
	botView:setAnchorPoint(0, 0)
	botView:setPositionY(-botView:getContentSize().height)
	self:addChild(botView)
	self.botView = botView
	-- 中间UI
	local midView = Sprite:create(prePath .. "copyBossBg/copy_mid_view.png")
	midView:setAnchorPoint(0, 0)
	midView:setPositionY(botView:getContentSize().height)
	midView:setVisible(false)
	self:addChild(midView)
	self.midView = midView
	-- 布阵按钮
	local btn_fight = ccui.ImageView:create("copy_img_fight.png", ccui.TextureResType.plistType)
	local size = btn_fight:getSize()
	local pos = cc.p(visibleSize.width - size.width / 2 - 10, botView:getContentSize().height + size.height / 2 + 10)
	btn_fight:setPosition(pos)
	btn_fight:setOpacity( 0 )
	btn_fight:setScale(1.4)
	self.btn_fight = btn_fight
	self:addChild(btn_fight, 1)
	-- 闪电动画
	local btn_light = ccui.ImageView:create("copy_img_light.png", ccui.TextureResType.plistType)
	btn_light:setPosition(pos)
	btn_light:setVisible(false)
	self.btn_light = btn_light
	self:addChild(btn_light, 0)
end

function CopyBossMet:create()
	local ui = CopyBossMet:new()

	return ui
end
-- 播放闪电动画
function CopyBossMet:showShineLight()
	local name = "and-tx-01"
	local path = "image/armature/scene/copy/" .. name .. "/" .. name .. ".ExportJson"
	local px, py= visibleSize.width / 2 + 130, visibleSize.height / 2 + 70
	
	self.light = ArmatureSprite:addArmatureTo(self, path, name, px, py, nil, 2)
	SoundMgr.playEffect("sound/ui/startbattle.mp3")
	local function complete()
		self.light:stop()
		local function play()
            SoundMgr.playEffect("sound/ui/startbattle.mp3")
			self.light:gotoAndPlay(1)
		end
		performWithDelay(self.light, play, 1.5)
	end
	self.light:onPlayComplete(complete)
end
-- 设置boss名称
function CopyBossMet:setBossName(monster)
	self.bossName:setName("Lv." .. monster.level .. " " .. monster.name)
	local url = MonsterData.getPhotoUrl(monster)
	local image = ccui.ImageView:create(url, ccui.TextureResType.localType)
	image:setScaleX(-1)
	image:setPosition(cc.p(self.bossPos.x, image:getSize().height / 2))
	self:addChild(image)
	self.boss = image
	if monster.type == 2 then
        SoundMgr.playSoldierTalk( monster.avatar ,false)
    end
end
-- 播放遇怪动画
function CopyBossMet:startShow()
	local delay = 0.3
	local topAction = cc.MoveBy:create(delay, cc.p(0, -self.bossName:getSize().height + 10))
	self.bossName:runAction(topAction)

	local upAction = cc.MoveBy:create(delay, cc.p(0, -self.upView:getContentSize().height))
	self.upView:runAction(upAction)

	local botAction = cc.MoveTo:create(delay, cc.p(0, 0))
	self.botView:runAction(botAction)

	local function callback()
		self.midView:setVisible(true)
	end
	performWithDelay(self, callback, delay)

	local bossUpAction = cc.MoveTo:create(0.5, cc.p(self.bossPos.x, self.bossPos.y + 100))
	local bossDownAction = cc.MoveTo:create(0.2, self.bossPos)
	local downScaleAction = cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(0, -60)), cc.ScaleTo:create(0.1, -1.11, 0.83))
	local upScaleAction = cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, 50)), cc.ScaleTo:create(0.2, -0.94, 1.04))
	local holdAction = cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, -20)), cc.ScaleTo:create(0.2, -1, 1))
	
	local bossAction = cc.Sequence:create(bossUpAction, bossDownAction, downScaleAction, upScaleAction, holdAction)
	self.boss:runAction(bossAction)

	local function showFight()
		local function showLight()
			self.btn_light:setVisible(true)
			local ligthAction = cc.RotateBy:create(2, 360)
			self.btn_light:runAction(cc.RepeatForever:create(ligthAction))
            self:showShineLight()

            local btn_fight = createScaleButton(self.btn_fight)
            local function touchEnded()
            	ActionMgr.save( 'UI', 'CopyBossMet click btn_fight')
                EventMgr.dispatch(EventType.FightCopyMonster)
            end
            btn_fight:addTouchEnded(touchEnded)
            if CopyData.wait_ref == true then
                Command.run("loading wait show", "copy")
            end
		end

		a_scale_fadein(self.btn_fight, 0.2, {x = 1, y = 1}, showLight)
	end
	performWithDelay(self, showFight, 1.3)
end

Command.bind("cmd copy fight", function()
    EventMgr.dispatch(EventType.FightCopyMonster)
end)
