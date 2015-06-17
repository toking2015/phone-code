--**谭春映
--**英雄系统 1.5  [2015版 ]   列表
SoldierList = createLayoutClass('SoldierList', cc.Node)
function SoldierList:onShow()
    EventMgr.addList(self.event_list)
    self:reset()
    self.ReList = SoldierData.SoldiersByEquipType(self.equipType)
    self.enableReList,self.notReList = SoldierData.getRecruitList(self.equipType)
    self:startTimer()
    self:updateData()
end

function SoldierList:reset( ... )
    self.stopTimerFlag = true
    self.qLevelUpGuid = nil
    self.inductItem = nil
end

function SoldierList:startTimer()
    self:removeCacheTimer()

    local function loop()
        if not self.stopTimerFlag then
            local newItem = nil
            --delayNotReList未招募优先
            if not self.notReFirst then
                for k,v in pairs(self.delayReList) do
                    table.remove(self.delayReList,k)
                    newItem = self:getListItem(true)
                    self:initReItem(v.i,newItem,v.offX,v.offY)
                    return
                end
            end

            if #self.delayNotReList <= 0 then
                self.notReFirst = false
            end

            for k,v in pairs(self.delayNotReList) do
                table.remove(self.delayNotReList,k)
                newItem = self:getListItem(false)
                self:initNotReItem(v.i,newItem,v.offX,v.offY)
                return
            end

            if not self.modelNormal then
                if self.pushed then
                    self.saveLvTime = DateTools.getMiliSecond()
                    self.showNeed = false
                    self.isIn = false
                    self:showLvOpacityStates(1)
                else
                    local dTime = DateTools.getMiliSecond() - self.saveLvTime
                    if dTime > self.spaceTime then
                        for k,v in pairs(self.reItems) do
                            if v.playLoop then
                                --动画
                                self:runOpacityAction(v)
                            end
                        end

                        self.isIn = not self.isIn
                        if self.isIn then
                            self.showNeed = not self.showNeed
                        end
                        self.saveLvTime = DateTools.getMiliSecond()
                    end
                end
            end
        end
    end
    self.gTimer = TimerMgr.startTimer( loop, 0, false )
end

function SoldierList:runOpacityAction( view )
    local lvUp = view.lvItem.lvUp
    local space = 0.6
    if self.showNeed then
        if self.isIn then
            a_fadein(lvUp.lvLabel,space)
            a_fadein(lvUp.levelNeed.lvNeedIcon,space)
            a_fadein(lvUp.levelNeed.needCount,space)
        else
            a_fadeout(lvUp.lvLabel,0,space)
            a_fadeout(lvUp.levelNeed.lvNeedIcon,0,space)
            a_fadeout(lvUp.levelNeed.needCount,0,space)
        end
    else
        if self.isIn then
            a_fadein(lvUp.lvLabel,space)
            a_fadein(lvUp.lvValue.Image_8,space)
            a_fadein(lvUp.lvValue.cur,space)
            a_fadein(lvUp.lvValue.max,space)
        else
            a_fadeout(lvUp.lvLabel,0,space)
            a_fadeout(lvUp.lvValue.Image_8,0,space)
            a_fadeout(lvUp.lvValue.cur,0,space)
            a_fadeout(lvUp.lvValue.max,0,space)
        end
    end

    if self.isIn then
        a_fadein(view.enLevelUp,space)
        a_fadein(self.top.lvupImg,space)
    else
        a_fadeout(view.enLevelUp,0,space)
        a_fadeout(self.top.lvupImg,0,space)
    end
end

--等级与圣水透明度
function SoldierList:showLvOpacityStates(state)
    for k,view in pairs(self.reItems) do
        if view.playLoop then
            self:showLvOpacityState(view,state)
        end
    end
end

function SoldierList:showLvOpacityState(view,state)
    local lvUp = view.lvItem.lvUp
    lvUp.lvLabel:stopAllActions()
    lvUp.levelNeed.lvNeedIcon:stopAllActions()
    lvUp.levelNeed.needCount:stopAllActions()
    lvUp.lvValue.Image_8:stopAllActions()
    lvUp.lvValue.cur:stopAllActions()
    lvUp.lvValue.max:stopAllActions()
    if state ==  1 then
        lvUp.lvLabel:setOpacity(255)
        lvUp.levelNeed.lvNeedIcon:setOpacity(0)
        lvUp.levelNeed.needCount:setOpacity(0)
        lvUp.lvValue.Image_8:setOpacity(255)
        lvUp.lvValue.cur:setOpacity(255)
        lvUp.lvValue.max:setOpacity(255)
        --显示等级
    elseif state ==  2 then
        --显示圣水
    else
        lvUp.lvLabel:setOpacity(0)
        lvUp.levelNeed.lvNeedIcon:setOpacity(0)
        lvUp.levelNeed.needCount:setOpacity(0)
        lvUp.lvValue.Image_8:setOpacity(0)
        lvUp.lvValue.cur:setOpacity(0)
        lvUp.lvValue.max:setOpacity(0)
    end
end

