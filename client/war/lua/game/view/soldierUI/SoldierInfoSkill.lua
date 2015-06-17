local effStepData = SoldierData.effStepData
SoldierInfoSkill = createLayoutClass('SoldierInfo', cc.Node)
function SoldierInfoSkill:onShow()
--技能没有激活的时候，文字显示为“英雄进阶到X色激活”
-- 1、每回合自动释放
-- 2、被图腾觉醒后释放
-- 3、怒气满后自动释放
-- 4、被动技能，激活后永久有效
-- 5、被动技能，激活后永久有效
-- 6、被动技能，激活后永久有效

-- 普通
-- 觉醒
-- 怒气
-- 被动
-- 被动
-- 被动
end

function SoldierInfoSkill:onClose()
    --UIMgr.registerScriptHandler(target, call, eventType, bubbles)
end

function SoldierInfoSkill:updateData()
	if not self.jSoldier or not self.jSoldierQuality then
		return
	end
	self.activeKills = self.jSoldier.skills  -- 主动技能
    self.passiveKills = self.jSoldier.odds   --被动技能
    self.passLen = table.getn(self.passiveKills)
    self.actLen = table.getn( self.activeKills)
    self.openCount = self.jSoldierQuality.skill_active
    self.oldPercent = self.percent
    self.tableView:reloadData()
    --local h = (100 - self.percent)/100 * self.ScrollOffH
    if self.oldPercent then
        local h = self.oldPercent/100 * self.ScrollOffH
        self.tableView:setContentOffset( cc.p(0, h) )
    end
end

function SoldierInfoSkill:setData( _sData,_jSoldier,_jSoldierQuality)
	self.sData = _sData
	self.jSoldier = _jSoldier
	self.jSoldierQuality = _jSoldierQuality
	self:updateData()
end

function SoldierInfoSkill:dispose( )
	
end

function SoldierInfoSkill:ctor( )
    self.labelArr = {"每回合自动释放","被图腾觉醒后释放","怒气满后自动释放","被动技能，激活后永久有效","被动技能，激活后永久有效","被动技能，激活后永久有效"}
    self.skillTypes = {1,2,3,4,4,4}
	self:initTableView()
end

function SoldierInfoSkill:updateItemData(j,content)
	if not self.jSoldier or not self.jSoldierQuality then
		return
	end

	if self.openCount == nil then
		return
	end

    content.bg.oddInfo = nil
    content.bg.skillInfo = nil
    local skillLv = 1
    local skillId = 0
    local openColorName = ""
    local openColor = nil
    --[[主动技能]]
    if j <= 3 then
        self:setGrow(content,true)
        openColorName = "绿色"
        openColor = QualityData.getColor(2)
        if j == 3 then
            --2阶开发第三个技能
            if self.sData.quality >= 2 then
                if self.sData.quality == 2 then
                    if SoldierDefine.stepUp then
                        --开放技能
                        effStepData.skillOpen = skillView
                    else
                        openColorName,openColor = "",nil
                        self:setGrow(content,false)
                    end
                else
                    openColorName,openColor = "",nil
                    self:setGrow(content,false)
                end
            end
        else
            openColorName,openColor = "",nil
            self:setGrow(content,false)
        end

        local dataIndex = j
        --调换2，3数据
        if j == 2 then
            dataIndex = 3
        elseif j == 3 then
            dataIndex = 2
        end
        skillId = self.activeKills[dataIndex].first
        if self.sData then
            skillLv = SoldierData.getLevel( self.sData.skill_list,skillId )
        end

        local skillInfo = findSkill( skillId,skillLv)
        self:setActSKillInfo(content,skillInfo)
        content.desc:setString(self.labelArr[j])
        content.typeIcon:loadTexture(string.format('soldierd_skillt%d.png',self.skillTypes[j]),ccui.TextureResType.plistType)
    else
        --[[被动技能]]
        local index = j - 3
        if index <= self.passLen then
            self:setGrow(content,true)
            openColorName,openColor = SoldierData.SoldierQualityOpenNeed(index)
            if index <= self.openCount then
                --已经开放
                if index == self.openCount then
                    local preQ = findSoldierQuality( self.sData.quality - 1 )
                    local actSkill = 0
                    if preQ and self.jSoldierQuality then
                        actSkill = preQ.skill_active - self.jSoldierQuality.skill_active
                    end
                    --新开被动技能
                    if SoldierDefine.stepUp and actSkill > 0 then
                        effStepData.skillOpen = content
                    else
                        openColorName,openColor = "",nil
                        self:setGrow(content,false)
                    end 
                else
                    openColorName,openColor = "",nil
                    self:setGrow(content,false) 
                end
            end
            skillId = self.passiveKills[index].first
            if self.sData then
                skillLv = SoldierData.getLevel( self.sData.skill_list,skillId )
            end
            local oddInfo = findOdd(skillId,skillLv)
            self:setPassSKillInfo(content,oddInfo)
            content.desc:setString(self.labelArr[j])
            content.typeIcon:loadTexture(string.format('soldierd_skillt%d.png',self.skillTypes[j]),ccui.TextureResType.plistType)
        end
    end

    content.bg.openColorName = openColorName
    if openColorName ~= "" then
        content.desc:setVisible(false)
        content.descNotOpen:setVisible(true)
        content.descNotOpen.txt1:setString(openColorName)
        content.descNotOpen.txt1:setColor(openColor)
    else
        content.desc:setVisible(true)
        content.descNotOpen:setVisible(false)
    end
