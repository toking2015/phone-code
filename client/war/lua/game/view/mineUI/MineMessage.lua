-- 点击建筑时出现加速信息介绍界面
--by weihao  
require "lua/game/view/mineUI/GetMineData.lua"

local prePath = "image/ui/MineUI/GritUp/"
local url = prePath .. "GritUpSpeed_1.ExportJson"
MineMessage = createUIClass("MineMessage", url, PopWayMgr.SMALLTOBIG)

MineMessage.UpSpeedbnt = nil  -- 加速按钮
MineMessage.mineLevelLabel = nil --金矿等级label
MineMessage.outSpeedLabel = nil --产出速度
MineMessage.saveLabel = nil --存储容量以及目前容量（1222222/1100000000）
MineMessage.nextSpeedMoreLabel = nil --下一等级金矿 产出速度添加多少（＋45）
MineMessage.nextSaveMoreLabel = nil --下一等级金矿 存储速度添加多少 （＋120）
MineMessage.nextmessageLabel = nil --下一等级得信息
MineMessage.loadingtool = nil   --进度条
MineMessage.line1 = nil --横线1
MineMessage.line2 = nil --横线2
MineMessage.isSpeed = false --是否点击加速

function MineMessage:ctor()
    self:initData()
    self:initUI()
    self.event_list = {}
    self.event_list[EventType.MineBuildingSet] = function() self:mineBuildingSet() end
end

function MineMessage:mineBuildingSet( )
    if self ~= nil and self:getParent() ~= nil then
        self:setPositionX(visibleSize.width/2)
    end
end

function MineMessage:initData()
    self.UpSpeedbnt = self.GritUpSpeed_allbg.GritUpSpeed_jiasu
    self.UpSpeedbnt = createScaleButton(self.UpSpeedbnt)
    self.mineLevelLabel = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_levelbg.GritUpSpeed_levelnumber
    self.outSpeedLabel = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_listtop.GritUpSpeed_shudunumber
    self.saveLabel = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_listtop.GritUpSpeed_jindutiao.GritUpSpeed_jindunumber
    self.nextSpeedMoreLabel = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_upspeednumber
    self.nextSaveMoreLabel = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_upmoresavenumber
    self.nextmessageLabel = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_updata
    self.loadingtool = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_listtop.GritUpSpeed_jindutiao.GritUpSpeed_jindu
    self.line1 = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_listbottomline1
    self.line2 = self.GritUpSpeed_allbg.GritUpSpeed_xiaoxilist.GritUpSpeed_xiaoxilist1.GritUpSpeed_listbottomline2

end

function  MineMessage:initUI()
    self.line1:setVisible(true)
    self.line2:setVisible(true)
    --设置各种label的数值
    getMineData.getBuildingData()
    self.mineLevelLabel:setString("LV."..getMineData.buildingLevel)
    self.outSpeedLabel:setString(''..getMineData.prodSpeed)
--    LogMgr.debug("getMineData.prodSpeed" .. getMineData.prodSpeed)
--    LogMgr.debug("getMineData.oldtime" .. getMineData.oldtime)
--    LogMgr.debug("GameData.getServerDate()" .. GameData.getServerTime()) 
    local minesave = math.floor((GameData.getServerTime() - getMineData.oldtime)/60 )* getMineData.prodSpeed
    minesave = minesave + getMineData.curMineCount
    if minesave > getMineData.prodSpeed*8*60 or minesave < 0 then 
        minesave = getMineData.prodSpeed*8*60
    end 
    
    local allsave = getMineData.prodSpeed*8*60
    local persent = minesave / allsave
    self.saveLabel:setString(minesave .. '/'..(getMineData.prodSpeed*8*60))
    self.loadingtool:setPercent(persent*100)
    self.nextSpeedMoreLabel:setString('+'.. getMineData.addSpeed)
    self.nextSaveMoreLabel:setString('+'.. getMineData.addMineCount)
    local teamLevel = tonumber(getMineData.requireGrade)
    self.nextmessageLabel:setString("战队达到" .. teamLevel .. "级金矿可升至LV" .. (getMineData.buildingLevel+1) )

    self.isUpSpeed = function (sender, eventType)
        ActionMgr.save( 'UI', 'MineMessage click isUpSpeed')
        local zdlevel = gameData.getSimpleDataByKey("team_level")
        if zdlevel < 20 then 
        -- 这里写战斗等级限制
            TipsMgr.showError('战队20级开放')  
         else 
            MineMessage.isSpeed = true 
            EventMgr.dispatch(EventType.showMineStype, {isCenter = false})
            self:setPositionX(visibleSize.width/2-(self:getSize().width/2 + 14))
         end 
    end
    self.UpSpeedbnt:addTouchEnded(self.isUpSpeed)
end


function MineMessage:onShow()
    self:initUI()
    EventMgr.addList(self.event_list)
end

function MineMessage:onClose()
    EventMgr.removeList(self.event_list)
end
