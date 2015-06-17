-- create by Live --

local PI = 3.1415926
local P_PI = PI / 180

local function getRowColumn(value)
	local list = string.split(value, "_")
	return list[1], list[2]
end

MainPage = class("MainPage", function()
	return Sprite:create()
end)

function MainPage:ctor()
	self.currPage = 1 	-- 当前页面下标
	self.sid = 0 		-- 定时器id
	self.addList = Dictionary:create() 		-- 需加载的列表
	self.removeList = Dictionary:create() 	-- 需移除的列表
	self.pieceDic = {} 		-- 地表切片列表		
	self.isStartTimer = false -- 是否已开启定时器
end
-- 初始化页面
function MainPage:initMainPage()
	self:firshShow(self.currPage)

	if self.currPage == 1 then
		BackButton:pop(self)
	else
		BackButton:pushHome(self, function() Command.run("ShowHomePage") end)
	end

	self:startTimer()
end
-- 首次显示时的执行方法
function MainPage:firshShow(index)
	self:setRotation((index - 1) * -45)
	-- 添加当前页显示背景切片
	local main_list = PageData.getPageImgList(index)
	for k, v in pairs(main_list) do
		local piece = self:createPiece(k, v)
		self:addChild(piece)
	end
	-- 获取前后页下载图片，放入下载列表
	local add_list = PageData.getPrevNextImageList(self.currPage)
	-- local add_list = PageData.getPageAllImgList(self.currPage) --PageData.getPageImgList(1)--
	for k, v in pairs(add_list) do
		local list = self.addList
		list:add(k, v)
	end
end
-- 开始执行定时器，当有下载列表时，先下载图片，否则移除图片
function MainPage:startTimer()
	if self.isStartTimer == false then
        PageData.setIsLoadingEnd(false)
		self.isStartTimer = true
		local function tick()
			local len = self.addList:getLength()
			if len > 0 then
				local i = 0
				len = math.min(3, len)
				local list = self.addList
				for k, _ in pairs(list:getList()) do
					if len <= i then
						break
					end
					local data = list:remove(k)
					self:addOnePiece({key = k, value = data})
					i = i + 1
				end
			else
				len = self.removeList:getLength()
				local list = self.removeList
				if len > 0 then
					for k, _ in pairs(list:getList()) do
						local data = list:remove(k)
						self:removeOnePiece({key = k, value = data})
						break
					end
				else
					self:clearTimer()
					LogMgr.debug(">>>>>>>>>>>>>> Ground remove Complete......")
					EventMgr.dispatch( EventType.ScenePageLoaded )
                    PageData.setIsLoadingEnd(true)
				end
			end
		end
		self.sid = TimerMgr.startTimer(tick, 0, false)
	end
end
-- 清除定时器
function MainPage:clearTimer()
	TimerMgr.killTimer(self.sid)
	self.isStartTimer = false
end
-- 创建地表切片，key为row_column的字符串，v为路径
function MainPage:createPiece(key, v)
	local row, col = getRowColumn(key)
	local piece = Sprite:create(v) -- GroundSprite:create(key, v, self.bright)
	piece:setAnchorPoint(0, 0)

	local px = col * PageInfo.piece_width - PageInfo.radius
	local py = PageInfo.piece_height * (PageInfo.row - row - 1) - PageInfo.radius - PageInfo.left_space
	piece:setPosition(px, py)

	self.pieceDic[key] = piece

	return piece
end
-- 添加一块地表切片
function MainPage:addOnePiece(data)
	if nil == data then return end
	if nil == self.pieceDic[data.key] then
		local piece = self:createPiece(data.key, data.value)
		self:addChild(piece)
	end
end
-- 移除地表切片
function MainPage:removeOnePiece(data)
	if nil == data then return end
	local k, v = data.key, data.value
	if nil ~= self.pieceDic[k] then
		local piece = self.pieceDic[k]
		self.pieceDic[k] = nil
		self:removeChild(piece)
	end
	-- 移除缓存中的图片
	LoadMgr.removeImage(v)
end
-- 转向index页面（已转完）
function MainPage:turnTo(index)
	if index == self.currPage then
		return
	end

	self:clearTimer()

	local lastPage = self.currPage
	self.currPage = index

	local removeList = nil
	local addList = nil

	local removeList, addList = PageData.getAddRemoveList(lastPage, index)	

	LogMgr.debug(">>>>>>> 移除的图片")
	for k, v in pairs(removeList) do
		local list = self.removeList
		list:add(k, v)
	end

	LogMgr.debug(">>>>>>> 添加的图片")
	for k, v in pairs(addList) do
		local list = self.addList
		list:add(k, v)
		self.removeList:remove(k)
	end

	local function delayFun()
		self:startTimer()
	end
	performNextFrame(self, delayFun)

	if self.currPage == 1 then
		BackButton:pop(self)
	else
		BackButton:pushHome(self, function() Command.run("ShowHomePage") end)
	end
end
-- 跳转到page页面，page为下标
function MainPage:jumpToPage(page)
	self:clearMain()
	self.currPage = page
	self:firshShow(self.currPage)
	self:startTimer()
	if self.currPage == 1 then
		BackButton:pop(self)
	else
		BackButton:pushHome(self, function() Command.run("ShowHomePage") end)
	end
end
-- 原本是可以刷新阴影的，已废弃
function MainPage:refresh()
	-- for k, v in pairs(self.pieceDic) do
	-- 	v:update()
	-- end
end

function MainPage:getCurrPage()
	return self.currPage
end

function MainPage:clearMain()
	self:clearTimer()

	for k, v in pairs(self.pieceDic) do
		local piece = self.pieceDic[k]
		self.pieceDic[k] = nil
		self:removeChild(piece)
		-- 移除缓存中的图片
		LoadMgr.removeImage("image/mainPage/pieces/" .. k .. ".png")
	end

	self.pieceDic = {}
	self.addList:clear()
	self.removeList:clear()
end

function MainPage:dispose()
	TimerMgr.killTimer(self.sid)
	self:clearMain()

	-- clearGroundDic()
	removeTmpImgList()
end

function MainPage:create(index)
	local page = MainPage.new()
	page:setPosition(MainScene.OFFX, -MainScene.OFFY)

	-- 当前页面数
	if nil ~= index then
		page.currPage = index
	end

	page:initMainPage()

	return page
end
