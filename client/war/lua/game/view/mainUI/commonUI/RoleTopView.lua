-- create by Hujingjiang --

local prevPath = "image/ui/MainUI/"

local function convertString(str)
    local match = {['0'] = '/',
        ['1'] = '0',
        ['2'] = '1',
        ['3'] = '2',
        ['4'] = '3',
        ['5'] = '4',
        ['6'] = '5',
        ['7'] = '6',
        ['8'] = '7',
        ['9'] = '8'
    }

    local dest = ''
    if '' == str or tonumber(str) < 0 then
        str = '0'
    end
    local len = string.len(str)
    for i = 1, len do
        local str1 = string.sub(str, i, i)
        local str2 = string.sub(str, i+1)
        if nil ~= str1 and '' ~= str1 then
            dest = dest .. match[str1]
        else
            dest = '0'
        end
    end

    return dest
end
local pervalue = 0
local addvalue = 0
local function createTopItem(view, name)
	local item = view[name]
	local txt_num = item.txt_num
	local btn_add = item.btn_add
	local img_w = item.img_w
	btn_add:setTouchEnabled(false)
   --weihao
    local goldkey = 1
    local arraylist = {}
    local function resetNumByData(num)
        if num == nil then num = 0 end
        img_w:setVisible(math.floor(num/1000000) ~= 0)
        if img_w:isVisible() == true then
            txt_num:setPositionX(img_w:getPositionX()-img_w:getSize().width - 1)
            txt_num:setString(math.floor(num/10000))
        else
            txt_num:setString(num)
            txt_num:setPositionX(img_w:getPositionX())
        end
    end 
    local function resetData(befornum,num)  
        if num == nil then num = 0 end
        img_w:setVisible(math.floor(num/1000000) ~= 0)
        if nil ~= pervalue and pervalue ~= 0 then           
            local sum = tonumber(txt_num:getString())  
            local step = 1
            local per = {}
            per[1] = pervalue + pervalue * 0.1
            per[2] = pervalue + pervalue * 0.5
            per[3] = pervalue + pervalue * 0.2 
            per[4] = pervalue + pervalue * 0.4
            per[5] = pervalue - pervalue * 0.2
            per[6] = pervalue - pervalue * 0.3
            per[7] = pervalue - pervalue * 0.4
            per[8] = pervalue - pervalue * 0.2
            per[9] = pervalue - pervalue * 0.1
            for i = 1 ,9 ,1 do
                local call = cc.CallFunc:create(function() 
                     local number = befornum + per[i] 
                     resetNumByData(math.floor(number))
                end )
                local delay = cc.DelayTime:create(0.05)
                arraylist[step] = call
                step = step + 1 
                arraylist[step] = delay
                step = step + 1
            end 
            local call10 = cc.CallFunc:create(function() 
                resetNumByData(num)
            end )
            arraylist[step] = call10
            txt_num:runAction(cc.Sequence:create(arraylist))
        else 
            if img_w:isVisible() == true then
                txt_num:setPositionX(img_w:getPositionX()-img_w:getSize().width - 1)
                txt_num:setString(math.floor(num/10000))
            else
                txt_num:setString(num)
                txt_num:setPositionX(img_w:getPositionX())
            end
        end
    end
	function item:setNum(value)
        if value == nil then value = 0 end

	    if name ~= "con_strength" then    
            if name == "con_solution" then
                if item.value == nil then 
                    resetNumByData(value)
                else 
                    pervalue = (value - item.value)/10 
                    resetData(item.value,value) 
--                    resetNumByData(value)
                end 
                item.value = value             
            elseif name == "con_gold" then 
                if item.value == nil then 
                    resetNumByData(value)
                else 
                    pervalue = (value - item.value)/10 
                    resetData(item.value,value) 
--                    resetNumByData(value)
                end 
                item.value = value 

            else 
                resetNumByData(value)
            end 
