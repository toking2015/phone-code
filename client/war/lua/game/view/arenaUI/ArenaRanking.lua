--竞技场排名panel
--by weihao
require "lua/game/view/arenaUI/ArenaRankingOne.lua"
local prePath = "image/ui/ArenaUI/"

local url = prePath .. "Ranking.ExportJson"
ArenaRanking = createUIClass("ArenaRanking", url, PopWayMgr.SMALLTOBIG)
local viewlist = {}
ArenaRanking.ranklabel = nil --我的排名
ArenaRanking.activitylabel = nil --我的活动
ArenaRanking.scrollview = nil --滚动层

function ArenaRanking:ctor()
    PopWayMgr.setSTBSkew(0,-25)
    self.ranklabel = self.myrank
    FontStyle.setFontNameAndSize(self.ranklabel, FontNames.HEITI, 20)
    FontStyle.setFontNameAndSize(self.rankname, FontNames.HEITI, 20)
    self.activitylabel = self.activity
    FontStyle.setFontNameAndSize(self.activitylabel, FontNames.HEITI, 22)
    self.scrollview = self.bg.bg2.sc
end

function ArenaRanking:onShow()
    EventMgr.addListener(EventType.ArenaRanking, self.updateData, self)
end

function ArenaRanking:onClose()
    EventMgr.removeListener(EventType.ArenaRanking, self.updateData)
end 

function ArenaRanking:updateData()
    local role = ArenaData.getRolelist()[1]
    if role then
        self.ranklabel:setString(role.rank)
        self.activitylabel:setString("每天".. role.calcul .. "点进行结算并发放奖励")
    end
    
    local ranklist = ArenaData.getRandList()
    function self.updateItemData(data ,constant, index, i, widthCount)
        if index > 0 then 
            local value = data[index]
            constant:init(value.rank, value.id, value.level,value.name,value.power) 
--            constant:setGlobalZOrder(value.rank)
            constant:setLocalZOrder(value.rank)
        end 
    end

    function self.create()
        return ArenaRankingOne:createView(nil)
    end
    self.scrollview:setVisible(false)
    createTableView(ranklist,self.create,self.updateItemData,cc.p(self.scrollview:getPositionX()+25,self.scrollview:getPositionY()+30),self.scrollview:getSize(),cc.size(615,90),self,nil)  
--    if viewlist ~= nil and #viewlist ~= 0 then  
--        for key,value in pairs(ranklist) do 
--            viewlist[key]:init(value.rank, value.id, value.level,value.name,value.power)
--        end 
--    else 
--        viewlist = {}
--        for key,rank in pairs(ranklist) do
--            local rankone = ArenaRankingOne:createView(rank.rank, rank.id, rank.level,rank.name,rank.power)
--            rankone:retain()
--            table.insert(viewlist,rankone) 
--        end   
--    end 
--    initScrollviewWith(self.scrollview, viewlist, 1, 0, 0, 0, 0)
end

function ArenaRanking:clear()
--   if viewlist ~= nil and #viewlist ~= 0 then  
--      for key ,value in pairs(viewlist) do 
--          TimerMgr.releaseLater(value)
--          viewlist[key] = nil 
--      end 
--   end 
end 