-- Create By Live --
-- 继承原始cocos2dx对象

Node = class("Node", function()
	local node = cc.Node:create()
	return node
end)
function Node:create()
	local node = Node.new()
	return node
end

-- px,py为左下角与注册点的偏移值（正数）
function Node:setOffset(px, py)
	local size = self:getContentSize()
	local p = cc.p(px / size.width, py / size.height)

	self:setAnchorPoint(p)
end

Sprite = class("Sprite", function(str,rect)
	local sprite = nil
	if nil ~= str then
		if nil ~= rect then
			sprite = cc.Sprite:create(str,rect)
		else
			sprite = cc.Sprite:create(str)
		end
	else
		sprite = cc.Sprite:create()
	end
	return sprite
end)

-- px,py为左下角与注册点的偏移值（正数）
function Sprite:setOffset(px, py)
	local size = self:getContentSize()
	local p = cc.p(px / size.width, py / size.height)

	self:setAnchorPoint(p)
end

function Sprite:create(str, rect)
	local sprite = Sprite.new(str, rect)
	return sprite
end
function Sprite:createWithSpriteFrame(spriteframe)
	local sprite = Sprite.new()
	sprite:setSpriteFrame(spriteframe)
	return sprite
end
function Sprite:createWithSpriteFrameName(str)
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
	local sprite = Sprite.new()
	sprite:setSpriteFrame(frame)
	return sprite
end 

function Sprite:getColor(__point, __convertToNodeSpace, __isFloat)
    if __convertToNodeSpace == nil then
        __convertToNodeSpace = true
    end
    if __convertToNodeSpace then
        __point = self:convertToNodeSpace(__point)
    end
    -- Create a new Texture to get the pixel datas.
    local __size = self:getContentSize()
    local __rt = cc.RenderTexture:create(__size.width, __size.height)
    -- Hold the old anchor and position to restore it late on.
    local __oldAnchor = self:getAnchorPoint()
    local __oldPosX, __oldPosY = self:getPositionX(), self:getPositionY()
    -- Move the sprite to left bottom.
    -- self:align(display.LEFT_BOTTOM, 0,0)
    self:setPosition(0, 0)
    --LogMgr.log( 'debug',"getColor:", __point.x, __point.y, __size.width, __size.height)
    -- Render the sprite to get a new texture.
    __rt:begin()
    self:visit()
    __rt:endToLua()
    -- Restore the original anchor and position.
    LogMgr.log( 'debug',__oldPosX .. " , " .. __oldPosY .. " and " .. __oldAnchor.x .. " , " .. __oldAnchor.y)
    self:setAnchorPoint(__oldAnchor.x, __oldAnchor.y)
    self:setPosition(__oldPosX, __oldPosY)
    local __img = __rt:newImage(false)
    local __color = nil
    -- if __isFloat then
    --     __color = __img:getColor4F(__point.x, __point.y)
    -- else
        __color = __img:getColor4B(math.floor(__point.x), math.floor(__point.y))
    -- end
    return __color, __rt
end
 
-- Only get a alpha value.
function Sprite:getColorAlpha(__point, __convertToNodeSpace, __isFloat)
    local color = self:getColor(__point, __convertToNodeSpace, __isFloat)
    LogMgr.log( 'debug',"color = " .. color.a)
    return color.a
end
-- function Sprite:createWithTexture(texture2d,rect,bool)
-- 	local sprite = Sprite.super:createWithTexture(texture2d,rect,bool)
-- 	return sprite
-- end

Layer = class("Layer", function()
	local layer = cc.Layer:create()
	return layer
end)
function Layer:getUIType()
	return "cc"
end
function Layer:create()
	local layer = Layer.new()
	return layer
end

LayerColor = class("LayerColor", function(c4b, w, h)
	local layerColor = cc.LayerColor:create(c4b, w, h)
	return layerColor
end)
function LayerColor:create(c4b, w, h)
	local layerColor = LayerColor.new(c4b, w, h)
	return layerColor
