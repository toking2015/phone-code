Command.bind( 'goods list', 
	function()
        trans.send_msg( 'PQVipTimeLimitShopWeek', {} )
	end 
)

Command.bind( 'buy_list request', 
	function(level, num)
        trans.send_msg( 'PQVipTimeLimitShopBuy', {vip_level = level, count = num } )
	end 
)