local resPath = "image/ui/FriendUI/"

FriendBlack = createUILayout("FriendBlack", resPath .. "Friend_black.ExportJson", "FriendUI" )

function FriendBlack:ctor( ... )
	local function btnHandler(sender,eveType )
		if eveType ~= ccui.TouchEventType.ended then
	        return
	    end
	    local name = sender:getName()
	    ActionMgr.save( 'UI', 'FriendBlack click '.. name )
	    FriendData:btnHandler(name,self.role_id)
	end
	ProgramMgr.setGray(self.btn_black_look)
	self.btn_black_look:setEnabled(false)

	if OpenFuncData.checkIsOpen(1,20,false) then
		ProgramMgr.setNormal(self.btn_black_challenge)
    	self.btn_black_challenge:setEnabled(true)
	else
		ProgramMgr.setGray(self.btn_black_challenge)
    	self.btn_black_challenge:setEnabled(false)
	end
	UIMgr.addTouchEnded( self.btn_black_challenge, btnHandler )
	UIMgr.addTouchEnded( self.btn_black_look, btnHandler )
end

function FriendBlack:setRoleId( role_id )
	self.role_id = role_id
	self.friend_data = FriendData:getFriendDataByRoleId(self.role_id)
	if not(self.friend_data and self.friend_data.friend_name ~= nil and self.friend_data.friend_name ~="") then
		FriendData:updateCachetData(role_id,self)
	end
	self:updateData()
end

function FriendBlack:setRoleData( roledata )
	self.role_data = roledata
	--self.role_id = roledata
	self:updateData()
end

function FriendBlack:onShow( ... )
	self:updateData()
end

function FriendBlack:onClose( ... )
	self.role_data = nil
end

function FriendBlack:updateData( ... )
	if self.friend_data and self.friend_data.friend_name ~= nil and self.friend_data.friend_name ~="" then
		self.name:setString(self.friend_data.friend_name)
		self.level:setString('Lv.' .. self.friend_data.friend_level)
		self.legion:setString(FriendData:getLegionName( nil,self.friend_data.friend_gname) )
	end
	if self.role_data then
		self.name:setString(self.role_data.name)
		self.level:setString('Lv.' .. self.role_data.team_level)
		self.legion:setString(FriendData:getLegionName(self.role_data.guild_id)) 
	end
end