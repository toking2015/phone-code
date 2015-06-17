
require "lua/game/view/trialUI/TrialStatisticsUI.lua"

local function getUrl(style, name, type)
	FightEffectMgr:pushResource(style)
    return 'image/armature/fight/effect/' .. style .. '/' .. name .. '.' .. type
end
local function getArmatureEffect(url, name, parent, x, y, depth)
    x = (nil == x) and visibleSize.width/2 or x
    y = (nil == y) and visibleSize.height/2 or y
	depth = (nil == depth) and 1 or depth
    local demo = ArmatureSprite:addArmature(url, name, "FightResultUI")
    demo:setAnchorPoint(0, 0)
    parent:addChild(demo, depth)
    demo:setPosition(cc.p(x, y))
    return demo
end

--战斗结果UI
local __this = createUIClassEx("FightResultUI", cc.Layer)
FightResultUI = __this
__this.isClose = false
__this.eff = nil
__this.eff_bg = nil
__this.star_list = nil

function FightResultUI:ctor()
	self.camp = nil		--胜利方阵营
	self.ui = nil		--结算界面句柄
	self.callback = nil	--回调函数

	self:setTouchEnabled(true)
	local function callfunc()
		ActionMgr.save( 'UI', string.format('[%s] click [%s]', self.winName, self.camp) )
		local eff, eff_bg = __this.eff, __this.eff_bg
		if "win" == self.camp or "fail" == self.camp then
			if __this.isClose == true and nil ~= eff then
				eff:play()
				eff:onPlayComplete(function() 
					eff:stop()
	           		TimerMgr.runNextFrame(function() 
	           				LogMgr.debug("移除 FightResultUI")
	           				PopMgr.removeWindowByName("FightResultUI")
	           				__this.eff, __this.eff_bg = nil, nil
	           			end)
				end)
	            eff_bg:runAction(cc.FadeOut:create(0.13))
	            if "win" == self.camp then
		            for _, v in pairs(__this.star_list) do
		                v:runAction(cc.FadeOut:create(0.13))
		            end
		        end
			end
			if self.tid then
				TimerMgr.killTimer(self.tid)
				self.tid = nil
			end
		elseif "trial" == self.camp then
			PopMgr.removeWindowByName("FightResultUI")
		end
	end
	UIMgr.addTouchEnded(self, callfunc)

	self.event_list = {}
	self.event_list[EventType.canCloseFightResultUI] = function()
		self.tid = TimerMgr.startTimer(function() 
			if self:isShow() then 
				TimerMgr.killTimer(self.tid)
				self.tid = nil
				-- PopMgr.removeWindowByName("FightResultUI")
				callfunc() 
			end
		end, 2)
	end
end

function FightResultUI:onShow()
	__this.isClose = false
    EventMgr.addList(self.event_list)
end

function FightResultUI:onClose()
	-- self.enClose = false
    EventMgr.removeList(self.event_list)
	if nil ~= self.callback then
		self.callback()
		self.callback = nil
	end
end

function FightResultUI:dispose()
	if self.tid then
		TimerMgr.killTimer(self.tid)
		self.tid = nil
	end
	if nil ~= self.callback then
		self.callback()
		self.callback = nil
	end
end

function FightResultUI:onBeforeClose()
    return not __this.isClose
end

function FightResultUI:showResult(winCamp, coins_list, callback)
	if self.ui then
		return
	end

	self.callback = callback
	if const.kFightTypeTrialSurvival == FightDataMgr.fight_type 
		or const.kFightTypeTrialStrength == FightDataMgr.fight_type 
		or const.kFightTypeTrialAgile == FightDataMgr.fight_type 
		or const.kFightTypeTrialIntelligence == FightDataMgr.fight_type
	then
		self.ui = TrialStatisticsUI:createStatisticsUI(coins_list)
		__this.isClose = true
		self.camp = "trial"
	else
		if FightAnimationMgr.camp == winCamp then
			self.camp = "win"
			local url = 'sound/ui/win.mp3'
	        self.ui = FightWinUI:createFightWinUI()
			-- self.ui:showStarAction()
			SoundMgr.stopMusic()
			SoundMgr.playEffect(url, false)
		else
			self.camp = "fail"
			local url = 'sound/ui/fail.mp3'
	        self.ui = FightFailUI:createFightFailUI()
	        -- self.ui:showCardAction()
	        SoundMgr.stopMusic()
			SoundMgr.playEffect(url, false)
		end
	end

	local size = self.ui:getSize()
	self.ui:setPosition((visibleSize.width - size.width) / 2, (visibleSize.height - size.height) / 2 + 20) 

    if CopyData.isMonsterBoss == false and FightAnimationMgr.camp == winCamp then
    	self.ui:setPosition((visibleSize.width - size.width) / 2, (visibleSize.height - size.height) / 2 + 60) 
    end
	self:addChild(self.ui)
