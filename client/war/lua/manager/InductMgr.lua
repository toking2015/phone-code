--新手引导管理
InductMgr = InductMgr or {}

local isOpen = Config.data.guide
-- isOpen = false
local runData = nil

local runGuideData = nil

local isRun = false
local isGuideRun = false

local gutData =	{}
local gutEndInduct = 0
local gutEndIndex = 0
local lastSoundId = 0

function InductMgr.clear()
	if InductMgr.endInduct then InductMgr:endInduct( true ) InductMgr:endInduct( false ) end

	runData = nil

	runGuideData = nil

	isRun = false
	isGuideRun = false

	gutData = {}
	gutEndInduct = 0
	gutEndIndex = 0
	lastSoundId = 0

	InductMgr.indexData = nil
	InductMgr.index = 0
	InductMgr.inductId = 0	

	InductMgr.guideIndexData = nil
	InductMgr.guideId = 0
	InductMgr.guideIndex = 0

	InductMgr.isJJCFight=false

	if InductUI then InductUI:onClose() end
	if GuideUI then GuideUI:onClose() end
end
InductMgr.clear()

--是否开启动引导
function InductMgr.open( flag )
	isOpen = flag
end

function InductMgr:runInductForId( id, startIndex )
	if id and (not SceneMgr.isSceneName( 'opening' ) ) then
		if isOpen and InductMgr:checkCanRun( id ) then
			if InductMgr:checkCanStart( InductData.StartData[id].checkList ) then
				if InductData.StartData[id].optional then
					PopMgr.checkPriorityPop( 
						"Optional", 
						PopOrType.Optional, 
						function()
							if  InductMgr:checkCanRun( id ) and isGuideRun == false then
					 			if InductMgr:checkCanStart( InductData.StartData[id].checkList ) then
									InductMgr:Run( id,startIndex, true )
								end
							end					
						end
					)				
				else
					PopMgr.checkPriorityPop( 
						"InductUI", 
						PopOrType.InductUI, 
						function()
							if InductMgr:checkCanRun( id ) and isRun == false then
					 			if InductMgr:checkCanStart( InductData.StartData[id].checkList ) then
					 				InductMgr:endInduct( true )
									InductMgr:Run( id,startIndex, false )
								end
							end					
						end
					)
				end
			end
		end
	end
end

local function checkRunNext( indexData, data, name, isGuide )
	if indexData and indexData.nextEvent then
		local theData = nil
		for k,v in pairs(indexData.nextEvent) do
			if v.event == name then
				if v.type == const.kDataTypeFun then
					theData = loadstring( v.data )()
				else
					theData = v.data
				end

				if theData == nil or theData == data then
					InductMgr:runInductNext( isGuide )
				end
			end
		end
	end
end

local function eventNext( data, name )
	if isRun then
		checkRunNext( InductMgr.indexData, data, name, false )
	end

	if isGuideRun then
		checkRunNext( InductMgr.guideIndexData, data, name, true )
	end
end

function InductMgr:Run( id, startIndex, isGuide )
	ActionMgr.save( 'mgr', '[InductMgr] Run id='..id..' index='..startIndex )
	local nextEventData = nil
	if isGuide then
		isGuideRun = true
		runGuideData = InductData.Data[id]
        InductMgr.guideIndex = startIndex - 1
		InductMgr.guideId = id
	else
		isRun = true
		runData = InductData.Data[id]
		InductMgr.inductId = id
        InductMgr.index = startIndex - 1
	end
	
	InductMgr:runInductNext( isGuide )

	if isGuide then
		GuideUI:onShow() 
	else
		InductUI:onShow()
	end

   	TimerMgr.callPerFrame( InductMgr.Loop )

	for i,v in ipairs(InductData.Data[id]) do
        if v.nextEvent then
            for n,m in pairs(v.nextEvent) do
				EventMgr.addListener( m.event, eventNext )
			end
		end
	end	
end

function InductMgr:runInductNext( isGuide )
	InductMgr:setpSendComplete( isGuide )

	local theIndex = 1
	local theRunData = nil
	if isGuide then
		InductMgr.guideIndex = InductMgr.guideIndex + 1
		theIndex = InductMgr.guideIndex
		theRunData = runGuideData
	else
		InductMgr.index = InductMgr.index + 1
		theIndex = InductMgr.index
		theRunData = runData
	end

	if theIndex <= #theRunData then
		InductMgr:runInduct( theRunData[theIndex], isGuide )
	else
		InductMgr:endInduct( isGuide )
	end
end


function InductMgr:runInduct( data, isGuide )
	local theId = 1
	local theIndex  = 1

	if isGuide then
		InductMgr.guideIndexData = data
		theId = InductMgr.guideId
		theIndex = InductMgr.guideIndex
	else
		InductMgr.indexData = data
		theId = InductMgr.inductId
		theIndex = InductMgr.index
	end

	if data.showHandle ~= nil then
		for k,v in pairs( data.showHandle ) do
			loadstring( v )()
		end
	end

	if lastSoundId ~= 0 then
		SoundMgr.stopEffect( lastSoundId )
		lastSoundId = 0
	end
	local infoData = findInduct( theId, theIndex )
    if infoData and infoData.sound == 1 then
		local url = "sound/induct/" .. theId .. '_' .. theIndex .. ".mp3"
    	lastSoundId = SoundMgr.playEffect(url, false)
    end