end

Scene = class("Scene", function()
	local scene = cc.Scene:create()
	return scene
end)
function Scene:ctor()
	self.name = "default"
	self.isInit = false
	self.isNeedRelease = true --默认就要释放资源

	self.displayList = {}  -- 执行retain()方法的现实对象
	self.addList = {} -- 添加进场景的对象

	local function onNodeEvent(event)
        if "exit" == event then
            self:dispose()
            if self.isNeedRelease == true then
            	self:onRelease()
            	self:removeObjList()
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)
end
function Scene:dispose()
end
function Scene:onRelease()
	LogMgr.debug("Scene onRelease .......")
	self.isInit = false
	for k, v in pairs(self.displayList) do
		LogMgr.debug(" key = " .. k)
		v:removeFromParent(true)
	end
	self.displayList = {}

	LoadMgr.releaseScene(self.name)
end
function Scene:addRelease(url)
	LoadMgr.loadImage(url, LoadMgr.SCENE, self.name)
end
function Scene:addDisplayList(key, value)
	self.displayList[key] = value
end

function Scene:removeObjList()
	LogMgr.debug("add obj remove .....")
	for k, v in pairs(self.addList) do
		v:removeFromParent(true)
	end
	self.addList = {}
end
function Scene:addObjList(value)
	table.insert(self.addList, value)
end
function Scene:getObjList()
	return self.addList
end
function Scene:create()
	local scene = Scene.new()

	return scene
end

TextInput = class("TextInput", function(width, height, filePath)
	if nil == filePath then
		filePath = "image/share/bg_edit.png"
	end
	local sacel9SprY = cc.Scale9Sprite:create(filePath)
	local input = cc.EditBox:create(cc.size(width, height), sacel9SprY)
	return input
end)

function TextInput:ctor()
	self:setAnchorPoint(0, 0.5)
	-- 设置编辑框内的文字
    self:setText("");
    -- 设置编辑框内的文字颜色
    self:setFontColor(cc.c3b(255, 0, 0));
    -- 当编辑框中没有任何字符的提示
    self:setPlaceHolder("请输入文字");
    -- 最大输入文本长度
    self:setMaxLength(50);
    -- 设置输入模式
    -- self:setInputFlag(kEditBoxInputFlagSensitive);
    -- 设置return类型
    -- self:setReturnType(kKeyboardReturnTypeDone);
	local function changeHandler(eventType, sender)
		if eventType == "changed" then
			local str = self:getText()
			local result = StringTools.subByteString(str, self:getMaxLength())
			if result ~= str then
				self:setText(result)
			end
			if self.changeHandler then
				self:changeHandler() --文本改变事件
			end
		end
	end
	self:registerScriptEditBoxHandler(changeHandler)
end

function TextInput:create(width, height, filePath)
	return TextInput.new(width, height, filePath)
end

function TextInput:replace(textfield, maxLen, isPassword, holder)
	local size = textfield:getContentSize()
	local ti = TextInput:create(size.width, size.height)
	local parent = textfield:getParent()
	local zOrder = textfield:getLocalZOrder()
	local tag = textfield:getTag()
	if maxLen then
		ti:setMaxLength(maxLen)
	end
	if isPassword then
		ti:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	end
	if holder then
		ti:setPlaceHolder(holder)
	end
	if textfield.getTextHorizontalAlignment then
		ti:setTextHorizontalAlignment(textfield:getTextHorizontalAlignment())
	end
    FontStyle.setFontNameAndSize(ti, nil, textfield:getFontSize())
	ti:setPosition(textfield:getPosition())
	ti:setFontColor(textfield:getColor())
	parent:addChild(ti, tag, zOrder)
	parent[textfield:getName()] = ti
	textfield:removeFromParent()
	return ti
end

ExSprite = class("ExSprite", function()
	local sprite = Sprite:create()
end)