function SoldierList:removeCacheTimer()
    if self.gTimer ~= nil  then
        TimerMgr.killTimer(self.gTimer)
        self.gTimer = nil
    end
end

function SoldierList:onClose()
    self:removeFightEffect()
    self:lvClearDownTimer()
    self:removeCacheTimer()
    EventMgr.removeList(self.event_list)
    self.inductItem = nil
end
function SoldierList:updateData( )
    --LogMgr.debug("谭SoldierList：：：：：updateData_out" )
    --防暴点
    if self.qLevelUpGuid then
        for k,v in pairs(self.ReList) do
            local oldData = self.ReList[k]
            self.ReList[k] = SoldierData.getSoldier(v.guid)
            if oldData.level ~= self.ReList[k].level then
                local view = self:getItemByGuid(v.guid)
                self:setRecruitData(view,self.ReList[k])
            end
            --LogMgr.debug("谭SoldierList：：：：：updateData" )
        end
        return
    end
    self:removeFightEffect()
 	self:setScrollViewContent()
end

function SoldierList:setItemBase( view,quality,jSoldier )
	local url = SoldierData.getOccNameUrl(jSoldier)
    view.occName:loadTexture(url, ccui.TextureResType.localType)
    local a,b = SoldierData.getQualityAndNum(quality)
    local color = QualityData.getColor(a)
    view.name:setColor(color)
    view.name:setString(jSoldier.name .. b)
    --职业名
    url = SoldierData.getOccUrl(jSoldier)
    view.occIcon:loadTexture( url, ccui.TextureResType.localType )
end

function SoldierList:setItemHeadBase( head,quality,jSoldier )
	local url = SoldierData.getQualityFrameName(quality)
    head.bg:loadTexture( url, ccui.TextureResType.plistType )
    url = SoldierData.getAvatarUrl(jSoldier )
    head.style:loadTexture( url, ccui.TextureResType.localType )
end

function SoldierList:setItemStar( head,star )
	local lastStar = nil
    self.pos1 = {{25,7}}
    self.pos2 = {{21,7},{31,7}}
    self.pos3 = {{16,9},{26,7},{36,9}}
    self.pos4 = {{11,9},{21,7},{31,7},{41,9}}
    self.pos5 = {{6,10},{16,8},{26,7},{36,8},{46,10}}
    self.pos6 = {{1,12},{11,9},{21,7},{31,7},{41,9},{51,12}}
    --星星
    local sY = 7
    for K=1,6 do
        if K <= star then
            head.starLay["star1_" .. K ]:setVisible(true)
        else
            head.starLay["star1_" .. K ]:setVisible(false)
        end
    end

    for i=1,star do
        local p = self["pos"..star][i]
        head.starLay["star1_" .. i ]:setPosition(p[1],p[2])
    end
end

function SoldierList:setRecruitData( view,sData,actionInit )
	local jSoldier = findSoldier(sData.soldier_id)
    local jSoldierQuality = findSoldierQuality(sData.quality)
	if not jSoldier or not jSoldierQuality then
		return
	end

    local q1 = jSoldierQuality.quality_effect.first
    local url = SoldierDefine.prePath2 .. "qbg_"..q1..".png"
    view.qBg:loadTexture(url,ccui.TextureResType.localType)
	view.sData = sData
    view.soldierId = jSoldier.id
	self:setItemBase(view,sData.quality,jSoldier)
	--头像相关
	local head = view.head
    local img = head.style:getVirtualRenderer()
    local star = sData.star
    local level = sData.level
    head.starLay:setVisible(true)
    img:setGLProgramState( ProgramMgr.createProgramState( 'normal' ) )
    head.level:setString(level)
    local c3b = cc.c3b(0xff, 0xfc, 0x00 )
    head.level:setColor(c3b)

    self:setItemHeadBase(head,sData.quality,jSoldier)
    self:setItemStar(head,star)
    --升级相关
    self:updateViewLv(view,sData,jSoldier,actionInit)
    --技能书相关
    if self.modelNormal then
        self:updateViewBook(view,sData,jSoldier,jSoldierQuality,q1)
    end
end

