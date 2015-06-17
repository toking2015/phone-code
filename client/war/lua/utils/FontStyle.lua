local styleMap = {}
local applyMap = {}
local configMap = {}

FontNames = {}
FontNames.DEFAULT = "fonts/default.ttf"
FontNames.HUAKANG = FontNames.DEFAULT --"fonts/huakang_round.ttf"
FontNames.HEITI = FontNames.DEFAULT --"fonts/simhei.ttf"
FontNames.Euphemia = "fonts/euphemia.ttf"

local function getTTFConfig(fontName)
    local config = configMap[fontName]
	if (config == nil) then
		config = {
			fontFilePath = fontName,
			distanceFieldEnabled = true,
			glyphs = cc.GLYPHCOLLECTION_DYNAMIC
		}
        configMap[fontName] = config
	end
	return config
end

FontStyle = {}

local glowColor = cc.c4b(0, 0, 0, 255)
local shadowColor = cc.c4b(0, 0, 0, 210)
local outlineColor = cc.c4b(0, 0, 0, 255)

local shadowOffset = cc.size(2, -2)

function FontStyle.getRichText(str, c3b, fontSize)
	return string.format("[style=%d,%d,%d,%d]%s", c3b.r, c3b.g, c3b.b, fontSize, str)
end

function FontStyle.setFontNameAndSize(text, fontName, fontSize)
	fontName = fontName or FontNames.HEITI
	if (tolua.type(text) == "cc.Label") then
	    local config = getTTFConfig(fontName)
	    if fontSize == nil then
	    	fontSize = text:getFontSize()
	    end
	    config.fontSize = fontSize
	    text:setTTFConfig(config) 
	else
		text:setFontName(fontName)
		text:setFontSize(fontSize)
	end
end

function FontStyle.get(r, g, b, size, font, bold, shadow, glow, outline)
	size = size or 18 --默认数值
	font = font or FontNames.HEITI
	bold = bold == true
	shadow = shadow == true
	glow = glow == true
	outline = outline == true
	local key = string.format("%d_%d_%d_%d_%s_%s_%s_%s_%s", r, g, b, size, font, tostring(bold), tostring(glow), tostring(shadow), tostring(outline))
	local result = styleMap[key]
	if (result == nil) then
		result = {}
		result.fontName = font
		result.fontSize = size
        result.fontColor = cc.c3b(r, g, b)
        result.c4b = cc.c4b(r, g, b, 0xff)
        result.bold = bold
        result.shadow = shadow
        result.glow = glow
        result.outline = outline
		styleMap[key] = result
	end
	return result
end

function FontStyle.applyStyle(text, style)
    FontStyle.setFontNameAndSize(text, style.fontName, style.fontSize)
	local ctype = tolua.type(text)
	-- if (tolua.type(text) == "cc.Label") then
	-- 	text:setTextColor(style.c4b)
	-- else
		text:setColor(style.fontColor)
	-- end

	if (applyMap[ctype]) then
		applyMap[ctype](text, style)
	else
		applyMap["none"](text, style)
	end
end

local function dealNone(text, style)
end

local function dealLabel(text, style)
	text:disableEffect()
	if style.shadow then
		text:enableShadow(shadowColor, shadowOffset, 0)
	end
	if style.glow then
		text:enableGlow(glowColor)
	end
	if style.bold then
		text:enableOutline(style.c4b, 1)
	elseif style.outline then
		text:enableOutline(outlineColor, 3)
	end
end

function FontStyle.setBold(text, value)
	if value then
		local c3b = text:getColor()
		local c4b = cc.c4b(c3b.r, c3b.g, c3b.b, 0xff)
		if text.getVirtualRenderer then
			text = text:getVirtualRenderer()
		end
		local oldConfig = text:getTTFConfig()
		local config = getTTFConfig(oldConfig.fontFilePath)
		config.fontSize = oldConfig.fontSize
		text:setTTFConfig(config)
		text:enableOutline(c4b, 1)
	else
		if text.getVirtualRenderer then
			text = text:getVirtualRenderer()
		end
		text:disableEffect()
	end
end

local function dealLabelTTF(text, style)
	if (style.shadow) then
		text:enableShadow(shadowOffset, 0.8, 0) --针对LabelTTF的阴影
	else
		text:disableShadow()
	end
end

