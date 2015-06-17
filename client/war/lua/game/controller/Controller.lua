local function register(file)
	require("lua/game/controller/"..file)
end

register("FormationMgr.lua")
register("OpenFuncMgr.lua")
register("OpeningMgr.lua")
register("TeamMgr.lua")
register("TimeMgr.lua")
