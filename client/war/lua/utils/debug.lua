local __this = debug or {}
debug = __this
__this.timeMap = {}
__this.timeThreshold = 0.03 --时间显示阀值

function __this.clearTime()
    __this.timeMap = {}
end

function __this.resetTime(key)
	__this.timeMap[key] = os.clock()
end

function __this.showTime(key)
    if __this.timeMap[key] then
        local nowTime = os.clock()
        local time = math.floor((nowTime - (__this.timeMap[key] or 0)) * 1000) / 1000
        if time >= __this.timeThreshold then
    	   LogMgr.log("time", key, time)
        end
    	__this.timeMap[key] = nowTime
        return time
    else
        __this.resetTime(key)
    end
end

function __this.dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end

    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end

    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

function __this.db_fmt(value)
	saved = {}
	if type(value) == type({}) then
		local retval = ''
		retval = retval .. '{'
		local visited = {}
		for i, v in ipairs(value) do
			if saved[v] and type(v) == type({}) then
				retval = retval .. '<visited>' .. ', '
			else
				saved[v] = true
				retval = retval .. db_fmt( v, saved ) .. ', '
			end
			visited[i] = true
		end
		for k, v in pairs(value) do
			if visited[k] == nil then
				if saved[v] and type(v) == type({}) then
					retval = retval .. '[' .. db_fmt(k, saved) .. '] = ' .. '<visited>' .. ', '
				else
					saved[v] = true
					retval = retval .. '[' .. db_fmt(k,saved) .. '] = ' .. db_fmt( v,saved ) .. ', '
				end
			end
		end
		retval = retval .. '}'
		return retval 
	elseif type(value) == type('') then
		return(string.format("'%s'",value))
	elseif value ~= nil then
		return(string.format("%s",tostring(value)))					
	elseif value == nil then
		return 'nil'
	end
	return "<unknown>"
end

function __this.print_byte(str)
	d("begin byte", str, string.len(str))
	local ByteCount = string.len(str)
	local ByteIndex = 1
	while (ByteIndex <= ByteCount) do
		d(string.byte(string.sub(str, ByteIndex, ByteIndex)))
		ByteIndex = ByteIndex + 1
	end
	d("end byte")
end

function __this.Log(data)
	local file = WRITE_PATH.."log.txt"
	local f = io.open(file,'a+')
	if f then
		local tab=os.date("*t",time);
		local str = tab.hour..":"..tab.min..":"..tab.sec.."   "..tostring(data)
		f:write(str)
		f:write("\r\n")
		f:close()
	end		
end

local function reload( moduleName )
	package.loaded[moduleName] = nil  
    if cc.FileUtils:getInstance():isFileExist( moduleName ) then
        require(moduleName)  
    else
        LogMgr.error("文件不存在：", moduleName)
    end
end

--调试接口
Command.bind("open debug", function()
    if not Config.is_debug() then
        return
    end
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_DEBUG)
    local win = layer.debugWin
    if not win then
        win = UIFactory.getLayerColor(cc.c4b(0xff, 0xff, 0xff, 0x10), 1, 1, layer, 30, 120)
        layer.debugWin = win
        win:retain()
        local data = {
        	{"关闭", function() win:removeFromParent() end},
        	{"重载测试", function() reload("lua/reload_test.lua") end},
        	{"打开涉漏检查", function() Command.run("memory 1") end},
        	{"关闭涉漏检查", function() Command.run("memory 2") end},
            {"输出涉漏检查", function() Command.run("memory 3") end},
        	{"移除空闲纹理", function() cc.Director:getInstance():getTextureCache():removeUnusedTextures() end},
    	}
    	for i,v in ipairs(data) do
    		local item = UIFactory.getButton("btn_green_new.png", win, 10, (#data - i) * 55 + 10)
    		item:addTouchEnded(v[2])
    		local size = item:getSize()
    		UIFactory.getText(v[1], item, size.width / 2, size.height / 2, 22, cc.c3b(0xff, 0xff, 0xff))
    	end
    	win:setContentSize(cc.size(179, 55 * #data + 20 - 8))
    	local startPos = nil
    	local orgPos = nil
    	local function touchBeginHandler(touch, event)
    		starPos = touch:getLocation()
    		orgPos = cc.p(win:getPosition())
    	end
    	local function touchMovedHandler(touch, event)
    		local pos = touch:getLocation()
    		win:setPosition(cc.pAdd(orgPos, cc.pSub(pos, starPos)))
    	end
    	UIMgr.addTouchBegin(win, touchBeginHandler)
    	UIMgr.addTouchMoved(win, touchMovedHandler)
    end
    if not win:getParent() then
        layer:addChild(win)
    end
    win:setPosition(30, 120)
end)
