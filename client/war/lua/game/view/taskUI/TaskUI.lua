-- create by Live --
--任务主界面
require "lua/game/view/taskUI/TaskReward.lua"
require "lua/game/view/taskUI/TaskRender.lua"

local prePath = "image/ui/TaskUI/"
TaskUI = createUIClass("TaskUI", prePath .. "TaskUI.ExportJson", PopWayMgr.SMALLTOBIG)
TaskUI.sceneName = "common"

function TaskUI:ctor()
	self.isUpRoleTopView = true
	self.itemList = {}

	if GameData.checkLevel(TaskData.openDayLevel) then
		self.selectIndex = 2

		if GameData.checkLevel( TaskData.openDayLevel ) then
			if TaskData.checkHaveOtherCanFinsh() and not TaskData.checkHaveDayCanFinsh() then
				self.selectIndex = 1
			end
		else
			self.selectIndex = 1
		end
	else
		self.selectIndex = 1
	end
	
	--日常
	self.pointview = getLayout( 'image/ui/TaskUI/TaskPoint.ExportJson' )
	self:addChild( self.pointview, 100 )
	self.pointview:retain()
	self.pointview:setPosition( 35, 355 )

	local function OnBoxTouch(target)
		ActionMgr.save( 'UI', '[TaskUI] click [pintView_box]' .. target.index )
		local dayTaskVal = findDayTaskValReward( target.index   )
		CoinData.openRewardGetUI( dayTaskVal.reward, CoinData.getCoinByCate(const.kCoinDayTaskVal) >= dayTaskVal.need_val )
		if CoinData.getCoinByCate(const.kCoinDayTaskVal) >= dayTaskVal.need_val then
			Command.run( 'task dayval reward', target.index )
		end 
	end

	for i=1,4 do
		self.pointview['box_'..i]:setTouchEnabled( true )
		UIMgr.addTouchBegin(self.pointview['box_'..i],OnBoxTouch )
		self.pointview['box_'..i].index = i
	end
	
	self.bg1.icon_player:loadTexture( prePath..'icon_player.png', ccui.TextureResType.localType )
	self.bg1.icon_player:setVisible(false)

    self.btnList = {self.btn_1, self.btn_2}
    local subMenuNames = {"task_btn_text_achieve_", "task_btn_text_task_" }
    local function btnHandler(index)
    	ActionMgr.save( 'UI', '[TaskUI] click [ btnList_'..index..' ]' )
		if index == 2  and not GameData.checkLevel( TaskData.openDayLevel ) then
			TipsMgr.showError( '任务功能'..TaskData.openDayLevel..'开放!' )
			return true
		end

		self.selectIndex = index
		self:updateData()
    end
    UIFactory.initSubMenu(self.btnList, subMenuNames, btnHandler, 1, self.selectIndex )

    function self.updateItemData(data ,constant, dataIndex, itemIndex, widhtCount )
        constant:updateData( self.taskMap[dataIndex] )
        constant.index = dataIndex
    end
	function self.create()
		local item = TaskRender:new()
		item:setTouchEnabled( false )
		table.insert( self.itemList, item )
		return item
	end
    self.tableView = createTableView({}, self.create,self.updateItemData, cc.p(20, 17 ),cc.size(660,345), cc.size(590,115), self )

    --主线
    self.mainView =  getLayout( 'image/ui/TaskUI/TaskMain.ExportJson' ) 
    self:addChild( self.mainView )
    self.mainView:setPosition( 25, 295 )
    self.mainView:retain()

	function self.onMainViewBtnGo(sender, eventType)
		if GameData.checkLevel( TaskData.openDayLevel ) then
			-- TaskData.goToFinsh( sender.data )
			local type = const.kCopyMopupTypeNormal
			local copyId = 0
			if cate == const.kTaskCondCopyFinished then
				copyId = data.cond.objid
			end

			if cate == const.kTaskCondBossKillCount then
				if data.cond.objid == 2 then
					type = const.kCopyMopupTypeElite
				end
			end
			
			Command.run("NCopyUI show copy", type, copyId )		
			PopMgr.removeWindow( self )	
		else
			self.btnList.touchEndedHandler(self.btn_2, ccui.TouchEventType.began)
		end
		ActionMgr.save( 'UI', '[TaskUI] click [mainView_btn_go]' )
	end

	function self.onMainViewBtnGet( sender, eventType )
		if self.mainTask then
	        SoundMgr.playUI( 'UI_perform' )
		 	TaskData.goSubmit( self.mainTask.task_id )
		 	self.mainView.btn_get:setTouchEnabled(false)
		end
	end
	UIMgr.addTouchEnded( self.mainView.btn_go, self.onMainViewBtnGo ) 
	UIMgr.addTouchEnded( self.mainView.btn_get, self.onMainViewBtnGet )
	setButtonPoint( self.mainView.btn_get, true, cc.p( 155, 40 ) ) 

	local function onMainViewReward(target)
		if target.data then
			local postion = target:getParent():convertToWorldSpace( cc.p(target:getPositionX(), target:getPositionY() - 100) )
			if target.data.cate == const.kCoinItem then
				local item = findItem( target.data.objid )
				TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, item )
			else
				local info = CoinData.getCoinName( target.data.cate, target.data.objid )
				TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, info .. '*' ..target.data.val )
			end
		end
		ActionMgr.save( 'UI', '[TaskUI] click [ mainView_reward]' )
	end

    for i=1,4 do
		self.mainView['item_'..i] = BagItem:create("image/ui/bagUI/Item.ExportJson" )
		self.mainView.con_items:addChild( self.mainView['item_'..i] )
		self.mainView['item_'..i]:setScaleX( 75 / 105 )
		self.mainView['item_'..i]:setScaleY( 75 / 105 )
		self.mainView['item_'..i]:setPosition( cc.p( (i - 1) * 100, 20 ) )
		self.mainView['item_'..i].text_name = UIFactory.getText('物品名称', self.mainView, 35, 20, 18 )
		self.mainView['item_'..i].index = i
		self.mainView['item_'..i].item_bg:setVisible( false )
		UIMgr.addTouchBegin(self.mainView['item_'..i], onMainViewReward )
    end

    self.text_more_reward = UIFactory.getText('完成下面任务，还可获得丰厚奖励哦！', self, 355, 250, 18, cc.c3b(0xff, 0xe3, 0x6b))


	function self.onBranchViewBtn(target)
		if target.data then
	        SoundMgr.playUI( 'UI_perform' )
		 	TaskData.goSubmit( target.data.task_id )
		 	target:setTouchEnabled(false)
		end
		ActionMgr.save( 'UI', '[TaskUI] click [ branchView_btn]' )
	end

    for i=1,3 do
    	self['branchView_' ..i] =  getLayout( 'image/ui/TaskUI/TaskBranch.ExportJson' ) 
    	self:addChild( self['branchView_' ..i] )
    	self['branchView_' ..i].item = BagItem:create("image/ui/bagUI/Item.ExportJson" )
    	self['branchView_'..i].item:setScaleX( 75 / 105 )
    	self['branchView_'..i].item:setScaleY( 75 / 105 )
    	self['branchView_'..i].item.item_bg:setVisible( false )
    	self['branchView_' ..i]:addChild( self['branchView_' ..i].item )
    	self['branchView_' ..i].item:setPosition( 60, 60 )
    	self['branchView_' ..i]:setPosition( 30 + ( (i - 1) * 220 ), 30 )
    	self['branchView_' ..i]:retain()
    	self['branchView_' ..i].index = i
    	-- self['branchView_' ..i].text_info:setSize( cc.size( 110, 50 ) )
    	UIMgr.addTouchBegin(self['branchView_' ..i].item, onMainViewReward )
    	UIMgr.addTouchBegin(self['branchView_' ..i].btn, self.onBranchViewBtn )
    	setButtonPoint( self['branchView_' ..i].btn, true, cc.p( 155, 40 ) ) 
    end
