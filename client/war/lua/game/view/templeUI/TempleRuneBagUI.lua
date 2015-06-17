local prePath = "image/ui/TempleUI/"
local resPath = "image/ui/bagUI/"
local url = prePath .. "TempleRuneBagUI.ExportJson"
TempleRuneBagUI = createUIClass("TempleRuneBagUI", url, PopWayMgr.SMALLTOBIG )

function TempleRuneBagUI:ctor( ... )
	self.item_contat={}
	self.index = 1
	self.pool = Pool.new()
	self.redPos = cc.p(70, 70)
	self.con_box = BoxContainer.new(5, 4, cc.p(70, 72), cc.p(11, 12), cc.p(10, 10))
	self.con_dw:addChild(self.con_box)
	function touchEndedHandler(sender, eventType)
		if sender and DateTools.getTime() - sender.time < 0.5 then
			local startPos = sender:getTouchStartPos()
			local endPos = sender:getTouchEndPos()
			if not cc.pFuzzyEqual(startPos, endPos, Config.FUZZY_VAR) then
				return
			end
			local index = self.con_box:hitTest(endPos)
			local sGlyph = self.userItem_list[index]
			if not sGlyph then
				return
			end
			if self.open_type == TempleData.RUNE_BOX_OPEN_BAG then
				if not TempleData.checkIsSameGlyph(sGlyph,self.index - 1) then
					TempleData.setCurFightValue(UserData.getFightValue())
					Command.run("temple embed",self.cur_select,self.index - 1,sGlyph.guid)
					performNextFrame(self,function( ) PopMgr.removeWindow(self) end)
				else
					TipsMgr.showError("不能镶嵌同一类型神符")
				end
			elseif self.open_type == TempleData.UPGRADE_OPEN_BAG then
				local win = PopMgr.getWindow('UpgradeRuneUI')
		        if win ~= nil then
		            win:setData(sGlyph)
		        end 
				performNextFrame(self,function( ) PopMgr.removeWindow(self) end)
			else
				if not TempleData.checkIsSameGlyph(sGlyph,self.index-1) then
					if self.index >= 0 then
						TempleData.setCurFightValue(UserData.getFightValue())
						Command.run("temple embed",self.cur_select,self.index ,sGlyph.guid)
						performNextFrame(self,function() PopMgr.removeWindow(self) end)
					end
				else
					TipsMgr.showError("不能镶嵌同一类型神符")
				end
			end
			TipsMgr.hideTips()
		end		
	end
	function touchBeginHandler( sender, eventType )
    	sender.time = DateTools.getTime()
    end
	UIMgr.addTouchEnded(self.con_dw, touchEndedHandler)
	UIMgr.addTouchBegin(self.con_dw, touchBeginHandler)

	self.select = UIFactory.getSprite(prePath .. "rune_bag_select.png")
	self.select:retain()
	
	local function onSelect( sender,type )
		if self.open_type == TempleData.RUNE_BOX_OPEN_BAG then
			return
		end
		self:onSelectHander(sender)
	end
	self.btn_list = {}
	for i=1,4 do
		local btn = self["btn_" .. (5-i)]
		btn.index = i
		table.insert(self.btn_list,btn)
		createScaleButton(btn)
		btn:addTouchEnded(onSelect)
	end
end

function TempleRuneBagUI:delayInit( ... )
	UIFactory.getTitleTriangle(self.bg_1, 1)
end

function TempleRuneBagUI:onSelectHander( sender )
	TempleData.setCurSelected(sender.index)
	self.cur_select = sender.index
	if self.open_type == TempleData.OPEN_BAG then
		self.index = TempleData.getEmptyIndex(self.cur_select)
		if TempleData.checkHasEmptyByType(self.cur_select) then
			self.tips_txt:setString(string.format("%s系尚有空余神符格，点击神符即可装备",TempleData.getTypeName( self.cur_select )))
			self.tips_txt:setVisible(true)
		else
			self.tips_txt:setVisible(false)
		end
	else
		self.tips_txt:setVisible(false)
	end
	if self.select then
		self.select:removeFromParent()
		sender:addChild(self.select)
		self.select:setVisible(true)
		self.select:setPosition(cc.p(40,50))
	end
	self:updateData()
end

function TempleRuneBagUI:onShow( ... )
	self.enableDelayUpdate = true
	if #self.item_contat == 0 then return end
	self.cur_select = TempleData.getCurSelected()
    performNextFrame(self,function ()
        if self.cur_select >= 0 then
            local cell = self.tableView:cellAtIndex(self.cur_select)
            if not cell then return end
            local item = cell:getChildByTag(1).view
            item.select_bg:setVisible(true)
            item.item_bg:loadTexture("Rune/img_rune_item_select_bg.png",ccui.TextureResType.plistType)
        end
    end)
    self:updateData()
