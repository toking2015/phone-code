InductUI = createUIClassEx("InductUI", cc.Layer )

local pClip = nil
-- local pColor = nil
-- local pStencil = nil
local pShow = nil
local pShowInfoBg = nil
local pShowInfo = nil
local pShowNode = nil
local pShowArrow = nil

local midPoint = nil
local endPoint = cc.p(0,0)
local circleRadius = 150
local listener = nil 

local isInit = false
local isClick = false
local touchBeganSuc = false
local touchBeganPoint = nil
local beganCount = 0

local test1 = nil
local test2 = nil

function InductUI:ctor()
	function InductUI.TouchBegan( pTouch, pEvent )
		touchBeganSuc = false
		if isClick then
	        touchBeganPoint = pTouch:getLocation()
	        if midPoint ~= nil then
				if InductMgr.indexData.responseTpye == const.kResponseTpyeSlide then 
					touchBeganSuc = true
				elseif InductMgr.indexData.responseTpye == const.kResponseTpyeDrag then
					if cc.pGetDistance( midPoint , touchBeganPoint ) <= circleRadius then
						touchBeganSuc = true	
					end
				else
				    if cc.pGetDistance( midPoint , touchBeganPoint ) <= circleRadius then
		                touchBeganSuc = true
					end
				end
			end
		end
		local touchValue = touchBeganSuc and 'true' or 'false'
		local clickValue = isClick and 'true' or 'false'
		ActionMgr.save( 'UI', '[InductUI] down [ isClick='.. clickValue ..' id='..	InductMgr.inductId..' index='..InductMgr.index..' touchBeganSuc='..touchValue..']' )
		return true
	end

	function InductUI.TouchEnd( pTouch, pEvent )
		if isClick then
			beganCount = beganCount + 1
			if beganCount >= 2 then
				InductUI:disposeTouche()
			elseif touchBeganSuc and midPoint ~= nil then
	            local touchPoint = pTouch:getLocation()
	            if InductMgr.indexData.responseTpye == const.kResponseTpyeSlide then 
	            	if cc.pGetDistance( touchBeganPoint, touchPoint ) > 10 then
	                	InductUI:disposeTouche()
	                end
	            elseif InductMgr.indexData.responseTpye == const.kResponseTpyeDrag then
	                -- if cc.pGetDistance( endPoint, touchPoint ) < circleRadius then	                	
	                	InductUI:disposeTouche()
	                -- end
				else
	               if cc.pGetDistance( midPoint , touchPoint ) <= circleRadius then
					   InductUI:disposeTouche()
					end
				end
			end
		end
		touchBeganSuc = false
		return true
	end

	function InductUI:disposeTouche()
        ActionMgr.save( 'UI', '[InductUI] disposeTouche [ id='..InductMgr.inductId..' index='..InductMgr.index..' beganCount='..beganCount..']' )
		isClick = false
		beganCount = 0
        if InductMgr.indexData and InductMgr.indexData.handle ~= nil then
        	for k,v in pairs(InductMgr.indexData.handle) do
        	    if v then
        		  loadstring( v )()
        		end
        	end
        end   

        if pShow ~= nil then
   			pShow:setVisible( false ) 
       	end   
        InductMgr:runInductNext( false )  
	end

	--添加底板
	pClip= cc.LayerColor:create(cc.c4b(0,0,0,200))
	pClip:retain()
	pClip:setTouchEnabled( true )
	pClip:setVisible( false )

	isInit = true
end

