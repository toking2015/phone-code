--声明类
local prePath = "image/ui/PaperSkillUI/"
local url = prePath .. "PaperSkillLearnConfirmUI.ExportJson"
PaperSkillLearnConfirmUI = createUIClass("PaperSkillLearnConfirmUI", url, PopWayMgr.SMALLTOBIG)

--构造函数
function PaperSkillLearnConfirmUI:ctor()
	local function onConfirm()
		ActionMgr.save('UI', 'PaperSkillLearnConfirmUI click btn_yes')
		local index = PaperSkillData.select_to_learn
		local cost = PaperSkillData.getLearnCost(index)
		if CoinData.checkLackCoin(const.kCoinStar, cost, 0) then
			return
		end
		local start_pos = self:convertToNodeSpace(PaperSkillData.star_position)
		local star = ccui.ImageView:create()
		star:loadTexture(prePath .. "xin1.png", ccui.TextureResType.localType)
		star:setPosition(start_pos.x, start_pos.y)
		self:addChild(star)
		local function starScale()
			local scaleAct1 = cc.ScaleTo:create(0.1, 1.5)
			local scaleAct2 = cc.ScaleTo:create(0.1, 1)
			self.bg.Image_22:runAction(cc.Sequence:create(scaleAct1, scaleAct2))
		end
		a_move_SpeedDown(star, self, 80, 0.5, 4, cc.p(self.bg.Image_22:getPosition()), starScale, function ()
			trans.send_msg("PQPaperLevelUp", {skill_type = PaperSkillData.skill_desc[index].equip_type})
		end)
	end
	createScaleButton(self.bg.btn_yes)
	self.bg.btn_yes:addTouchEnded(onConfirm)

	createScaleButton(self.bg.btn_no)
	self.bg.btn_no:addTouchEnded(function ()
		ActionMgr.save('UI', 'PaperSkillLearnConfirmUI click btn_no')
		Command.run('ui hide', 'PaperSkillLearnConfirmUI')
	end)

	function self.onSkillChange()
		local cur_skill = PaperSkillData.getSkillId()
		if cur_skill > 0 then
			Command.run('ui hide', 'PaperSkillLearnConfirmUI')
			Command.run('ui hide', 'PaperSkillSelectUI')
			Command.run('ui show', 'PaperCreateUI', PopUpType.SPECIAL)
			CopyData.curSelectUI = const.kCopyMaterial
		end
	end
end

--onShow处理方法
--处理添加事件侦听
function PaperSkillLearnConfirmUI:onShow()
	self:updateData() --调用窗口更新
	EventMgr.addListener(EventType.UserOther, self.onSkillChange)
end

--onClose处理方法
--移除事件侦听
function PaperSkillLearnConfirmUI:onClose()
	EventMgr.removeListener(EventType.UserOther, self.onSkillChange)
end

function PaperSkillLearnConfirmUI:dispose()
end

--窗口更新方法
function PaperSkillLearnConfirmUI:updateData()
	local index = PaperSkillData.select_to_learn
	local desc = PaperSkillData.skill_desc[index]
	if not desc then
		return
	end
	self.text_bg.equip_text:setString(desc.title)
	self.text_bg.occ_text:setString(desc.occ)
	self.text_bg.cost_text:setString("× " .. PaperSkillData.getLearnCost(index))
	self.text_bg.occ_confirm_text:setString(string.format("是否确定学习%s", desc.title))
	self.bg.skill_png:loadTexture(prePath .. desc.name .. ".png", ccui.TextureResType.localType)
end
