--本地GM命令
local function serverCommand(...)
	Chat.sendMessage({msg="$$ "..table.concat( {...}, " "), type=1})
end
Command.bind("$$", serverCommand)

local function soldierAddAll()
	local list = GetDataList("Soldier")
	for _,v in pairs(list) do
		serverCommand("soldier add "..v.id)
	end
end
Command.bind("soldier add all", soldierAddAll)

local function totemAddAll()
	local list = GetDataList("Totem")
	for _,v in pairs(list) do
		serverCommand("totem add "..v.id)
	end
end
Command.bind("totem add all", totemAddAll)

local function glyphAddAll()
	local list = GetDataList("TotemGlyph")
	for _,v in pairs(list) do
		serverCommand("totemglyph add "..v.id)
	end
end
Command.bind("glyph add all", glyphAddAll)

local function glyphAdd(id, num)
	num = num or 10
	for i=1, num do
		serverCommand("totemglyph add "..id)
	end
end
Command.bind("glyph add", glyphAdd)

local function fightMonster(id)
	local function callback()
		serverCommand("fight monster "..id)
	end
	Command.run("formation show monster", id, callback)
end
Command.bind("fight monster", fightMonster)