end
function SoldierInfoSkill:setGrow(skillView, b)
    if b then
        --未开放
        --skillView.bgNotOpen:setVisible(true)
        --skillView.bgOpen:setVisible(false)
        --名字灰色
        --skillView.skillName:setColor(cc.c3b(159, 159, 159))
        local img = skillView.skillIcon:getVirtualRenderer()
        img:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
        --local img2 = skillView.kuang:getVirtualRenderer()
        --img2:setGLProgramState( ProgramMgr.createProgramState( 'gray' ) )
    else
        --已经开放
        --skillView.bgNotOpen:setVisible(false)
        --skillView.bgOpen:setVisible(true)
        --skillView.skillName:setColor(cc.c3b(0x60, 0x26, 0x1D))
        local img = skillView.skillIcon:getVirtualRenderer()
        -- 还原
        img:setGLProgramState( ProgramMgr.createProgramState( 'normal' ) )

        --local img2 = skillView.kuang:getVirtualRenderer()
        --img2:setGLProgramState( ProgramMgr.createProgramState( 'normal' ) )
    end
end

function SoldierInfoSkill:setActSKillInfo( skillView, skillInfo )
    if skillInfo ~= nil then
        --技能图标
        local skillUrl = SkillData.killUrlByJson(skillInfo)
        skillView.skillIcon:loadTexture( skillUrl, ccui.TextureResType.localType )
        skillView.name:setString(skillInfo.name)
        --skillView.desc:setString(skillInfo.desc)
        skillView.bg.skillInfo = skillInfo
        --skillView.bgNotOpen.skillInfo = skillInfo
    end
end

function SoldierInfoSkill:setPassSKillInfo( skillView, oddInfo )
    if oddInfo ~= nil then
        --技能图标
        local skillUrl = SkillData.oddUrlByJson(oddInfo)
        skillView.skillIcon:loadTexture( skillUrl, ccui.TextureResType.localType )
        skillView.name:setString(oddInfo.name)
        --skillView.desc:setString(oddInfo.description)
        skillView.bg.oddInfo = oddInfo
        --skillView.bgNotOpen.oddInfo = oddInfo
    end
end

function SoldierInfoSkill:addTipEvent(target)
	local function onBegin( touch, event )
        ActionMgr.save( 'UI', 'SoldierInfoSkill click content_bg' )
        local sender = event:getCurrentTarget()
        if sender == nil then
            return
        end
        local pos = touch:getLocation()
        local exData = {}
        if sender.openColorName ~= "" then
            exData.cue = "[br]" .. fontNameString("TIP_R") .. string.format("进阶到%s之后获得", sender.openColorName)
        end

        if sender.skillInfo then
            TipsMgr.showTips(pos, TipsMgr.TYPE_SKILL, sender.skillInfo,exData)
        end
        if sender.oddInfo then
            TipsMgr.showTips(pos, TipsMgr.TYPE_ODD, sender.oddInfo,exData)
        end
    end
    UIMgr.registerScriptHandler(target, onBegin, cc.Handler.EVENT_TOUCH_BEGAN, true)
    --UIMgr.addTouchBegin(target,onBegin)
end
function SoldierInfoSkill:initTableView()
	self.tcellHeigth = 100
	self.tcellWidth = 350

	local function scrollViewDidScroll(view)
        self.percent = math.ceil( self.tableView:getContentOffset().y / self.ScrollOffH * 100)
    end

    local function scrollViewDidZoom(view)
       
    end

    local function tableCellTouched(view,cell)
        if view:isTouchMoved() then
            return
        end

        --local touchIndex = cell:getIdx() + 1
    end

    local function tableCellAtIndex(view, idx)
	    local index = idx + 1
	    local cell = view:dequeueCell()
	    local label = nil
	    local saveContent = nil
	    if nil == cell then
	        cell = cc.TableViewCell:new()
	        local content = getLayout(SoldierDefine.prePathI .. "skillItem.ExportJson")
            content.bg:loadTexture(SoldierDefine.prePath2 .. "soldier_skillbg.png",ccui.TextureResType.localType)
	        buttonDisable(content,true)
	        content.descNotOpen:setVisible(false)
            content:setAnchorPoint(cc.p(0,0))
	        content:setPosition(cc.p(0, 0))
	        content:setTag(1)
	        cell:addChild(content)
	        saveContent = content
	        buttonDisable(content.bg,true)
	        self:addTipEvent(content.bg)
	    else
	        saveContent = cell:getChildByTag(1)
	    end

	    self:updateItemData(index,saveContent)
	    return cell
    end

    local function numberOfCellsInTableView(view)
     --    local dataLen = math.ceil(self.dataLen/2)
	    -- self.maxCeil = dataLen
	    -- return self.maxCeil
	    self.maxCeil = 6
        self.ScrollOffH = -(self.tcellHeigth * self.maxCeil - self.theigth + 10 )
	    return self.maxCeil
    end
    
    local function cellSizeForTable(view,idx) 
	    --宽高度很变态
	    return self.tcellHeigth,self.tcellWidth
    end

	self.tableView = cc.TableView:create(cc.size(350, 345 + 30 ))
    self.twidth = 350
    self.theigth = 345 + 30
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(7,10 )
   	self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView)
    self.tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL )
    self.tableView:registerScriptHandler( scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM )
    self.tableView:registerScriptHandler( tableCellTouched,cc.TABLECELL_TOUCHED )
    self.tableView:registerScriptHandler( cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX )
    self.tableView:registerScriptHandler( tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX )
    self.tableView:registerScriptHandler( numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    --self.tableView:reloadData()
end