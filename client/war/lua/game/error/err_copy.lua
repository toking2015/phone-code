EventMgr.addListener( 'kErrFightFailure', function()
    --将记录上传到服务器
    local log = LogMgr.get_cache_log( 'fight' )
    if log ~= nil and log ~= '' then
        local stream = seq.string_to_stream( log )
        local length = seq.stream_length( stream )

        trans.send_msg( 'PQFightErrorLog', { data = { size = length, data = zlib.compress( stream ) } } )
    end

    --弹出确认
    showMsgBox( "[image=alert.png][font=ZH_10]战斗校验失败，请联系技术人员。[btn=one]confirm.png", function()
        --[[
        if copy_commit_event_fight_data ~= nil then
            TimerMgr.callLater(function()
                trans.send_msg( 'PQCopyCommitEventFight', copy_commit_event_fight_data )
            end, 1)
        end
        --]]
    end)
end )

EventMgr.addListener( 'kErrCoinLack', function()
    PopMgr.removeWindowByName("SaoDangUI")
end )