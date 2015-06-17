--base.lua

local net_error = false


--删除对象组
function clear( obj )
	for _, item in pairs( obj ) do
		if item then
		    item:removeFromParent()
		end
	end
end

--隐藏对象组
function hide(obj)
	for _, item in pairs( obj ) do
		item:setVisible(false)
	end
end


--检查table中是否有值，如无则采用默认值，一般用于简化函数默认值处理
function setTableDefault( table, default_table )
	table = totable( table )
	for k, v in pairs( default_table ) do
		if not table[k] then
			table[k] = v
		end
	end
end


--显示一个对象，ms毫秒后隐藏
function view( obj, ms )
	obj:setVisible(true)	
end


--[[
比对文件是否失效
参数：
filename：完整文件名
second：秒
]]
function isFileExpires( filename, second )
	local curTime = tonumber(xymodule.get_curTime())
		
	local c,m,a = getFiletime( filename )
	
	return (curTime - a) > tonumber(second)
end	

function empty_function()
end

-- 播放背景音乐
function playMp3( file, ms )
	file = getResFilename( file )
	
	local function stopMp3()
		SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
	end
	if isFileExists(file) == true then
		SimpleAudioEngine:sharedEngine():playBackgroundMusic( file, true)		
	end
end

function preLoadMp3( file )
	--if CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid then
	file = getResFilename( file )	
	if isFileExists(file) == true then
		SimpleAudioEngine:sharedEngine():preloadBackgroundMusic( file)	
	end
end

-- 播放音效
function playWav( file, ms )
	file = getResFilename( file )
	
	local effectID = nil
	local function stopWav()
		SimpleAudioEngine:sharedEngine():stopEffect(effectID)
	end
	if isFileExists(file) == true then
		effectID = SimpleAudioEngine:sharedEngine():playEffect( file )		
	end
	return effectID
end

function preLoadWav(file)
	file = getResFilename( file )
	if isFileExists(file) == true then	
		SimpleAudioEngine:sharedEngine():preloadEffect( file )		
	end		
end

