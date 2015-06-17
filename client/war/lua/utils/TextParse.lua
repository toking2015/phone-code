local __this = {}

--'你于{date:1416240155}{time:1416240155}售出物品:{coin:4%500%1}, 获得{coin:1%0%1000}hello world!'
--解释成: "你于2014年11月18日00:02:35售出物品:珍品石×1, 获得金币×1000hello world!"
function __this.custom_parse( text )
    local keep_search = true
    local save_idx = 0
    local next_idx = 1
    local cur_idx = 0

    local ret = ''
    while keep_search do
        cur_idx, next_idx = text.find( text, "{[^}]*}", next_idx )
        if cur_idx == nil then
            break
        end

        ret = ret .. string.sub( text, save_idx + 1, cur_idx - 1 )
        save_idx = next_idx

        local str = string.sub( text, cur_idx + 1, next_idx - 1 )
        local idx = string.find( str, ':' )
        if idx == nil then
            ret = ret .. str
        else
            local key = string.sub( str, 1, idx - 1 )
            local val = string.sub( str, idx + 1 )

            if key == 'date' then
                val = os.date( '%Y年%m月%d日', val )
            elseif key == 'time' then
                val = os.date( '%X', val )
            elseif key == 'coin' then
                local x,y,z = string.match( val, "(%d*)%%(%d*)%%(%d*)" )
                
                if x and y and z then
                    x = tonumber(x)
                    y = tonumber(y)
                    z = tonumber(z)
                    if x ~= const.kCoinItem then
                        val = CoinData.getCoinName( x ) .. '×' .. z
                    else
                        local item = findItem( y )
                        val = item.name .. '×' .. z
                    end
                end
            end

            ret = ret .. val
        end
    end

    return ret .. string.sub( text, save_idx + 1 )
end

TextParse = __this