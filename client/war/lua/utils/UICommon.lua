UICommon = UICommon or {}

--递归获取UI子元件对象
function initLayout( root )
	local childrens = root:getChildren()
	for k,v in pairs(childrens) do
		local name = v:getName()
		if name ~= "" and name ~= nil then
			root[ name ] = v
			initLayout( v )
		end
	end
end

--- 生成组件对象，fileName 为文件路径
--@param fileName 文件路径
function getLayout(fileName)
	local skin = ccs.GUIReader:getInstance():widgetFromJsonFile(fileName)
	initLayout( skin )
	return skin
end

function cloneLayout(layout)
	local skin = layout:clone()
	initLayout(skin)
	return skin
end

local jsonPlistTextureMap = {} --json=>{textures, texturesPng} --缓存对应的数据，不重复读取文件
--分析ExportJson文件，把里面的plist加入到资源释放列表里面去
function analyseExportJson(uiName, fileName, isBelongScene)
	local data = jsonPlistTextureMap[fileName]
	if not data then
		local jsonTable = loadJsonFromFile(fileName)
		data = {}
		data.textures = jsonTable.textures
		data.texturesPng = jsonTable.texturesPng
		jsonPlistTextureMap[fileName] = data
	end
	if data.textures then
		local prePath = string.findLastFolder(fileName)
		for i,v in ipairs(data.textures) do
			if isBelongScene then
				LoadMgr.addPlistPool(prePath..v, prePath..data.texturesPng[i], LoadMgr.SCENE, uiName)
			else
				PopMgr.addWinPlist(uiName, prePath..v, prePath..data.texturesPng[i])
			end
		end
	end
end

-- 窗口说明
-- 对于窗口：
-- self.winName 窗口的名字
-- ctor(), 构造窗口的时候会调用
-- onShow(), 打开窗口的时候会调用
-- onClose()， 关闭窗口的时候会调用
-- dispose(), 销毁窗口的时候会调用
-- onBeforeClose() 在关闭窗口前会调用，如果返回值为true,则取消关闭窗口
-- isShow() 判断是否处于打开的状态

--生成窗口对象
--添加窗口必须的方法
local function createWindow(panel, popType, uiName)
	panel.popType = popType or PopWayMgr.NONE
	-- function panel:onBeforClose()
    --可以实现此方法return true阻止UI关闭
    -- end
    --获取是否处于打开状态
	function panel:isShow()
		return self._isShow == true
	end
	function panel:show()
		self._isShow = true
        if self.delayInit ~= nil then --在PopWaymgr处理
			performNextFrame(self, self.delayInit, self)
			--把delayInit置空，以防止重复调用
			self.delayInit = nil
		end
		PopWayMgr.showUiPanel(self, EventType.WindowDownShow)
		return true
	end
	function panel:close(noAnimation)
		self._isShow = false
		-- if self.onClose ~= nil then
		-- 	self:onClose()
		-- end
		PopWayMgr.hideUiPanel(self, noAnimation)
		return true
	end
	-- function panel:dispose()
    --可以实现此方法进行特殊释放操作
	-- end
	return panel
end

-- 生成窗口对象，fileName 为文件路径，popType 为弹出动画显示方式:
-- 木有动画  PopWayMgr.NONE = 0
-- 从上往下弹出  PopWayMgr.UPTOBOTTOM = 1
-- 在中间从小变大弹出  PopWayMgr.SMALLTOBIG = 2
--@param uiName 所属的窗口(模块)
local function getPanel(fileName, popType, uiName)
	local panel = getLayout(fileName)
	analyseExportJson(uiName, fileName)
	return createWindow(panel, popType, uiName)
end

local function getNode(panel, popType, uiName, subFilename)
	if subFilename then
		analyseExportJson(uiName, subFilename)
	end
	return createWindow(panel, popType, uiName)
end

local uiClsMap = {}
local function setUIClass(cls, uiName)
    if PopMgr.NEED_CACHE_DIC[uiName] then
    	cls.isNeedCache = true
    end
    local jUI = findUI(uiName)
    if jUI then
    	cls.__uiGroup = jUI.group
    end
	uiClsMap[uiName] = true
	cls.winName = uiName
	PopMgr.addWinCreate(uiName, cls)
	return cls
end

--打印所有的窗口名字
local function outputuinames(includeXls)
	local xls = {}
	if not includeXls then
		xls = GetDataList("UI")
	end
	local result = {}
	for name,_ in pairs(uiClsMap) do
		if not xls[name] then
			table.insert(result, name)
		end
	end
	table.sort(result)
	local str = table.concat(result, "\n")
	local stream = seq.string_to_stream(str)
    --输出文件
    seq.write_stream_file("uinames.txt", stream)
end
Command.bind("outputuinames", outputuinames)

---通过ExportJson创建Layout类
--@param uiName 类名
--@param fileName ExportJson的路径
--@param belongWinName 可选，属于的窗口名字，用于在关闭该窗口的时候，释放资源
--@param isBelongScene 可选，是否第三个参数为场景的名字
function createUILayout(uiName, fileName, belongWinName, isBelongScene)
	local cls = class(uiName, function()
		if belongWinName then
			analyseExportJson(belongWinName, fileName, isBelongScene)
		end
		return getLayout(fileName)
	end)
	return cls
end

---通过cc.Node的子类创建子UI类
--不能作为窗口，不实现close, show等方法
--@param clsName 类名
--@param nodeCls cc.Node或其子类
--@return 类
function createLayoutClass(clsName, nodeCls)
	local cls = class(clsName, function()
		return nodeCls:create()
	end)
	return cls
end

---通过ExportJson创建UI窗口类
--@param uiName 窗口名字
--@param fileName ExportJson的路径
--@param popType 可选，默认为PopWayMgr.NONE，PopWayMgr的枚举
--@param needBg 可选，是否需要添加通用铁链窗口背景
--@return 类
function createUIClass(uiName, fileName, popType, needBg)
	local cls = class(uiName, function()
		local panel = getPanel(fileName, popType, uiName)
		if needBg then
			UIFactory.getWindowBg(panel)
		end
		return panel
	end)
	return setUIClass(cls, uiName)
