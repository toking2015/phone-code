local prePath = "image/ui/TempleUI/"
local resPath = "image/ui/bagUI/"

local url = prePath .. "UpgradeRuneUI.ExportJson"
UpgradeRuneUI = createUIClass("UpgradeRuneUI", url, PopWayMgr.SMALLTOBIG )

function UpgradeRuneUI:ctor()
	self.txt_list = {}
	self.progress.light_img:setVisible(false)
	self.sGlyph = nil
	self.box = nil
	self.pShowNode = nil
	self.index = 0
	self.pool = Pool.new()
	-- local pos = cc.p(self.lv_txt:getPosition())
	self.limit_lv = UIFactory.getText("", self, 134, 428, 24, cc.c3b(0xff,0xed,0xa8))

	self.cell = UIFactory.getLayout(74, 74)
	self.cell:setTouchEnabled(false)
	self:addChild(self.cell)
	self.cell:setPosition(114,288)

	local function helpHandler( sender )
		-- local str = string.format("战队%s级时神符等级上限将提升至%s",)
		-- TipsMgr.showTips(cc.p(sender:getPosition()),TipsMgr.TYPE_STRING,str)
	end
	-- createScaleButton(self.help_btn)
	-- self.help_btn:setTouchEnabled(helpHandler)
		
	self.con_box = BoxContainer.new(5, 5, cc.p(78, 74), cc.p(11, 12), cc.p(10, 10))
	self.con_dw:addChild(self.con_box)

	self.box = UIFactory.getLayout(74, 74)
	self.box:setTouchEnabled(false)
	self:addChild(self.box,2)
	self.box:setPosition(114,288)

	local function onSelectHandler( ... )
		Command.run("ui show","TempleRuneBagUI",PopUpType.SPECIAL)
		local win = PopMgr.getWindow('TempleRuneBagUI')
        if win ~= nil then
            win:setData(TempleData.UPGRADE_OPEN_BAG,TempleData.getCurSelected(),0 )
        end 
	end
	createScaleButton(self.select_btn)
	self.select_btn:addTouchEnded(onSelectHandler)

	local function completeHandler()
		if self.box and self.box.icon then
			self:disposeDwObject(self.box.icon)
			self.box.icon = nil
		end
		-- self.box:removeFromParent()
		self.con_dw:setTouchEnabled(true)
	end
	local function playAction(  )
		local sbox = self.con_box:getNode(self.index)
		local pos = sbox:getParent():convertToWorldSpace(cc.p(sbox:getPosition()))
		pos.x = pos.x - (self:getPositionX() - self:getContentSize().width / 2) - 40
		pos.y = pos.y - (self:getPositionY()	- self:getContentSize().height / 2) + 20
		-- local pp = cc.p(sbox:getParent():getPosition())
		-- local pos = self.touchPos		
		self.box.icon = self:addDwObject(self.jGlyph, self.box, 42, 42, self.sGlyph)
		self.box:setPosition(pos.x,pos.y)
		-- self.box:setPosition(pos.x,pos.y)
		local duration = 0.5
		local moveToLeft = cc.MoveTo:create(duration, cc.p(114, 288))
		local scaleAct = cc.ScaleTo:create(duration, 1)
		local fadeoutAct = cc.FadeOut:create(duration)
		self.box:runAction(cc.Sequence:create(cc.Spawn:create(moveToLeft, scaleAct, fadeoutAct), cc.CallFunc:create(completeHandler)))
		self.con_dw:setTouchEnabled(false)
	end 
	local function okFun( ... )
		playAction()
		SoundMgr.playEffect("sound/ui/UI_TTenergy.mp3")
		Command.run("temple train" ,self.data.guid,self.sGlyph.guid)
	end

	local function callfunc( ... )
		self.pShowNode.count = self.pShowNode.count + 1
		if self.pShowNode.count < 5 then
			self.pShowNode:gotoAndPlay(1)
			self.pShowNode:play()
			return
		end
        self.pShowNode:stop()
        self.pShowNode:removeNextFrame()
        self.pShowNode = nil
	end
	local function showEffect( ... )
		if self.pShowNode then
			return
		end
		local path = 'image/armature/ui/InductUI/xsz-tx-01/xsz-tx-01.ExportJson'
		-- local path = 'image/armature/ui/InductUI/'
		LoadMgr.loadArmatureFileInfo(path, LoadMgr.WINDOW, "xsz-tx-01" )
		-- self.pShowNode = ArmatureSprite:addArmatureEx( path , "xsz-tx-01",self.winName,self,callfunc, 160, 230,5 )
		self.pShowNode = ArmatureSprite:addArmatureTo( self, path , "xsz-tx-01", 160, 230,nil,2 )
		self.pShowNode.count = 0
		self.pShowNode:onPlayComplete(callfunc)
	end
	
	local function touchEndedHandler(sender, eventType)
		if sender and DateTools.getTime() - sender.time >= 0.5 then
			return
		end
		TipsMgr.hideTips()

		local startPos = sender:getTouchStartPos()
		local endPos = sender:getTouchEndPos()
		if not cc.pFuzzyEqual(startPos, endPos, Config.FUZZY_VAR) then
			return
		end
		local index = self.con_box:hitTest(endPos)
		self.index = index
		local sGlyph = self.userItem_list[index]
		self.sGlyph = sGlyph
		self.touchPos = startPos
		if not sGlyph then
			return
		end
		if not self.data then
			showEffect()
			TipsMgr.showError("请选择神符")
			return
		end

		local data = TempleData.getGlyphByGuid(self.data.guid)
		local jDataGlyph = findTempleGlyph(self.data.id)
		local jGlyph = findTempleGlyph(sGlyph.id)
		self.jGlyph = jGlyph

		if data.guid == sGlyph.guid then
			TipsMgr.showError("不能吞噬同一物品")
			return
		end
		if data.level >= TempleData.getMaxLevel() then
			SoundMgr.playEffect("sound/ui/UI_TTfull.mp3")
			TipsMgr.showError("已达等级上限")
			return
		end
		if sGlyph.embed_type > 0 then
			showMsgBox("神符已装备，是否吞噬？", okFun)
			return
		end
		if jDataGlyph.quality < jGlyph.quality then
			showMsgBox("将要吞噬较高品质的神符，是否确定？", okFun)
			return
		end
		playAction()
		TipsMgr.showGreen("+"..jGlyph.exp,300,140)
		Command.run("temple train" ,data.guid,sGlyph.guid)
		SoundMgr.playEffect("sound/ui/UI_TTenergy.mp3")
	end
	local function touchBeginHandler( sender, eventType )
    	sender.time = DateTools.getTime()
    end
	UIMgr.addTouchEnded(self.con_dw, touchEndedHandler)
	UIMgr.addTouchBegin(self.con_dw, touchBeginHandler)
	
	self.lv_txt:setString(0)
	self.limit_txt:setString(0)
	self.help_btn:setVisible(false)