local function dealText(text, style)
	local label = text:getVirtualRenderer()
	dealLabel(label, style)
end

function addOutline(item, c4b, px)
    if item == nil then return end
    if item.getVirtualRenderer then
    	item = item:getVirtualRenderer()
    end
	item:enableOutline(c4b, px)
end

applyMap["none"] = dealNone
applyMap["cc.LabelTTF"] = dealLabelTTF
applyMap["cc.Label"] = dealLabel
applyMap["ccui.Text"] = dealText

---字体统一配置
FontStyle.ZH_1 = FontStyle.get(255, 241, 158, 18, FontNames.HEITI)
FontStyle.ZH_1_B = FontStyle.get(255, 241, 158, 18, FontNames.HEITI, true)
FontStyle.ZH_2 = FontStyle.get(246, 255, 0, 15, FontNames.HEITI)
FontStyle.ZH_3 = FontStyle.get(255, 174, 1, 24, FontNames.HEITI) --
FontStyle.ZH_4 = FontStyle.get(173, 44, 0, 22, FontNames.HEITI)
FontStyle.ZH_5 = FontStyle.get(255, 221, 179, 24, FontNames.HEITI) --
FontStyle.ZH_6 = FontStyle.get(96, 47, 20, 22, FontNames.HEITI)
FontStyle.ZH_7 = FontStyle.get(255, 239, 49, 24, FontNames.HEITI)
FontStyle.ZH_8 = FontStyle.get(107, 44, 73, 20, FontNames.HEITI)
---MsgBox字体，有注释的字体可为MsgBox字体
FontStyle.ZH_9 = FontStyle.get(255, 221, 179, 26, FontNames.HEITI)
FontStyle.ZH_10 = FontStyle.get(232, 161, 97, 24, FontNames.HEITI)
FontStyle.ZH_11 = FontStyle.get(233, 162, 7, 26, FontNames.HEITI)
FontStyle.ZH_12 = FontStyle.get(0xff, 0xff, 0x9d, 23, FontNames.HEITI)  -- 升级开启功能字体
---竞技场
FontStyle.JJ_1 = FontStyle.get(225, 213, 44, 20, FontNames.HUAKANG)  --黄色20号
FontStyle.JJ_2 = FontStyle.get(225, 225, 225, 18, FontNames.HUAKANG)  --白色18号
FontStyle.JJ_3 = FontStyle.get(232, 161, 97, 18, FontNames.HUAKANG)  --棕色18号
FontStyle.JJ_4 = FontStyle.get(225, 0, 4, 20, FontNames.HUAKANG)  --红色20号
--登录公告
FontStyle.JJ_5 = FontStyle.get(225, 221, 176, 18, FontNames.HUAKANG)  --黄白色18号
FontStyle.JJ_6 = FontStyle.get(0, 224, 244, 20, FontNames.HUAKANG)    --蓝色20号
---拍卖场用begin
FontStyle.ZH_P1 = FontStyle.get(225, 225, 225, 22, FontNames.HEITI) --白色22号
FontStyle.ZH_P2 = FontStyle.get(246, 225, 0, 22, FontNames.HEITI)  --黄色22号
FontStyle.ZH_P3 = FontStyle.get(72, 225, 249, 22, FontNames.HEITI)  --蓝色22号
FontStyle.ZH_P4 = FontStyle.get(49, 225, 22, 22, FontNames.HEITI)  --绿色22号
FontStyle.ZH_P5 = FontStyle.get(246, 225, 0, 24, FontNames.HEITI)  --黄色24号
FontStyle.ZH_P6 = FontStyle.get(49, 225, 22, 22, FontNames.HEITI)  --绿色24号
---拍卖场用end
FontStyle.EN_1 = FontStyle.get(255, 246, 0, 18, FontNames.Euphemia)
FontStyle.EN_2 = FontStyle.get(255, 174, 1, 24, FontNames.Euphemia) --
FontStyle.EN_3 = FontStyle.get(43, 253, 38, 16, FontNames.Euphemia)
FontStyle.EN_4 = FontStyle.get(214, 44, 49, 22, FontNames.HEITI)
FontStyle.EN_5 = FontStyle.get(255, 238, 144, 16, FontNames.Euphemia)
FontStyle.EN_6 = FontStyle.get(26, 116, 171, 20, FontNames.HEITI)
FontStyle.EN_7 = FontStyle.get(255, 155, 221, 16, FontNames.Euphemia)
FontStyle.EN_8 = FontStyle.get(252, 251, 181, 13, FontNames.HEITI)
FontStyle.EN_9 = FontStyle.get(121, 231, 255, 16, FontNames.Euphemia)
FontStyle.EN_10 = FontStyle.get(255, 255, 255, 18, FontNames.Euphemia)

