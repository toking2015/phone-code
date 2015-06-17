OpenIocnUI = createUIClassEx("OpenIocnUI", cc.Node )
local listener = nil

function OpenIocnUI:ctor()
	self.bg =  UIFactory.getSprite("image/ui/TaskUI/task_btn.png", self, 0, 0, 2)
	
	self.onActionEnd = function( ... )
		PopMgr.removeWindowByName( 'OpenIocnUI' )
	end
end

function OpenIocnUI:updateData()
	local task = TaskData.getMianTask()
	if task then
		self.textName:setString( task.name )
		self.textInfo:setString( task.desc )
	end
end

function OpenIocnUI:showEffcet()
	local effectName = 'rwzz-tx-03'
	local prePath = "image/armature/ui/TaskUI/" .. effectName .. "/"  
	local change = nil
	local index = 0
	local complete = function()
		change:removeNextFrame()

		local btn = MainUIMgr.getRoleRight().btn_task
		local pos = cc.p(btn:getPosition())
		local size = btn.getSize and btn:getSize() or btn:getContentSize()
		pos.x = pos.x + size.width / 2
		pos.y = pos.y - size.height / 2
		pos = btn:convertToWorldSpace(pos)
		pos = self:convertToNodeSpace( pos )
 		action = cc.MoveTo:create( 1, pos  )			    
        sequence = cc.Sequence:create( action, cc.CallFunc:create(self.onActionEnd) )
    	self.bg:stopAllActions() 
        self.bg:runAction( sequence )
	end 

	change = ArmatureSprite:addArmature(prePath .. effectName .. ".ExportJson", effectName, 'TaskTrackUI', self, -81 - 75, 27 + 105, complete, 1, 2 )
end

function OpenIocnUI:onShow()
	self:showEffcet()
end

function OpenIocnUI:onClose()
	-- TimerMgr.callLater( function() Command.run( 'ui show', "TaskUI", PopUpType.SPECIAL ) end , 1 )
end