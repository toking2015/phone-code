
--十字军试炼玩法规则
TrialRuleUI = createUIClass("TrialRuleUI", "image/ui/RuleUI/ArenaRuleUI.ExportJson", PopWayMgr.SMALLTOBIG)
TrialRuleUIType = {
   Rule = 1,
   Other = 2 
}
local ruledata = nil
local issc = true 
function TrialRuleUI:ctor()
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

function TrialRuleUI:onShow()
    local data = ruledata--到时根据需要调用data
    local scrollview = self.scrollview -- scrollview 在这里
    local name = self.name --标题更改在这里
    
    local size = self.scrollview:getInnerContainer():getSize()
    local pw = size.width
    local ph = size.height + 380
    
    local str = ''
    if not TrialMgr.currentTrial then
        str = "[font=JJ_1]1、挑战与奖励规则：[br]"
        str = str .. "[font=JJ_2]试炼分为4种，开放的试炼可以挑战两次；[br] "
        str = str .. "[font=JJ_2]两次挑战结束后根据试炼成绩领奖[br]"

        str = str .. "[font=JJ_1]2、成绩统计：[br]"
        str = str .. "[font=JJ_2]不同的试炼类型对应不同的统计方法，具体如下：[br]"
        str = str .. "[font=JJ_2]板甲试炼——参加该玩法，则所有板甲英雄造成的伤害结果[br]"
        str = str .. "[font=JJ_2]及治疗结果×10倍[br]"
        str = str .. "[font=JJ_2]锁甲试炼——参加该玩法，则所有锁甲英雄造成的伤害结果[br]"
        str = str .. "[font=JJ_2]及治疗结果×10倍[br]"
        str = str .. "[font=JJ_2]皮甲试炼——参加该玩法，则所有皮甲英雄造成的伤害结果[br]"
        str = str .. "[font=JJ_2]及治疗结果×10倍[br]"
        str = str .. "[font=JJ_2]布甲试炼——参加该玩法，则所有布甲英雄造成的伤害结果[br]"
        str = str .. "[font=JJ_2]及治疗结果×10倍[br]"
        
        str = str .. "[font=JJ_1]3、奖励说明：[br]"
        str = str .. "[font=JJ_2]板甲试炼——奖励土系充能石和板甲英雄灵魂石[br]"
        str = str .. "[font=JJ_2]锁甲试炼——奖励火系充能石和锁甲英雄灵魂石[br]"
        str = str .. "[font=JJ_2]皮甲试炼——奖励风系充能石和皮甲英雄灵魂石[br]"
        str = str .. "[font=JJ_2]布甲试炼——奖励水系充能石和布甲英雄灵魂石[br]"
    elseif 1 == TrialMgr.currentTrial.id then
        str = "[font=JJ_1]板甲试炼：[br]"
        str = str .. "[font=JJ_2]1、本玩法推荐使用板甲英雄和土系图腾[br]"
        str = str .. "[font=JJ_2]2、板甲英雄在本玩法中将获得10倍属性加成[br]"
        str = str .. "[font=JJ_2]3、本玩法可以挑战2次，根据2次战斗的总生存回合数获得[br]"
        str = str .. "[font=JJ_2]奖励[br]"
        str = str .. "[font=JJ_2]4、生存试炼结束后可以获得大量土系充能石等奖励[br]"
        ph = size.height - 20
    elseif 2 == TrialMgr.currentTrial.id then
        str = "[font=JJ_1]锁甲试炼：[br]"
        str = str .. "[font=JJ_2]1、本玩法推荐使用锁甲英雄和火系图腾[br]"
        str = str .. "[font=JJ_2]2、锁甲英雄在本玩法中将获得10倍属性加成[br]"
        str = str .. "[font=JJ_2]3、本玩法可以挑战2次，根据2次战斗的总杀怪数量获得奖[br]"
        str = str .. "[font=JJ_2]励[br]"
        str = str .. "[font=JJ_2]4、 试炼结束后可以获得大量火系充能石等奖励[br]"
        ph = size.height - 20
    elseif 3 == TrialMgr.currentTrial.id then
        str = "[font=JJ_1]皮甲试炼：[br]"
        str = str .. "[font=JJ_2]1、本玩法推荐使用皮甲英雄和风系图腾[br]"
        str = str .. "[font=JJ_2]2、皮甲英雄在本玩法中将获得10倍属性加成[br]"
        str = str .. "[font=JJ_2]3、本玩法可以挑战2次，根据2次战斗造成伤害的次数和闪[br]"
        str = str .. "[font=JJ_2]避次数获得奖励[br]"
        str = str .. "[font=JJ_2]4、试炼结束后可以获得大量风系充能石等奖励[br]"
        ph = size.height - 20
    elseif 4 == TrialMgr.currentTrial.id then
        str = "[font=JJ_1]布甲试炼：[br]"
        str = str .. "[font=JJ_2]1、本玩法推荐使用布甲英雄和水系图腾[br]"
        str = str .. "[font=JJ_2]2、布甲英雄在本玩法中将获得10倍属性加成[br]"
        str = str .. "[font=JJ_2]3、本玩法可以挑战2次，根据2次战斗造成伤害和治疗[br]"
        str = str .. "[font=JJ_2]总量获得奖励[br]"
        str = str .. "[font=JJ_2]4、试炼结束后可以获得大量水系充能石等奖励[br]"
        ph = size.height - 20
    end

    self.scrollview:setInnerContainerSize(cc.size(pw, ph))
    if issc == false then 
       RichText:addMultiLine(str, prePath, self.vector)
    else
       RichText:addMultiLine(str, prePath, self.scrollview:getInnerContainer())
    end 
end 

function TrialRuleUI:onClose()
 
end 
