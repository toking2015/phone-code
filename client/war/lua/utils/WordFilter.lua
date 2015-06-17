WordFilter = WordFilter or {}

local hasInit = false -- 是否初始化
local isOpen = true -- 是否开启
local indexDic = {} -- 索引字典

local especialChars = {} -- 特殊字符
local especialNames = {} -- 特殊名字

local function getInsteads(len, rep)
	return string.rep(rep or "*", len)
end

local function replaceSub(str, start, stop, rep)
	return string.sub(str, 1, start - 1) .. getInsteads(stop - start + 1, rep) .. string.sub(str, stop + 1)
end

local function addToDic(dic, word, index, wordLen)
	if (index <= wordLen) then
		local char = string.sub(word, index, index)
		local dic1 = dic[char]
		if (dic1 == nil) then
			dic1 = {}
			dic[char] = dic1
		end
		addToDic(dic1, word, index + 1, wordLen)
	else
		dic[""] = true
	end
end

--[[
 * 内部调用
 * 替换屏蔽字
 * @param word 原始字符串
 * @param rep 要替换成的字，默认是"*"
 * @param isTest 是否只是测试
 * @return 替换后的字符串，如果isTest为true，则返回true（存在敏感词）或者false
]]
local function replace(word, rep, isTest)
	local wordLen = string.len(word)
	local index = 1
	local lowerMap = {}
	local dicMap = {}
	while (index <= wordLen) do
		local dic = indexDic
		local stop = index
		for i = index, wordLen do
			local c = lowerMap[i] 
			if not c then
				c = string.lower(string.sub(word, i, i))
				lowerMap[i] = c
			end
			if dic[c] then
				dic = dic[c]
				dicMap[i] = dic
				stop = i
			else
				break
			end
		end
		local work = false
		for i = stop, index, -1 do
			if dicMap[i] and dicMap[i][""] == true then --找到
				if isTest then
					return true -- 已经找到屏蔽词
				end
				word = replaceSub(word, index, i, rep)
				index = i + 1 -- 从下个位置继续
				work = true
				break
			end
		end
		if not work then
		  index = index + 1
		end
	end
	if isTest then -- 根据是否测试返回相应的值
		return false
	end
	return word
end

-- local badwordMap = {}
--去掉重复的屏蔽字，并保存
-- Command.bind("savebadword", function()
-- 	local t = table.keys(badwordMap)
-- 	table.sort(t)
-- 	local content = table.concat(t, '\n')
-- 	seq.write_stream_file( 'badword.txt', seq.string_to_stream( content ) )
-- end)

local function addOneWord(content, startIndex, endIndex)
	local orgWord = string.sub(content, startIndex, endIndex)
	local word = string.lower(orgWord)
	local wordLen = string.len(word)
	addToDic(indexDic, word, 1, wordLen)
	-- badwordMap[word] = word
end

--[[
 * 初始化
 * 把屏蔽字数组转成字典，并生成一个索引数组
 * @param content 屏蔽字
 * @return
]]
local function initDict(content)
	local startIndex = 1
	for i = 1, #content do
		local char = string.sub(content, i, i)
		if char == '\n' or char == '\r' then
			if i > startIndex then
				addOneWord(content, startIndex, i - 1)
			end
			startIndex = i + 1
		end
	end
	if startIndex <= #content then
		addOneWord(content, startIndex, #content)
	end
end

local function baseInit()
	if hasInit then
		return
	end
	hasInit = true
	if not isOpen then
		return
	end
	local data = "/\\\"'<>&%@[],\r\n\t|" -- 无法判断多字节的
	for i = 1, string.len(data) do
		especialChars[string.sub(data, i, i)] = true
	end
	especialNames["　"] = true --全角空格
	especialNames["；"] = true --全角分号
	debug.resetTime("WordFilter.initDict")
	local content = seq.stream_to_string( seq.read_stream_file( "cbm/badword.txt" ) )
	initDict(content) --初始化
	debug.showTime("WordFilter.initDict")
end

--[[
 * 检测是否存在特殊字符
 * @param	word
 * @return 存在true，不存在false
]]
local function checkSpecialChar(word)
	for i = 1, string.len(word) do
		local char = string.sub(word, i, i)
		if (especialChars[char]) then
			return true
		end
	end
	return false
end

function WordFilter.setIsOpen(value)
	isOpen = value
end

--特殊名字，如指导员，GM等
function WordFilter.setEspecialNames(names)
	for _,v in pairs(names) do
		especialNames[v] = true
	end
end

--[[
 * 检测名字是否存在非法字符（特殊字符，敏感词，英雄名字，指导员）存在true，不存在false
 * @param	name
 * @return 存在true，不存在false
]]
function WordFilter.checkName(name)
	baseInit()
	local result = checkSpecialChar(name) or WordFilter.check(name)
	if (not result) then
		for k, v in pairs(especialNames) do
			if (string.find(name, k) ~= nil) then
				return true
			end
		end
	end
	return result
end

--[[
 * 把字符串里面的敏感词替换为'*'
 * @param	word
 * @return 替换后的字符串
]]
function WordFilter.filter(word)
	baseInit()
	debug.resetTime("WordFilter.filter")
	word = replace(word, "*")
	debug.showTime("WordFilter.filter")
	return word
end

--[[
 * 检测是否存在敏感词
 * @param	word
 * @return 存在true，不存在false
]]
function WordFilter.check(word)
	baseInit()
	debug.resetTime("WordFilter.check")
	local result = replace(word, nil, true)
	debug.showTime("WordFilter.check")
	return result
end