end

function InductMgr:endInduct( isGuide )
	ActionMgr.save( 'mgr', '[InductMgr] endInduct' )
    InductMgr:endSaveCompleteId( isGuide )
    
	local lastInductId = 0
	if isGuide then
		runGuideData = nil
		InductMgr.guideIndexData = nil
		isGuideRun = false
		GuideUI:onClose()
		lastInductId = InductMgr.guideId
		InductMgr.guideId = 0
		InductMgr.guideIndex = 0 
	else
		runData = nil
		InductMgr.indexData = nil
		isRun = false
		InductUI:onClose()
		InductMgr:replayerCopyOpen()
		lastInductId = InductMgr.inductId
		InductMgr.inductId = 0
		InductMgr.index = 0
	end

	if isRun == false and isGuideRun == false then
		TimerMgr.killPerFrame( InductMgr.Loop )
	end

	FightDataMgr:fightContinue()

	if not isGuide then
		EventMgr.dispatch( EventType.InductEnd, lastInductId )
	end
end

function InductMgr:checkCanRun( id )
    return id ~=nil and not InductMgr:checkRunEnd( id )
end

function InductMgr:checkRunEnd( id )
	return VarData.getVar(InductMgr:getKey(id)) > 0
end 

function InductMgr:endSaveCompleteId( isGuide )
	local theId = 1
	local theIndex = 1
	if isGuide then
		theId = InductMgr.guideId
		theIndex = InductMgr.guideIndex
	else
		theId = InductMgr.inductId
		theIndex = InductMgr.index
	end

	if theId > 0 then
		if InductMgr:checkCanRun( theId ) then
			if not ( InductData.StartData[theId] and InductData.StartData[theId].notRecord ) then
		    	Command.run( 'induct logset', theId, theIndex )
		    	ActionMgr.save( 'mgr', '[InductMgr] save induct_id='.. theId )
		    end
		end
	end
end

function InductMgr:setpSendComplete( isGuide )
	local theData = nil
	if isGuide then
		theData = InductMgr.guideIndexData
	else
		theData = InductMgr.indexData
	end

	if theData and theData.isEnd then
		InductMgr:endSaveCompleteId( isGuide )
	end
end

function InductMgr:initInductGut( id, index )
	if SceneMgr.isSceneName("main") and PageData.getCurrPage() == 1 then
		InductMgr:runInductForId(id, index)
	elseif not SceneMgr.isSceneName("copy") then
		gutData = GutMgr:getTransformGut( 10000 )
		gutEndInduct = id
		gutEndIndex = index
		EventMgr.dispatch( EventType.GutInfo, GutType.GutInductInfo )
		EventMgr.addListener( EventType.GutInductEnd, InductMgr.endInductGut )
	end
end

local function OnInductEnd( id )
	if id == 1 then
        EventMgr.removeListener( EventType.InductEnd, OnInductEnd )
        InductMgr:runInductForId(gutEndInduct, gutEndIndex)
	end
end

function InductMgr.endInductGut( id )
	if id == 10000 then
		EventMgr.addListener( EventType.InductEnd, OnInductEnd )	
		if SceneMgr.isSceneName("main") then
			Command.run("cmd main turn", 0 )
			InductMgr:runInductForId(gutEndInduct, gutEndIndex)
		else
			InductMgr:Run(1, 1, false)
		end
	end
	EventMgr.removeListener( EventType.GutInductEnd, InductMgr.endInductGut )
end

function InductMgr:getInudctGut( )
	return gutData
end

local function eventFightInduct( index )
	ActionMgr.save( 'mgr', '[InductMgr] eventFightInduct index='.. index )
	local gutId = index + 10000
	local data = GutMgr:getTransformGut( gutId )
	if #data.event > 0 then
		FightDataMgr:fightPause()
		InductMgr:runGut( data )
		EventMgr.addListener( EventType.GutInductEnd, InductMgr.endInductGut )
	end
end

--引导触发管理
local function eventDispose( data, name )
	local check = nil
	if isRun == false or isGuideRun == false then
		for k,v in ipairs(InductData.StartData) do
			if InductMgr:checkCanRun( k ) and v and v.eventList then
	            for n, m in pairs(v.eventList) do
	            	if name == m then
	                    if InductMgr:checkCanStart( v.checkList ) then
	                    	local index = 1
	                    	local check = nil
	                    	local isMatching = false
	                    	if v.checkIndexList then
		                    	for i,l in pairs(v.checkIndexList) do
		                    		if l.type == const.kIndexTypeEvent then
                                        if l.data== nil or (  l.dataType == nil and l.data == data )or ( l.dataType == const.kdataValTypeNot and l.data ~= data ) then
		                    				index = l.index
		                    				isMatching = true
		                    				break
		                    			end
		                    		elseif l.type == const.kIndexTypeFun then
										check = loadstring( 'return ' .. l.data)
							            if check and check() then
							                index = l.index
							                isMatching = true
							                break
							            end
		                    		end
		                    	end
		                    end

                            if ( v.mustEvent and isMatching ) or ( v.mustEvent == nil) then
		                    	if v.readyGut then
		                    		InductMgr:initInductGut( k, index)
	                    			return
		                    	end
		                    	
								if name == EventType.FightInduct then
								 	eventFightInduct( data )
								end	          

								InductMgr:runInductForId( k, index )
	            				return
	            			end
	            		end
	            	end
	            end
			end
		end
	end
