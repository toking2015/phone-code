local prePath = "image/ui/PaperSkillUI/"
PaperList = createLayoutClass('PaperList', cc.Node)

local quality_bg_map = {
	"green.png",
	"blue.png",
	"purple.png",
	"orange.png",
	"gray.png"
}

local function checkCreate(jPaper)
    local jSkill = PaperSkillData.getJSkill()
    if not jSkill then
        return false
    end
    local left_score = CoinData.getCoinByCate(const.kCoinActiveScore)
    local need_score = math.ceil(jPaper.active_score * (1 - jSkill.create_cost_reduce / 10000))
    if left_score < need_score then
        return false
    end
    if jSkill.paper_level_limit < jPaper.level_limit then
        return false
    end
    return true
end

-- @select_callback: table_view某一项被选中时主UI的回调事件
function PaperList:ctor(select_callback)
    self.max_idx = 0
    self.paper_list = PaperSkillData.getPaperList()
    if #self.paper_list == 0 then
        return
    end
    table.sort(self.paper_list, function (a, b) return a.item_id < b.item_id end)

    self.select_callback = select_callback
    -- {cell:paper_list.idx}
	self.cell_idx_map = {}
    -- paper_list.idx
	self.cur_select = -1

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
        if not self.slider then return end
        self.t_moving = true
        if not self.s_moving then
            local cur_offset = self.tableView:getContentOffset()
            self.slider:setPercent((1 - cur_offset.y / self.orgin_offset) * 100)
        end
        self.t_moving = false
    end

    local function scrollViewDidZoom(view)
        --
    end

    local function tableCellTouched(view,cell)
        ActionMgr.save('UI', 'PaperCreateUI click paper')
    	if self.cur_select == self.cell_idx_map[cell] then
    		return
    	end
    	for k, v in pairs(self.cell_idx_map) do
    		if v == self.cur_select then
    			local item = k:getChildByTag(1)
    			item.lock:setVisible(false)
    		end
    	end

    	self.cur_select = self.cell_idx_map[cell]
    	local item = cell:getChildByTag(1)
    	item.lock:setVisible(true)

        if self.select_callback ~= nil then
            self.select_callback(self.paper_list[self.cur_select + 1])
        end
    end

    local function updateCell(cell, idx)
    	local jData = self.paper_list[idx + 1]
    	if not jData then
    		return cell
    	end

    	local jItem = findItem(jData.item_id)
    	if not jItem then
    		return cell
    	end

    	local item = getLayout(prePath .. "PaperItem.ExportJson")
    	item.item_icon:loadTexture(ItemData.getItemUrl(jData.item_id), ccui.TextureResType.localType)
        local bg_index = 0
        if checkCreate(jData) then
            bg_index = jItem.quality
        else
            bg_index = 5
        end
    	item.bg:loadTexture(prePath .. quality_bg_map[bg_index], ccui.TextureResType.localType)
        item.lock:loadTexture(prePath .. "lock.png", ccui.TextureResType.localType)
    	item.item_name:setString(jItem.name)
    	if self.cur_select ~= idx then
    		item.lock:setVisible(false)
    	end
    	item:setTouchEnabled(false)
    	cell:addChild(item, 0, 1)

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
    	return #self.paper_list
    end
    
    local function cellSizeForTable(view,idx) 
    	return 113, 286
    end

    --TabelView初始化
	self.tableView = cc.TableView:create(cc.size(280, 290))
    -- self.tableView = cc.TableView:create(cc.size(PaperUICommon.w, PaperUICommon.h))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(0, 0)
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
    self.slider:setScaleX(0.92)
    self.slider:setPosition(292, 138)
    -- self.slider:setScaleX(PaperUICommon.w / PaperUICommon.h)
    -- self.slider:setPosition(PaperUICommon.x, PaperUICommon.y)
    self.slider:setRotation(90)

    self.slider:addEventListenerSlider(percentChangedEvent)
    self:addChild(self.slider)
end

function PaperList:onShow()
    -- 默认选中可制作的最高等级的图纸
    if #self.paper_list == 0 then return end
    local jSkill = PaperSkillData.getJSkill()
    if not jSkill then return end
    local max_idx = 0
    for k, v in ipairs(self.paper_list) do
        if v.level_limit <= jSkill.paper_level_limit then
            max_idx = max_idx + 1
        end
    end
    self.max_idx = max_idx
    -- self.max_idx = PaperUICommon.max_idx 

    if self.max_idx > 2 then
        local offset = self.tableView:getContentOffset()
        -- 113 * 3 - 290
        local cell_unvisible_height = 49
        offset.y = offset.y + cell_unvisible_height + (self.max_idx - 3) * 113
        self.tableView:setContentOffset(offset)
    end

    performNextFrame(self, function ()
        if self.cur_select ~= -1 then return end
        self.cur_select = self.max_idx - 1
        if self.cur_select >= 0 and self.select_callback ~= nil then
            local cell = self.tableView:cellAtIndex(self.cur_select)
            if not cell then return end
            local item = cell:getChildByTag(1)
            item.lock:setVisible(true)
            self.select_callback(self.paper_list[self.cur_select + 1])
        end
    end)
end
