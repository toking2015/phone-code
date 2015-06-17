-- Create By Live --
-- 建筑物类 --

BuilderView = class("BuilderView", function()
	return Node:create()
end)

function BuilderView:ctor()
	self.id = id
	self.data = nil
	self.page = 0
	self.isClick = false
	self.grow = nil
	self.bg = nil
end

function BuilderView:addGrow(bln)
	if true == bln then
		if nil == self.grow then
			local data = self.data
			self.grow = Sprite:create("image/mainPage/grow/" .. data.grow .. ".png")
			self.grow:setAnchorPoint(0, 0)
			self:addChild(self.grow)
			self.grow:setPosition(data.growX - PageInfo.radius, PageInfo.height - data.growY - self.grow:getContentSize().height - PageInfo.radius)
		end
	else
		if nil ~= self.grow then
            if self.grow:getParent() ~= nil then
				self.grow:removeFromParent()
			end
			self.grow = nil
		end
	end
end

function BuilderView:setData(data)
	local builder = self
	local id, building, currPage = data.value.id, data.value, data.page
	builder.id = id
	builder.data = building
	builder.page = currPage

	local posX, posY = building.nameX - PageInfo.radius, PageInfo.height - building.nameY - PageInfo.radius

	local bubbleList = PageData.getBubbleIcon()
	if nil ~= bubbleList[currPage .. "_" .. id] then
       local obj = bubbleList[currPage .. "_" .. id]
       local bp = cc.p(posX + obj.x, posY + obj.y)
       obj.icon:setPosition(bp)
       builder:addChild(obj.icon, 5)
	end

	if building.hasName == 1 then
		url = "image/mainPage/txtBg/" .. building.color .. ".png"
		local bg = ccui.ImageView:create(url, ccui.TextureResType.localType)
		local posX, posY = building.nameX - PageInfo.radius, PageInfo.height - building.nameY - PageInfo.radius
		bg:setPosition(posX, posY)
		builder:addChild(bg, 3)
		builder.bg = bg
        local isOpen = (data.isNotOpen == false)
		builder.bg:setVisible(isOpen)
		bg:setRotation((currPage - 1) * 45)

		local bg_size = bg:getContentSize()
		local txt = Sprite:create("image/mainPage/txt/" .. id .. ".png")
		txt:setPosition(bg_size.width / 2, bg_size.height / 2)
		bg:addChild(txt)

		self:addClickConfig()
	end
end

function BuilderView:addClickConfig()
	local function touchBegin()
        self:clickBuilderBegan()
	end
    local function touchEnded()
        self:clickBuilderEnded(true)
	end
	 local function touchCancel()
        self:clickBuilderEnded(false)
	end
    UIMgr.addTouchBegin(self.bg, touchBegin)
    UIMgr.addTouchEnded(self.bg, touchEnded)
    UIMgr.addTouchCancel(self.bg, touchCancel)
end
local testrankui = true 
Command.bind("open rankui",function() 
    testrankui = true 
end)
-- 通过建筑id，获取点击参数
local function getClickParams(id)
   
    local data = {id = id}
    if id == 1001 then
        data.type,data.ui,data.value = const.kBuildingTypePalace, "TempleUI"
    elseif id == 1002 then
        data.type, data.ui, data.value = const.kBuildingTypeTrainingGround, "EquipmentUI"
    elseif id == 1003 then 
        if testrankui == true then 
           data.type, data.ui, data.value = const.kBuildingTypeLegion, "RankUI"
        end 
    elseif id == 1004 then
        data.type, data.ui, data.value = const.kBuildingTypeAlter, "CardUI" 
    elseif id == 1005 then
        -- data.type, data.ui, data.value = const.kBuildingTypeWaterFactory, "HolySpeed", BubbleLayer.isBubble
        data.type, data.ui, data.value = const.kBuildingTypeWaterFactory, "HolyUI", BubbleLayer.isBubble
    elseif id == 1006 then
        -- data.type, data.ui, data.value = const.kBuildingTypeGoldField, "MineMessage", getMineData.isCoin
        data.type, data.ui, data.value = const.kBuildingTypeGoldField, "HolyUI", getMineData.isCoin
    elseif id == 1007 then
        data.type, data.ui, data.value = const.kBuildingTypeBlacksimith, "PaperSkillSelectUI"
        if PaperSkillData.getSkillId() > 0 then
            data.ui = "PaperCreateUI"
        end
    elseif id == 8001 then
        data.type, data.ui, data.value = const.kBuildingTypeJumping, "AuctionUI"
    elseif id == 8002 then
    	data.type, data.ui, data.value = const.kBuildingTypePVEBattle, "TombMainUI"
    elseif id == 8003 then
        data.type, data.ui, data.value = const.kBuildingTypePVPBattle, "TrialMainUI"
    elseif id == 8004 then
        data.type, data.ui, data.value = const.kBuildingTypeSingleArena, "ArenaUI"
    end
    return data
end

-- 建筑物被点击后执行的行为
function BuilderView:buildingTouchAction()
    local id = self.id
    -- if id == 10001 then return end
    local data = getClickParams(id)
    local buildingType, name, gValue = data.type, data.ui, data.value
    if gValue == nil then
        gValue = false
    end
    if gValue == false then
        if BuildingData.checkBuildingExist(buildingType) then
           if 8002 == id then
                -- TASK #7552::手游----【大墓地】开启条件限制
                local open_time, serv_time = gameData.getOpenTime(), gameData.getServerTime()
                local isOne = DateTools.isOneDayPass(serv_time, open_time) -- 判断是否隔天
                if not isOne then
                    TipsMgr.showError('开服第二天6点开启')
                    return
                end
            end
            if id == 8004 then 
            end
            if id == 1005 or id == 1006 then
            	EventMgr.dispatch(EventType.showBuildingInfoByType, data.type)
            else
            	PopMgr.popUpWindow(name, true, PopUpType.SPECIAL)
            end
        else
            TipsMgr.showError('该功能尚未开启')
            -- showMsgBox('[image=alert.png][font=ZH_3]  还没有生成建筑')
        end
    else
        if id == 1005 then
            Command.run('holy collect')
        elseif id == 1006 then
            Command.run("mine collect")
        end
    end
end
function BuilderView:clickBuilderBegan()
    -- self:doGrowBuilding(true)
    self:addGrow(true)
end
function BuilderView:clickBuilderEnded(isClick)
    -- self:doGrowBuilding(false)
    local id = self.id
    ActionMgr.save( 'UI', string.format('%s[%d] click [%s]', "BuilderView", id, "MainScene") )
    self:addGrow(false)
    if isClick == true then
        self:buildingTouchAction()
    end
end

function BuilderView:create(data)
	local builder = BuilderView:new()

	builder:setData(data)

	return builder
end