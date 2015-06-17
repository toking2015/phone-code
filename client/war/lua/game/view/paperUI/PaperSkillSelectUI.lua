--声明类
local prePath = "image/ui/PaperSkillUI/"
local url = prePath .. "PaperSkillSelectUI.ExportJson"
PaperSkillSelectUI = createUIClass("PaperSkillSelectUI", url, PopWayMgr.SMALLTOBIG)
PaperSkillSelectUI.sceneName = "common"

--构造函数
function PaperSkillSelectUI:ctor()
	self.isUpRoleTopView = true

	local function selectHandler(touch, eventType)
		ActionMgr.save('UI', 'PaperSkillSelectUI click selectbg')
		PaperSkillData.select_to_learn = touch.arr_index
		PaperSkillData.star_position = self.bg.star:convertToWorldSpace(cc.p(42, 45))
		Command.run('ui show', 'PaperSkillLearnConfirmUI', PopUpType.SPECIAL)
	end

	local skill_to_learn = PaperSkillData.skill_desc
	for i = 1, #skill_to_learn do
		local text = skill_to_learn[i].name
		self.text_bg[text .. "_cost"]:setString(string.format("× %d", PaperSkillData.getLearnCost(i)))

		self.bg[text].arr_index = i
		UIMgr.addTouchEnded(self.bg[text], selectHandler)
	end

	UIMgr.addTouchBegin(self.bg.star, function ()
		ActionMgr.save('UI', 'PaperSkillSelectUI down star')
		PaperUICommon.showTips(self.bg.star)
	end)
	UIMgr.addTouchEnded(self.bg.star, function ()
		ActionMgr.save('UI', 'PaperSkillSelectUI up star')
		PaperUICommon.hideTips()
	end)
	UIMgr.addTouchCancel(self.bg.star, PaperUICommon.hideTips)

	local s = self:getSize()
	s.height = s.height - 50
	s.width = s.width - 50
	self:setSize(s)
end

function PaperSkillSelectUI:delayInit()
	self.head_figure:loadTexture(prePath .. "head_figure.png", ccui.TextureResType.localType)
	self.bg.leather:loadTexture(prePath .. "leather.png", ccui.TextureResType.localType)
	self.bg.cloth:loadTexture(prePath .. "cloth.png", ccui.TextureResType.localType)
	self.bg.mail:loadTexture(prePath .. "mail.png", ccui.TextureResType.localType)
	self.bg.plate:loadTexture(prePath .. "plate.png", ccui.TextureResType.localType)

	local path1 = 'image/armature/ui/PaperSkillUI/sgjn-xzhkgx-tx-01/sgjn-xzhkgx-tx-01.ExportJson'
	local path2 = 'image/armature/ui/PaperSkillUI/sgjn-xzyxjngx-tx-01/sgjn-xzyxjngx-tx-01.ExportJson'
	local x, gap = 133, 237
	for i = 1, 4 do
		ArmatureSprite:addArmature(path1, 'sgjn-xzhkgx-tx-01', self.winName, self.bg, x, 163, nil, 4)
		ArmatureSprite:addArmature(path2, 'sgjn-xzyxjngx-tx-01', self.winName, self.bg, x, 320, nil, 4)
		x = x + gap
	end
end

function PaperSkillSelectUI:onShow()
	self:updateData()
end

function PaperSkillSelectUI:onClose()
end

function PaperSkillSelectUI:updateData()
	local sum_history = gameData.user.star.copy + gameData.user.star.hero + gameData.user.star.totem
	local sum_cur = CoinData.getCoinByCate(const.kCoinStar)
	self.text_bg.left_star:setString(string.format("%d/%d", sum_cur, sum_history))
end