
local prePath = "image/ui/CopyUI/"
ExpBar = class("ExpBar", function() 
    return getLayout(prePath .. "CopyExpBar/CopyExpBar.ExportJson") 
end)

local oldLevel = 0
local function onSimpleChange(evt)
    local level = gameData.getSimpleDataByKey("team_level")
    if level ~= oldLevel then --升级成功
        oldLevel = level
        max_xp = findLevel(oldLevel).team_xp
    end
    local xp = gameData.getSimpleDataByKey("team_xp")
    if xp >= max_xp then
        max_xp = 4294967295 --uint.max_value, 防止重复升级
        local jNextLevel = findLevel(level + 1)
        if jNextLevel then
            local tid = nil
            tid = TimerMgr.startTimer(function() Command.run('team levelup') TimerMgr.killTimer(tid) end, 0.3)
        end
    end
end

function ExpBar:ctor()
    if not self.tid then
        self.tid = TimerMgr.startTimer(function() 
                TimerMgr.killTimer(self.tid)
                self.tid = nil
                local view = PopMgr.getWindow("TeamUpgradeUI")
                if view and view:isShow() then
                    return
                end
                EventMgr.dispatch(EventType.expBarPercent) 
            end, 1.6)
    end
end

function ExpBar:create(data)
    local view = ExpBar.new()

    local old_exp = data.old_value -- 起始经验
    local sum_exp = gameData.getSimpleDataByKey('team_xp') -- 目前的总经验
    local splus_exp = sum_exp - old_exp -- 增加的经验
    local team_level = gameData.getSimpleDataByKey('team_level')
    local max_exp = findLevel(team_level).team_xp
    local percent = old_exp/max_exp*100

    view:initExpBar(percent, team_level)
    view:showStyle(team_level, sum_exp, splus_exp)
    -- view:progressAction(team_level, sum_exp, splus_exp)

    return view
end

function ExpBar:showStyle(team_level, sum_exp, splus_exp) --逐渐淡入
    setUIFade(self, cc.FadeIn, 0.5) 
    onSimpleChange()
    local function callback()
        self.left:setVisible(true)
        self.progress_bar:setVisible(false)
        self:progressAction(team_level, sum_exp, splus_exp)
    end
    performWithDelay(self, callback, 0.5)
end

function ExpBar:initExpBar(percent, lev)
    lev = lev or gameData.getSimpleDataByKey('team_level')
    self.left = self:createSpriteProgress(percent)
    self.progress_bar:setPercent(percent)
    self.pre_lev:setString('' .. lev)
    self.after_lev:setString('' .. lev + 1)
    setUiOpacity(self, 0) 
end

function ExpBar:createSpriteProgress(percent)
    local left = UIFactory.getLeftProgressBar("copy_exp_progress.png", self, 228, 59)
    left:setPercentage(percent)
    left:setVisible(false)

    return left
end

function ExpBar:progressAction(level, sumExp, val)
    local jLevel = findLevel(level)
    if not jLevel then
        return
    end
    local maxExp = jLevel.team_xp
    local preExp = sumExp - val
    self.pre_lev:setString('' .. level)
    self.after_lev:setString('' .. level + 1)
    if sumExp > maxExp then -- 需要升级
        LogMgr.debug("超过经验值上限，升级>>>>>>")
        local function callfunc() 
            LogMgr.debug("--------重置进度条坐标--------")
            self.left:setPercentage(0)
            sumExp = sumExp - maxExp
            val = sumExp
            self:progressAction(level + 1, sumExp, val)
        end
        local prePercent = preExp/maxExp*100
        self:setExpPercent(prePercent, 100, callfunc)
    else
        local prePercent = preExp/maxExp*100
        local afterPercent = sumExp/maxExp*100
        LogMgr.debug("没有超过上限>>>>>>>>")
        local function callfunc()
            self:closeStyle(afterPercent)
        end
        self:setExpPercent(prePercent, afterPercent, callfunc)
    end
end

function ExpBar:setExpPercent(pre, after, callfunc)
    local function actionCom()
        if callfunc then 
            callfunc() 
        end
    end

    LogMgr.debug('设置精度条>>>')
    LogMgr.debug('pre = ', pre, 'after', after)
    after = math.min(100, after)
    local progress = cc.ProgressFromTo:create(0.3, pre, after) 
    self.left:runAction(progress)
    performWithDelay(self, actionCom, 0.4)
end

function ExpBar:closeStyle(percent)
    local hideUI = cc.CallFunc:create(function() 
         if not SceneMgr.isSceneName( 'copy' ) then
             LogMgr.debug('派发显示升级UI事件>>>>>>>')
             if self.tid then
                TimerMgr.killTimer(self.tid)
                self.tid = nil
             end
             EventMgr.dispatch(EventType.expBarPercent)
         end
        self.left:setVisible(false)
        self.left:removeFromParent()
        self.left = nil
        self.progress_bar:setVisible(true)
        self.progress_bar:setPercent(percent)
        setUIFade(self, cc.FadeOut, 0.5)
    end)
    local delayout = cc.DelayTime:create(0.6)
    self:runAction(cc.Sequence:create(hideUI, delayout, cc.RemoveSelf:create()))
end

local function showExpBarFunc(data)
    local exp = data.val
    local sum = data.sumExp
    local level = data.level
    -- local expBar = ExpBar:createCopyExpBar(level, sum, exp)
    local msg = {old_value = sum - exp}
    local expBar = ExpBar:create(msg)
    expBar:setTouchEnabled(false)
    expBar:setAnchorPoint(cc.p(0.5, 0.5))
    expBar:setPosition(visibleSize.width/2, visibleSize.height/2 + 200)
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    layer:addChild(expBar)

    -- expBar:updateCopyExpData(level, sum, exp)
end

local exp_msg = nil
local function expGet(data)
    if SceneMgr.isSceneName('copy') then
        onSimpleChange()
        return
    end
    if data.coin.cate == trans.const.kCoinTeamXp then
        if data.set_type == 1 then -- 刪除不处理
            local old_exp = data.old_value
            local team_level = gameData.getSimpleDataByKey('team_level')
            local sum_exp = gameData.getSimpleDataByKey('team_xp')
            exp_msg = data

            if true == FightDataMgr:fighting() then
                -- 判断是否在战队场景中
                LogMgr.debug("战斗场景中...")
                local function onSceneShow(scene)
                    if scene ~= "fight" then
                        EventMgr.removeListener(EventType.SceneShow, onSceneShow)
                        if exp_msg then
                            expGet(exp_msg) --重新显示
                        end
                    end
                end
                EventMgr.addListener(EventType.SceneShow, onSceneShow)
                return
            end
            exp_msg = nil
            local msg = {val = sum_exp-old_exp, sumExp = sum_exp, level = team_level}
            showExpBarFunc(msg)
        end
    end
end
-- EventMgr.addListener(EventType.showExpBarUI, showExpBarFunc)
EventMgr.addListener(EventType.UserCoinUpdate, expGet)