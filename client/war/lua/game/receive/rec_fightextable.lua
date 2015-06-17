--二级属性(英雄。。。)
trans.call.PRFightExtAbleList = function( msg )
    if gameData.user.fightextable_map == nil then
        gameData.user.fightextable_map = {}
    end
    gameData.user.fightextable_map[msg.attr] = msg.fightextable_list
    UserData.updateFightValue()
    EventMgr.dispatch( EventType.UserFightExtAbleUpdate )
end
--二级属性 （在升级时候）
trans.call.PRFightExtAbleSet = function(msg)
    gameData.changeArray( gameData.user.fightextable_map[ msg.fightextable.attr ], 'guid', trans.const.kObjectAdd, msg.fightextable )
    UserData.updateFightValue()
    EventMgr.dispatch( EventType.UserFightExtAbleUpdate )
end