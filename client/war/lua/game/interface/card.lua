-- create by 谭春映 --
--信息----
Command.bind( 'altar info', function()
    trans.send_msg( 'PQAltarInfo', {} )
end )
-- 召唤
Command.bind( 'altar lottery', function(type,count,usetype)
    trans.send_msg( 'PQAltarLottery', {lottery_type = type,lottery_count = count ,use_type = usetype } )
end )