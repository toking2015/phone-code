--连续加速弹出得界面，展示出来
--by weihao 

local prePath = "image/ui/MineUI/GritUp/"

local url = prePath .. "GritUpCalculator.ExportJson"
MineUpShow = createUIClass("MineUpShow", url, PopWayMgr.SMALLTOBIG)

--MineUpShow = class("MineUpShow", function()
--     return getPanel(prePath .. "GritUpCalculator.ExportJson", PopWayMgr.SMALLTOBIG, 'MineUpShow')
--end)

MineUpShow.surebtn = nil --确定按钮
MineUpShow.scrollview = nil --滚动层
MineUpShow.slider = nil --滑动条
MineUpShow.moneylabel = nil --获得多少金子
MineUpShow.baojibeishu = nil --暴击倍数(X2)
MineUpShow.coin = nil    --金币 
MineUpShow.allmoneylabel = nil --总获得金钱
MineUpShow.allmoneycoin = nil --总获得钱的金币


local delay = 0.5   --延迟时间
local time = 1    --进来更新数据次数
local updatekey = 0 --定时器的key
local pass = 0      --经过多少时间
local presstime = 0  --是否为touch
local touchflag = 0 --是否点击
local calculend = false --计数是否结束

--展示自己，并点击别处不会反弹ui
local function showMineUp()  
    PopMgr.popUpWindow("MineUpShow", false, PopUpType.MODEL)
end

--点击监听
local function TouchBgLister()
    if touchflag == 0 then 
        touchflag = 1 
    else
        touchflag = 2 
    end 

end

function MineUpShow:ctor()
    self:setPositionX(visibleSize.width/2 - (self:getSize().width/2))
    self:initData()
end

--展示数据
function MineUpShow:lineShow()
    LogMgr.log( 'debug',"time "..time )

    --确定按钮
    self.isSure = function()
        ActionMgr.save( 'UI', 'MineUpShow click isSure')
        PopMgr.removeWindow(self)
    end

    if MineUpSpeed.critTimesList[time] == nil then 
       LogMgr.log( 'debug',"time nil " .. time )
    end 
    if MineUpSpeed.critTimesList[time] ~= nil then 
       
        local baojinum = MineUpSpeed.critTimesList[time] * MineUpSpeed.upspeed
        --钱数
        self.moneylabel[time]:setString(baojinum)
        self.moneylabel[time]:setVisible(true)

        --暴击
        if  MineUpSpeed.critTimesList[time] > 1 then 
            self.baojibeishu[time]:setString("暴击 X"..MineUpSpeed.critTimesList[time])

            self.baojibeishu[time]:setVisible(true)
        end 

        
        self.coin[time]:setVisible(true)
        if time ~= 10 then 
            self.scrollview["line_" .. time ]:setVisible(true)
        end 
        
        if time >= 3 then 
            self.scrollview:scrollToPercentVertical(time*10,0.1,false)
        end 
        time = time + 1
        if time > 10 then 
            self.allmoneylabel:setString(MineUpSpeed.sumMoney)
            self.allmoneylabel:setVisible(true)
            self.allmoneycoin:setVisible(true)
            createScaleButton(self.GritUpCalculator_allbg.GritUpCalculator_sure)
            self.surebtn:setVisible(true)
            self.surebtn:addTouchEnded(self.isSure)
            time = 1
            calculend = true 
        end 
    else 
        self.allmoneylabel:setString(MineUpSpeed.sumMoney)
        self.allmoneylabel:setVisible(true)
        self.allmoneycoin:setVisible(true)
        createScaleButton(self.GritUpCalculator_allbg.GritUpCalculator_sure)
        self.surebtn:setVisible(true)
        self.surebtn:addTouchEnded(self.isSure)
        calculend = true 
    end 

end



--初始化数据
function MineUpShow:initData()
    self.surebtn = self.GritUpCalculator_allbg.GritUpCalculator_sure
    self.surebtn = createScaleButton(self.surebtn)
    
    self.scrollview = self.GritUpCalculator_allbg.GritUpCalculator_bg2.GritUpCalculator_bg3.GritUpCalculator_scrollview
    self.slider = self.GritUpCalculator_allbg.GritUpCalculator_bg2.GritUpCalculator_bg3.GritUpCalculator_huadong
    self.allmoneylabel = self.GritUpCalculator_allbg.GritUpCalculator_bg2.GritUpCalculator_bg3.GritUpCalculator_allLabel
    self.allmoneycoin = self.GritUpCalculator_allbg.GritUpCalculator_bg2.GritUpCalculator_bg3.GritUpCalculator_coin
    self.allmoneycoin:setVisible(false)
    self.allmoneylabel:setVisible(false)
    self.slider:setPercent(0)
    self.moneylabel = {}
    self.coin = {}
    self.baojibeishu = {}
    for i = 1 ,10 do     
        self.moneylabel[i] = self.scrollview["GritUpCalculator_Label" ..i]
        self.coin[i] = self.scrollview["GritUpCalculator_coin" ..i]
        self.baojibeishu[i] = self.scrollview["GritUpCalculator_gritX" ..i]
        self.baojibeishu[i]:setColor(cc.c3b(165,48,8))
        FontStyle.setFontNameAndSize(self.baojibeishu[i], FontNames.HEITI, 20)
        
        self.moneylabel[i]:setVisible(false)
        self.moneylabel[i]:setColor(cc.c3b(137,67,48))
        FontStyle.setFontNameAndSize(self.moneylabel[i], FontNames.HEITI, 20)

        self.coin[i]:setVisible(false)
        self.baojibeishu[i]:setVisible(false)
        if i ~= 10 then 
            self.scrollview["line_" .. i ]:setVisible(false)
        end 
    end 
    bindScrollViewAndSlider(self.scrollview, self.slider, false)

end

function MineUpShow:delayInit()
    self.GritUpCalculator_allbg.GritUpCalculator_bg2.GritUpCalculator_bg3:loadTexture(prePath .. "GritUpSpeed_neidi.png",ccui.TextureResType.localType)
end 

--初始化ui
function MineUpShow:onShow()
    --更新监听是否长按过一秒，以及是否为触碰，以及展示所有的数据
    local function updateMineUpShow(delay1)
        pass = pass + delay1
        if pass >= delay then
            if calculend == false then 
                self:lineShow()
            end 
            pass = 0
        end
        if touchflag ~= 0 then 
            if touchflag == 1 then 
                presstime = presstime  + delay1
                if presstime >= 1 then 
                    delay = 0.1 
                    presstime = 0
                end 
            elseif touchflag == 2 then 
                if presstime < 1 then 
                    self:lineShow()
                    presstime = 0
                    touchflag = 0
                else 
                    delay = 0.5 
                    presstime = 0
                end  
            end 
        end  
    end
    if MineUpSpeed.isTenSpeed == true then 
        TimerMgr.killTimer(updatekey)
        updatekey = TimerMgr.startTimer(updateMineUpShow, 0, false)
        MineUpSpeed.isTenSpeed = false 
        calculend = false 
    end 
    
    EventMgr.addListener(EventType.WindowOutClick, TouchBgLister)
    
end

function MineUpShow:onClose()
    TimerMgr.killTimer(updatekey)
    updatekey = nil
    touchflag = 0 
    time = 1
end 

EventMgr.addListener(EventType.showMineUpShow, showMineUp)
