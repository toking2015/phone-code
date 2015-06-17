require "lua/game/view/trialUI/TrialMgr.lua"
require "lua/game/view/trialUI/TrialMainEnter.lua"
require "lua/game/view/trialUI/TrialMainReward.lua"

TrialMainItem = createLayoutClass('TrialMainItem', cc.Node)
function TrialMainItem:ctor(trial)
	self.trial = trial

	self.bg = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_bg1.png", self)

	self.title = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_" .. trial.id .. ".png", self, 0, 182)
	
	self.image = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_Icon" .. trial.id .. ".png", self, 0, 7)
	self.image:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )

	local enter = TrialMainEnter.new(trial)
	self.enter = enter
	self:addChild(enter)
	enter:setPosition(-106, -150)
	enter:setVisible(false)

	local reward = TrialMainReward.new(trial)
	self.reward = reward
	self:addChild(reward)
	reward:setPosition(-106, -150)
	reward:setVisible(false)

	self.finish = UIFactory.getSprite(TrialMgr.prePath .. "TrialMainUI/TrialMain_Finish.png", self, 0, -125)
	self.finish:setVisible(false)

	self.textList = {}
	for i = 1, 3, 1 do
		local text = UIFactory.getText(nil, self, 0, -170, 22, cc.c3b(0xff, 0xc9, 0xa7))
		table.insert(self.textList, text)
	end
end

function TrialMainItem:updateData()

	local flag = false
    local date = GameData.getServerDate()
    if self.checkWday(date, self.trial) then
    	flag = true
    end

    for __, v in pairs(self.textList) do
		v:setVisible(false)
	end

    self.userTrial = TrialMgr.getTrial(self.trial.id)
    --未开放
    if not flag then
    	self.image:setGLProgramState(ProgramMgr.createProgramState('gray'))

    	if not self.userTrial then
	    	self:setReward(false)
	    else
	    	local list = TrialMgr.getJsonRewards(self.trial.id, self.userTrial.trial_val)
			if table.empty(list) then
				self:setReward(false, false)
			else
				if self.userTrial.reward_count < #list then
					self:setReward(true, false)
				else
					self:setReward(false, true)
				end
			end
	    end
    else
    	self.image:setGLProgramState(ProgramMgr.createProgramState('normal'))

    	--已开放
    	if not self.userTrial then
    		self:setEnter(0)
		elseif self.userTrial.try_count < self.trial.try_count then
			self:setEnter(self.userTrial.try_count)
		else
			local list = TrialMgr.getJsonRewards(self.trial.id, self.userTrial.trial_val)
			if table.empty(list) then
				self:setReward(false, false)
			else
				if self.userTrial.reward_count < #list then
					self:setReward(true, false)
				else
					self:setReward(false, true)
				end
			end
    	end
    end
end

function TrialMainItem:setReward(btnVisible, finVisible)

	-- self.reward:setBg(btnVisible)
	self.finish:setVisible(finVisible)
	self.reward:setVisible(btnVisible)
	self.enter:setVisible(false)

	local str = ''
	for i, v in pairs(self.trial.open_day) do
		if v then
			if '' ~= str then
				str = str .. '、'
			end

			if 1 == v then
				str = str .. '一'
			elseif 2 == v then
				str = str .. '二'
			elseif 3 == v then
				str = str .. '三'
			elseif 4 == v then
				str = str .. '四'
			elseif 5 == v then
				str = str .. '五'
			elseif 6 == v then
				str = str .. '六'
			elseif 7 == v then
				str = str .. '日'
			end
		end
	end

	self.textList[1]:setString("每周")
	self.textList[2]:setString(str)
	self.textList[2]:setColor(cc.c3b(0xff, 0xfc, 0x01))
	self.textList[3]:setString("开放")

	self.textList[1]:setPositionX(-75)
	self.textList[2]:setPositionX(-75 + (self.textList[1]:getContentSize().width + self.textList[2]:getContentSize().width) / 2)
	self.textList[3]:setPositionX(self.textList[2]:getPositionX() + (self.textList[2]:getContentSize().width + self.textList[3]:getContentSize().width) / 2)

    for __, v in pairs(self.textList) do
		v:setVisible(true)
	end
end

function TrialMainItem:setEnter(count)
	self.finish:setVisible(false)
	self.reward:setVisible(false)
	self.enter:setVisible(true)

	self.textList[1]:setString("剩余次数：")
	self.textList[1]:setVisible(true)
	self.textList[2]:setString((self.trial.try_count - count) .. '/' .. self.trial.try_count)
	self.textList[2]:setColor(cc.c3b(0xff, 0xfc, 0x01))
	self.textList[2]:setVisible(true)
	self.textList[3]:setVisible(false)

	self.textList[1]:setPositionX(-15)
	self.textList[2]:setPositionX(-15 + (self.textList[1]:getContentSize().width + self.textList[2]:getContentSize().width) / 2)
end

-- function TrialMainItem:getWday(v)
-- 	local val = v + 1
-- 	if val > 7 then
-- 		val = 1
-- 	end

-- 	return val
-- end


function TrialMainItem.checkWday(date, trial)
	for __, v in pairs(trial.open_day) do
		local val = v + 1
		if val > 7 then
			val = 1
		end

		if date.hour >= 6  then
	    	if date.wday == val then
	    		return true
	    	end
	    else
	    	val = val + 1
	    	if val > 7 then
	    		val = 1
	    	end

	    	if date.wday == val then
	    		return true
	    	end
    	end
    end

	return false
end