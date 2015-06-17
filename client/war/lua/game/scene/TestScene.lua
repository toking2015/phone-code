local testScene = Scene:create()

function testScene:onShow()
	local id = 8002
	
-- 	local path = "image/ui/CopyProgressUI/cpu_progress.png"
-- 	local sp = Sprite:create(path)
-- 	sp:setAnchorPoint(0, 0)
-- --	sp:setPosition(visibleSize.width / 2, visibleSize.height / 2)
-- --	self:addChild(sp)

-- 	local size = sp:getContentSize()

-- 	local layer = LayerColor:create(cc.c4b(255, 0, 0, 255), size.width, size.height)
-- 	layer:setAnchorPoint(0, 0)
-- --	layer:setPosition(100, 100)
-- --	self:addChild(layer)

-- 	local clippingNode = cc.ClippingNode:create(layer)
-- --	clippingNode:Anc
-- --	clippingNode:setStencil(layer)
-- 	clippingNode:addChild(sp)
-- 	clippingNode:setInverted(false)
-- 	clippingNode:setPosition(100, 100)
	
--     self:addChild(clippingNode)
    
-- --	layer:setScaleX(0)

-- --	sp:setOpacity(50)
    
--     local action1 = cc.FadeIn:create(1)
--     sp:setOpacity(0)
-- --	local scale = cc.ScaleTo:create(1, 1, 1)
--     sp:runAction(action1)
	
--     local action2 = cc.FadeIn:create(1)
--     local p = UIFactory.getLeftProgressBarWith(path, self, 300, 200, 1)
--     p:setPercentage(80)
--     p:setOpacity(0)
--     p:runAction(action2)

	-- local sc = ccui.ScrollView:create()
	-- sc:setSize(cc.size(500, 400))
	-- sc:setPosition(300, 100)
	-- self:addChild(sc)

	-- local list_1 = {}
	-- for i = 1, 10 do
	-- 	local layer = LayerColor:create(cc.c4b(255, 0, 0, 255), 200, 50)
	-- 	table.insert(list_1, layer)
	-- end
	-- local list_2 = {}
	-- for i = 1, 1 do
	-- 	local layer = LayerColor:create(cc.c4b(255, 255, 0, 255), 400, 30)
	-- 	table.insert(list_2, layer)
	-- end
	-- local list_3 = {}
	-- for i = 1, 10 do
	-- 	local layer = LayerColor:create(cc.c4b(125, 125, 125, 255), 200, 50)
	-- 	table.insert(list_3, layer)
	-- end

	-- -- initScrollViewWithList(scrollview, list, rowNumList, off_x, off_y, space_x, space_y)
	-- -- local list = {list_1, list_2, list_3}
	-- -- local rowNumList = {2, 1, 2}
	-- local list = {list_1, list_2, list_3}
	-- local rowNumList = {2, 1, 2}
	-- initScrollViewWithList(sc, list, rowNumList, 20, 20, 10, 10)
	

	UIMgr.addTouchBegin(testScene, function()
		  Command.run( "scene leave")
	end)
end

SceneMgr.insertScene('test', testScene)