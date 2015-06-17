Command.bind( 'activity openload', function()
    trans.send_msg( 'PQActivityOpenLoad', {} )
end )

Command.bind( 'activity dataload', function()
    trans.send_msg( 'PQActivityDataLoad', {} )
end )

Command.bind( 'activity factorload', function()
    trans.send_msg( 'PQActivityFactorLoad', {} )
end )

Command.bind( 'activity rewardload', function()
    trans.send_msg( 'PQActivityRewardLoad', {} )
end )

Command.bind( 'activity activitylist', function()
    trans.send_msg( 'PQActivityList', {} )
end )

Command.bind( 'activity infolist', function()
    trans.send_msg( 'PQActivityInfoList', {} )
end )

Command.bind( 'activity takereward', function(open_guid,index)
    trans.send_msg( 'PQActivityTakeReward', { open_guid = open_guid,index = index } )
end )
-- 首充领取
Command.bind( 'activity getfirstrecharge', function()
    trans.send_msg( 'PQPayFristPayReward', {} )
end )
