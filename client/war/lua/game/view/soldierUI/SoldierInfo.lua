--**谭春映
--**英雄系统 2015版  英雄信息(独立UI)
require "lua/game/view/soldierUI/SoldierDefine.lua"
require "lua/game/view/soldierUI/SoldierInfoSkill.lua"
require "lua/game/view/soldierUI/SoldierInfoEquip.lua"
require "lua/game/view/soldierUI/SoldierInfoArr.lua"
require "lua/game/view/soldierUI/SoldierStepUpEffect.lua"
require "lua/game/view/soldierUI/SoldierStarUpSuccess.lua"
require "lua/game/view/soldierUI/SoldierStepSuccess.lua"
local effStepData = SoldierData.effStepData  --升阶相关特效
--声明类
local url = SoldierDefine.prePathI .. "infoMain.ExportJson"
SoldierInfo = createUIClass("SoldierInfo", url, PopWayMgr.SMALLTOBIG)
SoldierInfo.sceneName = "common"

function SoldierInfo:onShow()
    EventMgr.addList(self.event_list)
    self.flyItems= {}
    --测试升阶成功
    -- Command.run("ui show", "SoldierStepSuccess", PopUpType.SPECIAL)
    -- local win = PopMgr.getWindow('SoldierStepSuccess')
    -- if win ~= nil then
    --     local serverData = SoldierData.getSoldier(1)
    --     serverData.quality = 4
    --     win:setData( serverData )
    -- end 
end

function SoldierInfo:onClose()
    self.eatBookQ = false
    self:clearDownTimer()
    self:lvClearDownTimer()
    self:clearCtorTimer()
    self:checkEatItem()
    self.stepEffect:removeAllEffect()
    EventMgr.removeList(self.event_list)
    self:removeStyleView() 
    ModelMgr:releaseUnFormationModel()
    Command.run("ui show", "SoldierUI", PopUpType.SPECIAL)  
    self:clearStepFlyItem()
    SoldierData.equipExt_map = {}
end

function SoldierInfo:clearStepFlyItem()
    for k,v in pairs(self.flyItems) do
        v:stopAllActions()
        extRemoveChild(v)
    end
    self.flyItems = {}
end

function SoldierInfo:dispose( ... )
    if self.stepEffect then
        self.stepEffect:dispose()
    end
    if self.skillLay then
        self.skillLay:release()
    end
    if self.equipLay then
        self.equipLay:release()
    end
    if self.arrLay then
        self.arrLay:release()
    end
    if self.arrScrollView then
        self.arrScrollView:retain()
    end
    SoldierData.dispose()
end

function SoldierInfo:updateData()
	self:checkEatItem()
    self:initCacheStep()

    self.qualityFull = self.isQfull(self.sData)
    if self.stepList then
        self.itemEat = self.stepList[1]
    end

	self:updataStyle()
	self:updateStar()
	self:updateStep()
    self:updateStepBook()
    self:updateQualify()

    --升阶效果
    if SoldierDefine.stepUp  then
        self.stepEffect:playEfect()
        SoldierDefine.stepUp = false
    end

    if self.skillLay then
        self.skillLay:updateData()
    end
    if self.equipLay then
        self.equipLay:updateData()
    end
    if self.arrLay then
        self.arrLay:updateData()
    end
end

function SoldierInfo:setPageBtnState( ... )
    if self.pageIndex <= 1 then
        self.btnPre:setVisible(false)
        self.pre.btnPreDis:setVisible(true)
    else
        self.btnPre:setVisible(true)
        self.pre.btnPreDis:setVisible(false)
    end

    if self.pageIndex >= self.dataLen then
        self.btnNext:setVisible(false)
        self.next.btnNextDis:setVisible(true)
    else
        self.btnNext:setVisible(true)
        self.next.btnNextDis:setVisible(false)
    end
end

function SoldierInfo:setData( sData , equipType )
    self:clearStepFlyItem()
    self:removeStyleView()
    if equipType then
        self.ReList = SoldierData.SoldiersByEquipType(equipType)
        self.dataLen = #self.ReList
        for k,v in pairs(self.ReList) do
            if v.guid == sData.guid then
                self.pageIndex = k
                break
            end
        end
        self:setPageBtnState()
    end

    if sData then
    	self.sData = self:flushSData(sData.guid)
    	self.jSoldier = findSoldier(sData.soldier_id)
    	self.jStarInfo = findSoldierStar( self.sData.star)
    	--等级数据
    	self.jLvInfo = findSoldierLv(self.sData.level)
        self.teamLevel = gameData.getSimpleDataByKey("team_level")
        self.jLevelBaseInfo = findLevel(self.teamLevel)
        --阶数据
        self.jSoldierQuality = findSoldierQuality(self.sData.quality)
    	self:updateData()

        if self.skillLay then
    	   self.skillLay:setData(self.sData,self.jSoldier,self.jSoldierQuality)
        end

        if self.equipLay then
    	   self.equipLay:setData(self.sData,self.jSoldier)
        end
        if self.arrLay then
    	   self.arrLay:setData(self.sData,self.jSoldier,self.jLvInfo)
        end
    end
end