--            resetNumByData(value)
	    else
	    	local str = string.split(value, "/")
	    	local txt_num0 = item.txt_num_0
            local txt_num1 = item.txt_num_1
            txt_num0:setString(convertString(str[1]))
            txt_num1:setString(convertString(str[1]))
            txt_num:setString("9" .. convertString(str[2]))
	    	txt_num0:setPositionX(txt_num:getPositionX()-txt_num:getSize().width-1)
            txt_num1:setPositionX(txt_num:getPositionX()-txt_num:getSize().width-1)
	    end
	    -- 目前只对体力的数值改变颜色
	    if name == "con_strength" then
	    	item:setItemColor(value)
	    end
	end

	function item:setItemColor(value)
	    -- local val = txt_num:getString()
	    if name ~= "con_strength" then
		    local num = tonumber(value)
		    if num < 100000 then
	            txt_num:setColor(cc.c3b(255, 255, 255))
		    elseif num >= 100000 and num < 1000000 then
	            txt_num:setColor(cc.c3b(0, 255, 0))
		    elseif num >= 1000000 and num < 10000000 then
	            txt_num:setColor(cc.c3b(0, 0, 255))
		    else
	            txt_num:setColor(cc.c3b(128, 0, 128))
		    end
		else
            local str = string.split(value, "/")
			local txt_num0 = item.txt_num_0
			local txt_num1 = item.txt_num_1
            local num2 = tonumber(str[2])
            local num1 = tonumber(str[1])
			if num1 >= num2 then
				txt_num0:setVisible(false)
				txt_num1:setVisible(true)
			else
				txt_num0:setVisible(true)
				txt_num1:setVisible(false)
			end
		end
	end
	function item:addCallback(callback)
        if name == "con_strength" then
            createScaleButton(item.btn_add)
            item.btn_add:addTouchEnded(callback)
        else
		    createScaleButton(item)
            item:addTouchEnded(callback)
        end
	end
	return item
end

-- 初始化 [主界面]顶部
RoleTopView = class("RoleTopView", function()
	return getLayout(prevPath .. "RoleTopView.ExportJson")
end)

function RoleTopView:ctor()
	-- 创建对象
	createTopItem(self, "con_strength")
	createTopItem(self, "con_gold")
	createTopItem(self, "con_solution")
	createTopItem(self, "con_diamond")

    local function updateTopView()
        local topView = {self.con_strength, self.con_gold, self.con_solution, self.con_diamond}
        if false == PopMgr.hasWindowOpen() then
            for _, v in pairs(topView) do
                v.btn_add:setVisible(true)
                v:setTouchEnabled(true)
            end
        else
            for _, v in pairs(topView) do
                v.btn_add:setVisible(false)
                v:setTouchEnabled(false)
            end
        end
    end
    EventMgr.addListener(EventType.ShowWindow, updateTopView)
    EventMgr.addListener(EventType.CloseWindow, updateTopView)
end

function RoleTopView:configureEventList()
    self.event_list = {}
    self.event_list[EventType.UserCoinUpdate] = function(data) 
        if data.coin.cate == const.kCoinMoney or data.coin.cate == const.kCoinGold or 
            data.coin.cate == const.kCoinStrength or data.coin.cate == const.kCoinWater then
            self:updateData()
        end
    end
    EventMgr.addList(self.event_list)
end

function RoleTopView:create()
	local ui = RoleTopView.new()

	ui:init()
	ui:updateData()

	return ui
end

--初始化对象显示
function RoleTopView:updateData()
	local team_level = gameData.getSimpleDataByKey("team_level")
    if team_level == nil then team_level = 0 end
    
	if team_level >= 90 then
		-- 目前暫定戰隊等級為90
		team_level = 90
	end
	local levelData = findLevel(team_level)
--	self.con_strength:setNum(convertString(gameData.getSimpleDataByKey("strength")).."9"..convertString(levelData.strength))
   
    self.con_strength:setNum(gameData.getSimpleDataByKey("strength").."/"..levelData.strength)
	self.con_gold:setNum(CoinData.getCoinByCate(const.kCoinMoney))
	self.con_solution:setNum(CoinData.getCoinByCate(const.kCoinWater))
	self.con_diamond:setNum(CoinData.getCoinByCate(const.kCoinGold))

