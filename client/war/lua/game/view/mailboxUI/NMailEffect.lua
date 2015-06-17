local __this = {}
NMailEffect = __this

__this.isRecMail = false
__this.timer_id = nil

-- 收到新邮件特效
function __this.showMailBoxEffect()
	__this.timer_id = nil
	NMailEffect.isRecMail = false
	local armPath = "image/armature/ui/mailboxUI/"
	LoadMgr.loadArmatureFileInfo(armPath .. "sdyj-tx-01/sdyj-tx-01.ExportJson", LoadMgr.SCENE, "main")
	local effect = ArmatureSprite:create("sdyj-tx-01", 0)
	effect:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
	local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    layer:addChild(effect)

    local function callback()
    	effect:stop()
    	effect:removeNextFrame()
    end
    effect:onPlayComplete(callback)
end

function __this.checkShowEffect()
	-- if SceneMgr.isSceneName("main") then
		if true == __this.checkCanRun() then
			if not __this.timer_id then
				__this.timer_id = TimerMgr.callLater(__this.showMailBoxEffect, 0.5)
			end
		end
	-- end
end

function __this.checkCanRun()
	-- if not SceneMgr.isSceneName("main") then
	-- 	return
	-- end
	-- local copy = PopMgr.getWindow("NCopyUI")
	-- if copy and copy:isShow() then
	-- 	return
	-- end
	local gut = PopMgr.getWindow("GutUI")
	if gut and gut:isShow() then
		return
	end
	if PopMgr.getRemoveOnce() then
        return
	end
	if NMailEffect.isRecMail == false then
		return
	end
	return true
end

local function onSceneShow()
    -- if SceneMgr.isSceneName("main") then
    	NMailEffect.checkShowEffect()
	-- end
end

local function onWindowClose(data)
	-- if data and data.winName == "NCopyUI" then
		NMailEffect.checkShowEffect()
	-- end
end

EventMgr.addListener(EventType.SceneShow, onSceneShow)
EventMgr.addListener(EventType.CloseWindow, onWindowClose)