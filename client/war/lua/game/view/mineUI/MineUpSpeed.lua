-- 加速界面 选择一次加速或连续加速
--by weihao
require "lua/game/view/mineUI/GetMineData.lua"
local prePath = "image/ui/MineUI/GritUp/"
local prePath1 = "image/ui/MineUI/Critplay_1/"

local url = prePath .. "GritUpConfirm.ExportJson"
MineUpSpeed = createUIClass("MineUpSpeed", url)

--MineUpSpeed = class("MineUpSpeed", function()
--    return getPanel(prePath .. "GritUpConfirm.ExportJson", PopWayMgr.SMALLTOBIG, 'MineUpSpeed')
--end)

MineUpSpeed.UpOnebnt = nil --加速一次按钮
MineUpSpeed.UpTenbnt = nil --加速十次按钮
MineUpSpeed.mineLevel = nil --金矿等级
MineUpSpeed.upOneMoneyLabel = nil --加速一次至少得到得金钱
MineUpSpeed.upTenMoneyLabel = nil --加速十次至少得到得金钱
MineUpSpeed.upOneNeedLabel = nil --加速一次需要得钻石
MineUpSpeed.upTenNeedLabel = nil --加速十次需要得钻石
MineUpSpeed.baojiPanel = nil --暴击Panel
MineUpSpeed.jinbiPanel = nil --金币Panel
MineUpSpeed.baojiLabel = nil --暴击label
MineUpSpeed.jinbiLabel = nil --金币label
MineUpSpeed.speedupword = nil --加速类型文字

local curTimes = 1    --现在加速的次数   
local UpOnekey = 1    --一次加速的key
local UpTenkey = 2    --十次加速的key
local timesCount = 11  --最大的加速次数
local upBuildingLevel = 11  --建筑最高等级
MineUpSpeed.critTimesList = nil  --暴击列表
local baojinumber = 1      --暴击倍数
MineUpSpeed.sumMoney = 1         --获得钱数
MineUpSpeed.upspeed = 1      --加速单位
MineUpSpeed.isTenSpeed = false  --是否进行连续加速 

local isUICenter = true


local function confirmHandler( )
    Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
end

-- 建筑随加速次数消耗的钻石数
local function consumeDiamond(times)
	if findBuildingCost(times) == nil then 
       return 0
	end 
    return tonumber( findBuildingCost(times).cost2.val )

end

-- 获取mine的数量
local function obtainMine(times)
	if findBuildingCoin(2) == nil then
       return 0
	end 
	
    local count  = findBuildingCoin(2).value[getMineData.buildingLevel].val
    return tonumber( findBuildingCoin(2).value[getMineData.buildingLevel].val)
end
--加速最大多少次
local function maxTimes()
    local levelid = gameData.user.simple.vip_level
    local times = findLevel(levelid).building_gold_times
    if times == nil and levelid > 20 then 
        times = findLevel(20).building_gold_times
    end  
    return times
end 

--获取加速过多少次
local function obtainSpeedTimes()
    
	if VarData.getVarData().building_goldfiel_speed_time == nil then
        VarData.getVarData().building_goldfiel_speed_time = {} 
        VarData.getVarData().building_goldfiel_speed_time.value = 0
        return 0
	end 
    return VarData.getVarData().building_goldfiel_speed_time.value
end

--展示自己
local function showMineStype(data)
--    LogMgr.debug("gamexuweihao")
--    Command.run( 'ui hide', "MineMessage" )
    -- EventMgr.removeListener(EventType.showMineStype, showMineStype)
    isUICenter = data.isCenter
    PopMgr.popUpWindow("MineUpSpeed", false, PopUpType.SPECIAL)
    -- Command.run('ui show', 'MineUpSpeed', PopUpType.SPECIAL )
end

function MineUpSpeed:ctor()
    self:initData()
    self.canSpeedup = true

end