end

function InductMgr:runGut( data )
	gutData = data
	EventMgr.dispatch( EventType.GutInfo, GutType.GutInductInfo )
end

function InductMgr:checkCanStart( checkList )
	if checkList ~= nil then
		local check = nil
		for k,v in pairs(checkList) do
            check = loadstring( 'return ' .. v)
            if check and not check() then
                return false
            end
		end
	end
	return true
end

function InductMgr:initStart()
	if isOpen then
	    for k,v in ipairs(InductData.StartData) do
	    	if InductMgr:checkCanRun( k ) then
	    		if v and v.eventList then
		            for n, m in pairs(v.eventList) do
		                EventMgr.addListener( m, eventDispose )
		            end
		        end
		    end
	    end
	end
end

function InductMgr:getKey( id )
	return 'induct_'..id
end

function InductMgr:checkInit( win, theModule, indexData )
	theModule = win
	if InductMgr:checkModuleInit( theModule, indexData ) then
		if indexData.module ~= nil then
	        local moduleList = string.split( indexData.module, '.' )
			for k,v in pairs(moduleList) do
				theModule = theModule[v]
				if InductMgr:checkModuleInit( theModule, indexData ) == false then
					return false, theModule
				end
			end
		end
	else
		return false, theModule
	end
	return true, theModule
end

function InductMgr:checkModuleInit( theModule, indexData )
	return indexData.isAction or ( theModule ~= nil and ( theModule.getNumberOfRunningActions == nil or (theModule.getNumberOfRunningActions and theModule:getNumberOfRunningActions() == 0 ) ) )
end

function InductMgr:runJJCFormation()
	Command.run("formation show arena",FormationData.getMonsterFormation(300) )
end

local function onJJCFightEnd( ... )
	EventMgr.removeListener( EventType.FightEnd, onJJCFightEnd)
	Command.run("arena get first reward")
end 
--启动竞技场假战斗
function InductMgr:runJJCFight()
	-- EventMgr.addListener( EventType.FightEnd, onJJCFightEnd)
	ArenaData.outShowFlag=true
	InductMgr.isJJCFight=true
	Command.run("fight common_auto", 300 )
end
--副本引导触发条件检测
function InductMgr:checkCanRunCopy()
	local scene = SceneMgr.getCurrentScene()
	if scene.name == 'copyUI' then
        local dataType = CopyData.area_type
        local copyId = CopyData.getNextCopyId(dataType)	
		local building = scene.mainUI:getBuilding(copyId)
		return CopyData.checkOpenCopy( copyId, true ) and building and building:isTouchEnabled() 
	end
	return false
end
--引导剧情完成 重播一遍副本开启动画
function InductMgr:replayerCopyOpen()
	local scene = SceneMgr.getCurrentScene()
	if scene.name == 'copyUI' then
		local copyId = CopyData.getNextCopyId(CopyData.area_type)
		local building = scene.mainUI:getBuilding(copyId)
		if building then
			scene.mainUI:ReplayNewCopy(building, CopyData.area_type)
		end
	end
end
--引导开启任务
function InductMgr:openTask( )
 	local function callback( ... )
 		Command.run("ui show", "OpenIocnUI", PopUpType.MODEL, true )
 	end
	OpenFuncMgr.showFuncOpen( 9, callback )	 	
end

function InductMgr.Loop()
	if isGuideRun then
		GuideUI:updateData()
	end

	if isRun then
		InductUI:updateData() 
	end
end

function InductMgr:checkNoFightScene()
	return ( not  CopyData.isShowFormation ) and ( not SceneMgr.isSceneName("fight") )
end

function InductMgr:checkRun()
	return isRun
end

function InductMgr:checkRunCopyBuilding()
	local dataType = CopyData.area_type
	local dataId = CopyData.getNextCopyId(dataType)
	if dataId - CopyData.area_id * 1000 < 1000 then
		if ( ( dataType == const.kCopyMopupTypeNormal and dataId <= 4071 ) or ( dataType == const.kCopyMopupTypeElite and dataId <= 2071 ) )then
			return true
		end
	end
	return false
end

local function logSet( id, index )
	VarData.setVar( InductMgr:getKey(id), index )
end

local function run( id, index, isGuide )
	PopMgr.removeWindowByName("ChatUI")
	if index == nil then
		index = 1
	end
	InductMgr:Run( id, index, isGuide )
end

Command.bind( 'induct start', run )
Command.bind( 'induct logset', logSet )