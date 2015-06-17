require "lua/game/view/paperUI/PaperList.lua"
--声明类
local prePath = "image/ui/PaperSkillUI/"
local url = prePath .. "PaperCreateUI.ExportJson"
PaperCreateUI = createUIClass("PaperCreateUI", url, PopWayMgr.SMALLTOBIG)

local skill_to_learn = PaperSkillData.skill_desc

--构造函数
function PaperCreateUI:ctor()
	self.isUpRoleTopView = true

	self.paper_to_create = nil
	self.left_score = 0
	self.create_need_score = 0
	function self.onSkillChange()
		self:updateData()
	end

	local function selectPaperChange(jPaper)
		local jItem = findItem(jPaper.item_id)
		if not jItem then
			return
		end

		self.cover_bg.item_icon:loadTexture(ItemData.getItemUrl(jItem.id), ccui.TextureResType.localType)
		self.cover_bg.item_icon:setScale(0.7, 0.7)
		self.cover_bg.item_name:setString(jItem.name)
		self.cover_bg:setVisible(true)
		self.text_bg.item_desc:setString(jItem.desc)

		local jSkill = PaperSkillData.getJSkill()
		if not jSkill then
			return
		end
		local level_limit = jPaper.level_limit or 0
		if jSkill.paper_level_limit < level_limit then
			self.create_bg:setVisible(false)
			self.bg.err_text:setString(string.format("需要%d级手工技能", jPaper.paper_skill_level_limit))
			self.bg.err_text:setVisible(true)
		else
			self.bg.err_text:setVisible(false)
			local need_score = math.ceil(jPaper.active_score * (1 - jSkill.create_cost_reduce / 10000))
			self.create_bg.cost_text:setString(need_score)
			self.create_bg:setVisible(true)
			self.create_need_score = need_score
		end
		self.paper_to_create = jPaper
	end

	local function onCreate()
		ActionMgr.save('UI', 'PaperCreateUI click btn_create')
		if not self.paper_to_create then return end
		if CoinData.checkLackCoin(const.kCoinActiveScore, self.create_need_score, 0) then
			return
		end
		SoundMgr.playEffect("sound/ui/holy.mp3")
		-- 特效播放
		local star = ccui.ImageView:create()
		star:loadTexture(prePath .. "xin2.png", ccui.TextureResType.localType)
		star:setPosition(self.bg.Image_18:getPosition())
		self:addChild(star, 2)
		a_move_SpeedDown(star, self, 80, 0.5, 4, {x = 644, y = 132}, nil, function ()
			trans.send_msg("PQPaperCreate", {paper_id = self.paper_to_create.item_id})
		end)
	end
	createScaleButton(self.create_bg.btn_create)
	self.create_bg.btn_create:addTouchEnded(onCreate)

	createScaleButton(self.bg.btn_levelup)
	self.bg.btn_levelup:addTouchEnded(function ()
		ActionMgr.save('UI', 'PaperCreateUI click btn_levelup')
		Command.run('ui show', 'PaperSkillLevelupUI', PopUpType.SPECIAL)
		Command.run('ui hide', 'PaperCreateUI')
	end)

	self.bg.err_text:setVisible(false)
	self.cover_bg:setVisible(false)
	self.create_bg:setVisible(false)
	self.listView = PaperList.new(selectPaperChange)
	self.listView:setPosition(15, 20)
	self:addChild(self.listView, 2)

	local s = self:getSize()
	s.height = s.height - 50
	s.width = s.width - 50
	self:setSize(s)
end

function PaperCreateUI:onCoinUpdate()
	local cur_score = CoinData.getCoinByCate(const.kCoinActiveScore)
	if cur_score ~= self.left_score then
		self.left_score = cur_score
		local jSkill = PaperSkillData.getJSkill()
		if not jSkill then return end
		self.text_bg.left_act_score:setString(string.format("%d/%d", self.left_score, jSkill.active_score_limit))
	end
end

function PaperCreateUI:delayInit()
	self.head_figure:loadTexture(prePath .. "head_figure.png", ccui.TextureResType.localType)
	self.cover_bg.bg:loadTexture(prePath .. "right_cover.png", ccui.TextureResType.localType)
	UIFactory.getSprite("image/ui/PaperSkillUI/slot_mask.png", self, 19, 20, 5):setAnchorPoint(0, 0)
end

function PaperCreateUI:onShow()
	self.popType = PaperSkillData.openPopType
	PaperSkillData.setWinShow(self.winName, true)
	self.listView:onShow()
	EventMgr.addListener(EventType.UserOther, self.onSkillChange)
	EventMgr.addListener(EventType.UserCoinUpdate, self.onCoinUpdate, self)

	performNextFrame(self, self.updateData, self) --调用窗口更新
	-- local x, y = self:getPosition()
	-- LogMgr.log('error', string.format("size[%d,%d], pos[%d,%d]", s.width, s.height, x, y))
end

function PaperCreateUI:onBeforeClose()
	self.popType = PaperSkillData.closePopType
end

--onClose处理方法
--移除事件侦听
function PaperCreateUI:onClose()
	PaperSkillData.setWinShow(self.winName, false)
	EventMgr.removeListener(EventType.UserOther, self.onSkillChange)
	EventMgr.removeListener(EventType.UserCoinUpdate, self.onCoinUpdate)
end

function PaperCreateUI:dispose()
end

--窗口更新方法
function PaperCreateUI:updateData()
	local jSkill = PaperSkillData.getJSkill()
	if not jSkill then return end
	self.left_score = CoinData.getCoinByCate(const.kCoinActiveScore)
	self.text_bg.left_act_score:setString(string.format("%d/%d", self.left_score, jSkill.active_score_limit))
	self.text_bg.skill_text:setString(string.format("已学习%d级%s；请选择一个产物进行制作：",
													jSkill.paper_level_limit, PaperSkillData.getSkillName(jSkill.skill_type)))
end

function PaperCreateUI:createFinish(id)
	TipsMgr.showSuccess("制造成功")
end