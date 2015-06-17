-- create by 胡核南
RichText = {}
RichText.btnImage = nil
RichText.btnCount = nil
RichText.rightBtn = nil
RichText.leftBtn = nil
--[[
    解析字符串，将解析的字符串放入到富文本中
    str结构：[image=icon.png][font=ZH_1]XXXX[br][btn=count]XXXX
    [imgae]XXXXX   图片名
    [font=ZH_1]XXXX  ZH_1 表示文字字体类型  XXXX 表示输出的文字
    [br] 换行
    [btn=count]XXXXX count表示按钮的数目（值为one，two）  XXXXX代表按钮图片，两张图片以“：”分割，
    				左边的为左边按钮的图片，右边为右边按钮的图片
]]--
------------------------------
--@ str:待解析的字符串
--@ prePath:图片路径
--@ richText: 富文本对象
function RichText:DisposeRichText(str, prePath, richText)
	if str == nil and str == "" then
		return
	end
        
    local textFont = FontStyle.ZH_1
	 -- str: 待解析字符串
	 -- str1: 正解析字符串
	 -- str2: 两[]之间文字
	local str1, str2 = '', ''
	while str and str ~= '' do
		local i, j = string.find(str, '(%b[])')
		if not i then
			str2 = str
			str = ''
            local text = ccui.RichElementText:create(0, textFont.fontColor, 255, str2, textFont.fontName, textFont.fontSize)
            richText:pushBackElement(text)
		elseif i > 1 then
			str2 = string.sub(str, 1, i - 1)
			str = string.sub(str, i)
            local text = ccui.RichElementText:create(0, textFont.fontColor, 255, str2, textFont.fontName, textFont.fontSize)
            richText:pushBackElement(text)
		elseif 1 == i and RichText.isFone(string.sub(str, i+1, j-1)) then
			str1 = string.sub(str, i, j)
			local m, n = string.find(str1,"%l+")   
			local tag = string.sub(str1,m,n)
			if tag ~= 'br' and tag ~= 'image' then
				local k, l = string.find(str, "(%b[])", j + 1) -- 匹配下一个[]
				if k then 
					str1 = string.sub(str, i, k - 1) 
					str = string.sub(str, k)
				else
					str1 = string.sub(str, i, k)
					str = ''
				end
			elseif tag == 'br' or tag == 'image' then
				str = string.sub(str, j + 1)
			end
			if tag == "font" then	
				local font = string.sub(str1, n+2, j-1)
				local word = string.sub(str1, j+1)
				LogMgr.debug("word = ", word)
                textFont = FontStyle[font]
                local text = ccui.RichElementText:create(0, textFont.fontColor, 255, word, textFont.fontName, textFont.fontSize)
                richText:pushBackElement(text)
			elseif tag == "image" then	
				local img = string.sub(str1, n+2, j-1)
				local fontStyle = FontStyle.JJ_2
                local image = ccui.RichElementImage:create(0, fontStyle.fontColor, 255, prePath..img)
                richText:pushBackElement(image)
			elseif tag == "btn" then
				RichText.btnCount = string.sub(str1, n+2, j-1)
				if "two" == RichText.btnCount then
					local pngName = string.split(string.sub(str1, j+1), ":")
					RichText.leftBtn = pngName[1]
					RichText.rightBtn = pngName[2]
				else
					RichText.btnImage = string.sub(str1, j+1)
				end
			elseif tag == "br" then	
				break
			end
		end
	end

	-- local str1, str2, str3
	-- str1 = str
	-- str3 = str
	-- while str1 ~= nil and str1 ~= '' do
	-- 	local i, j = string.find(str1, "(%b[])")		-- 寻找第一个[]匹配字符
	-- 	if i ~= nil and RichText.isFone(string.sub(str1,i+1,j-1)) == nil then
	-- 	 	str3 = string.sub(str1, i, j)
	-- 	    str1 = string.sub(str1, j+1)
	-- 	    i = nil
	-- 	elseif i ~= nil and i > 1 then
	-- 	    str3 = string.sub(str1, 1, i - 1)
	-- 	    str1 = string.sub(str1, i)
	-- 	    i = nil
	-- 	elseif i == 1 then
 --    		local k, l
 --    		if j ~= nil then
 --                k, l = string.find(str1, "(%b[])", j + 1)	-- 寻找下一个[]匹配字符
 --    		end
 --    		if k == nil then
 --    			str2 = str1
 --    			-- str1 = ''
 --    			str1 = string.sub(str1, j + 1)
 --    			str3 = str1
 --    			str1 = ''
 --    		else
 --    			str2 = string.sub(str1, i, k - 1)	-- 截取待解析的字符串
 --    			str1 = string.sub(str1, k)	-- 余下的字符串
 --    		end
 --    	elseif i == nil then
 --    	    str1 = ''
	-- 	end
 --        local textFont = FontStyle.ZH_1
	-- 	if i ~= nil then
	-- 		local m, n = string.find(str2,"%l+")   
	-- 		--LogMgr.log( 'debug',m,n)
	-- 		local tag = string.sub(str2,m,n)
	-- 		--LogMgr.log( 'debug',tag)

	-- 		if tag == "font" then	
	-- 			local font = string.sub(str2, n+2, j-1)
	-- 			local word = string.sub(str2, j+1)
	-- 			-- local b, c = string.find(str2, "(%b())", j+1)
	-- 			-- if j + 1 == b and c ~= #str2 then
	-- 			-- 	word = string.sub(str2, b+1, c-1)
	-- 			-- 	str1 = string.sub(str2, c + 1) .. str1
	-- 			-- end
	-- 			LogMgr.log( 'debug',"font = "..font,"word = " .. word)
 --                textFont = FontStyle[font]
 --                local text = ccui.RichElementText:create(0, textFont.fontColor, 255, word, textFont.fontName, textFont.fontSize)
            
 --                richText:pushBackElement(text)
	-- 		elseif tag == "image" then	
	-- 			local img = string.sub(str2, n+2, j-1)
 --                local image = ccui.RichElementImage:create(0, textFont.fontColor, 255, prePath..img)
               
 --                richText:pushBackElement(image)
	-- 			LogMgr.log( 'debug',"image = " .. img)
	-- 		elseif tag == "btn" then
	-- 			RichText.btnCount = string.sub(str2, n+2, j-1)
	-- 			if "two" == RichText.btnCount then
	-- 				local pngName = string.split(string.sub(str2, j+1), ":")
	-- 				RichText.leftBtn = pngName[1]
	-- 				RichText.rightBtn = pngName[2]
	-- 			else
	-- 				RichText.btnImage = string.sub(str2, j+1)
	-- 			end
				
	-- 			-- LogMgr.log( 'debug',"btn = " .. RichText.btnImage)
	-- 		elseif tag == "br" then	
	-- 			str1 = string.sub(str2, j + 1)	
	-- 			break
	-- 		end
 --        else
 --            local text = ccui.RichElementText:create(0, textFont.fontColor, 255, str3, textFont.fontName, textFont.fontSize)
 --            richText:pushBackElement(text)
	-- 	end
	-- end
	LogMgr.debug('str = ', str)
	return str
end

function RichText.isFone( str )
	local i,j = string.find(str,"font")
	if i == nil then
		i,j = string.find(str,"image")
		if i == nil then
			i,j = string.find(str,"br")
			if i == nil then
				i,j = string.find(str,"btn")
			end
		end
	end
	return i
end

------------------------------
--@ str:待解析的字符串
--@ prePath:图片路径
--@ layout:层容器
function  RichText:addMultiLine(srcStr, prePath, layout)
	local index = 0
	while srcStr ~= '' do
        rich = ccui.RichText:create()
        rich:setAnchorPoint(cc.p(0, 1))
        buttonDisable(rich,true)
        srcStr = RichText:DisposeRichText(srcStr, prePath, rich)
        if '' ~= srcStr or 0 ~= index then
            rich:setPosition(cc.p(0, layout:getSize().height-35*index))
        else
            rich:setPosition(cc.p(0, layout:getSize().height))
        end
        index = index + 1
        layout:addChild( rich )
    end
end
