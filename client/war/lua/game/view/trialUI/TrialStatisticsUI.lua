
-- TrialStatisticsUI = class("TrialStatisticsUI", function() 
--     return getLayout(FightFileMgr.prePath .. "FightResult/TrialStatisticsUI.ExportJson") 
-- end)
TrialStatisticsUI =  createUILayout("TrialStatisticsUI", FightFileMgr.prePath .. "FightResult/TrialStatisticsUI.ExportJson", "FightDataMgr")

function TrialStatisticsUI:createStatisticsUI(list)
	local view = TrialStatisticsUI.new()
	view.rewardList = list

	view:setTouchEnabled(false)
	view.con_up:setTouchEnabled(false)
	view.con_up.img_first:setTouchEnabled(false)
	view.con_up.txt_num:setTouchEnabled(false)
	view.con_down:setTouchEnabled(false)
	view.con_down.img_reward:setTouchEnabled(false)
	view.con_down.txt_num:setTouchEnabled(false)

	view.fight_over_bg:loadTexture(FightFileMgr.prePath..'FightResult/trial_fight_over.png', ccui.TextureResType.localType)
	view.fight_statistics:loadTexture(FightFileMgr.prePath..'FightResult/trial_fight_statistics.png', ccui.TextureResType.localType)

    FightResultUI.isClose = true
	view:updateData()

	return view
end

function TrialStatisticsUI:updateData()
	self:updateStatisticsType()
	self:updateStatisticsReward()
end

local function getStatisticsType()
	local json = nil
	if const.kFightTypeTrialSurvival == FightDataMgr.fight_type 
		or const.kFightTypeTrialStrength == FightDataMgr.fight_type 
		or const.kFightTypeTrialAgile == FightDataMgr.fight_type 
		or const.kFightTypeTrialIntelligence == FightDataMgr.fight_type
	then
		if const.kFightTypeTrialSurvival == FightDataMgr.fight_type then
			json = findTrial(1)
		elseif const.kFightTypeTrialStrength == FightDataMgr.fight_type then
			json = findTrial(2)
		elseif const.kFightTypeTrialAgile == FightDataMgr.fight_type then
			json = findTrial(3)
		else
			json = findTrial(4)
		end
	end

	return json
end
function TrialStatisticsUI:updateStatisticsType()
	local trial = getStatisticsType()
	if nil == trial then
		trial = {}
		trial.id = 1
	end

	local id = 4
	local url = 'trial_' .. id .. '.png'
	self.con_up.img_first:loadTexture(url, ccui.TextureResType.plistType)
	local imgSize = self.con_up.img_first:getSize()

	local textNumber = FightDataMgr.theFightUI and FightDataMgr.theFightUI.trial.textNumber or 0
	self.con_up.txt_num:setString('' .. textNumber)
	local txtSize = self.con_up.txt_num:getContentSize()
	self.con_up.txt_num:setPositionX(self.con_up.img_first:getPositionX() + imgSize.width + 2)

	local width = imgSize.width + txtSize.width + 2
	local trialSize = self:getSize()
	self.con_up:setPositionX((trialSize.width - width)/2)
end

local function getTrialExp(list)
	local exp = 0
	if not list then list = {} end
	for _, v in pairs(list) do
		if 7 == v.cate then
			exp = v.val
			break
		end
	end
	return exp
end
function TrialStatisticsUI:updateStatisticsReward()
	local exp = getTrialExp(self.rewardList)
	self.con_down.txt_num:setString('/' .. exp)
end