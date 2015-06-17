-- 订单列表
Command.bind( 'pay list', 
	function(tid)
        trans.send_msg( 'PQPayList', {target_id = tid} )
	end 
)

Command.bind( 'pay info', 
	function()
        trans.send_msg( 'PQPayInfo', { } )
	end 
)

Command.bind( 'month reward', 
	function()
        trans.send_msg( 'PQPayMonthReward', { } )
	end 
)

Command.bind( 'pay notice', 
	function(tid)
        trans.send_msg( 'PQPayNotice', {target_id = tid} )
	end 
)