end

function UpgradeRuneUI:showIntroArmature()
	local tswc = loadCompleteArmature("xsz-tx-01", self)
    local function callfunc()
        tswc:stop()
        tswc:removeNextFrame()
    end
    tswc:onPlayComplete(callfunc)
end

function UpgradeRuneUI:delayInit( ... )
	UIFactory.getTitleTriangle(self.bg_1, 1)
end

function UpgradeRuneUI:onShow()
	self.enableDelayUpdate = true
	EventMgr.addListener(EventType.TempleInfo,self.updateData,self)
	performNextFrame(self, self.delayOnShow, self)
end

function UpgradeRuneUI:delayOnShow()
	self:updateData()

end

function UpgradeRuneUI:onClose( ... )
	-- body
	EventMgr.removeListener(EventType.TempleInfo,self.updateData)
end

function UpgradeRuneUI:updateData( ... )
	self:clearTxt()
	self:updateWDW()
	self.userItem_list = TempleData.getData().glyph_list
	table.sort(self.userItem_list,TempleData.sortFunc)
    local cell = self.cell
    
    if cell and cell.icon then
		self:disposeDwObject(cell.icon)
		cell.icon = nil
	end

	local data = nil
	if self.data then
		data = TempleData.getGlyphByGuid(self.data.guid)
	end
	if not data then
		self.lv_img:setVisible(false)
		self.lv_txt:setVisible(false)
		self.limit_txt:setVisible(false)
		self.name_txt:setString("") 
		return
	end
	self.lv_img:setVisible(true)
	self.lv_txt:setVisible(true)
	self.limit_txt:setVisible(false)
	local jGlyph = findTempleGlyph(data.id)
	cell.icon = self:addDwObject(jGlyph, cell, 42, 42, data)
	cell.icon.lv:setString("Lv"..data.level)
	local jGlyphAttr = findTempleGlyphAttr(data.id,data.level)
	local jNextGlyphAttr = findTempleGlyphAttr(data.id,data.level + 1)
	self.name_txt:setString(jGlyph.name)
	for k,v in pairs(jGlyphAttr.attrs) do
		-- local px = (k - 1) % 2 * 88 + 65
		-- local py = 195 - math.floor((k - 1)/2)  * 25 
		local px = 80
		local py = 220 - k * 25
		
		self:creatTxt(findEffect(v.first).desc,self, px, py, cc.c3b(0xff, 0xda, 0x00))
		
		if jNextGlyphAttr then
			local attr = jNextGlyphAttr.attrs[k]
			self:creatTxt("+" .. v.second ,self, px + 60, py, cc.c3b(0xff, 0xff, 0xff))
			self:creatTxt("(下级  +"..attr.second..")",self, px + 140, py , cc.c3b(0x7e, 0xff, 0x00))
			-- self:creatTxt("+" .. attr.second ..")",self, px + 180, py , cc.c3b(0x7e, 0xff, 0x00))
		else
			self:creatTxt("+" .. v.second,self, px + 60, py, cc.c3b(0xff, 0xff, 0xff))
			self:creatTxt("(满级)",self, px+120, py, cc.c3b(0x7e, 0xff, 0x00))
		end
	end


	jGlyphNext =  findTempleGlyphAttr(data.id,data.level + 1)
	self.lv_txt:setString(data.level)
	self.limit_txt:setString(TempleData.getMaxLevel())
	self.limit_lv:setString("/"..TempleData.getMaxLevel())

	local progressLay = self.progress
	local percent = data.exp / jGlyphNext.exp * 100

    progressLay.ProgressBar:setPercent(percent)
    progressLay.lb_txt:setString(data.exp .."/".. jGlyphNext.exp)
    progressLay.light_img:setPositionX(progressLay.ProgressBar:getPositionX() + (percent - 50) / 100 * progressLay.ProgressBar:getSize().width)
