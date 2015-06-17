RichTextUtil = {}
--注意，字符里的{}用来作行缩进标志，每一段以{内容}开头，会在换行时以 内容 宽度 来缩进 by tokeng
-- lastPointY 记录一行的Y位置，currentWidht 记录同一行不同richText时显示的实际宽度
local savefnt = ""
function RichTextUtil:DisposeRichText(str, node, richText, height, maxWidht, lineSpace ,allindent,indent,lastPointY)
	if str == nil and str == "" then
        return 
	end

	if maxWidht == nil or maxWidht == 0 then
		maxWidht = 1500
	end

	if lineSpace == nil then
		lineSpace = 0
	end
	
	local str1, str2
	local i, j = string.find(str, "(%b[])")		--
	local k, l
	if j ~= nil then
		k, l = string.find(str, "(%b[])", j + 1)	--
	end
	if k == nil then
		str2 = str
	else
		str2 = string.sub(str, i, k - 1)	-- 
		str1 = string.sub(str, k)	-- 
	end
	local cindent = allindent or indent 

    local textFont = FontStyle.ZH_1
    local postionY = 0 
	if i ~= nil then
		local m, n = string.find(str2,"%l+")   -- 
		local tag = string.sub(str2,m,n)

		if tag == "style" or tag == "font" then
			local font = string.sub(str2, n+2, j-1)
			local word = string.sub(str2, j+1)
			if font ~= nil then 
               savefnt = font 
            end 
			if tag == "style" then
				local tmp = string.split(font, ",")
				local r,g,b = 255, 255, 255
				if #tmp > 2 then
					r,g,b = tonumber(tmp[1]), tonumber(tmp[2]), tonumber(tmp[3])
				end
				textFont = FontStyle.get(r, g, b, toint(tmp[#tmp]))
			else
				textFont = FontStyle[font]
			end
			local is_firstline = true
            local t,k = string.find(word,"(%b{})")
			if t == 1  then
				local tk = string.sub(word,t,k)
				word = string.gsub(word,"{","")
				word = string.gsub(word,"}","")
                cindent = allindent or StringTools.getStringWidth(tk,textFont.fontSize) - textFont.fontSize / 2
                if allindent then
                	is_firstline = false
                end
			end
			if is_firstline then
				richText = RichTextUtil:getRichText( node, richText, postionY, textFont, height, lineSpace )
			else
				if richText and richText:getPositionX() == 0 then
					richText:setPosition(cc.p(cindent,richText:getPositionY()))
				end
				richText = RichTextUtil:getRichText( node, richText, postionY, textFont, height, lineSpace,cindent )
			end
            lastPointY = richText:getPositionY()
            richText ,lastPointY= RichTextUtil:setText( word, textFont, richText, maxWidht, node, postionY, lineSpace,allindent,cindent,lastPointY,is_firstline)
		elseif tag == "image" then	
			local img = string.sub(str2, n+2, j-1)
            richText = RichTextUtil:getRichText( node, richText, postionY, textFont, richText.infoHeight, lineSpace )	
            RichTextUtil:setElementSprite( img, richText )
		elseif tag == "br" then	
			if richText then	
				cindent = nil
				postionY = lastPointY or richText:getPositionY()
	            if str1 then --如果接下来还有文本，即textFont 需要更新
	            	textFont = RichTextUtil:getFirstFont(str1) or textFont
	        	end
	        	richText  = nil
	            richText = RichTextUtil:getRichText( node, nil, postionY, textFont, textFont and textFont.fontSize or richText.infoHeight, lineSpace )
	            lastPointY = richText:getPositionY()
        	end
        elseif tag == "exp"  then 
--            local prepath = "image/ui/ChatUI/biaoqing/1.png"
            local url = string.sub(str2, n+2, j-1)
            RichTextUtil:setElementExp( url, richText )
            local word = string.sub(str2, j+1)
            if savefnt ~= "" then  
                textFont = FontStyle[savefnt]          
                local is_firstline = true
                local t,k = string.find(word,"(%b{})")
                if t == 1  then
                    local tk = string.sub(word,t,k)
                    word = string.gsub(word,"{","")
                    word = string.gsub(word,"}","")
                    cindent = allindent or StringTools.getStringWidth(tk,textFont.fontSize) - textFont.fontSize / 2
                    if allindent then
                        is_firstline = false
                    end
                end
                if is_firstline then
                    richText = RichTextUtil:getRichText( node, richText, postionY, textFont, height, lineSpace )
                else
                    if richText and richText:getPositionX() == 0 then
                        richText:setPosition(cc.p(cindent,richText:getPositionY()))
                    end
                    richText = RichTextUtil:getRichText( node, richText, postionY, textFont, height, lineSpace,cindent )
                end
                lastPointY = richText:getPositionY()
                richText ,lastPointY= RichTextUtil:setText( word, textFont, richText, maxWidht, node, postionY, lineSpace,allindent,cindent,lastPointY,is_firstline) 
		    end 
		end
        
	end

	if str1 ~= nil and str1 ~= "" then
		RichTextUtil:DisposeRichText(str1, node, richText, height, maxWidht, lineSpace ,allindent,cindent,lastPointY)
	end
end

function RichTextUtil:getFirstFont( str )
	local i, j = string.find(str, "(%b[])")
	local refont = nil
	if i == 1 then
		local m, n = string.find(str,"%l+")
		local tag = string.sub(str,m,n)
		local font = string.sub(str, n+2, j-1)
		if tag == "style" then
			local tmp = string.split(font, ",")
			local r,g,b = 255, 255, 255
			if #tmp > 2 then
				r,g,b = tonumber(tmp[1]), tonumber(tmp[2]), tonumber(tmp[3])
			end
			refont = FontStyle.get(r, g, b, toint(tmp[#tmp]))
		else
			refont = FontStyle[font]
		end
	end
	return refont
end

function RichTextUtil:getRichText( node, richText, postionY, textFont, height, lineSpace ,indent)
	if richText == nil then
		richText = ccui.RichText:create()
		
		node:addChild( richText )
		richText:setTouchEnabled(false)
		richText:setAnchorPoint( cc.p( 0, 0 ) )

		if height == 0 or height == nil then
			-- height = 1.3 * ( textFont.fontSize / 72 ) * 96
			height = textFont.fontSize
		end
		
		richText:setPosition( cc.p( indent, postionY - height - lineSpace ) )

		node:setContentSize( 0,  math.abs( richText:getPositionY() ) ) 
		richText.infoWidth = 0
		richText.infoHeight = 0
	end
	
	return richText
end	

function RichTextUtil:getTextSize( info, textFont )
    return textFont.fontSize
end
-- indent 缩进
function RichTextUtil:setText( info, textFont, richText, maxWidht, node, postionY, lineSpace ,allindent,indent,lastPointY,isFirstLine)
 	local trueMaxWidht = maxWidht
 	indent = allindent or indent
	if indent and not isFirstLine then
		trueMaxWidht = maxWidht - indent --实际显示宽度
	end
    local infoHeight = RichTextUtil:getTextSize( info, textFont )
	local spareWidth = trueMaxWidht - richText.infoWidth

	local sortIndex = StringTools.cutStringForWidth( info, textFont.fontSize, spareWidth )
	local lastIndex = sortIndex - 1
	local infoLength = #info
	if lastIndex == infoLength then 	-- 能够放置info字符串
		RichTextUtil:setElementLalbe( info, textFont, richText, infoHeight )
	elseif lastIndex < infoLength then 	-- 不能完全放下info字符串中的字符
		local shortInfo = info
   		if sortIndex ~= 1 then 			-- 只能放下部分info中的任何字符
			shortInfo = string.sub( info, 1, lastIndex )
			RichTextUtil:setElementLalbe( shortInfo, textFont, richText, infoHeight )
            shortInfo = string.sub( info, sortIndex )
   		end
		postionY = lastPointY or richText:getPositionY() 
        richText = RichTextUtil:getRichText( node, nil, postionY, textFont, shortHeight, lineSpace ,indent)
        lastPointY = richText:getPositionY() 
        richText,lastPointY = RichTextUtil:setText( shortInfo, textFont, richText, maxWidht, node, postionY, lineSpace ,allindent,indent,lastPointY)   		
	end
	return richText,lastPointY
end

function RichTextUtil:setElementLalbe( info, textFont, richText, size )
 	local text = ccui.RichElementText:create( 0, textFont.fontColor, 255, info, textFont.fontName, textFont.fontSize )
	richText:pushBackElement(text)
	--LogMgr.log( 'login', '[setText] richText.infoWidth='..richText.infoWidth)
	richText.infoWidth = richText.infoWidth + StringTools.getStringWidth( info, size )
    richText.infoHeight = size
   -- LogMgr.log( 'login', '[setText] info='..info)
    --LogMgr.log( 'login', '[setText] size='..size)
    --LogMgr.log( 'login', '[setText] richText.infoWidth2='..richText.infoWidth)
end

function RichTextUtil:setElementSprite( url, richText )
    local sprite = AnimateSprite:create(url)
	local image = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, sprite )
	richText:pushBackElement(image)	
    
    richText.infoWidth = richText.infoWidth + sprite:getContentSize().width
    richText.infoHeight = sprite:getContentSize().height
end

function RichTextUtil:setElementExp( url, richText )
    -- text 为"WX"  中名字为WX文件夹
    local num = ExpressionData.getNum(url) 
    local list = {}
    if num ~= nil then 
        local num = tonumber(num)
        for i = 1 , num do
            if i < 10 then 
                table.insert(list,  url .. "/" .. "0" .. i .. ".png")
            else 
                table.insert(list, url .. "/" .. i .. ".png")
            end 
        end 
        local sprite1 = Sprite:createWithSpriteFrame(list[1]) 
        local sprite = nil 
        if num == 1 then 
            sprite = sprite1 
        else 
            sprite = AnimateSprite:create(list, true, 1, 0.5,true) 
        end 
        sprite:setContentSize( sprite1:getContentSize().width,sprite1:getContentSize().height )
        local image = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, sprite )
        richText:pushBackElement(image)
    
        richText.infoWidth = richText.infoWidth + sprite1:getContentSize().width
        richText.infoHeight = sprite1:getContentSize().height
    end 
end

