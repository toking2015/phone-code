-- rec_formation.lua
trans.call.PRFormationList = function(msg)
	FormationData.setTypeData(msg.formation_type, msg.formation_list)
	EventMgr.dispatch(EventType.UserFormationUpdate)
	if msg.formation_type == const.kFormationTypeCommon then
		UserData.updateFightValue()
	end
end