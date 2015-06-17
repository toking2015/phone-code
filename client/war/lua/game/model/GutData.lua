GutType = {}
GutType.GutInfo = 1
GutType.GutCopyInfo = 2
GutType.GutInductInfo = 3
GutType.GutFightInfo = 4

local _this = GutData or {}
GutData = _this

function _this.clear()
	_this.dataList = {}
	_this.type = GutType.GutInfo
	_this.data = nil
	_this.fightData = nil
	_this.index = 0
end
_this.clear()
EventMgr.addListener(EventType.UserLogout, _this.clear)

function _this.getData()
    if _this.data == nil then
        if _this.type == GutType.GutInfo then
            _this.data = gameData.user.gut
            
            if _this.data ~= nil then
                _this.index = _this.data.index
            else
                _this.index = 0
            end
        elseif _this.type == GutType.GutCopyInfo then
            _this.data = gameData.user.copy.gut[CopyData.currGid]
            _this.index = CopyData.user.copy.index
        elseif _this.type == GutType.GutInductInfo then
        	_this.data = InductMgr:getInudctGut()
            _this.index = _this.data.index
       	elseif _this.type == GutType.GutFightInfo then
        	_this.data = _this.fightData
            _this.index = _this.data.index
        end    
    end 
    return _this.data
end

function _this.getType()
	return _this.type
end

function _this.setType(type)
	_this.type = type

	if _this.type == GutType.GutInfo then
		_this.data = gameData.user.gut
		_this.index = _this.data.index
	elseif _this.type == GutType.GutCopyInfo then
		_this.data =  gameData.user.copy.gut[CopyData.currGid]
		_this.index = CopyData.user.copy.index
    elseif _this.type == GutType.GutInductInfo then
    	_this.data = InductMgr.getInudctGut()
        _this.index = _this.data.index  
    elseif _this.type == GutType.GutFightInfo then
      	_this.data = _this.fightData
        _this.index = _this.data.index    			
	end	
end

function _this.setFightData( id, index )
	_this.fightData = GutMgr:getTransformGut( id )
	_this.fightData.index = index
end

function _this.getId()
	if _this.getData() ~= nil then
		return _this.getData().gut_id
	end

	return 0
end

function _this.getStep()
	return _this.index
end

function _this.setStep()
	_this.index = _this.index + 1
end

function _this.setStartData()
	_this.index = 0
end

function _this.getGut()
	return _this.getData().event[_this.getStep()+1]
end

function _this.getFight()
	local fightList = _this.getData().fight
	local fightId = _this.getFightId()
	for i,v in pairs(fightList) do
		if v.fight_id == fightId then
			return v
		end
	end
end

function _this.getFightId()
	return _this.getGut().val
end

function _this.getFightSeed()
	return _this.getData().seed[_this.getFightId()]
end

function _this.CheckCanRun()
	local data = _this.getData()
    if SceneMgr.isSceneName( 'main' ) or SceneMgr.isSceneName( 'copyUI' ) or SceneMgr.isSceneName( 'fight' ) or SceneMgr.isSceneName( 'copy' ) then
		if data ~= nil and data.event then
			if _this.index < #data.event then
				return true
			end
		end
	end

	return false
end