function SoldierInfo:updataStyle( )
    if self.jSoldier ~= nil then
	    local color = QualityData.getColor(SoldierData.getQualityAndNum(self.sData.quality))
	    self.styleCon.name:setColor(color)
	    self.styleCon.name:setString(self.jSoldier.name)
	    for K=1,6 do
	        if K <= self.sData.star then
	            self.styleCon["star_" .. K ]:loadTexture("soldierd_star.png", ccui.TextureResType.plistType)
	        else
	            self.styleCon["star_" .. K ]:loadTexture("soldierd_starn.png", ccui.TextureResType.plistType)
	        end
	    end

	    if self.styleView == nil then
	        self.styleView = ModelMgr:useModel(self.jSoldier.animation_name)
	        self.styleView:setPositionX(self.styleCon.style:getPositionX())
	        self.styleView:setPositionY(self.styleCon.style:getPositionY() - 50)
	        self.styleCon:addChild(self.styleView)
	        self.styleView:playOne(false, "stand")
	    end
    end
end

function SoldierInfo:updateQualify( )
	local qLay = self.styleCon.quality
    qLay:setVisible(false)
    --品质与品质+
    if self.jSoldierQuality then
        local q1 = self.jSoldierQuality.quality_effect.first
        local q2 = self.jSoldierQuality.quality_effect.second
        effStepData.q1 = q1
        effStepData.q2 = q2
        if not SoldierDefine.stepUp then
            local url2 = SoldierDefine.prePath2 .. "soldiern_q"..q1..".png"
            self.qBg:loadTexture(url2,ccui.TextureResType.localType)
            if self.stepCon then
                self.stepCon.nItemBg:loadTexture(string.format("qualitybg%d.png",q1),ccui.TextureResType.plistType)
            end
        end
        if q2 > 0 then
            qLay:setVisible(true)
            setUiOpacity(qLay,0)
            if not SoldierDefine.stepUp then
                setUiOpacity(qLay,255)
                qLay.qn:loadTexture("soldiern_qn"..q2..".png",ccui.TextureResType.plistType)
            end
        end
    end
end

function SoldierInfo:removeStyleView( ... )
    if self.styleView ~= nil then
        ModelMgr:recoverModel(self.styleView)
        self.styleView = nil
    end
end

function SoldierInfo:updateStar()
	-- if self.sData.star >= 5 then
 --        self.starCon.btnStarUp:setVisible(false)
 --    else
 --        self.starCon.btnStarUp:setVisible(true)
 --    end
 	if self.jSoldier == nil then
 		return
 	end

    if not self.starCon then
        return 
    end

    local isRedShow = SoldierData.enableStarUp(self.sData.star,self.jSoldier)
    local size = self.starCon.btnStarUp:getSize()
    local off = cc.p(size.width - 8,size.height - 8)
    setButtonPoint( self.starCon.btnStarUp, isRedShow ,off)

    if self.jStarInfo == nil then
        return
    end

    local progressLay = self.starCon.progress
    local starUpCost = {}
    starUpCost.first = self.jSoldier.star_cost.objid
    starUpCost.second = self.jStarInfo.cost
    self.starUpCost = starUpCost
    local need = starUpCost.second
    local packNum = ItemData.getItemCount(starUpCost.first,const.kBagFuncCommon)
    local url = ItemData.getItemUrl(starUpCost.first)
    self.starCon.icon:loadTexture(url,ccui.TextureResType.localType)

    local percent = math.min(1,packNum/need) * 100
    progressLay.progress:setPercent(percent)
    progressLay.levelV_4:setString(packNum.."/"..need)
    if self.jLvInfo and self.jLevelBaseInfo then
        if not SoldierDefine.levelUp then
            self.starCon.levelV:setString(self.sData.level .. "/" .. self.jLevelBaseInfo.soldier_lv )
        end
        --是否可升级
        -- local isRedShow2 = false
        -- if SoldierData.enLevelUp(self.sData.level,self.jLvInfo) then
        --     isRedShow2 = true
        -- end
        -- local leveUpBtn = self.starCon.more
        -- local size = leveUpBtn:getSize()
        -- local off = cc.p(size.width,size.height)
        -- setButtonPoint( leveUpBtn, isRedShow2 ,off,199)
    end
    if self.sData.star == 6 then
        progressLay.levelV_4:setString("已满星")
        progressLay.progress:setPercent(100)
    end
    self.starCon.fight:setString( "战力：" .. SoldierData.getFightValue(self.sData.guid,const.kAttrSoldier) )
    self.starCon.occ:setString( "职业：" .. SoldierData.getOccName(self.jSoldier) )
    self.starCon.equipType:setString( "装备类型：" .. SoldierData.getEquipTypeName(self.jSoldier) )
    
end

function SoldierInfo:isQfull(sData )
    if not sData then
        return false
    end

    return sData.quality >= 15
end

