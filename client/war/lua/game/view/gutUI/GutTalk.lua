local resPath = "image/ui/GutUi/"

--剧情对话界面
GutTalk = class("GutTalk", 
				function()
			     	return getLayout(resPath .. "GutTalk.ExportJson")
			  	end)

local playIconY = 410 -  25 - 36 - 26

function GutTalk:ctor()
    function self.closeGut()
       	self:setVisible( false )
    end
    
	self.bg:loadTexture( resPath..'bg.png', ccui.TextureResType.localType )
	self.bg_name:loadTexture( resPath..'bg_name.png', ccui.TextureResType.localType )
	self.icon_arrow:loadTexture( resPath..'icon_arrow.png', ccui.TextureResType.localType )
	self.icon_player:setAnchorPoint( 0.5, 0.5 )

	local function OnTalkTounch(sender, eventType)
		ActionMgr.save( 'UI', '[GutUI] click [GutTalk] id='..GutData.getId()..', index='.. GutData.getStep() )
		-- self:setTouchEnabled(false)
		if eventType == ccui.TouchEventType.ended then
			EventMgr.dispatch( EventType.clickGutTalk, self.gut )
		end
	end
    UIMgr.addTouchEnded( self, OnTalkTounch )

	function self.onActionEnd()
		if self.gut.move_face ~= 0 then
			local action = cc.MoveTo:create( self:getTimeForSpeed( self.gut.move_speed ), self:getMoveFaceEndPostion( self.gut.move_face ) )
			self.icon_player:stopAllActions() 
			self.icon_player:runAction( action )
		end
	end
end

function GutTalk:getReadView()
	if self.redView == nil then
		local winSize = cc.Director:getInstance():getWinSize()
		self.redView = GLNodeRect:create()
		self.redView:retain()
	    self.redView:setAnchorPoint( 0, 0 )
	    self.redView:createBuffer()
	    self.redView:drawRect( winSize.width, winSize.height )
	    
	    self.redView:setProgramName( 'hurt' )
	    self.redView:setUniformData( 'u_color', 'vec4', { 0.88, 0, 0, 0.5 } )
	    self.redView:setUniformData( 'u_distance', 'vec1', { 100 } )
	    self.redView:setUniformData( 'u_size', 'vec2', { winSize.width, winSize.height } )
	end
	
	return self.redView
end

function GutTalk:dispose()
	self:getRichText():release()
	self:getReadView():release()
end

function GutTalk:updateGut( data )
    if self.gut ~= data then
     	-- self:setTouchEnabled(true)
		self:setVisible( true )
        self.gut = data
        self:updateData()
    end
end

function GutTalk:getRichText()
    if self.rich_text == nil then
        self.rich_text = cc.Node:create()
        self.rich_text:setAnchorPoint( 0, 0 )
        self.rich_text:retain()
        self:addChild( self.rich_text, 2 )
    else
        self.rich_text:removeAllChildren()
    end

    return self.rich_text
end

function GutTalk:onShow()
	self:updateData()

	local action = cc.JumpBy:create(1,cc.p( 0, 0 ), 20, 1 )
	self.icon_arrow:runAction(cc.RepeatForever:create( action ))		
	
	EventMgr.addListener(EventType.hideGutTalk, self.closeGut )
end

function GutTalk:onClose()
	self.icon_arrow:stopAllActions()
    EventMgr.removeListener(EventType.hideGutTalk, self.closeGut )
	self.gut = nil
	self.face = 0
end

function GutTalk:updateData()
	if self.gut ~= nil then
        local icon_player = self.icon_player
        local text_name = self.text_name
		
 		text_name:setString( getNmaeForGut( self.gut ) )

 		local action = nil
 		local sequence = nil
		if self.face ~= self.gut.face then
			if self.gut.attr == 0 then
				icon_player:setVisible( false )
				text_name:setVisible( false )
			else
				icon_player:setVisible( true )
				text_name:setVisible( true )

				if( self.gut.face == 1 ) then
					icon_player:setScaleX(1)
					self.bg_name:setPositionX( 222 )
					text_name:setPositionX( 222 )
			    else 
			    	icon_player:setScaleX(-1)
			    	self.bg_name:setPositionX( 900 )
			    	text_name:setPositionX( 900 )
			    end
			
		        icon_player:setPosition( self:getMoveFaceStarPostion(self.gut.face) )
		        action = cc.MoveTo:create( 0.3, self:getMoveFaceEndPostion( self.gut.face ) )			    

                sequence = cc.Sequence:create( action, cc.CallFunc:create(self.onActionEnd) )
		    	icon_player:stopAllActions() 
                icon_player:runAction( sequence )
				
                icon_player:loadTexture( getIconForGut( self.gut ), ccui.TextureResType.localType )
			end

	   		self.face = self.gut.face
		end

		RichTextUtil:DisposeRichText( self.gut.talk, self:getRichText() )
        self.rich_text:setPosition( cc.p( 90, 25 + ( 130 - self.rich_text:getContentSize().height ) / 2 + self.rich_text:getContentSize().height )  )

        if self.gut.red_screen ~= 0 then
        	if self:getReadView():getParent() == nil then
	        	self:getReadView():setUniformData( 'u_distance', 'vec1', { 360 } )
	        	self:addChild(self:getReadView(), 2 )
	        end
        else
	        if self:getReadView():getParent() ~= nil then
	        	self:removeChild( self:getReadView() )
	        end
        end
	end
end

function GutTalk:getMoveFaceStarPostion( face )
	-- local postion = nil
	-- local winSize = cc.Director:getInstance():getWinSize()
	-- if face == 1 then
	-- 	postion = cc.p( -200, playIconY )
	-- elseif face == 2 then
	-- 	postion = cc.p( winSize.width, playIconY )
	-- elseif face == 3 then
	-- 	postion = cc.p( winSize.width / 2 + 150, 0 )
	-- end
	-- return postion

	local postion = nil
	local winSize = cc.Director:getInstance():getWinSize()
	if face == 1 then
		postion = cc.p( -200, playIconY )
	elseif face == 2 then
		postion = cc.p( winSize.width - 73, playIconY )
	elseif face == 3 then
		postion = cc.p( winSize.width - 250 + 7, 0 )
	end
	return postion
end

function GutTalk:getMoveFaceEndPostion( face )
	-- local postion = nil
	-- local winSize = cc.Director:getInstance():getWinSize()
	-- if face == 1 then
	-- 	postion = cc.p( 300, playIconY )
	-- elseif face == 2 then
	-- 	postion = cc.p( winSize.width - 250, playIconY )
	-- elseif face == 3 then
	-- 	postion = cc.p( winSize.width / 2 + 150, playIconY )
	-- end
	-- return postion

	local postion = nil
	local winSize = cc.Director:getInstance():getWinSize()
	if face == 1 then
		postion = cc.p( 300 - 90, playIconY )
	elseif face == 2 then
		postion = cc.p( winSize.width - 250 + 7, playIconY )
	elseif face == 3 then
		postion = cc.p( winSize.width - 250 + 7, playIconY )
	end
	return postion	
end

function GutTalk:getTimeForSpeed( speed )
	local time = 0
	if speed == 1 then
		time = 0.9 
	elseif speed == 2 then
		time = 0.3
	elseif speed == 3 then
		time = 0.1
	end

	return time
end



