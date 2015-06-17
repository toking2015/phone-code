-- create by Live --
require "lua/game/scene/main/BuilderView.lua"

BuilderLayer = class("BuilderLayer", function()
	return Node:create()
end)

function BuilderLayer:create(index)
	local layer = BuilderLayer.new()
	layer:setPosition(MainScene.OFFX, -MainScene.OFFY)

	-- layer.sid = 0
	layer.rid = 0  		-- 加载定时器
	layer.addTime = 0 	-- 异步用到，已废弃

	layer.currPage = 1
	if nil ~= index then
		layer.currPage = index
	end

	layer:firstShow(index)

	layer.updateFun = function(data)
		Command.run('bubble show')
		layer:addNewBuilding(data, layer.currPage)
	end
	layer.event_list = {}
	layer.event_list[EventType.UserBuildingUpdate] = layer.updateFun
	EventMgr.addList(layer.event_list)

	return layer
end
-- 首次显示
function BuilderLayer:firstShow(index)
	self.builderList = {} 	-- 建筑物列表
	self.decoList = {}		-- 装饰物列表
	self.partiList = {}		-- 粒子列表

	self:showPageView(1)
	self:showPageView(8)
	
	self:setRotation((index - 1) * -45)

	self.rid = TimerMgr.startTimer(function() self:showBuilderRedPoint() end, 1)
end

function BuilderLayer:addBuilding(data)
	local id, building, currPage = data.value.id, data.value, data.page
    LogMgr.log( 'scene',">>>>>>>>>>>>>>>>>>bid = " .. id)
	if nil == self.builderList[currPage] then
		self.builderList[currPage] = {}
	end

	local isOpen = (data.isNotOpen == false)
	
	local builderView = self.builderList[currPage][id]
	if builderView ~= nil then
		if builderView:getParent() ~= nil then builderView:removeFromParent() node = nil end
	end
	
	builderView = BuilderView:create(data)--Node:create()
	builderView.isClick = isOpen
  
	self:addParticalBy(currPage, id)
    self:addChild(builderView)

	-- if BuildingData.hideMap[id] then
	-- 	builderView:setVisible(false)
	-- end
	self.builderList[currPage][id] = builderView
	
	return node
end

-- 显示效果吧~~~
function BuilderLayer:showEffectAction(name, x, y, parent, depth)
	local url = "image/armature/ui/MainUI/" .. name .. "/" .. name ..".ExportJson"
	local effect = ArmatureSprite:addArmatureScene(url, name, "main", parent, x, y, nil, depth)
	return effect
end

-- 显示竞技场时间
local function showArenaTime(v)
	 -- 设置时间
    if v.time == nil then       
        v.time = getLayout("image/ui/ArenaUI/ArenaTime_1.ExportJson")
        v:addChild(v.time, 20)
        v.time.minute:setString("10")
        v.time.second:setString("00")
        v.time:setRotation(-45)
        -- local point = v:convertToNodeSpace(cc.p(417, 310))
        -- v.time:setPosition(point)
        v.time:setPosition(cc.p(-1065, 851))
        v.time:setVisible(false)
    end 
    local rolecd = ArenaData.getCdTime()
    if rolecd ~= 0 and rolecd > gameData.getServerTime() then 
       local minute = tostring(os.date("%M", rolecd - gameData.getServerTime()))
       local second = tostring(os.date("%S", rolecd - gameData.getServerTime()))
       if v.time ~= nil then 
          v.time.minute:setString(minute)
          v.time.second:setString(second)
          v.time:setVisible(true)  
       end 
    else 
       v.time:setVisible(false)
    end