function SoldierInfo:updateStepBook( )
    if not self.sData or not self.jSoldier then
        return
    end

    local stepCon = self.stepCon
    if not self.stepCon then
        return
    end

    local isRedShow = false
    stepCon.bookCount:setString(string.format("(%d/1)",0))
    self.bookCue =""
    --技能书
    stepCon.nNotItem:setVisible(false)
    stepCon.nItemIcon:setScale(1)
    stepCon.nItemIcon:setVisible(true)
    stepCon.nItemIcon:loadTexture("soldierd_book5.png",ccui.TextureResType.plistType)
    stepCon.nextQV:setString('')
    if not self.qualityFull then
        local a,b = SoldierData.getQualityAndNum(self.sData.quality + 1)
        local color = QualityData.getColor(a)
        stepCon.nextQV:setColor(color)
        local colorName = QualityData.getName(a)
        stepCon.nextQV:setString(colorName .. b)
    end

    local jSoldierQualityOccu = findSoldierQualityOccu(self.sData.quality,self.jSoldier.occupation)
    if jSoldierQualityOccu then
        local itemId = jSoldierQualityOccu.cost.objid
        local jItem = findItem(itemId)
        if jItem then
            self.bookId = itemId
            stepCon.bookName:setString(jItem.name)
            local quality = ItemData.getQuality( jItem, nil )
            quality = quality - 1
            --LogMgr.debug(itemId,sData.quality,jItem.quality,quality)
            --是否已经装备
            local userItem = ItemData.getSoldierSkillBook(self.sData.guid) 
            if userItem or self.eatBookQ then
                buttonDisable(stepCon.nNotItem,true)
                buttonDisable(stepCon.nItemBg,true)
                stepCon.nItemIcon:setScale(0.6)
                stepCon.nItemIcon:loadTexture(ItemData.getItemUrl(itemId),ccui.TextureResType.localType)
                stepCon.bookCount:setString(string.format("(%d/1)",1))
            else
                self.bookCue = jItem.name .. " 不足"
                local packNum = ItemData.getItemCount(itemId,const.kBagFuncCommon)
                buttonDisable(stepCon.nNotItem,false)
                buttonDisable(stepCon.nItemBg,false)
                stepCon.nNotItem.guid = self.sData.guid
                stepCon.nNotItem.itemId = itemId
                stepCon.nItemBg.itemId = itemId
                stepCon.nItemBg.guid = self.sData.guid
                local packNum = ItemData.getItemCount(itemId,const.kBagFuncCommon)
                if packNum > 0 then
                    stepCon.nNotItem:setVisible(true)
                    if self.sData.level >= jSoldierQualityOccu.limit_lv then
                        isRedShow = true
                        stepCon.nNotItem:loadTexture("soldierd_book1.png",ccui.TextureResType.plistType)
                    else
                        stepCon.nNotItem:loadTexture("soldierd_book2.png",ccui.TextureResType.plistType)
                    end 
                else
                    if ItemData.bookMergeRecursionCheck(itemId) then
                        stepCon.nNotItem:setVisible(true)
                        if self.sData.level >= jSoldierQualityOccu.limit_lv then
                            isRedShow = true
                            stepCon.nNotItem:loadTexture("soldierd_book3.png",ccui.TextureResType.plistType)
                        else
                            stepCon.nNotItem:loadTexture("soldierd_book4.png",ccui.TextureResType.plistType)
                        end 
                    end
                end

            end
            stepCon.bookCount:setPositionX( stepCon.bookName:getPositionX() + stepCon.bookName:getSize().width )
            --stepCon.nItemBg:loadTexture(string.format("qualitybg%d.png",quality),ccui.TextureResType.plistType)
        end
    end

    local size = stepCon.nNotItem:getSize()
    local off = cc.p(size.width,size.height)
    setButtonPoint( stepCon.nNotItem, isRedShow ,off)
end


function SoldierInfo:updateStep( )
	if self.stepList == nil then
        return
    end

    self.stepEnable = false
    self.xp = self:getXp()
    if self.jSoldierQuality and self.jSoldierQuality.xp then 
        self.needMaxXp = self.jSoldierQuality.xp
        self:changeXp( self.xp )
        if self.xp >= self.needMaxXp then
            self.stepEnable = true
            self.stepCon.bookCount2:setString("")
        else 
            self.stepCon.bookCount2:setString( string.format("(%d/%d)",self.xp,self.needMaxXp) )
        end
    end

    self.stepCon.btnStepUp:setVisible(self.stepEnable)
    self.stepCon.isFull:setVisible(self.stepEnable)
    self.stepCon.bookName2:setString("充满奥术能量")
    for i=1,4 do
        local boxView = self.stepList[i]
        boxView:setVisible(not self.stepEnable )
        if not self.stepEnable then
            local qualityXpInfo = findSoldierQualityXp(i)
            if qualityXpInfo ~= nil then
                local item = nil
                item = findItem( qualityXpInfo.coin.objid)
                if item then
                    local itemCache = self:getItemCache(item.id)
                    if itemCache == nil then
                        return
                    end

                    local leftCount = itemCache.packNum - itemCache.useNum
                    boxView.num:setString(leftCount)

                    local isRedShow = false
                    boxView.icon:setVisible(true)
                    local img = boxView.icon:getVirtualRenderer()
                    if leftCount <= 0 then
                        img:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
                    else
                        buttonDisable(boxView.icon,false)
                        img:setGLProgramState( ProgramMgr.createProgramState( 'normal' ) )
                        --isRedShow = data.teamLevel <= 5
                        isRedShow = SoldierData.enEatStepItem( self.sData ) 
                    end

                    local size = boxView.icon:getSize()
                    local off = cc.p(size.width - 8,size.height - 8)
                    setButtonPoint( boxView.icon, isRedShow ,off)

                    boxView.icon.item = item
                    boxView.icon.xpInfo = qualityXpInfo
                end
            end
        end
    end

    local isRedShow2 = SoldierData.enStepUp( self.sData )
    local size2 = self.stepCon.btnStepUp:getSize()
    local off2 = cc.p(size2.width - 8,size2.height - 8)
    setButtonPoint( self.stepCon.btnStepUp, isRedShow2 ,off2) 
    -- if self.jSoldierQuality then
    --     self.stepUpLay.level:setString(self.jSoldierQuality.lv_limit.."级")
    -- end