function SoldierList:updateViewLv( view,sData,jSoldier,actionInit)
    local star = sData.star
    local lvNormal = view.lvItem.lvNormal
    local lvUp = view.lvItem.lvUp
    local lvInfo = findSoldierLv(sData.level)
    local fullLevel = false
    if lvInfo == nil then
        return
    end

    if self.jLevelBaseInfo then
        if sData.level >= self.jLevelBaseInfo.soldier_lv then
            fullLevel = true
        end

        lvNormal.lvValue.max:setString(self.jLevelBaseInfo.soldier_lv)
        lvUp.lvValue.max:setString(self.jLevelBaseInfo.soldier_lv)
        lvUp.lvValue2.max:setString(self.jLevelBaseInfo.soldier_lv)
    end

    lvNormal.lvValue:setVisible(true)
    local needObj = lvUp.levelNeed
    needObj.needCount:setString(lvInfo.cost.val)
    local valueSize = needObj.needCount:getSize()
    needObj.lvNeedIcon:setPosition(needObj.needCount:getPositionX() - valueSize.width/2 - 18 ,needObj.needCount:getPositionY() )
    lvNormal.lvValue.cur:setString(sData.level)
    lvUp.lvValue.cur:setString(sData.level)
    lvUp.lvValue2.cur:setString(sData.level)
    --是否可升级
    local redLv = false
    local redOther = false
    local size = nil
    local off = nil
    view.enLevelUp:setVisible(false)
    view.playLoop = true
    if self.modelNormal then
        lvNormal:setVisible(true)
        lvUp:setVisible(false)
        --红点
        local isStepUp = SoldierData.enStepUp(sData)
        local isBookEat = SoldierData.enBookDress(sData)
        if SoldierData.enableStarUp(star,jSoldier) or isStepUp or isBookEat then
            redOther = true
        end
        size = view:getSize()
        off = cc.p(12,size.height - 8)
    else
        lvNormal:setVisible(false)
        lvUp:setVisible(true)
        --红点
        local soldierQuality = findSoldierQuality(sData.quality)
        if SoldierData.enLevelUp(sData.level,lvInfo) then
            redLv = true
        end
        size = view.lvItem:getSize()
        off = cc.p(size.width - 8,size.height - 8)
    end

    setButtonPoint( view, redOther ,off)
    setButtonPoint( view.lvItem, redLv ,off,199)

    --等级说明
    if lvInfo.lv == 90 or fullLevel then
        --等级已满
        lvNormal.lvLabel:loadTexture("soliern_lv_label3.png",ccui.TextureResType.plistType)
        lvUp.lvLabel:loadTexture("soliern_lv_label3.png",ccui.TextureResType.plistType)
        lvUp.lvLabel2:loadTexture("soliern_lv_label3.png",ccui.TextureResType.plistType)
        view.playLoop = false
    else
        if self.modelNormal then
            view.playLoop = false
            lvNormal.lvLabel:loadTexture("soliern_lv_label1.png",ccui.TextureResType.plistType)
            lvUp.lvLabel:loadTexture("soliern_lv_label1.png",ccui.TextureResType.plistType)
            lvUp.lvLabel2:loadTexture("soliern_lv_label1.png",ccui.TextureResType.plistType)
        else
            --可升级
            view.enLevelUp:setVisible(true)
            lvNormal.lvLabel:loadTexture("soliern_lv_label2.png",ccui.TextureResType.plistType)
            lvUp.lvLabel:loadTexture("soliern_lv_label2.png",ccui.TextureResType.plistType)
            lvUp.lvLabel2:loadTexture("soliern_lv_label2.png",ccui.TextureResType.plistType)
        end
    end

    if view.playLoop then
        lvUp.lvLabel2:setVisible(false)
        lvUp.lvValue2:setVisible(false)
        --初始化升级模式轮换显示
        if actionInit then
            lvUp.levelNeed:setVisible(true)
            lvUp.lvLabel:setVisible(true)
            lvUp.lvValue:setVisible(true)
            self:showLvOpacityStates(1)
        end
    else
        lvUp.levelNeed:setVisible(false)
        lvUp.lvLabel:setVisible(false)
        lvUp.lvValue:setVisible(false)
        --非轮换模式显示时，使用 lvLabel2与 lvValue2 显示（由于透明度设置存在很多bug）
        lvUp.lvLabel2:setVisible(true)
        lvUp.lvValue2:setVisible(true)
    end
end

function SoldierList:updateViewBook( view,sData,jSoldier,jSoldierQuality,q1)
    --技能书相关
    local lvNormal = view.lvItem.lvNormal
    buttonDisable(lvNormal,true)
    lvNormal.nNotItem:setVisible(false)
    lvNormal.nItemIcon:setScale(1)
    lvNormal.nItemIcon:setVisible(true)
    lvNormal.nItemIcon:loadTexture("soldier_book5.png",ccui.TextureResType.plistType)
    local jSoldierQualityOccu = findSoldierQualityOccu(sData.quality,jSoldier.occupation)
    if jSoldierQualityOccu then
        local itemId = jSoldierQualityOccu.cost.objid
        local jItem = findItem(itemId)
        if jItem then
            local quality = ItemData.getQuality( jItem, nil )
            quality = quality - 1
            --LogMgr.debug(itemId,sData.quality,jItem.quality,quality)
            --是否已经装备
            local userItem = ItemData.getSoldierSkillBook(sData.guid) 
            if userItem then
                lvNormal.nItemIcon:setScale(0.6)
                lvNormal.nItemIcon:setVisible(true)
                lvNormal.nItemIcon:loadTexture(ItemData.getItemUrl(itemId),ccui.TextureResType.localType)
            else
                lvNormal.guid = sData.guid
                lvNormal.itemId = itemId
                lvNormal.sData = sData
                local packNum = ItemData.getItemCount(itemId,const.kBagFuncCommon)
                if packNum > 0 then
                    lvNormal.nNotItem:setVisible(true)
                    if sData.level >= jSoldierQualityOccu.limit_lv then
                        lvNormal.nNotItem:loadTexture("soldier_book1.png",ccui.TextureResType.plistType)
                    else
                        lvNormal.nNotItem:loadTexture("soldier_book2.png",ccui.TextureResType.plistType)
                    end 
                else
                    if ItemData.bookMergeRecursionCheck(itemId) then
                        lvNormal.nNotItem:setVisible(true)
                        if sData.level >= jSoldierQualityOccu.limit_lv then
                            lvNormal.nNotItem:loadTexture("soldier_book3.png",ccui.TextureResType.plistType)
                        else
                            lvNormal.nNotItem:loadTexture("soldier_book4.png",ccui.TextureResType.plistType)
                        end 
                    end
                end
            end
            lvNormal.nItemBg:loadTexture(string.format("qualitybg%d.png",q1),ccui.TextureResType.plistType)
        end
    end
