-- create by Live --

-- 请求接受任务
Command.bind( 'task accept', function(id)
    trans.send_msg( 'PQTaskAccept', {task_id = id} )
end )

-- 请求任务记录列表
Command.bind( 'task log', function()
    trans.send_msg( 'PQTaskLogList', {} )
end )

-- 完成任务
Command.bind( 'task finish', function(id)
    trans.send_msg( 'PQTaskFinish', { task_id = id } )
end )


Command.bind( 'task auto finish', function(id)
    trans.send_msg( 'PQTaskAutoFinish', { task_id = id } )
end )

-- 更新任务数据
Command.bind( 'task set', function(id, cond)
    trans.send_msg( 'PQTaskSet', { task_id = id, cond = cond } )
end )


-- 日常活动积分领奖
Command.bind( 'task dayval reward', function(_id)
    trans.send_msg( 'PQTaskDayValReward', { id = _id } )
end )