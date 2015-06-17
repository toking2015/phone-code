local prePath = "image/ui/TipsSoldierUI/"
TipsSoldierArr = createLayoutClass('TipsSoldierArr', cc.Node)
function TipsSoldierArr:onShow()

end

function TipsSoldierArr:onClose()

end

function TipsSoldierArr:updateData()

	if self.sData == nil or not self.jSoldier or not self._sFightExtAble1 then
        return
    end

    self.descCon.desc:setString(self.jSoldier.desc)
    
    --二级属性
    --self.soldierArr = SoldierData.getSoldierFightExtAble(self.sData.guid)
    self.soldierArr = self._sFightExtAble1
    if self.soldierArr then
        local s = self.soldierArr
        self.values = {s.hp,s.physical_ack,s.physical_def,s.critper,s.crithurt,s.parryper,s.hitper - 10000,
            s.speed,s.magic_ack,s.magic_def,s.critper_def,s.crithurt_def,s.parryper_dec,s.dodgeper}

        --[[
        local equipExt = SoldierData.getEquipExtByGuid(self.sData.guid)
        local equipExt = self._sFightExtAble2
        if equipExt then
        	self.equipValues = {equipExt.hp,equipExt.physical_ack,equipExt.physical_def,equipExt.critper,equipExt.crithurt,equipExt.parryper,equipExt.hitper,
            	equipExt.speed,equipExt.magic_ack,equipExt.magic_def,equipExt.critper_def,equipExt.crithurt_def,equipExt.parryper_dec,equipExt.dodgeper}
        else
        	if not self.qEquipExt then
				local qInfo = {}
			    --英雄 first:英雄背包类型 second:英雄guid
			    qInfo.first = const.kSoldierTypeCommon
			    qInfo.second = self.sData.guid
			    Command.run( 'soldier equipext', qInfo )
			    self.qEquipExt = true
			end
        end
        ]]
        for k,v in pairs(self.values) do
        	if k > self.arrLen then
        		return
        	end
        	local item = self.arrItems[k]
        	item.label:setString(self.arrLabel[k] .. "：")
        	if not equipExt then
				item.value:setString(self.values[k])
				item.add:setString("")
			else
				local dValue = self.values[k]
				item.value:setString(dValue)
				item.add:setString("")
			end
			local lSize = item.label:getSize()
			item.value:setPositionX( item.label:getPositionX() + lSize.width)
        end
    end
    --self.tableView:reloadData()
end

function TipsSoldierArr:setData(_sData,_jSoldier,_jLvInfo,_sFightExtAble1)
	self.qEquipExt = nil
	self.sData = _sData
	self.jSoldier = _jSoldier
	self.jLvInfo = _jLvInfo
	self._sFightExtAble1 = _sFightExtAble1
	self:updateData()
end

function TipsSoldierArr:dispose( )
	
end

function TipsSoldierArr:ctor( )
	--buttonDisable(self,true)
	self.arrLabel = SoldierData.getArrLabel()
	self.arrLen = #self.arrLabel
	--buttonDisable(self,true)


	self.arrItems = {}
	local totalHeight = 0
	local offX = 12
	--local bgTop = cc.Sprite:createWithSpriteFrameName("soidierd_arrbgt.png")
	local bgTop = cc.Sprite:create(SoldierDefine.prePath2 .. "soidierd_arrbgt.png")
	bgTop:setAnchorPoint(0,0)
	self:addChild(bgTop,5)
	local bgBottom = cc.Sprite:create(SoldierDefine.prePath2 .. "soidierd_arrbgb.png")
	bgBottom:setAnchorPoint(0,0)
	self:addChild(bgBottom,5)
	local mid = cc.Sprite:create(SoldierDefine.prePath2 .. "soidierd_arrbgm1.png")
	local topSize = bgTop:getContentSize()
	local bottomSize = bgBottom:getContentSize()
	local midSize = mid:getContentSize()
    totalHeight = bottomSize.height + self.arrLen * midSize.height
	bgTop:setPosition(offX,totalHeight)

	local title = cc.Sprite:createWithSpriteFrameName("TipsSoldierUI/soldierd_arrt2.png")
	bgTop:addChild(title)
	title:setPosition(topSize.width/2,topSize.height/2)
	local itemBg = nil
	local itemArr = nil
	for i=1,self.arrLen do
		local offY = totalHeight - i * midSize.height
		if i % 2 == 0 then
			itemBg = cc.Sprite:create(SoldierDefine.prePath2 .. "soidierd_arrbgm2.png")
		else
			itemBg = cc.Sprite:create(SoldierDefine.prePath2 .. "soidierd_arrbgm1.png")
		end
		itemBg:setAnchorPoint(0,0)
		self:addChild(itemBg)
		itemBg:setPosition(offX,offY)
		itemArr = getLayout(prePath .. "arrItem.ExportJson")
		buttonDisable(itemArr,true)
		itemArr:setAnchorPoint(0,0)
		itemBg:addChild(itemArr)
		itemArr:setPosition(35,2)
		table.insert(self.arrItems,itemArr)
	end
	bgBottom:setPosition(offX,0)

	totalHeight = totalHeight + topSize.height
	self.descCon = getLayout(prePath .. "arrCon.ExportJson")
	self.descCon.bg1:loadTexture(SoldierDefine.prePath2 .. "soldierd_arrbg1.png",ccui.TextureResType.localType)
	self.descCon:setAnchorPoint(0,0)
	self:addChild(self.descCon)
	self.descCon:setPosition(offX,totalHeight)
	local descSize = self.descCon:getSize()
	totalHeight = totalHeight + descSize.height

	self.width = descSize.width
	self.height = totalHeight
end

function TipsSoldierArr:gSize()
	return cc.size( self.width,self.height )
end

