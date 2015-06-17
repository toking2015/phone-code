local prePath = "image/ui/TempleUI/"
local url = prePath .. "TempleAttrSummary.ExportJson"
TempleAttrSummary = createUIClass("TempleAttrSummary", url, PopWayMgr.SMALLTOBIG )

function TempleAttrSummary:ctor()
	self.txt_list = {}
end

function TempleAttrSummary:delayInit( ... )
	UIFactory.getTitleTriangle(self, 1)
end

function TempleAttrSummary:onShow()
	self:updateData()
end

function TempleAttrSummary:onClose( ... )
	-- body
end

function TempleAttrSummary:updateData( ... )
	self:clearTxt()
	local total_list = TempleData.getGroupAttr()	
	table.sort(total_list,TempleData.sortAttrFunc)
	local txt = nil
	local col_height = 80
	local jEffect = nil
	local valStr = ""

	for k,v in pairs(total_list) do
		local px = (k - 1) % 2 * 230 + 30
		local py = 65 - math.floor((k - 1)/2)  * 25 
		-- local v = gameData.findArrayData(total_list,"first",k)
		jEffect = findEffect( v.first )
		self:creatTxt(jEffect.desc,self.total_con, px, py,20, cc.c3b(0xff, 0xed, 0xa8))
		self:creatTxt(v.second,self.total_con, px + 105, py,20, cc.c3b(0xff, 0xf0, 0x00))
	end
	local col_height = col_height + math.ceil((#total_list)/2) *25
	
	self.bg_1:setSize(cc.size(534,col_height + 34))
	self.bg_2:setSize(cc.size(518,col_height ))
	self.tips_txt:setPositionY(310 - col_height )
end

function TempleAttrSummary:creatTxt(str,parent,px,py,font_size,c3b )
	local txt =  UIFactory.getText(str, parent, px, py, font_size, c3b)
	txt:setAnchorPoint(cc.p(0, 0))
	table.insert(self.txt_list,txt)
	-- return txt
end

function TempleAttrSummary:clearTxt( ... )
	for i,v in ipairs(self.txt_list) do
		v:removeFromParent()
		v = nil
	end
	self.txt_list = {}
end

function TempleAttrSummary:dispose( ... )
	-- body
end