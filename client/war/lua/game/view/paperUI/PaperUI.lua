require "lua/game/view/paperUI/PaperSkillSelectUI.lua"
require "lua/game/view/paperUI/LearnConfirmUI.lua"
require "lua/game/view/paperUI/StarTipsUI.lua"
require "lua/game/view/paperUI/PaperSkillForgetUI.lua"
require "lua/game/view/paperUI/PaperCreateUI.lua"
require "lua/game/view/paperUI/PaperSkillLevelupUI.lua"

PaperUICommon = {}
PaperUICommon.w = 0
PaperUICommon.h = 0
PaperUICommon.x = 325
PaperUICommon.y = 145
PaperUICommon.max_idx = 1

function PaperUICommon.onLevelup()
	local jSkill = PaperSkillData.getJSkill()
	if not jSkill then
		return
	end
	local jNextSkill = PaperSkillData.getNextJSkill(jSkill)
	if not jNextSkill then
		return
	end
	if CoinData.checkLackCoin(const.kCoinStar, jNextSkill.level_up_star, 0) or
		CoinData.checkLackCoin(const.kCoinMoney, jNextSkill.level_up_money, 0) then
		return
	end
	trans.send_msg("PQPaperLevelUp", {})
end

local tipsUI = nil
function PaperUICommon.showTips(target)
	tipsUI = tipsUI or StarTipsUI.new()
	tipsUI:updateData()
	local size = tipsUI:getContentSize()
	local gp = target:getTouchStartPos()
	local pos = cc.p( gp.x, gp.y + 20 ) --默认右上方
	if pos.x + size.width > visibleSize.width then
	    pos.x = gp.x - size.width
	    if pos.x < 0 then
	        pos.x = 0
	    end
	end
	if pos.y + size.height > visibleSize.height then
	    pos.y = gp.y - 20 - size.height
	    if pos.y < 0 then
	        pos.y = 0
	    end
	end

	local layer = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
	addToParent(tipsUI, layer, pos.x, pos.y, 10000)
end
function PaperUICommon.hideTips()
	if tipsUI then
		tipsUI:removeFromParent()
		tipsUI = nil
	end
end