end

function SoldierInfo:getXp( )
    if self.sData then
        return self:getAddXp() + self.sData.quality_xp
    end
    return 0
end

--临时xp
function SoldierInfo:getAddXp( )
    local addXp = 0
    if self.sData then
        if self.cacheStep then
            for k,v in pairs( self.cacheStep ) do
                addXp = addXp + v.xp * v.useNum
            end
        end
    end
    return addXp
end

function SoldierInfo:getItemCache( itemId )
    if self.cacheStep then
        for k,v in pairs(self.cacheStep) do
            if itemId == v.itemId then
                return v
            end
        end
    end
    return nil
end


--提交英雄所吃的材料
function SoldierInfo:qStepItem( cue )
    if self.qSoldierGuid == nil or self.qSoldierGuid == 0 then
        return
    end

    if not self.sData.guid or self.sData.guid == 0 then
        return
    end

    if self.cacheStep then
        local qInfo = {}
        --英雄 first:英雄背包类型 second:英雄guid
        qInfo.first = const.kSoldierTypeCommon
        qInfo.second = self.qSoldierGuid
        local list = {}
        for k,v in pairs(self.cacheStep) do
            if v.useNum > 0 then
                local costItem = {}
                costItem.cate = 4
                costItem.objid = v.itemId
                costItem.val = v.useNum
                table.insert(list,costItem)
            end
        end

        if table.getn(list) > 0 and self.qSoldierGuid then
            self.qSoldierGuid = 0
            Command.run( 'soldier addxp', qInfo ,list)
        else
            if cue then
                TipsMgr.showError("请点击材料")
            end
        end
    end
end

--升阶相关缓存
function SoldierInfo:initCacheStep( )
    if self.sData == nil then
        return
    end

    self.cacheStep = {}
    for i=1,4 do
        local obj = {}
        local qualityXpInfo = findSoldierQualityXp(i)
        if qualityXpInfo then
            local item = nil
            item = findItem( qualityXpInfo.coin.objid)
            if item then
                local packNum = ItemData.getItemCount(item.id,const.kBagFuncCommon)
                obj.itemId = item.id
                obj.packNum = packNum
                obj.useNum = 0
                obj.xp = qualityXpInfo.quality_xp
                self.cacheStep[i] = obj
            end
        end
    end
end

function SoldierInfo:initFlyItem(itemId)
    local flyItem = UIFactory.getSprite(ItemData.getItemUrl(itemId),SceneMgr.getLayer(SceneMgr.LAYER_EFFECT),0,0,999)
    flyItem:setAnchorPoint(0.5,0.5)
    flyItem:setVisible(false)
    return flyItem
end

function SoldierInfo:flyItemAction( from_p ,itemId )
    local flyItem = self:initFlyItem(itemId)
    local function onComplete( )
        if self.flyItems then
            for k,v in pairs(self.flyItems) do
                v:stopAllActions()
                table.remove(self.flyItems,k)
                extRemoveChild(v)
                break
            end
            self:updateStep()
        end
    end

    flyItem:setTexture(ItemData.getItemUrl(itemId))
    flyItem:setVisible(true)
    flyItem:setOpacity(0)
    flyItem:setPosition(from_p)
    --local obj = SoldierData.stepItemTobj
    local obj = self.styleCon.style
    local to_p = toScenePoint( obj ,cc.p(obj:getPosition()) )
    SoundMgr.playUI("UI_rolelevel")
    a_flyto(flyItem,0.1,0.2, to_p,0.3,onComplete)
    table.insert(self.flyItems,flyItem)
end

function SoldierInfo:InductUseOneItem( )
    -- self.itemId = self.stepList[1].icon.item.id
    -- self:stepUseItemById(self.stepList[1].icon.item.id)
    self.itemId = 26
    self:stepUseItemById(self.itemId)
    self:qStepItem()
end

function SoldierInfo:clearDownTimer()
    if self.downTimer ~= nil  then
        TimerMgr.killTimer(self.downTimer)
        self.downTimer = nil
    end
end

function SoldierInfo:startDownTimer( flag )
    local function idle( )
        self.beginTime = self.beginTime+1
        if self.beginTime >= self.saveMax or self.saveMax < 0 then
            self.beginTime = 1
            self.longClick = true
            if self.flag == 1 then
                self:stepUseItemById(self.itemId)
            else
                self:stepBackItemById(self.itemId)
            end
            self.saveMax = self.saveMax -1
        end
    end

    self:clearDownTimer()
    self.flag = flag
    self.longClick = false
    self.beginTime  = 0
    self.saveMax = 12
    self.downTimer = TimerMgr.startTimer( idle, 0.01, false )
end

function SoldierInfo:stepUseItemById( itemId )
   --如果经验已满
    if self.stepEnable then
        TipsMgr.showError("经验已满,请升阶")
        self:clearDownTimer()
        return
    end

    self.qSoldierGuid = self.sData.guid
    for k,v in pairs(self.cacheStep) do
        if v.itemId == itemId then
            local leftCount = v.packNum  - v.useNum
            if leftCount <= 0 then
                self:clearDownTimer()
                return
            end

            self.xp = self:getXp()
            self.needMaxXp = self.jSoldierQuality.xp
            if self.xp >= self.needMaxXp then
                self:clearDownTimer()
                return
            end

            local from_p = toScenePoint( self.stepList[k].icon,cc.p(self.stepList[k].icon:getPosition()) )
            self:flyItemAction(from_p,self.itemId)
            v.useNum = v.useNum + 1
            break
        end
    end 