--以变量保存动态组建
function  MineUpSpeed:initData()
    self.UpOnebnt = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg1.GritUpConfirm_jiasuyicibnt
    self.UpTenbnt = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2.GritUpConfirm_jiasushicibnt
    self.UpOnebnt = createScaleButton(self.UpOnebnt)
    self.UpTenbnt = createScaleButton(self.UpTenbnt)
    self.upOneMoneyLabel = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg1.GritUpConfirm_huodebg.GritUpConfirm_huodeLabel
    self.upTenMoneyLabel = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2.GritUpConfirm_huodebg.GritUpConfirm_huodeLabel
    self.upOneNeedLabel = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg1.GritUpConfirm_diamondXLabel
    self.upTenNeedLabel = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2.GritUpConfirm_diamondXLabel
    self.mineLevel = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_levelbg.GritUpConfirm_levelLabel
    self. baojiPanel = self.GritUpConfirm_bg.baojiPanel
    self.jinbiPanel = self.GritUpConfirm_bg.jinbiPanel
    self.baojiLabel = self.GritUpConfirm_bg.baojiPanel.baojinumber
    self.jinbiLabel = self.GritUpConfirm_bg.jinbiPanel.jinbinumber
    self.speedupword = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_biaozhibg.GritUpConfirm_biaozhiLabel
    --加速十次label
    self.uptenlabel = self.UpTenbnt.GritUpConfirm_jiasushicipicture
    --以初始化ui以及做好各监听
    self.initUI = function()
        if self.mineLevel ~= nil then 
            getMineData.getBuildingData()
            local time = obtainSpeedTimes()+1
            if time >= 200 then 
                time = 200
            end 
            MineUpSpeed.upspeed = obtainMine(time)
            self.mineLevel:setString("LV."..getMineData.buildingLevel)
            self.upOneMoneyLabel:setString(''..obtainMine(time))
            self.upTenMoneyLabel:setString(''..(tonumber(obtainMine(time))*10))
            self.upOneNeedLabel:setString('X'..consumeDiamond(time))
            self.upTenNeedLabel:setString('X'..(consumeDiamond(time)))
            
            self:showOpenCondition()
        end

    end
    EventMgr.addListener( EventType.UserVarUpdate ,self.initUI) 
end

function MineUpSpeed:showOpenCondition()
   -- 连续加速开发条件
    self.tenBg = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2
    self.tenExpend = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2.GritUpConfirm_xiaohao
    self.tenDia = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2.GritUpConfirm_diamond
    self.tenDiaNum = self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2.GritUpConfirm_diamondXLabel
    local posX = self.UpTenbnt:getPositionX()
    local txt = UIFactory.getText('VIP2开启', self.tenBg, posX+80, 63, 22, cc.c3b(0xff, 0x00, 0x00))
    local vip_level = gameData.getSimpleDataByKey('vip_level')
    if vip_level < 2 then
        txt:setVisible(true)
        self.UpTenbnt:setVisible(false)
        self.tenExpend:setVisible(false)
        self.tenDia:setVisible(false)
        self.tenDiaNum:setVisible(false)
    else
        txt:setVisible(false)
        self.UpTenbnt:setVisible(true)
        self.tenExpend:setVisible(true)
        self.tenDia:setVisible(true)
        self.tenDiaNum:setVisible(true)
    end
end


--初始化 button 以及做好监听
function  MineUpSpeed:initButton()

    --加速一次表现
    self.UpOne = function( data )
        self.canSpeedup = true
        MineUpSpeed.critTimesList = {}
        MineUpSpeed.critTimesList = data.list_crit_times
        MineUpSpeed.sumMoney = data.add_value
        self.baojiLabel:setString('' .. MineUpSpeed.critTimesList[1])
        self.jinbiLabel:setString('' .. MineUpSpeed.sumMoney)
        self.baojiPanel:setVisible(true)
        if MineUpSpeed.critTimesList[1] == 1 then 
            self.baojiPanel:setVisible(false)
        end 

        local move = cc.MoveBy:create(1,cc.p(0,60))
        local sq = cc.Sequence:create(move,cc.CallFunc:create(function() self.baojiPanel:setVisible(false) end), move:reverse())
        self.baojiPanel:runAction(sq)
        local delay = cc.DelayTime:create(0.2)
        local move1 = cc.MoveBy:create(1,cc.p(0,50))
        local sq1 = cc.Sequence:create(delay,cc.CallFunc:create(function() self.jinbiPanel:setVisible(true)  end),
            move1 ,cc.CallFunc:create(function() self.jinbiPanel:setVisible(false)  end), move1:reverse())
        self.jinbiPanel:runAction(sq1)
        self.initUI()
    end

    self.UpTen = function(data)
        self.canSpeedup = true
        LogMgr.log( 'debug',"ininininnnnnnininin")
        MineUpSpeed.critTimesList = data.list_crit_times
        MineUpSpeed.sumMoney = data.add_value
        MineUpSpeed.isTenSpeed = true 
        EventMgr.dispatch(EventType.showMineUpShow, {type = "show"})
        self.initUI()
    end
    --点击加速回调处理
    local function  isUpSpeed(sender, eventType)
        if self.canSpeedup == false then
            return
        end
        self.canSpeedup = false
        ActionMgr.save( 'UI', 'MineUpSpeed click isUpSpeed')
        timesCount = maxTimes()
        if sender:getTag() == UpOnekey then
            curTimes = obtainSpeedTimes()
            LogMgr.log( 'debug',"++++++++curTimes:"..curTimes)
            if curTimes >= timesCount then
                TipsMgr.showError('超过最大加速次数')
                return 
            end
            local cost = consumeDiamond(curTimes + 1)
            LogMgr.log( 'debug',"+++++++++cost"..cost)
            local dim = CoinData.getCoinByCate(const.kCoinGold)
            if dim < cost then
                local str = "[image=diamond.png][font=ZH_3]  钻石不足[btn=two]cancel.png:recharge.png"
                showMsgBox(str, confirmHandler)
                return
            end
            if getMineData.buildingLevel < 0 or getMineData.buildingLevel > upBuildingLevel then
                TipsMgr.showError('建筑等级错误')
                return
            end

            Command.run('building output', const.kBuildingTypeGoldField, 1) 
            EventMgr.addListener(EventType.BuildingCritUpdate, self.UpOne)
        elseif sender:getTag() == UpTenkey then 
            local vip_level = gameData.getSimpleDataByKey('vip_level')
            if vip_level < 2 then 
               return 
            end 
            curTimes = obtainSpeedTimes()
            if curTimes >= timesCount then
                TipsMgr.showError('超过最大加速次数')
                return 
            end
            local cost = consumeDiamond(curTimes + 1)
            local dim = CoinData.getCoinByCate(const.kCoinGold)
            if dim  < cost  then
                local str = "[image=diamond.png][font=ZH_3]  钻石不足[btn=two]cancel.png:recharge.png"
                showMsgBox(str, confirmHandler)
                return
            end
            if getMineData.buildingLevel < 0 or getMineData.buildingLevel > upBuildingLevel then
                TipsMgr.showError('建筑等级错误')
                return
            end
            Command.run('building output', const.kBuildingTypeGoldField, 10) 
            EventMgr.addListener(EventType.BuildingCritUpdate, self.UpTen)
        end

    end
    
    self.UpOnebnt:setTag(UpOnekey)
    self.UpTenbnt:setTag(UpTenkey)
    self.UpOnebnt:addTouchEnded(isUpSpeed)
    self.UpTenbnt:addTouchEnded(isUpSpeed)
