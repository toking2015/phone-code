local prePath = "image/ui/TempleUI/"
TempleRuneBoxes = createUIClass('TempleRuneBoxes', prePath .. "TempleRuneBoxes.ExportJson")

function TempleRuneBoxes:ctor( parent )
	self.parent = parent
	self.redPos = cc.p(70, 70)
	self.target_index = 0
	self.boxes = {}
	self.nodeMap = {}
	self.len = 0
	self.data_list = {}
	local content = display.newLayer()
    content:setAnchorPoint(cc.p(0,0))
    content:setPosition(cc.p(0, 0))
    content:setTag(10)
    content.itemList = {}
    self:addChild(content,10)
    content:setVisible(true)

    local function okFun( ... )
    	if not TempleData.checkIsEnoughOpen(1,self.target_index) and not TempleData.checkIsEnoughOpen(2,self.target_index) then
			--TipsMgr.showError("钻石不足")
			return
		else
			if not TempleData.checkIsEnoughOpen(1,self.target_index) then
				Command.run("temple openhole",self.cur_select,0)
			else
				Command.run("temple openhole",self.cur_select,1)
			end			
		end
    end 

    function touchEndedHandler(sender, eventType)
	    if sender and DateTools.getTime() - sender.time < 0.5 then
	    	self.target_index = sender.index
	    	if sender.index == self.len + 1 then
	    		showMsgBox(string.format("是否消耗%s或%s开启格子？[br]剩余拓展卷轴：%s",TempleData.getOpenItemString(1,sender.index),TempleData.getOpenItemString(2,sender.index),TempleData.getPackNum(sender.index)), okFun)
	    	elseif sender.index <= self.len then
		    	Command.run("ui show","TempleRuneBagUI",PopUpType.SPECIAL)
				local win = PopMgr.getWindow('TempleRuneBagUI')
		        if win ~= nil then
		            win:setData(TempleData.RUNE_BOX_OPEN_BAG,self.cur_select,sender.index )
		        end 
		    end
		    TipsMgr.hideTips()
		end
    end

    function touchBeginHandler( sender, eventType )
    	sender.time = DateTools.getTime()
    end

	for i = 1,const.kTempleHoleMaxCount do
		local cell = self:getNode(i)
		if not cell then
			cell = UIFactory.getLayout(74, 74)
			cell.index = i
			cell.bg = UIFactory.getSpriteFrame("Rune/box_rune_0.png", cell, 42, 42)
			cell.lock = UIFactory.getSpriteFrame("Rune/img_rune_locked.png", cell, 42, 42)
			cell.lock:setVisible(false)

			cell.add = UIFactory.getSpriteFrame("Rune/img_rune_add.png",cell,42,42)
			cell.add:setVisible(false)
			cell.add.index = i
			self:addNode(cell, i)
			UIMgr.addTouchEnded(cell, touchEndedHandler)
			UIMgr.addTouchBegin(cell, touchBeginHandler)
			-- local function touchEndedHandler(touch, event)
   --          	TipsMgr.hideTips()
   --          end
   --          UIMgr.registerScriptHandler(cell, touchEndedHandler, cc.Handler.EVENT_TOUCH_ENDED, true)
		end
	end

end

function TempleRuneBoxes:onShow( ... )
	-- body
end

function TempleRuneBoxes:onClose( ... )

end

function TempleRuneBoxes:UpdateData( ... )
	local data = nil
	local cell = nil
	for k,v in pairs(self.nodeMap) do
		local cell = self:getNode(k)
		if cell and cell.icon then
			self.parent:disposeDwObject(cell.icon)
			cell.icon = nil
		end
		cell.add:setVisible(false)
		cell.lock:setVisible(false)
		cell:setTouchEnabled(true)
		-- data = self.data_list[k]
		setButtonPoint(cell, TempleData.checkIsEmpty(self.cur_select,k - 1), self.redPos, 200)
		data = gameData.findArrayData(self.data_list,"embed_index",k-1)
		if k <= self.len then
			if data then
				local jGlyph = findTempleGlyph(data.id)
				cell.icon = self.parent:addDwObject(jGlyph, cell, 42, 42, data)
				UIFactory.setSpriteChild(cell,"bg",true,"Rune/box_rune_" .. jGlyph.quality .. ".png",42,42)
				cell.icon.lv:setString("Lv"..data.level)
			else
				UIFactory.setSpriteChild(cell,"bg",true,"Rune/box_rune_1.png",42,42)
				cell.add:setVisible(true)
			end
		else
			UIFactory.setSpriteChild(cell,"bg",true,"Rune/box_rune_0.png",42,42)
			cell.lock:setVisible(true)
			cell.add:setVisible(false)
			if TempleData.checkOpenRedPoint(self.cur_select,k) then
				cell.lock:setSpriteFrame("Rune/txt_unlock.png")
			else
				cell.lock:setSpriteFrame("Rune/img_rune_locked.png")
				cell:setTouchEnabled(false)
			end
		end
	end
end

function TotemUI:updateRed()
	--刷新红点
	-- setButtonPoint(self.btn_1, TotemData.checkBottomRedPoint(), self.redPos, 200)	
end

function TempleRuneBoxes:setData( list,type)
	self.data_list = list
	self.cur_select = type
	self.len = TempleData.getBoxLenById(type)
	self:UpdateData()
	
end

function TempleRuneBoxes:addNode(node, index)
	self.nodeMap[index] = node
	self:addChild(node)
    local pos = cc.p(self["box_" .. index]:getPosition())
    local dx = pos.x - 41
    local dy = pos.y - 41
	node:setPosition(dx, dy)
end

function TempleRuneBoxes:removeNode(index)
	local node = self.nodeMap[index]
	self:removeChild(node)
	self.nodeMap[index] = nil
	return node
end

function TempleRuneBoxes:getNode(index)
	return self.nodeMap[index]
end