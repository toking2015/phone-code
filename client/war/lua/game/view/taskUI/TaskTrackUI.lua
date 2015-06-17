TaskTrackUI = createLayoutClass("TaskTrackUI", cc.Node)
local effect = nil
local change = nil
local taskId = 0

function TaskTrackUI:ctor()
	self.bg =  UIFactory.getSprite("image/ui/TaskUI/task_track_bg.png", self, 0, 0, 1)
	self.textName = UIFactory.getLabel('', self, 0, 0, 18, cc.c3b(0xff, 0xfc, 0x00), nil, cc.TEXT_ALIGNMENT_RIGHT, 3)
	self.textName:setPosition( cc.p( 12, 12 ) )

	self.textInfo = cc.Label:createWithTTF('11', FontNames.HEITI, 16)
	self.textInfo:setColor(cc.c3b(0xff, 0xff, 0xff))
	self:addChild( self.textInfo, 2 )
	self.textInfo:setPosition( cc.p( 0, -20 ) )
	self.textInfo:setWidth( 120 )

	self:showEffcet()

	local function toucheBegin()
		if GameData.checkLevel(10) then
			Command.run( 'ui show', "TaskUI", PopUpType.SPECIAL )			
		end 
		ActionMgr.save( 'UI', 'TaskTrackUI click' )
	end
	UIMgr.addTouchBegin( self.bg, toucheBegin )
end

function TaskTrackUI:updateData()
	local task = TaskData.getMianTask()
	if task then
		self.textName:setString( task.name )
		self.textInfo:setString( task.desc )
	end
end

function TaskTrackUI:showChange( id )
	if id ~= 0 then
		if not SceneMgr.isSceneName("fight") and ( not PopMgr.hasWindowOpen() ) then
			taskId = 0
			local task = findTask( id )
			if task then
				effect:setVisible( false )
				effect:stop()
				if task and task.type == const.kTaskTypeMain then
					if change == nil then
						local effectName = 'rwzz-tx-02'
						local prePath = "image/armature/ui/TaskUI/" .. effectName .. "/"  
						local change = nil
						local index = 0
						local complete = function()
							index = index + 1
							if index >= 2 then
								self:updateData()
								-- change:removeNextFrame()
								effect:setVisible( true )
								effect:play()
								change:setVisible( false )
								change:stop()
								index = 0
							end
						end 

						change = ArmatureSprite:addArmature(prePath .. effectName .. ".ExportJson", effectName, 'TaskTrackUI', self, -81, 27, complete, 2, 2 )
					else
						change:setVisible( true )
						change:play()
					end
				end
			end
		else
			taskId = id
		end
	end
end

function TaskTrackUI:showEffcet()
	local effectName = 'rwzz-tx-01'
	local prePath = "image/armature/ui/TaskUI/" .. effectName .. "/"  
	effect = ArmatureSprite:addArmature(prePath .. effectName .. ".ExportJson", effectName, 'TaskTrackUI', self, -115, 58, nil, 2 )
	effect:setSpeedScale( 0.25 )
end

function TaskTrackUI:onSceneShow(name)
	self:showChange( taskId )
end

function TaskTrackUI:onWindowClose(... )
	self:showChange( taskId )
end

function TaskTrackUI:onShow()
	EventMgr.addListener( EventType.TaskAdd, self.showChange, self )
	EventMgr.addListener( EventType.SceneShows, self.onSceneShow, self  )
	EventMgr.addListener( EventType.CloseWindow, self.onWindowClose, self  )
end

function TaskTrackUI:onClose()
    Command.run("loading wait hide", "task")
	EventMgr.removeListener( EventType.TaskAdd, self.showChange )
	EventMgr.removeListener( EventType.SceneShows, self.onSceneShow )
	EventMgr.removeListener( EventType.CloseWindow, self.onWindowClose )
end
