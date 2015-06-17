local __scene = Scene:create()
local defaultMap = string.format("image/map/%d.png", 0)

function __scene:onShow(bgUrl)
	local url = bgUrl or defaultMap
	if url == defaultMap then
		LoadMgr.loadImage(defaultMap, LoadMgr.MANUAL, self.name)
	end
	if bgUrl ~= "" then
		self.img_bg = UIFactory.getSprite(url, self, visibleSize.width / 2, visibleSize.height / 2)
	end
end

function __scene:onClose()
	safeRemoveFromParent(self.img_bg)
	self.img_bg = nil
end

SceneMgr.insertScene( 'common', __scene )