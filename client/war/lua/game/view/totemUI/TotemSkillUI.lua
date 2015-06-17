--图腾技能UI
local path = "image/ui/TotemUI/SkillUI.ExportJson"
TotemSkillUI = createUILayout("TotemSkillUI", path)

function TotemSkillUI:ctor(parent)
	self.parent = parent
	local con = self.con
	con.bg_skill:setTouchEnabled(true)
	local function touchBeginHandler(target)
		if parent.jSkill then
			TipsMgr.showTips(target:getTouchStartPos(), TipsMgr.TYPE_SKILL, parent.jSkill)
		end
	end
	UIMgr.addTouchBegin(con.bg_skill, touchBeginHandler)
end

function TotemSkillUI:updateData()
	local parent = self.parent
	local con = self.con
	local isSameTotem = self.currentGuid == parent.currentTotem.guid
	self.currentGuid = parent.currentTotem.guid
	self:setValue(con.txt_1, TotemData.getTypeDesc(parent.jTotem.type, parent.jWakeAttr), isSameTotem)
	self:setValue(con.txt_2, TotemData.getFormationDesc(parent.jFormationOdd), isSameTotem)
	self:setValue(con.txt_3, TotemData.getSpeedDesc(parent.jSpeedOdd), isSameTotem)
	local skill_icon = UIFactory.setSpriteChild(con.bg_skill, "skill_icon", false, TotemData.getAvatarUrl(parent.jTotem), 42, 42)
	if skill_icon then
		skill_icon:setScale(TotemData.AVATAR_SCALE)
	end
end

function TotemSkillUI:setValue(txt, str, isSameTotem)
	local old = txt:getString()
	if old ~= str then
		txt:setString(str)
		if isSameTotem then
			local pos = cc.p(txt:getPosition())
			local armature
			local function onComplete()
				armature:removeNextFrame()
			end
			armature = ArmatureSprite:addArmatureOnce("image/armature/ui/TotemUI/", "stg-tx-01", self.parent.winName, txt:getParent(), pos.x, pos.y, onComplete, 20)
		end
	end
end
