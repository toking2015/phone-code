
local prePath = "image/ui/CopyUI/"
CopyExpBar = createUILayout("CopyExpBar", prePath .. "CopyExpBar/CopyExpBar.ExportJson")

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
            tid = TimerMgr.startTimer(function() Command.run('team levelup') TimerMgr.killTimer(tid) end, 0.5)
        end
    end
end

function CopyExpBar:createCopyExpBar(lev, sumExp, val)
    local view = CopyExpBar.new()
    view:setTouchEnabled(false)

    view:initExpBar(lev, sumExp, val)

    return view
end

function CopyExpBar:initExpBar(lev, sum, val)
    local preExp = sum - val
    local maxExp = findLevel(lev).team_xp
    local percent = preExp/maxExp * 100

    if lev >= MainScene.MaxTeamLevel then
        LogMgr.debug("达到战队最大等级")
        self.progress_bar:setPercent(100)
    else
        self.progress_bar:setPercent(percent)
        setUiOpacity(self, 0) 
    end
    self.pre_lev:setString('' .. lev)
    self.after_lev:setString('' .. lev + 1)
    self.progress_bar:setVisible(true)
end

function CopyExpBar:updateCopyExpData(lev, sumExp, val)
    local pre_lev = self.pre_lev
    local after_lev = self.after_lev
    local progress_bar = self.progress_bar

    local preExp = sumExp - val
    local maxExp = findLevel(lev).team_xp
    local surplus = sumExp - maxExp
    -- local sExp = surplus < 0 and 0 or surplus
    local sExp = surplus
    local prePercent = preExp/maxExp * 100
    local afterPercent = surplus < 0 and sumExp/maxExp*100 or 100 
    if surplus < 0 then CopyData.isTeamUpgrade = false else CopyData.isTeamUpgrade = true end
    self:doExpBarAction(lev, sExp, prePercent, afterPercent)
end

function CopyExpBar:doExpBarAction(lev, exp, pre, after)
    local left = UIFactory.getLeftProgressBar("copy_exp_progress.png", self, 228, 59)
    left:setPercentage(pre)
    left:setVisible(false)

    local showBar = cc.CallFunc:create(function() setUIFade(self, cc.FadeIn, 0.5)  end)--onSimpleChange()
    local hideBar = cc.CallFunc:create(function()
         if nil ~= left then LogMgr.debug('remove progress left>>>>') left:removeFromParent() end 
         self.progress_bar:setVisible(true)
         self.progress_bar:setPercent(after)
         setUIFade(self, cc.FadeOut, 0.5)
    end)
    local delay1 = cc.DelayTime:create(0.5)
    local delay2 = cc.DelayTime:create(0.5)

    local function closeTeamUpgradeUI()
        -- 升级处理
        EventMgr.removeListener(EventType.closeTeamUpgradeUI, closeTeamUpgradeUI)
        EventMgr.dispatch(EventType.showCopyExpBar, {val = exp, sumExp = exp, level = lev+1})
    end

    if lev >= MainScene.MaxTeamLevel or pre == after then
        local sq = cc.Sequence:create(showBar, delay1, hideBar, delay2, cc.RemoveSelf:create())
        self:runAction(sq)
    else
        local callback1 = cc.CallFunc:create(function()
                self.progress_bar:setVisible(false)
                left:setVisible(true)
                local progress = cc.ProgressFromTo:create(0.3, pre, after) 
                left:runAction(progress) 
            end)
        local callback2 = cc.CallFunc:create(function()
                if exp >= 0 then
                    if SceneMgr.isSceneName( 'copy' ) then
                        LogMgr.debug('副本中提交经验')
                        Command.run('copy commit')
                    -- elseif SceneMgr.isSceneName( 'copyUI' ) then
                    --     Command.run("team levelup") --请求升级
                    -- elseif SceneMgr.isSceneName('main') then
                    --     Command.run('team levelup')
                    else
                        -- EventMgr.dispatch(EventType.expBarPercent)
                    end
                    LogMgr.debug('副本copy中升级打开UI')
                    -- EventMgr.dispatch(EventType.expBarPercent)
                    LogMgr.debug('终于升级了 >>>>>>>')
                    EventMgr.addListener(EventType.closeTeamUpgradeUI, closeTeamUpgradeUI)
                end
                LogMgr.debug('移除经验条Bar >>>>>>>')
                self:removeFromParent()
            end)
        local delay3 = cc.DelayTime:create(0.6)
        local sq = cc.Sequence:create(showBar, delay1, callback1, delay3, hideBar, delay2, callback2)
        self:runAction(sq)
    end
end

local function showExpBarFunc(data)
    local exp = data.val
    local sum = data.sumExp
    local level = data.level

    local expBar = CopyExpBar:createCopyExpBar(level, sum, exp)
    expBar:setTouchEnabled(false)
    expBar:setAnchorPoint(cc.p(0.5, 0.5))
    expBar:setPosition(visibleSize.width/2, visibleSize.height/2 + 200)
    
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    layer:addChild(expBar)

    expBar:updateCopyExpData(level, sum, exp)
end

local exp_msg = nil
local function expGet(data)
    if SceneMgr.isSceneName('copy') then
        LogMgr.debug('副本copy中升级打开UI')
        onSimpleChange()
        -- Command.run('team levelup')
        -- EventMgr.dispatch(EventType.expBarPercent)
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
                LogMgr.debug("战斗场景中。。。")
                local function onSceneShow(scene)
                    if scene ~= "fight" then
                        LogMgr.debug("退出战斗场景。。。")
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
EventMgr.addListener(EventType.showCopyExpBar, showExpBarFunc)
-- EventMgr.addListener(EventType.UserCoinUpdate, expGet)