Command.bind( 'mail take', 
	function(mid)
        trans.send_msg( 'PQMailTake', {mail_id = mid} )
	end 
)

Command.bind( 'mail write', 
	function(tid, sub, str, items)
        trans.send_msg( 'PQMailWrite', {target_id = tid, subject = sub, body = str, coins = items} )
	end 
)

Command.bind( 'mail read', 
	function(mid)
        trans.send_msg( 'PQMailReaded', {mail_id = mid} )
	end 
)

Command.bind( 'mail del', 
	function(mid)
        trans.send_msg( 'PQMailDel', {mail_id = mid} )
	end 
)