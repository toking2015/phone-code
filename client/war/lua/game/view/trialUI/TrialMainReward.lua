require "lua/game/view/trialUI/TrialMgr.lua"
require "lua/game/view/trialUI/TrialRewardMain.lua"
require("lua/utils/UICommon.lua")

TrialMainReward = createUILayout('TrialMainReward', TrialMgr.prePath .. "TrialMainUI/TrialMainReward.ExportJson")
function TrialMainReward:ctor(trial)
	self.trial = trial

	local function reward()

		TrialMgr.currentTrial = self.trial
		Command.run("ui show", "TrialRewardMain")
	end
	createScaleButton(self.image)
	self.image:addTouchEnded(reward)

end

function TrialMainReward:setBg(b)
	if b then
		if self.bg then
			self.bg:removeFromParent()
			self.bg = nil
		end
	else
		if not self.bg then
			self.bg = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_Btn.png", self)
			local size = self.bg:getContentSize()
			self.bg:setPosition(size.width / 2, size.height / 2)
			self.bg:setGLProgramState(ProgramMgr.createProgramState('gray'))
			
			UIMgr.addTouchEnded(self.bg, function ( ... )
				end)
		end
	end
end