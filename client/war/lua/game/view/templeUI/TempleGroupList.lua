local prePath = "image/ui/TempleUI/"
TempleGroupList = createLayoutClass('TempleGroupList', cc.Node)

-- @select_callback: table_view某一项被选中时主UI的回调事件
function TempleGroupList:ctor( select_callback )
	self.group_list = GetDataList("TempleGroup")
    self.redPos = cc.p(172, 45)
	self.cell_idx_map = {}
	self.cur_select = 0
	self.select_callback = select_callback

     -- 滚动条滑动
    local function percentChangedEvent(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            self.s_moving = true
            if not self.t_moving then
                local cur_percent = sender:getPercent()
                self.tableView:setContentOffset(cc.p(0, self.orgin_offset * (100 - cur_percent) / 100))
            end
            self.s_moving = false 
        end
    end

    -- tableView滑动
    local function scrollViewDidScroll(view)
        -- if not self.slider then return end
        -- self.t_moving = true
        -- if not self.s_moving then
        --     local cur_offset = self.tableView:getContentOffset()
        --     self.slider:setPercent((1 - cur_offset.y / self.orgin_offset) * 100)
        -- end
        -- self.t_moving = false
    end

    local function scrollViewDidZoom(view)
        --
    end

	local function tableCellTouched(view,cell)
    	if self.cur_select == self.cell_idx_map[cell] then
    		return
    	end
    	for k, v in pairs(self.cell_idx_map) do
    		if v == self.cur_select then
    			local item = k:getChildByTag(1)
    			item.select:setVisible(false)
                item.txt:setColor(cc.c3b(0xf4, 0xc6, 0xaa))
    			item.bg:loadTexture(prePath .. "btn_collect_unselect_bg.png",ccui.TextureResType.localType)
    		end
    	end

    	self.cur_select = self.cell_idx_map[cell]
    	local item = cell:getChildByTag(1)
        item.select:setVisible(true)
        item.txt:setColor(cc.c3b(0x5a, 0x30, 0x29))
    	item.bg:loadTexture(prePath .. "btn_collect_select_bg.png",ccui.TextureResType.localType)
        if self.select_callback ~= nil then
            self.select_callback(self.group_list[self.cur_select + 1])
        end
        -- SoundMgr.playEffect("sound/ui/fubenpass.mp3")
    end

    local function updateCell(cell, idx)
    	local jData = self.group_list[idx + 1]
    	if not jData then
    		return cell
    	end

    	local item = getLayout(prePath .. "TempleGroupItem.ExportJson")
    	item.bg:loadTexture(prePath .. "btn_collect_unselect_bg.png",ccui.TextureResType.localType)
    	item.txt:setString(jData.name)
    	if self.cur_select ~= idx then
    		item.select:setVisible(false)
            item.txt:setColor(cc.c3b(0xf4, 0xc6, 0xaa))
        else 
            item.select:setVisible(true)
            item.txt:setColor(cc.c3b(0x5a, 0x30, 0x29))
            item.bg:loadTexture(prePath .. "btn_collect_select_bg.png",ccui.TextureResType.localType)
		end
    	item:setTouchEnabled(false)
    	cell:addChild(item, 0, 1)
        setButtonPoint(item, TempleData.CheckIsCanLvUp(jData.id), self.redPos, 200)
    	self.cell_idx_map[cell] = idx
    end

    local function tableCellAtIndex(view, idx)
    	local cell = view:dequeueCell()
    	if not cell then
    		cell = cc.TableViewCell:new()
    	end
    	cell:removeAllChildren()
    	updateCell(cell, idx)
    	return cell
    end

    local function numberOfCellsInTableView(view)
    	return #self.group_list
    end
    
    local function cellSizeForTable(view,idx) 
    	return 62, 430
    end

    --TabelView初始化
	self.tableView = cc.TableView:create(cc.size(228, 430))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(18, 12)
   	self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView)
    self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:reloadData()

    -- 滚动控制
    self.orgin_offset = self.tableView:getContentOffset().y
    self.t_moving = false
    self.s_moving = false

    local sliderbg = prePath .. "sliderbg.png"
    local sliderbar = prePath .. "sliderbar.png"
    self.slider = ccui.Slider:create()
    self.slider:loadBarTexture(sliderbg)
    self.slider:loadSlidBallTextures(sliderbar, sliderbar, sliderbar)
    self.slider:setScaleX(1.3)
    self.slider:setPosition(218, 230)--222
    self.slider:setRotation(90)

    self.slider:addEventListenerSlider(percentChangedEvent)
    -- self:addChild(self.slider)
end

function TempleGroupList:onShow( ... )
	if #self.group_list == 0 then return end

    performNextFrame(self,function ()
        if self.cur_select >= 0 and self.select_callback ~= nil then
            local cell = self.tableView:cellAtIndex(self.cur_select)
            if not cell then return end
            local item = cell:getChildByTag(1)
            item.select:setVisible(true)
            item.bg:loadTexture(prePath .. "btn_collect_select_bg.png",ccui.TextureResType.localType)
            self.select_callback(self.group_list[self.cur_select+1])
        end
    end)
end

function TempleGroupList:updateData( ... )
    self.tableView:reloadData()
end