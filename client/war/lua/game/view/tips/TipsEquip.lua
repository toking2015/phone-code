--**谭春映
--**装备Tips
local Path = "image/ui/EquipTipUI/"
--TipsEquip = createLayoutClass("TipsEquip", cc.Node)
TipsEquip = createUIClassEx("TipsEquip", cc.Node,PopWayMgr.SMALLTOBIG )
TipsMgr.registerTipsRender(TipsMgr.TYPE_EQUIP, TipsEquip)
function TipsEquip:dispose( ... )
end
function TipsEquip:ctor()
	self.width = 491
    self.height = 540
	self.content = getLayout(Path .. "content.ExportJson")
	self.bg = UIFactory.getScale9Sprite("equiptip_bg.png", cc.rect(28, 28, 1, 1), cc.size(1,1), self)
	self.bg:addChild(self.content)
    self:setContentSize(self.width,self.height)
    self.base_close = UIFactory.getButton("close.png", self, 0, 0, 555, resType)
    local function exit( ... )
        ActionMgr.save( 'UI', 'TipsBase click btn_close' )
        PopMgr.removeWindow(self)
    end

    self.base_close:addTouchEnded(exit)
end
function TipsEquip:render()
	--如果有extData，extData.quality里，显示标题
	if self.exData and self.exData.quality then
		self.title = getLayout(Path .. "title.ExportJson")
		self.bg:addChild(self.title)
		self.title:setPosition(0,450)
		self.content:setLocalZOrder(99)
		local q = self.exData.quality
		self.title.qualityIcon:loadTexture("equiptip_type"..q..".png",ccui.TextureResType.plistType)
		self.height = 540
		self.bgHeight = 480

	else
		self.height = 460
		self.bgHeight = self.height
	end

	self:updateInfo(self.data)
	self.bg:setContentSize(self.width,self.bgHeight)
    self:setContentSize(self.width,self.height)
    local size = self:getContentSize()
    self.base_close:setPosition(size.width - 30,size.height - 30)
end

function TipsEquip:updateInfo( equipment )
    if equipment ~= nil then 
    	local jItem = findItem( equipment.item_id )	
        if jItem == nil then
            return
        end
        	
    	local itemLay = self.content.itemLay
    	local url = ItemData.getItemBgUrl(equipment.item_id)
    	itemLay.itemBg:loadTexture(url,ccui.TextureResType.localType)
    	ItemData.setItemUlr( itemLay.icon, equipment.item_id )
		itemLay.name:setString(jItem.name)
        local curQuality = ItemData.getQuality( jItem, equipment )
        local color = ItemData.getItemColor( curQuality )
        itemLay.name:setColor(color)

    	self.content.info_1.value:setString( EquipmentData:getEquipTypeName( jItem.equip_type ) )
    	self.content.info_3.value:setString( jItem.limitlevel )
    	self.content.info_2.value:setString( 'T'..jItem.level )
        self.content.info_5:setString("生　　命：")
        self.content.info_7:setString("护　　甲：")

        self.content.score_num:setString( '评分:'..EquipmentData:getEquipmentScore(equipment, jItem.level))
    	
    	--一级属性
    	local info_index = 4
    	local jEffect = nil
    	for k,v in pairs(jItem.attrs) do
    		if v.first ~= 0 then
    			jEffect = findEffect( v.first )
                self.content['info_'..info_index]:setString( jEffect.desc..'：' )
    			self.content['info_'..info_index].value:setString( math.floor( v.second * ( 1 + equipment.main_attr_factor / 10000 ) ) )
    			self.content['info_'..info_index]:setVisible(true)
                self.content['info_'..info_index]:setColor( cc.c3b( 0x31, 0xff, 0x16 ) )
    			info_index = info_index + 1
    		end
    	end
    
    	--随机属性
    	local slave_attr = nil
    	for k,v in pairs(equipment.slave_attrs) do
            if v ~= 0 then
    		    slave_attr = jItem.slave_attrs[v]
    			jEffect = findEffect( slave_attr.first )
    			if self.content['info_'..info_index] == nil then
    			     break
    			end
                self.content['info_'..info_index]:setString( '随机属性：' )
    			self.content['info_'..info_index].value:setString( jEffect.desc .. math.floor( slave_attr.second * ( 1 + equipment.slave_attr_factor / 10000 ) ) )
    			self.content['info_'..info_index]:setVisible(true)
                self.content['info_'..info_index]:setColor( cc.c3b( 0x53, 0xe9, 0xff ) )
    			info_index = info_index + 1
    		end
    	end
    
    	for i=info_index,15 do
            if self.content['info_'..i] == nil then
                break
            end
    		self.content['info_'..i]:setVisible(false)
    	end
    
    	--套装属性
    	local jEquipSuit = EquipmentData:getEquipSuit( jItem.level, const.kCoinEquipWhite, jItem.equip_type )
        local suit_attr = jEquipSuit.odds[1];
    	local jOdd = findOdd( suit_attr.first, suit_attr.second )
    	local count = 0
    	self.content.midInfo.add:setString( jOdd.description )
    	count = EquipmentData:getEquipmentCountForQuality( jItem.equip_type, jItem.level, const.kCoinEquipWhite )
		self.content.midInfo.num:setString(count)
        self.content.midInfo:setString(string.format("T%d套装(   /6)：",jItem.level))
		if count < 6 then
			self.content.midInfo.num:setColor( cc.c3b( 0xff, 0x00, 0x00 ) )
            self.content.midInfo.add:setColor(cc.c3b( 0x6E, 0x6E, 0x6E ))
		else
			self.content.midInfo.num:setColor( cc.c3b( 0x31, 0xff, 0x16 ) )
             self.content.midInfo.add:setColor(cc.c3b( 0x31, 0xff, 0x16 ))
		end    	
    
    	--套装品质属性
    	local quality = const.kCoinEquipGreen
    	local sets = nil
    	for i=1,3 do
            sets = self.content['arr'..i]
            local numTxt = self.content['num'..i]
            local qName = EquipmentData:getEquipmentQualityName(quality)
            local labelName = string.format('全身%s装(   /6)：',qName)
            sets:setString(labelName)
    		sets.open:setVisible(true)
    		count = EquipmentData:getEquipmentCountForQuality( jItem.equip_type, jItem.level, quality )
    		if count < 6 then
                sets.open:setVisible(false)
    			numTxt:setColor( cc.c3b( 0xff, 0x00, 0x00 ) )
                sets.add:setColor(cc.c3b( 0x6E, 0x6E, 0x6E ))
    		else
    			sets.open:setVisible(false)
    			numTxt:setColor( cc.c3b( 0x31, 0xff, 0x16 ) )
                sets.add:setColor(cc.c3b( 0x31, 0xff, 0x16 ))
                sets:setColor(cc.c3b( 0x31, 0xff, 0x16 ))
    		end    		
 			--sets.num:setString( count )
            numTxt:setString(count)
    		jEquipSuit = EquipmentData:getEquipSuit( jItem.level, quality, jItem.equip_type )
    		suit_attr = jEquipSuit.odds[1];		
    		jOdd = findOdd( suit_attr.first, suit_attr.second )	
    		sets.add:setString( jOdd.description )
            --local oddSize = sets.add:getSize()
            local openP_X = sets.add:getPositionX() + 200
            sets.open:setPositionX(openP_X)
            quality = quality + 1
    	end
    end
end

function TipsEquip:setData( data, exData )
	self.data = data
	self.exData = exData
	self:render()
end