end

---通过cc.Node的子类创建UI窗口类
--@param uiName 窗口名字
--@param nodeCls cc.Node或其子类
--@param popType 可选，默认为PopWayMgr.NONE，PopWayMgr的枚举
--@param subFilename 可选，该窗口包含的ExportJson路径之一，用于释放plist与texture
--@return 类
function createUIClassEx(uiName, nodeCls, popType, subFilename)
	local cls = class(uiName, function()
		return getNode(nodeCls:create(), popType, uiName, subFilename)
	end)
	return setUIClass(cls, uiName)
end

local function createTriangle(px, py, scaleY)
	local triangle = Sprite:createWithSpriteFrameName("triangle.png")
	triangle:setScaleY(scaleY)
	triangle:setAnchorPoint(px, py)
	triangle:setPosition(px, py)
	return triangle
end

function  createGroupTriangle(ui, off_x)
	local ui_size = ui:getSize()
	local w, h = 47, 28
	local num = math.floor((ui_size.width - off_x) / w)
	LogMgr.log( 'debug',"create triangle num = " .. num)
	local distance = (ui_size.width - num * w) / (w - 1)
	for i = 1, num, 1 do
		local triangle = createTriangle(off_x + (i - 1) * (w + distance), 0, 1)
		ui:addChild(triangle)

		triangle = createTriangle(off_x + (i - 1) * (w + distance), ui_size.height, -1)
		ui:addChild(triangle)
	end
end

-- 创建OneShow 只能显示list中一个显示对象
function createOneShow(list)
	local oneShow = {}
	local showList = list
	local data = nil
	local length = table.getn(showList)

	function oneShow:showByIndex(index)
		for i = 1, length, 1 do
			local item = showList[i]
			item:setVisible(false)
		end
		LogMgr.log( 'debug',"showByIndex : "..index)
		showList[index]:setVisible(true)
	end

	function oneShow:showByValue(value)
		if nil ~= data then
			for i = 1, length, 1 do
				local item = showList[i]
				item:setVisible(value == data[i])
			end
		end
	end

	local function init()
		LogMgr.log( 'debug',"length = "..length)
		for i = 1, length, 1 do
			local item = showList[i]
			item.index = i
			item:setVisible(false)
		end
		showList[1]:setVisible(true)
	end

	init()

	return oneShow
end

function setBtnGray(btn, shaderName, uniform)
    -- if shaderName == "light" then
    --  shaderName = "gray"
    -- end
    local programState = ProgramMgr.createProgramState(shaderName)
    if uniform then
        programState:setUniformFloat("u_multiple", uniform)
    end
    local isCCUI = (string.find(tolua.type(btn), "ccui.") == 1)
    if isCCUI == true then
        local render = btn:getVirtualRenderer()
        -- LogMgr.log( 'debug'," type = " .. tolua.type(render))
        if tolua.type(render) ~= "cc.Label" then
            if render ~= nil then
                render:setGLProgramState( programState )
            end
            local list = btn:getChildren()
            for _, v in pairs(list) do
                setBtnGray(v, shaderName, uniform)
            end
        end
    end
end
-- 创建类似标签按钮 list有规格要求
function createTab(list,typedata,isscale)
	if isscale == nil then 
	   isscale = false 
	end 
	local tab = {}
	local dataProvider = nil
	local target = nil
	local handler = nil
	local selectedIndex = 0
	local btnList = list
	local hideIndexList = {}
	local locationP = {}
	-- point.unselectPoint point.selectPoint
	function tab:getCurrentPoint( index )
		local currentPointIndex = index
		for i = 1,index do 
			if currentPointIndex > 1 and table.indexOf(hideIndexList,i) ~= -1 then
				currentPointIndex = (currentPointIndex - 1)
			end
		end
		return locationP[currentPointIndex]
	end
	function tab:updateBtnPosition( ... )
		local length = table.getn(btnList)
		for i = 1, length, 1 do
			local btns = btnList[i]
			local pointData = self:getCurrentPoint(i)
			if pointData then
				btns.btn_selected:setPosition(pointData.selectPoint.x,pointData.selectPoint.y)
				btns.btn_unselected:setPosition(pointData.unselectPoint.x,pointData.unselectPoint.y)
			end
		end
	end
	-- 设置不显示列表
    function tab:setIndexVible( index ,b)
		if b == nil then
			b = true
		end
		local btn_selected = btnList[index].btn_selected
		local btn_unselected = btnList[index].btn_unselected
		if b == true then
			if table.indexOf( hideIndexList, index ) == -1 then
				return
			else
				table.remove(hideIndexList,table.indexOf( hideIndexList, index ))
    			btn_unselected:setVisible(true)
			end
		else
			if table.indexOf( hideIndexList, index ) ~= -1 then
				return
			else
				table.insert(hideIndexList,index)
				if selectedIndex == index then
					if index == 1 then
						self:clickIndex(index + 1)
					else
						self:clickIndex(1)
					end
				else
					btn_unselected:setVisible(false)
					btn_selected:setVisible(false)
				end
			end
		end
		self:updateBtnPosition()
    end

    -- 添加 dataProvider 的 get/set 方法
	function tab:setDataProvider(data)
		dataProvider = data;
	end
	function tab:getDataProvider()
		return dataProvider
	end
    -- 添加点击事件回调
	function tab:addEventListener(_target, _handler)
		target = _target
		handler = _handler
	end
    -- 添加 selectedIndex 的 get/set 方法
	function tab:getSelectedIndex()
		return selectedIndex
	end
	function tab:setSelectedIndex(value)
		if selectedIndex ~= value then
			if 0 ~= selectedIndex then
        --        LogMgr.debug("selectIndex .. " .. selectedIndex)
				btnList[selectedIndex].btn_selected:setVisible(false)
				if table.indexOf( hideIndexList, selectedIndex ) == -1 then
					btnList[selectedIndex].btn_unselected:setVisible(true)
				end
			end