end

function SoldierList:setNotRecruitData( view,eData )
	local jSoldier = eData.jData
	if not jSoldier then
		return
	end

    local url = SoldierDefine.prePath2 .. "qbg_1.png"
    view.qBg:loadTexture(url,ccui.TextureResType.localType)
	view.eData = eData
    view.soldierId = jSoldier.id
	--头像相关<<<<<<<<<<<<<
	local head = view.head
    local img = head.style:getVirtualRenderer()
    head.starLay:setVisible(false)
	img:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
	self:setItemBase(view,jSoldier.quality,jSoldier)
    head.level:setString('')
    head.levelBg:setVisible(false)
    self:setItemHeadBase(head,jSoldier.quality,jSoldier)
    --头像相关>>>>>>>>>>>>>>>>>>
    --是否可招募
    local isRedShow = false
    local jSoldierRecruit= SoldierData.getRecruitInfo(jSoldier.id)
    if jSoldierRecruit then
        if SoldierData.enRecruit(jSoldierRecruit) then
            isRedShow = true
        end
    end

    size = view.qBg:getSize()
    off = cc.p(12,size.height - 8)
    setButtonPoint( view.qBg, isRedShow ,off)
    --进度
    local progressItem = view.progressItem
   	local recruitInfo = SoldierData.getRecruitInfo(jSoldier.id)
   	if recruitInfo then
   		local costItem = recruitInfo.cost_[1]
   		local need = costItem.val
	    local packNum = ItemData.getItemCount(costItem.objid,const.kBagFuncCommon)
	    local percent = math.min(1,packNum/need) * 100
	    progressItem.progress:setPercent(percent)
	    progressItem.precent:setString(packNum .. "/"..need)
        view.recruitInfo = recruitInfo
   	end

end

function SoldierList:dispose( )
    self:disposeLvEffect()
    self:removeCacheTimer()
    self:toCache()
    for k,v in pairs(self.cacheReItems) do
        v:release()
    end
    for k,v in pairs(self.cacheNotReItems) do
        v:release()
    end
    self:removeLvEffectTimer()
end

function SoldierList:ctor()
	local function update()
        self:updateData()
    end

    local function soldierLevelUp()
        self:playLvUpEffect()
    end

    self.spaceTime = 600
    self.isIn = false
    self.runOpacity = 0
    self.qLevelUpGuid = nil
    self.cacheReItems = {}
    self.cacheNotReItems = {}
    self.notReItems = {}
    self.reItems = {}
	self.testSort = true
	self.spaceW = 360 --项宽
	self.spaceH = 141 --项高
	self.splitH = 46  --分隔线占高度
    self.scrollOffX = 5
    self.modelNormal = true
	self:initScrollView()
    self.event_list = {}
    self.event_list[EventType.SoldierLevelUp] = soldierLevelUp
end

function SoldierList:onRecruit( sender )
    if sender.eData == nil then
        return
    end
    
    local jSoldier = sender.eData.jData
    local recruitInfo = sender.recruitInfo
    local costItem = recruitInfo.cost_[1]
    local recostMoney =recruitInfo.cost_[2]
    
    local money= CoinData.getCoinByCate(const.kCoinMoney)
    local packNum = ItemData.getItemCount(costItem.objid,const.kBagFuncCommon)

    if (CoinData.checkLackCoin(const.kCoinItem, costItem.val, costItem.objid)) then
        return
    end

    function self.okFun(id,needMoney)
        ActionMgr.save( 'UI', 'SoldierList click showMsgBox_okFun' )
        if (CoinData.checkLackCoin(const.kCoinMoney, recostMoney.val, 0)) then
            return
        end
        Command.run('soldier recruit',recruitInfo.id)
    end

    if recostMoney then
        showMsgBox( string.format("[font=ZH_5]是否消耗[font=ZH_3]%s[font=ZH_5]金币招募[font=ZH_3]%s？",
            recostMoney.val,jSoldier.name), self.okFun, function() end )
    else
        Command.run('soldier recruit',recruitInfo.id)
    end
end

function SoldierList:toInfoBySData( sData )
    if self.equipType and sData then
        local equipType = self.equipType
        Command.run("ui show", "SoldierInfo", PopUpType.SPECIAL)
        local win = PopMgr.getWindow('SoldierInfo')
        if win then
            win:setData(sData, equipType)
        end 
        PopMgr.removeWindow(self:getParent())
    end
