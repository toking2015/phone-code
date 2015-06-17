require("lua/game/view/templeUI/TempleGroupList.lua")
require("lua/game/view/templeUI/TempleItem.lua")
local prePath = "image/ui/TempleUI/"
local url = prePath .. "TempleCollectUI.ExportJson"
TempleCollect = createUIClass("TempleCollect", url, PopWayMgr.SMALLTOBIG )


function TempleCollect:ctor()
	self.txt_list = {}
	self.cur_selected = 0
	self.item_list = {}
	
	self.tips = LabelBatch.new(3,18,cc.c3b(0xff,0xed,0xa8))
	self:addChild(self.tips)
	self.tips:setPosition(405,32)

	local function onUpgrade()
		if(TempleData.CheckIsCanLvUp(self.jGroup.id)) then
			TempleData.setCurFightValue(UserData.getFightValue())
			Command.run("temple lvup" ,self.jGroup.id)
		else
			TipsMgr.showError("组合星级未达到")
		end
	end
	local function onDetail()
		Command.run("ui show","TempleAttrSummary",PopUpType.SPECIAL)
	end

	self.btn_prev:setTouchEnabled(false)
	ProgramMgr.setNormal(self.btn_prev)
	self.btn_next:setTouchEnabled(false)
	ProgramMgr.setNormal(self.btn_next)
	createScaleButton(self.btn_prev)
	createScaleButton(self.btn_next)
	createScaleButton(self.upgrade_btn)
	self.upgrade_btn:addTouchEnded(onUpgrade)
	createScaleButton(self.detail_btn)
	self.detail_btn:addTouchEnded(onDetail)
	local function selectGroupChange(jGroup)
		if(self.jGroup == jGroup) then return end
		self.item_list = {}
		self.jGroup = jGroup
		for i,v in ipairs(jGroup.members) do
			local item = TempleItem.new()
			item:setAnchorPoint(cc.p(0, 0))
			table.insert(self.item_list,item)
			item:setData(v)
		end
		self.group_name:setString(jGroup.name)
		self:updateData()

		if #self.item_list > 4 then
			self.btn_prev:setVisible(true)
			self.btn_next:setVisible(true)
			initScrollviewWith(self.ScrollView, self.item_list, #self.item_list, 0,30,30,0)
		else
			self.btn_prev:setVisible(false)
			self.btn_next:setVisible(false)
			local pos = (4 - #self.item_list) * 110 / 2 
			initScrollviewWith(self.ScrollView, self.item_list, #self.item_list, pos,30,30,0)
		end
	end
	self.name_list = TempleGroupList.new(selectGroupChange)
	self:addChild(self.name_list)
	self:configureTouchFunc()
	self:configureEventFunc()
	self:setBtnEnabled()
end

function TempleCollect:setBtnEnabled( ... )
	if #self.item_list <= 4 then
		self.btn_next:setTouchEnabled(false)
		ProgramMgr.setGray(self.btn_next)
	end
	if self.cur_selected == 0 then
		self.btn_prev:setTouchEnabled(false)
		ProgramMgr.setGray(self.btn_prev)
	elseif self.cur_selected == #self.item_list then
		self.btn_next:setTouchEnabled(false)
		ProgramMgr.setGray(self.btn_next)
	end
end

function TempleCollect:configureTouchFunc( ... )
	local left_arrow = createScaleButton(self.btn_prev)
	local right_arrow = createScaleButton(self.btn_next)
	local function arrowTouchFunc(ref,eventType)
		if ref == left_arrow then
			self.cur_selected = self.cur_selected - 1
		else
			self.cur_selected = self.cur_selected + 1
		end
	end 
	left_arrow:addTouchEnded(arrowTouchFunc)
	right_arrow:addTouchEnded(arrowTouchFunc)
end

-- 事件监听处理
function TempleCollect:configureEventFunc()
	self.event_list = {}
	-- self.event_list[EventType.showSelectBox] = function(level)
	-- 	LogMgr.debug('touch btn = ', level)
	-- 	self.cur_selected = level
	-- 	TempleData.setCurSelected(level)
	-- end

	self.event_list[EventType.TempleChangeSelect] = function(data)
		self:setBtnEnabled()
		-- local btn = self.item_list[self.cur_selected + 1]
		-- if not btn then return end
		-- if self.selected_box and self.selected_box:getParent() then self.selected_box:removeFromParent() end
		-- btn:addChild(self.selected_box)

		local isMove, direction = TempleData.isMove(data.prev, data.curr)
		if true == isMove then
			local posX = self.item_list[data.curr + 1]:getPositionX()
			local sW, iW = 450, self.vip_bg.con_vip:getInnerContainerSize().width
			local percent = (posX + direction * (106 + 6) - 6)/(iW - sW)*100
			self.vip_bg.con_vip:scrollToPercentHorizontal(percent, 0.5, true)
		end
		self:updateData()
	end
end

function TempleCollect:onShow()
	self.name_list:onShow()
end

function TempleCollect:onClose( ... )
	
end

function TempleCollect:updateData()
	-- body
	self:clearTxt()
	if(self.jGroup == nil) then return end
	local is_collected = false
	self.lv_txt:setVisible(false)
	self.lv_img:setVisible(false)
	local sTempleGroup = TempleData.getTempleGroupById(self.jGroup.id)
	if sTempleGroup ~= nil then
		is_collected = true
		self.lv_txt:setString(sTempleGroup.level)
		self.lv_txt:setVisible(true)
		self.lv_img:setVisible(true)
	end

	if TempleData.getTempleGroupById(self.jGroup.id) then
		self.upgrade_btn:setVisible(true)
		self.un_collect_img:setVisible(false)
	else
		self.upgrade_btn:setVisible(false)
		self.un_collect_img:setVisible(true)
	end
	
	local jNextLvUp = nil
	local list = {}
	if(is_collected == true) then
		local star = TempleData.getGroupStar(self.jGroup)
		local jLvUp = findTempleGroupLevelUp(self.jGroup.id,sTempleGroup.level)
		jNextLvUp = findTempleGroupLevelUp(self.jGroup.id,sTempleGroup.level + 1)
		list = jLvUp.attrs
		if jNextLvUp then
			self.tips:setString("总星级达",star,"/"..jNextLvUp.star.."可升级")
			if star >= jNextLvUp.star then
				self.tips:setFontColor(2, cc.c3b(0x7e, 0xff, 0x00))
			else
				self.tips:setFontColor(2, cc.c3b(0xff, 0x00, 0x00))
			end
			self.upgrade_btn:setVisible(true)
		else
			self.tips:setString("","","")
			self.upgrade_btn:setVisible(false)
		end	
		self.collect_txt:setVisible(true)
	else 
		self:creatTxt("达到最高等级（5级）时获得属性：",self, 252, 208 ,20, cc.c3b(0x7e, 0xff, 0x00))
		self.collect_txt:setVisible(false)
		list = findTempleGroupLevelUp(self.jGroup.id,5).attrs
		self.tips:setString("","","")
	end
	for k,v in pairs(list) do
		local px = (k - 1) % 2 * 250 + 252
		local py = 175 - math.floor((k - 1)/2)  * 25 
		if #list <= 2 then
			px = 370
			py = 175 - (k - 1) * 25
		else
			if is_collected then 
				py = 200 - math.floor((k - 1)/2)  * 25
			end
		end
		
		if jNextLvUp then
			local attr = jNextLvUp.attrs[k]
			self:creatTxt("(下级  +"..attr.second..")",self, px + 140, py ,20, cc.c3b(0x7e, 0xff, 0x00))
		else
			if is_collected then
				self:creatTxt("(满级)",self, px + 140, py ,20, cc.c3b(0x7e, 0xff, 0x00))
			end	
		end
		
		jEffect = findEffect( v.first )
		-- local v = gameData.findArrayData(list,"first",i)
		txt = self:creatTxt(jEffect.desc,self, px, py,20, cc.c3b(0xff, 0xed, 0xa8))
        txt = self:creatTxt(v.second,self, px + 98, py,20, cc.c3b(0xff, 0xf0, 0x00))
	end
end

function TempleCollect:updateNameList( ... )
	self.name_list:updateData()
end

function TempleCollect:creatTxt(str,parent,px,py,font_size,c3b )
	local txt =  UIFactory.getText(str, parent, px, py, font_size, c3b)
	txt:setAnchorPoint(cc.p(0, 0))
	table.insert(self.txt_list,txt)
	-- return txt
end

function TempleCollect:clearTxt( ... )
	for i,v in ipairs(self.txt_list) do
		v:removeFromParent()
		v = nil
	end
	self.txt_list = {}
end

function TempleCollect:createView()
   local view = TempleCollect.new()
   return view 
end 