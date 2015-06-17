local function register(file)
	require("lua/game/view/tips/"..file)
end

register("TipsBase.lua")
register("CommonRuleUI.lua")
register("TipsItem.lua")
register("TipsSkill.lua")
register("TipsString.lua")
register("TipsTotem.lua")
register("TipsEquip.lua")
register("TipsRune.lua")
register("TipsRuneTotalAttr.lua")