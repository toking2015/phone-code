local resPath = "image/ui/GutUi/"

GutUI = createUIClass("GutUI", resPath .. "GutUI.ExportJson" )

function GutUI:ctor()
	self._isUpLayer = true
	self.talk = GutTalk:new()
	self.talk:ctor()
	self.talk:retain()
	self.talk:setVisible( false )

    self:addChild( self.talk )
end

function GutUI:onShow()
	self.talk:onShow()
	self:updateData()
end

function GutUI:onClose()
	self.talk:onClose()
	self.talk:setVisible( false )
	GutMgr:endGut()	
end

function GutUI:dispose()
	self.talk:release()
	self.talk:dispose()
end

function GutUI:updateData()
	if self ~= nil and self.gut ~= nil then
		self.talk:setVisible( true )
		self.talk:updateGut(self.gut)
	end
end

function GutUI:updateGut(gut)
	self.gut = gut
	self:updateData()
end