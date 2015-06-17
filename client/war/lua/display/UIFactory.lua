--UI工厂方法
require("lua/display/LabelBatch.lua")
UIFactory = UIFactory or {}

function addToParent(child, parent, x, y, depth)
	if parent then
		parent:addChild(child, depth or 0)
	end
	child:setPosition(x or 0, y or 0)
	return child
end

function safeRemoveFromParent(child)
	if child and child:getParent() then
		child:removeFromParent()
	end
	return child
end

function addToNewParent(child, parent, x, y, depth)
	child:retain()
	safeRemoveFromParent(child)
	addToParent(child, parent, x, y, depth)
	child:release()
end

function UIFactory.getScale9Sprite(frameName, capInsets, size, parent, x, y, depth)
	local sp = cc.Scale9Sprite:createWithSpriteFrameName(frameName, capInsets)
	sp:setContentSize(size)
	sp:setAnchorPoint(0, 0) --默认设置左下角为锚点
	addToParent(sp, parent, x, y, depth)
	return sp
end

function UIFactory.getScale9SpriteFile(file, capInsets, size, parent, x, y, depth)
	local sp = cc.Scale9Sprite:create(capInsets, file)
	sp:setContentSize(size)
	sp:setAnchorPoint(0, 0) --默认设置左下角为锚点
	addToParent(sp, parent, x, y, depth)
	return sp
end

--为锁链窗口添加标题图片
--@param win 窗口实例
--@param frameName 标题图片的名字
function UIFactory.addTitleImage(win, frameName)
	local size = win:getSize()
	UIFactory.getSpriteFrame(frameName, win, size.width / 2, size.height - 84, 10)
end

--构造通用带铁链的窗口背景
--@param parent 真正的窗口对象
--@param size 尺寸
--@param x,y 坐标
--@param title 标题对象
function UIFactory.getWindowBg(parent, size, x, y, title)
	if parent.getSize then
		size = size or parent:getSize()
	else
		size = size or parent:getContentSize()
	end
	x = x or 0
	y = y or 0
	local bg = ccui.Layout:create()
	bg:setSize(size)
	parent._normalbg = bg
	bg:setTouchEnabled(true) --阻断点击事件
	UIFactory.getScale9Sprite("bg_6.png", cc.rect(85, 85, 1, 1), size, bg)
	UIFactory.getScale9Sprite("title_bg.png", cc.rect(20, 20, 1, 1), cc.size(size.width, 60), bg, 0, size.height - 60)
	UIFactory.getSpriteFrame("title.png", bg, size.width / 2, size.height - 28)
	UIFactory.getSpriteFrame("dec_hole.png", bg, 36, size.height - 29)
	UIFactory.getSpriteFrame("dec_hole.png", bg, size.width - 35, size.height - 29)
	UIFactory.getSpriteFrame("dec_lain.png", bg, 36, size.height + 17)
	UIFactory.getSpriteFrame("dec_lain.png", bg, size.width - 35, size.height + 17)
	addToParent(bg, parent, x, y, -1) --层次为负数
	if title then
		title:setPosition(x + size.width / 2, size.height - 30)
		title:setLocalZOrder(10)
	end
	size.height = size.height + 65
	if parent.setSize then
		parent:setSize(size)
	else
		parent:setContentSize(size)
	end
    return bg
end

function UIFactory.getSpriteFrame(frameName, parent, x, y, depth)
	local sp = cc.Sprite:createWithSpriteFrameName(frameName)
	addToParent(sp, parent, x, y, depth)
	return sp
end

function UIFactory.getSprite(file, parent, x, y, depth)
	local sp = cc.Sprite:create()
	if file and file ~= "" then
		sp:setTexture(file)
	end
	addToParent(sp, parent, x, y, depth)
	return sp
end

--设置子对象的图片，没有则添加，如果url为空就移除
function UIFactory.setSpriteChild(con, name, isFrame, url, x, y, depth)
	if url and url ~= "" then
		if not con[name] then
			if isFrame then
				con[name] = UIFactory.getSpriteFrame(url, con, x, y, depth)
			else
				con[name] = UIFactory.getSprite(url, con, x, y, depth)
			end
		else
			if isFrame then
				con[name]:setSpriteFrame(url)
			else
				con[name]:setTexture(url)
			end
			con[name]:setPosition(x or 0, y or 0)
		end
	else
		if con[name] then
			con[name]:removeFromParent()
			con[name] = nil
		end
	end
	return con[name]
end

function UIFactory.getNode(parent, x, y, depth)
	local sp = cc.Node:create()
	addToParent(sp, parent, x, y, depth)
	return sp
end

