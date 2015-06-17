-- create by Live --
local kObjectAdd = trans.const.kObjectAdd
local kObjectDel = trans.const.kObjectDel
local kObjectUpdate = trans.const.kObjectUpdate


-- @@任务数据更新返回
trans.call.PRTaskSet = function(msg)
    if msg.set_type == kObjectAdd then
    	TaskData.addTask(msg.data)
    	TaskData.RmoveAcceptTask(msg.data.task_id )
    	EventMgr.dispatch( EventType.TaskAdd, msg.data.task_id )
	elseif msg.set_type == kObjectDel then
		TaskData.deleteTask(msg.data)
        EventMgr.dispatch( EventType.TaskDel, msg.data.task_id )
	elseif msg.set_type == kObjectUpdate then
		TaskData.updateTask(msg.data)
		TaskData.onTaskUpdate(msg.data)
	end

	 EventMgr.dispatch( EventType.UserTaskUpdate, msg.data.task_id )
end


-- 返回任务完成记录( 只增不删 )
trans.call.PRTaskLog = function(msg)
	TaskData.addLogTask(msg.data)
    TaskData.searchAcceptTask()
    EventMgr.dispatch( EventType.UserTaskLogUpdate )
end

trans.call.PRTaskDayList = function(msg)
	TaskData.setDayTaskList(msg.data)
    EventMgr.dispatch( EventType.UserTaskUpdate )
end

trans.call.PRTaskDay = function(msg)
	TaskData.updateDayTask(msg.data)
    EventMgr.dispatch( EventType.UserTaskUpdate )
end

trans.call.PRTaskDayValReward = function(msg)
	if msg.err == 0 then
		GameData.user.day_task_reward_list[msg.id]=msg.id
		EventMgr.dispatch( EventType.UserTaskUpdate )
	else

	end
end


trans.call.PRTaskDayValRewardList = function( msg)
	GameData.user.day_task_reward_list=msg.id_list
	EventMgr.dispatch( EventType.UserTaskUpdate )
end