end

function TempleRuneBagUI:onClose( ... )
	for _,arr in pairs(self.pool.pool) do
        for _,v in ipairs(arr) do
            v:release() --释放内存池
        end
    end
    self.pool:clear()
end

function TempleRuneBagUI:updateData( ... )

	self.userItem_list = TempleData.getRuneListByType(self.cur_select)
 	self:updateWDW()
 	if self.open_type == TempleData.OPEN_BAG then
	 	for i,v in ipairs(self.btn_list) do
			setButtonPoint(v, TempleData.checkHasEmptyByType(i), self.redPos, 200)
	 	end
	elseif self.open_type == TempleData.RUNE_BOX_OPEN_BAG then
		for i,v in ipairs(self.btn_list) do
			if i ~= self.cur_select then
				ProgramMgr.setGray(v)
				ProgramMgr.setGray(v.icon)
				v:setTouchEnabled(false)
			end
	 	end
	end

end

function TempleRuneBagUI:updateWDW()
	local con = self.con_box
	local list = self.userItem_list
	--TotemData.sortGlyphByType(list, parent.jTotem.type)
	self.sGlyphList = list
    local currentGlyph = nil

	for i = 1, con.count do
		local cell = con:getNode(i)
		if cell and cell.icon then
			self:disposeDwObject(cell.icon)
			cell.icon = nil
		end
	end
	con:setNodeCount(#list)
	local function updateOneNode(i)
		local cell = con:getNode(i)
		if not cell then
			cell = UIFactory.getLayout(74, 74)
			cell:setTouchEnabled(false)
			cell.bg = UIFactory.getSpriteFrame("RuneBag/box_rune_bag_3.png", cell, 30, 30)
			cell.state = UIFactory.getSpriteFrame("RuneBag/txt_equiped.png", cell, 30, 0, 2)
			cell.state:setVisible(false)
			con:addNode(cell, i)
		end
		local hasMark = false
		cell.state:setVisible(false)
		if i <= #list then
			local jGlyph = findTempleGlyph(list[i].id)
			cell.icon = self:addDwObject(jGlyph, cell, 30, 30, list[i])
			cell.icon.lv:setString("Lv"..list[i].level)
			if list[i].embed_type > 0 then
				cell.state:setVisible(true)
			end 
			hasMark = currentGlyph and list[i].guid == currentGlyph.guid
			-- if jGlyph.type ~= parent.jTotem.type then
			-- 	ProgramMgr.setGray(cell.icon.icon)
			-- end
		end
		if hasMark then
			if not cell.mark then
				cell.mark = UIFactory.getSpriteFrame("head_mark.png", cell, 45, 20, 10)
			end
		else
			if cell.mark then
				cell.mark:removeFromParent()
				cell.mark = nil
			end
		end
	end
	con:reloadData(updateOneNode, self.enableDelayUpdate)
	self.enableDelayUpdate = nil

	local scrollSize = cc.size(375, math.max(260, con:getHeight() + 35))
	self.con_dw:setInnerContainerSize(scrollSize)
	con:setPosition(0, scrollSize.height)
end

function TempleRuneBagUI:dispose( ... )
	-- body
	if self.select then
		self.select:release()
	end
end

function TempleRuneBagUI:setData( type,select, index)
	self.open_type = type
	self.index = index
	self.cur_select = select
	local btn = self.btn_list[select]
	if btn then 
		self:onSelectHander(btn)
	end
end


function TempleRuneBagUI:addDwObject(jGlyph, parent, x, y, sGlyph)
    local name = jGlyph.icon
    local dw = nil
    local lv = nil
    if self.pool then
        dw = self.pool:getObject(name)
    end
    if not dw then
        dw = TempleData.getGlyphObject(jGlyph.id, self.winName, parent, x, y, sGlyph)
        dw.lv = UIFactory.getText("", dw, 50, 50, 16,nil,nil,nil,2)
    else
        dw.jGlyph = jGlyph
        dw.sGlyph = sGlyph
        dw:play()
        dw:setPosition(x, y)
        parent:addChild(dw)
        dw:release()
    end
    dw:setOpacity(255)
    dw:setScale(1) -- 默认缩放倍数
    return dw
end

function TempleRuneBagUI:disposeDwObject(dw)
    ProgramMgr.setNormal(dw.icon)
    dw:retain()
    dw:stop()
    self.pool:disposeObject(dw._dwname, dw)
    dw:removeFromParent()
end