--            for key , v in pairs(btnList)do
--                if v.btn_unselected:isVisible() == true then 
--                   v.btn_selected:setVisible(false)
--                   v.btn_unselected:setVisible(true)
--                end 
--            end  

			selectedIndex = value
			local btn_selected = btnList[value].btn_selected
			local btn_unselected = btnList[value].btn_unselected
			if table.indexOf( hideIndexList, selectedIndex ) == -1 then
				btn_selected:setVisible(true)
			end
			btn_unselected:setVisible(false)
		end
	end
	function tab:clickIndex( index )
		local btns = btnList[index]
		tab:setSelectedIndex(index)
		if target ~= nil and handler ~= nil then
		    local data1 = typedata[index]
			handler({selectedIndex = index , data = data1})
		end
		if isscale == true then 
			 p = btns.btn_unselected.p
            btns.btn_unselected:setScale(1)
            if nil ~= p then
                btns.btn_unselected:setPosition(p.x, p.y)
            end
            setBtnGray(btns.btn_unselected, "normal")
        end 
	end
    -- 获取 selectedItem
	function tab:getSelectedItem()
		if nil ~= dataProvider then
			return dataProvider[selectedIndex]
		end
		return nil
	end

    
    local p = nil --cc.p(btn:getPositionX(), btn:getPositionY())
    local per = 1.2
    local dp = (per - 1) / 2
	local function init()
		local length = table.getn(btnList)
		for i = 1, length, 1 do
			local btns = btnList[i]
			btns.btn_selected:setVisible(false)
			btns.btn_unselected:setVisible(true)
			btns.btn_unselected.index = i
			btns.btn_unselected:setTouchEnabled(true)
            local s = btns.btn_unselected:getSize()
            local ap = btns.btn_unselected:getAnchorPoint()
            if locationP[i] == nil then
            	local ipoint = {}
            	ipoint.unselectPoint = cc.p(btns.btn_unselected:getPositionX(), btns.btn_unselected:getPositionY())
            	ipoint.selectPoint = cc.p(btns.btn_selected:getPositionX(), btns.btn_selected:getPositionY())
            	locationP[i] = ipoint
            end
            if nil == btns.btn_unselected.p then
                btns.btn_unselected.p = cc.p(btns.btn_unselected:getPositionX(), btns.btn_unselected:getPositionY())
            end
			local function clickHandler(ref, eventType)
			    --p = ref:getCurrentPoint(i).unselectPoint
			    p = btns.btn_unselected.p
			    if eventType == ccui.TouchEventType.began then
                    if isscale == true then 
                       setBtnGray(btns.btn_unselected, "light", 1.25)
                       btns.btn_unselected:setScale(per)
                       local sp = cc.p(p.x - s.width * dp, p.y - s.height * dp)
                       btns.btn_unselected:setPosition(sp.x, sp.y)
                    end 
			    end 
				if eventType == ccui.TouchEventType.ended then
					local index = ref.index
					tab:clickIndex(index)
                    SoundMgr.playEffect(soundUrl or "sound/ui/click.mp3")
				end
                if eventType == ccui.TouchEventType.canceled then 
                    if isscale == true then
                        if nil ~= p then
                            btns.btn_unselected:setPosition(p.x, p.y)
                        end
                        btns.btn_unselected:setScale(1) 
                        setBtnGray(btns.btn_unselected, "normal") 
                    end  
                end 
			end
			btns.btn_unselected:addTouchEventListener(clickHandler)
		end
		tab:setSelectedIndex(1)
	end

	init()

	return tab
end
-- 1 .view列表 ,2.位置列表{{x1=*,y1=*,x2=*,y2=*},...},3.筛选列表,4.需要添加得函数5.tab 列表
function createTabselect (viewlist ,positionlist,list, fun,tab)
    for _ ,value in pairs(viewlist) do 
        value.btn_unselected:setVisible(false)
        value.btn_selected:setVisible(false)
    end 

    if fun ~= nil then 
       fun()
    end 
    local key = 1
    for k,v in pairs(list) do
        viewlist[v].btn_unselected:setVisible(true)
        viewlist[v].btn_selected:setVisible(true)
        viewlist[v].btn_unselected:setPosition(cc.p(positionlist[key].x1,positionlist[key].y1))
        viewlist[v].btn_selected:setPosition(cc.p(positionlist[key].x2,positionlist[key].y2))
        if key == 1 then 
            viewlist[v].btn_selected:setVisible(true)
            if tab ~= nil then
               tab:setSelectedIndex(v)
            end 
        else 
            viewlist[v].btn_selected:setVisible(false)
        end  
        key = key + 1
    end 
--    for _ , value in pairs(viewlist) do 
--        if value.btn_selected:isVisible() == true then 
--            value.btn_unselected:setPosition(cc.p(positionlist[key].x1,positionlist[key].y1))
--            value.btn_selected:setPosition(cc.p(positionlist[key].x2,positionlist[key].y2))
--            if key == 1 then 
--                value.btn_selected:setVisible(true)
--            else 
--                value.btn_selected:setVisible(false)
--            end  
--            key = key + 1
--        end 
--    end 
end 

-- 容器按钮，必须以 (0 , 0) 为注册点 ，注意容器Size
function createScaleButtonByName(parent, childName)
	local btn = parent:getChildByName(childName)
	return createScaleButton(btn)
