require("lua/preload/PreLoadUtils.lua")
require("lua/preload/PreLoadBg.lua")
require("lua/preload/PreLoadUI.lua")

PreLoadMgr = {}

local function getScene()
	local scene = cc.Director:getInstance():getRunningScene()
	if not scene then
		scene = cc.Scene:create()
		cc.Director:getInstance():runWithScene(scene)
	end
	return scene
end

function PreLoadMgr:start(callback, showLogo)
	local function completeHandler(logo)
		cc.SimpleAudioEngine:getInstance():stopMusic(true) --释放音乐
		self.blackLayer = PreLoadUtils.removeSelfLater(self.blackLayer)
		self.whiteLayer = PreLoadUtils.removeSelfLater(self.whiteLayer)
		PreLoadUtils.removeSelfLater(logo)
		local scene = getScene()
		local bg = PreLoadBg:getInstance()
		scene:addChild(bg, 2)
		local ui = PreLoadUI:getInstance()
		scene:addChild(ui, 3)
		PreLoadMgr.isDone = true
		callback()
	end
	if not showLogo then
		completeHandler()
		return
	end
	local name = "LOGO"
	local path = "image/ui/LoadingUI/"
	local scene = getScene()
	self.blackLayer = PreLoadUtils.getLayerColor(cc.c4b(0,0,0,0xff), visibleSize.width, visibleSize.height, scene)
	local armature = PreLoadUtils.getArmature(path, name, "preload", scene, visibleSize.width / 2, visibleSize.height / 2, completeHandler, 1, 0)
	local function onTimer()
		local index = armature:getAnimation():getCurrentFrame()
		if index == 65 then
			if not self.whiteLayer then
				self.whiteLayer = PreLoadUtils.getLayerColor(cc.c4b(0xff,0xff,0xff,0xff), visibleSize.width, visibleSize.height, scene)
			end
		end
	end
	schedule(armature, onTimer, 0)
	local url = "sound/logo.mp3"
	cc.SimpleAudioEngine:getInstance():playMusic(url, false) --不能用SoundMgr，因为还没有init
end
