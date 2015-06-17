-- 购买体力
Command.bind( 'buy strength', 
	function(tid)
        trans.send_msg( 'PQStrengthBuy', {} )
	end 
)