end

function FightResultUI:idle(time)
	-- if not self.ui then
	-- 	return
	-- end
	-- self.ui:idle(time)
end

------------------------------------------------------------------

--fail windows
FightFailUI =  createUILayout("FightFailUI", FightFileMgr.prePath .. "FightResult/FightFail.ExportJson", "FightDataMgr")

local function createTxtDes(txt, parent, x, y, size, color, w, h)
	local desc = UIFactory.getText(txt, parent, x, y, size, color)
	desc:ignoreContentAdaptWithSize(false)
	desc:setSize(cc.size(w, h))
	local txt = desc:getVirtualRenderer()
    txt:enableOutline(cc.c3b(0x44, 0x22, 0x0a), 0.5)

    return desc
end

local function createOpenTxt(txt, parent, x, y, rgb, fontSize)
    local lbl = ccui.Text:create()
    FontStyle.setFontNameAndSize(lbl, FontNames.HEITI, fontSize)
    addOutline(lbl,cc.c4b(0x44, 0x22, 0x0a),0.5)
    lbl:setColor(rgb)
    lbl:setString(txt)
    lbl:setAnchorPoint(cc.p(0, 0))
    lbl:setPosition(cc.p(x, y))

    parent:addChild(lbl)

    return lbl
end

local function showCardDescription(obj, index)
	if index == 1 then
		return
	end
	-- local obj = list[index]
	local size = obj:getSize()
	local desc = createTxtDes(nil, obj, size.width/2+5, 51, 18, cc.c3b(0xff,0xdd,0xb3), 175, 74)
	local node = cc.Node:create()
	local open_1 = createOpenTxt("战队等级", node, 0, 0, cc.c3b(0xff, 0xff, 0xff), 18)
	local size_1 = open_1:getContentSize().width
	local open_2 = createOpenTxt("30级", node, size_1, 0, cc.c3b(0xfe, 0x3e, 0x31), 18)
	local size_2 = open_2:getContentSize().width
	local open_3 = createOpenTxt("开放", node, size_1 + size_2, 0, cc.c3b(0xff, 0xff, 0xff), 18)
	local size_3 = open_3:getContentSize().width
	obj:addChild(node, 100)
	local width = size_1 + size_2 + size_3
	node:setPosition(cc.p((size.width - width)/2, 61))

	local teamLevel = gameData.getSimpleDataByKey('team_level')
	-- if index == 1 then
	-- 	desc:setString("升级与进阶英雄，可以获得更强大的技能与属性")
	if index == 2 then
		if teamLevel < 10 then
			-- desc:setString("战队等级10级开放")
			node:setVisible(true)
			desc:setVisible(false)
			open_2:setString("10级")
		else
			node:setVisible(false)
			desc:setVisible(true)
			desc:setString("升级图腾，可以为队员提供更强的属性加成")
		end
	elseif index == 3 then
		if teamLevel < 20 then
			node:setVisible(true)
			desc:setVisible(false)
			open_2:setString("20级")
			-- desc:setString("战队等级20级开放")
		else
			node:setVisible(false)
			desc:setVisible(true)
			desc:setString("好的装备可以提供更高的属性，使你更加强壮")
		end
	else
		if teamLevel < 40 then
			node:setVisible(true)
			desc:setVisible(false)
			open_2:setString("40级")
			-- desc:setString("战队等级30级开放")
		else
			node:setVisible(false)
			desc:setVisible(true)
			desc:setString("神符可以使成员更强大，还会产生额外的效果")
		end
	end
end

