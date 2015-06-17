TeamData = TeamData or {}

TeamData.AVATAR_AVATAR = 1
TeamData.AVATAR_SOLDIER = 2
TeamData.AVATAR_CHENGJIU = 3
TeamData.AVATAR_OFFSET = cc.p(0, 14) --头像偏移位置

TeamData.forceRename = false --是否强制改名

local settingData = {
	hasInit=false,
	sound=true,
	music=true,
	strength_get=true,
	activity=true,
	store=true,
	strength_full=true
}

function TeamData.getData()
	return gameData.user.team
end

function TeamData.getChangeNameCount()
	return TeamData.getData().change_name_count
end

function TeamData.addChangeNameCount()
	gameData.user.team.change_name_count = TeamData.getChangeNameCount() + 1
end

function TeamData.getChangeNameCost()
	local times = TeamData.getChangeNameCount()
	return times == 0 and 0 or 100 --首次免费，后面固定100元宝
	-- local result = times * toint(findGlobal("change_name_cost_multiple").data)
	-- local max = toint(findGlobal("change_name_const_limit").data)
	-- return result > max and max or result
end

--获取战队头像路径
function TeamData.getAvatarUrlById(avatarId)
	return TeamData.getAvatarUrl(findAvatar(avatarId))
end

--获取战队头像路径, jAvatar
function TeamData.getAvatarUrl(jAvatar)
	if jAvatar then
		return string.format("image/icon/avatar/%s.png", jAvatar.avatar)
	end
end

function TeamData.getSettingValue(name)
	if not settingData.hasInit then
		local data = LocalDataMgr.load_string(0, "team_setting")
		if data then
			copyToSource(settingData, json.decode(data))
		end
		settingData.hasInit = true
	end
	return settingData[name]
end

function TeamData.setSettingValue(name, value)
	 settingData[name] = value
	 LocalDataMgr.save_string(0, "team_setting", json.encode(settingData))
 	if name == "sound" and not value then
 		SoundMgr.stopAllEffects()
 	end
 	if name == "music" then
		SoundMgr.enableSceneMusic(value)
 	end
end