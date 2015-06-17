--声明类
local prePath = "image/ui/PaperSkillUI/"
local url = prePath .. "PaperSkillLevelupUI.ExportJson"
PaperSkillLevelupUI = createUIClass("PaperSkillLevelupUI", url, PopWayMgr.SMALLTOBIG)

local skill_to_learn = PaperSkillData.skill_desc
local active_add_text_bg_pos = cc.p(300, 121)

--构造函数
function PaperSkillLevelupUI:ctor()
	self.isUpRoleTopView = true

	local path1 = 'image/armature/ui/PaperSkillUI/gql-tx-01/gql-tx-01.ExportJson'
	local path2 = 'image/armature/ui/PaperSkillUI/gql-tx-02/gql-tx-02.ExportJson'
	local path3 = 'image/armature/ui/PaperSkillUI/gql-tx-03/gql-tx-03.ExportJson'
	local tx1_pos = cc.p(240, 246)
	local tx2_pos = cc.p(375, 252)
	local tx3_pos = cc.p(511, 233)

	UIMgr.addTouchBegin(self.bg.star_icon, function ()
		ActionMgr.save('UI', 'PaperSkillLevelupUI down star')
		PaperUICommon.showTips(self.bg.star_icon)
	end)
	UIMgr.addTouchEnded(self.bg.star_icon, function ()
		ActionMgr.save('UI', 'PaperSkillLevelupUI up star')
		PaperUICommon.hideTips()
	end)
	UIMgr.addTouchCancel(self.bg.star_icon, PaperUICommon.hideTips)

	local function completeHandler()
		self.bg.tx1:removeFromParent()
		self.bg.tx1, self.bg.tx2, self.bg.tx3 = self.bg.tx2, self.bg.tx3, self.bg.tx4
		self:updateData()
		self.btn_bg.btn_levelup:setTouchEnabled(true)
	end
	local function ballMove()
		local duration = 0.5
		local moveToLeft = cc.MoveTo:create(duration, cc.p(100, 246))
		local scaleAct = cc.ScaleTo:create(duration, 0.5)
		local fadeoutAct = cc.FadeOut:create(duration)
		self.bg.tx1:runAction(cc.Sequence:create(cc.Spawn:create(moveToLeft, scaleAct, fadeoutAct), cc.CallFunc:create(completeHandler)))

		local moveTo1 = cc.MoveTo:create(duration, tx1_pos)
		local scaleTo1 = cc.ScaleTo:create(duration, 0.75)
		self.bg.tx2:runAction(cc.Spawn:create(moveTo1, scaleTo1))

		local moveTo2 = cc.MoveTo:create(duration, tx2_pos)
		local scaleTo2 = cc.ScaleTo:create(duration, 1.0)
		self.bg.tx3:runAction(cc.Spawn:create(moveTo2, scaleTo2))

		self.bg.tx4 = ArmatureSprite:addArmature(path2, 'gql-tx-02', self.winName, self.bg, 600, 233, nil, 4)
		self.bg.tx4:setScale(0.5)
		local moveTo3 = cc.MoveTo:create(duration, tx3_pos)
		local scaleTo3 = cc.ScaleTo:create(duration, 0.75)
		self.bg.tx4:runAction(cc.Spawn:create(moveTo3, scaleTo3))
	end

	local function ball2Change()
		self.bg.tx2:removeFromParent()
		self.bg.tx2 = ArmatureSprite:addArmature(path1, 'gql-tx-01', self.winName, self.bg, tx2_pos.x, tx2_pos.y, nil, 4)
		self.bg.blink_tx:removeNextFrame()
		performNextFrame(self, ballMove)
	end
	local function levelupTx()
		self.bg.blink_tx = ArmatureSprite:addArmature(path3, 'gql-tx-03', self.winName, self.bg, tx2_pos.x, tx2_pos.y, ball2Change, 5)
	end

	function self.onSkillChange()
		if PaperSkillData.getSkillId() == 0 then
			return
		end
		levelupTx()
	end

	local function onLevelupBtn()
		ActionMgr.save('UI', 'PaperSkillLevelupUI click btn_levelup')
		local jSkill = PaperSkillData.getJSkill()
		local jNextSkill = PaperSkillData.getNextJSkill(jSkill)
		if not jNextSkill then
			TipsMgr.showError('下一等级暂未开放')
			return
		end
		if CoinData.checkLackCoin(const.kCoinStar, PaperSkillData.level_up_star, 0) or
			CoinData.checkLackCoin(const.kCoinMoney, PaperSkillData.level_up_money, 0) then
			return
		end
		SoundMgr.playEffect("sound/ui/holy.mp3")
		self.btn_bg.btn_levelup:setTouchEnabled(false)
		local star = ccui.ImageView:create()
		star:loadTexture(prePath .. "xin1.png", ccui.TextureResType.localType)
		star:setPosition(self.bg.star_icon:getPosition())
		self.bg:addChild(star, 5)
		local x, y = self.bg.tx2:getPosition()
		a_move_SpeedDown(star, self.bg, 80, 0.5, 4, {x = x, y = y}, nil, PaperUICommon.onLevelup)
	end
	-- 升级按钮
	createScaleButton(self.btn_bg.btn_levelup)
	self.btn_bg.btn_levelup:addTouchEnded(onLevelupBtn)

	-- 遗忘按钮
	createScaleButton(self.btn_bg.btn_forget)
	self.btn_bg.btn_forget:addTouchEnded(function ()
		ActionMgr.save('UI', 'PaperSkillLevelupUI click btn_forget')
		Command.run('ui show', 'PaperSkillForgetUI', PopUpType.SPECIAL)
	end)

	-- 制作图纸按钮
	createScaleButton(self.btn_bg.btn_create_paper)
	self.btn_bg.btn_create_paper:addTouchEnded(function ()
		ActionMgr.save('UI', 'PaperSkillLevelupUI click btn_create_paper')
		Command.run('ui show', 'PaperCreateUI', PopUpType.SPECIAL)
		Command.run('ui hide', 'PaperSkillLevelupUI')
	end)

	local s = self:getSize()
	s.height = s.height - 50
	s.width = s.width - 50
	self:setSize(s)