end
-- 添加建筑物红点
function BuilderLayer:showBuilderRedPoint()
	local rList = PageData.getRedPointData()
	local currPage = PageData.getCurrPage()
	for k, v in pairs(rList) do
		local isShow = v.callback()
		local bList = self:getBuilderList(currPage)
		local node = bList[v.id]
		if nil ~= node and v.page == currPage then
			if false == isShow then 
				node.rPoint = nil
			end
			if 1004 == v.id then
				if true == isShow and self.cardEff == nil then
					self.cardEff = self:showEffectAction("mfts-tx-01", node.bg:getPositionX(), node.bg:getPositionY() + 60, node, 1000)
					-- 添加点击区域
					if self.cardClick ~= nil then
						self.cardClick:removeFromParent()
						self.cardClick = nil
					end
					self.cardClick = ccui.Layout:create()
					self.cardClick:setSize(cc.size(80, 80))
					self.cardClick:setPosition(node.bg:getPositionX() - 40, node.bg:getPositionY() + 20)
					node:addChild(self.cardClick)
					local function touchBegin()
		                node:clickBuilderBegan()
					end
		            local function touchEnded()
		                node:clickBuilderEnded(true)
					end
					 local function touchCancel()
		                node:clickBuilderEnded(false)
					end
		            UIMgr.addTouchBegin(self.cardClick, touchBegin)
		            UIMgr.addTouchEnded(self.cardClick, touchEnded)
		            UIMgr.addTouchCancel(self.cardClick, touchCancel)
				elseif not isShow and nil ~= self.cardEff and self.cardEff:getParent() then
					self.cardEff:stop()
					self.cardEff:removeNextFrame()
					self.cardEff = nil
					if self.cardClick ~= nil then
						self.cardClick:removeFromParent()
						self.cardClick = nil
					end
				end
			elseif nil == node.rPoint then
				-- local point = node:convertToNodeSpace(cc.p(v.x, v.y))
				local point = cc.p(v.x, v.y)
				node.rPoint = setButtonPoint(node, isShow, point)
			end
			if 8004 == v.id then
				showArenaTime(node)
			end
		end
	end
end
-- 添加粒子效果
function BuilderLayer:addPartical(data)
	local px = data.x - PageInfo.radius
	local py = PageInfo.height - data.y - PageInfo.radius
	local rotation = data.rotation

	local particle = Particle:create(data.plist, px, py)
	self:addChild(particle, 20)
	if nil ~= rotation then
		particle:setRotation(rotation)
	end
	return particle
end

-- 获取currPage页面可以显示的建筑物列表
function BuilderLayer:getPageBuilderList(currPage, isShowAll)
	local buildingList = PageData.getPageBuilding(currPage)

	local list = {}

	if currPage == 1 or currPage == 8 then
		local bList = gameData.user.building_list
		for k, v in pairs(buildingList) do
			local data = {id = v.id, value = v, page = currPage, isNotOpen = true}
			for _, value in pairs(bList) do 
				local bd = findBuilding(value.building_type)
				if bd.icon == v.id then 
				    data.isNotOpen = false
				    break 
				end
			end
			table.insert(list, data)
		end
	elseif currPage == 2 then
	    
	end
	
	return list
end
-- 显示建筑物
function BuilderLayer:showBuilding(currPage, isShowAll, isDelay)
	local list = self:getPageBuilderList(currPage, isShowAll)
	
	for _, v in pairs(list) do
		self:addBuilding(v)
	end
end
-- 添加currPage页面的id粒子效果
function BuilderLayer:addParticalBy(currPage, id)
	local particleList = PageData.getPageParticle(currPage)
	LogMgr.log( 'scene',"partical : page = " .. currPage .. " , id = " .. id)
	if nil ~= particleList and nil ~= particleList[id] then
		if nil == self.partiList[currPage] then
			self.partiList[currPage] = {}
		end
		if nil == self.partiList[currPage][id] then
			local particle = self:addPartical(particleList[id])
			self.partiList[currPage][id] = particle
		end
	end
end
-- 添加currPage页面的所有粒子效果
function BuilderLayer:showParticle(currPage)
	local particleList = PageData.getPageParticle(currPage)

	if nil == self.partiList[currPage] then
		self.partiList[currPage] = {}
	end

	if nil ~= particleList then
		for k, v in pairs(particleList) do
			local bList = self.builderList[currPage]
			if nil ~= bList[v.id] then
				local particle = self:addPartical(v)
				self.partiList[currPage][v.id] = particle
			end
		end
	end
