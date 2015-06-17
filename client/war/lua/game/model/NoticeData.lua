NoticeData = {}

local noticeData = {}

function NoticeData.getNoticeStr()
	--local richdata = NoticeData.explaystr(NoticeData.getJsonDataList(getNoticeContent()))
	local richdata = NoticeData.explaystr(getNoticeContent())
    return richdata
end

function NoticeData.getJsonDataList( value )
	local obj = nil
	if value and value ~= "" then 
		local function cheakjson( value )
			obj = Json.decode(value)
		end 
  		pcall(cheakjson, value)
	end
	return obj
end

function NoticeData.explaystr( datalist )
--	datalist = NoticeData.getTestData()
	local noticStr = nil
	if datalist and datalist ~= "" then
		noticStr = ""
		if type(datalist) == "table" then
			for i=1,#datalist do 
                noticStr = noticStr .. "[font=JJ_6]"..(#datalist > 1 and NoticeData.convertNumber(i).."、" or "") .. NoticeData.getStrinsquare(datalist[i].title).."[br]" 
				noticStr = noticStr .. "[font=JJ_5]"..NoticeData.getStrinsquare(datalist[i].content) .. (#datalist > 1 and "[br][style=120,64,49, 14]    一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一[br]" or "[br]")
			end
		elseif type(datalist) == "string" then
			noticStr = noticStr .. "[font=JJ_5]"..NoticeData.getStrinsquare(datalist) 
		end
	end
    --noticStr = noticStr .."[font=JJ_5]".. NoticeData.convertNumber( 5201314 )
	return noticStr
end

function NoticeData.getTestData( ... )
	local data = {}
	for i=1,34 do 
		local notic = {}
		notic.title ="活动标题20号"
		notic.content = "[活动时间] 2014年fdsafdsa\n[活动范围] 所有服务器\n[活动内容] 活动期间内，如果游戏达到一定的等级即可领取一点的奖励\n[奖励发放] 发放方式 "
		table.insert(data,notic)
	end
	return data
end

function NoticeData.getStrinsquare( str )
	local square = string.gsub(str, "%[", "{【")
	square = string.gsub(square, "]", "】}")
	square = string.gsub(square, "\13\n", "[br][font=JJ_5]        ")
	square = string.gsub(square, "\n", "[br][font=JJ_5]")
	return square
end

function NoticeData.setData( value )
	noticeData = value
end

local tenNum = {"一","二","三","四","五","六","七","八","九"}
local thoundNum = {"零","十","百","千","万","亿"}
--转换个位
function NoticeData.convertunit( value )
	local arestr = ""
	if value  and value ~= "" then
		local unit = math.modf(tonumber(value))
		if #tenNum >= unit and unit ~= 0 then
	        arestr =  tenNum[tonumber(value)]
		elseif unit == 0 then
	        arestr =  thoundNum[1]
		else
	        arestr =  ""
		end
	end
    return arestr
end

function NoticeData.convertName( len )
	if tonumber(len) <= #thoundNum then
		return thoundNum[tonumber(len)]
	else
		return ""
	end
end
--转换4位数
function NoticeData.convertThousand(value)
	local restr = ""
	if value  and value ~= "" then
		local unitNum = math.modf(tonumber(value))
		local len = # tostring(unitNum)
		if unitNum > 0 and string.find(tostring(value),"0") == 1 then
			restr = restr .. thoundNum[1]
		end
		if unitNum < 20 then
			if unitNum < 10 then 
				if unitNum == 0 then
					restr = thoundNum[1]
				else
					restr =  tenNum[unitNum]
				end
			else 
				local secNum = string.sub(tostring(unitNum),2,2)
	            restr =  thoundNum[2] .. (tonumber(secNum) > 0 and NoticeData.convertunit(secNum) or '')
			end
		else 
			for i = 1,len do
				local secN = string.sub(tostring(unitNum),i,i)
				restr = restr .. ((tonumber(secN) == 0 and len == i ) and "" or NoticeData.convertunit(string.sub(tostring(unitNum),i,i)))..((len > i and tonumber(secN) ~= 0 )and NoticeData.convertName(len + 1 - i) or "")
			end
		end
	end
	return restr
end
--把阿拉伯数字转换成汉字
function NoticeData.convertNumber( value )
	local constr = ""
	if value  and value ~= "" then
		local unitNum = math.modf(tonumber(value))
		local totallen = # tostring(unitNum)
		local tCount = math.modf(totallen / 4)
		local rCount = totallen % 4
		if tCount > 0 then
			local index = ((tCount == 1 or (tCount == 2 and rCount == 0)) and 5 or 6)
			local strL = ""
			local strR = ""
			if rCount > 0 then
				strL = string.sub(tostring(unitNum),1,rCount)
				strR = string.sub(tostring(unitNum),rCount + 1,totallen)
			else
				strL = string.sub(tostring(unitNum),1,4)
				strR = (totallen > 5 and  string.sub(tostring(unitNum),5,totallen) or "")
			end
			constr = constr .. NoticeData.convertThousand(strL)..((tCount == 1 and rCount == 0 ) and "" or thoundNum[index]) .. NoticeData.convertNumber(strR)
		else
			constr = constr .. NoticeData.convertThousand(value)
		end
	end
	return constr
end