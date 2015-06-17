GuideUI = createUIClassEx("GuideUI", cc.Layer )
local pShowNode = nil
local inductData = nil
local isShow = false

function GuideUI:onShow()
	isShow = true
	GuideUI:updateData()

	PopMgr.setIsPoping('GuideUI', true)
    ActionMgr.save( 'UI', '[GuideUI] onShow' )	
end

function GuideUI:updateData()
	if isShow then
		inductData = InductMgr.guideIndexData
       	if inductData then
            local isInit = false
            local theModule = nil
            
			if inductData.type == const.kTypeWindow then
				win = PopMgr.getWindow(inductData.ui)
	            if PopMgr.getIsShow( inductData.ui ) and ( PopMgr.getIsPoping( inductData.ui ) == nil or PopMgr.getIsPoping( inductData.ui ) == false ) then
					isInit, theModule = InductMgr:checkInit( win, theModule, inductData )
				end
			elseif inductData.type == const.kTypeFun then
				win = loadstring( 'return ' .. inductData.ui)
	            win = win()
	            isInit, theModule = InductMgr:checkInit( win, theModule, inductData )
	        end
       		
       		if isInit then
				local name = 'zsyq-tx-01'
				local path = 'image/armature/ui/InductUI/'
				local offX = 0
				local offY = 0
				if inductData.offPoint then
					offX = inductData.offPoint.x
					offY = inductData.offPoint.y
				end

				if pShowNode == nil then
					pShowNode = ArmatureSprite:addArmatureEx(path, name, self.winName, theModule, offX, offY, nil, 200 )
				    pShowNode:setAnchorPoint( cc.p( 0.5, 0.5 ))
				    pShowNode:retain()
				else
					if pShowNode:getParent() and pShowNode:getParent() ~= theModule  then
						pShowNode:removeFromParent()
					end
					theModule:addChild( pShowNode )
				end

				if pShowArrow == nil then
					name = 'xsz-tx-01'
					pShowArrow = ArmatureSprite:addArmatureEx( path, name, self.winName, theModule, offX + 40, offY -30, nil, 200 )
					pShowArrow:retain()		
			        pShowArrow:setAnchorPoint( cc.p( 0.5, 0.5 ))
			    else
					if pShowArrow:getParent() and pShowArrow:getParent() ~= theModule  then
						pShowArrow:removeFromParent()
					end
					theModule:addChild( pShowArrow )	
				end				
				isShow = false
			end
       	end	
	end
end

function GuideUI:onClose()
	if pShowNode then
		if pShowNode:getParent() then
			pShowNode:removeFromParent()
		end
		pShowNode:release()
		pShowNode = nil
	end

	if pShowArrow then
		if pShowArrow:getParent() then
			pShowArrow:removeFromParent()
		end
		pShowArrow:release()
		pShowArrow = nil
	end	

    PopMgr.setIsPoping('GuideUI', false)	
end