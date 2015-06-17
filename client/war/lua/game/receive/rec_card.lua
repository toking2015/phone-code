-----谭春映----------
--信息
trans.call.PRAltarInfo = function(msg)
	--LogMgr.debug("抽卡：服务器返回种子 ---",msg.info.money_seed_1,msg.info.money_seed_10,msg.info.gold_seed_1,msg.info.gold_seed_10)
    CardData.addInfo(msg)
    EventMgr.dispatch( EventType.UserCardUpdate )
end

trans.call.PRAltarLottery = function(msg)
	--LogMgr.debug("抽卡：服务器返回种子 ---",msg.info.money_seed_1,msg.info.money_seed_10,msg.info.gold_seed_1,msg.info.gold_seed_10)
	CardData.actReward( msg )
	CardData.qLock = false
	Command.run("loading wait hide", "cardq")
	--LogMgr.error("抽卡：：：：：：服务器返回----------------")
	LogMgr.log( 'action', "card：：：：：：serverback----------------")
	if msg.soldier_id and msg.soldier_id ~= 0 then
		 LogMgr.log( 'action', "card：getsoldier::::::" .. msg.soldier_id)
	else
		for k,v in pairs(msg.reward_list) do
			local str1 = string.format( v.objid .."x".. v.val )
			local str2 = ""
			if CardData.virRewardData then
				local cv = CardData.virRewardData.reward_list[k]
				if cv then
					str2 = string.format( cv.cate .."x".. cv.val )
					if cv.objid ~= v.objid then
--						LogMgr.error("diff：：" .. k )
					end
				end
			end
			--LogMgr.error( k.."服:" ..  str1.."          " .. "客:" .. str2 )
			 LogMgr.log( 'action', k.."server:" ..  str1.."          " .. "client:" .. str2 )
		end
	end
	--LogMgr.error("--------------------------------------------")
	LogMgr.log( 'action', "--------------------------------------------")
    EventMgr.dispatch( EventType.UserCardUpdate )
end