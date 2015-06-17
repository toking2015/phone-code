-- Create By Hujingjiang --
local MAX_EFFECT_TIME = 20 --最长音效时长
local prevPath = "sound/scene/"
local audio = cc.SimpleAudioEngine:getInstance()
local musicVolume = 1
local effectVolume = 1
audio:setMusicVolume(musicVolume)
audio:setEffectsVolume(effectVolume)

local _this = { _effect_cache = {} }
SoundMgr = _this

local prevMusic = ""

local sceneDic = {
	main = prevPath .. "Menumusic.mp3",
	fight = {prevPath .. "Battlemusic1.mp3", prevPath .. "Battlemusic2.mp3"},
	opening = prevPath .. "Battlemusic2.mp3",
    arena = {prevPath .. "arenamusic.mp3", prevPath .. "Battlemusic1.mp3"},
	copy = prevPath .. "Menumusic.mp3",
	copyUI = prevPath .. "Menumusic.mp3"
}

_this.isArena = false

local ischat = false 
function _this.isPlayChat()
   return ischat
end

function _this.setPlayChat(flag)
   ischat = flag 
end 

-- 0-1 之间
function _this.setMusicValume(valume)
    audio:setMusicVolume(valume)
end

--回到之前音量
function _this.resetMusicValume()
    audio:setMusicVolume(musicVolume)
end  
 
--暂停所有音乐
function _this.pauseAllMusic()
    audio:pauseMusic()
end 

function _this.pauseAllEffect()
    audio:pauseAllEffects()
end 

function _this.resumeAllEffect()
	if not TeamData.getSettingValue("sound") then
		return
	end
    audio:resumeAllEffects()
end 
--重启所有音乐
function _this.resumeAllMusic()
	if not TeamData.getSettingValue("music") then
		return
	end
    _this.enableSceneMusic(true)
end

function _this.getSceneMusic(sceneName)
    local bgMusicPath = sceneDic[sceneName]
    if sceneName == "fight" then
		if FormationData.type == const.kFormationTypeSingleArenaAct or FormationData.type == const.kFormationTypeSingleArenaDef or _this.isArena == true then
			bgMusicPath = _this.getSceneMusic("arena")
		end
	elseif sceneName == "copy" then
		local copyMusic = CopyData.getCurrCopyMusic()
		if copyMusic then
			bgMusicPath = "sound/Ambiences/" .. copyMusic .. ".mp3"
		else
			bgMusicPath = sceneDic["copy"] -- 默认的
		end
	end
    if type(bgMusicPath) == "table" then
    	bgMusicPath = bgMusicPath[MathUtil.random(1, #bgMusicPath)]
    end
	return bgMusicPath
end

local function playMusic(url, isLoop)
	if TeamData.getSettingValue("music") then
		_this.stopMusic()
		if url and url ~= "" then
			audio:playMusic(url, isLoop)
		end
	end
	prevMusic = url
end

function _this.playSceneMusic(sceneName)
	local bgMusicPath = _this.getSceneMusic(sceneName)
	if bgMusicPath ~= nil then
		if bgMusicPath ~= prevMusic then
            _this.release()
			playMusic(bgMusicPath, true)
		end
	end
end

--@param release 是否释放资源
function _this.stopMusic(release)
	audio:stopMusic(release)
	prevMusic = ""
end

function _this.enableSceneMusic(value)
	if value then
		if audio:isMusicPlaying() then
			audio:resumeMusic()
		else
			playMusic(prevMusic, true)
		end
	else
		audio:pauseMusic()
	end
end

function _this.stopAllEffects()
	audio:stopAllEffects()
	_this.release(true)
end

function _this.preloadEffect(url)
	-- if not TeamData.getSettingValue("sound") then
	-- 	return
	-- end
	-- audio:preloadEffect(url)
end

function _this.setEffectsVolume(volume)
	audio:setEffectsVolume(volume or effectVolume)
end

local function find_effect_cache(url)
    local effects = _this._effect_cache[ url ]
    if not effects then
        effects = {}
        _this._effect_cache[ url ] = effects
    end
    return effects
end

function _this.playEffect(url, force, pitch)
    if _this.isPlayChat() == false then 
    	if not force and not TeamData.getSettingValue("sound") then --force代表强迫
    		return
    	end
    	pitch = pitch or 1
    	--effect不允许重复播放, 需要重复播放在外层控制
    	local effect_id = audio:playEffect(url, false, pitch)
    	local effects = find_effect_cache( url )
        effects[effect_id] = system.time_sec() + MAX_EFFECT_TIME
    	return effect_id
    else 
        return nil 
	end 
end

function _this.stopEffect(id)
    if id then
        audio:stopEffect(id)
        for key, var in pairs(_this._effect_cache) do
            if var[id] then
                var[id] = nil
        	    return
        	end
        end
    end
end

function _this.playStep(url)
    _this.playEffect(url)
end

function _this.playUI(name)
	local url = string.format("sound/ui/%s.mp3", name)
    _this.playEffect(url)
end

function _this.playSoldierTalk(soldierId)
   	local rand = math.random(1, 3)
	local url = string.format("sound/talk/%s_%d.mp3", soldierId, rand)
    _this.playEffect(url)
end

--播放语音，与设置无关
function _this.playChat(url)
	_this.playEffect(url, true)
end

--释放effect
--@param force 是否强制释放所有的音效
function _this.release(force)
    local time_now = system.time_sec()
    for url, effects in pairs(_this._effect_cache) do
        local hasEffect = false
        if not force then
	        for key, var in pairs(effects) do
	    		if time_now >= var then
	                audio:stopEffect( key )
	    		    effects[ key ] = nil
	    		else
	    		    hasEffect = true
	    		end
	    	end
	    end
    	if not hasEffect then
    	    audio:unloadEffect( url )
    	    _this._effect_cache[ url ] = nil
    	end
    end
end
