require("lua/game/view/rankUI/RankTypeUntil.lua")
require("lua/game/view/rankUI/RankUIUntil.lua")
local prePaiPath = "image/ui/RankUI/ranktitle/"
local prePath = "image/ui/RankUI/"
local url = prePath .. "RankUI.ExportJson"
RankUI = createUIClass("RankUI", url ,PopWayMgr.SMALLTOBIG)
local flag = false 
local flag1 = 0 
local flag2 = 0  
function RankUI:ctor()
    flag = true
    PopWayMgr.setSTBSkew(0,30)
    self.isUpRoleTopView = true
    createScaleButton(self.bg.ssbtn)
    createScaleButton(self.bg.zrbtn)
    createScaleButton(self.bg.shuaxinbtn)
    self.bg.ssbtn:setLocalZOrder(10)
    self.bg.zrbtn:setLocalZOrder(10)
    self.bg.shuaxinbtn:setLocalZOrder(10)
    
    self.bg.ssbtn:addTouchEnded(function()
       ActionMgr.save( 'UI', 'RankUI click down ssbtn' )
       RankData.time = const.kRankAttrReal
       RankData.sendRankList()
--       print("实时")
       self.bg.ssbtn:setVisible(false)
       self.bg.zrbtn:setVisible(true)
       self.bg.shuaxinbtn:setVisible(true)
       self.paiming:setString("实时排名")
       self.bianhuaqingk:setString("昨日排名")
       self.phan:loadTexture( prePaiPath .. "rankui_phb1.png",ccui.TextureResType.localType)
       
    end)
    self.bg.zrbtn:addTouchEnded(function()
       ActionMgr.save( 'UI', 'RankUI click down zrbtn' )
       if gameData.isOpenPassOneDay() == true then 
           RankData.time = const.kRankAttrCopy
           RankData.sendRankList()
           self.bg.ssbtn:setVisible(true)
           self.bg.zrbtn:setVisible(false)
           self.bg.shuaxinbtn:setVisible(false)
           self.paiming:setString("昨日排名")
           self.bianhuaqingk:setString("变动情况")
           self.phan:loadTexture( prePaiPath .. "rankui_phb2.png",ccui.TextureResType.localType)
       else
           TipsMgr.showError('开服第一天，暂无昨日排名')
       end 
--       print("昨天")
    end)
    self.bg.shuaxinbtn:addTouchEnded(function()
       ActionMgr.save( 'UI', 'RankUI click down shuaxinbtn' )
       RankData.sendRankList(true)
--       print("刷新")
        if self.tableview ~= nil then 
           self.tableview:setVisible(false)
        end 
    end)
    self.ranklist = {}
    local count = RankData.getTypeCount()
    if RankData.time == const.kRankAttrCopy then 
       self.bg.ssbtn:setVisible(true)
       self.bg.zrbtn:setVisible(false)
       self.bg.shuaxinbtn:setVisible(false)
       self.paiming:setString("昨日排名")
       self.bianhuaqingk:setString("变动情况")
       self.phan:loadTexture( prePaiPath .. "rankui_phb2.png",ccui.TextureResType.localType)
    else 
       self.bg.ssbtn:setVisible(false)
       self.bg.zrbtn:setVisible(true)
       self.bg.shuaxinbtn:setVisible(true)
       self.paiming:setString("实时排名")
       self.bianhuaqingk:setString("昨日排名")
       self.phan:loadTexture( prePaiPath .. "rankui_phb1.png",ccui.TextureResType.localType)
    end 
  
    for i = 1  , count do
        local view = nil 
        local build = findBuilding(19)  -- 拍卖行
        local build1= findBuilding(12)  -- 神殿
        local level = 100
        local level1 = 100 
        if build ~= nil then 
           level = build.common_open
        end 
        if build1 ~= nil then 
           level1 = build1.common_open
        end 

        local now_level = gameData.getSimpleDataByKey("team_level")
        if i ~= 8 then 
            if (i ~= 5 and i ~= 7) or (now_level >= level1 and i == 5) or (now_level >= level and i == 7) then 
                view = RankTypeUntil:createView(i)
                createScaleButton(view,false)
                table.insert(self.ranklist,view)
                view:addTouchEnded(function()
                    RankData.index = i 
                    ActionMgr.save( 'UI', 'RankUI click down RankTypeUntil' .. i )
                    if i == 6 and flag1 == 1 then 
                        self:pressIndex(i - flag1,i) 
                    elseif i == 7  then 
                        self:pressIndex(i - flag1 - flag2, i)    
                    else 
                        self:pressIndex(i,i)  
                    end             
                end)
            else
                if i == 5 then
                   flag1 = 1 
                end 
                if i == 7 then 
                   flag2 = 1
                end 
            end 
        end 
    end
    initScrollviewWith(self.bg2.sc,self.ranklist , 1, 0, 0, 0, 0)
    local num = 1
    if RankData.type == const.kRankingTypeTeamLevel then   --战队
        num = 1
    elseif RankData.type == const.kRankingTypeSoldier  then -- 英雄
        num = 2
    elseif RankData.type == const.kRankingTypeTotem then  -- 图腾
        num = 3
    elseif RankData.type == const.kRankingTypeCopy then  -- 副本
        num = 4
    elseif RankData.type == const.kRankingTypeTemple then -- 神殿
        num = 5
    elseif RankData.type == const.kRankingTypeEquip then  -- 装备评分
        num = 6
    elseif RankData.type == const.kRankingTypeMarket then  --拍卖行
        num = 7
    end 
    if num == 6 and flag1 == 1 then 
        self:pressIndex(num - flag1,num) 
    elseif num == 7  then 
        self:pressIndex(num - flag1 - flag2, num)    
    else 
        self:pressIndex(num,num)  
    end
    self:refreshByIndex()
    
