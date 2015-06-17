local url = SoldierDefine.prePathI .. "equipCon.ExportJson"
SoldierInfoEquip = createUILayout("SoldierInfoEquip", url)
function SoldierInfoEquip:onShow()

end

function SoldierInfoEquip:onClose()

end

function SoldierInfoEquip:updateData()
    if self.jSoldier == nil then
        return
    end

    local equipType =self.jSoldier.equip_type
    self.equipIcon:loadTexture("soldierd_equiptype" .. equipType..".png", ccui.TextureResType.plistType)
    self.type:setString(SoldierData.getEquipTypeName(self.jSoldier))
    self.Label_7:setString("该英雄装备")
    --self.Label_7:setColor(cc.c3b(0xFF, 0xdd, 0xb3))

    if self.sData == nil then
        return
    end

    local teamLevel = gameData.getSimpleDataByKey("team_level")
    if teamLevel >= 20 then
        if self.sData.level < 20 then
            self.type:setString("")
            self.Label_7:setString("需要英雄20级")
           -- self.Label_7:setColor(cc.c3b(0xFF, 0x00, 0x00))
        end
    end
    
    --GameData.user.equip_suit_level[EquipmentData.selectType]
    for i=1,6 do
        local item = self.equipList[i]
        --本甲当前等级 
        local equipTypeLevel = GameData.user.equip_suit_level[ equipType]
        --本英雄能穿的等级
        local equipLevel = EquipmentData:getLevel(self.sData.level)
        if equipTypeLevel and equipLevel >= equipTypeLevel then
            equipLevel = equipTypeLevel
        end
        
        item.equipLevel = equipLevel
        local data = EquipmentData:getEquipmentForConditionMin(equipType,equipLevel,i)
        if data then
            local jItem = findItem(data.item_id)
            if jItem then
                ItemData.setItemUlr( item.icon, data.item_id )
                item.icon.EquipmentData = data
                item.name:setString(jItem.name)
                local quality = ItemData.getQuality( jItem, data )
                item.name:setColor(ItemData.getItemColor(quality))
            end
        else
            item.icon:loadTexture("soldiern_equip_no.png",ccui.TextureResType.plistType)
            item.icon.EquipmentData = nil
            item.name:setString('')
        end
    end
end

function SoldierInfoEquip:setData( _sData,_jSoldier )
	self.sData = _sData
	self.jSoldier = _jSoldier
	self:updateData()
end

function SoldierInfoEquip:dispose( )
	
end

function SoldierInfoEquip:ctor( )
	local function onBegin( sender,type )
        ActionMgr.save( 'UI', 'SoldierInfoEquip click itemView_icon' )
        if sender.EquipmentData == nil then
            return
        end
        TipsMgr.showTips(sender:getTouchStartPos(),TipsMgr.TYPE_EQUIP,sender.EquipmentData )
    end

    local function toEquip( sender,type )
        ActionMgr.save( 'UI', 'SoldierInfoEquip click toMark' )
        if type ~= ccui.TouchEventType.ended then
            return
        end
        local teamLevel = gameData.getSimpleDataByKey("team_level")
        --EquipmentUI
        if teamLevel < 20 then
            TipsMgr.showError('战队等级达到20级开放')
            return
        end
        PopMgr.removeWindow(self:getParent())
        Command.run("ui show", "EquipmentUI", PopUpType.SPECIAL)
    end

	self.equipList ={}
    for i=1,3 do
		for j=1,2 do
			local index = (j-1) * 3 + i
		    local itemView = getLayout(SoldierDefine.prePathI .. "equipItem.ExportJson")
		    self:addChild(itemView)
		    itemView:setPosition( 16 + (i - 1) * 116 , 315 - ( j * 150 ) )
		    table.insert(self.equipList,itemView)
            buttonDisable(itemView.icon,false)
            UIMgr.addTouchBegin(itemView.icon,onBegin)
		end 
	end
	createScaleButton(self.toMark)
    self.toMark:addTouchEnded(toEquip)
end