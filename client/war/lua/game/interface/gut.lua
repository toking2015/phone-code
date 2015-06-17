-- @@请求剧情事件
Command.bind( 'gut info', 
	function()
   		trans.send_msg( 'PQGutInfo' )
	end 
)

-- 事件验证基类
Command.bind( 'gut commit', 
	function(gutIndex)
   	 	trans.send_msg( 'PQGutCommitEvent', {index= gutIndex} )
	end 
)

-- 事件验证--战斗
Command.bind( 'gut commitFight', 
	function(gutIndex, orderList, fightInfoList)
   		trans.send_msg( 'PQGutCommitEventFight', {index= gutIndex, order_list= orderList, fight_info_list=fightInfoList} )
	end 
)

--刷新数据
Command.bind( 'gut refurbish', 
	function()
   		trans.send_msg( 'PQGutRefurbish' )
	end 
)