end

function SoldierInfo:stepBackItemById( itemId )
    if self.cacheStep == nil then
        return
    end

    for k,v in pairs( self.cacheStep ) do
        if v.itemId == itemId then
            if v.useNum > 0 then
                v.useNum = v.useNum - 1
                break
            else
                self:clearDownTimer()
            end
        end
    end
    self:updateStep()
end

function SoldierInfo:checkEatItem( )
    --按住不请求
    if self.isDownStepItem then
        return
    end

    if self.qualityFull then
        return
    end

    self:qStepItem(cue)
end

function SoldierInfo:changeByIndex( )
	extRemoveChild(self.skillLay)
	extRemoveChild(self.equipLay)
	extRemoveChild(self.arrScrollView)
	if self.index == 1 then
		  extAddChild(self,self.skillLay)
          self.skillLay:updateData()
	elseif self.index == 2 then
        self:initSubEquip()
		extAddChild(self,self.equipLay)
        self.equipLay:updateData()
	elseif self.index == 3 then
        self:initSubArr()
		extAddChild(self,self.arrScrollView)
        self.arrLay:updateData()
	end
end

function SoldierInfo:changeRightSub( )
	if(self.curBtn ~= nil) then
        self:setBtn(self.curBtn,true)
    end
    --变更子项
    self:changeByIndex()
    self:setBtn(self.btnList[self.index],false)
    self.curBtn = self.btnList[self.index]
end

function SoldierInfo:setBtn( btn,state)
	local index = btn.index
	local btnS = self.subBtnS
    if not state then
        --选中
        btn:setVisible(false)
		btnS:setVisible(true)

		btnS.icon:loadTexture(string.format("soldierd_subts%d.png",index), ccui.TextureResType.plistType)
		--btnS.mainBtnTitle:loadTexture (self.titleUrls[index] .. ".png", ccui.TextureResType.plistType)
    	--btnS.mainBtnIcon:loadTexture (self.iconUrl[index] .. ".png", cdcui.TextureResType.plistType)
    	local btnPosi = cc.p( btn:getPosition() )
    	local parentPosi = cc.p(self.subBtns:getPosition())
    	btnPosi.x = btnPosi.x - 6
    	btnPosi.y = btnPosi.y - 10
    	btnS:setPosition(parentPosi.x + btnPosi.x, parentPosi.y + btnPosi.y)
    else
    	btn:setVisible(true)
    end
end

function SoldierInfo:addPageBtnEvent( ... )
    local function goPre( sender )
        ActionMgr.save( 'UI', 'SoldierInfo click btnPre' )
        if not self.ReList then
            return
        end
        if self.pageIndex <= 1 then
            return
        end
        self.eatBookQ = false
        self.pageIndex = self.pageIndex -1 
        self:setData(self.ReList[self.pageIndex])
        self:setPageBtnState()
    end
    local function goNext( sender )
        ActionMgr.save( 'UI', 'SoldierInfo click btnNext' )
        if not self.ReList then
            return
        end
        if self.pageIndex >= self.dataLen then
            return
        end
        self.eatBookQ = false
        self.pageIndex = self.pageIndex + 1 
        self:setData(self.ReList[self.pageIndex])
        self:setPageBtnState()
    end

    self.btnPre = createScaleButton(self.pre.btnPre,false)
    self.btnPre:setVisible(false)
    buttonDisable(self.btnPre,false)
    self.btnPre:addTouchEnded(goPre)
    self.btnNext = createScaleButton(self.next.btnNext,false)
    self.btnNext:setVisible(false)
    buttonDisable(self.btnNext,false)
    self.btnNext:addTouchEnded(goNext)
end

function SoldierInfo:clearCtorTimer( ... )
    if self.ctorTimer ~= nil  then
        TimerMgr.killTimer(self.ctorTimer)
        self.ctorTimer = nil
    end
end

function SoldierInfo:ctorByTimer(  )
    if self.ctorTimer then
        return
    end

    local function idle( )
        if self.ctorTimerBegin == 1 then
            self:initStep()
        elseif self.ctorTimerBegin == 2 then
            self:initStar()
        elseif self.ctorTimerBegin == 3 then
            self:initSubSkill()
            self:initSubBtn()
            --self.index = self.subDefault
            --self:changeRightSub()
        elseif self.ctorTimerBegin == 4 then
            self:clearCtorTimer()
            self.skillLay:setData(self.sData,self.jSoldier,self.jSoldierQuality)
            self:updateData()
        end
        self.ctorTimerBegin = self.ctorTimerBegin + 1
    end
    self.ctorTimerBegin = 1
    self.ctorTimer = TimerMgr.startTimer( idle, 0.1, false )
end

function SoldierInfo:flushSData( guid )
    local newSData = SoldierData.getSoldier(guid)
    for k,v in pairs(self.ReList) do
        if v.guid == newSData.guid then
            self.ReList[k] = newSData
            return newSData
        end
    end
end