end 

function RankUI:pressIndex(i,num)
    for key , value in pairs(self.ranklist) do
        value.bg.xz:setVisible(false)
    end 
    self.ranklist[i].bg.xz:setVisible(true)  
    --  到时调整两个进来 又得改  
    RankData.type = const.kRankingTypeTeamLevel 
    i = num 
    if i == 1 then 
        RankData.type = const.kRankingTypeTeamLevel 
--        print("战队等级")
    elseif i == 2 then 
        RankData.type = const.kRankingTypeSoldier
--        print("英雄")
    elseif i == 3 then
        RankData.type = const.kRankingTypeTotem  
--        print("图腾")
    elseif i == 4 then
        RankData.type = const.kRankingTypeCopy
--        print("副本")
    elseif i == 5 then
        RankData.type = const.kRankingTypeTemple
--        print("神殿积分")
    elseif i == 6 then
        RankData.type = const.kRankingTypeEquip
--        print("装备")
    elseif i == 7 then
        RankData.type = const.kRankingTypeMarket  
--        print("拍卖行")
    end  
    
    if flag == false then 
       RankData.sendRankList()
    end 
    flag = false 
end 

function RankUI:refreshData()
    self.list = RankData.getRankList()
    if self.tableview ~= nil then 
        self.tableview:removeFromParent()  
    end 
    function self.updateItemData(data ,constant, index, i, widthCount)
        if index > 0 then 
            local value = self.list[index]
            constant:refreshData(value,index) 
        end 
    end

    function self.create()
        return RankUIUntil:createView(nil)

    end
    self.tableview = createTableView({},self.create,self.updateItemData,cc.p(self.sc:getPositionX(),self.sc:getPositionY()),cc.size(self.sc:getSize().width ,self.sc:getSize().height),cc.size(550,95),self,nil)  
    self.dataLen = #self.list -- 由于传空数据
    if #self.list == 0 then 
        self.dataLen = 0
    end 
    self.tableView:reloadData() 
end 

function RankUI:refreshByIndex()
    local str = ""
    if RankData.type == const.kRankingTypeSoldier  then 
        str = "英雄数量"
    elseif RankData.type == const.kRankingTypeTotem then 
        str = "图腾数量"
    elseif RankData.type == const.kRankingTypeCopy then
        str = "副本星数"
    elseif RankData.type == const.kRankingTypeEquip then
        str = "装备评分"
    elseif RankData.type == const.kRankingTypeMarket then
        str = "拍卖行收入"
    elseif RankData.type == const.kRankingTypeSingleArena then
        str = "战力"
    elseif RankData.type == const.kRankingTypeTeamLevel then
        str = "战队等级"
    elseif RankData.type == const.kRankingTypeTemple then 
        str = "神殿积分"
    end 
    self.yinsu:setString(str)   
end 

function  RankUI:refreshView() 
    self:refreshByIndex()
    if self.tableview ~= nil then 
        self.tableview:setVisible(true)
    end    
    if self.tableview == nil then 
        self:refreshData()     
    else 
        self.list = RankData.getRankList()
        self.dataLen = #self.list -- 由于传空数据
        if #self.list == 0 then 
            self.dataLen = 0
        end 
        self.tableView:reloadData() 
    end 
    
    local data = RankData.getRankUs()
    local view  = RankUIUntil:createView(data.data,data.index + 1)
    self.vector:addChild(view)
end 

function RankUI:onShow()
    self.bg3:loadTexture("image/ui/RankUI/rankui_bgui.png", ccui.TextureResType.localType)
    local str = ""
    if RankData.type == const.kRankingTypeSoldier  then 
        str = "英雄数量"
    elseif RankData.type == const.kRankingTypeTotem then 
        str = "图腾数量"
    elseif RankData.type == const.kRankingTypeCopy then
        str = "副本进度"
    elseif RankData.type == const.kRankingTypeEquip then
        str = "装备评分"
    elseif RankData.type == const.kRankingTypeMarket then
        str = "拍卖行收入"
    elseif RankData.type == const.kRankingTypeSingleArena then
        str = "战力"
    end
    self.yinsu:setString(str)
--    RankData.type = const.kRankingTypeSoldier 
--    RankData.time = const.kRankAttrCopy
    EventMgr.addListener(EventType.RankList, self.refreshView,self)
    RankData.sendRankList()
end 

function RankUI:onClose()
    Command.run("loading wait hide","rankui")
    EventMgr.removeListener(EventType.RankList, self.refreshView)
end 