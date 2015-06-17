--竞技场结构

--by weihao
local prePath = "image/ui/ArenaUI/"

local url = prePath .. "ArenaResult_1.ExportJson"
ArenaResult = createUIClass("ArenaResult", url, PopWayMgr.SMALLTOBIG)

function ArenaResult:ctor()
--   self.bg.lpming -- 历史最高排名
--   self.bg.npming -- 当前排名
--   self.bg.shen  --上升名次
--   self.bg.zhuanshi --可获得奖励label
--   self.bg.zhuanshitupian --钻石图片
   createScaleButton(self.closebtn) --关闭按钮
   self.closebtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'ArenaResult click closeArenaResult' )
        Command.run( 'ui hide', 'ArenaResult')
    end )
end 


function ArenaResult:onShow()
    EventMgr.addListener(EventType.UpdateArenaResultData, self.refreshData, self)
    self:refreshData()
end 

function ArenaResult:onClose()
    EventMgr.removeListener(EventType.UpdateArenaResultData, self.refreshData)
end 

function ArenaResult:refreshData()

    local data = ArenaData.getWinFlag()
--    local info = ArenaData.getRolelist()[1]
    self.flag = data.winflag
    self.addrank = data.addrank
    self.coin = data.coin 
    self.rank = data.rank   -- 获取当前排名
    if not self.coin then
      return
    end
    local function setCoin()
        local url = CoinData.getCoinUrl(self.coin.cate)
        self.bg.zhuanshitupian:loadTexture(url, ccui.TextureResType.localType)
    end 
    if self.coin.cate == const.kCoinGold then --钻石
--        setCoin()
        LogMgr.debug("zuanshi")
    elseif self.coin.cate == const.kCoinMoney then --金币
        setCoin()
        LogMgr.debug("jinbi")
    elseif  self.coin.cate == const.kCoinMedal then --勋章 
        setCoin()
        LogMgr.debug("xunzhan")
    elseif self.coin.cate == const.kCoinItem then --物品 
        local id = self.coin.objid
        LogMgr.debug("wuping  id = " ..id  )
    end

    self.count = self.coin.val
--    self.currank = info.rank
    self.maxrank = self.rank

    if self.addrank ~= 0 then 
        self.bg.lpming:setString(self.maxrank + self.addrank.. '')
        self.bg.npming:setString(self.maxrank .. '')
    else 
        self.bg.lpming:setString(self.maxrank .. '')
        self.bg.npming:setString(self.maxrank .. '')
    end 
    self.bg.zhuanshi:setString(self.count .. '')
    
    self.bg.shen:setString(self.addrank .. '')
    self.bg.kuohao1:setPositionX(self.bg.npming:getPositionX() + self.bg.npming:getSize().width + 10)
    self.bg.shanshen:setPositionX(self.bg.kuohao1:getPositionX() + self.bg.kuohao1:getSize().width + 10)
    self.bg.shen:setPositionX(self.bg.shanshen:getPositionX() + self.bg.shanshen:getSize().width - 10 )
    local width = self.bg.shen:getSize().width
    local x = self.bg.shen:getPositionX()
    self.bg.kuohao2:setPositionX(x + width + 10)
    if self.addrank == 0 then 
       self.bg.shen:setVisible(false)
       self.bg.kuohao1:setVisible(false)
       self.bg.kuohao2:setVisible(false)
       self.bg.shanshen:setVisible(false)
    else 
       self.bg.shen:setVisible(true)
       self.bg.kuohao1:setVisible(true)
       self.bg.kuohao2:setVisible(true)
       self.bg.shanshen:setVisible(true)
    end 
    --    self.bg.zhuanshitupian:loadTexture("")
end 
