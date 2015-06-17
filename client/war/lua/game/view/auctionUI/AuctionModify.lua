local prepath = "image/ui/AuctionUI/"
local url = prepath .. "AuctionUp.ExportJson"
AuctionModify = createUIClass("AuctionModify", url, PopWayMgr.SMALLTOBIG)

function AuctionModify:ctor()

    self.data = AuctionData.getModifylist()
    self.bgid = self.data.bgid      --框bg
    self.coinbgid = self.data.coinbg  --头像bg
    self.coinid = self.data.coin      --头像id
    self.nameid = self.data.name      --名字
    self.moneyid = self.data.money    --多少货币
    self.leixinid = self.data.leixin  -- 货币类型
    self.biaoqianid = self.data.biaoqian --标签
    self.countid = self.data.count --数量
    self.baifenid = self.data.percent
    self.buycount = 1
    
    self.text1:setVisible(false)
    createScaleButton(self.sjbtn)
    createScaleButton(self.canclebtn)
    createScaleButton(self.sub1)
    createScaleButton(self.sub2)
    createScaleButton(self.add1)
    createScaleButton(self.add2)
    ProgramMgr.setGray(self.sub1)
    ProgramMgr.setGray(self.add1)
    self.sub1:setTouchEnabled(false)
    self.add1:setTouchEnabled(false)
    self.canclebtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'AuctionModify click canclebtn' )
        Command.run('ui hide' , 'AuctionModify')
    end)
    self.sjbtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'AuctionModify click sjbtn' )
        local wuping = {}
        wuping.cate = self.leixinid
        wuping.objid = self.coinid
        wuping.val = self.buycount
        Command.run( 'marketxiugai', self.data.cargo_id,self.baifenid)
        Command.run('ui hide' , 'AuctionModify')
        LogMgr.debug("shangjia")
    end)
    self.subfun1 = function ()
        if self.buycount > 0 then 
            if self.leixinid == const.kCoinActiveScore then --手工活力
                self.buycount = self.buycount - 10
            else 
                self.buycount = self.buycount - 1 
            end 
        end
        if self.buycount <= 0 then  
            self.buycount = 1
            if self.leixinid == const.kCoinActiveScore and self.countid >= 10 then --手工活力
                self.buycount = 10
            elseif self.leixinid == const.kCoinActiveScore then 
                self.buycount = self.countid
            end    
        end 
        self:refreshData()
    end 

    self.subfun2 = function()
        if self.baifenid > 80 then 
            self.baifenid = self.baifenid - 10
        end
        if self.baifenid <= 0 then 
            self.baifenid = 80
        end 
        AuctionData.Uppersent = self.baifenid
        self:refreshData()
    end 

    self.addfun1 = function()
        if self.buycount < self.countid then 
            if self.leixinid == const.kCoinActiveScore and self.buycount + 10 <= self.countid then --手工活力
                self.buycount = self.buycount + 10
            elseif self.leixinid == const.kCoinActiveScore and self.buycount + 10 > self.countid then
                self.buycount = self.countid
            else 
                self.buycount = self.buycount + 1 
            end 
        else  
            self.buycount = self.countid
        end 
        self:refreshData()
    end 

    self.addfun2 = function()
        if self.baifenid < 180 then 
            self.baifenid = self.baifenid + 10
        else
            self.baifenid = 180
        end 
        AuctionData.Uppersent = self.baifenid
        self:refreshData()
    end

    self.sub1:addTouchBegan(function() 
        ActionMgr.save( 'UI', 'AuctionModify click down sub1' )
        self:startDownTimer(2,1)
    end)   
    self.sub2:addTouchBegan(function()
        ActionMgr.save( 'UI', 'AuctionModify click down sub2' )
        self:startDownTimer(2,2)
    end)
    self.add1:addTouchBegan(function()
        ActionMgr.save( 'UI', 'AuctionModify click down add1' )
        self:startDownTimer(1,1)
    end)
    self.add2:addTouchBegan(function()
        ActionMgr.save( 'UI', 'AuctionModify click down add2' )
        self:startDownTimer(1,2)
    end)

    self.sub1:addTouchCancel(function() 
        ActionMgr.save( 'UI', 'AuctionModify click up sub1' )
        self:clearTimer("downTimer")
    end)
    self.sub2:addTouchCancel(function() 
        ActionMgr.save( 'UI', 'AuctionModify click up sub2' )
        self:clearTimer("downTimer")
    end)
    self.add1:addTouchCancel(function() 
        ActionMgr.save( 'UI', 'AuctionModify click up add1' )
        self:clearTimer("downTimer")
    end)
    self.add2:addTouchCancel(function() 
        ActionMgr.save( 'UI', 'AuctionModify click up add2' )
        self:clearTimer("downTimer")
    end)

    self.sub1:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'AuctionModify click up sub1' )
        self:clearTimer("downTimer")
        self.subfun1()
    end)
    self.sub2:addTouchEnded(function()
        ActionMgr.save( 'UI', 'AuctionModify click up sub2' )
        self:clearTimer("downTimer")
        self.subfun2()
    end)
    self.add1:addTouchEnded(function()
        ActionMgr.save( 'UI', 'AuctionModify click up add1' )
        self:clearTimer("downTimer")
        self.addfun1()
    end)
    self.add2:addTouchEnded(function()
        ActionMgr.save( 'UI', 'AuctionModify click up add2' )
        self:clearTimer("downTimer")
        self.addfun2()
    end)
