-- create by Hujingjiang --

local prevPath = "image/ui/MainUI/"
local isExpose = -1
local ui = nil
RoleBottomView = {}
local bottomMove = false

-- 初始化 [主界面]下边按钮
RoleBottomView = class("RoleBottomView", function()
	return getLayout(prevPath .. "RoleBottomView.ExportJson")
end)

function RoleBottomView:ctor()
	self.buttonList = { self.con_bottom.btn_totem, self.con_bottom.btn_hero, self.con_bottom.btn_bag, self.con_bottom.btn_shop }
	for _, v in pairs(self.buttonList) do
		createScaleButton(v)
	end
	self.tid, self.hid, self.bid, self.sid = nil, nil, nil, nil
	bottomMove = false
	local function updateRedPoint()
		if self:getParent() then
			self:updateBottomData()
		end
	end
	local function scriptHandler(event)
		if event == "enter" then
			if not self.red_timer_id then
				self.red_timer_id = TimerMgr.startTimer(updateRedPoint, 1)
			end
		elseif event == "exit" then
			self.red_timer_id = TimerMgr.killTimer(self.red_timer_id)
		end
	end
	self:registerScriptHandler(scriptHandler)
end

--获取按钮
function RoleBottomView:getButtonByName(name)
	return self.con_bottom[name]
end

function RoleBottomView:create()
	ui = RoleBottomView.new()
    local posX = ui.con_bottom:getPositionX()

	local function showBagHandler(ref, eventType)
        ActionMgr.save( 'UI', 'BagMain click con_bottom.btn_bag' )
	 	Command.run("ui show", "BagMain", PopUpType.SPECIAL)
        -- SoldierData.soldierGetUI(nil,10202)
	 	-- GuideUI:show( ui.con_bottom.btn_bag )
	end
	ui.con_bottom.btn_bag:addTouchEnded(showBagHandler)

	local function showHeroHandler(ref, eventType)
        ActionMgr.save( 'UI', 'SoldierUI click con_bottom.btn_hero' )
		Command.run("ui show", "SoldierUI", PopUpType.SPECIAL)
		-- GuideUI:hide()
	end
	
	ui.con_bottom.btn_hero:addTouchEnded(showHeroHandler)

	local function showPlayHandler(ref, eventType)
		--战斗系统专用测试开关，请勿删除	[涛--2014.12.23.]
        if FightDataMgr.self then
        	if FightDataMgr.first then
				FightDataMgr:fightEnter()
			else
				Command.run("scene enter", "test")
			end
            return
        end

        if false == bottomMove then
        	bottomMove = true
	        local rotate = cc.RotateBy:create(0.3, 180)
	        ref:runAction(rotate)

	        isExpose = isExpose * (-1)
	        local size = (ui:getSize().width + 20) * isExpose
	        -- for _, v in pairs(self.buttonList) do
	        -- 	v:runAction(cc.MoveBy:create(0.3, cc.p(size, 0)))
	        -- end
	        local posX = ui.con_bottom:getPositionX() + size
	        local posY = ui.con_bottom:getPositionY()
	        local move = cc.MoveBy:create(0.3, cc.p(size, 0))
	        local callback = cc.CallFunc:create(function() bottomMove = false end)
	        local sq = cc.Sequence:create(move, callback)
	        ui.con_bottom:runAction(sq)
	    end
	    local function onNodeEvent(event)
			if "exit" == event then
				local x = ui.con_bottom:getPositionX()
				if x ~= posX then
					bottomMove = false
		        	local size = (ui:getSize().width + 20) * isExpose
					ui.con_bottom:setPositionX(posX + size)
					ref:setRotation(0)
				end
			elseif "enter" == event then
			end
		end
	    ui.con_bottom:registerScriptHandler(onNodeEvent)
	end
    UIMgr.addTouchEnded( ui.btn_play, showPlayHandler )
    
    local function showShopHandler()
        ActionMgr.save( 'UI', 'Store click con_bottom.btn_shop' )
    	--战斗系统专用测试开关，请勿删除	[涛--2014.12.23.]
        if FightDataMgr.self then
        	if FightDataMgr.first then
				FightDataMgr:fightEnter()
			else
				Command.run("scene enter", "test")
			end
            return
        end
    	
    	local teamLevel = gameData.getSimpleDataByKey("team_level")
		if teamLevel >= 10 then
    		Command.run("ui show", "Store", PopUpType.SPECIAL)
    	else
    		TipsMgr.showError('战队10级开启')
    	end
	end
    ui.con_bottom.btn_shop:addTouchEnded(showShopHandler)
	
	local function showTotemHandler()
        ActionMgr.save( 'UI', 'TotemUI click con_bottom.btn_totem' )
		if TotemData.isTotemOpen(true) then
    		Command.run("ui show", "TotemUI", PopUpType.SPECIAL)
    	end
    end
    ui.con_bottom.btn_totem:addTouchEnded(showTotemHandler)

    ui:updateBottomData()
	return ui
end

function RoleBottomView:OpenButtonList()
    if isExpose == 1 then
    	isExpose = isExpose * (-1)
    	local size = ui:getSize().width * isExpose
        for _, v in ipairs(self.buttonList) do
        	v:setPositionX( v:getPositionX() + size )
        end
    end
end

--刷新红点
function RoleBottomView:updateBottomData()
	self:updateHeroData()
	self:updateTotemData()
    self:updateShopData()
    self:updateBagData()
end

function RoleBottomView:updateShopData()
    local off = cc.p(self.con_bottom.btn_shop:getSize().width-21, self.con_bottom.btn_shop:getSize().height-16)
    setButtonPoint( self.con_bottom.btn_shop , StoreData.getStoreRedPoint(), off )
end 

function RoleBottomView:updateHeroData()
	local off = cc.p(self.con_bottom.btn_hero:getSize().width-21, self.con_bottom.btn_hero:getSize().height-16)
	setButtonPoint( self.con_bottom.btn_hero, SoldierData.checkSoldierRedPoint(), off )
end

function RoleBottomView:updateTotemData()
	local off = cc.p(self.con_bottom.btn_totem:getSize().width-21, self.con_bottom.btn_totem:getSize().height-16)
	setButtonPoint( self.con_bottom.btn_totem, TotemData.checkBottomRedPoint(), off )
end

function RoleBottomView:updateBagData()
	local off = cc.p(self.con_bottom.btn_bag:getSize().width-21, self.con_bottom.btn_bag:getSize().height-16)
	setButtonPoint( self.con_bottom.btn_bag, ItemData:checkBagPackage(), off )
end
