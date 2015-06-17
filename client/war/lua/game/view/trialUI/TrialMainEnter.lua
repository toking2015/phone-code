require "lua/game/view/trialUI/TrialMgr.lua"
require "lua/game/view/trialUI/TrialRewardMain.lua"
require("lua/utils/UICommon.lua")

TrialMainEnter = createUILayout('TrialMainEnter', TrialMgr.prePath .. "TrialMainUI/TrialMainEnter.ExportJson")
function TrialMainEnter:ctor(trial)
	self.trial = trial
	self.formationType = TrialMgr.trailFormationType[trial.id]

	local function enter()
		-- if GameData.getSimpleDataByKey("strength") < 15 then
		-- 	TipsMgr.showError("体力不足")
		-- 	return
		-- end

		TrialMgr.currentTrial = trial
		local formationType = self.formationType
		Command.run(
			"formation show trial", 
			formationType,
			trial.monster_id,
			function ( ... )
				Command.run("trial enter", trial.id, FormationData.getTypeData(formationType))

				EventMgr.addListener(EventType.FightEnd, TrialMgr.listener, TrialMgr)
			end,
			function ( ... )
				Command.run("ui show", "TrialMainUI")
			end
		)

		Command.run("ui hide", "TrialMainUI")
	end
	createScaleButton(self.image)
	self.image:addTouchEnded(enter)

	-- self.image.number:setString(trial.strength_cost)

	local function mopup( ... )
		local v = findGlobal("trial_vip_mopup_level")
		if v then
			if tonumber(v.data) > GameData.getSimpleDataByKey ("vip_level") then
				showMsgBox("需要VIP" .. tonumber(v.data) .. "级[btn=one]")
				return
			end
		end

		self.userTrial = TrialMgr.getTrial(self.trial.id)
		if not self.userTrial or 0 == self.userTrial.max_single_val then
			showMsgBox("该玩法还未进行挑战，无法扫荡！[btn=one]")
			return
		end
		showMsgBox("是否一键扫荡“" .. self.trial.name .. "”",
			function ( ... )
				Command.run("trial mopup", trial.id)
				Command.run('SaoDangUI show')
			end)
	end
	createScaleButton(self.mopup)
	self.mopup:addTouchEnded(mopup)
end