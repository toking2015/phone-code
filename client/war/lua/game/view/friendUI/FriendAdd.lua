-- author:toking
local resPath = "image/ui/FriendUI/"

FriendAdd = createUILayout("FriendAdd", resPath .. "Friend_add.ExportJson", "FriendUI" )

function FriendAdd:ctor( ... )
	createScaleButton(self.btn_make_add)
	createScaleButton(self.btn_make_cancel)
	TextInput:replace(self.txt_make_input, 100)

	self.btn_make_add:addTouchEnded(function ( ... )
		ActionMgr.save( 'UI', 'FriendAdd click btn_make_add' )
		local act_code = self.txt_make_input:getText()
		if act_code ~= "" then
			Command.run( 'frined make_name',act_code)
			-- self.isWaiting = true
			-- Command.run("loading login server", act_code)
		end
	end)
	self.btn_make_cancel:addTouchEnded(function ( ... )
		ActionMgr.save( 'UI', 'FriendAdd click btn_make_cancel' )
		if self.parents and self.parents.hideOtherWin then
			self.parents:hideOtherWin("addui")
		end
		end)
end

function FriendAdd:onShow( ... )
	local function changeHandler(input)
		--self.txt_err:setString("")
	end
	self.txt_make_input.changeHandler = changeHandler
	self.txt_make_input:setPlaceHolder("请输入好友名称")
	--self.txt_err:setString("")
end

function FriendAdd:onClose( ... )
end