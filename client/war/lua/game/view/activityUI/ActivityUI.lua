--**谭春映
--**活动UI
require "lua/game/view/activityUI/ActivityInfo.lua"
local url = ActivityData.path1 .. "main.ExportJson"
ActivityUI = createUIClass("ActivityUI", url, PopWayMgr.SMALLTOBIG)
--SoldierUI.sceneName = "common"
function ActivityUI:onShow()
    self.selectedIndex = 1
    self.getRewardUpdate = false
    Command.run( 'activity activitylist' )
    Command.run( 'activity infolist' )
    EventMgr.addList(self.event_list)
    if self.info then
        self.info:onShow()
    end
    performNextFrame(self, self.updateData, self)
end

function ActivityUI:onClose()
    EventMgr.removeList(self.event_list)
    if self.info then
        self.info:onClose()
    end
end

function ActivityUI:updateData( )
	self.dataList = ActivityData.activityInfoList
    if not self.dataList then
        self.dataList = {}
    end
    self.itemList = {}
    self.tableView:reloadData()
end

function ActivityUI:updateItemData( index,content )
    self.itemList[index] = content
    content:setVisible(false)
    local isRedShow = true
    if index <= #self.dataList then
        content:setVisible(true)
    	local data = self.dataList[index]
        local openData = ActivityData.findOpenData(data.name)
        local AData = nil
        if openData then
            AData = ActivityData.findAData(openData.data_id)
            --读取活动图标
            if AData then
                content.txtName:setString(AData.name)
                local url = string.format(ActivityData.path3,AData.type)
                content.icon:loadTexture(url,ccui.TextureResType.localType)
                isRedShow = ActivityData.hasGeted(openData,AData)
            end
        end

        local size = content:getSize()
        local off = cc.p(size.width - 8,size.height - 8)
        setButtonPoint( content, isRedShow ,off)
        content.data = data
        content.openData = openData
        content.AData = AData
    end

    content.selected:setVisible(false)
    if index == self.selectedIndex then
        self:changeSelected(index,content)
    end
end

function ActivityUI:changeSelected( index,content)
    content.selected:setVisible(true)
    
    self.txtDesc:setString(index)
    self.txtTime:setString("")
    --local time = os.time()
    if content.data then
        if content.data.end_time > 0 then
            local timestr_s = DateTools.toFormatString(content.data.start_time,"%m月%d日%H:%M")
            local timestr_e = DateTools.toFormatString(content.data.end_time,"%m月%d日%H:%M")
            self.txtTime:setString(timestr_s .."--"..timestr_e)
            local days = DateTools.getDay(content.data.end_time)
            if days >= 9999 then
                self.txtTime:setString("永久开放")
            end
        else
            self.txtTime:setString("永久开放")
        end
    end
    
    if content.AData then
        self.txtTitle:setString(content.AData.name)
        self.txtDesc:setString(content.AData.desc)
    end
    
    if not self.getRewardUpdate then 
        self.info:setData(index,content.data)
    end

    self.getRewardUpdate = false
end

function ActivityUI:dispose( )
    if self.info then
        self.info:dispose()
    end
end

function ActivityUI:ctor()
    --self.txtTitle:setString("活动")
	local url = ActivityData.path2 .. "bg.png"
    self.bg:loadTexture(url,ccui.TextureResType.localType)
	self:initTableView()
	self:initInfo()
    local function update( )
        self:updateData()
    end

    local function updateRedPoint( ... )
        if self.tableView and self.selectedIndex then
            self.getRewardUpdate = true
            self.tableView:updateCellAtIndex(self.selectedIndex - 1)
        end
    end
    self.event_list = {}
    self.event_list[EventType.activityListUpdate] = update
    self.event_list[EventType.activityGetReward] = updateRedPoint
end

function ActivityUI:initInfo( )
	self.info = ActivityInfo.new()
	self:setAnchorPoint(cc.p(0,0))
	local posi = cc.p(self.Image_4:getPosition())
	self.info:setPosition(posi)
	self:addChild(self.info)
end

function ActivityUI:initTableView()
    self.dataList = {}
    self.itemList = {}
	self.tcellWidth =  118
	self.tcellHeigth = 112
	local function scrollViewDidScroll(view)

    end

    local function scrollViewDidZoom(view)
       
    end

    local function tableCellTouched(view,cell)
        if view:isTouchMoved() then
            return
        end

        for k,v in pairs(self.itemList) do
            v.selected:setVisible(false)
        end
        
        local touchIndex = cell:getIdx() + 1
        self.selectedIndex = touchIndex
        local content =cell:getChildByTag(1)
        if content then
            self:changeSelected(touchIndex,content)
        end
    end

    local function tableCellAtIndex(view, idx)
	    local index = idx + 1
	    local cell = view:dequeueCell()
	    local label = nil
	    local saveContent = nil
	    if nil == cell then
	        cell = cc.TableViewCell:new()
	        local content = getLayout(ActivityData.path1 .. "activityItem.ExportJson")
	        content:setAnchorPoint(cc.p(0,0))
	        content:setPosition(cc.p(0, 0))
	        content:setTag(1)
	        cell:addChild(content)
	        saveContent = content
	        buttonDisable(content,true)
            content.selected:setVisible(false)
            addOutline(content.txtName,cc.c4b(0x59, 0x1f, 0x05,255),1)
	    else
	        saveContent = cell:getChildByTag(1)
	    end

	    self:updateItemData(index,saveContent)
	    return cell
    end

    local function numberOfCellsInTableView(view)
	    self.maxCeil = #self.dataList
	    return self.maxCeil
	    --return 10
    end
    
    local function cellSizeForTable(view,idx) 
	    --宽高度很变态
	    return self.tcellHeigth,self.tcellWidth
    end

    local posi = cc.p( self.Image_3:getPosition() )
	self.tableView = cc.TableView:create(cc.size(118,382 ))
	self.tableView:setPosition(posi.x + 11, posi.y + 10)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
   	self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView)
    self.tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL )
    self.tableView:registerScriptHandler( scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM )
    self.tableView:registerScriptHandler( tableCellTouched,cc.TABLECELL_TOUCHED )
    self.tableView:registerScriptHandler( cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX )
    self.tableView:registerScriptHandler( tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX )
    self.tableView:registerScriptHandler( numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    self.tableView:reloadData()
    addOutline(self.txtTitle,cc.c4b(0x59, 0x1f, 0x05,255),1)
end