--初始化基础
function SoldierInfo:ctor()
    local function update( )
        self:setData(self.sData)
    end

    local function arrUpate()
        if self.arrLay then
            self.arrLay:updateData()
        end
    end

    local function eatBookQ()
        self.eatBookQ = true
        self:updateStepBook()
    end

    self.subDefault = 1
    if SoldierDefine.soldierLevel >= 20 then
        self.subDefault = 2
    end

    self.isUpRoleTopView = true --显示资源条
    self.stepEffect = SoldierStepUpEffect
	self:initStyle()
	self:initSelectedBtn()
	--self:initSubSkill()
	--self:initSubEquip()
	--self:initSubArr()
	--self:initSubBtn()
	--self.index = 1
	--self:changeRightSub()
    self.event_list = {}
    self.event_list[EventType.UserSoldierUpdate] = update
    self.event_list[EventType.UserItemUpdate] = update
    self.event_list[EventType.UserFightExtAbleUpdate] = update
    self.event_list[EventType.UserSoldierEquipExt] = arrUpate
    self.event_list[EventType.SoldierEatBookQ] = eatBookQ
    self:addPageBtnEvent()
    self.stepBg:loadTexture(SoldierDefine.prePath2 .. "soldierd_bg1.png",ccui.TextureResType.localType)

    local bottomLine = cc.Sprite:createWithSpriteFrameName("soldierd_bgbottom.png")
    self:addChild(bottomLine,555)
    bottomLine:setPosition(725,26)
    self:ctorByTimer()
end

function SoldierInfo:initStyle(  )
	local function playAction( )
        ActionMgr.save( 'UI', 'SoldierInfo click styleCon' )
        if self.styleView then
            self.styleView:playOne(false, "physical1")
        end
    end
    
	self.styleCon = getLayout(SoldierDefine.prePathI .. "styleCon.ExportJson")
	self:addChild(self.styleCon)
	self.qBg:loadTexture( SoldierDefine.prePath2 .. "soldiern_q1.png",ccui.TextureResType.localType)
	self.styleCon:setPosition( self.qBg:getPosition() )
	buttonDisable(self.styleCon,false)
	UIMgr.addTouchEnded( self.styleCon, playAction)
    effStepData.qLay = self.styleCon.quality
    effStepData.qBg = self.qBg
    effStepData.styleCon = self.styleCon
end

function SoldierInfo:onStepUp( sender,type )
    if not self.sData then
        return
    end

    if self.isDownStepItem then
        return
    end

    if self.qualityFull then
        TipsMgr.showError("恭喜您，已满阶")
        return
    end

    self:checkEatItem()
    -- if self.sData.quality > 1 then
    --     local lim = self.jSoldierQuality.lv_limit
    --     if data.level < lim then
    --         TipsMgr.showError(string.format("需要英雄%s级",self.jSoldierQuality.lv_limit ))
    --         return
    --     end
    -- end
    if self.bookCue ~= '' then
        TipsMgr.showError(self.bookCue)
        return
    end

    SoldierDefine.qStepQualify = self.sData.quality
    SoldierDefine.upPreFight = SoldierData.getFightValue(self.sData.guid,const.kAttrSoldier)
    --客户模拟弹出进阶UI
    if SoldierDefine.qStepQualify == 1 then
        SoldierData.virShowStepSuccessUI(self.sData)
    end
    
    local qInfo = {}
    --英雄 first:英雄背包类型 second:英雄guid
    qInfo.first = const.kSoldierTypeCommon
    qInfo.second = self.sData.guid
    Command.run( 'soldier qualityup', qInfo )
    self.eatBookQ = false
end

function SoldierInfo:stepItemTouchCancel( sender,type )
    self.isDownStepItem = false
    if self.qualityFull then
        TipsMgr.showError("满阶")
        return
    end

    self:clearDownTimer()
    if self.longClick then
        ActionMgr.save( 'UI', 'SoldierInfo longclick itemView_icon ' .. sender.item.id )
        self:checkEatItem()
        return
    end
    self:stepUseItemById(sender.item.id)
end

function SoldierInfo:addStepItemEvent( itemView )
    local function useStepUpItemBegin( sender,type )
        ActionMgr.save( 'UI', 'SoldierInfo click itemView_icon ' .. sender.item.id )
        if self.qualityFull then
            TipsMgr.showError("满阶")
            return
        end
        self.isDownStepItem = true
        self:startDownTimer(1)
        self.itemId = sender.item.id
    end

    local function useStepUpItemEnded( sender,type )
        self:stepItemTouchCancel(sender,type)
    end

    local function useStepUpItemCancel( sender,type )
        self:stepItemTouchCancel(sender,type)
    end

    buttonDisable(itemView.icon,false)
    UIMgr.addTouchBegin(itemView.icon,useStepUpItemBegin)
    UIMgr.addTouchEnded(itemView.icon,useStepUpItemEnded)
    UIMgr.addTouchCancel(itemView.icon,useStepUpItemCancel)
end

function SoldierInfo:addOpenSkillBookEvent( target )
    local function openSkillBookCom( sender )
        ActionMgr.save( 'UI', 'SoldierInfo click stepCon_nNotItem' )
        SkillBookMergeUI.showUI(sender.itemId,sender.guid)
    end
    createScaleButton(target,false)
    target:addTouchEnded(openSkillBookCom)
end