function FightFailUI:ctor()
	local url_1 = "image/armature/fight/effect/shibai-tx-01/shibai-tx-01.ExportJson"
	local shibai = getArmatureEffect(url_1, "shibai-tx-01", self, 293, 331, 2)
	__this.eff = shibai
	local shibai_bg = nil

	local function onTimer()
        local index = shibai:getAnimation():getCurrentFrame()
        if index >= 30 and nil == shibai_bg then
			local url_2 = "image/armature/fight/effect/shibai-tx-02/shibai-tx-02.ExportJson"
			shibai_bg = getArmatureEffect(url_2, "shibai-tx-02", self, 326, 348, 1)
			__this.eff_bg = shibai_bg
        	LogMgr.debug("到30帧，播放特性2" .. index)
        elseif index >= 70 then
            shibai:stop()
            shibai:stopAllActions()
            self:showCardAction()
        end
    end
    schedule(shibai, onTimer, 0)
end

function FightFailUI:createFightFailUI()
	local view = FightFailUI.new()

	view:setTouchEnabled(false)
	view.fail_tips:setLocalZOrder(3)

	view.cardList = {view.fail_hero, view.fail_totem_upgrade, view.fail_equipment, view.fail_totem_glypy}
	local imgList = {"fail_hero_promot", "fail_totem_upgrade", "fail_equipment", "fail_totem_glypy"}
	for k, v in pairs(view.cardList) do
		v:setScale(0.65)
		v:loadTexture(FightFileMgr.prePath..'FightResult/'..imgList[k]..'.png', ccui.TextureResType.localType)
		v:setVisible(false)
	end

	-- view:showCardAction()

	return view
end

function FightFailUI:showCardAction()
	local teamLevel = gameData.getSimpleDataByKey('team_level')
	if teamLevel <= 20 then
		local url = FightFileMgr.prePath..'FightResult/fail_hero_obtain.png'
		local hero_obtain = ccui.ImageView:create(url, ccui.TextureResType.localType)
		self:addChild(hero_obtain)
		hero_obtain:setTouchEnabled(false)
		hero_obtain:setScale(0.65)
		hero_obtain:setPosition(cc.p(self:getSize().width/2, 181))
		local scale = cc.ScaleTo:create(0.12, 1)
		local bounceOut = cc.EaseBounceOut:create(scale)
		hero_obtain:runAction(cc.Sequence:create(bounceOut, cc.CallFunc:create(function() __this.isClose = true end)))
	else
		local i = 0
		local len = #(self.cardList)
		local function callback()
			if i < len then
				i = i + 1
				local function loadCardFunc()
					-- cardList[i]:loadTexture(FightFileMgr.prePath..'FightResult/'..imgList[i]..'.png', ccui.TextureResType.localType)
					self.cardList[i]:setVisible(true)
					showCardDescription(self.cardList[i], i) 
				end
				local callfunc = cc.CallFunc:create(loadCardFunc)

				local obj = self.cardList[i]
				local scale = cc.ScaleTo:create(0.12, 1)
				local bounceOut = cc.EaseBounceOut:create(scale)

				local sq = cc.Sequence:create(callfunc, bounceOut)
				self.cardList[i]:runAction(sq)
				if i == len then
					__this.isClose = true
					EventMgr.dispatch(EventType.canCloseFightResultUI)
				end
			end
		end
		a_repeate(self, callback, 0.1, len+1)
	end
	
end

function FightFailUI:idle()
end
function FightFailUI:releaseAll()
	-- self:release()
end

----------------------------------------------------

-- win window
-- FightWinUI = class("FightWinUI", function() 
-- 	return getLayout(FightFileMgr.prePath .. "FightResult/FightWin.ExportJson")
-- end)
FightWinUI =  createUILayout("FightWinUI", FightFileMgr.prePath .. "FightResult/FightWin.ExportJson", "FightDataMgr")

local function getFightResultStar(view, star_list, show_list)
	for i = 1, 3, 1 do
		local star = nil
		if 2 == i then 
			star = Sprite:createWithSpriteFrameName("fight_win_star_big.png")
			star:setPosition(314, 353)
		elseif 1 == i then
			star = Sprite:createWithSpriteFrameName("fight_win_star_small.png")
			star:setPosition(205, 333)
		else
			star = Sprite:createWithSpriteFrameName("fight_win_star_small.png")
			star:setPosition(421, 333)
		end

		star:setScale(0.65)
		star:setVisible(false)
		table.insert(star_list, star)
		table.insert(show_list, star)
		view:addChild(star)
	end
