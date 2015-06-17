-- Create By Live --

local fps = 1 / 12

function createSpriteFrames(pattern, begin, length, isReversed)
	local frames = {}
	local step = 1
	local last = begin + length - 1
	if isReversed then
		last, begin = begin, last
		step = -1
	end
	
	for index = begin, last, step do
		local frameName = string.format(pattern, index)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
		if not frame then
			break
		end
		table.insert(frames, frame)
	end

	--LogMgr.log( 'debug', debug.dump(frames) )

	return frames
end

AnimateSprite = class("AnimateSprite", function()
	local sprite = Sprite:create()
	return sprite
end)

function AnimateSprite:create(_list, _isPlay, _startFrame, _delay, _isLoop)
	local sprite = AnimateSprite.new()

	local frames = _list or {}
	local isPlay = true
	if nil ~= _isPlay then isPlay = _isPlay end
	local isLoop = true
	if nil ~= _isLoop then isLoop = _isLoop end
	local currentFrame = _startFrame or 1
	local totalFrames = table.getn(frames)
	local delay = _delay or fps
	local schedulerID = nil

	-- px,py为左下角与注册点的偏移值（正数）
	function sprite:setOffset(px, py)
		local size = sprite:getContentSize()
		local p = cc.p(px / size.width, py / size.height)

		sprite:setAnchorPoint(p)
	end

	function sprite:showFrame(frame)
--        sprite:loadTexture(frames[frame],ccui.TextureResType.plistType)
--        sprite:setTexture(frames[frame])
        sprite:setSpriteFrame(frames[frame])
	end

	function sprite:step()
		currentFrame = currentFrame + 1
		if currentFrame <= totalFrames then
			self:showFrame(currentFrame)
		end
		if currentFrame == totalFrames then
			if isLoop == false then
				self:stop()
			else
				currentFrame = 1
			end
		end
	end

	function sprite:play()
		local _this = self
		if isPlay == false then
			isPlay = true
		end
		if totalFrames > 1 then
			if currentFrame < totalFrames or isLoop == true then
				schedulerID = TimerMgr.startTimer(function () 
														self:step() 
												end, delay, false)
				local function onNodeEvent(event)
                   if "exit" == event or "exitTransitionStart" == event then
			           self:stop()
			       end
			    end
			    self:registerScriptHandler(onNodeEvent)
			end
		end
	end

	function sprite:remove()
		self:stop()
		self:removeFromParent()
	end

	function sprite:stop()
		isPlay = false
		self:unregisterScriptHandler()
		if schedulerID ~= nil then
			TimerMgr.killTimer(schedulerID)	
		end
	end

	function sprite:gotoAndPlay(frame)
		currentFrame = frame
		self:play()
	end

	function sprite:gotoAndStop(frame)
		self:stop()
		currentFrame = frame
		if currentFrame > totalFrames then
			currentFrame = totalFrames
		end
		self:showFrame(currentFrame)
	end

	function sprite:getCurrentFrame()
		return currentFrame
	end

	function sprite:getTotalFrames()
		return totalFrames
	end

	function sprite:isPlay()
		return isPlay
	end

	function sprite:isLoop()
		return isLoop
	end

	local function init()
		if true == isPlay then
			sprite:play()
		end
	end

	init()

	return sprite
end

-- AnimateGroup = class("AnimateGroup", function()
-- 	local animate = Node.create()
-- 	return animate
-- end)

