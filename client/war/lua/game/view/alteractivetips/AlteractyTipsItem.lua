-- write by toking 
local prepath = "image/ui/AlternativesTipsUI/"
local url = prepath .. "AlternativesTipsItem.ExportJson"

local item_id = nil

AlteractyTipsItem = class(
	"AlteractyTipsItem", 
	function()
		return getLayout(url)
	end
)

function AlteractyTipsItem:ctor( ... )
    self:setTouchEnabled(true)
	local function touchEndedHandler()
		if self.data and AlteractData.cheakOpen(self.data) then
	        AlteractData.goToFinsh(self.data)
		elseif not AlteractData.cheakOpen(self.data) then
			TipsMgr.showError(AlteractData.getLinkDesc(self.data))
		end
	end
	UIMgr.addTouchEnded(self, touchEndedHandler)
end

function AlteractyTipsItem:updateData( alterdata )
	if alterdata then
		self.data = alterdata
		local iconindex = (alterdata.icon and alterdata.icon ~= "") and alterdata.icon or alterdata.link_type
		self.icon:loadTexture("image/ui/AlternativesTipsUI/moreimg/"..iconindex..".png", ccui.TextureResType.localType )
		self.bg:loadTexture("image/ui/AlternativesTipsUI/moreimg/bg_item.png", ccui.TextureResType.localType )
		self.icon:setScale(0.9,0.9)
		local icon_size = self.icon.getSize and self.icon:getSize() or self.icon:getContentSize()
		local sw = 70 / icon_size.width
		self.icon:setScale(sw,sw)
		self.icon:setPosition(cc.p(60,45))
		local allW = 187
		local centerX= 211

		self.name:setString(AlteractData.getName(alterdata))
		allW = self.name:getContentSize().width
		if alterdata.link_type == AlteractData.TYPE_COPY and AlteractData.getArrStr(alterdata.link_data)[1] == 2 then
			self.bg_elipt:setVisible(true)
			allW = allW + self.bg_elipt:getContentSize().width + 5
		else 
			self.bg_elipt:setVisible(false)
		end
        local leftNum,isenough = AlteractData.getLeftNum(alterdata)
		if leftNum then
			self.count:setVisible(true)
			self.count:setString(leftNum)
			if isenough then 
				self.count:setColor(cc.c3b(0x31, 0xff, 0x16))
			else
				self.count:setColor(cc.c3b(0xff, 0x00, 0x00))
			end
			allW = allW + self.count:getContentSize().width + 5
		else
			self.count:setVisible(false)
		end
		self.name:setPosition(cc.p(centerX - allW/2,66))
		self.bg_elipt:setPosition(cc.p(self.name:getPositionX() + self.name:getContentSize().width + 5,68))
		if(self.bg_elipt:isVisible()) then
			self.count:setPosition(cc.p(self.bg_elipt:getPositionX() + self.bg_elipt:getContentSize().width,66))
		else
            self.count:setPosition(cc.p(self.name:getPositionX() + self.name:getContentSize().width + 5,66))
		end

		self.bg_tips.Label_10:setString(AlteractData.getLinkDesc(alterdata))
		if AlteractData.cheakOpen(alterdata) then
			self.bg_tips.Label_10:setColor(cc.c3b(0xED, 0xDB, 0x79))
		else
			self.bg_tips.Label_10:setColor(cc.c3b(0xFF, 0x00, 0x00))
		end
	end
end