end

function RoleTopView:init()
    -- createScaleButton(self.con_strength.btn_add)
	local function showStrengthUI()
        ActionMgr.save( 'UI', 'StrengthUI click con_strength.btn_add' )
        LogMgr.debug("购买体力")
        buyStrength( )
	end
	-- UIMgr.addTouchEnded(self.con_strength.btn_add, showStrengthUI)
    self.con_strength:addCallback(showStrengthUI)

    createScaleButton(self.con_strength.img_bg, false)
    local tid = nil
    local function showTips(sender, event)
        ActionMgr.save( 'UI', 'StrengthUI showTips click con_strength.img_bg' )
        if event == ccui.TouchEventType.began then
            local cost = StrengthData.getCurrCostTime() -- 当前恢复一点体力已消耗时间
            -- local few = StrengthData.getFewStrengthTime(cost)
            -- local all = StrengthData.getAllStrengthTime(cost)
            local info = StrengthData.getStrengthTips(cost)
            local pos = sender:getTouchStartPos()
            -- local pos = cc.p(visibleSize.width/2, visibleSize.height - 100)
            TipsMgr.showTips(pos, TipsMgr.TYPE_STRING, info)

            local function updateTips()
                local tips = TipsMgr.getCurrTips()
                if nil ~= tips then
                    cost = cost + 1
                    -- few = few - 1
                    -- all = all - 1
                    local data = StrengthData.getStrengthTips(cost)
                    -- LogMgr.debug("时间更新，cost = " .. cost, "data = " .. data)
                    tips:setData(data)
                end
            end
            if false == StrengthData.isStrengthFull() then
                tid = TimerMgr.startTimer(updateTips, 1)
            end
        else
            if tid ~= nil then
                LogMgr.debug("<<<<<<<停止时间更新定时器>>>>>>")
                TimerMgr.killTimer(tid)
                tid = nil
            end
        end
    end
    self.con_strength.img_bg:addTouchEventListener(showTips)
	
	local function showHolySpeedup()
        ActionMgr.save( 'UI', 'HolySpeedStyle click con_solution' )
        local zdlevel = gameData.getSimpleDataByKey("team_level")
        if zdlevel < 20 then 
            -- 这里写战斗等级限制
            TipsMgr.showError('战队20级开放')  
        elseif BuildingData.checkBuildingExist(const.kBuildingTypeWaterFactory) then
            -- Command.run( 'ui show', 'HolySpeedStyle', PopUpType.SPECIAL )
            EventMgr.dispatch(EventType.showSpeedStyle, 6)
        else
            TipsMgr.showError('该功能尚未开启')    
        end
	end
	self.con_solution:addCallback(showHolySpeedup)

    local function showMineTest()
        ActionMgr.save( 'UI', 'MineUpSpeed click con_gold' )
    	local zdlevel = gameData.getSimpleDataByKey("team_level")
        if zdlevel < 20 then 
            -- 这里写战斗等级限制
            TipsMgr.showError('战队20级开放') 
    	--是否点击加速
    	elseif (BuildingData.getDataByType(const.kBuildingTypeGoldField)) then
    	    -- Command.run( 'ui show', 'MineUpSpeed', PopUpType.SPECIAL )
            EventMgr.dispatch(EventType.showSpeedStyle, 2)
    	else 
    		TipsMgr.showError('该功能尚未开启')   
    	end 
    end
    self.con_gold:addCallback(showMineTest)

    local function addDiamond() -- 增加钻石按钮
        ActionMgr.save( 'UI', 'VipPayUI click con_diamond' )
    	Command.run( 'ui show', 'VipPayUI', PopUpType.SPECIAL)
    end
    self.con_diamond:addCallback(addDiamond)
end