end
-- 显示currPage页面的建筑物
function BuilderLayer:showPageView(currPage, isDelay)
	self:showBuilding(currPage, false, isDelay)
end
-- 预加载建筑物，已废弃
function BuilderLayer:preloadPageView(currPage)
	local list = self:getPageBuilderList(currPage, false)

	self:addBuildAsync(list)
end
-- 异步添加建筑物，已废弃
function BuilderLayer:addBuildAsync(list)
	if self.asyncList == nil then self.asyncList = {} end
	local len = #self.asyncList
	if #list > 0 then
		for k, v in pairs(list) do
			table.insert(self.asyncList, 1, v)
		end
	end
	if len == 0 then
		self:showBuildAsync(list)
	end	
end
-- 以异步方式显示建筑物，已废弃
function BuilderLayer:showBuildAsync(list)
	if true then return end
--    local list = self.asyncList
	-- if self.asyncList == nil then return end
    if #self.asyncList > 0 then
		local function doCallback()
            if #self.asyncList > 0 then
                local v = table.remove(self.asyncList, 1)
    			local effect = v.value.effect
    			local json = "image/armature/scene/main/effect/" .. effect .. "/" .. effect .. ".ExportJson"
    			local function callback()
    				local scene = SceneMgr.getCurrentScene()
    				if scene.name == "main" and self ~=nil and self.addBuilding ~= nil then
	                    if self.addTime == nil then self.addTime = 0 end
	                    self.addTime = self.addTime + 1
	    				armatrueMgr:addArmatureFileInfo(json)
	    				ccs.Armature:createAsync(effect, cc.CallFunc:create(function()
	    					local scene = SceneMgr.getCurrentScene()
	    					if scene.name == "main" and self ~=nil and self.addBuilding ~= nil then
	    				        self.addTime = self.addTime - 1
	    						self:addBuilding(v)
	    					end
	    				end))
	    			end
    			end
    			LoadMgr.loadArmatureFileInfoAsync(json, LoadMgr.SCENE, "main", callback)
			else
                if self.addTime <= 0 then
        			LoadMgr.clearAsyncCache()
            		TimerMgr.killTimer(self.async_id)
            		self.async_id = nil
        		end
			end
		end
		if self.async_id == nil then
            self.async_id = TimerMgr.startTimer(doCallback, 0.05)
		end
	end
end
-- 移除currPage页面的建筑物
function BuilderLayer:removePageView(currPage)
	-- if true then return end
	if nil ~= self.decoList[currPage] then
		for k, v in pairs(self.decoList[currPage])  do
			self:removeChild(v)
		end
		self.decoList[currPage]  = nil
	end

	if nil ~= self.partiList[currPage] then
		LogMgr.debug("remove particle page = " .. debug.dump(self.partiList))
		for k, v in pairs(self.partiList[currPage])  do
			self:removeChild(v)
		end
		self.partiList[currPage]  = nil
	end

	if nil ~= self.builderList[currPage] then
		for k, v in pairs(self.builderList[currPage])  do
			local effect = v.data.effect
			v:removeAllChildren()
			self:removeChild(v)
			if nil ~= effect and "" ~= effect then
				local path = "image/armature/scene/main/effect/" .. effect .. "/" .. effect .. ".ExportJson"
				LoadMgr.removeArmature(path)
			end
		end
		self.builderList[currPage]  = nil
	end
end
-- 在index页面添加一个建筑物
function BuilderLayer:addOneBuildingInPage(info, index)
	if index == 2 or index == 3 then
		return
	else
		local data = {value = info, page = index, isNotOpen = false}
		self:addBuilding(data)
	end
end
-- 判断建筑是否在当前页
function BuilderLayer:judgeBuildingInPage(index, icon)
	local list = PageData.getPageBuilding(index)
	for k, v in pairs(list) do
		if v.id == icon then
			return true, v
		end
	end
	return false, v
