--**谭春映
--**活动UI -- 子页
ActivityInfo = createLayoutClass('ActivityInfo', cc.Node)
function ActivityInfo:onShow()
    EventMgr.addList(self.event_list)
end

function ActivityInfo:onClose()
     EventMgr.addList(self.event_list)
end

function ActivityInfo:updateData()
    self.dataList = {}
    if self.infoData then
        self.openData = ActivityData.findOpenData(self.infoData.name)
        if self.openData then
            self.AData = ActivityData.findAData(self.openData.data_id)
            if self.AData then
                self.dataList = ActivityData.getCondintionListBySort( self.openData,self.AData )
            end
        end
    end
    self.tableView:reloadData()
end

function ActivityInfo:setData( index , data )
    self.tempLen = index
    self.infoData = data
    self:updateData()
end

function ActivityInfo:updateItemData( index,content )
    content.btnGet:setVisible(false)
    content.geted:setVisible(false)
    content:setVisible(false)
    content.curValue:setString("")
    content.btnGet.factor = nil
    if index <= #self.dataList then
        content:setVisible(true)
        local data = self.dataList[index]
        if data.first and data.first ~= 0 then
            local factor = ActivityData.findFactorData(data.first)
            if factor then
                local factorDesc = ActivityData.getFactorDescByType(factor.type)
                if factor.value1 and factor.value1 ~= 0 then
                    content.txtCondName:setString(string.format(factorDesc,factor.value,factor.value1) )
                    if factor.type == const.kActivityFactorTypeUpSoldier then
                        local qColorName = SoldierData.getSoldierQualityColor(factor.value1)
                        content.txtCondName:setString(string.format(factorDesc,factor.value,qColorName) )
                    end
                else
                    content.txtCondName:setString(string.format(factorDesc,factor.value) )
                end

                local condNameSize = content.txtCondName:getSize()
                content.curValue:setString(string.format("(%s/%s)",data.curVar,factor.value))
                content.curValue:setColor(cc.c3b(0x31, 0xff, 0x16))
                content.curValue:setPositionX(content.txtCondName:getPositionX() + condNameSize.width)

                local img = content.btnGet:getVirtualRenderer()
                img:setGLProgramState( ProgramMgr.createProgramState( 'normal' ) )
                buttonDisable(content.btnGet,false)
                local isRedShow = data.meetCondition
                if not data.meetCondition then 
                    buttonDisable(content.btnGet,true)
                    img:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
                    content.curValue:setColor(cc.c3b(0xff, 0x00, 0x00))
                end

                local size = content.btnGet:getSize()
                local off = cc.p(size.width - 12,size.height - 12)
                setButtonPoint( content.btnGet, isRedShow ,off)

                --是否已经领取（必需要用最新数据）
                local isGetedValue = VarData.getVar(string.format("activity_%s_present_%d",self.openData.name,data.index - 1))
                if isGetedValue and isGetedValue > 0  then
                    content.geted:setVisible(true)
                else
                    content.btnGet:setVisible(true)
                end
            end
            content.btnGet.factor = factor
        end

        if data.second and data.second ~= 0 then
            local rewardData = ActivityData.findRewardData(data.second)
            if rewardData then
                local rewardLen = #rewardData.value_list
                for k,v in pairs(content.rewardList) do
                    local item = content.rewardList[k]
                    item.count:setString("")
                    item:setVisible(false)
                    if k <= rewardLen then
                        item:setVisible(true)
                        item.count:setString("")
                        local reward = {}
                        local x,y,z = string.match(rewardData.value_list[k],"(%w+)%%(%w+)%%(%w+)")
                        reward.cate,reward.objid,reward.val = toMyNumber(x),toMyNumber(y),toMyNumber(z)
                        if reward.cate then
                            local url = CoinData.getCoinUrl(reward.cate,reward.objid)
                            item.icon:loadTexture(url,ccui.TextureResType.localType)
                            item.reward = reward
                            item.num_w:setVisible(false)
                            local itemValue = reward.val
                            if itemValue >= 10000 then
                                local pValue = itemValue/10000
                                --整数判断
                                if math.floor(pValue)>= pValue then 
                                    itemValue = pValue .. "/" 
                                end
                                --item.num_w:setVisible(true)
                                --item.count:setString(itemValue)
                                --数字的位置很诡异？？？？？？？
                                --item.count:setPosition(66,18)
                            else
                                --item.count:setString(itemValue)
                                --item.count:setPosition(66,18)
                            end

                            item.count:setString(itemValue)
                            item.count:setPosition(66,18)
                        end
                    end
                end
            end
        end

        content.btnGet.dIndex = data.index - 1
        content.btnGet.index = index - 1
        content.data = data
    end