function UIFactory.getDrawNode(parent, x, y, depth)
	local sp = cc.DrawNode:create()
	addToParent(sp, parent, x, y, depth)
	return sp
end

--进度条
--@param url 
--@param isFrame 是否plist
function UIFactory.getProgress(url, isFrame, parent, x, y, depth)
	local pgs = ccui.LoadingBar:create()
	pgs:loadTexture(url, isFrame and ccui.TextureResType.plistType or ccui.TextureResType.localType)
	addToParent(pgs, parent, x, y, depth)
	return pgs
end

function UIFactory.getLayer(width, height, parent, x, y, depth)
	local ly = cc.Layer:create()
	ly:setContentSize(width, height)
	addToParent(ly, parent, x, y, depth)
	return ly
end

function UIFactory.getLayerColor(c4b, width, height, parent, x, y, depth)
	local ly = cc.LayerColor:create(c4b, width, height)
	addToParent(ly, parent, x, y, depth)
	return ly
end

--构造文本
--默认不可点击
--默认锚点（0.5, 0.5）
function UIFactory.getLabel(txt, parent, x, y, fontSize, c3b, font, align, depth)
	return UIFactory.getText(txt, parent, x, y, fontSize, c3b, font, align, depth)
	-- local lbl = cc.Label:create()
	-- if align then
	--     lbl:setAlignment(align)
	-- end
	-- c3b = c3b or cc.c3b(0xff, 0xff, 0xff)
	-- FontStyle.applyStyle(lbl, FontStyle.get(c3b.r, c3b.g, c3b.b, fontSize, font))
	-- addToParent(lbl, parent, x, y, depth)
	-- if txt then
	-- 	lbl:setString(txt)
	-- end
	-- return lbl
end

--创建ccui.Text文本
--默认不可点击
function UIFactory.getText(txt, parent, x, y, fontSize, c3b, font, align, depth)
	local lbl = ccui.Text:create()
	lbl:setTouchEnabled(false)
	if align then
	    lbl:setTextHorizontalAlignment(align)
	end
	c3b = c3b or cc.c3b(0xff, 0xff, 0xff)
	FontStyle.applyStyle(lbl, FontStyle.get(c3b.r, c3b.g, c3b.b, fontSize, font))
	addToParent(lbl, parent, x, y, depth)
	if txt then
		lbl:setString(txt)
	end
	return lbl
end

function UIFactory.getLayout(w, h, parent, x, y, depth)
	local ly = ccui.Layout:create()
	ly:setSize(cc.size(w, h))
	addToParent(ly, parent, x, y, depth)
	return ly
end

function UIFactory.getButton(frameName, parent, x, y, depth, resType)
	local iv = ccui.ImageView:create(frameName, resType or ccui.TextureResType.plistType)
	iv:setAnchorPoint(0, 0)
	createScaleButton(iv)
	addToParent(iv, parent, x, y, depth)
	return iv
end

function UIFactory.getTextAtlas(parent, str, frameName, w, h, startChar, num, x, y, depth)
	local txt = ccui.TextAtlas:create()
	txt:setProperty(str, frameName, w, h, startChar)
	txt:setString(num)
	addToParent(txt, parent, x, y, depth)

	return txt
end

-- 获取从左向右进度条
function UIFactory.getLeftProgressBar(frameName, parent, x, y, depth)
	local left = cc.ProgressTimer:create(Sprite:createWithSpriteFrameName(frameName))
    left:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    left:setMidpoint(cc.p(0, 0))
    left:setBarChangeRate(cc.p(1, 0))
    addToParent(left, parent, x, y, depth)

    return left
end
function UIFactory.getLeftProgressBarWith(fileName, parent, x, y, depth)
	local left = cc.ProgressTimer:create(Sprite:create(fileName))
    left:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    left:setMidpoint(cc.p(0, 0))
    left:setBarChangeRate(cc.p(1, 0))
    addToParent(left, parent, x, y, depth)

    return left
end

function UIFactory.getTableView(parent, w, h, x, y, direction, depth)
	direction = direction == nil and cc.SCROLLVIEW_DIRECTION_VERTICAL or direction ---cc.SCROLLVIEW_DIRECTION_HORIZONTAL
	local tv = cc.TableView:create(cc.size(w, h))
	tv:setDirection(direction)   
	tv:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tv:setDelegate()
	addToParent(tv, parent, x, y, depth)

	return tv
end