end

function PaperSkillLevelupUI:delayInit()
	self.head_figure:loadTexture(prePath .. "head_figure.png", ccui.TextureResType.localType)
	self.bg.inside_bg:loadTexture(prePath .. "levelup_bg.jpg", ccui.TextureResType.localType)
	self.bg.soldier_icon:loadTexture(prePath .. "soldier.png", ccui.TextureResType.localType)

	local path1 = 'image/armature/ui/PaperSkillUI/gql-tx-01/gql-tx-01.ExportJson'
	local path2 = 'image/armature/ui/PaperSkillUI/gql-tx-02/gql-tx-02.ExportJson'
	local path3 = 'image/armature/ui/PaperSkillUI/gql-tx-03/gql-tx-03.ExportJson'

	local tx1_pos = cc.p(240, 246)
	local tx2_pos = cc.p(375, 252)
	local tx3_pos = cc.p(511, 233)
	self.bg.tx1 = ArmatureSprite:addArmature(path1, 'gql-tx-01', self.winName, self.bg, tx1_pos.x, tx1_pos.y, nil, 4)
	self.bg.tx1:setScale(0.75)
	self.bg.tx2 = ArmatureSprite:addArmature(path2, 'gql-tx-02', self.winName, self.bg, tx2_pos.x, tx2_pos.y, nil, 4)
	self.bg.tx3 = ArmatureSprite:addArmature(path2, 'gql-tx-02', self.winName, self.bg, tx3_pos.x, tx3_pos.y, nil, 4)
	self.bg.tx3:setScale(0.75)	
end