end

function SoldierList:toInfo( sender )
    if sender.sData then
        SoldierDefine.soldierLevel = sender.sData.level
    end

    self:toInfoBySData(sender.sData)
end

-- function SoldierList:addEvent( view )
-- 	local function onItemClick(sender)
       -- ActionMgr.save( 'UI', 'SoldierList click view_bg ' .. sender.soldierId )
-- 		if sender.eData then
--             self:onRecruit(sender)
-- 			return
-- 		end 
--         self:toInfo(sender)
-- 	end
-- 	createScaleButton(view.bg,false)
-- 	view.bg:addTouchEnded(onItemClick)
-- end

function SoldierList:toCache()
    for k,v in pairs(self.notReItems) do
        table.insert(self.cacheNotReItems,v)
    end

    for k,v in pairs(self.reItems) do
        table.insert(self.cacheReItems,v)
    end
end

function SoldierList:initReItem(i,view,offX,offY)
    self.scrollView:addChild(view)
    view:setPosition(offX,offY)
    table.insert( self.reItems,view )
    --self:addEvent(view)
    self:addItemEvent(view)
    self:setRecruitData(view,self.ReList[i],true)
    view.offX = offX + self.scrollOffX
    view.offY = offY
    if self.defaultId then
        if self.defaultId == view.soldierId then
            self:changeScrollByItem(view)
        end
    end
end

function SoldierList:initNotReItem(i,view,offX,offY)
    self.scrollView:addChild(view)
    view:setPosition(offX,offY)
    table.insert( self.notReItems,view )
    --self:addEvent(view)
    self:addItemEvent(view)
    self:setNotRecruitData(view,self.notReList[i])
    view.offX = offX + self.scrollOffX
    view.offY = offY
    if self.defaultId then
        if self.defaultId == view.soldierId then
            self:changeScrollByItem(view)
        end
    end
end

function SoldierList:setScrollViewContent( )
    self.stopTimerFlag = true
	local scSize = self.scrollView:getSize()
	local inner = self.scrollView:getInnerContainer()
	local topY = 0
    self:toCache()
	self.scrollView:removeAllChildren()
	--测试
	--self.ReList = {1,2,3,4,5}
	--self.ReList = {}
    --self.notReList = {1,2,3,4,5,6,7,8}
    --self.notReList = {}

    self.reDataLen = #self.ReList
    self.notReDataLen = #self.notReList

    --计算滚动总大小--》》》
    local innerHeight = 0
    local notReH = self.spaceH  * math.floor(( self.notReDataLen -1 )/2)
    notReH = math.max(0,notReH)
    innerHeight = notReH
    if self.notReDataLen > 0 then
    	innerHeight = innerHeight + self.spaceH
    end
    --分隔线
    if self.reDataLen > 0 then
        innerHeight = innerHeight + self.splitH
    end

    local reH = self.spaceH  * math.floor(( self.reDataLen -1 )/2)
    reH = math.max(0,reH)
    innerHeight = reH + innerHeight
    if self.reDataLen > 0 then
    	innerHeight = innerHeight + self.spaceH
    end

    if innerHeight < scSize.height then
    	topY = scSize.height - innerHeight 
    	innerHeight = scSize.height
    end

    local innerWidth = scSize.width
    self.scrollView:setInnerContainerSize(cc.size(innerWidth, innerHeight)) 
    --计算滚动总大小--》》》
    self.delayReList = {}
    self.delayNotReList = {}
    self.reItems = {}
    self.notReItems = {}
    self.splitImg = nil

    local offX = 0
    local offY = 0
    local obj = nil
    --【未招募】
    local maxTop = topY + self.spaceH  * math.floor(( self.notReDataLen -1 )/2)
   	for i=1,self.notReDataLen do
        local view = self:getCacheListItem(false)
        offX = (i - 1 ) % 2 * self.spaceW
        offY = maxTop - self.spaceH  * math.floor(( i -1 )/2)
        if view then
            self:initNotReItem(i,view,offX,offY)
        else
            obj = {}
            obj.i = i
            obj.offX = offX
            obj.offY = offY
            table.insert(self.delayNotReList,obj)
        end
   	end
   	topY = maxTop + self.spaceH

   	--【分隔线】
    self.splitOffY = nil
    if self.reDataLen > 0 then
        self.splitImg = getLayout(SoldierDefine.prePath .. "split.ExportJson")
        self.splitImg.bg:loadTexture( "soldier_line2.png", ccui.TextureResType.plistType )
        self.splitImg.btnTo:setVisible(false)
        self.splitImg.btnBack:setVisible(false)
    	self.scrollView:addChild(self.splitImg)
    	self.splitImg:setAnchorPoint(0.5,0.5)
    	self.splitImg:setPosition( scSize.width/2,topY + self.splitH/2 - 5 )
        self.splitOffY = topY
    	topY = topY + self.splitH
    end
    self:setTopBgStateByScroll()

	--【已经招募】
	maxTop = topY + self.spaceH  * math.floor(( self.reDataLen -1 )/2)
   	for i=1,self.reDataLen do
		local view = self:getCacheListItem(true)
        offX = (i - 1 ) % 2 * self.spaceW
        offY = maxTop - self.spaceH  * math.floor(( i -1 )/2)
        if view then
            self:initReItem(i,view,offX,offY)
        else
            obj = {}
            obj.i = i
            obj.offX = offX
            obj.offY = offY
            table.insert(self.delayReList,obj)
        end
   	end
    self.stopTimerFlag = false
    self.isScroll = false
