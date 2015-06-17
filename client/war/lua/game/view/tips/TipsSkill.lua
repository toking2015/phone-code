--TipsSkill = createLayoutClass("TipsSkill", TipsBase)
TipsSkill = createUIClassEx("TipsSkill", TipsBase, PopWayMgr.SMALLTOBIG)
--注册
TipsMgr.registerTipsRender(TipsMgr.TYPE_SKILL, TipsSkill)

function TipsSkill:render()
	if self.exData and self.exData.cue then
		self:addRich( SkillData.getTipsInfoAct(self.data) .. self.exData.cue)
	else
    	self:addRich(SkillData.getTipsInfoAct(self.data))
    end
end

--TipsOdd = createLayoutClass("TipsOdd", TipsBase)
TipsOdd = createUIClassEx("TipsOdd", TipsBase,PopWayMgr.SMALLTOBIG )
--注册
TipsMgr.registerTipsRender(TipsMgr.TYPE_ODD, TipsOdd)

function TipsOdd:render()
	if self.exData and self.exData.cue then
		self:addRich( SkillData.getTipsInfoPass(self.data) .. self.exData.cue )
	else
		self:addRich(SkillData.getTipsInfoPass(self.data))
	end
end
