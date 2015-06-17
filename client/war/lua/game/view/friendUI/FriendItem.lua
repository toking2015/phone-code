-- write by toking 
local prepath = "image/ui/FriendUI/"
local url = prepath .. "Friend_item1.ExportJson"
FriendItem = class(
	"FriendItem", 
	function()
		return getLayout(url)
	end
)

function FriendItem:ctor( ... )
	self[FriendData.TYPE_FRIEND]={self.name,self.level,self.legion,self.icon_face}
	self[FriendData.TYPE_STRANGER]={self.name,self.level,self.legion,self.icon_face}
	self[FriendData.TYPE_BLIACK]={self.btn_black_delect,self.name,self.level,self.legion,self.icon_face}
	self["isrecomand"]={self.name,self.legion,self.icon_face,self.btn_recom_add,self.fla_ask}
	self[FriendData.TYPE_ASKED]={self.btn_ask_accept,self.btn_ask_refuse,self.btn_ask_black,self.txt_ask_title,self.txt_ask_name,self.txt_ask_tips}
    --self:setTouchEnabled(true)
    --self.icon_face:setTouchEnabled(true)
    self.countbg:setVisible(false)
    self.icon_face:setScale(0.75,0.75)
    self.icon_face:setPosition(-6,3)
	local function btnHandler(sender,eveType )
		if eveType ~= ccui.TouchEventType.ended then
	        return
	    end
	    local name = sender:getName()
	    ActionMgr.save( 'UI', 'FriendItem click '.. name )

	    if name == "btn_send2" then
	    	if self.send2_time and (DateTools.getTime() - self.send2_time) < 2 then
	    		return
	    	end
	    	self.send2_time = DateTools.getTime()
		end
		FriendData:btnHandler(name,self.friend_data)
	end
	UIMgr.addTouchEnded( self.btn_send2, btnHandler )
	UIMgr.addTouchEnded( self.btn_black_delect, btnHandler )
	UIMgr.addTouchEnded( self.btn_recom_add, btnHandler )
	UIMgr.addTouchEnded( self.btn_ask_accept, btnHandler )
	UIMgr.addTouchEnded( self.btn_ask_refuse, btnHandler )
	UIMgr.addTouchEnded( self.btn_ask_black, btnHandler )
	UIMgr.addTouchEnded( self, btnHandler )
end

function FriendItem:setRoleData( roleData )
	if roleData then
		self.role_data = roleData
		self:updateRole()
	end
end

function FriendItem:updateRole( ... )
	if self.friend_data then
		self.icon_face:loadTexture(TeamData.getAvatarUrlById(self.friend_data.friend_avatar))
		self.name:setString(self.friend_data.friend_name)
		self.txt_ask_name:setString(self.friend_data.friend_name)
		self.level:setString('Lv.' .. self.friend_data.friend_level)
		self.legion:setString(FriendData:getLegionName(nil,self.friend_data.friend_gname))
	end
	if self.role_data then
		--self.icon_face:loadTexture(string.format("image/icon/avatar/%s.png", roleData.avatar))
		self.icon_face:loadTexture(TeamData.getAvatarUrlById(self.role_data.avatar))
		self.name:setString(self.role_data.name)
		self.txt_ask_name:setString(self.role_data.name)
		self.level:setString('Lv.' .. self.role_data.team_level)
		self.legion:setString(FriendData:getLegionName(self.role_data.guild_id))
	end
end

function FriendItem:dispose( ... )
	if self.re_tips and self.re_tips.release then
		self.re_tips:release()
	end
	if self.friend_data then
		self.friend_data = nil
	end
	if self.timer_id then
		TimerMgr.killTimer(self.timer_id)
		self.timer_id = nil
	end
end

function FriendItem:onClose( ... )
	self:dispose()
end

function FriendItem:updateData( friendData,isrecomand )
	self.fla_recom = isrecomand
	for _,v in ipairs(self[FriendData.TYPE_FRIEND]) do
		v:setVisible(false)
	end
	self.btn_black_delect:setVisible(false)
	self.btn_recom_add:setVisible(false)
	self.bg_left_time:setVisible(false)
	self.btn_send2:setVisible(false)
	self.btn_send1:setVisible(false)
	self.fla_ask:setVisible(false)

	for _,v in ipairs(self[FriendData.TYPE_ASKED]) do
		v:setVisible(false)
	end
	self.bg_left_time:setVisible(false)
	if friendData then
		self.friend_data = friendData
		if isrecomand then
			for _,v in ipairs(self["isrecomand"]) do
				v:setVisible(true)
			end
			self.role_id = friendData.friend_id
			self.bg:loadTexture("image/ui/FriendUI/img/bg_item2.png", ccui.TextureResType.localType )
			if table.indexOf(FriendData.FriendAskMakeFriend,friendData.friend_id) ~= -1 then
				self.fla_ask:setVisible(true)
				self.btn_recom_add:setVisible(false)
			else
				self.btn_recom_add:setVisible(true)
				self.fla_ask:setVisible(false)
			end
		else
			if FriendData.current_type == FriendData.TYPE_FRIEND then
				self.role_id = friendData.friend_id
				local rp_pos = cc.p(78+18, 50 + 34)
				setButtonPointWithNum(self.icon_face, FriendData:getNewChatById(self.role_id) > 0, FriendData:getNewChatById(self.role_id), rp_pos)
				self.bg:loadTexture("image/ui/FriendUI/img/bg_item1.png", ccui.TextureResType.localType )
				--赠送---------------
				if FriendData:getCanSenActivity(friendData.friend_id) then
					self.bg_left_time:setVisible(true)
					self.btn_send2:setVisible(false)
					self.btn_send1:setVisible(true)
					if self.timer_id == nil then
					 	local function runLater()
					 		local  lefttime = FriendData:getCanSenActivity(friendData.friend_id)
					 		if lefttime then
								self.bg_left_time.txt_left_time:setString(DateTools.secondToString(lefttime))
							else
								TimerMgr.killTimer(self.timer_id)
								self.timer_id = nil
								EventMgr.dispatch( EventType.FriendLimitChange )
							end
				        end
						self.timer_id = TimerMgr.startTimer(runLater, 1)
						runLater()
					end
				else
					self.btn_send2:setVisible(true)
					self.btn_send1:setVisible(false)
				end
				--赠送结束-----------
			elseif FriendData.current_type == FriendData.TYPE_BLIACK then
				self.role_id = friendData.friend_id
				self.bg:loadTexture("image/ui/FriendUI/img/bg_item3.png", ccui.TextureResType.localType )
			elseif FriendData.current_type == FriendData.TYPE_STRANGER then
				self.role_id = friendData.friend_id
				local rp_pos = cc.p(78+18, 50 + 34)
				setButtonPointWithNum(self.icon_face, FriendData:getNewChatById(self.role_id) > 0, FriendData:getNewChatById(self.role_id), rp_pos)
				self.bg:loadTexture("image/ui/FriendUI/img/bg_item3.png", ccui.TextureResType.localType )
			else
				self.role_id = friendData.friend_id
				self.bg:loadTexture("image/ui/FriendUI/img/bg_item4.png", ccui.TextureResType.localType )
			end
			for _,v in ipairs(self[FriendData.current_type]) do
				v:setVisible(true)
			end
		end
	end
	self:updateRole()
end