end


function MineUpSpeed:delayInit()
    self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg1:loadTexture(prePath .. "GritUpSpeed_onebg.png",ccui.TextureResType.localType)
    self.GritUpConfirm_bg.GritUpConfirm_bg2.GritUpConfirm_bg3.GritUpConfirm_upspeedbg2:loadTexture(prePath .. "GritUpSpeed_uptenbg.png",ccui.TextureResType.localType)
end 

function MineUpSpeed:onShow ( )
    -- if self.isSpeed == true then 
    --     self.isSpeed=false 
    --     self:setPosition(cc.p(visibleSize.width/2-6, (visibleSize.height-self:getSize().width)/2))
    -- end 
    self.initUI()
    self:initButton()
    
    self:styleShow()

end

function MineUpSpeed:onClose()
    EventMgr.removeListener( EventType.UserVarUpdate ,self.initUI) 
    EventMgr.removeListener(EventType.BuildingCritUpdate, self.UpOne)
    EventMgr.removeListener(EventType.BuildingCritUpdate, self.UpTen)
end


function MineUpSpeed:backHandler()
    self:styleClose()
end

function MineUpSpeed:styleShow()
    self:setVisible(true)
        local midX, midY = visibleSize.width/2, visibleSize.height/2
        local winSize = self:getSize()
        if false == self:isCascadeOpacityEnabled() then
            self:setCascadeOpacityEnabled(true)
        end
        setUiOpacity(self, 45)
        self:setAnchorPoint(cc.p(0.5, 0.5))

        local mAction = nil
        local sAction = nil
        local scaleBack = nil
        if false == isUICenter then
            self:setPosition(cc.p(midX+winSize.width*0.5-3, midY))
            sAction = cc.ScaleTo:create(0.1, 1.05)
            scaleBack = cc.ScaleTo:create(0.08, 1)
            setUIFade(self, cc.FadeIn, 0.18)
        else
            self:setPosition(cc.p(midX, midY))
            sAction = cc.ScaleTo:create(0.1, 1.05)
            scaleBack = cc.ScaleTo:create(0.08, 1)
            setUIFade(self, cc.FadeIn, 0.18)
        end

        local function showUiPanelFunc()
            PopMgr.setUiAminal(false)
        end
        local animFunc = cc.CallFunc:create(showUiPanelFunc)
        local action = cc.Sequence:create(sAction, scaleBack, animFunc)

        self:runAction(action)
end

function MineUpSpeed:styleClose()
    local midX, midY = visibleSize.width/2, visibleSize.height/2
        local winSize = self:getSize()

        local sAction = cc.ScaleTo:create(0.14, 1.05)
        -- local mAction = nil
        if false == isUICenter then
            isUICenter = true
            setUIFade(self, cc.FadeOut, 0.14)
        else
            setUIFade(self, cc.FadeOut, 0.14)
        end

        local function showUiPanelFunc()
            PopMgr.removeWindow(self)
        end
        local animFunc = cc.CallFunc:create(showUiPanelFunc)
        local action = cc.Sequence:create(sAction, animFunc)

        self:runAction(action)

        EventMgr.dispatch( EventType.MineBuildingSet )
end

EventMgr.addListener(EventType.showMineStype, showMineStype)