function InductUI:onShow()
    touchBeganSuc = false
	if isInit == false then
		InductUI:ctor()
		SceneMgr.getLayer(SceneMgr.LAYER_INDUCT):addChild( pClip, 99999 )

	 	listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)	
		listener:registerScriptHandler(InductUI.TouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(InductUI.TouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
	    local layer = SceneMgr.getLayer(SceneMgr.LAYER_INDUCT)
	    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layer)

		PopMgr.setIsPoping('InductUI', true)
        -- InductUI:disposeTouche()

        ActionMgr.save( 'UI', '[InductUI] onShow' )
	end
end

function InductUI:updateData()
	isClick = false
	if InductMgr.indexData ~= nil then
	    midPoint = nil
		local indexData = InductMgr.indexData
		local win = nil 
		local theModule	= nil 		
		local anchorPoint = nil
        local moduleList = nil
        local movePostion = nil
        local isInit = true

		if indexData.type == const.kTypeWindow then
			win = PopMgr.getWindow(indexData.ui)
            if PopMgr.getIsShow( indexData.ui ) and ( PopMgr.getIsPoping( indexData.ui ) == nil or PopMgr.getIsPoping( indexData.ui ) == false ) then
				isInit, theModule = InductMgr:checkInit( win, theModule, indexData )
                if isInit and theModule:getParent() ~= nil and( win.isUIMoving == nil or win.isUIMoving == false ) and( win.isInit == nil or win.isInit == true ) then
            		midPoint = theModule:getParent():convertToWorldSpace( cc.p(theModule:getPositionX(), theModule:getPositionY() ) )
                	midPoint = SceneMgr.getCurrentScene():convertToNodeSpace( midPoint )
                	if theModule.getAnchorPoint then
    				    anchorPoint = theModule:getAnchorPoint()
    				else
    				    anchorPoint = cc.p( 0, 0 )
    				end
    				isClick = true
    			end
			end
		elseif indexData.type == const.kTypeFun then
			win = loadstring( 'return ' .. indexData.ui)
            win = win()
           	isInit, theModule = InductMgr:checkInit( win, theModule, indexData )
            if isInit == true then
            	if theModule:getParent() then
		            midPoint = theModule:getParent():convertToWorldSpace( cc.p(theModule:getPositionX(), theModule:getPositionY() ) )
		            midPoint = SceneMgr.getCurrentScene():convertToNodeSpace( midPoint )

					anchorPoint = theModule:getAnchorPoint()

					isClick = true		
				end					
            end
		else
			theModule = SceneMgr.getCurrentScene()
			anchorPoint = cc.p( 0.5, 0.5 )
			midPoint = cc.p( 0, 0 )
            isClick = true   
		end

	    movePostion = midPoint
		if indexData.offPoint ~= nil and midPoint ~= nil then
			midPoint = cc.pAdd( midPoint, indexData.offPoint )
	        movePostion = midPoint			
			if indexData.responseTpye == const.kResponseTpyeDrag then
				if indexData.offPoint.x1 then
					midPoint = cc.pAdd( midPoint, cc.p( indexData.offPoint.x1, indexData.offPoint.y1 ) )
				end

				if indexData.offPoint.x2 then
			    	endPoint.x=indexData.offPoint.x2
			    	endPoint.y=indexData.offPoint.y2
			    end
		    end

		  --   if test1 == nil then
				-- test1 = ccui.ImageView:create("image/icon/task/1.png", ccui.TextureResType.localType)
				-- test1:setAnchorPoint(cc.p(0,0))
				-- test2 = ccui.ImageView:create("image/icon/task/2.png", ccui.TextureResType.localType)
				-- test2:setAnchorPoint(cc.p(0,0))

		  --   	SceneMgr.getCurrentScene():addChild( test1, 10000 )
		  --   	SceneMgr.getCurrentScene():addChild( test2, 10000 )
		  --   end
		end  

		if theModule ~= nil and midPoint ~= nil then
		    if anchorPoint ~= nil then
	            if anchorPoint.x > 0.5 then
					midPoint.x = midPoint.x - theModule:getContentSize().width * ( anchorPoint.x - 0.5 )
					midPoint.y = midPoint.y - theModule:getContentSize().height * ( anchorPoint.y - 0.5  )
				elseif anchorPoint.x < 0.5 then
					midPoint.x = midPoint.x + theModule:getContentSize().width * ( 0.5 - anchorPoint.x )
					midPoint.y = midPoint.y + theModule:getContentSize().height * ( 0.5 - anchorPoint.y )
				end
			end	  		
	        InductUI:setShowNode( indexData.bg, movePostion.x, movePostion.y )

	        if test1 then
		    	test1:setPosition( midPoint )
			    test2:setPosition( endPoint )	   
			end     
		end
	end	
end

function InductUI:onClose()
	ActionMgr.save( 'UI', '[InductUI] onClose' )

	InductUI:releaseNode( pShowNode )
	pShowNode = nil
	InductUI:releaseNode( pShowArrow )
	pShowArrow = nil
	InductUI:releaseNode( pShowInfo )
	pShowInfo = nil
	InductUI:releaseNode( pShowInfoBg )
	pShowInfoBg = nil
	InductUI:releaseNode( pClip )
	pClip = nil
	InductUI:releaseNode( pShow )
	pShow = nil
	
	isInit = false
	isClick = false
	isFirstClick = false

	SceneMgr.getLayer(SceneMgr.LAYER_INDUCT):getEventDispatcher():removeEventListener(listener )

    PopMgr.setIsPoping('InductUI', false)

    EventMgr.dispatch(EventType.CloseWindow, {winName = "InductUI"})
end

function InductUI:releaseNode( node )
    if node ~= nil then
    	if node:getParent() then
    		node:removeFromParent()
    	end
    	node:stopAllActions()
    	node:release()
    	node = nil	
    end
end

function InductUI:setShowNode( name, x, y )
	if pShow == nil then
		pShow = cc.Node:create()
		pShow:retain()
		SceneMgr.getLayer(SceneMgr.LAYER_INDUCT):addChild( pShow, 10000 )
	end

    if pShowNode ~= nil and pShowNode.name ~= name then
    	if pShowNode:getParent() then
			pShowNode:removeFromParent()
		end
		pShowNode:release()
		pShowNode = nil
	end

	if pShowNode == nil then
		local path = 'image/armature/ui/InductUI/'..name..'/'..name..'.ExportJson'
		LoadMgr.loadArmatureFileInfo(path, LoadMgr.WINDOW, name )
		pShowNode = ArmatureSprite:addArmatureTo( pShow, path , name, 0, 0 )
		pShowNode.name = name
		pShowNode:retain()		
        pShowNode:setAnchorPoint( cc.p( 0.5, 0.5 ))
	end
	if pShowInfoBg == nil then
		pShowInfoBg = cc.Sprite:create('image/ui/InductUI/bg_info.png')
		pShowInfoBg:retain()
		pShow:addChild( pShowInfoBg )

		pShowInfo = cc.Node:create()
        pShowInfo:setAnchorPoint( 0, 0 )
        pShowInfo:retain()
        pShowInfoBg:addChild( pShowInfo, 2 )	
	end

	pShowInfo:removeAllChildren()
	local infoData = findInduct( InductMgr.inductId, InductMgr.index )
    if infoData and infoData.info ~= nil and infoData.info ~= '' then
		RichTextUtil:DisposeRichText( infoData.info, pShowInfo, nil, nil, 350 )
		pShowInfo:setPosition( cc.p( 185, 25 + ( 140 - pShowInfo:getContentSize().height ) / 2 + pShowInfo:getContentSize().height ) )
		local infoPosition = cc.p( 0, 20 )
		if infoData.face == 1 then
			infoPosition.y = 175 
		elseif infoData.face == 2 then
			infoPosition.y = -135
			infoPosition.x = -55
		else
			if x < ( cc.Director:getInstance():getWinSize().width )/ 2 - 50 then 
				infoPosition.x = 350
			else
				infoPosition.x = -350
			end
		end

		pShowInfoBg:setPosition( infoPosition )
		pShowInfoBg:setVisible( true )
	else
		pShowInfoBg:setVisible( false )
	end

	if pShowArrow == nil then
		name = 'xsz-tx-01'
		local path = 'image/armature/ui/InductUI/'..name..'/'..name..'.ExportJson'
		LoadMgr.loadArmatureFileInfo(path, LoadMgr.WINDOW, name )
		pShowArrow = ArmatureSprite:addArmatureTo( pShow, path ,name, 40, -30 )
		pShowArrow.name = name
		pShowArrow:retain()		
        pShowArrow:setAnchorPoint( cc.p( 0.5, 0.5 ))
	end
	
	if InductMgr.indexData.bg == 'zsyq-tx-01' then
		pShowArrow:setVisible( true )
	else
		pShowArrow:setVisible( false )
	end

	pShow:setPosition( cc.p( x, y ) )
	pShow:setVisible( true )
end