end

function UpgradeRuneUI:creatTxt(str,parent,px,py,c3b )
	local txt =  UIFactory.getText(str, parent, px, py, 18, c3b)
	table.insert(self.txt_list,txt)
	-- return txt
end

function UpgradeRuneUI:updateWDW()
	local con = self.con_box
	local list = TempleData.getData().glyph_list
	table.sort(list,TempleData.sortFunc)
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

function UpgradeRuneUI:clearTxt( ... )
	for i,v in ipairs(self.txt_list) do
		v:removeFromParent()
	end
	self.txt_list={}
end

function UpgradeRuneUI:dispose()
	for _,arr in pairs(self.pool.pool) do
        for _,v in ipairs(arr) do
            v:release() --释放内存池
        end
    end
    self.pool:clear()
end

function UpgradeRuneUI:setData( data )
	self.data = data
	self:updateData()
end

function UpgradeRuneUI:addDwObject(jGlyph, parent, x, y, sGlyph)
    local name = jGlyph.icon
    local dw = nil
    local lv = nil
    dw = self.pool:getObject(name)
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

function UpgradeRuneUI:disposeDwObject(dw, isRelease)
    ProgramMgr.setNormal(dw.icon)
    dw:stop()
    dw:retain()
    self.pool:disposeObject(dw._dwname, dw)
    dw:removeFromParent()
end