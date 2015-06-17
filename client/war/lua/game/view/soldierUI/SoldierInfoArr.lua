SoldierInfoArr = createLayoutClass('SoldierInfoArr', cc.Node)
function SoldierInfoArr:onShow()

end

function SoldierInfoArr:onClose()

end

function SoldierInfoArr:updateData()
	if self.sData == nil or not self.jSoldier then
        return
    end

    self.descCon.desc:setString(self.jSoldier.desc)
    
    --二级属性
    self.soldierArr = SoldierData.getSoldierFightExtAble(self.sData.guid)
    if self.soldierArr then
        local s = self.soldierArr.able
        self.values = {s.hp,s.physical_ack,s.physical_def,s.critper,s.crithurt,s.parryper,s.hitper - 10000,
            s.speed,s.magic_ack,s.magic_def,s.critper_def,s.crithurt_def,s.parryper_dec,s.dodgeper}

        local equipExt = SoldierData.getEquipExtByGuid(self.sData.guid)
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
        for k,v in pairs(self.values) do
        	if k > self.arrLen then
        		return
        	end
        	local item = self.arrItems[k]
        	--self.arrItems[k]:setString(tostring(v))
        	item.label:setString(self.arrLabel[k] .. "：")
        	if not equipExt then
				item.value:setString(self.values[k])
				item.add:setString("")
			else
				local dValue = self.values[k] - self.equipValues[k]
				item.value:setString(dValue)
				if self.equipValues[k] > 0 then
					item.add:setString('+'.. self.equipValues[k])
				else
					item.add:setString("")
				end
			end
			local lSize = item.label:getSize()
			item.value:setPositionX( item.label:getPositionX() + lSize.width)
        end
    end
    --self.tableView:reloadData()
end

function SoldierInfoArr:setData(_sData,_jSoldier,_jLvInfo)
	self.qEquipExt = nil
	self.sData = _sData
	self.jSoldier = _jSoldier
	self.jLvInfo = _jLvInfo
	self:updateData()
end

function SoldierInfoArr:dispose( )
	
end

function SoldierInfoArr:ctor( )
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

	local title = cc.Sprite:createWithSpriteFrameName("soldierd_arrt2.png")
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
		itemArr = getLayout(SoldierDefine.prePathI .. "arrItem.ExportJson")
		buttonDisable(itemArr,true)
		itemArr:setAnchorPoint(0,0)
		itemBg:addChild(itemArr)
		itemArr:setPosition(35,2)
		table.insert(self.arrItems,itemArr)
	end
	bgBottom:setPosition(offX,0)

	totalHeight = totalHeight + topSize.height
	self.descCon = getLayout(SoldierDefine.prePathI .. "arrCon.ExportJson")
	self.descCon.bg1:loadTexture(SoldierDefine.prePath2 .. "soldierd_arrbg1.png",ccui.TextureResType.localType)
	self.descCon:setAnchorPoint(0,0)
	self:addChild(self.descCon)
	self.descCon:setPosition(offX,totalHeight)
	local descSize = self.descCon:getSize()
	totalHeight = totalHeight + descSize.height

	self.width = descSize.width
	self.height = totalHeight
end

function SoldierInfoArr:gSize()
	return cc.size( self.width,self.height )
end