end

function SoldierList:getCacheListItem( isRe )
    local result = nil
    local list =  nil
    if isRe then
        list = self.cacheReItems
    else
        list = self.cacheNotReItems
    end

    if #list > 0 then
        result = list[#list]
        result.offX = nil
        result.offY = nil
        result.soldierId = nil
        table.remove(list, #list)
        return result
    end

    return nil
    --return self:getListItem(isRe)
end

-- function SoldierList:addOpenSkillBookEvent( target )
--     local function openSkillBookCom( sender )
--         self:toInfoBySData(sender.sData)
--         SkillBookMergeUI.showUI(sender.itemId,sender.guid)
--     end
--     createScaleButton(target,false)
--     target:addTouchEnded(openSkillBookCom)
-- end

function SoldierList:levelUpById( soldierId )
    local data = SoldierData.getSoldierBySId(soldierId)
    if data then
        self:onLevelUp(data)
    end
end

function SoldierList:onLevelUp( sData )
    if sData == nil then
        return 
    end

    local jLvInfo = findSoldierLv(sData.level)
    if not jLvInfo or not self.jLevelBaseInfo then
        return
    end

    if sData.level >= self.jLevelBaseInfo.soldier_lv then
        TipsMgr.showError("升级战队可提升等级上限")
        return
    end

    -- 圣水
    local warter= CoinData.getCoinByCate(const.kCoinWater)
    local needNum = jLvInfo.cost.val
    if (CoinData.checkLackCoin(const.kCoinWater, needNum, 0)) then
        return
    end

    self.qLevelUpGuid = sData.guid
    --LogMgr.debug("谭SoldierList：：：：：onLevelUp",self.qLevelUpGuid )

    self.qLevelUpFight = SoldierData.getFightValue(self.qLevelUpGuid,const.kAttrSoldier)
    SoldierData.lvUpNeed = needNum
    local qInfo = {}
    --英雄 first:英雄背包类型 second:英雄guid
    qInfo.first = const.kSoldierTypeCommon
    qInfo.second = sData.guid
    Command.run( 'soldier soldierLvUp', qInfo )
end

function SoldierList:lvStartDownTimer( flag )
    local  function idle( )
        if self.levelUpSender then
            if self.isScroll then
                return
            end
            
            self.lvBeginTime = self.lvBeginTime+1
            if self.lvBeginTime >= self.lvSaveMax or self.lvSaveMax < 0 then
                self.lvBeginTime = 1
                self.lvLongClick = true
                self:onLevelUp(self.levelUpSender.sData)
                self.lvSaveMax = self.lvSaveMax -1
            end
        end
    end

    self:lvClearDownTimer()
    self.lvLongClick = false
    self.lvBeginTime  = 0
    self.lvSaveMax = 12 + 6
    self.lvDownTimer = TimerMgr.startTimer( idle, 0.01, false )
end

function SoldierList:lvClearDownTimer()
    if self.lvDownTimer ~= nil  then
        TimerMgr.killTimer(self.lvDownTimer)
        self.lvDownTimer = nil
    end
end

function SoldierList:addItemEvent( target )
    --长按
    local function itemBegin( sender,type )
        ActionMgr.save( 'UI', 'SoldierList click item_islvup_ ' .. tostring( not self.modelNormal) .. sender.soldierId  )
        self.isScroll = false
        self.pushed = true
        if not self.modelNormal and sender.sData then
            
            self.levelUpSender = sender
            local parent = sender:getParent()
            self.levelDownPosi = toScenePoint( parent ,cc.p(parent:getPosition()) )
            self:lvStartDownTimer()
        end
    end

    local function itemCancel( sender,type )
        ActionMgr.save( 'UI', 'SoldierList click click item_islvup_' .. tostring( not self.modelNormal ) .. sender.soldierId  )
        self.pushed = false
        self:lvClearDownTimer()
        if self.isScroll then
            self.isScroll = false
            return
        end
        self.isScroll = false

        if sender.eData then
            ActionMgr.save( 'UI', 'SoldierList onRecruit item' )
            self:onRecruit(sender)
        else 
            if not self.modelNormal then
                if not self.lvLongClick then
                    self:onLevelUp(sender.sData)
                end
            else
                --进详细页面
                self:toInfo(sender)
            end
        end
    end

    createScaleButton(target,false)
    target:addTouchBegan(itemBegin)
    target:addTouchEnded(itemCancel)
    target:addTouchCancel(itemCancel)
end

function SoldierList:getListItem( isRe )
    local view = getLayout(SoldierDefine.prePath .. "soldierItem.ExportJson")
    view.bg:loadTexture(SoldierDefine.prePath2 .. "soldier_itembg1.png",ccui.TextureResType.localType)
    view:retain()
    view.isRe = isRe
    if isRe then
        --升级/技能书 相关<<<<<<<<<<<<<<<
        local lvItem = getLayout(SoldierDefine.prePath .. "soldierItemLv.ExportJson")
        view:addChild(lvItem)
        lvItem:setPosition(120,15)
        view.lvItem = lvItem
        local needObj = lvItem.lvUp.levelNeed
        needObj.lvNeedIcon:setScale(0.3)
        needObj.lvNeedIcon:loadTexture(CoinData.getCoinUrl(const.kCoinWater,0),ccui.TextureResType.localType )
        lvItem.lvUp:setVisible(false)
        lvItem.lvNormal:setVisible(false)
    else
        --进度相关
        local progressItem = getLayout(SoldierDefine.prePath .. "soldierItemPro.ExportJson")
        view:addChild(progressItem)
        progressItem:setPosition(123,35)
        view.progressItem = progressItem
    end
    return view
end

function SoldierList:setTopBg(isShowGeted)
    if isShowGeted then
        self:setModelBtnState()
    else
        self.top.bg:loadTexture( "soldier_line2.png", ccui.TextureResType.plistType )
        self.top.btnTo:setVisible(false)
        self.top.btnBack:setVisible(false)
    end
end

function SoldierList:setModelBtnState( ... )
    if self.modelNormal then
        self.top.bg:loadTexture( "soldier_line1.png", ccui.TextureResType.plistType )
        self.top.btnTo:setVisible(true)
        self.top.btnBack:setVisible(false)
        buttonDisable(self.top.btnTo.btnf,false)
        buttonDisable(self.top.btnBack.btnf,true)
        self.top.lvupImg:setVisible(false)
    else
        self.top.bg:loadTexture( "soldier_line3.png", ccui.TextureResType.plistType )
        self.top.btnTo:setVisible(false)
        self.top.btnBack:setVisible(true)
        buttonDisable(self.top.btnTo.btnf,true)
        buttonDisable(self.top.btnBack.btnf,false)
        self.top.lvupImg:setVisible(true)
    end

    --是否可升级
    local enLevelUp,enStarUp = SoldierData.starAndLevelUpMap()
    local isRedShow = false
    if self.modelNormal and not table.empty(enLevelUp) then
        isRedShow = true
    end
    local size = self.top.btnTo:getSize()
    local off = cc.p(size.width - 8,size.height - 8)
    setButtonPoint( self.top.btnTo, isRedShow ,off,199)
end

function SoldierList:toModel()
    ActionMgr.save( 'UI', 'SoldierList click top_btn isLvUp ' .. tostring(self.modelNormal) )
    self.modelNormal = not self.modelNormal
    self:setModelBtnState()
    for k,v in pairs(self.reItems) do
        self:setRecruitData(v,v.sData,true )
    end

    --初始化升级模式轮换显示
    if not self.modelNormal then
        self.showNeed = false
        self.isIn = false
        self.saveLvTime = DateTools.getMiliSecond()
    end
end

function SoldierList:changeModelEvent( target )
    local function toModel( sender,type )
        self:toModel()
    end
    createScaleButton(target,true)
    target:addTouchBegan(toModel)
end

function SoldierList:setTopBgStateByScroll()
    if self.splitOffY then
        local scrollH = math.abs(self.scrollView:getInnerContainer():getPositionY() -  self.scrollViewSizeH )
        if scrollH < self.splitOffY then
            self:setTopBg(false)
        else
            self:setTopBg(true)
        end
    else
        self:setTopBg(false)
    end
end

function SoldierList:initScrollView()
    local function scrollViewEvent( sender, eventType )
        if eventType == ccui.ScrollviewEventType.scrolling then
            self.isScroll = true
            self:setTopBgStateByScroll()
        end
    end

    local function scrollViewEventEnd( sender, eventType )
        self.isScroll = false
    end
     --初始化最上面那条
    self.top = getLayout(SoldierDefine.prePath .. "split.ExportJson")
    local topSize = self.top:getSize()
    self.scrollViewSizeH = 512 - topSize.height

	self.scrollView = ccui.ScrollView:create()
    self.scrollView:setTouchEnabled(true)
    self.scrollView:setSize(cc.size(713 + self.scrollOffX, self.scrollViewSizeH))  
    self:addChild(self.scrollView)
    self:setPosition(-self.scrollOffX,0)
    self.scrollView:addEventListenerScrollView(scrollViewEvent)
    UIMgr.addTouchEnded(self.scrollView, scrollViewEventEnd)

    self:addChild(self.top)
    self.top:setPosition(0,self.scrollViewSizeH)
    self:changeModelEvent(self.top.btnTo.btnf)
    self:changeModelEvent(self.top.btnBack.btnf)
    self:setTopBg(true)
    self:setModelBtnState()
end

function SoldierList:setType( equipType )
    self:reset()
	self.equipType = equipType
    self.ReList = SoldierData.SoldiersByEquipType(self.equipType)
    self.enableReList,self.notReList = SoldierData.getRecruitList(self.equipType)
    local teamLevel = gameData.getSimpleDataByKey("team_level")
    self.jLevelBaseInfo = findLevel(teamLevel)
    self.saveLvTime = DateTools.getMiliSecond()
    self:updateData()
end

function SoldierList:setDefaultSoldier(soldierId)
    if not soldierId or soldierId == 0 then
        return
    end

    if not self.scrollView then
        return
    end

    local findItem = nil
    for k,v in pairs(self.reItems) do
        if soldierId == v.soldierId then
            findItem = v
            break
        end
    end

    if not findItem then
        for k,v in pairs(self.notReItems) do
            if soldierId == v.soldierId then
                findItem = v
                break
            end
        end
    end

    if findItem then
        self:changeScrollByItem(findItem)
    else
        for k,v in pairs(self.delayReList) do
            if self.ReList[v.i].soldier_id == soldierId then
                self:setScrollPrecent(v.offY)
                return
            end
        end

        for k,v in pairs(self.delayNotReList) do
            if self.notReList[v.i].id == soldierId then
                self:setScrollPrecent(v.offY)
                self.notReFirst = true
                return
            end
        end
        self.defaultId = soldierId
    end
end

function SoldierList:getItemPrecent( item_offY )
    local tHeight = self.scrollView:getInnerContainerSize().height
    local offY = tHeight - ( item_offY + self.spaceH )
    local precent = offY/ ( tHeight - self.scrollViewSizeH ) * 100
    if item_offY < self.scrollViewSizeH - self.spaceH  then
        precent = 100
    end

    if item_offY >= tHeight - self.scrollViewSizeH then
        precent = 0
    end
    return precent
end

function SoldierList:setScrollPrecent( item_offY )
    self.toPrecent = self:getItemPrecent(item_offY)
    self.scrollView:jumpToPercentVertical( self.toPrecent)
    self:setModelBtnState()
end

function SoldierList:changeScrollByItem( item )
    self:setScrollPrecent(item.offY)
    -- for k,v in pairs(self.reItems) do
    --     self:setRecruitData(v,v.sData)
    -- end
    self.defaultId = nil
    self.inductItem =item
end

function SoldierList:removeLvEffectTimer( ... )
    if self.timeId ~= nil  then
        TimerMgr.killTimer(self.timeId)
        self.timeId = nil
    end
end

function SoldierList:playLvUpEffect()
    if self.qLevelUpGuid then
        self:playLvLightEffect()
        self:playLvAddNumEffect()
    end
end

function SoldierList:getItemByGuid( guid )
    if self.reItems then
        for k,v in pairs(self.reItems) do
            if v.sData then
                if v.sData.guid == guid then
                    return v
                end
            end
        end
    end
end

function SoldierList:playLvLightEffect()
    local view = self:getItemByGuid(self.qLevelUpGuid)
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    local function removeEffect()
        extRemoveChild(self.lvEffect)
    end
    local function effectComplete()
        self:removeLvEffectTimer()
        self.lvEffect:stop()
        self.timeId = TimerMgr.runNextFrame( removeEffect )
    end

    if view then
        local temp_obj = view.head.bg
        local pos = cc.p(temp_obj:getPosition())
        if self.lvEffect then
            extRemoveChild(self.lvEffect)
            extAddChild(layer,self.lvEffect)
            self.lvEffect:gotoAndPlay(1)
            
        else
            local path1 = 'image/armature/ui/SoldierUI/yxsjxg-tx-01/yxsjxg-tx-01.ExportJson'
            self.lvEffect = ArmatureSprite:addArmature(path1, 'yxsjxg-tx-01', "SoldierUI", 
                                  layer, 0,0,effectComplete)
            self.lvEffect:retain()
        end
        pos = temp_obj:getParent():convertToWorldSpace(pos)
        self.lvEffect:setPosition(pos.x,pos.y)
    end
end

function SoldierList:removeFightEffect( ... )
    -- if self.fEffectCon then
    --     local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    --     self.fEffectCon:removeAllChildren()
    --     self.fEffectCon:removeFromParent()
    --     layer.fEffectCon = nil
    --     self.fEffectCon = nil
    -- end
    TipsMgr.hideFightAdd()
    TipsMgr.hideFightAdd()
end

function SoldierList:playLvAddNumEffect()
    local curFight = SoldierData.getFightValue(self.qLevelUpGuid,const.kAttrSoldier)
    local dFight = curFight - self.qLevelUpFight
    local view = self:getItemByGuid(self.qLevelUpGuid)
    if view and dFight >0 then
        local centerPoint = cc.p(view.head.bg:getPosition() ) 
        centerPoint.y = centerPoint.y - 50
        TipsMgr.showFightAdd(centerPoint,view.head.bg,dFight)
    end
end

function SoldierList:disposeLvEffect( ... )
    if self.lvEffect then
        self.lvEffect:stop()
        extRemoveChild(self.lvEffect)
        self.lvEffect:release()
    end
    if self.lvFightAddEfect then
        self.lvFightAddEfect:stopAllActions()
        self.lvFightAddEfect:release()
    end
end