--剧情管理类
GutMgr={}
GutMgr.gutLogList = {}
GutMgr.endGutList = {}
GutMgr.lastGut = nil
GutMgr.lock = false

--------------------------------
--json数据处理
function getNmaeForGut( gut )
	local name = ''
	if gut.attr == const.kAttrPlayer then
		--玩家
	elseif gut.attr == const.kAttrSoldier then
		local soldier = findSoldier( gut.monster )
		name = soldier.name
	elseif gut.attr == const.kAttrTotem then
		--图腾
	elseif gut.attr == const.kAttrMonster then
		local monster = findMonster( gut.monster )
		name = monster.name
	elseif gut.attr == const.kAttrNpc then
		local npc = findNpc( gut.monster )
		name = npc.name
	end
	return name
end

function getIconForGut( gut )
	local icon = ''
	if gut.attr == const.kAttrPlayer then
		--玩家
	elseif gut.attr == const.kAttrSoldier then
		local soldier = findSoldier( gut.monster )
		icon = soldier.avatar
	elseif gut.attr == const.kAttrTotem then
		--图腾
	elseif gut.attr == const.kAttrMonster then
		local monster = findMonster( gut.monster )
		icon = monster.avatar
	elseif gut.attr == const.kAttrNpc then
		local npc = findNpc( gut.monster )
		icon = npc.body
	end

	-- assert( gut.monster ~= 0, '对话剧情 monster不能为0, 剧情' .. gut.id )
	return "image/photo/"..icon..".png"
end
----------------------------------------剧情控制
local function sendGutLog( log )
	if GutData.getType() == GutType.GutInfo then
		Command.run( 'gut commit', log.index )
	end
end

local function sendGutLogList()
    if GutMgr.gutLogList ~= nil then
    	for i,v in ipairs( GutMgr.gutLogList ) do
    		-- print( i, v.index, v.type )
    		sendGutLog( v )
    	end
	end
end

local function runTalk( gut )
	PopMgr.getWindow( 'GutUI' ):updateGut( gut )
	GutMgr.autoNext = false
end

local function runVideo( gut )

end

local function runOpenBox( gut )
	GutBox:runBox( gut )
	GutMgr.autoNext = false
	GutMgr.lock = true
end

local function runReward( gut )
	GutBox:runReward( gut )
	GutMgr.autoNext = false
	GutMgr.lock = true
end

local function runAnimation( gut )
end

local function getLogList()
	local data = GutData.getData()
	local list = {}
	if data.event then
		for i,v in ipairs(data.event) do
			table.insert( list, {type=v.cate, index=i})
			-- findGut( GutData.getId(), GutData.getStep() )
		end
	end
	return list
end

function GutMgr:endGut()
    if GutMgr.isRing == true then
    	InductMgr:replayerCopyOpen()

    	GutMgr.gutLogList = getLogList()
    	local data = {}
    	data.type = GutData.getType()
    	data.logList = GutMgr.gutLogList
    	EventMgr.dispatch( EventType.GutEnd, data )

    	if data.type== GutType.GutFightInfo then
    		FightDataMgr:fightContinue()
    	elseif data.type == GutType.GutInfo then
    		sendGutLogList()
    		table.insert( GutMgr.endGutList, GutData.getId() )
    	end
    	
        GutMgr.lock = false
        GutMgr.isRing = false    	

    	EventMgr.dispatch( EventType.GutInductEnd, GutData.getId() )    

        GutMgr.gutLogList = {}
        GutData.clear()	
    	GutMgr.lastGut = nil
    end
end

local function runGut( gut )
    GutMgr.isRing = true
    --通用效果处理
    if gut.sound ~= '' then
		local url = "sound/" .. gut.sound .. ".mp3"
    	SoundMgr.playEffect(url, false)
    end
    
    if gut.weather ~= 0 then
		EventMgr.dispatch( EventType.ChangeMainState, gut.weather )
	end
	
    if gut.shaking_screen ~= 0 then
        if gut.shaking_screen == 1 then
            ShakeMgr.startShake( SceneMgr.getCurrentScene(), 3, "GutMgr")
        else
            ShakeMgr.stopAllShake( "GutMgr" )
        end
    end
    
    if gut.shock ~= 0 then
    end
    
    --具体剧情逻辑执行
	if gut.type == const.kGutTypeTalk then
		runTalk( gut )
	elseif gut.type == const.kGutTypeFight then
		-- runFight( gut )
	elseif gut.type == const.kGutTypeBox then
		runOpenBox( gut )
	elseif gut.type == const.kGutTypeReward then
		runReward( gut )
	elseif gut.type == const.kGutTypeVideo then
		runVideo( gut )
	elseif gut.type == const.kGutTypeSpecial then	
		--特殊类型暂未处理
	end