---初始化侧边按钮
--按钮包括两个子对象，icon与txt
--txt的纹理由1.png与2.png结尾
--@param btnList 按钮列表
--@param nameList 按钮文字模式列表
--@param callback 回调 function(index)
--@param selectIndex 当前为选中状态的按钮的序号
--@param targetIndex [可选]首次应该选择的按钮的序号，默认为1
function UIFactory.initSubMenu(btnList, nameList, callback, selectIndex, targetIndex)
	local btnNormal = selectIndex == 1 and btnList[2] or btnList[1]
	local btnCurrent = selectIndex == 1 and btnList[1] or btnList[2]
    local selectConfig = {x=btnCurrent:getPositionX(), ix=btnCurrent.icon:getPositionX(), tx=btnCurrent.txt:getPositionX(), name="sub_menu_selected.png", tname="2.png", zOrder=50}
    -- local normalConfig = {x=btnNormal:getPositionX(), ix=btnNormal.icon:getPositionX(), tx=btnNormal.txt:getPositionX(), name="sub_menu_normal.png", tname="1.png", zOrder=0}
    local normalConfig = {x=selectConfig.x + 7, ix=btnNormal.icon:getPositionX(), tx=btnNormal.txt:getPositionX(), name="sub_menu_normal.png", tname="1.png", zOrder=0}
	local function setBtnState(btn, config, txtName)
		btn:setPosition(cc.p(config.x, btn:getPositionY()))
		btn.icon:setPosition(cc.p(config.ix, btn.icon:getPositionY()))
		btn.txt:setPosition(cc.p(config.tx, btn.txt:getPositionY()))
	    btn:loadTexture(config.name, ccui.TextureResType.plistType)
	    btn.txt:loadTexture(txtName .. config.tname, ccui.TextureResType.plistType)
	    btn:setLocalZOrder(config.zOrder)
	end
	function btnList.touchBeginHandler(touch, eventType)
		if touch ~= btnCurrent then
			touch:setScale(1.2)
		end
	end
	function btnList.touchEndedHandler(touch, eventType)
		touch:setScale(1)
		setBtnState(btnCurrent, normalConfig, btnCurrent._txtName)
		setBtnState(touch, selectConfig, touch._txtName)
		if eventType then
			SoundMgr.playEffect("sound/ui/click.mp3")
			if callback(touch._btnIndex) == true then --用户点击才回调
				setBtnState(btnCurrent, selectConfig, btnCurrent._txtName)
				setBtnState(touch, normalConfig, touch._txtName)
				return --如果回调返回了true，则不切换
			end
		end
		btnCurrent = touch
	end
	local y1, deltaY = btnList[1]:getPositionY(), -92
	local function initBtn(btn, index)
		btn:setTouchEnabled(true)
		btn:setPosition(normalConfig.x, y1 + (index - 1) * deltaY)
		btn._btnIndex = index
		btn._txtName = nameList[index]
		UIMgr.addTouchBegin(btn, btnList.touchBeginHandler)
		UIMgr.addTouchEnded(btn, btnList.touchEndedHandler)
		UIMgr.addTouchCancel(btn, btnList.touchEndedHandler)
	end
	for i = 1, #btnList do
		initBtn(btnList[i], i)
	end
	btnList.touchEndedHandler(btnList[targetIndex or 1]) --默认选中
end

--背景的三角形
function UIFactory.getTitleTriangle(parent, depth)
	local padding = 34
	local size = cc.size(24, 13)
	local winSize = parent.getSize and parent:getSize() or parent.getContentSize()
	local count = math.floor((winSize.width - padding) / size.width)
	local x = (winSize.width - size.width * count) / 2 - size.width / 2
	local y = winSize.height - size.height / 2 - 1
	local node = UIFactory.getNode(parent, x, y, depth)
	for i = 1, count do
		UIFactory.getSpriteFrame("title_triangle_m.png", node, size.width * i)
	end
	return node
end

--切换按钮
function UIFactory.initToggleButton(target, text, selected, toggleHandler)
	local function touchEndedHandler(sender, eventType)
		UIFactory.setToggleButton(sender, text, not sender.isSelect, true)
		sender:toggleHandler(sender.isSelect)
	end
	target:setTouchEnabled(true)
	UIMgr.addTouchEnded(target, touchEndedHandler)
	target.toggleHandler = toggleHandler
	UIFactory.setToggleButton(target, text, selected)
end

function UIFactory.setToggleButton(target, text, selected, tween)
	target.isSelect = selected
	local posX
	if selected then
		text:setString("开")
		target:loadTexture("toggle_bg_2.png", ccui.TextureResType.plistType)
		posX = 30
	else
		text:setString("关")
		target:loadTexture("toggle_bg_1.png", ccui.TextureResType.plistType)
		posX = -30
	end
	if tween then
		target.icon:stopAllActions()
		target.icon:runAction(cc.MoveTo:create(0.2, cc.p(posX + 51.5, 19)))
	else
		target.icon:setPositionX(posX + 51.5)
	end
end