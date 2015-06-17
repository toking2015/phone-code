local __this = {}
Config = __this

__this.init = function( config )
    __this.data = config
    if __this.data == nil then
        __this.data = { debug = true, guide = true, group = 'debug', host = '192.168.1.249' }
    end
end

__this.is_debug = function()
    return __this.data.debug
end

Config.FUZZY_VAR = 10 --点击模糊判断相等的距离
Config.MAX_NAME_LENGTH = 18 --最大名字长度
Config.TIPS_DELAY_TIME = 0.8 --1.0秒算长按