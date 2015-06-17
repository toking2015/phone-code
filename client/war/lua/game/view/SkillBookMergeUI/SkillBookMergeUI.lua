require "lua/game/view/SkillBookMergeUI/SkillBookItem.lua"

--声明类
local prePath = "image/ui/SkillBookMergeUI/"
local url = prePath .. "SkillBookMergeUI.ExportJson"
SkillBookMergeUI = createUIClass("SkillBookMergeUI", url, PopWayMgr.SMALLTOBIG)

-- 对应按钮的三种状态[获取，装备，合成]
local BTN_SOURCE, BTN_EQUIP, BTN_MERGE = 1, 2, 3

SkillBookMergeUI.target_id = 24043
SkillBookMergeUI.soldier_guid = 1
function SkillBookMergeUI.showUI(target_id, soldier_guid)
	SkillBookMergeUI.target_id = target_id
	SkillBookMergeUI.soldier_guid = soldier_guid
	Command.run('ui show', 'SkillBookMergeUI', PopUpType.SPECIAL)
end

function SkillBookMergeUI:ctor()
	self.isUpRoleTopView = true

	local merge_item_id = SkillBookMergeUI.target_id 
	-- 左上角图标
	local item = SkillBookItem.create(merge_item_id, 1)
	item:setPosition(72, 392)
	self.left_panel:addChild(item, 2)

	self:createAttrPanel()
	self.merge_panel_child_to_clear = {}
	self.show_stack = {}
	self.right_panel_show = false

	local ui_size = self:getSize()
	local left_ui_size = self.left_panel:getSize()
	self.left_panel:setPosition((ui_size.width - left_ui_size.width) / 2, 0)

	-- 装备按钮
	self.btn_usage = BTN_EQUIP
	createScaleButton(self.left_panel.btn)
	function self.onLeftPanelTouch()
		ActionMgr.save('UI', 'SkillBookMergeUI click btn_left_panel')
		if self.btn_usage == BTN_SOURCE then
			self.left_panel:setPosition(0, 0)
			AlteractData.item_id = SkillBookMergeUI.target_id
			AlteractData.cate = const.kCoinItem
			self.subWin = PopMgr.getOrCreateWin('AlteractyTipsUI')
			self.subWin:setMainUI('SkillBookMergeUI')
			self.subWin:setPosition(left_ui_size.width + 6, 0)
			self:addChild(self.subWin)
			self.subWin:onShow()
		elseif self.btn_usage == BTN_EQUIP then
			self:equipSkill()
		else
    		self.left_panel:setPosition(0, 0)
    		self.right_panel:setPosition(left_ui_size.width + 6, 0)
    		self.right_panel:setVisible(true)
    		self.right_panel_show = true
    		self.show_stack = { SkillBookMergeUI.target_id }
    		self:showMergePanel()
		end
	end

	self.left_panel.btn:addTouchEnded(self.onLeftPanelTouch)

	-- 合成按钮
	createScaleButton(self.right_panel.merge_panel.btn_merge)
	self.right_panel.merge_panel.btn_merge:addTouchEnded(function ()
		ActionMgr.save('UI', 'SkillBookMergeUI click btn_merge')
		local merge_id = self.show_stack[#self.show_stack]
		local jMerge = ItemData.getItemMergeForItemId(merge_id)
		if not jMerge then
			return
		end
		if ItemData.checkMerge(merge_id) then
			Command.run('item merge', jMerge.id, 1)
		elseif ItemData.bookMergeRecursionCheck(merge_id) and #self.show_stack == 1 then
			self.recurseMergeTarget = jMerge.id
			self:recurseMerge(merge_id)
		else
			for _, v in ipairs(jMerge.materials) do
				if v.cate == const.kCoinItem and ItemData.getItemCount(v.objid) < v.val then
					local subMerge = ItemData.getItemMergeForItemId(v.objid)
					if subMerge then
						self.show_stack[#self.show_stack+1] = v.objid
						self:showMergePanel()
						return
					end
				end
			end
			TipsMgr.showError('材料不足')
		end
	end)

	-- 副本列表返回按钮
	createScaleButton(self.right_panel.source_panel.btn_ret)
	self.right_panel.source_panel.btn_ret:addTouchEnded(function ()
		ActionMgr.save('UI', 'SkillBookMergeUI click btn_ret')
		self:showMergeUI()
	end)

	self.right_panel.source_panel_child_tag = 0 
	self:setTouchEnabled(false)
end

function SkillBookMergeUI:equipSkill( )
	local guid = ItemData.getItemGuid(const.kBagFuncCommon, SkillBookMergeUI.target_id)
	local _, lv_accept = SoldierData.checkSoldierBookDressLv(SkillBookMergeUI.soldier_guid)
	ActionMgr.save( 'UI', '[SkillBookMergeUI] click [equipSkill guid:'..guid..' soldier_guid:'..SkillBookMergeUI.soldier_guid..' guid:'..guid..']' )
	if not lv_accept then
		TipsMgr.showError('该英雄等级不足')
		return
	end
	Command.run('item equipskill', const.kBagFuncCommon, guid, SkillBookMergeUI.soldier_guid)
	EventMgr.dispatch( EventType.SoldierEatBookQ )
end

function SkillBookMergeUI:updateItemData(data)
	local merge_item_id = SkillBookMergeUI.target_id
	local own_num = ItemData.getItemCount(merge_item_id)
	self.left_panel.own_num:setString(string.format("%d", own_num))

	local lv, lv_accept = SoldierData.checkSoldierBookDressLv(SkillBookMergeUI.soldier_guid)
	if not self.level_rich_text then
		self.level_rich_text = cc.Node:create()
		self.level_rich_text:setAnchorPoint(0, 0)
		local x = 124
		if lv > 9 then
			x = x - 1
		end
		self.level_rich_text:setPosition(x, 46)
		self.left_panel:addChild(self.level_rich_text, 3)
	else
		self.level_rich_text:removeAllChildren()
	end
	local txt
	if not lv_accept then
		txt = string.format("[font=SBM_B18]需要英雄达到[font=SBM_RED]%d[font=SBM_B18]级", lv)
	else
		txt = string.format("[font=SBM_B18]需要英雄达到%d级", lv)
	end
	RichTextUtil:DisposeRichText(txt, self.level_rich_text)

	local jMerge = ItemData.getItemMergeForItemId(merge_item_id)
	if own_num > 0 then
		self.btn_usage = BTN_EQUIP
	elseif not jMerge then
		self.btn_usage = BTN_SOURCE
	else
		self.btn_usage = BTN_MERGE
	end

	local btn_image = { "btn_text_source.png", "btn_text_equip.png", "btn_text_merge.png" }
	local btn_text_png = btn_image[self.btn_usage]
	self.left_panel.btn.btn_text:loadTexture(prePath .. btn_text_png, ccui.TextureResType.localType)

	self:updateMaterialCount()
end

function SkillBookMergeUI:delayInit()
	UIFactory.getTitleTriangle(self.left_panel.bg, 1)
	UIFactory.getTitleTriangle(self.right_panel.bg, 1)
end

function SkillBookMergeUI:onShow()
	performNextFrame(self, self.delayOnShow, self)
end

function SkillBookMergeUI:delayOnShow()
	self:showMergeUI()
	self:updateData()
	EventMgr.addListener(EventType.UserItemUpdate, self.updateItemData, self)
	EventMgr.addListener(EventType.UserItemMerge, self.onMergeResult, self)
end

function SkillBookMergeUI:onClose()
	if self.subWin then
		PopMgr.removeWindow(self.subWin, true, true)
	end
	EventMgr.removeListener(EventType.UserItemUpdate, self.updateItemData)
	EventMgr.removeListener(EventType.UserItemMerge, self.onMergeResult)
end

function SkillBookMergeUI:updateData()
	self:updateItemData()
end

function SkillBookMergeUI:updateMaterialCount()
	if not self.right_panel_show then return end
	local jMerge = ItemData.getItemMergeForItemId(self.show_stack[#self.show_stack])
	if not jMerge then
		return
	end
	for i, material in ipairs(jMerge.materials) do
		-- 规定前x个材料为物品，最后一个是金币
		if material.cate == const.kCoinMoney then
			self.right_panel.merge_panel.money_cost:setString(string.format("%d", material.val))
		else
			-- 消耗数量
			self.right_panel.merge_panel["material_" .. i .. "_num"]:setString(string.format("%d/%d",
				ItemData.getItemCount(material.objid), material.val))
		end
	end
end

-- 合成界面
function SkillBookMergeUI:showMergePanel()
	local function toClear(child)
		self.merge_panel_child_to_clear[#self.merge_panel_child_to_clear+1] = child
	end

	local function clear()
		for _, v in pairs(self.merge_panel_child_to_clear) do
			v:removeFromParent()
		end
		self.merge_panel_child_to_clear = {}
	end

	-- 清除旧数据
	clear()

	-- 最顶部那一栏图标
	local curX = 47
	if #self.show_stack > 1 then
		local show_beg_pos = 1
		local show_beg_x = 35
		if #self.show_stack > 4 then
			show_beg_pos = #self.show_stack - 4
			show_beg_x = -10
		end

		local lastx = show_beg_x
		for i = show_beg_pos, #self.show_stack - 1 do
			local icon = SkillBookItem.create(self.show_stack[i], 0.55)
			icon:setPosition(lastx, 43)
			self.right_panel.merge_panel.head_panel:addChild(icon)
			toClear(icon)
			UIMgr.addTouchBegin(icon.item_icon, function ()
				ActionMgr.save('UI', 'SkillBookMergeUI click merge_icon')
				while #self.show_stack > i do
					table.remove(self.show_stack)
				end
				self:showMergePanel()
			end)

			local arrow = UIFactory.getSprite(prePath .. "arrow.png", self.right_panel.merge_panel.head_panel, lastx + 40, 43)
			toClear(arrow)
			lastx = lastx + 80
		end
		curX = lastx + 5
	end

	-- 当前合成的那一个图标
	self.right_panel.merge_panel.head_panel.curbg:setPositionX(curX)
	local merge_item_id = self.show_stack[#self.show_stack]
	local merge_lt_icon = SkillBookItem.create(merge_item_id, 0.6)
	merge_lt_icon:setPosition(curX, 42)
	self.right_panel.merge_panel.head_panel:addChild(merge_lt_icon, 1)
	toClear(merge_lt_icon)

	-- 合成界面中间图标
	-- (0.85 (190 235))
	local merge_md_icon = SkillBookItem.create(merge_item_id, 0.75)
	merge_md_icon:setPosition(192, 323)
	self.right_panel.merge_panel:addChild(merge_md_icon, 1)
	toClear(merge_md_icon)

	-- 合成界面材料图标
	local jMerge = ItemData.getItemMergeForItemId(merge_item_id)
	if not jMerge then
		return
	end

	local function getMaterialPos(idx, count, begin_pos, gap)
		local pos = {
			{ 1 },
			{ 0, 2 },
			{ 0, 1, 2 }
		}
		local x = pos[count][idx]
		return x and begin_pos + x * gap or 0
	end

	local material_count = #jMerge.materials - 1
	for i = 1, 3 do self.right_panel.merge_panel["material_" .. i .. "_num"]:setVisible(true) end
	for i, material in ipairs(jMerge.materials) do
		-- 规定前x个材料为物品，最后一个是金币
		if material.cate ~= const.kCoinMoney then
			-- 消耗图标
			local icon = SkillBookItem.create(material.objid, 0.55)
			local x = getMaterialPos(i, material_count, 98, 96)
			icon:setPosition(x, 215)
			self.right_panel.merge_panel["material_" .. i .. "_num"]:setPositionX(x)

			local function completeHandler()
				local jMerge = ItemData.getItemMergeForItemId(material.objid)
				if not jMerge then
					self:showSourcePanel(self.show_stack[#self.show_stack], material.objid)
				else
					self.show_stack[#self.show_stack+1] = material.objid
					self:showMergePanel()
				end
			end
			UIMgr.addTouchBegin(icon.item_icon, function ()
				ActionMgr.save('UI', 'SkillBookMergeUI click material_icon')
				local duration = 0.1
				local scaleAct_1 = cc.ScaleTo:create(duration, 1.5)
				local scaleAct_2 = cc.ScaleTo:create(duration, 1)
				icon:runAction(cc.Sequence:create(scaleAct_1, scaleAct_2, cc.CallFunc:create(completeHandler)))
			end)

			self.right_panel.merge_panel:addChild(icon, 1)
			toClear(icon)
		end
	end
	for i = #jMerge.materials, 3 do self.right_panel.merge_panel["material_" .. i .. "_num"]:setVisible(false) end
	self:updateMaterialCount()
end

-- 将两个字的字符串添加两个空格变成四个字的字符串
local function insertSpaceIntoStr(str)
	local utf8_str = StringTools.disposeUtf8String(str)
	if #utf8_str == 2 then
		return utf8_str[1] .. "　　" .. utf8_str[2]
	end
	return str
end

local function createRichText(desc, val)
	return string.format("[font=SBM_Y22]%s：　[font=SBM_B22]+%d[br]", desc, val)
end

-- 物品属性左半屏
function SkillBookMergeUI:createAttrPanel()
	local item_id = SkillBookMergeUI.target_id
	local jItem = findItem(item_id)
	if not jItem then
		return
	end

	self.left_panel.item_name_bg:loadTexture(string.format("%sbg_name_%d.png", prePath, jItem.quality),
								ccui.TextureResType.localType)

	self.left_panel.item_name:setColor(ItemData.getItemColor(jItem.quality))
	self.left_panel.item_name:setString(jItem.name)

	local rich_text = {}
	for _, v in pairs(jItem.attrs) do
		local jEffect = findEffect(v.first)
		local desc = insertSpaceIntoStr(jEffect.desc)
		local txt = createRichText(desc, v.second)
		rich_text[#rich_text+1] = txt
	end
	rich_text[#rich_text+1] = string.format("[font=SBM_BLK]%s[br]", jItem.desc)

	if not self.rich_text then
		self.rich_text = cc.Node:create()
		self.rich_text:setAnchorPoint(0, 0)
		self.rich_text:setPosition(34, 335)
		self.left_panel:addChild(self.rich_text, 4)
	else
		self.rich_text:removeAllChildren()
	end
	local txt = table.concat(rich_text)
	local lineSpace = 20
	if #rich_text > 4 then
		lineSpace = 12
	elseif #rich_text > 3 then
		lineSpace = 18
	end
	RichTextUtil:DisposeRichText(txt, self.rich_text, nil, 0, 300, lineSpace)
end

function SkillBookMergeUI:showMergeUI()
	self.right_panel.source_panel:setVisible(false)
	if self.tableView then self.tableView:setTouchEnabled(false) end
	self.right_panel.merge_panel:setVisible(true)
end

-- 来源滚动屏
function SkillBookMergeUI:createTableView()
	local function scrollViewDidScroll(view)
	end
    local function scrollViewDidZoom(view)
    end
    local function tableCellTouched(view, cell)
    	ActionMgr.save('UI', 'SkillBookMergeUI click source_panel')
    	local idx = cell:getIdx()
    	if idx < 0 or idx >= #self.copy_list then
    		return
    	end
    	local copy_data = self.copy_list[idx+1]
    	if AlteractData.cheakOpen(copy_data) then
    		TimerMgr.runNextFrame(function ()
    			AlteractData.goToFinsh(copy_data, 'SkillBookMergeUI')
    		end)
    	else
    		TipsMgr.showError(AlteractData.getLinkDesc(copy_data))
    	end
    end
    local function cellSizeForTable(view,idx) 
    	return 93, 338 
    end
    local function tableCellAtIndex(view, idx)
    	local cell = view:dequeueCell()
    	if not cell then
    		cell = cc.TableViewCell:new()
    		local copy_item = AlteractyTipsItem:new()
    		copy_item:updateData(self.copy_list[idx+1])
	    	copy_item:setTouchEnabled(false)
	    	cell:addChild(copy_item)
	    	cell.copy_item = copy_item
    	else
    		cell.copy_item:updateData(self.copy_list[idx+1])
    	end
    	return cell
    end
    local function numberOfCellsInTableView(view)
    	return #self.copy_list
    end
    
	self.tableView = UIFactory.getTableView(self.right_panel.source_panel, 360, 210, 5, 85)
    self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:reloadData()
end

function SkillBookMergeUI:showSourcePanel(item_id, material_id)
	local function clearChild()
		for i = 1, self.right_panel.source_panel_child_tag do
			self.right_panel.source_panel:removeChildByTag(i)
		end
		self.right_panel.source_panel_child_tag = 0
	end
	clearChild()

	local function addChild(child, zorder)
		self.right_panel.source_panel_child_tag = self.right_panel.source_panel_child_tag + 1
		self.right_panel.source_panel:addChild(child, zorder or 0, self.right_panel.source_panel_child_tag)
	end

	self.copy_list = AlteractData.getalterDatalist(const.kCoinItem, material_id, const.kCoinItem)
	if self.tableView then
		self.tableView:setTouchEnabled(true)
		self.tableView:reloadData()
	else
		self:createTableView()
	end

	local lastx = 46
	-- 副本列表左上角图标
	for i, v in ipairs(self.show_stack) do
		local icon = SkillBookItem.create(v, 0.58)
		icon:setPosition(lastx, 410)
		addChild(icon)

		UIMgr.addTouchBegin(icon.item_icon, function ()
			ActionMgr.save('UI', 'SkillBookMergeUI click merge_icon')
			while #self.show_stack > i do
				table.remove(self.show_stack)
			end
			self:showMergeUI()
			self:showMergePanel()
		end)

		local arrow = UIFactory.getSprite(prePath .. "arrow2.png", nil, lastx + 42, 408)
		addChild(arrow, 1)

		lastx = lastx + 84
	end

	self.right_panel.source_panel.target_bg:setPositionX(lastx+15)
	local material_icon = SkillBookItem.create(material_id, 0.75)
	material_icon:setPosition(lastx+16, 406)
	addChild(material_icon, 1)

    -- 互斥显示
	self.right_panel.merge_panel:setVisible(false)
	self.right_panel.source_panel:setVisible(true)
end

function SkillBookMergeUI:onMergeResult(id)
	if self.recurseMergeTarget then
		local target_id = self.show_stack[1]
		self.show_stack = { target_id }
		if id == self.recurseMergeTarget then
			self.recurseMergeTarget = nil
			TipsMgr.showSuccess("合成成功")
			return
		end
		self:recurseMerge(target_id)
	else
		TipsMgr.showSuccess("合成成功")
	end
end

function SkillBookMergeUI:recurseMerge(itemId, count)
	count = count or 1
	local jMerge = ItemData.getItemMergeForItemId(itemId)
	if not jMerge then
		return
	end

	for _, v in ipairs(jMerge.materials) do
		local got = ItemData.getItemCount(v.objid)
		if v.cate == const.kCoinItem and got < v.val then
			table.insert(self.show_stack, v.objid)
			self:recurseMerge(v.objid, v.val - got)
			return
		end
	end

	performWithDelay(self, function ()
		self:showMergePanel()
		Command.run('item merge', jMerge.id, count)
	end, 0.5)
end