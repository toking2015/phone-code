
--十字军试炼玩法规则
TombRuleUI = createUIClass("TombRuleUI", "image/ui/RuleUI/ArenaRuleUI.ExportJson", PopWayMgr.SMALLTOBIG)
TombRuleUIType = {
   Rule = 1,
   Other = 2 
}
local ruledata = nil
local issc = true 
function TombRuleUI:ctor()
--    local list = {
--        "[font=JJ_1]1、挑战与奖励规则：",
--        "[font=JJ_2]试炼分为4种，开放的试炼可以挑战两次，每次消耗15体力；两次挑战结束后根据试炼成绩领奖 ",
--        "[font=JJ_1]2、成绩统计：",
--        "[font=JJ_2]不同的试炼类型对应不同的统计方法，具体如下：",
--        "[font=JJ_2]生存试炼——统计生存的回合数，推荐板甲英雄和土系图腾",
--        "[font=JJ_2]勇气试炼——统计造成伤害数量，推荐锁甲英雄和火系图腾",
--        "[font=JJ_2]敏捷试炼——统计累计出手和闪避次数，推荐皮甲英雄和风",
--        "[font=JJ_2]系图腾",
--        "[font=JJ_2]智力试炼——统计治疗量和伤害量，推荐布甲英雄和水系图腾",
--        "[font=JJ_1]奖励说明",
--        "[font=JJ_2]生存试炼——奖励土系充能石和板甲英雄灵魂石",
--        "[font=JJ_2]勇气试炼——奖励火系充能石和锁甲英雄灵魂石",
--        "[font=JJ_2]敏捷试炼——奖励风系充能石和皮甲英雄灵魂石",
--        "[font=JJ_2]智力试炼——奖励水系充能石和布甲英雄灵魂石"
--    }
--    TipsMgr.showRules(list, TrialMgr.prePath .. "TrialMainUI/TrialRuleTitle.png", true)
  self.name:loadTexture(TrialMgr.prePath .. "TrialMainUI/TrialRuleTitle.png", ccui.TextureResType.localType)
--  self:setContentSize(cc.size(516, 400))
end 

function TombRuleUI:onShow()
    local data = ruledata--到时根据需要调用data
    local scrollview = self.scrollview -- scrollview 在这里
    local name = self.name --标题更改在这里
    
    local size = self.scrollview:getInnerContainer():getSize()
    local pw = size.width
    local ph = size.height + 30
    
    local str = "[font=JJ_2]1、大墓地一共有5个区域，每个区域5关，在大墓地重置时，[br] "
     .. "[font=JJ_2]区域随机产生[br] "
     .. "[font=JJ_2]2、大墓地战斗消耗的血量不会回复，死亡的英雄将不能继[br]"
     .. "[font=JJ_2]续上阵[br]"
     .. "[font=JJ_2]3、通关大墓地关卡可以获得海量金币和大量神符[br]"
     .. "[font=JJ_2]4、第5、10、15、20、25关的通关宝箱产出勇气勋章，可以[br]"
     .. "[font=JJ_2]在勇气商店中购买道具[br]"
     .. "[font=JJ_2]5、大墓地每天可以重置1次[br]"

    self.scrollview:setInnerContainerSize(cc.size(pw, ph))
    if issc == false then 
       RichText:addMultiLine(str, prePath, self.vector)
    else
       RichText:addMultiLine(str, prePath, self.scrollview:getInnerContainer())
    end 
end 

function TombRuleUI:onClose()
 
end 