end 

function AuctionModify:onShow() 
    performNextFrame(self, self.refreshData, self)
end 

function AuctionModify:onClose()

end

function AuctionModify:startDownTimer(flag,type)
    local  function idle( )
        self.beginTime = self.beginTime+1
        if self.beginTime >= self.saveMax or self.saveMax < 0 then
            self.beginTime = 1
            self.longClick = true
            if self.flag == 1 then
                -- 一为加
                if self.ntype == 1 then --一为数量
                    self.addfun1()
                elseif self.ntype == 2 then 
                    self.addfun2()
                end 
            elseif self.flag == 2 then 
                -- 二为减
                if self.ntype == 1 then 
                    self.subfun1()
                elseif self.ntype == 2 then 
                    self.subfun2()
                end 
            end
            self.saveMax = self.saveMax - 1
        end
    end

    self:clearTimer("downTimer")
    self.flag = flag
    self.ntype = type 
    self.longClick = false
    self.beginTime  = 0
    self.saveMax = 12
    self.downTimer = TimerMgr.startTimer( idle, 0.01, false )
end 


function AuctionModify:refreshData()
    local bgurl = ItemData.getItemKuanUrl(self.bgid)
    local thingbgurl = ItemData.getItemBgUrl(self.coinbgid)
    local flag = true 
    local thingurl = ItemData.getItemUrl(self.coinid) 
    LogMgr.debug("const.kCoinActiveScore" .. const.kCoinActiveScore)
    AuctionCommon.setCoin(self.leixinid,self.coinid, {self.coin})  --设置头像
    self.name:setString(self.nameid)
    self.kuan:loadTexture(thingbgurl, ccui.TextureResType.localType) --物品框背景
    self.numlabel:setString(self.buycount)
    self.realnum:setString("背包数量:" .. (self.countid or 0))
    self.baifenbi:setString("当前单价:" .. (self.baifenid or 0) .. "%")

    local list = findMarket(self.coinid)
    local money = 1 
    if list ~= nil and self.leixinid ~= const.kCoinActiveScore then --手工活力
        money = list.value * money
    else 
        money = money * 1
    end 

    self.danjialabel:setString(''.. money * (self.baifenid or 0) / 100)
end 

function AuctionModify:clearTimer( name )
    if self[name] == nil then
        return
    end

    if self[name] ~= nil  then
        TimerMgr.killTimer(self[name])
        self[name] = nil
    end
end