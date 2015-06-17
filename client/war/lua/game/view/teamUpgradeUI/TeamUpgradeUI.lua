require "lua/game/view/teamUpgradeUI/TeamUpgradeItem.lua"

local prePath = 'image/ui/NTeamUpgradeUI/'

local newLevel = 0
local oldLevel = 0
local originStrength = 0
local showLevel = 0

TeamUpgrade = createUIClassEx("TeamUpgradeUI", ccui.Layout)

function TeamUpgrade:ctor()
	self._isUpLayer = true
	self:setSize(cc.size(1139, 479))
	self:setTouchEnabled(true)

	self:initBg()
end

function TeamUpgrade:onShow()
	self:setPositionY(self:getPositionY() + 22)
	self:showEffectAction("zdsj-npchygx-tx01", 77, 329, self.people)

	SoundMgr.playUI("ui_troopslevel")
	self:showStyle()
end

function TeamUpgrade:showStyle()
	local fade = cc.FadeIn:create(0.15)
	local move = cc.MoveTo:create(0.5, cc.p(568, 220))
	local bounceOut = cc.EaseExponentialIn:create(move)
	local callfunc = cc.CallFunc:create(function() 
		self:showEffectAction("zdsj-npcbjgx-tx01", 274, 225, self.bg) 
		self:delayCall() 
	end)
	local sp = cc.Spawn:create(bounceOut, fade:clone())
	local delay = cc.DelayTime:create(0.3)
	local sq = cc.Sequence:create(sp, delay, callfunc)
	self.bg:runAction(sq)
	local move_1 = cc.MoveTo:create(0.5, cc.p(310, 250))
	local bounceOut_1 = cc.EaseExponentialIn:create(move_1)
	local sp_1 = cc.Spawn:create(bounceOut_1, fade:clone())
	self.people:runAction(sp_1)
end

function TeamUpgrade:showEffectAction(name, x, y, parent)
	local url = "image/armature/ui/TeamUpgradeUI/" .. name .. "/" .. name ..".ExportJson"
	LoadMgr.loadArmatureFileInfo(url, LoadMgr.SCENE, "main")
	local effect = ArmatureSprite:create(name, 0)

	effect:setPosition(cc.p(x, y))

	parent:addChild(effect)

	return effect
end

function TeamUpgrade:initBg()
	local bg = UIFactory.getSprite(prePath .. "team_upgrade_bg.png", self, 568, 220, 1)
	bg:setOpacity(0)
	bg:setPositionX(1707)
	self.bg = bg
	local people = UIFactory.getSprite(prePath .. "team_upgrade_people.png", self, 310, 250, 2)
	people:setOpacity(0)
	people:setPositionX(-318)
	self.people = people
end

-- 延迟加载比较大的图片
function TeamUpgrade:delayCall()--delayInit()
	LogMgr.debug("调用战队升级Item >>>>>>>>")
	self.item = TeamUpgradItem:createItem(oldLevel, newLevel, originStrength)
	self:addChild(self.item, 2)
	self.item:setPosition(cc.p(334, 56))
	self.item:setTouchEnabled(false)
end

function TeamUpgrade:onClose()
	EventMgr.dispatch( EventType.TeamUpgradeHide, newLevel )
end

function TeamUpgrade:dispose()
	newLevel = 0
	oldLevel = 0
	originStrength = 0
	LogMgr.debug('releaseAll >>>>>>>')
	if self.item and self.item:getParent() then
		LogMgr.debug('<<<<<<<< releaseAll >>>>>>>')
		self.item:releaseAll()
	end
end


local upGradeMsg = nil --升级的缓存
local function createTeamLevelUp()
	if not upGradeMsg then return end
	local cond = tonumber(findGlobal("open_team_up_condition").data)
	if newLevel <= cond then return end
	if true == FightDataMgr:fighting() or SceneMgr.isSceneName('opening') then
		-- 判断是否在战队场景中
		local function onSceneShow(scene)
			if scene ~= "fight" or scene ~= 'opening' then
				EventMgr.removeListener(EventType.SceneShow, onSceneShow)
				if upGradeMsg then
					createTeamLevelUp(upGradeMsg) --重新显示
				end
			end
		end
		EventMgr.addListener(EventType.SceneShow, onSceneShow)
		return
	end
	upGradeMsg = nil

	PopMgr.checkPriorityPop('TeamUpgradeUI',
		PopOrType.Com,
		function()
			if newLevel <= showLevel then
				return
			end
			showLevel = newLevel
			Command.run("ui show", "TeamUpgradeUI", PopUpType.MODEL)
		end)
	
end
local function saveTeamData(msg)
	LogMgr.debug("保存升级数据>>>>>>")
	upGradeMsg = msg
	newLevel = msg.new_level
	oldLevel = msg.old_level
	originStrength = msg.old_strength
	if SceneMgr.isSceneName('copy') then
		createTeamLevelUp(msg)
		return
	end
end

EventMgr.addListener(EventType.TeamLevelUp, saveTeamData)
EventMgr.addListener(EventType.expBarPercent, createTeamLevelUp)
EventMgr.addListener(EventType.SceneShow, createTeamLevelUp)