end
-- 在currPage页新增建筑物
function BuilderLayer:addNewBuilding(value, currPage)
	local bd = findBuilding(value.data.building_type)
	if nil ~= bd then
		local icon = bd.icon
		local page = currPage

		-- 副本建筑不需要显示了~~~
		if icon > 2000 and icon < 8000 then
			return
		end
		local isExist, buildingInfo = self:judgeBuildingInPage(currPage, icon)
		if true == isExist then
			page = currPage
			self:addOneBuildingInPage(buildingInfo, currPage)
		else
			local prevPage = PageData.getPrevPage(currPage)
			isExist, buildingInfo = self:judgeBuildingInPage(prevPage, icon)
			if true == isExist then
				page = prevPage
				self:addOneBuildingInPage(buildingInfo, prevPage)
			else
				local nextPage = PageData.getNextPage(currPage)
				isExist, buildingInfo = self:judgeBuildingInPage(nextPage, icon)
				if true == isExist then
					page = nextPage
					self:addOneBuildingInPage(buildingInfo, nextPage)
				end
			end
		end
	end
end
-- 获取currPage页面的建筑物列表
function BuilderLayer:getBuilderList(currPage)
	-- LogMgr.log( 'scene',"currPage = " .. currPage)
	local list = {}
	if nil ~= self.builderList[currPage] then
		return self.builderList[currPage]
	end
	return list
end
--获取建筑图片实体
function BuilderLayer:getBuilding(currPage, id)
	local list = self.builderList[currPage]
	if nil ~= list and list[id] then
		-- return list[id].effect
		return list[id]
	end
end
--开启建筑动作
function BuilderLayer:openBuildingAction(currPage, id)
	local list = self.builderList[currPage]
	if nil ~= list and list[id] then
		local s = 1.02 -- 放大系数
		-- local builder = list[id].effect
		list[id].bg:setVisible(true)
		-- local big = cc.ScaleTo:create(0.5, s)
		-- local small = cc.ScaleTo:create(0.2, 1)
		-- local size = builder:getBoundingBox()
		-- local w1, h1 = size.width * (s - 1) , size.height * (s - 1)
		-- local move1 = cc.MoveBy:create(0.5, cc.p(-w1/2, -h1/2))
		-- local move2 = cc.MoveBy:create(0.2, cc.p(w1/2, h1/2))
		-- local sp1 = cc.Spawn:create(big, move1)
		-- local sp2 = cc.Spawn:create(small, move2)
		-- builder:runAction(cc.Sequence:create(sp1, sp2))
	end
end
-- 在currPage页是否有id的建筑物
function BuilderLayer:hasBuilding(currPage, id)
	local building = self:getBuilding(currPage, id)
	if nil ~= building then
		return true
	end
	return false
end
-- 显示所有建筑物
function BuilderLayer:showAll()
	local prevPage = PageData.getPrevPage(self.currPage)
	self:showBuilding(prevPage, true)
	self:showBuilding(self.currPage, true)
	local nextPage = PageData.getNextPage(self.currPage)
	self:showBuilding(nextPage, true)
end
-- 转向index页面（已跳转）
function BuilderLayer:turnTo(index)
	local prevPage = self.currPage
	self.currPage = index
end
-- 跳转到pge页面
function BuilderLayer:jumpToPage(page)
	-- TimerMgr.killTimer(self.sid)
	TimerMgr.killTimer(self.rid)
	-- for i = 1, 8 do
	-- 	self:removePageView(i)
	-- end
	self.currPage = page
end

function BuilderLayer:setBuildingVisible(currPage, id, value)
	-- local list = self.builderList[currPage]
	-- if nil ~= list and list[id] then
	-- 	list[id]:setVisible(value)
	-- 	-- list[id].effect:setScale(0)
	-- end	
end

function BuilderLayer:dispose()
    self.addTime = 0
	TimerMgr.killTimer(self.async_id)
	TimerMgr.killTimer(self.aid)
	-- TimerMgr.killTimer(self.sid)
	TimerMgr.killTimer(self.rid)
	for i = 1, 8 do
		self:removePageView(i)
	end
	-- EventMgr.removeListener( EventType.UserBuildingUpdate, self.updateFun )
	EventMgr.removeList(self.event_list)
end
