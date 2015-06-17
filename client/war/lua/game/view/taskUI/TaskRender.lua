-- create by Live --
--单条主界面任务详情

local prePath = "image/ui/TaskUI/"

TaskRender = class(
	"TaskRender", 
	function()
		return getLayout(prePath .. "TaskRender.ExportJson")
	end
)

function TaskRender:ctor()
	self.itemList = {}

	addOutline(self.con_detail.txt_task_type, cc.c4b(0x59,0x1f,0x09,0xff),0.5)
	addOutline(self.con_detail.txt_detail,cc.c4b(0x60,0x2f,0x14,0xff),0.5)
	addOutline(self.con_detail.txt_times,cc.c4b(0x44,0x1d,0x00,0xff),0.5)
	addOutline(self.con_detail.sub_info,cc.c4b(0x44,0x1d,0x00,0xff),0.5)

	self.icon.icon:setPosition( 0, 95 )

	function self.getHandler()
		if self.data and TaskData.checkTaskCanFinsh(self.data.task_id) then
	        TaskData.finishTaskData = self.data
	        SoundMgr.playUI( 'UI_perform' )
		 	TaskData.goSubmit( self.data.task_id )
		 	self.btn_get:setTouchEnabled(false)

			if self.effectGet == nil then
				local effectGetName = 'ljkg-tx-02'
				local path = 'image/armature/ui/TaskUI/'..effectGetName..'/'..effectGetName..'.ExportJson'
				LoadMgr.loadArmatureFileInfo(path, LoadMgr.WINDOW, effectGetName )
				local function onGetCom()
					if self.effectGet:getParent() then
						self.effectGet:removeFromParent()
					end
				end
				self.effectGet = ArmatureSprite:addArmatureTo( self, path, effectGetName, 360, 70, onGetCom )	
				self.effectGet:retain()	
			else
				self.effectGet:gotoAndPlay( 0 )
				self:addChild( self.effectGet )
			end	 
		end
		local id = 0
		if self.data then
			id = self.data.task_id
		end
		ActionMgr.save( 'UI', '[TaskUI] click [ btn_get id='..	id..']' )
	end

	function self.goHandler()
		local task_id = 0
		if self.data then
			 task_id = self.data.task_id
		end

		if self.data and not TaskData.checkTaskCanFinsh(task_id) then
			TaskData.goToFinsh( findTask( task_id ) )
		end
		
		ActionMgr.save( 'UI', '[TaskUI] click [ TaskRender.btn_go id='..task_id..']' )		
	end
	UIMgr.addTouchEnded(self.btn_get, self.getHandler)
    UIMgr.addTouchEnded(self.btn_go, self.goHandler)
end

function TaskRender:dispose()
	for i,v in ipairs(self.itemList) do
        v:removeFromParent()
		v:release()
	end
	self.itemList = nil

	if self.effectGet then
		self.effectGet:removeFromParent()
        self.effectGet:release()
        self.effectGet = nil
	end

	if self.effectCanGet then
		self.effectCanGet:removeFromParent()
		self.effectCanGet:release()
		self.effectCanGet = nil
	end
end	

function TaskRender:updateData(value)
	self.data = value
	self.con_items:removeAllChildren()
	self.btn_get:setTouchEnabled(true)

	if value ~= nil then
	    local taskData = findTask(value.task_id)

		if TaskData.checkTaskCanFinsh(value.task_id) then
			self.btn_get:setVisible( true )
			self.btn_go:setVisible(false)
			self.sub_info:setVisible( false )
		else
			self.btn_get:setVisible( false )
			
			if taskData.cond.cate == const.kTaskCondTime then
				self.sub_info:setString( '时间未到' )
				self.sub_info:setVisible( true )
				self.btn_go:setVisible(false)
			elseif taskData.cond.cate == const.kTaskCondTeamLevel then
				self.btn_go:setVisible(false)
				self.sub_info:setVisible( false )
			else
				self.btn_go:setVisible(true)
				self.sub_info:setVisible( false )
			end
		end

		--taskStatus = 
		local taskCoins = TaskData.getTaskCoins( taskData )
		local nums = table.getn(taskCoins)
		local hasExp = false
		for i = 1, nums, 1 do
			local item = self:getItem(i) 
			item:updateData( taskCoins[i] )
			item:setPosition( cc.p(10 + (i - 1) * (item:getSize().width + 15), 0 ))
			self.con_items:addChild(item)
			if hasExp == false and taskCoins[i].cate == const.kCoinTeamXp then
				hasExp = true
			end
		end

		self.icon.icon:setVisible( hasExp )

		--taskIcon

		self.icon:loadTexture( "image/icon/task/"..taskData.icon..".png", ccui.TextureResType.localType )

		self.con_detail.txt_task_type:setString(taskData.name)
		self.con_detail.txt_detail:setPositionX( self.con_detail.txt_task_type:getPositionX() + self.con_detail.txt_task_type:getSize().width + 10 )
		self.con_detail.txt_detail:setString(TaskData.getTaskDesc( taskData ) )

		self.con_detail.txt_times:setVisible( taskData.cond.cate ~= const.kTaskCondVipLevel )
		local task_cond = ''
		if taskData.cond.cate ~= const.kTaskCondTime then
			task_cond = self.data.cond .. "/" .. TaskData.getTaskCoinVal( taskData )
		end
		self.con_detail.txt_times:setString( task_cond )

		if TaskData.checkTaskCanFinsh( value.task_id ) then
			if self.effectCanGet == nil then
				local effectCanGetName = 'ljkg-tx-01'
				local path = 'image/armature/ui/share/'..effectCanGetName..'/'..effectCanGetName..'.ExportJson'
				LoadMgr.loadArmatureFileInfo(path, LoadMgr.WINDOW, effectCanGetName )
				self.effectCanGet = ArmatureSprite:addArmatureTo( self, path , effectCanGetName, 575, 45 )
				self.effectCanGet:retain()		
			end			
		else
			if self.effectCanGet ~= nil then
				self.effectCanGet:removeFromParent()
				self.effectCanGet:release()	
				self.effectCanGet = nil
			end
		end
	end
end

function TaskRender:getItem(index)
	local item = nil
	if index <= #self.itemList then
		item = self.itemList[index]
	else
		item = TaskRewardItem:new()
		item:retain()
		self.itemList[index] = item
	end

	return item
end