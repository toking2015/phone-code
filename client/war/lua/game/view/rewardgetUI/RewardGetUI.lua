local prePath = "image/ui/RewardGetUI/"
local url = prePath .. "rewardGetMain.ExportJson"
RewardGetUI = createUIClass("RewardGetUI", url, PopWayMgr.SMALLTOBIG)
function RewardGetUI:onShow()
	
end
function RewardGetUI:onClose()
	if self.callBack then
		self.callBack()
	end
	TipsMgr.showSuccess("领取成功")
end
function RewardGetUI:updateData()
	local img = self.btnOk:getVirtualRenderer()
	if self.canGet then
		img:setGLProgramState( ProgramMgr.createProgramState( 'normal' ) )
		buttonDisable(self.btnOk,false)
	else
		img:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
		buttonDisable(self.btnOk,true)
	end
	if self.coins then
		self.coinLen = #self.coins
		for k,coin in pairs(self.coins) do
			if k <= 4 then
				local item = self.itemList[k]
				local url = CoinData.getCoinUrl(coin.cate,coin.objid)
				item.icon:loadTexture(url,ccui.TextureResType.localType)
				--item.icon:setVisible(true)

				local name = CoinData.getCoinName(coin.cate,coin.objid)
				if name then
					item.name:setString(name .. "X" .. coin.val)
					item.num:setString(coin.val)
				else
					item.num:setString(coin.cate..":"..coin.objid)
				end
				
				if coin.cate == const.kCoinItem	then
					url = ItemData.getItemBgUrl(coin.objid)
					item.box:loadTexture(url,ccui.TextureResType.localType)
				end

				if coin.cate == const.kCoinGlyph then
					CoinData:setGlyphItem( coin,self.winName,item,"icon","box",cc.p(50,50),true )
				end

				if coin.cate == const.kCoinSoldier then
					CoinData:setSoldierItem( coin,item,"icon","box",cc.p(50,50))
				end
			end
		end
	end
	self:resetPostion()
end

function RewardGetUI:setData( coins,canGet,cue, callBack )
	if canGet == nil then
		canGet = true
	end
	self.coins = coins
	self.canGet = canGet
	self.cue = cue
	self.callBack = callBack
	self:updateData()
end

function RewardGetUI:resetPostion()
	if self.coinLen and self.coinLen > 0 then
		local pos = self["pos" .. self.coinLen]
		--长度大于4情况
		if pos == nil then
			pos = self.pos4
		end
		local len = #pos
		for k,v in pairs(self.itemList) do
			if k <= self.coinLen then
				v:setVisible(true)
				if k <= len then
					v:setPosition(pos[k],self.h)
				else
					LogMgr.debug("谭......RewardGetUI:::"..k)
				end
			else
				v:setVisible(false)
				v:setPosition(0,0)
			end
		end
	end
end
function RewardGetUI:ctor()
    local function exit(sender, type)
        ActionMgr.save( 'UI', 'RewardGetUI click btnOk' )
        if self.cue and self.cue ~= "" then
        	TipsMgr.showGreen(cue)
        end
        PopMgr.removeWindow(self)
    end

	self.h = 155
	self.pos1 = {245}
	self.pos2 = {167,318}
	self.pos3 = {94,244,394}
	self.pos4 = {65,184,301,420}

	self.itemList = {}
	for i=1,4 do
		local item = getLayout(prePath .. "item.ExportJson")
		item:setAnchorPoint(cc.p(0.5,0.5))
		self:addChild(item,10)
		table.insert(self.itemList,item)
	end

	buttonDisable(self.btnOk,false)
	self:resetPostion()
	createScaleButton(self.btnOk)
	self.btnOk:addTouchEnded(exit)
	buttonDisable(self.btnOk,true)
end