--@author yantojin
local prePath = "image/ui/NoticeUI/"
NoticeUI = createUIClass("NoticeUI", prePath.."NoticeUI_1.ExportJson", PopWayMgr.NONE)

function NoticeUI:ctor( ... )
	createScaleButton(self.btn_confirm)
	self.btn_confirm:addTouchEnded(function()
                Command.run("ui hide", "NoticeUI", PopUpType.SPECIAL)
            end)
end

function NoticeUI:onShow( ... )
	self:updateData()
end

function NoticeUI:updateData( ... )
	local noticeStr = NoticeData.getNoticeStr()
	if noticeStr then
		local scrHeight = 300
		local scrollview = self.scrollView
		local richCon = cc.Node:create();
	    RichTextUtil:DisposeRichText(noticeStr,richCon,richText,0,570,15)
	    local consize = richCon.getSize and richCon:getSize()  or richCon:getContentSize()
	    if consize.height < scrHeight then
	    	consize.height = scrHeight
	    end

	    self.scrollView:getInnerContainer():addChild(richCon)
	    richCon:setPosition(20,consize.height)
	    self.scrollView:setInnerContainerSize(cc.size(590, consize.height))

	    bindScrollViewAndSlider(self.scrollView, self.slider)
	    local size = self.scrollView:getInnerContainer():getSize()
	    local cursize = self.scrollView:getInnerContainerSize()
	    if scrHeight < cursize.height then
	    	self.slider:setVisible(true)
	    else
	    	self.slider:setVisible(false)
	    end
	    self.slider:setPercent(0)
	end
end

function NoticeUI:onClose( ... )
end