function SoldierInfo:addOpenSkillBookBgEvent( target )
    local function openSkillBookCom( sender )
        ActionMgr.save( 'UI', 'SoldierInfo click stepCon_nItemBg' )
        SkillBookMergeUI.showUI(sender.itemId,sender.guid)
    end
    createScaleButton(target,false)
    target:addTouchEnded(openSkillBookCom)
end

function SoldierInfo:initStep(  )
    if self.stepCon then
        return
    end

	local function onStepUp( sender,type )
        ActionMgr.save( 'UI', 'SoldierInfo click btnStepUp' )
        self:onStepUp(sender,type)
    end

	local view = getLayout(SoldierDefine.prePathI .. "stepCon.ExportJson")
	self.stepCon = view
    self.stepCon.btnStepUp:loadTexture(SoldierDefine.prePath2 .. "soldierd_stepbtn.png",ccui.TextureResType.localType )
	self:addChild(view)
	view:setPosition(self.stepBg:getPosition())
	view.btnStepUp:setVisible(false)
	self.btnStepUp = createScaleButton(view.btnStepUp)
    self.btnStepUp:addTouchEnded(onStepUp)
    buttonDisable(self.stepCon.nItemBg,false)
    self:addOpenSkillBookBgEvent(self.stepCon.nItemBg)
    buttonDisable(self.stepCon.nNotItem,false)
    self:addOpenSkillBookEvent(self.stepCon.nNotItem)

	self.stepList ={}
    for i=1,2 do
		for j=1,2 do
			local index = (i-1) * 2 + j
            --LogMgr.debug( "stepListstepList" .. index )
		    local itemView = getLayout(SoldierDefine.prePathI .. "stepItem.ExportJson")
            itemView:setVisible(false)
		    view:addChild(itemView)
		    itemView:setPosition( 8 + (j - 1) * 140 , 169 - ( i * 83 ) )
			local url = SoldierDefine.prePath2 .. "soldier_stepitem".. index .. ".png"
			itemView.icon:loadTexture(url, ccui.TextureResType.localType)
			table.insert(self.stepList,itemView)
            self:addStepItemEvent(itemView)
			--local img = itemView.icon:getVirtualRenderer()
			--img:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
		end
	end
end

function SoldierInfo:onLevelUp( sender )
    local sData = self.sData
    if sData == nil then
        return 
    end

    local jLvInfo = findSoldierLv(sData.level)
    local teamLevel = gameData.getSimpleDataByKey("team_level")
    local jLevelBaseInfo = findLevel(teamLevel)

    if not jLvInfo or not jLevelBaseInfo then
        return
    end

    if sData.level >= jLevelBaseInfo.soldier_lv then
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
    SoldierData.lvUpNeed = needNum
    local qInfo = {}
    --英雄 first:英雄背包类型 second:英雄guid
    qInfo.first = const.kSoldierTypeCommon
    qInfo.second = sData.guid
    Command.run( 'soldier soldierLvUp', qInfo )
end

function SoldierInfo:lvStartDownTimer( flag )
    local function idle( )
        self.lvBeginTime = self.lvBeginTime+1
        if self.lvBeginTime >= self.lvSaveMax or self.lvSaveMax < 0 then
            self.lvBeginTime = 1
            self.lvLongClick = true
            self:onLevelUp(self.levelUpSender)
            self.lvSaveMax = self.lvSaveMax -1
        end
    end

    self:lvClearDownTimer()
    self.lvLongClick = false
    self.lvBeginTime  = 0
    self.lvSaveMax = 12 + 6
    self.lvDownTimer = TimerMgr.startTimer( idle, 0.01, false )
end

function SoldierInfo:lvClearDownTimer()
    if self.lvDownTimer ~= nil  then
        TimerMgr.killTimer(self.lvDownTimer)
        self.lvDownTimer = nil
    end
end

function SoldierInfo:addLevelUpEvent( target )
    --长按
    local function levelUpBegin( sender,type )
        ActionMgr.save( 'UI', 'SoldierInfo click starCon_more' )
        self.levelUpSender = sender
        self:lvStartDownTimer()
    end

    local function levelUpCancel( sender,type )
        self:lvClearDownTimer()
        if self.lvLongClick then
            ActionMgr.save( 'UI', 'SoldierInfo longclick starCon_more' )
            self:onLevelUp(sender)
            return
        end
        self:onLevelUp(sender)
    end

    --UIMgr.addTouchEnded(target, onLevelUp)
    createScaleButton(target,true)
    target:addTouchBegan(levelUpBegin)
    target:addTouchEnded(levelUpCancel)
    target:addTouchCancel(levelUpCancel)
end