function PaperSkillLevelupUI:setMiddleRichText(text)
	if not self.text_middle_node then
		self.text_middle_node = cc.Node:create()
		self.text_middle_node:setAnchorPoint(0.5, 0)
		self.text_middle_node:setPosition(310, 145)
		self.text_bg:addChild(self.text_middle_node)
	end

	if text then
		RichTextUtil:DisposeRichText(text, self.text_middle_node)
	else
		self.text_middle_node:removeAllChildren()
	end
end

--onShow处理方法
--处理添加事件侦听
function PaperSkillLevelupUI:onShow()
	self.popType = PaperSkillData.openPopType
	PaperSkillData.setWinShow(self.winName, true)
	EventMgr.addListener(EventType.UserOther, self.onSkillChange)
	performNextFrame(self, self.updateData, self)
end

function PaperSkillLevelupUI:onBeforeClose()
	self.popType = PaperSkillData.closePopType
end

--onClose处理方法
--移除事件侦听
function PaperSkillLevelupUI:onClose()
	PaperSkillData.setWinShow(self.winName, false)
	EventMgr.removeListener(EventType.UserOther, self.onSkillChange)
end

function PaperSkillLevelupUI:dispose()
end

--窗口更新方法
function PaperSkillLevelupUI:updateData()
	local sum_history = gameData.user.star.copy + gameData.user.star.hero + gameData.user.star.totem
	local sum_cur = CoinData.getCoinByCate(const.kCoinStar)
	self.text_bg.left_star:setString(string.format("%d/%d", sum_cur, sum_history))

	local jSkill = PaperSkillData.getJSkill()
	if not jSkill then
		return
	end
	self.text_bg.cur_level:setString(string.format("%d级", jSkill.level))
	self.text_bg.next_level:setString(string.format("%d级", jSkill.level+1))
	self.text_bg.nnext_level:setString(string.format("%d级", jSkill.level+2))

	local active_score_limit_add = jSkill.active_score_limit or 0
	local active_score_reduce = jSkill.create_cost_reduce or 0
	self.text_bg.active_limit_add:setString(string.format("+%d", active_score_limit_add - PaperSkillData.getBaseActiveScoreLimit()))
	self.text_bg.active_reduce:setString(string.format("-%d%%", active_score_reduce/100))

	local collect_name = PaperSkillData.getAbility(jSkill.skill_type)
	self.text_bg.ability_1:setString(string.format("%d级%s", jSkill.collect_skill_level, collect_name))
	local _, name = PaperSkillData.getSkillName(jSkill.skill_type)
	self.text_bg.ability_2:setString(string.format("%d级%s图纸制作", jSkill.paper_level_limit, name))

	local jNextSkill = PaperSkillData.getNextJSkill(jSkill)
	if not jNextSkill then
		return
	end

	-- 下一级数值比当前等级数值有增加时才显示对应字符串
	local text_middle = nil
	if jNextSkill.paper_level_limit > jSkill.paper_level_limit then
		text_middle = string.format("%s%d级%s%s图纸制作", fontNameString("PAPER_W20"), jNextSkill.paper_level_limit,
									fontNameString("PAPER_Y20"), name)
	elseif jNextSkill.collect_skill_level > jSkill.collect_skill_level then
		text_middle = string.format("%s获得%s%d级%s%s", fontNameString("PAPER_Y20"), fontNameString("PAPER_W20"),
									jNextSkill.collect_skill_level, fontNameString("PAPER_Y20"), collect_name)
	elseif jNextSkill.active_score_limit > jSkill.active_score_limit then
		local n = jNextSkill.active_score_limit - jSkill.active_score_limit
		text_middle = string.format("%s手工活力上限%s +%d", fontNameString("PAPER_Y20"), fontNameString("PAPER_W20"), n)
	end
	self:setMiddleRichText(text_middle)

	PaperSkillData.level_up_star = jNextSkill.level_up_star
	PaperSkillData.level_up_money = jNextSkill.level_up_money
	self.text_bg.star_cost:setString(string.format("×%d", jNextSkill.level_up_star))
	self.text_bg.money_cost:setString(string.format("×%d", jNextSkill.level_up_money))
end