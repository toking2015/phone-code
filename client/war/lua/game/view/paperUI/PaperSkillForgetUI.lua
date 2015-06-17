--声明类
local prePath = "image/ui/PaperSkillUI/"
local url = prePath .. "PaperSkillForgetUI.ExportJson"
PaperSkillForgetUI = createUIClass("PaperSkillForgetUI", url, PopWayMgr.SMALLTOBIG)

local function getForgetCost(level)
	return level > 10 and 2000 or 200 * level
end

--构造函数
function PaperSkillForgetUI:ctor()
	local function onConfirm()
		ActionMgr.save('UI', 'PaperSkillForgetUI click btn_yes')
		local jSkill = PaperSkillData.getJSkill()
		local forget_cost = getForgetCost(jSkill.level)
		if CoinData.checkLackCoin(const.kCoinGold, forget_cost, 0) then
			return
		end
		trans.send_msg("PQPaperForget", {})
	end
	createScaleButton(self.bg.btn_yes)
	self.bg.btn_yes:addTouchEnded(onConfirm)

	createScaleButton(self.bg.btn_no)
	self.bg.btn_no:addTouchEnded(function ()
		ActionMgr.save('UI', 'PaperSkillForgetUI click btn_no')
		Command.run('ui hide', 'PaperSkillForgetUI')
	end)

	function self.onSkillChange()
		local cur_skill = PaperSkillData.getSkillId()
		if cur_skill == 0 then
			Command.run('ui hide', 'PaperSkillForgetUI')
			Command.run('ui hide', 'PaperSkillLevelupUI')
		end
	end
end

function PaperSkillForgetUI:onShow()
	self:updateData() --调用窗口更新
	EventMgr.addListener(EventType.UserOther, self.onSkillChange)
end

function PaperSkillForgetUI:onClose()
	EventMgr.removeListener(EventType.UserOther, self.onSkillChange)
end

function PaperSkillForgetUI:dispose()
end

--窗口更新方法
function PaperSkillForgetUI:updateData()
	local jSkill = PaperSkillData.getJSkill()
	if jSkill == nil then
		return
	end

	-- 悲剧常量的定义和ui的定义反了
	local index = 5 - jSkill.skill_type
	if index < 1 or index > 4 then
		return
	end
	self.text_bg.equip_text:setString(string.format("是否确定遗忘“%s”技能？", PaperSkillData.skill_desc[index].title))

	local forget_cost = getForgetCost(jSkill.level)
	self.text_bg.cost_text:setString(string.format("× %d", forget_cost))
end
