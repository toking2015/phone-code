NameRandom = NameRandom or {}

function NameRandom.init()
	NameRandom.json = loadJsonFromFile("cbm/name.json")
end

function NameRandom.getRandomName()
	if not NameRandom.hasInit then
        NameRandom.hasInit = true
		NameRandom.init()
	end
	local name = NameRandom.doGetRandomName()
	while WordFilter.checkName(name) do
		name = NameRandom.doGetRandomName()
	end
	return name
end

function NameRandom.doGetRandomName()
	local result = ""
	for i = 1, 3 do
		local ary = NameRandom.json[tostring(i)]
		if (ary) then
			local key = math.random(1, #ary)
			result = result .. ary[key]
		end
	end
	return result
end
