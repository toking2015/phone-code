
OpeningGut = createUIClassEx("OpeningGut", cc.Node)

function OpeningGut:ctor()
	self:setContentSize(cc.p(visibleSize.width, visibleSize.height))
	self.bg = UIFactory.getLayerColor(cc.c4b(17, 6, 49, 0xff), visibleSize.width, visibleSize.height, self)
	function self.onTouchHandler()
		self.firstTime = self.firstTime + 1
		if self.firstTime > 2 then
			local function jumpOver()
				OpeningMgr.abort()
				self:onPlayComplete()
			end
			showMsgBox("是否跳过开场动画？", jumpOver)
		end
	end
end

function OpeningGut:start(text, completeHandler)
	self.completeHandler = completeHandler
	self.firstTime = 0
end

function OpeningGut:onShow()
	-- self.bg:setTouchEnabled(true)
	-- UIMgr.addTouchBegin(self.bg, self.onTouchHandler)
	-- self.fileList = {}
	-- for i = 1, 3 do
	-- 	table.insert(self.fileList, string.format("image/ui/Opening/openinggut%d.json", i))
	-- end
	-- self.currentIndex = 0
	-- self:playNext()
	-- if not self.isPlaying then
	-- 	SoundMgr.playSceneMusic("opening", false)
 --        self.isPlaying = true
	-- end
end

function OpeningGut:onPlayComplete()
	local callback = self.completeHandler
	self.completeHandler = nil
	PopMgr.removeWindow(self)
	if callback ~= nil then
		callback()
	end
end

function OpeningGut:playNext()
	self.currentIndex = self.currentIndex + 1
	if self.currentIndex > #self.fileList then
		self:onPlayComplete()
		return
	end
	if self.currentIndex == #self.fileList then --预加载战斗资源
		ModelMgr:loadFirstShowModel()
	end
	local json = loadJsonFromFile(self.fileList[self.currentIndex])
	self:killSwf()
	self.swf = SWFRender.new(json, self.winName..self.currentIndex)
	self:addChild(self.swf)
	local function onOneComplete()
		self:playNext()
	end
	self.swf:play(onOneComplete)
end

function OpeningGut:onClose()
	self.bg:setTouchEnabled(false)
	self:killSwf()
	if self.isPlaying then
		SoundMgr.stopMusic()
		self.isPlaying = nil
	end
end

function OpeningGut:killSwf()
	if self.swf then
		self.swf:stop()
		self:removeChild(self.swf)
		self.swf = nil
	end
end
