

clsData = {
Inherit = InheritWithCopy,
}

local obj = Import( "lua/util/cls_instance.lua" )
clsData = obj.clsInstance:Inherit()

function clsData:__init__( ... )
	obj.Super(clsData).__init__( self )	
end		

function clsData:close()
	obj.Super(clsData).close(self)
end	