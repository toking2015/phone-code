-- Create By Live --

local prevPath = "image/ui/CopyUI/effect/"

local minX = visibleSize.width / 2
local minY = visibleSize.height / 2

CopySceneBG = class("CopySceneBG", function()
	return Node:create()
end)

function CopySceneBG:ctor()
	self.bgPath = ""
	self.mainBg = nil  	-- 背景图片，静止的
	self.chnBg = nil 	-- 探索时能缩放的图片
	self.isSearchComplete = true
	self.fightMonster = nil
end

function CopySceneBG:create(bgPath)
	LogMgr.log( 'debug'," CopySceneBG ....... ")
	local main = CopySceneBG.new()

	main.bgPath = bgPath

	main.mainBg = Sprite:create(bgPath)
	main.mainBg:setPosition(visibleSize.width / 2, visibleSize.height / 2)
	main:addChild(main.mainBg)

	main.chnBg = Sprite:create(bgPath)
	main.chnBg:setVisible(false)
	main.chnBg:setPosition(visibleSize.width / 2, visibleSize.height / 2)
	main:addChild(main.chnBg)


	local function doSearch()
		main:search()
	end
	Command.bind("CopySceneBG search", doSearch)

	local function doSpecialSearch()
		main:judgeSearch()
	end
	Command.bind("CopySceneBG doSpecialSearch", doSpecialSearch)

	return main
end
-- 执行探索动画
function CopySceneBG:search()
	if self.isSearchComplete == true then
		if nil ~= self.chnBg then
			self.isSearchComplete = false
			-- 播放声音
			local url = "sound/Ambiences/" .. CopyData.stepSound .. ".mp3"
			SoundMgr.playStep(url)
            -- 执行缩放图片变大效果，缩放从1->1.5，透明度从255->0，过程中并上下抖动
			self.chnBg:setScale(1)
            self.chnBg:setPosition(visibleSize.width / 2, visibleSize.height / 2)
			self.chnBg:setVisible(true)
			local handler = function(...)
				self.chnBg:stopAllActions()
				self.chnBg:setVisible(false)
				self.chnBg:setOpacity(255)
				
				self.isSearchComplete = true
				
        		self:judgeSearch()
			end
			local fadeOut = cc.FadeOut:create(2)
			local scaleLarge = cc.ScaleTo:create(2, 1.5)
			
			local moveUp = cc.MoveBy:create(0.3, cc.p(0, 50))
			local moveDown = cc.MoveBy:create(0.3, cc.p(0, -50))
			local easeUp = cc.EaseSineIn:create(moveUp)
			local easeDown = cc.EaseSineIn:create(moveDown)
			local seq = cc.Sequence:create(easeUp, easeDown)
			local rep = cc.Repeat:create(seq, 3)
			
			local action = cc.Spawn:create(fadeOut, scaleLarge, rep)
			local complete = cc.CallFunc:create(handler,{})
			self.chnBg:runAction(cc.Sequence:create(action, complete))
		end
	end
end
-- 判断执行chunk事件
function CopySceneBG:judgeSearch()
    LogMgr.debug(">>>>>>>> 解析探索过程")
	local chunk = CopyData.getCurrChunk()
	local evtType = chunk.cate
	
	local evtName = CopyData.getSearchName(evtType)
    LogMgr.log( 'debug',"posi = " .. CopyData.user.copy.posi .. " , 探索类型 : " .. evtName)
    ActionMgr.save("UI", "CopySceneBG judgeSearch chunk cate:" .. chunk.cate .. " objid:" .. chunk.objid .. " val:" .. chunk.val)

    if evtType == const.kCopyEventTypeBox then	-- 2 宝箱 [ objid: packet_id ], [ val: reward_id ]
		self:showBoxResult(chunk)
	elseif evtType == const.kCopyEventTypeReward then -- 3 奖励 [ objid: reward_id ]
		self:showPrizeResult(chunk)
	elseif evtType == const.kCopyEventTypeGut then -- 4 剧情 [ objid: gut_id ]
    	self:showCopyGut(chunk)
	elseif evtType == const.kCopyEventTypeShop then -- 5 商人
		Command.run( 'copy search' )
	elseif evtType == const.kCopyEventTypeFight then -- 6 战斗 [ objid: monster_id ], [ val: fight_id ]
		-- self:showWarOpen(chunk)
		CopyMgr.showCopyFormation()
	elseif evtType == const.kCopyEventTypeFightMeet then -- 7 迎敌战 [ objid: monster_id ], [ val: fight_id ], Monster.strength 消耗体力
		self:showMonsterMet(chunk)
	end
    CopyData.isMetBoss = (evtType == const.kCopyEventTypeFightMeet)
end
-- 显示剧情chunk
function CopySceneBG:showCopyGut(chunk)
	CopyData.currGid = chunk.objid
	LogMgr.log("copy", "当前剧情id = " .. chunk.objid)
	EventMgr.dispatch( EventType.GutInfo, GutType.GutCopyInfo )
end
-- 遇怪chunk
function CopySceneBG:showMonsterMet(chunk)
	LogMgr.log("copy", "showMonsterMet")
	EventMgr.dispatch( EventType.ShowMonsterMet, true )

	local monster = findMonster(chunk.objid)
	if CopyData.user.copy.index == 0 then
		-- CopyData.useChunkStrength()
		-- 先把遇怪第一步事件提交
		Command.run( 'copy search' )
	end
	-- 显示遇怪画面
	SoundMgr.playStep("sound/ui/ui_yudi.mp3")
	self.met = CopyBossMet:create()
	self.met:setBossName(monster)
	self:addChild(self.met)
	--播放遇怪动画
	self.met:startShow()
	-- 攻击怪物
	self.fightMonster = function()
		-- 测试用，忽略战斗
        if Config.data.ignore_fight == true then
            --跳过战斗
    		EventMgr.removeListener(EventType.FightCopyMonster, self.fightMonster)
    		CopyData.fightData = {}
    		Command.run("CopySceneUI hideUI", true)
    		self:removeChild(self.met)
    		Command.run("copy search")
    		return
        end
        -- 判断是否足够体力攻击怪物
		if true == CopyData.enabledSearch() then
			EventMgr.removeListener(EventType.FightCopyMonster, self.fightMonster)
			-- self:showWarOpen(chunk)
			CopyMgr.showCopyFormation()
		else
            --StrengthUI.showBuyStrengt("体力不足，")
            Command.run("show actTips",const.kCoinStrength)
        end
	end
	EventMgr.addListener(EventType.FightCopyMonster, self.fightMonster)
	-- 隐藏部分UI
	Command.run("CopySceneUI hideUI")
end
-- 显示奖励chunk
function CopySceneBG:showPrizeResult(chunk)
	showReward(self)
	Command.run( 'copy search' )
end
-- 显示宝箱chunk
function CopySceneBG:showBoxResult(chunk)
	local function callback()
		LogMgr.debug(">>>>>>>> ShowBoxResult")
		local function showCallBack()
			ActionMgr.save('copy', 'CopySceneBG showBoxResult copy search')
            Command.run( 'copy search' )
		end

		if not GutBox:showTotmeGet( chunk.objid, showCallBack ) then
			showCallBack()
		end
	end
	showPrizeBox(self, callback)
end

function CopySceneBG:dispose()
	Command.unbind("CopySceneBG search")
	Command.unbind("CopySceneBG doSpecialSearch")

	if self.fightMonster ~= nil then
		EventMgr.removeListener(EventType.FightCopyMonster, self.fightMonster)
	end
end


