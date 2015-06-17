--用户数据请求

Command.bind('user simple', function(guid)
        trans.send_msg('PQUserSimple', {target_id=guid})
end)