FontStyle.GUT_1 = FontStyle.get(0xFF, 0xDF, 0x2B, 32, FontNames.HEITI)
FontStyle.GUT_2 = FontStyle.get(0, 0, 0, 14, FontNames.HEITI)
FontStyle.GUT_3 = FontStyle.get(255, 0, 0, 16, FontNames.HEITI)
FontStyle.GUT_4 = FontStyle.get(0, 255, 0, 18, FontNames.HEITI)
FontStyle.GUT_5 = FontStyle.get(255, 255, 0, 20, FontNames.HEITI)
FontStyle.GUT_6 = FontStyle.get(0, 0, 255, 22, FontNames.HEITI)

FontStyle.INDUCT_1 = FontStyle.get(0xFF, 0xFF, 0x00, 30, FontNames.HEITI)
FontStyle.INDUCT_2 = FontStyle.get(0xFF, 0xFF, 0xFF, 30, FontNames.HEITI)

FontStyle.ITEM_1 = FontStyle.get(0xFc, 0xFF, 0x00, 22, FontNames.HEITI)
FontStyle.ITEM_2 = FontStyle.get(0xFF, 0x00, 0x00, 22, FontNames.HEITI)

FontStyle.COPY_1 = FontStyle.get(0xFF, 0xEA, 0x00, 16, FontNames.HEITI, false, false, true, true)
FontStyle.COPY_2 = FontStyle.get(0xFF, 0xEA, 0x00, 20, FontNames.HEITI, false, false, true, false)
FontStyle.COPY_3 = FontStyle.get(0xFF, 0x78, 0x00, 20, FontNames.HEITI, false, false, true, false)

--聊天字
FontStyle.CHAT_0 = FontStyle.get(255, 162, 0, 16, FontNames.HEITI)  --聊天16号深黄色
FontStyle.CHAT_1 = FontStyle.get(0, 198, 255, 16, FontNames.HEITI)  --聊天16号蓝色
FontStyle.CHAT_2 = FontStyle.get(254, 251, 0, 16, FontNames.HEITI)  --聊天16号黄色
FontStyle.CHAT_3 = FontStyle.get(255, 255, 255, 16, FontNames.HEITI)  --聊天16号白色
FontStyle.CHAT_4 = FontStyle.get(173, 254, 0, 16, FontNames.HEITI)  --聊天16号绿色


FontStyle.CHAT_5 = FontStyle.get(0, 198, 255, 24, FontNames.HEITI)  --聊天24号蓝色
FontStyle.CHAT_6 = FontStyle.get(254, 251, 0, 24, FontNames.HEITI)  --聊天24号黄色
FontStyle.CHAT_7 = FontStyle.get(255, 255, 255, 24, FontNames.HEITI)  --聊天24号白色
FontStyle.CHAT_8 = FontStyle.get(173, 254, 0, 24, FontNames.HEITI)  --聊天24号绿色

FontStyle.CHAT_9 = FontStyle.get(255,48,0, 16, FontNames.HEITI)  --聊天16号橙色
FontStyle.CHAT_10 = FontStyle.get(0,56,0, 16, FontNames.HEITI)  --聊天16号绿色
FontStyle.CHAT_11 = FontStyle.get(0x00, 0x5a, 0xFF, 16, FontNames.HEITI)  --聊天16号蓝色
FontStyle.CHAT_12 = FontStyle.get(0xa2, 0x00, 0xFF, 16, FontNames.HEITI)  --聊天16号紫色


FontStyle.CHAT_1_1 = FontStyle.get(255, 174, 1, 18, FontNames.HEITI) -- 聊天18号 深黄色
FontStyle.CHAT_1_2 = FontStyle.get(83,34,26, 18, FontNames.HEITI) -- 聊天18号 棕色
FontStyle.CHAT_1_3 = FontStyle.get(0,255,240, 18, FontNames.HEITI) -- 聊天18号 亮蓝色
FontStyle.CHAT_1_4 = FontStyle.get(255,48,0, 18, FontNames.HEITI) -- 聊天18号 红色
FontStyle.CHAT_1_5 = FontStyle.get(173,254,0, 18, FontNames.HEITI) -- 聊天18号 绿色

