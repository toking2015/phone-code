-- @@请求好友列表
Command.bind( 'friend list', function()
    trans.send_msg( 'PQFriendList', {} )
    LogMgr.debug( 'friend', '发送协议：PQFriendList' ..'\n')
end )

-- @@请求好友限制列表
Command.bind( 'friend limit_list', function()
    trans.send_msg( 'PQFriendLimitList', {} )
    LogMgr.debug( 'friend', '发送协议：PQFriendLimitList' ..'\n')
end )
-- @@请求赠送好友物品 const.kItemClientTypeMaterial
Command.bind( 'friend give', 
	function(_friend_id,_give_type,_active_score,_item_list)
    trans.send_msg( 'PQFriendGive', 
	{friend_id=_friend_id,give_type=_give_type,active_score=_active_score,item_list=_item_list} )
    LogMgr.debug( 'friend', '发送协议：PQFriendGive' ..'\n')
end )

-- 好友分组修改
Command.bind( 'frined update_group', 
    function(_id,_type,_group)
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQFriendUpdate',{target_id = _id,set_type = _type,group = _group})
    	LogMgr.debug( 'friend', '发送协议：PQFriendUpdate; target_id = '.._id..";set_type =".._type..";group =" ..'\n')
    end 
)
-- 真正拉黑
Command.bind( 'frined FriendBlack', 
    function(_id)
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQFriendBlack',{target_id = _id})
        LogMgr.debug( 'friend', 'PQFriendBlack; target_id = '.._id..'\n')
    end 
)

--加好友并分组
Command.bind( 'frined make', 
    function(_id)
    trans.send_msg( 'PQFriendRequest',{target_id = _id})
	 LogMgr.debug( 'friend', '发送协议：PQFriendRequest;target_id = '.._id ..'\n')
    end 
)

--加好友并分组
Command.bind( 'frined make_group', 
    function(_id,_group)
        trans.send_msg( 'PQFriendMake',{target_id = _id,group = _group})
        LogMgr.debug( 'friend', '发送协议：PQFriendMake; target_id = '.._id.." group =".._group ..'\n')
    end 
)

-- 以key加好友
Command.bind( 'frined make_name', 
    function(_name)
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQFriendMakeByName',{target_name = _name})
        LogMgr.debug( 'friend', '发送协议：PQFriendMakeByName;target_name ='.._name ..'\n')
    end 
)

-- 全部加好友
Command.bind( 'frined make_all', 
    function(_list)
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQFriendMakeAll',{target_id_list = _list})
        LogMgr.debug( 'friend', '发送协议：PQFriendMakeAll;target_id_list.length='..#_list ..'\n')
    end 
)

-- 接受加好友
Command.bind( 'frined accept', 
    function(_id)
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQFriendOK',{target_id = _id})
        LogMgr.debug( 'friend', '发送协议：PQFriendOK ; target_id ='.._id ..'\n')
    end 
)

-- 请求推荐好友
Command.bind( 'frined recom', 
    function( )
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQSFriendRecommend',{})
        LogMgr.debug( 'friend', '发送协议：PQSFriendRecommend' ..'\n')
    end 
)

-- 请求推荐好友
Command.bind( 'frined fightapply', 
    function( _friend_id )
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQFriendFightApply',{friend_id = _friend_id})
        LogMgr.debug( 'friend', '发送协议：PQFriendFightApply' ..'\n')
    end 
)