end
function createScaleButton(btn, type, expBtn, soundUrl,isLight,scale)
    local isCCUI = (string.find(tolua.type(btn), "ccui.") == 1)
    
    if type == nil then 
       type = true
    end 
    btn.type = type
    if isLight == nil then
       isLight = true 
    end 
    if scale == nil then
    	scale = 1.2
    end
    
    local s = nil
    if isCCUI then
        btn:setTouchEnabled(true)
        s = btn:getSize()
    else
        s = btn:getContentSize()
	end

	local ap = btn:getAnchorPoint()

	if btn.type == true then
	    if ap.x ~= 0 or ap.y ~= 0 then -- 针对锚点不在0,0的处理
			btn:setAnchorPoint(0, 0)
			btn:setPosition(btn:getPositionX() - s.width * ap.x, btn:getPositionY() - s.height * ap.y)
		end
	end
	
	local onTouchBegan = nil
	local onTouchMoved = nil
	local onTouchEnded = nil
	local onTouchCancel = nil
	
	local p = nil --cc.p(btn:getPositionX(), btn:getPositionY())
	local per = scale
	local dp = (per - 1) / 2

    --事件代理
	function btn:addTouchBegan(func)
		onTouchBegan = func
	end
	function btn:addTouchMoved(func)
		onTouchMoved = func
	end
	function btn:addTouchEnded(func)
		onTouchEnded = func
	end
	function btn:addTouchCancel(func)
		onTouchCancel = func
	end
	function btn:switchTypeStatus(bln)
		btn.type = bln
	end

    --事件监听
    local function __touchBegin( ref, eventType, coord )
        p = cc.p(btn:getPositionX(), btn:getPositionY())
        if btn.type == true then
            btn:setScale(per)
            local sp = cc.p(p.x - s.width * dp, p.y - s.height * dp)
            btn:setPosition(sp.x, sp.y)
        end 
        if isLight == true then 
            setBtnGray(btn, "light", 1.25)
        end 
        if nil ~= onTouchBegan then
            onTouchBegan(ref, eventType)
        end
    end
    
    local function __touchEnded( ref, eventType, coord )
        SoundMgr.playEffect(soundUrl or "sound/ui/click.mp3")
        if btn.type == true then
            btn:setScale(1)
            if nil ~= p then
                btn:setPosition(p.x, p.y)
            end
        end
        if isLight == true then 
            setBtnGray(btn, "normal")
        end 

        if nil ~= onTouchEnded then
            onTouchEnded(ref, eventType)
        end
    end
    
    local function __touchMoved( ref, eventType, coord )
        if nil ~= onTouchMoved then
            onTouchMoved(ref, eventType)
        end
    end
    
    local function __touchCancel( ref, eventType, coord )
        if btn.type == true then
            btn:setScale(1)
            if nil ~= p then
                btn:setPosition(p.x, p.y)
            end
        end
        if isLight == true then
            setBtnGray(btn, "normal")
        end 

        if nil ~= onTouchCancel then
            onTouchCancel(ref, eventType)
        end
    end
    
    UIMgr.addTouchBegin( btn, __touchBegin )
    UIMgr.addTouchEnded( btn, __touchEnded )
    UIMgr.addTouchMoved( btn, __touchMoved )
    UIMgr.addTouchCancel( btn, __touchCancel )

	return btn
end

