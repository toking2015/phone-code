local __this = StringTools or {}
StringTools = __this

--根据UTF8字符串的第一个字节获得字节数
local function getByteCount(c)
	local seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or 
		c < 0xF8 and 4 or c < 0xFC and 5 or c < 0xFE and 6 or error("invalid UTF-8 character sequence")
	return seq
end

-----------------
-- 将十六进制字符串(ffffff)转换为十进制字符串"255,255,255"
--@ hexStr: 十六进制字符串
function __this.hexToDecimal(hexStr)
	local decNum = ''
	if nil == hexStr then
		LogMgr.log( 'debug',"请输入十六进制字符串")
	elseif 1 == string.len(hexStr) % 2 then
		LogMgr.log( 'debug',"请输入合法的十六进制字符串")
	else
		for i = 1, string.len(hexStr), 2 do
			local a = string.sub(hexStr, i, i + 1)
			local n = tonumber(a, 16)
			decNum = decNum .. n .. ','
		end
	end
	decNum = string.sub(decNum, 1, string.len(decNum) - 1)
	return decNum
end

---------------------
-- 解析可含有中文的utf8字符串，并将每个字符存在table中
function __this.disposeUtf8String(utf8Str)
	assert(type(utf8Str) == "string")
	local res, index, seq = {}, 1, 0
	while index <= #utf8Str do
		local c = string.byte(utf8Str, index)
		seq = getByteCount(c)
		table.insert(res, string.sub(utf8Str, index, index + seq - 1))
		index = index + seq
	end
	return res
end

-------------------
-- 截取utf-8格式字符串
--@ str: 待截取的字符串
--@ len: 截取字符串的长度
function __this.subUtf8String(str, len)
	local res = __this.disposeUtf8String(str)
	len = len > #res and #res or len
	local result = table.concat(res, "", 1, len)
	return result
end

---------------------
-- 截取指定字节长度的字符串
function __this.subByteString(str, len)
	assert(type(str) == "string")
	if len >= string.len(str) then
		return str
	end
	local index, seq = 1, 0 -- 字符串索引，字符含有几个字节
	while true do
		local c = string.byte(str, index)
		seq = getByteCount(c)
		if index + seq > len then
			return string.sub(str, 1, index - 1)
		end
		index = index + seq
	end
	return str
end

---------------
-- 获取字符串中指定的字符
--@ str
--@ index
function __this.obtainIndexChar(str, index)
	local res = __this.disposeUtf8String(str)
	return res[index] or ''
end

-----------------
-- 字符串字符个数
function __this.len(str)
	local res = __this.disposeUtf8String(str)
	return #res
end

function __this.getCharWidth(seq, size )
	if seq > 2 then
		return size
	else
		return size / 2
	end
end

function __this.getStringWidth( str, size )
	local strWidth = 0
	local index, seq = 1, 0 -- 字符串索引，字符含有几个字节
	while index < #str do
		local c = string.byte(str, index)
		seq = getByteCount( c )
		index = index + seq
		strWidth = strWidth + __this.getCharWidth( seq, size )
	end
	return strWidth
end

function __this.cutStringForWidth( str, size, width )
	local index, seq = 1, 0 -- 字符串索引，字符含有几个字节
	local strWidth = 0
	while index <= #str do
		local c = string.byte(str, index)
		seq = getByteCount( c )
		strWidth = strWidth + __this.getCharWidth( seq, size )
		if strWidth >= width then
			break
		end
		index = index + seq
	end
	return index
end
