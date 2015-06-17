local resPath = "image/ui/FriendUI/"

require("lua/game/view/bagUI/BagItem.lua")
require("lua/game/view/friendUI/FriendItemSend.lua")

FriendDetail = createUILayout("FriendDetail", resPath .. "Friend_gift.ExportJson", "FriendUI" )

function FriendDetail:ctor( ... )
	self.is_showsend = false
	self.btnMap = {"btn_gift_chat","btn_gift_gift","btn_gift_challenge","btn_gift_look","btn_gift_black","btn_gift_delect","btn_gift_add","btn_gift_invit_legion","btn_gift_jubao"}
	
	self.btnFriend = {"btn_gift_delect","btn_gift_black","btn_gift_look",
	"btn_gift_challenge","btn_gift_gift","btn_gift_chat"}
	self.btnSinple = {"btn_gift_jubao","btn_gift_black","btn_gift_challenge","btn_gift_invit_legion","btn_gift_add","btn_gift_chat"}
	self.btnList = {}


	local function btnHandler(sender,eveType )
		if eveType ~= ccui.TouchEventType.ended then
	        return
	    end
	    local name = sender:getName()
	    ActionMgr.save( 'UI', 'FriendDetail click '.. name )
	    if name == "btn_gift_gift" then
	    	self:showSendItem()
	   	elseif name == "btn_gift_chat" or name == "btn_gift_black" or name == "btn_gift_delect" then
	   		FriendData:btnHandler(name,self.role_id)
	   		if self.parents and self.parents.hideOtherAllWin then
	   			self.parents:hideOtherAllWin()
	  		else
	  			if self.parents and self.parents.addFriendDetail then
	  				self.parents:addFriendDetail()
	  			end
	  		end
	   	else
	   	 	FriendData:btnHandler(name,self.role_id)
	   	end
	end
	if gameData.getSimpleDataByKey("team_level") < 20 then
		ProgramMgr.setGray(self.btn_gift_jubao)
    	self.btn_gift_jubao:setEnabled(false)
	else
		ProgramMgr.setNormal(self.btn_gift_jubao)
    	self.btn_gift_jubao:setEnabled(true)
	end
	if OpenFuncData.checkIsOpen(1,20,false) then
		ProgramMgr.setNormal(self.btn_gift_challenge)
    	self.btn_gift_challenge:setEnabled(true)
	else
		ProgramMgr.setGray(self.btn_gift_challenge)
    	self.btn_gift_challenge:setEnabled(false)
	end
	ProgramMgr.setGray(self.btn_gift_invit_legion)
	self.btn_gift_invit_legion:setEnabled(false)
	ProgramMgr.setGray(self.btn_gift_look)
	self.btn_gift_look:setEnabled(false)

	UIMgr.addTouchEnded( self.btn_gift_jubao, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_chat, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_gift, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_challenge, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_look, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_black, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_delect, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_add, btnHandler )
	UIMgr.addTouchEnded( self.btn_gift_invit_legion, btnHandler )
end

function FriendDetail:showSendItem( ... )
	if self.is_showsend == false then
		if not self.friend_data then
			TipsMgr.showError("不是好友不能赠送物品！")
			return
		end
		if self.sendui == nil then
			self.sendui = FriendItemSend:new()
			self.sendui:setPosition(169,13)
		end
		self:addChild(self.sendui)
		self.sendui:setVisible(true)
		self.sendui:onShow()
		self.sendui:setFriendData(self.friend_data)
		self.is_showsend = true
	else
		if self.sendui then
			self.sendui:onClose()
			if self.sendui:getParent() then
				self.sendui:removeFromParent()
				self.sendui = nil
			end
		end
		self.is_showsend =false
	end
	self:updateSize()
	if self.parents then
		--self.parents:updateSize()
	end
end

function FriendDetail:getSize( ... )
	local size = cc.size(460, 431)
	if self.is_showsend == false then
		size.width = 176
	else
		size.width = 460
	end
	return size
end

function FriendDetail:updateSize( ... )
	local sx1 = 176
	local sy1 = 429

	local sx2 = 153
	local sy2 = 352
	if self.btnList then
		sy1 = sy1 - (6 - #self.btnList) * 57
		sy2 = sy2 - (6 - #self.btnList) * 57 

		self.txt_name:setPositionY(406 - (6 - #self.btnList) * 57 )
		self.txt_level:setPositionY(406 - (6 - #self.btnList) * 57 )
		self.txt_legion:setPositionY(380 - (6 - #self.btnList) * 57 )
	end
	if self.is_showsend == true then
		sx1 = 460
	else
		sx1 = 176
	end
	self.bg1:setSize(cc.size(sx1, sy1))
	self.bg2:setSize(cc.size(sx2, sy2))
end

function FriendDetail:updateBtn( ... )
	if not self.role_id then
		return
	end
	for _,v in pairs(self.btnMap) do
		self[v]:setVisible(false)
	end
	self.friend_data = FriendData:getFriendDataByRoleIdType(self.role_id)
	if self.friend_data then
		self.btnList = self.btnFriend
	else
		self.btnList = self.btnSinple
	end
	for _,v in pairs(self.btnList) do
		self[v]:setVisible(true)
		self[v]:setPositionY(49 + (_ - 1) * 57)
	end
end

function FriendDetail:setRoleId( role_id )
	self.role_id = role_id
	self.friend_data = FriendData:getFriendDataByRoleId(self.role_id)
	if not(self.friend_data and self.friend_data.friend_name ~= nil and self.friend_data.friend_name ~="") then
		FriendData:updateCachetData(role_id,self)
	end
	self:updateData()
end

function FriendDetail:setRoleData( roledata )
	self.role_data = roledata
	--self.friend_data = friendData
	self:updateData()
end

function FriendDetail:onShow( ... )
	self:updateData()
end

function FriendDetail:dispose( ... )
	if self.sendui then
		self.sendui:onClose()
		--self.sendui:release()
		if self.sendui:getParent() then
			self.sendui:removeFromParent()
		end
		self.sendui = nil
	end
	self.is_showsend = false
	self.role_id = nil
	--self.role_data = nil
	--self.friend_data = nil
end

function FriendDetail:onClose( ... )
	self:dispose()
end

function FriendDetail:updateData( ... )
	if not self.role_id then
		return
	end
	if self.friend_data and self.friend_data.friend_name ~= nil and self.friend_data.friend_name ~="" then
		self.txt_name:setString(self.friend_data.friend_name)
		self.txt_level:setString('Lv.' .. self.friend_data.friend_level)
		self.txt_legion:setString(FriendData:getLegionName( nil,self.friend_data.friend_gname) )
	end
	if self.role_data then
		self.txt_name:setString(self.role_data.name)
		self.txt_level:setString('Lv.' .. self.role_data.team_level)
		self.txt_legion:setString(FriendData:getLegionName( self.role_data.guild_id) )
	end
	self:updateBtn()
	self:updateSize()
	self.friend_data = FriendData:getFriendDataByRoleId(self.role_id)
	if self.is_showsend == true and not self.friend_data then
		FriendDetail:showSendItem()
	elseif self.is_showsend == true then
		self.sendui:setFriendData(FriendData:getFriendDataByRoleId(self.role_id))
	end
end