trans.call.PRMailData = function(msg)
    gameData.changeMap( MailBoxData.getMailMap(), msg.data.mail_id, msg.set_type, msg.data )
    
    MailBoxMgr.checkReceiveMail(msg)
    EventMgr.dispatch( EventType.UserMailBoxUpdate, msg.data )
end

trans.call.PRMailDataList = function(msg)
	-- local list = {}
	-- for _, v in pairs(msg.list) do
	-- 	list[v.mail_id] = v
	-- end
	-- gameData.user.mail_map = list
	for _, v in pairs(msg.list) do
		gameData.changeMap(MailBoxData.getMailMap(), v.mail_id, msg.set_type, v)
	end

	if trans.const.kObjectAdd == msg.set_type then
		-- EventMgr.dispatch(EventType.addNewMail, msg.data)
	elseif trans.const.kObjectUpdate == msg.set_type then
		EventMgr.dispatch(EventType.recvAllMail)
	else
		EventMgr.dispatch(EventType.delAllMail)
	end
end