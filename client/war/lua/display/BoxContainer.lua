--盒子容器
--0,0在左上角
--y值都为负值
--index从1开始
BoxContainer = class("BoxContainer", function()
	return cc.Layer:create()
end)

function BoxContainer:ctor(column, minRow, nodeSize, spaceSize, offset)
	self.column = column
	self.minRow = minRow or 0 --最少一行
	self.row = self.minRow
	self.count = column * self.row
	self.nodeMap = {}
	self.nodeSize = nodeSize or cc.p(110, 110)
	self.spaceSize = spaceSize or cc.p(4, 4)
	self.offset = offset or cc.p(0, 0)
end

function BoxContainer:getHeight()
	return self.row * self:getNodeHeight()
end

function BoxContainer:getNodeHeight()
	return self.nodeSize.y + self.spaceSize.y
end

function BoxContainer:setNodeCount(count)
	self.row = math.max(self.minRow, math.ceil(count / self.column))
	local oldCount = self.count
	self.count = self.column * self.row
	for i = self.count + 1, oldCount do
		self:removeNode(i)
	end
end

function BoxContainer:addNode(node, index)
	self.nodeMap[index] = node
	self:addChild(node)
	local i = index - 1
    local col = i % self.column
    local row = math.floor(i / self.column)
    local dx = col * (self.nodeSize.x + self.spaceSize.x) + self.offset.x
    local dy = -(row + 1) * (self.nodeSize.y + self.spaceSize.y) + self.offset.y
	node:setPosition(dx, dy)
end

function BoxContainer:removeNode(index)
	local node = self.nodeMap[index]
	self:removeChild(node)
	self.nodeMap[index] = nil
	return node
end

function BoxContainer:getNode(index)
	return self.nodeMap[index]
end

--获取点击的对象
function BoxContainer:hitTest(globalPos)
	local pos = self:convertToNodeSpace(globalPos)
	local col = math.floor((pos.x - self.offset.x) / (self.nodeSize.x + self.spaceSize.x))
	local row = math.floor(-(pos.y - self.offset.y) / (self.nodeSize.y + self.spaceSize.y))
	for i = row - 1, row + 1 do
		for j = col - 1, col + 1 do
			local index = i * self.column + j + 1 --index需要计算出来的+1
			local node = self:getNode(index)
			if node then
				if cc.rectContainsPoint(node:getBoundingBox(), pos) then
					return index
				end
			end
		end
	end
	return 0
end

--刷新数据
--@param callback 刷新单个节点callback(index)
function BoxContainer:reloadData(callback, enableDelay)
	self:stopUpdateAction()
	self.starIndex = 1
	local function updateHandler()
		if self.starIndex <= self.count then
			callback(self.starIndex)
			self.starIndex = self.starIndex + 1
		else
			self:stopUpdateAction()
		end
	end
	if enableDelay then
		local action = schedule(self, updateHandler, 0)
		action:setTag(199)
		self.updateTag = action:getTag()
	else
		for i = 1, self.count do
			callback(i)
		end
	end
end

function BoxContainer:stopUpdateAction()
	if self.updateTag then
		self:stopActionByTag(self.updateTag)
		self.updateTag = nil
	end
end