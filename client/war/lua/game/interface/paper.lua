

Command.bind("paper collect", function(collect_level)
    LogMgr.debug(">>>>>>>>>>>副本采集：collect_level = " .. collect_level)
    trans.send_msg("PQPaperCollect", {collect_level = collect_level})
end)