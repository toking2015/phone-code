--author:何遵祖
--date:2014.6.13
--descript:
--该文件主要负责的是背包的每个物品功能的封装。

--@class BagItem 
BagItem = class(
    "BagItem",
	function(self, fileName)
		return getLayout(fileName)
	end
)

--@param fileName cocostudio的文件名字
function BagItem:create(_fileName)
	local bagItem = BagItem:new(_fileName)
	-- bagItem:setScale(0.8)
	return bagItem
end 

function BagItem:setItemIcon(id)
	local url = ''
    if id ~= 0 then
        url = ItemData.getItemUrl( id )
    end

    if url ~= '' then
        self.item_icon:setVisible(true)
        self.item_icon:loadTexture( ItemData.getItemUrl( id ), ccui.TextureResType.localType )
        -- BitmapUtil.setTexture(self.item_icon,ItemData.getItemUrl( id ))
    else
        self.item_icon:setVisible(false)
    end
end

function BagItem:setItemCount(count)
	if count == nil	then
		self.item_num:setVisible(false)
		if self.w then
			self.w:setVisible(false)
		end
	else 
		if self.count ~= count then
			self.count = count
			self.num = count
			if self.w then
				self.w:setVisible(false)
			end
			if count >= 10000 then
				if self.w == nil then
					self.w = UIFactory.getSpriteFrame("W.png",self,98,11)
					if self.scalew then
						self.w:setScale(self.scalew,self.scalew)
						--self.w:setPosition(cc.p(98 + 3 * self.scalew,11))
					end
					self.w:setAnchorPoint(cc.p(1,0))
				end
				self.num = math.floor(count / 10000)
				self.w:setVisible(true)
			end
			self.item_num:setString( self.num )
		end
		self.item_num:setVisible(true)
		if self.w and self.w:isVisible() == true then
			local sizew = self.w.getSize and self.w:getSize() or self.w:getContentSize()
			if self.scalew then
				sizew.width = sizew.width * self.scalew
			end
			self.item_num:setPosition(cc.p(98 - sizew.width,11))
		else
			self.item_num:setPosition(cc.p(98,11))
		end
	end
end 

function BagItem:setReward( reward )
	local quality = 3
	self.reward = reward
    if reward.cate == const.kCoinItem then
        local jItem = findItem( reward.objid )
        if jItem then
            quality = ItemData.getQuality( jItem, userItem )
        end
    end
    self.item_quality:loadTexture(ItemData.getItemBgUrl( quality ),ccui.TextureResType.localType)
    local url = CoinData.getCoinUrl(reward.cate, reward.objid)
    if nil == url or url == "" then
        LogMgr.debug("路径不存在：")
    else
        self.item_icon:loadTexture(url,ccui.TextureResType.localType)
        self:setItemCount(reward.val)
    end
end

function BagItem:showTips( value )
	if value then
		-- self:setTouchEnabled(true)
		-- local function onScaleClick(target, eventType )
	 --        if self.reward then
		--         if  eventType == ccui.TouchEventType.began then
	 --              	TipsMgr.showTips(target:getParent():convertToWorldSpace( cc.p(target:getPositionX(), target:getPositionY()) ), TipsMgr.TYPE_COIN, target.reward)
		--         elseif eventType == ccui.TouchEventType.ended then
		--             TipsMgr.hideTips()
		--         end
	 --        end
  --   	end
  --   	self:addTouchEventListener(onScaleClick)
  		self:setTouchEnabled(false)
	  	local function onTouchBegin(touch, event)
	  		if self:isVisible() then
	  			self.time = DateTools.getTime()
	        	TipsMgr.showTips(touch:getLocation(), TipsMgr.TYPE_COIN, self.reward)
	        end
	    end
	    local function onTouchEnd(touch, event)
	  		if self:isVisible() then
	  			local newtime = DateTools.getTime()
	  			if self.time and (newtime - self.time) > 0.2 then
	  				self.time = newtime
	  				TipsMgr.hideTips()
	  			end
	        end
	    end
	    local function hidetips( touch, event )
	    	TipsMgr.hideTips()
	    end
	    --UIMgr.addTouchEnded( self, onTouchBegin )
	  	--UIMgr.registerScriptHandler(self, onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED, true)
	  	UIMgr.registerScriptHandler(self, onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN, true)
	  	--UIMgr.registerScriptHandler(self, hidetips, cc.Handler.EVENT_TOUCH_CANCELLED, true)
	end
end