-- 绑定垂直方向中的 ScrollView 与 Slider , isSameDirection 为 是否同个方向滚动
function bindScrollViewAndSlider(scrollView, slider, isSameDirection)
    LogMgr.log( 'debug',"bind......")
	LogMgr.log( 'debug',"bind......")
	local svSize = scrollView:getSize()
	-- scrollView:setBounceEnabled(false)
	local inner = scrollView:getInnerContainer()
	local prev_y = 0

	if isSameDirection == true then
		slider:setPercent(0)
	else
		slider:setPercent(100)
	end
	local isShowMore = false
	local function scrollViewHandler(ref, eventType)
		if eventType == ccui.ScrollviewEventType.scrolling then
			LogMgr.log( 'debug',"scrollview ing ")
			if prev_y ~= inner:getPositionY() then
				prev_y = inner:getPositionY()
				local size = inner:getSize()
                --将此屏蔽，即可做暴击界面用
                if nil ~= scrollView.isToBottom then 
                   if nil ~= scrollView.toHeight then 
				      scrollView.isToBottom = (-prev_y < scrollView.toHeight)
				   end 
			    end 

				isShowMore = (svSize.height - size.height - prev_y > 88)
                --将一下判断屏蔽，可做暴击界面用
                if nil ~= scrollView.setPushDown then 
					if isShowMore == true then
						scrollView:setPushDown(1)
					else
						scrollView:setPushDown(2)
					end
                end 
                -- 这模式得想想
				local percent = -prev_y * 100 / (size.height - svSize.height)
				if isSameDirection ~= true then
					percent = 100 - percent
				end
				-- LogMgr.log( 'debug',"percent = "..percent)
				slider:setPercent(percent)
			end
		elseif eventType == ccui.ScrollviewEventType.bounceTop then
			if true == isShowMore then 
				scrollView.toShowMore = true
			end
		end
	end
	scrollView:addEventListenerScrollView(scrollViewHandler)
    
   
	local function sliderHandler(ref, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local percent = slider:getPercent()
			local size = inner:getSize()
			if isSameDirection == true then
				percent = 100 - percent
			end
			prev_y = percent * (size.height - svSize.height)
			scrollView.isToBottom = (-prev_y < 88)
			scrollView:jumpToPercentVertical(percent)
		end
	end
	slider:addEventListenerSlider(sliderHandler)
end

function initScrollviewWith(scrollview, list, rowNum, off_x, off_y, space_x, space_y)
	local sc = scrollview
	local inner = sc:getInnerContainer()
	inner:removeAllChildren()
	inner:setSize(sc:getSize())
	local size = inner:getSize()
    
	local total = table.getn(list)
	local row = math.ceil(total / rowNum)
	LogMgr.log( 'debug',"row = "..row)

	local isOne = false
	local w = 0
	local h = 0

	if nil ~= list[1] then 
		local nsize = list[1].getSize and list[1]:getSize()  or list[1]:getContentSize()
		w = nsize.width
		h = nsize.height
	end
	local pw = size.width
	local pw = off_x * 2 + rowNum * (w + space_x) -space_x
    local ph = off_y * 2 + row * (h + space_y) - space_y
    -- 每一行变长的情况（目前适应一行情况）
    if rowNum == 1 then 
        ph = off_y * 2  - space_y
        for key , value in pairs(list) do
            local nsize = value.getSize and value:getSize()  or value:getContentSize()
            h = nsize.height 
            ph = ph + h + space_y
        end 
    end 
	
	if pw < size.width then
		pw = size.width
	end
	if ph < size.height then 
		ph = size.height
	end
	sc:setInnerContainerSize(cc.size(pw, ph))
    sc.ph = ph - sc:getSize().height -- 在外边要用
	for i = 1, total, 1 do
		local item = list[i]
        local nsize = list[i].getSize and list[i]:getSize()  or list[i]:getContentSize()
        w = nsize.width
        h = nsize.height
		local px = off_x + ((i - 1) % rowNum) * (w + space_x)
        local py = ph - off_y - (math.floor((i - 1) / rowNum) + 1)  * (h) - (math.floor((i-1)/rowNum))*space_y
          
        -- 每一行变长的情况（目前适应一行情况）
        if rowNum == 1 then --只有一行 如聊天的情况
            py = ph - off_y
            for j = total - i  ,total - 1 ,1 do 
                if j ~= 0 then 
                    local nsize = list[total -j].getSize and list[total -j]:getSize()  or list[total -j]:getContentSize()
                    h = nsize.height
                    py = py - h - space_y
                else 
                    local nsize = list[total].getSize and list[total]:getSize()  or list[total]:getContentSize()
                    h = nsize.height 
                    py = py - h - space_y

                end   
            end 
        end 
        
		LogMgr.log( 'debug',"i = "..i.." px = "..px.." py = "..py)
		item:setPosition(cc.p(px, py))
		sc:addChild(item)
	end
	
	 --添加滚动时候的回调
    local scrollfun = nil 
    sc.scrollFun = function(func)
       scrollfun = func 
    end
    --添加滚动到底部的回调
    local scrollbottom = nil  
    sc.scrollbottom = function(func)
       scrollbottom = func 
    end 
    
    local scrolltop = nil 
    sc.scrolltop = function(func)
       scrolltop = func
    end 
    local function scrollViewHandler(ref, eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            if sc.prev_y ~= inner:getPositionY() then
                sc.prev_y = inner:getPositionY()
                sc.percent = -sc.prev_y/(ph - sc:getSize().height) * 100
                if scrollfun ~= nil then
                   scrollfun()
                end
            end 
        elseif eventType == ccui.ScrollviewEventType.bounceBottom then
            sc.prev_y = inner:getPositionY()
            sc.percent = -sc.prev_y/(ph - sc:getSize().height) * 100
            if scrollbottom ~= nil then 
               scrollbottom()
            end 
        elseif eventType == ccui.ScrollviewEventType.bounceTop then 
            sc.prev_y = inner:getPositionY()
            sc.percent = -sc.prev_y/(ph - sc:getSize().height) * 100
            if scrolltop ~= nil then 
                scrolltop()
            end 
        end 
    end 
    sc:addEventListenerScrollView(scrollViewHandler)
    return sc
end

local function getVerListSize(list, rowNum, space_x, space_y)
	local total = table.getn(list)
	local row = math.ceil(total / rowNum)

	local w = 0
	local h = 0

	if nil ~= list[1] then 
		local nsize = list[1].getSize and list[1]:getSize()  or list[1]:getContentSize()
		w = nsize.width
		h = nsize.height
	end

	local pw = w * (rowNum + space_x) - space_x
    local ph = row * (h + space_y) - space_y
    
    return cc.size(pw, ph)
end

function initScrollViewWithList(scrollview, list, rowNumList, off_x, off_y, space_x, space_y)
	local sc = scrollview
	local inner = sc:getInnerContainer()
	inner:removeAllChildren()
	inner:setSize(sc:getSize())
	local size = inner:getSize()
    
	local hList = {}

    local pw, ph = off_y * 2, off_x * 2
    local len = #list
	for i = 1, len do
		if i > 1 then
			ph = ph + space_y
		end
		local lSize = getVerListSize(list[i], rowNumList[i], space_x, space_y)
		pw = pw + lSize.width
		ph = ph + lSize.height
		table.insert(hList, lSize.height)
	end

	if ph < size.height then
		ph = size.height
	end
	sc:setInnerContainerSize(cc.size(pw, ph))
	local tmpH = ph
	for i = 1, len, 1 do
		local viewList = list[i]
		local l = #viewList
		local rowNum = rowNumList[i]
		for j = 1, l do
			local item = viewList[j]
	        local nsize = viewList[j].getSize and viewList[j]:getSize()  or viewList[j]:getContentSize()
	        w = nsize.width
	        h = nsize.height
			local px = off_x + ((j - 1) % rowNum) * (w + space_x)
	        local py = tmpH - off_y - (math.floor((j - 1) / rowNum) + 1)  * (h) - (math.floor((j - 1) / rowNum)) * space_y
			item:setPosition(cc.p(px, py))
			sc:addChild(item)
		end
		tmpH = tmpH - hList[i] - space_y
	end

	return sc
end

function initVector(vector, list, rowNum, off_x, off_y, space_x, space_y)
    local inner = vector
    inner:removeAllChildren()
    local size = inner:getSize()

    local total = table.getn(list)
    local row = math.ceil(total / rowNum)
    LogMgr.log( 'debug',"row = "..row)

    local isOne = false
    local w = 0
    local h = 0

    if nil ~= list[1] then 
        w = list[1]:getSize().width
        h = list[1]:getSize().height
    end
    local pw = size.width
    local ph = off_y * 2 + row * (h + space_y) - space_y
    if ph < size.height then 
        ph = size.height
    end
    vector:setSize(cc.size(pw, ph))
--    vector:setInnerContainerSize(cc.size(pw, ph))

    for i = 1, total, 1 do
        local item = list[i]

        local px = off_x + ((i - 1) % rowNum) * (w + space_x)
        local py = ph - off_y - (math.floor((i - 1) / rowNum) + 1)  * (h) - (math.floor((i-1)/rowNum))*space_y
        -- LogMgr.log( 'debug',"i = "..i.." px = "..px.." py = "..py)
        item:setPosition(cc.p(px, py))
        vector:addChild(item)
    end

    return vector

end 

-- 显示掉落宝箱特效
function showPrizeBox(parent, callback)
	local prevPath = "image/ui/CopyUI/effect/"
	local armPath = "image/armature/scene/copy/"
	local txtPath = "image/ui/CopyUI/txt/txt_get_box.png"

	local minX = visibleSize.width / 2
	local minY = visibleSize.height / 2
	
	local x = minX - 315
	local y = minY + 310

    -- 添加宝箱
	local boxPath = armPath .."baox-tx-03/baox-tx-03.ExportJson"
	local box = ArmatureSprite:addArmatureTo(parent, boxPath, "baox-tx-03", x + 322, y - 275, nil, 5)
	
	local sid = 0
	local function boxDown(ref)
		if nil == box or box.getCurrentFrameIndex == nil then
			TimerMgr.killTimer(sid)
			return
		end
		local frame = box:getCurrentFrameIndex()
		local total = box:getCurrentFrames()
		
		if frame >= total - 2 then
			TimerMgr.killTimer(sid)
			box:gotoAndStop(total - 2)

			local effPath = armPath .."jqys-1/jqys-1.ExportJson"
			local effect = ArmatureSprite:addArmatureTo(parent, effPath, "jqys-1", x, y, nil, 4)
			effect:setScale(2)

			local clickBox = ccui.Layout:create()
			clickBox:setSize(cc.size(visibleSize.width, visibleSize.height))
			-- clickBox:setPosition(cc.p, visibleSize.height / 2 - 100))
			local function touchHandler(ref, eventType)
                SoundMgr.playEffect("sound/ui/openbox.mp3")
				box:gotoAndStop(total - 1)
				
				effect:stop()
                effect:removeArmature()
				
                clickBox:removeFromParent()
                
				local prizePath = armPath .."jqys-2/jqys-2.ExportJson"
				local prizeEffect = ArmatureSprite:addArmatureTo(parent, prizePath, "jqys-2", x + 100, y - 100, nil, 5)
				prizeEffect:setScale(2)
				local function showEffectEnd()
					prizeEffect:stop()
					prizeEffect:setVisible(false)

					local function complete()
                        prizeEffect:removeArmature()
						box:removeArmature()
					end
					a_scale_fadeout(box, 0.5, {x = 0.2, y = 0.2}, complete)
				end
				prizeEffect:onPlayComplete(showEffectEnd)
				
				if callback then
                    callback()
                end			
			end
			parent:addChild(clickBox, 5, 1)

			UIMgr.addTouchEnded(clickBox, touchHandler)
		end
	end
	sid = TimerMgr.startTimer(boxDown, 0, false)
    
    SoundMgr.playEffect("sound/ui/fallbox.mp3")
    
	showRewardText(parent, cc.p(minX, minY + 100), "box")
end

--播放奖励特效
function showReward(parent, callback)
	local txtPath = "image/ui/CopyUI/txt/txt_get_prize.png"
	local armPath = "image/armature/scene/copy/"

    local minX = visibleSize.width / 2
    local minY = visibleSize.height / 2
    local x = minX - 200
    local y = minY + 200
    local path = armPath .. "jqys-3/jqys-3.ExportJson"
    local complete = function(ref)
        ref:stop()
        ref:setVisible(false)
        local function doSome()
            ref:removeArmature()
        end
        performWithDelay(ref, doSome, 0.03)
--        ref:removeNextFrame()
       
        if callback ~= nil then
        	callback()
        end
    end
    local armature = ArmatureSprite:addArmatureTo(parent, path, "jqys-3", x, y, complete)
    -- armature:setScale(2)

    showRewardText(parent, cc.p(minX, minY + 100), "prize")
end

function showRewardText(parent, pos, rewardType)
	local txtPath = "image/ui/CopyUI/txt/txt_get_prize.png"
	if rewardType == "box" then
		txtPath = "image/ui/CopyUI/txt/txt_get_box.png"
	end
	local txtImg = Sprite:create(txtPath)
	txtImg:setPosition(pos)
	parent:addChild(txtImg, 10)

	a_move_movefade(txtImg, 0.5, cc.p(pos.x, pos.y + 20), 0.5, cc.p(pos.x, pos.y + 40))
end

--按钮的启用与禁止
function buttonDisable(button, disable)
	if disable then 
		button:setTouchEnabled(false)
		button:setBright(false)
	else 
		button:setTouchEnabled(true)
		button:setBright(true)
	end 
end

function swiftbutton(openbtn, closebtn , func, func1)
	openbtn:setTouchEnabled(true)
	closebtn:setTouchEnabled(true)
    local function linkHandler(ref, eventType)
        if eventType == ccui.TouchEventType.ended then
            if openbtn:isVisible() == true and closebtn:isVisible() == false then
                openbtn:setVisible(false)
                closebtn:setVisible(true)
                func()
            elseif openbtn:isVisible() == false and closebtn:isVisible() == true then
                openbtn:setVisible(true)
                closebtn:setVisible(false)
                func1()
            end
        end
    end
    -- if openbtn:isVisible() == true then
        openbtn:addTouchEventListener(linkHandler)
    -- end
    -- if closebtn:isVisible() == true then
        closebtn:addTouchEventListener(linkHandler)
    -- end
end

-- 创建类似标签按钮 list,typedata标签data ,动画
function createMoveTab(list,typedata)
    local tab = {}
    local dataProvider = nil
    local target = nil
    local handler = nil
    local selectedIndex = 2
    local btnList = list
    local positionlist = nil 
    -- 添加 dataProvider 的 get/set 方法
    function tab:setDataProvider(data)
        dataProvider = data;
    end
    function tab:getDataProvider()
        return dataProvider
    end
    -- 添加点击事件回调
    function tab:addEventListener(_target, _handler)
        target = _target
        handler = _handler
    end
    -- 添加 selectedIndex 的 get/set 方法
    function tab:getSelectedIndex()
        return selectedIndex
    end
    function tab:setSelectedIndex(value)
        if selectedIndex ~= value then
            if 0 ~= selectedIndex then
                btnList[selectedIndex].btn_selected:setVisible(false)
                btnList[selectedIndex].btn_unselected:setVisible(true)
                for k, v in pairs(positionlist) do
                    btnList[k].btn_unselected:setPositionX(v[1])
                end 
                --在这里做动画
                for key ,v in pairs(btnList) do 
                    if key > value then
                        btnList[key].btn_unselected:setPositionX(positionlist[key][1] +  (btnList[key].btn_selected:getSize().width - btnList[key].btn_unselected:getSize().width))
                    end 
                end 
            end

            selectedIndex = value
            local btn_selected = btnList[value].btn_selected
            local btn_unselected = btnList[value].btn_unselected
            btn_selected:setVisible(true)
            btn_unselected:setVisible(false)
            
            
        end
    end
    -- 获取 selectedItem
    function tab:getSelectedItem()
        if nil ~= dataProvider then
            return dataProvider[selectedIndex]
        end
        return nil
    end

    local function init()
        local length = table.getn(btnList)
        positionlist = {}
        for i = 1, length, 1 do
            local btns = btnList[i]
            btns.btn_selected:setVisible(false)
            btns.btn_unselected:setVisible(true)
            btns.btn_unselected.index = i
            btns.btn_unselected:setTouchEnabled(true)
            local function clickHandler(ref, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local index = ref.index
                    tab:setSelectedIndex(index)
                    if target ~= nil and handler ~= nil then
                        local data1 = typedata[index]
                        handler({selectedIndex = index , data = data1})
                    end
                end
            end
            table.insert(positionlist,{btns.btn_unselected:getPositionX(),btns.btn_unselected:getPositionY()})
            btns.btn_unselected:addTouchEventListener(clickHandler)
        end
        tab:setSelectedIndex(1)
    end

    init()

    return tab
end

function showAnimateText(txt, t_delay, prevNum, nextNum, format, doFunc)
	local dn = nextNum - prevNum
	if dn == 0 then
		if nil ~= doFunc then
			doFunc()
		end
		return
	end
	local frame = cc.Director:getInstance():getFrameRate()
	local delay = 1 / frame
	local times = math.ceil(t_delay / delay)
	local add = math.ceil(dn / times)
	local currNum = prevNum

	LogMgr.debug(" dn = " .. dn .. " frame = " .. frame .. " delay = " .. delay .. " times = " .. times .. " add = " .. add)

	local function callback()
		currNum = currNum + add
		if currNum >= nextNum then
			currNum = nextNum
			txt:stopAllActions()
			if nil ~= doFunc then
				doFunc()
			end
		end
		txt:setString(string.format(format, currNum))
	end
	schedule(txt, callback, delay)
end

function setButtonPoint( button, isShow, off, depth, icon_url,scale)
	if isShow then
		if button.redPoint == nil then
			if not icon_url then
				button.redPoint = cc.Sprite:createWithSpriteFrameName("tip_red.png")
			else
				button.redPoint = cc.Sprite:create(icon_url)
			end
			if scale then
				button.redPoint:setScale(scale.x,scale.y)
			end
			button:addChild( button.redPoint, depth or 9 )
			if off == nil then
				local size = button.getSize and button:getSize() or button:getContentSize()
				local anchorPoint = button:getAnchorPoint()
				local subOffX = 20
				local subOffY = 20
				if size.width / 5 > subOffX then
					subOffX = size.width / 5 
				end

				if size.height / 5 > subOffY then
					subOffY = size.height / 5 
				end
                off = cc.p(size.width - subOffX, size.height - subOffY )
                button.redPoint:setPosition( off )
			end
		end
	end
	if button.redPoint then
		if isShow then
		    if off then
		    	button.redPoint:setPosition( off )
		    end
		end
		button.redPoint:setVisible( isShow )
	end	

	return button.redPoint
end

-- 包含数字的红点
function setButtonPointWithNum(button, isShow, num, off, depth)
	local rp = setButtonPoint(button, isShow, off, depth)
	if rp and not button.txt then
		rp:setSpriteFrame("tip_red_big.png")
		local size = rp:getBoundingBox()
		local txt = UIFactory.getText('', rp, size.width/2, size.height/2, 22)
		txt:setString(num)
		button.txt = txt
	end

	if button.txt and button.txt:getString() ~= num then
		button.txt:setString(num)
	end
	button.rp = rp

	return button.rp
end

-- 传空表需要在父类设置这个函数self.dataLen
-- 1,数据data ， 2 为初始化viewfunc为没交互时间 ，更新数据，position位置 ， size 大小，untilsize是until大小， parent 父类，slieder 滚动条 
function createTableView(data,viewfunc,updatefunc, position,size,untilsize , parent,slider, widthCount,scroMaxll )
    --TabelView初始化
    if widthCount == nil then
    	widthCount = 1
    end
    if scroMaxll == nil then
    	scroMaxll = 3
    end

    function parent:setSliderCell( percent )
        if self.tcellHeigth == nil or self.maxCeil == nil or self.theigth == nil then
            return
        end
        local min = -(self.tcellHeigth * self.maxCeil - self.theigth )
  
        self.ScrollOffH = min
        if slider then
	        if self.maxCeil <= scroMaxll then
	            slider:setPercent(100)
	            slider:setEnabled(false)
	            return
	        end
                	
	        slider:setEnabled(true)
	        slider:setPercent(percent)
	        self:valueChanged(slider)
	    end
    end
    
    function parent:cellAtIndex( view, idx )
        local index = idx + 1
        local cell = view:dequeueCell()
        local content
        if nil == cell then
            cell = cc.TableViewCell:new()
            content = viewfunc()
            cell:addChild(content) 
            content:setTag(1)
        else
            content = cell:getChildByTag(1)
        end

        for i=1,widthCount do
        	updatefunc(data, content, index, i, widthCount )
        end
        
        return cell
    end
    
    function parent:valueChanged(pSender)  
        if self.tableView == nil then
            return
        end

        self.m_bTable = false
        if  self.m_bSlider then
            --小于4列时，禁止一切滚动操作
            if self.maxCeil <=  scroMaxll then
                return
            end
            local h = (100 - pSender:getPercent())/100 * self.ScrollOffH
            self.tableView:setContentOffset( cc.p(0, h) )
        end
        self.m_bTable = true
    end
    
    function parent:numberOfCells( view )
        local dataLen = self.dataLen / self.widthCount
        if self.dataLen % self.widthCount ~= 0 then
        	dataLen = dataLen + 1
        end
        self.maxCeil = dataLen
        return self.maxCeil
    end
    
    function parent:DidScroll(view)
        parent.isscorlling = true 
        if slider == nil then
            return
        end

        if self.maxCeil <= 3 then
            return
        end

        self.m_bSlider = false
        if  self.m_bTable  then
            local p = math.ceil( self.tableView:getContentOffset().y / self.ScrollOffH * 100)
            slider:setPercent(100 - p)
        end
        self.m_bSlider = true
    end  
    
    function parent:cellSize( view,idx )
        self.tcellWidth =  untilsize.width
        self.tcellHeigth =  untilsize.height 
        --宽高度很变态
        return self.tcellHeigth,self.tcellWidth
    end
    
    local function scrollViewDidScroll(view)
        parent:DidScroll(view)
    end

    local function scrollViewDidZoom(view)
    end

    local function tableCellTouched(view,cell)
        if view:isTouchMoved() then
            return
        end

        if parent.touchCell == nil then
            return 
        end

        local content =cell:getChildByTag(1)
        if content then
            parent.touchCell( content, ( content.index - 1 ) * parent.widthCount + parent.indexX, parent.indexX )
        end
    end

    local function cellTouched(	pTouch, pEvent )
		local view = pEvent:getCurrentTarget()
        if view:isTouchMoved() then
            return
        end

        if parent.touchCell == nil then
            return
        end

        local touchPosition = pTouch:getLocation()
        touchPosition = view:convertToNodeSpace(touchPosition)
        parent.indexX = math.ceil( touchPosition.x / ( parent.untilsize.width / parent.widthCount ) )
    end

    local function tableCellAtIndex(view, idx)
        return parent:cellAtIndex(view,idx)
    end

    local function numberOfCellsInTableView(view)
        return parent:numberOfCells(view)
    end

    local function cellSizeForTable(view,idx) 
        return parent:cellSize(view,idx)
    end
    
    local function percentChangedEvent(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            parent:valueChanged(slider)
        end
    end
    
    --是否tableview滚动    
    parent.m_bTable = true
    parent.m_bSlider = false
    parent.ScrollOffH = 1
    parent.indexX = 1
    parent.dataLen = table.getn(data)
    parent.widthCount = widthCount
    parent.tableView = cc.TableView:create(size)
    parent.twidth = size.width
    parent.theigth = size.height
    parent.untilsize = untilsize
    parent.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    parent.tableView:setPosition(position)
    parent.tableView:setDelegate()
    parent.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    parent:addChild(parent.tableView,10)
    parent.tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL )
    parent.tableView:registerScriptHandler( scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM )
    parent.tableView:registerScriptHandler( tableCellTouched,cc.TABLECELL_TOUCHED )
    parent.tableView:registerScriptHandler( cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX )
    parent.tableView:registerScriptHandler( tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX )
    parent.tableView:registerScriptHandler( numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW )

    UIMgr.registerScriptHandler(parent.tableView, cellTouched, cc.Handler.EVENT_TOUCH_BEGAN, true)
    
    parent.tableView:reloadData()
    if slider ~= nil then 
       slider:addEventListenerSlider(percentChangedEvent)
       parent:setSliderCell(0)
    end 
    
    parent.closeTableview = function ()
        if parent.tableView ~= nil then 
           parent.tableView:removeFromParent(true)
           parent.tableView = nil 
        end 
    end 

    return parent.tableView    
end 

--ui对应位置关系
local SubUiPos = {
	[1]={-1, 1}, [2]={0, 1}, [3]={1, 1},
	[4]={-1, 0}, [5]={0, 0}, [6]={1, 0},
	[7]={-1, -1}, [8]={0, -1}, [9]={1, -1}
}

--子UI进场动画
--target
--posType 1-9, 9宫格位置
--duration [可选]
-- isInto [可选] 默认为true
function UICommon.showSubUI(target, posType, duration)
	if target._sub_action_tag then
		target:stopActionByTag(target._sub_action_tag)
	end
	local pos = cc.p(target:getPosition())
	local function onNodeEvent(event)
		if "exit" == event then
			target:setPosition(pos)
			-- LogMgr.info("ui out", cc.p(target:getPosition()).y, pos.x, pos.y)
		elseif "enter" == event then
			-- LogMgr.info("ui in", cc.p(target:getPosition()).y, pos.x, pos.y)
		end
	end
	local size = target:getContentSize()
	local uiPos = SubUiPos[posType]
	local startPos = cc.p(pos.x + uiPos[1] * size.width, pos.y + uiPos[2] * size.height)
	target:setPosition(startPos)
	target._targetPos = pos
    UICommon.showTargetAction(target, pos, duration)
	target:registerScriptHandler(onNodeEvent)
end
function UICommon.getSubOutPoint(target, pos, posType)
	local size = target:getContentSize()
	local uiPos = SubUiPos[posType]
	local outPos = cc.p(pos.x + uiPos[1] * size.width, pos.y + uiPos[2] * size.height)
	return outPos
end
function UICommon.showTargetAction(target, endPos, duration)
	duration = duration or 0.5
	local action = cc.MoveTo:create(duration, endPos)
	action = cc.EaseBackOut:create(action)
	action:setTag(919)
	target._sub_action_tag = action:getTag()
	target:runAction(action)
end
