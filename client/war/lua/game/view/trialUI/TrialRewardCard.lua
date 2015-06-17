

TrialRewardCard1 = createUILayout('TrialRewardCard1', TrialMgr.prePath .. "TrialRewardUI/TrialRewardCard1.ExportJson")
function TrialRewardCard1:setData(userTrialReward, coin, index)
	TrialMgr.setTouchEnabledChild(self, false)

	if index > 4 then
		self.panel1:setVisible(false) 
		self.panel2:setVisible(false)
		return
	elseif 0 == coin.val then
		self.panel1:setVisible(true)
		self.panel2:setVisible(false)
		return
	end

	self.panel2.number:setString(coin.val)
	self.panel1:setVisible(false)
	self.panel2:setVisible(true)
end

TrialRewardCard2 = createUILayout('TrialRewardCard2', TrialMgr.prePath .. "TrialRewardUI/TrialRewardCard2.ExportJson")
function TrialRewardCard2:setData(userTrialReward)
	-- local json = findTrialReward(userTrialReward.reward)
	-- if not json then
	-- 	return
	-- end

	local reward = findReward(userTrialReward.reward)
	if not reward or table.empty(reward.coins) then
		return
	end

	if self.image then
		self.image:removeFromParent()
	end

	self.panel2.name_label:setString('')
	-- self.panel2.count_label:setString(0)
	-- self.panel2.gold_label:setString(0)

	for __, coin in pairs(reward.coins) do
		local url = CoinData.getCoinUrl(coin.cate, coin.objid)

		self.image = UIFactory.getSprite(url, self, 90, 120)

		self.panel2.name_label:setString(CoinData.getCoinName(coin.cate, coin.objid))
		
		self.number:setString(coin.val)

		if const.kCoinItem == coin.cate then
			local item = findItem(coin.objid)
			if item then
				self.panel2.name_label:setColor(ItemData.itemColor[item.quality])
			end
		end
	end

	self.number:setLocalZOrder(100)
end

TrialRewardCard = createLayoutClass("TrialRewardCard", cc.Node)
function TrialRewardCard:ctor(cardIndex)
	self.cardIndex = cardIndex

	self.card1 = TrialRewardCard1.new()
	self.card1:setAnchorPoint(cc.p(0.5, 0))
	self.card1:setPositionX(self.card1:getContentSize().width / 2)
	self:addChild(self.card1)
	self.card2 = TrialRewardCard2.new()
	self.card2:setAnchorPoint(cc.p(0.5, 0))
	self.card2:setPositionX(self.card2:getContentSize().width / 2)
	self:addChild(self.card2)
	self.card2:setVisible(false)
end

function TrialRewardCard:clear()
	self.attr = nil
end

function TrialRewardCard:setData(userTrial, userTrialReward, coin, index, json)
	self.userTrial = userTrial
	self.userTrialReward = userTrialReward
	self.jsonRewardCount = json
	self.coin = coin

	if not userTrialReward or 0 == userTrialReward.flag then
		self.card2:setVisible(false)
		self.card1:setVisible(true)
		self.card = self.card1

		self.attr = 1
	else
		if not self.attr then
			self.card1:setVisible(false)
			self.card2:setVisible(true)
		elseif 2 ~= self.attr then
			TrialMgr.runFirst(self.card1, 1, 
				function()
					self.card1:setVisible(false)
					self.card2:setVisible(true)
					TrialMgr.runSecond(self.card2, -1)
					TrialMgr.runSecond(self.card1, -1)
				end)
		end

		self.card = self.card2
		self.attr = 2
	end

	self.index = index
	self.card:setData(userTrialReward, self.coin, index)

	self.card:setTouchEnabled(true)
    UIMgr.addTouchEnded(self.card,
		function()
			if not self.attr or self.index > 4 or not self.userTrialReward or 0 == self.userTrialReward.falg then
				return
			end

			if 80 == self.coin.objid then
				TipsMgr.showError("本次翻牌结束")
				return
			end

			if self.userTrial.trial_val < self.jsonRewardCount.trial_val then
				TipsMgr.showError("本次翻牌未达成")
				return
			end

			if CoinData.checkLackCoinX(self.coin, false) then
				return
			end

			Command.run("trial reward_get", self.userTrialReward.trial_id, self.cardIndex)
		end)
end