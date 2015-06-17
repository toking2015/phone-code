trans.call.PRUserData = function(msg)
    Command.run("loading fake percent")
    LogMgr.log( 'login', '[login] 登录用户数据\n' )
    local stream = zlib.uncompress( msg.data.data, msg.data.size )
    gameData.id = msg.role_id
    gameData.user =  seq.stream_to_object( "SUserData", stream )
    UserData.saveCache("SUserSimple", msg.role_id, gameData.user.simple) --缓存数据
    --weihao 获取拍卖行信息
--    Command.run( 'buylist') 
    LogMgr.log( 'login', '[login] 初始化任务数据\n' )
    TaskData.setTaskLogMap(gameData.user.task_log_map or {})
    -- TaskData.setTaskMap(gameData.user.task_map or {})
    TaskData.initLeveTask()
    TaskData.searchAcceptTask()
    TaskData.onTaskList()

    LogMgr.log( 'login', '[login] 副本数据初始化\n' )
    local u_copy = gameData.user.copy
    CopyData.user.copy = clone(u_copy)
    CopyRewardData.prePosi = u_copy.posi + 1
    
    if CopyData.user.copy.copy_id == 0 then
        local copy_id = 0
        if u_copy.copy_id == 0 then
            copy_id = CopyData.getNextCopyId()
        end
        --服务器以忽略 copy_id 参数, 自动打开下一个副本, copy_id 仍然传参只是方便action记录
        Command.run( 'copy open', copy_id )
    end

    CopyData.setMaterialList(gameData.user.copy_material_list)

    CopyData.initAreaBossList()
    --请求祭坛信息
    Command.run( 'altar info' )
    --请求二级属性
    Command.run( 'extable list', const.kAttrSoldier )
    --请求活动数据
    Command.run( 'activity activitylist' )
    Command.run( 'activity infolist' )
    -- LogMgr.debug( debug.dump(gameData.user ) )
    LogMgr.debug(">>>>>>>>>>>> Live 需要信息 ： ")
    -- LogMgr.debug(">>>>>>>>>>> var_map : \n" .. debug.dump(gameData.user.var_map))
    -- LogMgr.debug(">>>>>>>>>>> copy_log_map : \n" .. debug.dump(gameData.user.copy_log_map))
    LogMgr.debug(">>>>>>>>>>> area_log_map : \n" .. debug.dump(gameData.user.area_log_map))

    if VarData.getVar( 'user_step' ) < 2 then
        VXinYouMgr.user_register()
        VXinYouMgr.ad_reg()
        VXinYouMgr.role_create(gameData.getSimpleDataByKey("name"), 1, DateTools.getTime())
    end
    VXinYouMgr.role_login(gameData.getSimpleDataByKey("team_level"))

    LogMgr.log( 'login', '[login] 用户加载事件抛出\n' )
    EventMgr.dispatch( EventType.UserDataLoaded )
    EventMgr.dispatch( EventType.InfEnterServer )
    EventMgr.dispatch( EventType.InfCreateRole )

    EventMgr.dispatch(EventType.InfEnterServer)
    EventMgr.dispatch(EventType.InfCreateRole)

    LogMgr.log( 'login', '[login] 引导流程初始化\n' )
    OpeningMgr.initialize()

end

trans.call.PRUserSimple = function(msg)
    if msg.target_id == gameData.id then
        gameData.user.simple = msg.data
        EventMgr.dispatch( EventType.UserSimpleUpdate )
    end
    UserData.saveCache("SUserSimple", msg.target_id, msg.data) --缓存数据
end

trans.call.PRUserOther = function(msg)
    gameData.user.other = msg.other
    StoreData.setWinTime(msg.other.single_arena_win_times)
    ReportPostData.setTime( gameData.user.other.chat_ban_endtime)
    EventMgr.dispatch(EventType.UserOther)
end

trans.call.PRUserTimeLimit = function(msg)
    EventMgr.dispatch(EventType.NewDayBegain)
    TaskData.searchAcceptTask()
    TrialMgr.refreshData()
    TombData.refreshData()
end
