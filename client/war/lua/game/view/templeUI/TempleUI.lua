--wyx
require("lua/game/view/templeUI/TempleCollect.lua")
require("lua/game/view/templeUI/TempleRune.lua")
require("lua/game/view/templeUI/TempleRuneBagUI.lua")
require("lua/game/view/templeUI/TempleAttrSummary.lua")
require("lua/game/view/templeUI/TempleScoreDetail.lua")
require("lua/game/view/templeUI/UpgradeRuneUI.lua")
require("lua/game/view/templeUI/GetTotemTipsUI.lua")

local prePath = "image/ui/TempleUI/"
local url = prePath .. "TempleBgUI.ExportJson"
TempleUI = createUIClass("TempleUI", url, PopWayMgr.SMALLTOBIG )

function TempleUI:ctor( ... )
	self.isUpRoleTopView = true
	self.selectIndex = 1
	--self.scrollView:setInnerContainerSize(cc.size(194, 500))
	self.collect = TempleCollect:createView()
	self.panel:addChild(self.collect)
	self.rune = TempleRune:createView()
	self.panel:addChild(self.rune)
	self.rune:setVisible(false)
	-- TempleData.setCurFightValue(0)
	TempleData.setCurFightValue(UserData.getFightValue())
	self.title:setLocalZOrder(3)

	self.btnList = {self.btn_1, self.btn_2}
    local subMenuNames = {"btn_text_collect_", "btn_text_rune_"}
    local function btnListHandler(index)
    	if index == 2  and not GameData.checkLevel( TempleData.getRuneOpenLevel() ) then
			TipsMgr.showError( '神符功能'..TempleData.getRuneOpenLevel()..'级开放!' )
			return true
		end
		self.selectIndex = index
		self:updateData()
    end
    local function btnHandler( ... )
    	-- Command.run("ui show","GetTotemTipsUI",PopUpType.SPECIAL)
    	Command.run("ui show","TempleScoreDetail",PopUpType.SPECIAL)
        -- local win = PopMgr.getWindow('TempleRuneBagUI')
    end
    UIFactory.initSubMenu(self.btnList , subMenuNames, btnListHandler, 1, self.selectIndex )
    createScaleButton(self.look)
	self.look:addTouchEnded(btnHandler)
end

function TempleUI:delayInit( ... )
	self.head_figure = UIFactory.getTitleTriangle(self.panel, 1)
end

function TempleUI:onShow()
	-- self:updateData()
	self.collect:onShow()
	Command.run("temple info")
	EventMgr.addListener(EventType.TempleInfo,self.updateData,self)
	EventMgr.addListener(EventType.TempleGroupLevelUp,self.updateData,self)
end

function TempleUI:onClose()
	EventMgr.removeListener(EventType.TempleInfo,self.updateData)
	EventMgr.removeListener(EventType.TempleGroupLevelUp,self.updateData)
	self.collect:onClose()
end

function TempleUI:dispose( ... )
	self:removeFightEffect()
end

function TempleUI:updateData( ... )
	self:playBlessFightAddEffect()
	self.score_txt:setString(TempleData.getRewardScore(1))
	if self.selectIndex == 1 then
		self.collect:setVisible(true)
		self.rune:setVisible(false)
		self.collect:updateData()
		self.collect:updateNameList()
	else 
		self.collect:setVisible(false)
		self.rune:setVisible(true)
		self.rune:onShow()
	end
	-- setButtonPoint(self.look, true, cc.p(30,30), 200)
	setButtonPoint(self.look, TempleData.checkIsCanTakeReward(), cc.p(30,30), 200)
end

--强化战力效果  战力+xxx
function TempleUI:playBlessFightAddEffect()
	local curFight = UserData.getFightValue()
	local mFight = TempleData.getCurFightValue()
    local dFight = curFight - mFight
    if dFight > 0 then
        local centerPoint = cc.p(580,178) 
        TipsMgr.showFightAdd(centerPoint,self,dFight)
        TempleData.setCurFightValue(curFight)
    end
end

function TempleUI:removeFightEffect( ... )
	TipsMgr.hideFightAdd()
    -- if self.fEffectCon then
    --     local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    --     self.fEffectCon:removeAllChildren()
    --     self.fEffectCon:removeFromParent()
    --     layer.fEffectCon = nil
    --     self.fEffectCon = nil
    -- end
end


