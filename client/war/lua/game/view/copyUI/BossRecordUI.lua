
local prePath = "image/ui/BossRecordUI/"

local BossRecordCell = createLayoutClass("BossRecordCell", cc.Node)

function BossRecordCell:ctor()
	UIFactory.getScale9Sprite("list_2.png", cc.rect(17, 17, 1, 1), cc.size(516, 110), self, 0, 0)
	UIFactory.getSpriteFrame("bg_role_new.png", self, 65, 55, 2)
	local sp = UIFactory.getSpriteFrame("BossRecordUI/color_tile.png", self, 85, 67, 1)
	sp:setAnchorPoint(0, 0.5)
	self.txt1 = UIFactory.getText("", self, 137, 65, 22, cc.c3b(0x44, 0x21, 0x08), nil, nil, 2)
	self.txt1:setAnchorPoint(0, 0.5)
	self.txt2 = UIFactory.getText("", self, 215, 65, 22, cc.c3b(0xad, 0x2c, 0x00), nil, nil, 2)
	self.txt2:setAnchorPoint(0, 0.5)
	self.txt3 = UIFactory.getText("", self, 137, 27, 20, cc.c3b(0x47, 0x81, 0x2b), nil, nil, 2)
	self.txt3:setAnchorPoint(0, 0.5)
	local btn = UIFactory.getButton("BossRecordUI/btn_play.png", self, 408, 9, 3)
	self.lastClickTime = 0
	btn:addTouchEnded(function()
		if self.data then
			local time = gameData.getServerTime()
			if time - self.lastClickTime > 10 then
				self.lastClickTime = time
				Command.run("fight replay", self.data.fight_id)
			end
		end
	end)
end

--@param data SCopyFightLog
function BossRecordCell:setData(data)
	self.data = data
	if not data then
		return
	end
	self.txt1:setString("LV."..data.ack_level)
	self.txt2:setString(data.ack_name)
	local time = data.log_time
	local serverTime = gameData.getServerTime()
	self.txt3:setString(DateTools.secondToString(serverTime - time, 1).."前")
	local url = TeamData.getAvatarUrlById(data.ack_avatar)
	UIFactory.getSprite(url, self, 65 + TeamData.AVATAR_OFFSET.x, 55 + TeamData.AVATAR_OFFSET.y, 2)
end

--窗口
BossRecordUI = createUIClass("BossRecordUI", prePath.."BossRecordUI.ExportJson", PopWayMgr.SMALLTOBIG)

function BossRecordUI:ctor()
	UIFactory.getTitleTriangle(self, 1)
	self.con = BoxContainer.new(1, 5, cc.p(510, 110), cc.p(5, 6), cc.p(8, 0))
	self.scrollView:addChild(self.con)
end

function BossRecordUI:onShow()
	self:updateData()
	self.scrollView:jumpToPercentVertical(0)
	EventMgr.addListener(EventType.COPY_FIGHTLOG_LOADED, self.updateData, self)
	EventMgr.addListener(EventType.FightRecordGet, self.onFightRecordGet, self)
end

function BossRecordUI:onClose()
	EventMgr.removeListener(EventType.COPY_FIGHTLOG_LOADED, self.updateData)
	EventMgr.removeListener(EventType.FightRecordGet, self.onFightRecordGet)
end

function BossRecordUI:onFightRecordGet()
	Command.run("ui hide", self.winName)
end

function BossRecordUI:updateData()
	local list = CopyData.bossRecordData[CopyData.bossRecordID]
	if not list then
		list = {}
	end
	for i = 1, 5 do
		local node = self.con:getNode(i)
		if i <= #list then
			if not node then
				node = BossRecordCell.new()
				self.con:addNode(node, i)
			end
			node:setVisible(true)
			node:setData(list[i])
		else
			if node then
				node:setVisible(false)
			end
		end
	end
	local size = self.scrollView:getSize()
	local scrollSize = cc.size(size.width, math.max(size.height, self.con:getNodeHeight() * #list))
	self.scrollView:setInnerContainerSize(scrollSize)
	self.con:setPosition(0, scrollSize.height)
end