function SoldierInfo:initStar(  )
    if self.starCon then
        return
    end
     --升星
    local function onStarUp(sender, type)
        ActionMgr.save( 'UI', 'SoldierInfo click starCon_btnStarUp' )
        if self.sData == nil or not self.jStarInfo then
            return
        end

        if self.starUpCost == nil then
            return
        end

        if self.sData.star == 6 then
            TipsMgr.showError("该英雄星级已满")
            return
        end

        if (CoinData.checkLackCoin(const.kCoinItem, self.starUpCost.second, self.starUpCost.first)) then
            return
        end

        local needMoney = self.jStarInfo.need_money.val
        local function okFun()
            ActionMgr.save( 'UI', 'SoldierInfo click showMsgBox_ok' )
            if (CoinData.checkLackCoin(const.kCoinMoney, needMoney, 0)) then
                return
            end
            SoldierDefine.upPreFight = SoldierData.getFightValue(self.sData.guid,const.kAttrSoldier)
            local qInfo = {}
            --英雄 first:英雄背包类型 second:英雄guid
            qInfo.first = const.kSoldierTypeCommon
            qInfo.second = self.sData.guid
            Command.run( 'soldier starup', qInfo )
        end
        showMsgBox(string.format("[font=ZH_5]是否消耗[font=ZH_3]%s[font=ZH_5]金币将英雄升至[font=ZH_3]%s[font=ZH_5]星？",needMoney,self.sData.star+1), okFun, function() end)
    end

	self.starCon= getLayout(SoldierDefine.prePathI .. "starCon.ExportJson")
	self:addChild(self.starCon)
	self.starCon:setPosition( self.starBg:getPosition() )

    buttonDisable(self.starCon.more,false)
    self:addLevelUpEvent(self.starCon.more)

    local progressLay = self.starCon.progress
    buttonDisable(self.starCon.btnStarUp,false)
    createScaleButton(self.starCon.btnStarUp)
    self.starCon.btnStarUp:addTouchEnded(onStarUp)
    addOutline(progressLay.levelV_4,cc.c4b(0x18, 0x32, 0x14,255),1)
    --addOutline(progressLay.levelV_4,cc.c4b(0x6b,0x2c,0x08,255),1)
end

--按钮初始化
function SoldierInfo:initSubBtn( )
    local function btnFunc(sender,type)
        ActionMgr.save( 'UI', 'SoldierInfo click subBtn_obj' .. sender.index )
    	if type ~= ccui.TouchEventType.ended then
	        return
	    end

        self.index = sender.index
        self:changeRightSub()
    end
 
 	self.btnList = {}
    for i=1,3 do
        local offX =  5 + 113 * ( i -1 )
        local obj = getLayout(SoldierDefine.prePathI .. "subBtn.ExportJson")
        self.subBtns:addChild(obj)
        obj:setPosition(offX,4)
        self.btnList[i]  = obj
        obj.icon:loadTexture(string.format("soldierd_subt%d.png",i), ccui.TextureResType.plistType )
        obj.index = i
        createScaleButton(obj,false)
    	obj:addTouchEnded(btnFunc)
	end

	self.index = self.subDefault
	self:changeRightSub()
end

function SoldierInfo:initSelectedBtn( )
	self.subBtnS = getLayout(SoldierDefine.prePathI .. "subBtns.ExportJson")
	self:addChild(self.subBtnS,5)
	self.subBtnS:setVisible(false)
end

function SoldierInfo:initSubSkill( )
	self.skillLay = SoldierInfoSkill.new()
	self.skillLay:retain()
	self.skillLay:setPosition(self.rightBg:getPosition())
    effStepData.skillLay = self.skillLay
end

function SoldierInfo:initSubEquip( )
    if self.equipLay then
        return
    end
	self.equipLay = SoldierInfoEquip.new()
	self.equipLay:retain()
	self.equipLay:setPosition(self.rightBg:getPosition())
    if self.equipLay and self.sData then
       self.equipLay:setData(self.sData,self.jSoldier)
    end
end

function SoldierInfo:initSubArr( )
    if self.arrLay then
        return
    end

	self.arrLay = SoldierInfoArr.new()
    self.arrLay:retain()
    self.arrScrollView = ccui.ScrollView:create()
    --self.arrScrollView:setTouchEnabled(true)
    self.arrScrollView:setSize(cc.size(364, 390)) 
    self.arrScrollView:retain() 
    self.arrScrollView:setPosition(self.rightBg:getPosition())
    self:setScrollViewContent()
    if self.arrLay and self.sData then
       self.arrLay:setData(self.sData,self.jSoldier,self.jLvInfo)
    end
end

function SoldierInfo:changeXp( curXp )
    if self.sData and self.jSoldierQuality then
        if self.needMaxXp  and self.needMaxXp ~= 0 then
            if curXp >= self.needMaxXp then
                EventMgr.dispatch( EventType.SoldierStepUp )
            end
            self.stepEffect:initXpPercent(self.sData.quality,curXp/self.needMaxXp)
        else
            self.stepEffect:initXpPercent(0,0)
        end
    else
        self.stepEffect:initXpPercent(0,0)
    end
end

function SoldierInfo:setScrollViewContent( )
    local scSize = self.arrScrollView:getSize()
    local inner = self.arrScrollView:getInnerContainer()
    self.arrScrollView:removeAllChildren()
    local innerSize = self.arrLay:gSize() 
    self.arrScrollView:setInnerContainerSize(innerSize) 
    self.arrScrollView:addChild(self.arrLay)
end

--吃书 -- 引导
function SoldierInfo:inductEatBook( itemId, soldierId )
    -- if self.bookId and self.sData then
        local soldier = SoldierData.getSoldierBySId( soldierId )
        if soldier then
            SkillBookMergeUI.showUI(itemId, soldier.guid )
        end
    -- end
    -- return nil
end

function SoldierInfo:GetBtnStepUp( soldierId )
    local soldier = SoldierData.getSoldierBySId( soldierId ) 
    if soldier then
        local userItem = ItemData.getSoldierSkillBook(soldier.guid) 
        if userItem then
            return self.btnStepUp
        end
    end
    return nil
end
