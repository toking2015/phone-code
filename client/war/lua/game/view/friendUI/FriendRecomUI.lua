-- author:toking
local resPath = "image/ui/FriendUI/"

require("lua/game/view/friendUI/FriendItem.lua")

FriendRecomUI = createUILayout("FriendRecomUI", resPath .. "Friend_invite.ExportJson", "FriendUI" )

function FriendRecomUI:ctor( ... )
	self.bg.mask:loadTexture("image/ui/FriendUI/img/mask_2.png", ccui.TextureResType.localType )
	local function btnHandler(sender,eveType )
		if eveType ~= ccui.TouchEventType.ended then
	        return
	    end
	    local name = sender:getName()
	     ActionMgr.save( 'UI', 'FriendRecomUI click '.. name)
	    FriendData:btnHandler(name)
	end
	UIMgr.addTouchEnded( self.btn_review, btnHandler )
	UIMgr.addTouchEnded( self.btn_addall, btnHandler )

	self.datalist = {}
	self.item_contat = {}

	function self.update( ... )
		self:updateData()
	end

     function self.updateItemData(data ,constant, dataIndex, itemIndex, widhtCount )
        constant.index = dataIndex
        constant.view:updateData(self.datalist[dataIndex],true)
        if not self.datalist[dataIndex].friend_name then
        	FriendData:updateCachetData(self.datalist[dataIndex].friend_id,constant.view)
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
        view:setPosition(8,0)
        return content
    end

    function self.touchCell( conctent, index, itemIndex )
        if conctent and conctent.view then
    		FriendData:btnHandler(conctent.view:getName(),conctent.view)
    	end
    end

    self.tableView = createTableView({}, self.create,self.updateItemData, cc.p( 12, 84 ),cc.size(377 + 16,474), cc.size(377+16,95), self, self.slider, 1 ,6)
end

function FriendRecomUI:onShow( ... )
	self:updateData()
	EventMgr.addListener(EventType.FriendRecomChange, self.updateData,self )
end

function FriendRecomUI:onClose( ... )
	EventMgr.removeListener(EventType.FriendRecomChange, self.updateData,self )
	FriendData:clearnAskMakeList()
	self:dispose()
end

function FriendRecomUI:dispose( ... )
	if self.item_contat and #self.item_contat > 0 then
	 	for i=1,#self.item_contat do 
	 		self.item_contat[i]:release()
	 	end
	 end
	 self.item_contat = nil
end

function FriendRecomUI:createItem( ... )
	local item = FriendItem:new()
	item:setTouchEnabled(false)
    createScaleButton(item.icon_face,nil,nil,nil,nil,0.8)
    item.icon_face:setTouchEnabled(false)
	item:retain()
	table.insert(self.item_contat,item)
	return item	
end

function FriendRecomUI:updateData( ... )
	self.datalist  = FriendData.recommend_list
	--self.datalist = FriendData:getTestData(FriendData.TYPE_ASKED)
	self.dataLen = table.getn(self.datalist)
	self.tableView:reloadData()
end