--[[
将table转换为json形式的字符串
]]
function table2json(t)
	local function serialize(tbl)
		local tmp = {}
		for k, v in pairs(tbl) do
			if type(v) == 'string' then
				v = string.gsub(v, "\\", "\\\\")
				v = string.gsub(v, "\"", "\\\"")
			end
			local k_type = type(k)
			local v_type = type(v)
			local key = (k_type == "string" and "\"" .. k .. "\":")
				or (k_type == "number" and "")
			local value = (v_type == "table" and serialize(v))
				or (v_type == "boolean" and tostring(v))
				or (v_type == "string" and "\"" .. v .. "\"")
				or (v_type == "number" and v)
			tmp[#tmp + 1] = key and value and tostring(key) .. tostring(value) or nil
		end
		if table.maxn(tbl) == 0 then
			return "{" .. table.concat(tmp, ",") .. "}"
		else
			return "[" .. table.concat(tmp, ",") .. "]"
		end
	end
	assert(type(t) == "table")
	return serialize(t)
end

--[[
从配置值中获取信息，并修改某个key，然后返回
因多次使用，故抽取出来
参数：
	config：整个配置值，对应于layout
	section：section name
	key：key name
	value：new value
返回值：
	修改后的新section
]]
function replaceConfigValue( config, section, key, value )
	local c = clone( config[section] )
	c[ key ] = value
	return c
end


-- 将new中的值覆盖default
function replaceTable( default, new )
	local ret = {}
	for k,v in pairs( default ) do
		ret[ k ] = v
	end
	for k,v in pairs( new ) do
		ret[ k ] = v
	end
	return ret
end

--设置指定长度的字符串
function AdjustString(label,txt,width)
	if label and txt and tonumber(width) > 0 then
		local i = 1	
		while(i <= string.len(txt)) do
			local str = ""
			local b = txt:byte(i)	
			if b > 128 then
				str = string.sub(txt,1,i+2)
				i = i + 3
			else
				str = string.sub(txt,1,i)
				i = i + 1
			end	
			label:setString(str)
			local orgSize = label:getContentSize()
			if orgSize.width >= width then			
				return 
			end
		end			
	end
end

--修改后缀名
function ModifySuffix(filename,suffix)
	local str = string.reverse(filename)
	local index = string.find(str,'%p')
	if not index then 
		local i = 0
	end
	local str3 = string.sub(str,index + 1,string.len(str))
	return string.reverse(str3)..suffix	
end

--获取字符串md5
function GetMD5(str)
	return c_md5encrypt(str)
end

--获取文件md5
function GetFileMD5(file)
	return xymodule.get_filemd5(file)
end

--获取cache路径
function GetCachePath()
	local cachepath = WRITE_PATH..'cache/'
	return cachepath
end

--保存cache内容
function saveCache( name, data )
	WriteByte( GetCachePath() .. name,data )
end

--设置cache过期
function setCacheExpires( name )
	WriteByte( GetCachePath() .. name .. '.expires', '' )
end

--检查cache是否过期，返回true为过期，false为未过期
function isCacheExpires( name, TTL )
	if getFileContent( GetCachePath() .. name .. '.expires' ) then
		return true
	end
	
	if not isFileExists(GetCachePath() .. name) then
		return true
	end
	local curTime = tonumber(xymodule.get_curTime())
	local aTime = tonumber(xymodule.get_atime(GetCachePath() .. name))
	if (curTime - aTime) <= tonumber(TTL) then
		return false
	end
	
	return true
end

--返回cache内容，如存在返回nil
function getCache( name )
	return getFileContent( GetCachePath() .. name )
end

--删除cache
function delCache( name )
	delFile( GetCachePath() .. name )
	delFile( GetCachePath() .. name .. '.expires' )
end

--获取data路径
function getDataFilename( name )
	return WRITE_PATH .. 'temp/' .. name
end

--[[
使用data目录文件，如果不存在，则从远程获取
 file：文件名
 second：缓存时间，0表示不缓存但获得到的内容会更新缓存文件，-1为不使用缓存且不会更新缓存文件
 callback：成功回调，如果当然存在缓存但失效，则会触发两次
 url：请求的地址，如不传入，则约定取远程对应的 [interface]/data/[section]
]]
function downRemoteData( section, second, callback, url )
	local filename = nil
	local content = nil
	
	filename = getDataFilename( section )
	
	local function cb( data )
		if not data then
			return
		end
		if not content or ( GetMD5(content) ~= getMD5(data) ) then
			if second > -1 then
				WriteByte( filename, data )
			end
			
			data = json.decode( data )
			callback( data )
		end
	end
	
	if second > 0 then
		content = getFileContent( filename )
		
		if content then
			callback( json.decode( content ) )
		
			if not isFileExpires( filename, second ) then
				return
			end
		end
	end
	
	if not url then
		url = GLOBAL.interface .. 'temp/' .. section
	end
	HTTP_REQUEST.http_request( url, cb )
end

function writeData( section, json )
	local filename = getDataFilename( section )
	WriteByte( filename, table2json( json ) )
end

--[[
删除整个data文件
]]
function delData( section )
	local filename = getDataFilename( section )

	delFile( filename )
end

--[[
设置data的key
]]
function setData( section, key, value )
	local filename = getDataFilename( section )
	
	local data = getData( section )
	if not data then 
		data = {}
	end
	data[ key ] = value
	
	local content = table2json(data)
	WriteByte( filename, content )
end

--返回data(json结构)，如不存在返回nil
function getData( section )
	local filename = nil
	filename = getDataFilename( section )
	content = getFileContent( filename )
		
	return content and json.decode( content ) or nil
end
-- 获得文件内容，如文件不存在，返回nil
function getFileContent( filename )
	local file,err = io.open( filename )
	
	local content = nil
	if file then
		content = file:read( '*a' )
		file:close()
	end
	
	return content
end

function delFile( filename )
	 os.remove( filename )
end

--写缓存(二进制数据)
function WriteByte(filename,data)
	assert(filename)
	local file = io.open(filename, "wb")
	if file then
		file:write(data)
		file:close()
		return true		
	end
	return false
end

function getResPath()
	return WRITE_PATH .. 'res/'
end

-- 加上前辍，获得资源文件名
function getResFilename( filename )
	return filename and getResPath() .. filename or nil
end		


--base64解码
function base64Decode(data)
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

--base64编码
function base64Encode(data)
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

--获取文件时间
function getFiletime(file)
	local c = xymodule.get_ctime(file)
	local m = xymodule.get_mtime(file)
	local a = xymodule.get_atime(file)
	return c,m,a
end

--清空缓存
function clearCache()
	xymodule.delete_file(GetCachePath())
end	

--获取指定字符个数字符串
function getCharString(txt,count)
	local str = ""
	local cnt = 0
	local i = 1
	if not txt or type(txt) ~= 'string' then
		return
	else
		while(i <= string.len(txt)) do
		local len = string.len(txt)
		local b = txt:byte(i)				
			if b > 128 then
				str = string.sub(txt,1,i+2)
				i = i + 3
			else
				str = string.sub(txt,1,i)
				i = i + 1
			end
			cnt = cnt + 1
			if cnt >= count then
				break
			end
		end
	end
	
	return str
end	

function split(s, delim)  
	assert (type (delim) == "string" and string.len (delim) > 0,          "bad delimiter")  
	local start = 1  local t = {}  -- results table  -- find each instance of a string followed by the delimiter  
	while true do    
	local pos = string.find (s, delim, start, true) -- plain find    
	if not pos then      
		
	break    
	end    
	table.insert (t, string.sub (s, start, pos - 1	))    
	start = pos + string.len (delim)  
	end -- while  
	-- insert final one (after last delimiter	) 
	if string.sub (s, start) ~= "" then	 
		table.insert (t, string.sub (s, start)) 
	end 
	return t
end -- function split	

--检查文件是否存在
function isFileExists(filename)
	--d(filename)
	if not filename then
		return false
	end
	local file,err = io.open( filename )
	if file then
		file:close()
		return true
	end
	return false
end

function escape( s )
	s = string.gsub( s, "[&=+%%%C]", function( c )
		return string.format( "%%%02X", string.byte( c ) )
		end )
	s = string.gsub( s, " ", "+" )
	return s		
end

function playLinkSound( ... )
	playWav( select( 1, ... ) )
	local soundCount = select( "#", ... )
	local i
	soundTimer = {}
	soundArr = {}
	local count = 2
	
	local function playSoundHandler()
		if soundTimer[ count ] then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(soundTimer[ count ])
			soundTimer[ count ] = nil	
		end
		playWav( soundArr[ count ] )
		count = count + 2
	end
	for i = 2, soundCount, 2 do
		if not soundTimer[ i ] then
			soundTimer[ i ] = cc.Director:getInstance():getScheduler():scheduleScriptFunc( playSoundHandler, select( i + 1, ... ), false )
		end	
		soundArr[ i ] = select( i, ... )
	end
end



--[[
获得用户数据，自己的用户数据保存在data目录，其它人的数据文件保存在缓存目录。
参数：
uid：要获取的uid，如果不传入，则取当前登录者
返回：
用户数据，table形式，如不存在，返回{}
]]
function getUserData( uid )
	if not uid then
		uid = GLOBAL.uid
	end
	
	local data = nil
	
	if uid == GLOBAL.uid then
		data = getData( 'uid_' .. uid )
	else
		local content = getCache( 'uid_' .. uid )
		
		if content then
			data = json.decode(content)
		end
	end
	
	return data or {}
end
function writeUserData( uid,table )
	if uid == GLOBAL.uid then
		writeData( 'uid_' .. uid, table )
	else
		local filename = GetCachePath() .. 'uid_' .. uid
		WriteByte( filename, table2json(table) )
	end
end
--[[
设置用户属性
参数：
data：数据，内含用户属性
uid_key：用户uid字段值
field：用户字段映射，key为data中的属性名，value为用户属性名
]]
function setUsersData( data, uid_key, field )
	local uid = data[ uid_key ]
	local userData = getUserData( uid )
	
	for k,v in pairs( field ) do
		if tonumber(k) == k then
			k = v
		end
		userData[ v ] = data[ k ]
	end
	
	writeUserData( uid, userData )
end	

--返回唯一key
function getUniverKey()
	return os.time() .. math.random()
end

--[[
从父中取出子的属性，如果不存在，则从默认值中取对应的子
参数：
parent：父对象
defautlt：默认父对象，当父对象中找不到子时，会改在这里取
son：子描述，字符串形式，如果为孙，则用半角句号隔开
]]
function getSon( parent, default_parent, son )
	local function g( parent, son )
		return parent and parent[son] or nil
	end
	local _, i = string.find( son, "[.]" )
	
	if i then
		local son_first = string.sub( son, 1, i - 1 )
		local son_second = string.sub( son, i + 1, -1 )
		return getSon( g(parent, son_first), g(default_parent, son_first), son_second )
	else
		return g(parent, son) or g(default_parent, son)
	end
end

--[[
传入完整日期，返回年月日时分秒
]]
function getPartByDate(r)
	local a = split(r, " ")
    local b = split(a[1], "-")
    local c = split(a[2], ":")
	
	return b[1],b[2],b[3],c[1],c[2],c[3]
end

---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss
function getSecondByDate(r)
	local y,m,d,h,i,s = getPartByDate(r)
	local t = os.time({year=y,month=m,day=d, hour=h, min=i, sec=s})
    
	return t
end

--[[
根据传入的timestamp，返回友好的时间值
]]
function getStyleTime( timestamp )
	local today = os.date("*t")
	local secondOfToday = os.time({day=today.day, month=today.month,
		year=today.year, hour=0, minute=0, second=0})
	
	if timestamp > secondOfToday then
		return os.date( '%H:%M', timestamp )
	elseif timestamp > secondOfToday - 86400 then
		return os.date( '昨天 %H:%M', timestamp )
	else
		return os.date( '%Y-%m-%d %H:%M', timestamp )
	end
end

--[[
返回字符串的运算结果
]]
function eval(str)
    if type(str) == "string" then
        return loadstring("return " .. str)()
    elseif type(str) == "number" then
        return loadstring("return " .. tostring(str))()
    else
        error("is not a string")
    end
end