function RoleTopView:onlyShow(name)
	self.con_strength:setVisible(false)
	self.con_gold:setVisible(false)
	self.con_solution:setVisible(false)
	self.con_diamond:setVisible(false)

	self:getItem(name):setVisible(true)
    self:saveLastStatus()
end
function RoleTopView:showAllExcept(name)
	self.con_strength:setVisible(true)
	self.con_gold:setVisible(true)
	self.con_solution:setVisible(true)
	self.con_diamond:setVisible(true)

	self:getItem(name):setVisible(false)
    self:saveLastStatus()
end
function RoleTopView:showAll()
    self.con_strength:setVisible(true)
    self.con_gold:setVisible(true)
    self.con_solution:setVisible(true)
    self.con_diamond:setVisible(true)
    self:saveLastStatus()
end
function RoleTopView:onlyShowStrength()
	self:onlyShow("con_strength")
end
function RoleTopView:showAllExceptStrength()
	self:showAllExcept("con_strength")
end

function RoleTopView:saveLastStatus()
    self.oldShowStatus = {}
    self.oldShowStatus[self.con_strength] = self.con_strength:isVisible()
    self.oldShowStatus[self.con_gold] = self.con_gold:isVisible()
    self.oldShowStatus[self.con_solution] = self.con_solution:isVisible()
    self.oldShowStatus[self.con_diamond] = self.con_diamond:isVisible()
end

function RoleTopView:resetShow() 
    if not self.oldShowStatus then
        self:saveLastStatus()
    end
	self.con_strength:setVisible(true)
	self.con_gold:setVisible(true)
	self.con_solution:setVisible(true)
	self.con_diamond:setVisible(true)
end

function RoleTopView:showLastStatus()
    if self.oldShowStatus then
        for k,v in pairs(self.oldShowStatus) do
            k:setVisible(v)
        end
        self.oldShowStatus = nil
    end
end

function RoleTopView:setValue(name, value)
	local item = self:getItem(name)
	if nil ~=  item then
		local team_level = gameData.getSimpleDataByKey("team_level")
		if team_level >= MainScene.MaxTeamLevel then
			-- 暫定戰隊等級為90
			team_level = MainScene.MaxTeamLevel
		end
		local levelData = findLevel(team_level)
--		item:setNum(convertString(value).."9"..convertString(levelData.strength))
        item:setNum(value.."/"..levelData.strength)
	end
end

function RoleTopView:reduceValue(name, value)
	local atl_reduce = ccui.TextAtlas:create("/" .. value, prevPath .. "reduce_num.png", 20, 25, "/")
	local item = self:getItem(name)
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    layer:addChild(atl_reduce)

	local tmp = item.txt_num
	if name ~= "con_strength" then
		tmp = item.txt_num_1
	end

    --不明白上面那个判断的意思，事实：con_solution时，item.txt_num(谭)
    if name == "con_solution" then
        tmp = item.txt_num
    end

	local px, py = tmp:getPositionX(), tmp:getPositionY()
    local pos = cc.p(px - tmp:getSize().width - 10, py - 20)
    pos = tmp:getParent():convertToWorldSpace(pos)
	atl_reduce:setPosition(pos)
    local jumpBy = cc.JumpBy:create(1, cc.p(0, 0), -40, 1)
    local delay = cc.DelayTime:create(0.5)
    local fadeOut = cc.FadeOut:create(0.5)
    local seq = cc.Sequence:create(delay, fadeOut)
    local spawn = cc.Spawn:create(jumpBy, seq)
	atl_reduce:runAction(cc.Sequence:create(spawn, cc.RemoveSelf:create()))
end

function RoleTopView:getItem(iconName)
    return self[iconName]
end

function RoleTopView:getIconView(iconName)
    local item = self:getItem(iconName)
    return item and item.img_icon
end

function RoleTopView:showIconScale(iconName)
    local item = self:getItem(iconName)
    if item then
        local icon = item.img_icon
        showScaleEffect(icon)
    end
end