FontStyle.CHAT_1_6 = FontStyle.get(0,56,0, 18, FontNames.HEITI)  --聊天18号绿色
FontStyle.CHAT_1_7 = FontStyle.get(0x00, 0x5a, 0xFF, 18, FontNames.HEITI)  --聊天18号蓝色
FontStyle.CHAT_1_8 = FontStyle.get(0xa2, 0x00, 0xFF, 18, FontNames.HEITI)  --聊天18号紫色
FontStyle.CHAT_1_9 = FontStyle.get(0xff, 0x30, 0x00, 18, FontNames.HEITI)  --聊天18号橙色
FontStyle.CHAT_1_10 = FontStyle.get(255, 255, 255, 18, FontNames.HEITI)  --聊天18号白色
--tips
FontStyle.TIP_1 = FontStyle.get(0xFF, 0xFF, 0xFF, 16, FontNames.HEITI)
FontStyle.TIP_C = FontStyle.get(0xFF, 0xFF, 0xFF, 18, FontNames.HEITI) --content
FontStyle.TIP_C_1 = FontStyle.get(0xFF, 0x00, 0x00, 18, FontNames.HEITI) --content
FontStyle.TIP_T = FontStyle.get(0xFF, 0xDA, 0x00, 24, FontNames.HEITI) --title
FontStyle.TIP_T1 = FontStyle.get(0xFF, 0xDA, 0x00, 20, FontNames.HEITI) --title
FontStyle.TIP_T2 = FontStyle.get(0xFF, 0xDA, 0x00, 18, FontNames.HEITI) --title
FontStyle.TIP_S = FontStyle.get(0x31, 0xFF, 0x16, 22, FontNames.HEITI) --特殊
FontStyle.TIP_R = FontStyle.get(0xFF, 0x00, 0x00, 18, FontNames.HEITI) --红色
FontStyle.TIP_Y = FontStyle.get(0xFF, 0xDA, 0x00, 18, FontNames.HEITI) --黄色

--paperskill
FontStyle.PAPER_W20 = FontStyle.get(225, 225, 225, 20, FontNames.HEITI) --白色20号
FontStyle.PAPER_Y20 = FontStyle.get(0xFF, 0xDA, 0x00, 20, FontNames.HEITI) --ffda00

--skillBookMerge
FontStyle.SBM_Y22 = FontStyle.get(0xFF, 0xAE, 0x01, 22, FontNames.HUAKANG)
FontStyle.SBM_B22 = FontStyle.get(0x94, 0xFB, 0x41, 22, FontNames.HUAKANG)
FontStyle.SBM_BLK = FontStyle.get(0xff, 0xdd, 0xb3, 22, FontNames.HUAKANG)
FontStyle.SBM_B18 = FontStyle.get(0xff, 0xdd, 0xb3, 18, FontNames.HUAKANG)
FontStyle.SBM_RED = FontStyle.get(0xFF, 0x00, 0x00, 18, FontNames.HUAKANG)

-- 公告颜色
FontStyle.GG_NAME = FontStyle.get(0x00, 0xf6, 0xff, 22, FontNames.HEITI)  -- 名字
FontStyle.GG_NORMAL = FontStyle.get(0xff, 0xcf, 0x8a, 22, FontNames.HEITI) -- 普通
FontStyle.GG_WHITE = FontStyle.get(0xff, 0xff, 0xff, 22, FontNames.HEITI)  --白色
FontStyle.GG_GREEN = FontStyle.get(0x4e, 0xff, 0x00, 22, FontNames.HEITI)  --绿色
FontStyle.GG_BLUE = FontStyle.get(0x00, 0xf6, 0xff, 22, FontNames.HEITI)   --蓝色
FontStyle.GG_PURPLE = FontStyle.get(0xf7, 0xb3, 0xff, 22, FontNames.HEITI) --紫色
FontStyle.GG_YELLOW = FontStyle.get(0xf6, 0xff, 0x0e, 22, FontNames.HEITI) --黄色
