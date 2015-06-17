local prePath = "image/ui/TempleUI/"
local url = prePath .. "TempleScoreDetailUI.ExportJson"
TempleScoreDetail = createUIClass("TempleScoreDetail", url, PopWayMgr.SMALLTOBIG )

function TempleScoreDetail:ctor( ... )
	self.redPos = cc.p(145, 54)
	local function onGet( ... )
		Command.run("temple takereward",self.reward.id)
	end
	createScaleButton(self.get_btn)
	self.get_btn:addTouchEnded(onGet)
	self.cur_score:setString("123")
	self.add_score:setString("234")
	self.reward_item_list = {}
	-- self.reward_txt_list = {}
	local pos = nil
	for i=1,4 do
        local itemBox = BagItem:create( "image/ui/bagUI/Item.ExportJson" )
        itemBox:setScale(0.5,0.5)
        itemBox.scalew = 1.5
        itemBox.item_num:setVisible(false)
        itemBox.item_num_line:setVisible(false)
        itemBox.btn_item_delect:setVisible(false)
        itemBox:showTips(true)
        self:addChild(itemBox)
        -- pos = cc.p(((i - 1) % 2) * 68,36 - math.floor(( i - 1)/2) * 20)

        itemBox:setPosition(60*(i-1)+100,52)
        self.reward_item_list[i] = itemBox
        -- local txt = UIFactory.getText("",self.reward_con,20,cc.c3b(0xff,0xed,0xa8))
        -- self.reward_txt_list[i] = txt
        -- txt:setPosition(cc.p(pos.x+60,pos.y+8))
    end
end

function TempleScoreDetail:delayInit( ... )
	UIFactory.getTitleTriangle(self.bg_1, 1)
end

function TempleScoreDetail:onShow( ... )
	self:updateData()
	EventMgr.addListener(EventType.TempleInfo,self.updateData,self)
end

function TempleScoreDetail:onClose( ... )
	EventMgr.removeListener(EventType.TempleInfo,self.updateData)
end

function TempleScoreDetail:updateData( ... )
	if not TempleData.getData() then
		return
	end
	local list = TempleData.getData().score_current
	local old_list = TempleData.getData().score_yesterday
	local item_list = {}
	
	local data = nil
	local old_data = nil
	local function getItem(key)
		local item = getLayout(prePath .. "ScoreDetailItem.ExportJson")
		item.icon:loadTexture(prePath .. TempleData.getScoreIconUrl(key) .. ".png")
		item.title:loadTexture(prePath .. TempleData.getScoreTxtUrl(key) .. ".png")
		return item
	end
	for i=1,9 do
		local item = nil
		data = list[i]
		old_data = old_list[i]
		item = getItem(i)
		if data then
			if not old_data then
				item.score_txt:setString("+ " .. data.second)
	            item.txt:setString(string.format(TempleData.getScoreTxt(i),data.first))
			else 
				item.score_txt:setString("+ " .. (data.second - old_data.second))
				item.txt:setString(string.format(TempleData.getScoreTxt(i) ,(data.first - old_data.first)))
			end
		else
			item.score_txt:setString("+ 0")
            item.txt:setString(string.format(TempleData.getScoreTxt(i),0))
		end
		if item then 
			table.insert(item_list,item)
		end
	end
	initScrollviewWith(self.ScrollView, item_list,2, 0,0,0,0)
	
	self.reward = TempleData.getReward(TempleData.getRewardScore(1))
	local reward_list = {}
	if self.reward then
		reward_list = self.reward.reward
	end
	setButtonPoint(self.get_btn, TempleData.checkIsCanTakeReward(), self.redPos, 200)
		

	if #reward_list == 0 then
		self.reward = TempleData.getNextReward()
		if self.reward then
			reward_list = self.reward.reward
		end
		self.get_btn:setTouchEnabled(false)
		ProgramMgr.setGray(self.get_btn)
	else
		self.get_btn:setTouchEnabled(true)
		ProgramMgr.setNormal(self.get_btn)
	end
	 -- 显示积分奖励
	for k,v in pairs(self.reward_item_list) do
		local reward = reward_list[k]
		-- local txt = self.reward_txt_list[k]
		if reward then
			-- txt:setString(reward.val)
			v:setReward(reward)
			v:setVisible(true)
			-- txt:setVisible(true)
		else
			v:setVisible(false)
			-- txt:setVisible(false)
		end
	end
	if self.reward then
		self.tips_txt:setString(string.format("积分达到%s可领取",self.reward.score))
	else
		self.tips_txt:setString("")
	end
	self.cur_score:setString(TempleData.getRewardScore(1))
	self.add_score:setString(TempleData.getRewardScore(1)-TempleData.getRewardScore(2))

end

function TempleScoreDetail:dispose( ... )
	-- body
end

