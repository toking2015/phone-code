

clsInstance = {
		Inherit = InheritWithCopy,		
	}

function clsInstance:__init__()
	if self._instance then
		error( "A single class cannot be instantiated." )
		return
	end
	if not self.canNew then
		error( "A single class cannot be instantiated." )
		return
	end	
end	
	
function clsInstance:getInstance( ... )	
	self.canNew = true
	if not self._instance then
		self._instance = self:New( ... )
	end		
	return self._instance
end	

function clsInstance:close()
	self.canNew = nil
	self._instance = nil
end		