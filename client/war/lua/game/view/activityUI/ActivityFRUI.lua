--**颜土金
--**首充活动
require("lua/game/view/bagUI/BagItem.lua")
ActivityFRUI = createUIClassEx("ActivityFRUI", ccui.Layout)
function ActivityFRUI:onShow()
	EventMgr.addList(self.event_list)
    performNextFrame(self, function() self:updateData() end)
end

function ActivityFRUI:onClose()
	EventMgr.removeList(self.event_list)
end

function ActivityFRUI:dispse( ... )
end

function ActivityFRUI:updateData( )
	self.btn:setVisible(true)
	if ActivityData.hasFirstRecharge() == false then
		self.btn:loadTexture(ActivityData.path2 .. "btn_recharge.png",ccui.TextureResType.localType)
		self.btn:setPositionX(370-44)
	elseif ActivityData.hasGetedFR() == false then
		self.btn:loadTexture(ActivityData.path2 .. "btn_get.png",ccui.TextureResType.localType)
		self.btn:setPositionX(370)
	else
		self.btn:setVisible(false)
	end
end

function ActivityFRUI:dispose( ... )
	if #self.item_contat > 0 then
	 	for i=1,#self.item_contat do 
	 		self.item_contat[i]:release()
	 	end
	 end
end

function ActivityFRUI:ctor()
    --记录需要释放的其他窗口的资源
    local otherPath = "image/ui/bagUI/"
    LoadMgr.addPlistPool(otherPath.."WarPackage0.plist", otherPath.."WarPackage0.png", LoadMgr.WINDOW, self.winName)

    --self.txtTitle:setString("活动")
   	self:setSize(cc.size(890, 474))
    self:setTouchEnabled(true)
    self.item_contat = {}
	local url = ActivityData.path2 .. "bg_fr.png"
	self.bg = UIFactory.getSprite(url,self,0,0)
	self.bg:setAnchorPoint(cc.p(0,0))
	self.btn = UIFactory.getButton(ActivityData.path2 .. "btn_recharge.png",self,370-44,41,5, ccui.TextureResType.localType)
	function touchEnd( sender,eveType )
		ActionMgr.save( 'UI', 'ActivityFRUI click btn' )
		if ActivityData.hasFirstRecharge() and ActivityData.hasGetedFR() == false then
			Command.run("activity getfirstrecharge")
		else
			Command.run("ui hide","ActivityFRUI")
			Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
		end
	end
	self.btn:addTouchEnded(touchEnd)
	self:initRewardList()

	self.event_list = {}
    self.event_list[EventType.UserPayUpdate] = function() self:updateData() end
    self.event_list[EventType.UserVarUpdate] = function() self:updateData() end
end

function ActivityFRUI:initRewardList( ... )
	local cpoint = cc.p(402,137)
	local rewad_id = tonumber(findGlobal("first_pay_coin").data)
 	local reward = findReward(rewad_id)
 	if not reward or table.empty(reward.coins) then
 		return
 	end
 	local reward_count = #reward.coins
 	for i = 1,reward_count do 
 		local reward_item = self:createItem(reward.coins[i])
 		self:addChild(reward_item)
 		if i == 1 then
 			self:createBtnEffect(reward_item)
 		end
 		reward_item:setPosition(cpoint.x - (reward_count * 105 + (reward_count - 1 ) * 10)/2  + (i - 1) * 114,cpoint.y)
 	end
end

function ActivityFRUI:createItem(reward)
	local rewardItem = BagItem:create("image/ui/bagUI/Item.ExportJson" )
	rewardItem.item_num_line:setVisible(false)
	rewardItem.btn_item_delect:setVisible(false)
	rewardItem:retain()
	if reward then
		rewardItem.reward = reward
		local quality = 3
		if reward.cate == const.kCoinItem then
			local jItem = findItem( reward.objid )
			if jItem then
				quality = ItemData.getQuality( jItem, userItem )
			end
		end
		rewardItem.item_quality:loadTexture(ItemData.getItemBgUrl( quality ),ccui.TextureResType.localType)
 		local url = CoinData.getCoinUrl(reward.cate, reward.objid)
	 	if nil == url or url == "" then
            LogMgr.debug("路径不存在：")
    	else
    		rewardItem.item_icon:loadTexture(url,ccui.TextureResType.localType)
    		rewardItem:setItemCount(reward.val)
    	end
	end
	table.insert(self.item_contat,rewardItem)
	rewardItem:showTips(true)
	return rewardItem
end

function ActivityFRUI:createBtnEffect( tar_btn )
	if tar_btn then
		if tar_btn.markEff == nil then
			local bSize = tar_btn:getSize()
			tar_btn.markEff = self:signEffectAction("xck-tx-03", bSize.width/2, bSize.height/2 - 3, tar_btn)
		end
	end
end

function ActivityFRUI:signEffectAction(name, x, y, parent)
	local url = "image/armature/ui/cardui/" .. name .. "/" .. name ..".ExportJson"
	LoadMgr.loadArmatureFileInfo(url, LoadMgr.SCENE, "main")
	local effect = ArmatureSprite:create(name, 0)
	effect:setPosition(cc.p(x, y))
	parent:addChild(effect)
	return effect
end
