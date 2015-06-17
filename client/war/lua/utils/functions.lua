function toS3UInt32( str )
    local obj = {cate = 0, objid = 0 ,val = 0 }
    local x,y,z = string.match(str,"(%w+)%%(%w+)%%(%w+)")
    if nil ~= x and nil ~= y and nil ~= z then
        obj.cate,obj.objid,obj.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
    end
    return obj
end
function tonum(v, base)
    return tonumber(v, base) or 0
end

function toint(v)
    return math.round(tonum(v))
end

function tobool(v)
    return (v ~= nil and v ~= false)
end

function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

function isset(arr, key)
    local t = type(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function copyToSource(source, obj)
    if obj then
        for k, v in pairs(obj) do
            if source[k] ~= nil then
                source[k] = v
            end
        end
    end
end

function iskindof(obj, className)
    local t = type(obj)

    if t == "table" then
        local mt = getmetatable(obj)
        while mt and mt.__index do
            if mt.__index.__cname == className then
                return true
            end
            mt = mt.super
        end
        return false

    elseif t == "userdata" then

    else
        return false
    end
end


function handler(target, method)
    return function(...)
        return method(target, ...)
    end
end

function math.round(num)
    return math.floor(num + 0.5)
end

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.empty(t)
    return next(t) == nil
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[--
insert list.
**Usage:**
    local dest = {1, 2, 3}
    local src  = {4, 5, 6}
    table.insertTo(dest, src)
    -- dest = {1, 2, 3, 4, 5, 6}
	dest = {1, 2, 3}
	table.insertTo(dest, src, 5)
    -- dest = {1, 2, 3, nil, 4, 5, 6}

@param table dest
@param table src
@param table begin insert position for dest
]]
function table.insertTo(dest, src, begin)
	begin = tonumber(begin)
	if begin == nil then
		begin = #dest + 1
	end

	local len = #src
	for i = 0, len - 1 do
		dest[i + begin] = src[i + 1]
	end
end

--[[
search target index at list.
@param table list
@param * target
@param int from idx, default 1
@param bool useNaxN, the len use table.maxn(true) or #(false) default:false
@param return index of target at list, if not return -1
]]
function table.indexOf(list, target, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	for i = from, len do
		if list[i] == target then
			return i
		end
	end
	return -1
	
end

function table.indexOfKey(list, key, value, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	local item = nil
	for i = from, len do
		item = list[i]
		if item ~= nil and item[key] == value then
			return i
		end
	end
	return -1
end

function table.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

function table.map(t, fun)
    for k,v in pairs(t) do
        t[k] = fun(v, k)
    end
end

function table.walk(t, fun)
    for k,v in pairs(t) do
        fun(v, k)
    end
end

function table.filter(t, fun)
    for k,v in pairs(t) do
        if not fun(v, k) then
            t[k] = nil
        end
    end
end

function table.find(t, item)
    return table.keyOfItem(t, item) ~= nil
end

function table.keyOfItem(t, item)
    for k,v in pairs(t) do
        if v == item then return k end
    end
    return nil
end

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialcharsDecode(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

local function urlencodeChar(c)
    return "%" .. string.format("%02X", string.byte(c))
end

function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.urldecode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonum(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.formatNumberThousands(num)
    local formatted = tostring(tonum(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function string.indexOf(s, pattern)
    local list = string.split(s, pattern)
    if #list > 1 then
        return string.len(list[1]) + 1
    end
    return 0
end

function string.lastIndexOf(s, pattern)
    local list = string.split(s, pattern)
    if #list > 1 then
        local tmp = ""
        for i = 1, #list - 1 , 1 do
            if i < #list - 1 then
                tmp = tmp .. list[i] .. pattern
            else
                tmp = tmp .. list[i]
            end
        end

        return string.len(tmp) + 1
    end
    return 0
end

function string.findLastFolder(url)
    local path = string.gsub(url, '[^/]+$', '')
    return path
end

-- list 操作
function findKeyInList(list, value)
    for k, v in pairs(list) do
        if v == value then
            return k
        end
    end
    return 0
end

function removeInList(list, value)
    local key = findKeyInList(list, value)
    local item = nil
    if key ~= 0 then
        item = table.remove(list, key)
    end
    return item
end

function  addInList(list, value)
    local key = findKeyInList(list, value)
    if 0 == key then
        table.insert(list, value)
    end
end

function fontNameString(name)
    return "[font=" .. name .. "]"
end

function toScenePoint( target , point )
    local midPoint = target:getParent():convertToWorldSpace( point )
    midPoint = SceneMgr.getCurrentScene():convertToNodeSpace( midPoint )
    return midPoint
end

--去除描述中的[xxxxx]内容 如：对敌人全体释放[font=TIP_S]嘲讽[font=TIP_C]并造成少量物理伤害。
function filterDesc( str )
    local reStr = string.gsub(str, "%[[^]]*%]", "")
    return reStr
end

--分离带有（）的道具名 如：aaa(bbb)  retrun "aaa","bbb"
function splitName( str )
    local i, j = string.find(str, "(%b())") 
    if i == nil or j == nil then
        return str,nil
    end

    local s1 = string.sub(str,1,i - 1)
    local s2 = string.sub(str,i + 1,j -1)
    return s1,s2
end

function touchIsAlahp(url, point, exNum)
    exNum = exNum or 0    
    local image = cc.Image:new()
    image:initWithImageFile( url )
    local px, py = math.floor(point.x), math.floor(point.y)
    local color = image:getColor4B(px, py)
    if color.a <= 0 then
        if exNum > 0 then
            color = image:getColor4B(px, py + exNum)
            if color.a > 0 then return false end
            color = image:getColor4B(px, py - exNum)
            if color.a > 0 then return false end
            color = image:getColor4B(px + exNum, py)
            if color.a > 0 then return false end
            color = image:getColor4B(px - exNum, py)
            if color.a > 0 then return false end
            color = image:getColor4B(px + exNum, py + exNum)
            if color.a > 0 then return false end
            color = image:getColor4B(px - exNum, py - exNum)
            if color.a > 0 then return false end
            color = image:getColor4B(px - exNum, py + exNum)
            if color.a > 0 then return false end
            color = image:getColor4B(px + exNum, py - exNum)
            if color.a > 0 then return false end
            return true
        else
            return true
        end
    end
    return false
end
