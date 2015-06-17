TipsBase = createLayoutClass("TipsBase", cc.Node)

function TipsBase:create(...)
	return TipsBase.new(...)
end

function TipsBase:ctor(width)
	self.width = width or 370
	self.bg = UIFactory.getScale9Sprite("tips_bg2.png", cc.rect(32, 32, 1, 1), cc.size(1,1), self)
	self.otherCon = UIFactory.getNode(self)
	self.richCon = UIFactory.getNode(self)
	self.richStrs = nil
	self.base_close = UIFactory.getButton("close.png", self, 0, 0, 555, resType)
	local function exit( ... )
		ActionMgr.save( 'UI', 'TipsBase click btn_close' )
        PopMgr.removeWindow(self)
	end

    self.base_close:addTouchEnded(exit)
end

function TipsBase:getStyleString(text, color, size)
	return FontStyle.getRichText(text, color, size)
end

--添加富文本
function TipsBase:addRich(richText)
	table.insert(self.richStrs, richText)
end

--添加文本
function TipsBase:addText(text, color, size)
	self:addRich(self:getStyleString(text, color, size))
end

--添加文本跟换行
function TipsBase:addTextBr(text, color, size)
	self:addText(text, color, size)
	self:addBr()
end

--添加换行
function TipsBase:addBr()
	self:addRich("[br]")
end

--直接添加子对象，绝对定位
--@param node 子对象
--@param x [可选]x坐标
--@param y [可选]y坐标
--@param depth [可选]深度
function TipsBase:addNode(node, x, y, depth)
	self.otherCon:addChild(node, depth or 0)
	if x and y then
		node:setPosition(x, y)
	end
end

function TipsBase:clear()
	self.richStrs = {}
	self.otherCon:removeAllChildren(true)
	self.richCon:removeAllChildren(true)
end

function TipsBase:updateView()
	self:clear()
	self:render()
	RichTextUtil:DisposeRichText(table.concat(self.richStrs), self.richCon, nil, 0, self.width - 50, 8)
	self:layout()
end

function TipsBase:setOtherSize(width, height)
	self.otherCon:setContentSize(cc.size(width, height))
end

--如果有特殊需求，需要重写
--目前布局为Node在Text的上面
function TipsBase:layout()
	local richSize = self.richCon:getContentSize()
	local otherSize = self.otherCon:getContentSize()
	self.richCon:setPosition(25, 25 + richSize.height)
	self.otherCon:setPosition(25, 25 + richSize.height)
	self.bg:setContentSize(self.width, 50 + richSize.height + otherSize.height)
	self:setContentSize(self.bg:getContentSize())
	local size = self:getContentSize()
	self.base_close:setPosition(size.width - 30,size.height - 30)
end

--设置数据，主数据，附加数据
function TipsBase:setData(data, exData)
	self.data = data
	self.exData = exData
	self:updateView()
end

--需要重写
--分析self.data，处理显示
function TipsBase:render()
end
