
local prePath = "image/ui/ActTipsUI/"
ActTipsUI = createUIClass("ActTipsUI", prePath.."ActTipsUI.ExportJson", PopWayMgr.SMALLTOBIG)

function ActTipsUI:ctor()
	createScaleButton(self.btn_ccel)
	createScaleButton(self.btn_comfirm)
	local function onCancelClick(sender, eventType)
		ActionMgr.save( 'UI', 'ActTipsUI click btn_ccel' )
		ActTipsData.hideTips()
	end	
	local function onComFirmClick(sender, eventType)
		ActionMgr.save( 'UI', 'ActTipsUI click btn_comfirm' )
		ActTipsData.ComFirClick()
	end
	self.btn_ccel:addTouchEnded(onCancelClick)
	self.btn_comfirm:addTouchEnded(onComFirmClick)
end

function ActTipsUI:onShow( ... )
	EventMgr.addListener(EventType.UserCoinUpdate, self.onUpdateData, self)
	self:onUpdateData()
end

function ActTipsUI:onClose( ... )
	EventMgr.removeListener(EventType.UserCoinUpdate, self.onUpdateData)
end

function ActTipsUI:onUpdateData( ... )
	self.title:loadTexture( "ActTipsUI/" .. ActTipsData.getTitleUrl(), ccui.TextureResType.plistType)
	local buytimes = ActTipsData.getBuyCount()
	if(ActTipsData.getBuyLeft() > 0) then
		self.info_con.info_cost:setVisible(true)
		self.info_con.vip_tips:setVisible(false)
		self.txt_tips:setVisible(false)
		local item_url = "ActTipsUI/" .. ActTipsData.getButItemUrl()
		self.info_con.info_cost.icon_buy:loadTexture(item_url, ccui.TextureResType.plistType)
		self.info_con.info_cost.num_cost:setString(ActTipsData.getCost())
		self.info_con.info_cost.num_buy:setString(ActTipsData.getBuyNum())
		self.btn_comfirm.txt_comfirm:loadTexture("confirm.png",ccui.TextureResType.plistType)

		self.txt_cost:setPosition(202,189)
	else
		self.info_con.info_cost:setVisible(false)
		self.info_con.vip_tips:setVisible(true)
		self.txt_tips:setVisible(true)
		self.btn_comfirm.txt_comfirm:loadTexture("ActTipsUI/txt_vip.png",ccui.TextureResType.plistType)
		self.txt_cost:setPosition(202,169)
	end
	self.txt_cost:setString(string.format("(今日已使用%d/%d次)", tostring(buytimes),ActTipsData.getBuyMax()))
end