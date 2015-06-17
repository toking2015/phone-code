local textureCache = cc.Director:getInstance():getTextureCache()

BitmapUtil = BitmapUtil or {}
BitmapUtil.timer_id = nil
BitmapUtil.spriteMap = {}
BitmapUtil.spriteList = {}

--使用队列方式进行图片的加载，而不是一帧就全部加载
--主要针对单个的散图片，缓解cpu卡的问题
function BitmapUtil.setTexture(sprite, url)
	if not sprite then
		return
	end
	if not BitmapUtil.spriteMap[sprite] then
		sprite:retain()
		table.insert(BitmapUtil.spriteList, sprite)
	end
	BitmapUtil.spriteMap[sprite] = url or ""
	BitmapUtil.start()
end

function BitmapUtil.start()
	if BitmapUtil.timer_id == nil then
		BitmapUtil.timer_id = TimerMgr.startTimer(BitmapUtil.onEnterFrame, 0, false)
	end
end

function BitmapUtil.stop()
	if BitmapUtil.timer_id and #BitmapUtil.spriteList == 0 then
		BitmapUtil.timer_id = TimerMgr.killTimer(BitmapUtil.timer_id)
	end
end

function BitmapUtil.onEnterFrame()
	local sprite = table.remove(BitmapUtil.spriteList, 1)
	if sprite then
		local url = BitmapUtil.spriteMap[sprite]
		if "" ~= url then
			if textureCache:getTextureForKey(url) then
				BitmapUtil.onEnterFrame()
			end
            if sprite.setTexture then
				sprite:setTexture(url)
			elseif sprite.loadTexture then
				sprite:loadTexture( url, ccui.TextureResType.localType )
			end
		else
			BitmapUtil.onEnterFrame()
		end
		BitmapUtil.spriteMap[sprite] = nil
		sprite:release()
	else
		BitmapUtil.stop()
	end
end
