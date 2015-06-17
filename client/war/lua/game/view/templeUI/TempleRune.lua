
require("lua/game/view/templeUI/TempleRuneBoxes.lua")
local prePath = "image/ui/TempleUI/"
local url = prePath .. "TempleRuneUI.ExportJson"
TempleRune = createUIClass("TempleRune", url, PopWayMgr.SMALLTOBIG )

local TargetItem = createUIClass("TargetItem",prePath .. "TempleRuneItem.ExportJson")

function TargetItem:ctor( ... )
	self:setTouchEnabled(true)
end

function TempleRune:ctor()
    self.rune_list = {const.kEquipPlate,const.kEquipMail,const.kEquipLeather,const.kEquipCloth}
    self.item_contat = {}
    self.cur_select = self.rune_list[1]
    self.data_list = {}
    self.pool = Pool.new()
    TempleData.setCurSelected(4)

	local function btnHandler(sender,type)
		local name = sender:getName()
		if name == "look_btn" then
            Command.run("ui show","TempleRuneBagUI",PopUpType.SPECIAL)
            local win = PopMgr.getWindow('TempleRuneBagUI')
            if win ~= nil then
                win:setData(TempleData.OPEN_BAG,TempleData.getCurSelected(),0 )
            end 
		elseif name == "upgrade_btn" then
			Command.run("ui show","UpgradeRuneUI", PopUpType.SPECIAL)
		else
			--Command.run("ui show","UpgradeRuneUI",PopUpType.SPECIAL)
            Command.run("ui show", "Store", PopUpType.SPECIAL)
		end
	end 
	createScaleButton(self.look_btn)
	self.look_btn:addTouchEnded(btnHandler)
	createScaleButton(self.upgrade_btn)
    self.upgrade_btn:setTouchEnabled(true)
	self.upgrade_btn:addTouchEnded(btnHandler)
	createScaleButton(self.buy_btn)
    self.buy_btn:setTouchEnabled(true)
	self.buy_btn:addTouchEnded(btnHandler)
	-- for k,v in pairs(rune_list) do
	-- 	local item = getLayout(prePath .. "TempleRuneItem.ExportJson")
	-- end
    local function glyphTouchBegin( touch, event )
        -- body
        attrs = TempleData.getGlyphAttrByType(self.cur_select)
        local pos = touch:getLocation()
        TipsMgr.showTips(pos, TipsMgr.TYPE_RUNE_TOTAL_ATTR, attrs,self.cur_select)
    end

    buttonDisable(self.search_btn,false)
    -- UIMgr.addTouchBegin(self.search_btn,glyphTouchBegin)
    UIMgr.registerScriptHandler(self.search_btn, glyphTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN, true)
    UIMgr.registerScriptHandler(self.type_icon, glyphTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN, true)
    -- self.search_btn:setTouchEnabled(false)

    self.boxes = TempleRuneBoxes.new(self)
    self:addChild(self.boxes)

	if self.tableView == nil then
        self:initTableView()
    end
    self.tableView:setVisible(true)
    self.dataLen = 4
    -- self.oldPercent = self.percent
    self.tableView:reloadData()
end

