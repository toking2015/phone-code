-- Create By Hujingjing --

local prevPath = "image/ui/MainUI/"

RoleRightView = class("RoleRightView", function()
	return getLayout(prevPath .. "RoleRightView.ExportJson")
end)

function RoleRightView:create()
	local ui = RoleRightView.new()

	ui:init()

	return ui
end

function RoleRightView:ctor()
	local function updateRedPoint()
		if self:getParent() then
			setButtonPoint( self.btn_active, ActivityData.checkActionGeted(), cc.p( 55, 60 ))
			if OpenTargetData.getIsOpen() == true then
				setButtonPoint( self.btn_opentarget, OpenTargetData.getCanget(), cc.p( 55, 65 ))
			end
		end
	end
	local function scriptHandler(event)
		if event == "enter" then
			if not self.red_timer_id then
				self.red_timer_id = TimerMgr.startTimer(updateRedPoint, 1)
			end
		elseif event == "exit" then
			self.red_timer_id = TimerMgr.killTimer(self.red_timer_id)
		end
	end
	self:registerScriptHandler(scriptHandler)
	setButtonPoint( self.btn_active, ActivityData.checkActionGeted(), cc.p( 55, 60 ))
end

-- 初始化 [主界面]右边按钮
function RoleRightView:init()
	local view = self

	local btn_opentarget = createScaleButton(view.btn_opentarget)
	local btn_task = createScaleButton(view.btn_task)
	local btn_active = createScaleButton(view.btn_active)
	local task_tarack = nil
	

	--local btnSize = btn_opentarget:getContentSize()
	--btn_opentarget:addChild(Particle:create("effect_btn.plist", btnSize.width / 2, btnSize.height / 2 + 30), 100, 100)
	
	local function showOpenTargetHandler()
	   	ActionMgr.save( 'UI', 'ActivityOpenTargetUI click btn_opentarget' )
    	Command.run( 'ui show', "ActivityOpenTargetUI", PopUpType.SPECIAL )
	end
    btn_opentarget:addTouchEnded(showOpenTargetHandler)
    OpenTargetData.updateForce()

	local function showTaskHandler()
        ActionMgr.save( 'UI', 'TaskUI click btn_task' )
		LogMgr.log( 'debug',"showTaskHandler......")
		Command.run( 'ui show', "TaskUI", PopUpType.SPECIAL )
	end
	btn_task:addTouchEnded(showTaskHandler)

	local function showActiveHandler()
--		 Command.run( 'scene enter', 'test' )
        -- Command.run( 'ui show', 'BossRecordUI', PopUpType.SPECIAL )
        -- Command.run("BuilderLayer showAll")
        --TipsMgr.showError("该功能暂未开放")
        --活动UI
        ActionMgr.save( 'UI', 'ActivityUI click btn_active' )
        Command.run( 'ui show', 'ActivityUI', PopUpType.SPECIAL )
	end
    btn_active:addTouchEnded(showActiveHandler)

    local function updateTaskUp()
		if SceneMgr.isSceneName("main") then
			if TaskData.hasTask( 10035 ) then
				if self.task_up == nil then
					self.task_up = UIFactory.getSprite( 'image/ui/TaskUI/task_icon_up_level.png', self.btn_task, -130, 50, 100 )
				end
				self.task_up:stopAllActions()
		        local move = cc.MoveBy:create(0.5,cc.p(20,0))
		        local easeIn = cc.EaseSineInOut :create( move )
       			local sq = cc.Sequence:create(easeIn, easeIn:reverse())
       			local re = cc.RepeatForever:create( sq )
				self.task_up:runAction( re )
				return
			end
		end

		if self.task_up then
			self.task_up: stopAllActions()
			self.task_up:removeFromParent()
			self.task_up = nil
		end		
    end

    local function userTaskUpdate()
		setButtonPoint( self.btn_task, TaskData.checkHaveCanFinsh(), cc.p( 55, 75 ) )
		
		updateTaskUp()
	end

	local function checkOpenFunc()
		if OpenFuncData.checkIsOpen(OpenFuncData.TYPE_FUNC, 9, false) then --任务开启id=9
			if InductMgr:checkRunEnd( 31 ) then
				btn_task:setVisible(true)

				if task_tarack then
					task_tarack:onClose()
					view:removeChild( task_tarack )
					task_tarack = nil
				end
			else
				btn_task:setVisible(false)

				if task_tarack == nil then
					task_tarack = TaskTrackUI.new()
					view:addChild( task_tarack )
					task_tarack:onShow()
					task_tarack:updateData()
					task_tarack:setPositionY( 150 )	
				end
			end
		else
			btn_task:setVisible(false)
		end
	end

	local function userTaskFinsh()
		checkOpenFunc()
	end

	EventMgr.addListener( EventType.UserTaskUpdate, userTaskUpdate )	
	EventMgr.addListener( EventType.hour, userTaskUpdate )	
	EventMgr.addListener( EventType.UserDataLoaded, userTaskUpdate )
	EventMgr.addListener( EventType.OpenFunc, checkOpenFunc )
	EventMgr.addListener( EventType.UserDataLoaded, checkOpenFunc )
	EventMgr.addListener( EventType.UserTaskLogUpdate, userTaskFinsh )
	EventMgr.addListener( EventType.InductEnd, checkOpenFunc )
	EventMgr.addListener( EventType.NewDayBegain, self.updateOpenTarget,self )
	EventMgr.addListener( EventType.SceneShows, updateTaskUp )
	
	userTaskUpdate()
	checkOpenFunc()
	self:updateOpenTarget()
end

function RoleRightView:updateOpenTarget( ... )
		OpenTargetData.getCurOpenDay(true)
		if OpenTargetData.getIsOpen() == true then
			self.btn_opentarget:setVisible(true)
		else
			self.btn_opentarget:setVisible(false)
		end
	end
function RoleRightView:onlyShowTask()
    self.btn_opentarget:setVisible(false)
    self.btn_active:setVisible(false)
end
function RoleRightView:resetShow()
    self:updateOpenTarget()
    self.btn_active:setVisible(true)
end