end

function GutMgr:runGutNext()
	if GutMgr.lock == false then
        local gut = findGut( GutData.getId(), GutData.getStep() )
		if gut ~= nil and gut.id ~= 0 then
			runGut( gut )
			GutData.setStep()
			local isAuto = GutMgr.autoNext
			GutMgr.autoNext = true

			if isAuto == true then
	            EventMgr.dispatch( EventType.autoGut )
			end

			GutMgr.lastGut = gut
		else
			Command.run( 'ui hide', 'GutUI' )
		end
	end
end

function GutMgr:runGutStart()
	GutData.setStartData()
	GutMgr.gutLogList = {}
	GutMgr:runGutNext()
end

local function startGut( data )
	GutData.setType( data )
	ActionMgr.save( 'mgr', '[GutMgr] data='..data..' id='..GutData.getId()..' step='..GutData.getStep() )
	if GutData.CheckCanRun() then
		PopMgr.checkPriorityPop(
			"GutUI", 
			PopOrType.Gut,
			function()
				if table.find( GutMgr.endGutList, GutData.getId() ) == false then
	     			Command.run("ui show", "GutUI", PopUpType.MODEL, true)
	     			GutMgr:runGutStart()
	     		else
                    Command.run("ui hide", "GutUI")
	     		end
     		end
     	)
	end
end

function GutMgr:sceneEnter( data )
    if data ~= 'fight' and data ~= 'opening' then
    	if GutData.CheckCanRun() then
			PopMgr.checkPriorityPop(
				"GutUI", 
				PopOrType.Gut,
				function()
					if table.find( GutMgr.endGutList, GutData.getId() ) == false then
		     			Command.run("ui show", "GutUI", PopUpType.MODEL, true)
		     			GutMgr:runGutStart()
                    else
                        Command.run("ui hide", "GutUI")
                    end
	     		end
	     	)
       	end
    end
end

local function fightCopyGut( chunk )
	FightDataMgr:fightPause()
	GutData.setFightData( chunk.first, chunk.second )
	EventMgr.dispatch( EventType.GutInfo, GutType.GutFightInfo )
end

local function clickGutTalk( data )
	GutMgr:runGutNext()

	if GutMgr.isRing == false or ( GutMgr.lastGut ~= nil and GutMgr.lastGut.type ~= const.kGutTypeTalk ) then
		EventMgr.dispatch( EventType.hideGutTalk )
	end			
end

local function endGutBox( data )
	GutMgr.lock = false
	GutMgr:runGutNext()
end

local function endGutReward()
	GutMgr.lock = false
	GutMgr:runGutNext()
end

local function autoGut()
	GutMgr:runGutNext()
end

function GutMgr:checkGutEndForId( id )
	if GutData:getId() == id then
		return GutMgr.isRing == false 
	end
	return true 
end

function GutMgr:getTransformGut(id)
	local list = GetDataList( 'Gut' )

	local gutList = {}
	for k,v in pairs(list) do
		if k == id then
			for i=0,#v, 1 do
				table.insert( gutList, {cate = v[i].type, objid = 1, val=1} )
			end
		end
	end

	-- if #gutList > 0 then
	-- 	local sortFunc = function(a, b) 
	-- 		return b.step > a.step
	-- 	end
	-- 	table.sort( gutList, sortfunction )

	-- end
	return {gut_id = id, index = 0, event=gutList}
end

EventMgr.addListener( EventType.endGutReward, endGutReward )
EventMgr.addListener( EventType.endGutBox, endGutBox )
EventMgr.addListener( EventType.clickGutTalk, clickGutTalk )
EventMgr.addListener( EventType.GutInfo, startGut )

EventMgr.addListener( EventType.FightCopyGut, fightCopyGut )
