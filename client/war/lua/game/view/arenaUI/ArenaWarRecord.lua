--竞技场对战纪录panel
--by weihao
require "lua/game/view/arenaUI/ArenaWarRecordOne.lua"
local prePath = "image/ui/ArenaUI/"

local url = prePath .. "WarRecord.ExportJson"
ArenaWarRecord = createUIClass("ArenaWarRecord", url, PopWayMgr.SMALLTOBIG)
ArenaWarRecord.scrollview = nil --滚动层

function ArenaWarRecord:ctor()
    PopWayMgr.setSTBSkew(0,-10)
    self.scrollview = self.scrollview
end

function ArenaWarRecord:onShow()
    ArenaData.redPoint = false
    EventMgr.addListener(EventType.ArenaWarRecord,self.updateData,self)
end

function ArenaWarRecord:updateData()
    local recordlist = ArenaData.getRecordList()
    local viewlist = {}
    if recordlist ~= nil and #recordlist ~= 0 then 
        for _,record in pairs(recordlist) do
            local recordone = ArenaWarRecordOne:createView(record.avatar,record.winflag ,record.roleid,record.level, record.time,record.name,record.downname,record.fightid)
            table.insert(viewlist,recordone)
        end 
        initScrollviewWith(self.scrollview, viewlist, 1, 10, 0, 0, 0)
    end 
end 

function ArenaWarRecord:onClose()
    ArenaData.redPoint = false
    EventMgr.removeListener(EventType.ArenaWarRecord,self.updateData)
end 
