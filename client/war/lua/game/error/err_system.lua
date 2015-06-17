local __error_exit_data = 
{
    kErrSystemSession = '用户登录信息已失效, 请重新登录!',
    kErrSystemRemoteLogin = '帐号异地登录!',
    kErrSystemUnusualError = '系统未知错误导致登录信息失效, 请重新登录',
    kErrSystemResend = '重新连接请求数据失败, 请重新登录'
}

for key, var in pairs(__error_exit_data) do
    EventMgr.addListener( key, function()
        showMsgBox( "[image=alert.png][font=ZH_10]" .. var .. "[btn=one]confirm.png", system.exit)
    end )
end