end

function TaskUI:onShow()
	EventMgr.addListener( EventType.UserTaskUpdate, self.updateData, self )

	self.btn_2:setVisible( GameData.checkLevel(TaskData.openDayLevel) )

	local function callback()
		self:updateData()
	end
	performNextFrame(self, callback)
end	

function TaskUI:onClose()
	EventMgr.removeListener( EventType.UserTaskUpdate, self.updateData )
end

function TaskUI:dispose()
	for i,v in pairs(self.itemList) do
		v:dispose()
	    v:removeFromParent()
	end

	self.itemList = nil

    for i=1,3 do
    	self['branchView_' ..i]:release()
    	self['branchView_' ..i] = nil
    end

	self.pointview:release()
	self.pointview = nil

  	self.mainView:release()
  	self.mainView = nil
end

function TaskUI:updateData()
	self:updateButtonPoint()

	if self.selectIndex == 2 then --日常任务
		self.pointview:setVisible( true )
		self.tableView:setVisible( true )

		self.mainView:setVisible( false )
		self.branchView_1:setVisible( false )
		self.branchView_2:setVisible( false )
		self.branchView_3:setVisible( false )
		self.text_more_reward:setVisible( false )

		self.taskMap = TaskData.getTaskDataForType( const.kTaskTypeDayRepeat )
		self:setSliderCell(0)
		self.dataLen = #self.taskMap
		self.tableView:reloadData()

		if #self.taskMap < 1 then
			self.bg1.icon_player:setVisible(true)
		else
			self.bg1.icon_player:setVisible(false)
		end

		local box = nil
		local box_index = 1
		local dayTaskVal = nil
		local isFalsh = false
		local nextDayTaskVal = nil
		self.pointview.flash:setVisible( false )
		for i=1,4 do
			box = self.pointview['box_'..i]
			dayTaskVal = findDayTaskValReward( i )
			box.value:setString( dayTaskVal.need_val..'积分' )
			box:setPositionX( 40 + math.floor( 570 / 95 ) * dayTaskVal.need_val )

			if i == 1 then
				box_index = i
			else
				box_index = i - 1
			end		
				
			if i <= #GameData.user.day_task_reward_list then
				if GameData.user.day_task_reward_list[i] > 0 then
					box:setTouchEnabled( false )
					box:loadTexture( 'task_box_'..box_index..'_2.png', ccui.TextureResType.plistType )
					setButtonPoint( box, false )
				else
					if isFalsh == false then
						if CoinData.getCoinByCate(const.kCoinDayTaskVal) >= dayTaskVal.need_val then
							isFalsh = true
							self.pointview.flash:setVisible( true )
							self.pointview.flash:setPositionX( box:getPositionX() + 10 )
						end
					end

					if nextDayTaskVal == nil then
						nextDayTaskVal = dayTaskVal
					end

					box:setTouchEnabled( true )
					box:loadTexture( 'task_box_'..box_index..'_1.png', ccui.TextureResType.plistType )
					
					setButtonPoint( box, CoinData.getCoinByCate(const.kCoinDayTaskVal) >= dayTaskVal.need_val, cc.p( 55, 50 ) )
				end
			else
				if isFalsh == false then
					if CoinData.getCoinByCate(const.kCoinDayTaskVal) >= dayTaskVal.need_val then
						isFalsh = true
						self.pointview.flash:setVisible( true )
						self.pointview.flash:setPositionX( box:getPositionX() + 10 )
					end
				end

				setButtonPoint( box, CoinData.getCoinByCate(const.kCoinDayTaskVal) >= dayTaskVal.need_val, cc.p( 55, 50 ) )

				if nextDayTaskVal == nil then
					nextDayTaskVal = dayTaskVal
				end

				box:setTouchEnabled( true )
				box:loadTexture( 'task_box_'..box_index..'_1.png', ccui.TextureResType.plistType )	
			end
		end
		local coinDayTaskVal = CoinData.getCoinByCate(const.kCoinDayTaskVal)
    	local function setProgress()
    		if self.pointview then
    			local space = 0.2
    			if self.pointview.coinDayTaskVal - self.pointview.nowTaskVal > space then
    				self.pointview.nowTaskVal = self.pointview.nowTaskVal + space
				elseif self.pointview.nowTaskVal - self.pointview.coinDayTaskVal > space then
					self.pointview.nowTaskVal = self.pointview.nowTaskVal - space
				else
					TimerMgr.killPerFrame(setProgress)
				end
				self.pointview.progress:setPercent( self.pointview.nowTaskVal / 95 * 100   )
    		end
		end
		self.pointview.coinDayTaskVal = coinDayTaskVal
		self.pointview.nowTaskVal = math.floor( self.pointview.progress:getPercent() )

    	TimerMgr.callPerFrame( setProgress )
	
		self.pointview.text_point_value:setString( coinDayTaskVal )
		local nextVal = nextDayTaskVal and nextDayTaskVal.need_val or 0
		nextVal = nextVal - CoinData.getCoinByCate(const.kCoinDayTaskVal)
		if nextVal < 0 then
			nextVal = 0
		end
		self.pointview.text_point_value_1:setString( nextVal )
	else
		self.pointview:setVisible( false )
		self.tableView:setVisible( false )
		self.bg1.icon_player:setVisible(false)

		self.mainView:setVisible( true )
		self.branchView_1:setVisible( true )
		self.branchView_2:setVisible( true )
		self.branchView_3:setVisible( true )
		self.text_more_reward:setVisible( true )

		self.mainTask = TaskData.getMianTask()
		if self.mainTask then
			if self.mainTask.task_id ~= 10033 then
				self.mainView.btn_go.icon:loadTexture( 'task_up_way.png', ccui.TextureResType.plistType )
			else
				self.mainView.btn_go.icon:loadTexture( 'image/ui/TaskUI/task_btn_copy.png', ccui.TextureResType.localType )
			end
			self.mainView.btn_go.data = self.mainTask
			
			self.mainView.con_detail.txt_task_type:setString( '目标:'..self.mainTask.name )
			self.mainView.con_detail.txt_detail:setString( TaskData.getTaskDesc( self.mainTask ) )
			self.mainView.btn_get:setTouchEnabled( true )
			if TaskData.checkTaskCanFinsh( self.mainTask.task_id ) then 
				self.mainView.btn_get:setVisible( true )
				self.mainView.btn_go:setVisible( false )			
			else
				self.mainView.btn_get:setVisible( false )
				self.mainView.btn_go:setVisible( true )		
			end
			local taskCoins = TaskData.getTaskCoins( self.mainTask )
			local item = nil
			for i = 1, 4 do
				item = self.mainView['item_'..i]
				if i <= #taskCoins then
			        local jItem = nil
			        local quality = 1
			        if jItem ~= nil then
			             quality = ItemData.getQuality( jItem )
			        end
			      
			      	item:setVisible( true )
			      	item.text_name:setVisible( true )
		        	item.item_num_line:setVisible(false)
		        	item.btn_item_delect:setVisible(false)
			       	item.item_quality:setVisible(true)
			        -- BitmapUtil.setTexture(item.item_quality, ItemData.getItemBgUrl( quality ))

			        item.item_icon:setVisible(true)
			        item.item_icon:loadTexture( CoinData.getCoinUrl( taskCoins[i].cate, taskCoins[i].objid ), ccui.TextureResType.localType )	        
			        item:setItemCount( taskCoins[i].val )
			        item.data = taskCoins[i]
			        item:setPositionX( ( 375 - ( 100 * #taskCoins ) ) / 2 + (i - 1) * 100 )
			       	item.item_quality:loadTexture( 'image/ui/bagUI/itembg/ItemBg_'..quality..'.png', ccui.TextureResType.localType )
					-- item.text_name:setColor(ItemData.getItemColor(quality))	
					item.text_name:setColor( cc.c3b( 0x5a, 0x10, 0x19) )
					item.text_name:setString( CoinData.getCoinName( taskCoins[i].cate, taskCoins[i].objid )  )
					item.text_name:setPosition( item:getPositionX() + 100, item:getPositionY() )
				else
					item:setVisible( false )
					item.text_name:setVisible( false )
				end
			end
		end	

		self.branchTask = TaskData.getTaskDataForType( const.kTaskTypeBranch )
		local branchView = nil
		local item = nil
		local userTask = nil
		local jTask = 1
		for i=1,3 do
			branchView = self['branchView_'..i]
			if i <= #self.branchTask  then
				branchView:setVisible(true)
				branchView.btn.data = self.branchTask[i]
				branchView.btn:setTouchEnabled( true )

				item = branchView.item
				userTask = self.branchTask[i]
				jTask = findTask( userTask.task_id )

				local taskCoins = TaskData.getTaskCoins( jTask )
				local coin = nil
				if taskCoins then
					coin = taskCoins[1]
				end
		        local quality = CoinData.getCoinQuality( coin.cate, coin.objid )
	        	item.item_num_line:setVisible(false)
	        	item.btn_item_delect:setVisible(false)
		       	item.item_quality:setVisible(true)
		       	item.data = coin
		        -- BitmapUtil.setTexture(item.item_quality, ItemData.getItemBgUrl( quality ))

		        item.item_icon:setVisible(true)
		        item.item_icon:loadTexture( CoinData.getCoinUrl( coin.cate, coin.objid ), ccui.TextureResType.localType )	        
		        item:setItemCount( coin.val )	
	        	item.item_quality:loadTexture( 'image/ui/bagUI/itembg/ItemBg_'..quality..'.png', ccui.TextureResType.localType )

		        branchView.text_info:setString( jTask.name  )
		        local startCond = userTask.cond
		        local endCond = TaskData.getTaskCoinVal( jTask )
		        if startCond > endCond then
		        	startCond = endCond
		    	end
		    	branchView.task_progress:setString( startCond .. "/" .. endCond )
		        
		        if TaskData.checkTaskCanFinsh( userTask.task_id ) then
		        	branchView.btn:setVisible( true )
		        	branchView.task_un:setVisible( false )
		        else
					branchView.btn:setVisible( false )
					branchView.task_un:setVisible( true )
		        end
			else
				branchView:setVisible(false)
			end
		end
	end
end

function TaskUI:updateButtonPoint()
	local off =  cc.p( 10, 75 )
	setButtonPoint( self.btn_1, false )
	setButtonPoint( self.btn_2, false )
	if GameData.checkLevel( TaskData.openDayLevel ) then
		if TaskData.checkHaveDayCanFinsh() then
			setButtonPoint( self.btn_2, true, off )
		end

		if TaskData.checkHaveOtherCanFinsh() then
			setButtonPoint( self.btn_1, true, off )
		end
	else
		if TaskData.checkHaveOtherCanFinsh() then
			setButtonPoint( self.btn_1, true, off )
		end
	end	
end

function TaskUI:setAchieveSelect(index)
 	TimerMgr.callLater(
 			function()
 				if self.btnList then
 					self.btnList.touchEndedHandler( self['btn_'..index], ccui.TouchEventType.began)
 				else
					TaskUI:setAchieveSelect()
 				end
 			end,
 			0.2
 		)	
end

function TaskUI:getItemById( id )
	if self.taskMap then
		local cell = self.tableView:cellAtIndex( table.indexOf( self.taskMap, TaskData.getTask(id) ) - 1 )
		if cell then
			cell = cell:getChildByTag(1)
		end
		return cell
	end
	return nil
end

function TaskUI:getMainView()
	return self.mainView
end