end

function ActivityInfo:dispose( ... )
    if self.listener1 then
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.listener1)
    end
end

function ActivityInfo:ctor()
    local function update( ... )
        --self:updateData()
        if self.tableView and self.qIndex then
            self.tableView:updateCellAtIndex(self.qIndex)
        end
    end
    self.dataList = {}
	self:initTableView()
    self.event_list = {}
    self.event_list[EventType.activityGetReward] = update
end

function ActivityInfo:addGetRewardEvent( target )
    local function getReward( sender )
        if self.openData and sender.factor then
            self.qIndex = sender.index
            Command.run( 'activity takereward',self.openData.guid,sender.dIndex)
        end
    end
    createScaleButton(target,true)
    target:addTouchEnded(getReward)
end

function ActivityInfo:addRewardItemEvent( target )
    local function onTouchBegan( touch, event )
        local target = event:getCurrentTarget()
        if target then
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height )
            
            if cc.rectContainsPoint(rect, locationInNode) then
                local pos = touch:getLocation()
                --local pos = target:getTouchStartPos()
                --local pos = locationInNode
                if target.reward then
                    if target.reward.cate == const.kCoinItem then
                        local jItem = findItem(target.reward.objid)
                        if jItem then
                            TipsMgr.showTips(pos,TipsMgr.TYPE_ITEM,jItem)
                        end
                    else
                        TipsMgr.showTips(pos, TipsMgr.TYPE_COIN, target.reward)
                    end
                end

            end
        end
    end

    if not target.listener1 then
        target.listener1 = cc.EventListenerTouchOneByOne:create()
        target.listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
        target:getEventDispatcher():addEventListenerWithSceneGraphPriority(target.listener1, target)
    end
end

function ActivityInfo:initTableView()
	self.tcellWidth =  507
	self.tcellHeigth = 149
	local function scrollViewDidScroll(view)

    end

    local function scrollViewDidZoom(view)
       
    end

    local function tableCellTouched(view,cell)
        --do return end
        if view:isTouchMoved() then
            return
        end

        -- local touchIndex = cell:getIdx() + 1
        -- local content =cell:getChildByTag(1)
        -- if content then
        --     self:toDetail(content,self.CellSub)
        -- end
        --local content =cell:getChildByTag(1)
    end

    local function tableCellAtIndex(view, idx)
	    local index = idx + 1
	    local cell = view:dequeueCell()
	    local label = nil
	    local saveContent = nil
	    if nil == cell then
	        cell = cc.TableViewCell:new()
	        local content = getLayout(ActivityData.path1 .. "conditionItem.ExportJson")
            buttonDisable(content,true)
	        content:setAnchorPoint(cc.p(0,0))
	        content:setPosition(cc.p(20, -10))
	        content:setTag(1)
	        cell:addChild(content)
	        saveContent = content
	        buttonDisable(content,true)
            self:addGetRewardEvent(content.btnGet)
            addOutline(content.txtCondName,cc.c4b(0x59, 0x1f, 0x05,255),1)
            content.curValue:setAnchorPoint(0,0.5)

            content.rewardList = {}
            for i=1,3 do
                local offY = 15
                local item = getLayout(ActivityData.path1 .. "rewardItem.ExportJson")
                buttonDisable(item,true)
                content:addChild(item)
                item:setPosition( 10 + (i - 1) * 87,offY)
                item.index = i
                content.rewardList[i] = item
                local url = ItemData.getItemUrl(26)
                item.icon:loadTexture(url,ccui.TextureResType.localType)
                item.icon:setScale(0.6)
                self:addRewardItemEvent(item)
            end
	    else
	        saveContent = cell:getChildByTag(1)
	    end
	    self:updateItemData(index,saveContent)
	    return cell
    end

    local function numberOfCellsInTableView(view)
        self.maxCeil = #self.dataList
        return self.maxCeil
	    --return self.tempLen
    end
    
    local function cellSizeForTable(view,idx) 
	    --宽高度很变态
	    return self.tcellHeigth,self.tcellWidth
    end

	self.tableView = cc.TableView:create(cc.size(674 ,290 + 18))
    self.tableView:setPosition(164 - 20,8 - 8)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
   	self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView)
    self.tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL )
    self.tableView:registerScriptHandler( scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM )
    self.tableView:registerScriptHandler( tableCellTouched,cc.TABLECELL_TOUCHED )
    self.tableView:registerScriptHandler( cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX )
    self.tableView:registerScriptHandler( tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX )
    self.tableView:registerScriptHandler( numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    self.tableView:reloadData()
end