end

local function setStarData(star_list)	
	local count = FightDataMgr.theFight:getLeftDeadSoldierCount()
	local v = count
	for i = #star_list, 1, -1 do
		if count <= 0 then
			star_list[i]:setGLProgramState(ProgramMgr.createProgramState('normal'))
		else
			count = count - 1
			star_list[i]:setGLProgramState(ProgramMgr.createProgramState('gray'))
		end
	end

	if v >= 3 then
		star_list[1]:setGLProgramState(ProgramMgr.createProgramState('normal'))
	end
end

function FightWinUI:createFightWinUI()
	local view = FightWinUI.new()

	view:setTouchEnabled(false)

	local star_list = {}
	local show_list = {}

	-- view.win_bg:loadTexture(FightFileMgr.prePath .. 'FightResult/win_bg.png', ccui.TextureResType.localType)	

	if CopyData.isMonsterBoss == true then
		getFightResultStar(view, star_list, show_list)
		setStarData(star_list)
	end

	local url_1 = "image/armature/fight/effect/shengli-tx-01/shengli-tx-01.ExportJson"
	local url_2 = "image/armature/fight/effect/shengli-tx-02/shengli-tx-02.ExportJson"
	local shengli = getArmatureEffect(url_1, "shengli-tx-01", view, 13, -68, 2) -- 0 -> -68
	local shengli_bg = getArmatureEffect(url_2, "shengli-tx-02", view, 100, -63, 1)  -- 5 -> -63
	__this.eff = shengli
	__this.eff_bg = shengli_bg
	__this.star_list = star_list
	local function onTimer()
        local index = shengli:getAnimation():getCurrentFrame()
        if index >= 91 then
        	-- LogMgr.debug("到91帧，可以点击关闭" .. index)
            shengli:stop()
            shengli:stopAllActions()
            view:showStarAction(show_list)
            if CopyData.isMonsterBoss == true then
            	view:showStarEffAction()
            end
        end
    end
    schedule(shengli, onTimer, 0)

	local win_quit = Sprite:createWithSpriteFrameName("win_quit.png")
	win_quit:setPosition(cc.p(313, -31))
	view:addChild(win_quit)
	win_quit:setVisible(false)
	table.insert(show_list, win_quit)

	return view
end

local function getStarCount(dead)
	if 0 == dead then
        return 3
    elseif 1 == dead then
        return 2
    elseif dead >= 2 then
        return 1
    end
end

function FightWinUI:showStarEffAction()
	local dead = FightDataMgr.theFight:getLeftDeadSoldierCount()
	local count = getStarCount(dead)
	local star_eff_url = "image/armature/scene/copy/jqys-5/jqys-5.ExportJson"
	local i = 0
	local function callback()
		if i < count then
			i = i + 1
			SoundMgr.playEffect("sound/ui/star.mp3")
			local star_eff = getArmatureEffect(star_eff_url, "jqys-5", self)
			star_eff:onPlayComplete(function()
				LogMgr.debug("star_eff 播放结束")
				-- star_eff:stop()
				star_eff:setVisible(false)
				star_eff:removeNextFrame()
				star_eff = nil
			end)
			star_eff:setAnchorPoint(cc.p(0.5, 0.5))
			if 1 == i then
				star_eff:setPosition(cc.p(205, 333))
			elseif 2 == i then
				star_eff:setPosition(cc.p(314, 353))
			else
				star_eff:setPosition(cc.p(421, 333))
			end
		end
	end
	a_repeate(self, callback, 0.15, count)
end

function FightWinUI:showStarAction(show_list)
	local i = 0
	local len = #(show_list)
	local function callback()
		if i < len then
			i = i + 1
			local obj = show_list[i]
			local show = cc.Show:create()
			local scale = cc.ScaleTo:create(0.12, 1)
			local bounceOut = cc.EaseBounceOut:create(scale)
			obj:runAction(cc.Sequence:create(show, bounceOut))
			if i == len then
				__this.isClose = true
				EventMgr.dispatch(EventType.canCloseFightResultUI)
			end
		end
	end
	a_repeate(self, callback, 0.1, len+1)
end

function FightWinUI:idle()
end