function TempleRune:initTableView( ... )
    function self.updateItemData(data ,constant, dataIndex, itemIndex, widhtCount )
        constant.index = dataIndex
        local type = self.rune_list[dataIndex]
        if constant and constant.view then
           constant.view.select_bg:setVisible(false)
           constant.view.txt:setString(TempleData.getRuneTypeName(type))
           constant.view.icon:loadTexture("Rune/s" .. TempleData.getRuneTypeIcon(type),ccui.TextureResType.plistType)
        end
    end

    function self.create()
        local content = display.newLayer()
        content:setAnchorPoint(cc.p(0,0))
        content:setPosition(cc.p(0, 0))
        content:setTag(1)
        local view = self:createItem()
        content:addChild(view)
        content.view = view
        view:setPosition(0,0)

        return content
    end

    function self.touchCell( content, index, itemIndex )
        self.cur_select = self.rune_list[index]
        for k,v in pairs(self.item_contat) do
            v.select_bg:setVisible(false)
            v.item_bg:loadTexture("Rune/img_rune_item_bg.png",ccui.TextureResType.plistType)
        end
        if content and content.view then
            content.view.select_bg:setVisible(true)
            content.view.item_bg:loadTexture("Rune/img_rune_item_select_bg.png",ccui.TextureResType.plistType)
            self.type_icon:loadTexture("Rune/b" .. TempleData.getRuneTypeIcon(self.cur_select),ccui.TextureResType.plistType)
            self.data_list = TempleData.getEmbedListByType(self.cur_select)
            self.boxes:setData(self.data_list,self.cur_select)

        end
    end

    local function scrollViewDidScroll(view)
        local TableHeight = self.tcellHeigth * self.dataLen
        local viewHeight = 435
        local ScrollOffH = math.max(0,TableHeight - viewHeight)
        local curY = self.tableView:getContentOffset().y
        if ScrollOffH > 0 then
            self.percent = curY / ScrollOffH * 100
        else
            self.percent = nil
        end
        --self.percent = math.ceil( self.tableView:getContentOffset().y / self.ScrollOffH * 100)
    end
    self.tableView = createTableView({}, self.create,self.updateItemData, cc.p( 15, 15 ),cc.size(238,428), cc.size(238,108), self, self.slider, 1 ,2)
    self.tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL )
end

function TempleRune:createItem( ... )
    local item = getLayout(prePath .. "TempleRuneItem.ExportJson")
    local function btnHandler(sender,eveType )
    end
    --UIMgr.addTouchEnded( item.icon_face, btnHandler )
    item:setTouchEnabled(false)
    -- UIMgr.addTouchEnded( item.btn_get, btnHandler )
    -- item:retain()
    -- --createScaleButton(item,nil,nil,nil,nil,1.05)
    table.insert(self.item_contat,item)
    return item
end

function TempleRune:onShow( ... )
	if #self.item_contat == 0 then return end
    performNextFrame(self,function ()
        if self.cur_select >= 0 then
            local index = gameData.indexOfArray(self.rune_list,self.cur_select)
            local cell = self.tableView:cellAtIndex(index-1)
            if not cell then return end
            local item = cell:getChildByTag(1).view
            item.select_bg:setVisible(true)
            item.item_bg:loadTexture("Rune/img_rune_item_select_bg.png",ccui.TextureResType.plistType)
            self.type_icon:loadTexture("Rune/b" .. TempleData.getRuneTypeIcon(self.cur_select),ccui.TextureResType.plistType)
            self.data_list = TempleData.getEmbedListByType(self.cur_select)
            self.boxes:setData(self.data_list,self.cur_select)
        end
    end)
    self:updateData()
end

function TempleRune:updateData( ... )
    -- body
    local list = {}
    for k,v in pairs(self.item_contat) do
        local type = self.rune_list[k]
        list = TempleData.getEmbedListByType(type)
        local len = TempleData.getBoxLenById(type)
        for i=1,8 do
            if i <= len then
                local data = gameData.findArrayData(list,"embed_index",i-1)
                if data then
                    local jGlyph = findTempleGlyph(data.id)
                    v["pt_"..i]:loadTexture("Rune/pt_rune_" .. jGlyph.quality ..".png",ccui.TextureResType.plistType)
                else
                    v["pt_"..i]:loadTexture("Rune/pt_rune_1.png",ccui.TextureResType.plistType)
                end
            else
                v["pt_"..i]:loadTexture("Rune/pt_rune_0.png",ccui.TextureResType.plistType)
            end
        end
    end
end

function TempleRune:onClose( ... )
	--移除所有雕文
    for _,arr in pairs(self.pool.pool) do
        for _,v in ipairs(arr) do
            v:release() --释放内存池
        end
    end
    self.pool:clear()
end

function TempleRune:dispose( ... )
	if #self.item_contat > 0 then
        for i=1,#self.item_contat do
            self.item_contat[i]:release()
        end
    end
end

function TempleRune:createView()
   local view = TempleRune.new()
   return view 
end 


function TempleRune:addDwObject(jGlyph, parent, x, y, sGlyph)
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

function TempleRune:disposeDwObject(dw)
    ProgramMgr.setNormal(dw.icon)
    dw:retain()
    dw:stop()
    self.pool:disposeObject(dw._dwname, dw)
    dw:removeFromParent()
end