-- Create By Hujingjiang --

local prePath = "image/ui/CopySearchCompleteUI/"
local url = prePath .. "CopySearchCompleteUI.ExportJson"
local __this = {}
CopySearchCompleteUI = __this
__this.count = 0

-- CopySearchCompleteUI = createUIClass("CopySearchCompleteUI", url, PopWayMgr.SMALLTOBIG)
CopySearchCompleteUI = createUIClassEx("CopySearchCompleteUI", cc.Layer)

local function loadCompleteArmature(name, parent, x, y, depth)
    x = (nil == x) and visibleSize.width/2 or x
    y = (nil == y) and visibleSize.height/2 or y
    depth = (depth == nil) and 1 or depth
    local prePath = "image/armature/scene/copy/"
    local effect = ArmatureSprite:addArmatureEx(prePath, name, "CopySearchCompleteUI", parent, x, y, nil, depth)
    return effect
end

local function getCopyResultStar(parent, star_list, depth)
    depth = (depth == nil) and 1 or depth
    for i = 1, 3, 1 do
        local star = nil
        if 2 == i then 
            star = Sprite:create(prePath .. "star_big.png")
            star:setPosition(567, 482)
        elseif 1 == i then
            star = Sprite:create(prePath .. "star_small.png")
            star:setPosition(429, 434)
        else
            star = Sprite:create(prePath .. "star_small.png")
            star:setPosition(695, 434)
        end

        star:setScale(1.25)
        star:setOpacity(0)
        star:setVisible(false)
        table.insert(star_list, star)
        parent:addChild(star, depth)
    end
end

local function getCopySearchStar(dead)
    if 0 == dead then
        return 3
    elseif 1 == dead then
        return 2
    elseif dead >= 2 then
        return 1
    end
end

local function setStarData(list)    
    local count = 0 -- 获得星星数
    if nil == FightDataMgr.leftDeadSoldierCount then
        local copy_id = CopyData.into_copy_id --gameData.user.copy.copy_id
        count, _ = CopyData.getCopyStars(copy_id, const.kCopyMopupTypeNormal)
    else
        count = getCopySearchStar(FightDataMgr.leftDeadSoldierCount)
    end
    __this.count = count
    -- LogMgr.debug("副本id = " .. copy_id, "副本结算星星 = " .. count)
    for i = 1, #list do
        if count > 0 then
            count = count - 1
            list[i]:setGLProgramState(ProgramMgr.createProgramState('normal'))
        else
            list[i]:setGLProgramState(ProgramMgr.createProgramState('gray'))
        end
    end
end

--区域副本通关特效显示
function CopySearchCompleteUI:showCopyResultArmature()
    local tswc = loadCompleteArmature("tswc-tx-01", self)
    local function callfunc()
        tswc:stop()
        tswc:removeNextFrame()
        local fbtg_bg = loadCompleteArmature("fbtg-tx-02", self, nil, nil, 1)
        local fbtg = loadCompleteArmature("fbtg-tx-01", self, nil, nil, 2)
        self.fbtg_bg = fbtg_bg
        self.fbtg = fbtg
        local function onTimer()
            local index = fbtg:getAnimation():getCurrentFrame()
            if index >= 72 then
                fbtg:stop()
                self:showStarAction()
                fbtg:stopAllActions()
            end
        end
        schedule(fbtg, onTimer, 0)

        SoundMgr.playUI("UI_open")
    end
    tswc:onPlayComplete(callfunc)
end

function CopySearchCompleteUI:showStarAction()
    local i = 0
    local len = #(self.star_list)
    local function callfunc()
        if i < len then
            i = i + 1
            if i <= __this.count then
                SoundMgr.playEffect("sound/ui/star.mp3")
            end
            local obj = self.star_list[i]
            local show = cc.Show:create()
            local scale = cc.ScaleTo:create(0.12, 1)
            local fade = cc.FadeIn:create(0.12)
            local sp = cc.Spawn:create(scale, fade)
            obj:runAction(cc.Sequence:create(show, sp))
            if i == len then
                self.isClose = true
            end
        end
    end
    a_repeate(self, callfunc, 0.16, len+1)
end

function CopySearchCompleteUI:ctor()
	-- local npc = Sprite:create(prePath .. "npc/copy_npc.png")
	-- npc:setAnchorPoint(0.5, 0)
	-- self:addChild(npc)
    self.isClose = false
    self:showCopyResultArmature()
    self.star_list = {}
    getCopyResultStar(self, self.star_list, 3)
    setStarData(self.star_list)
	local isClick = false
    SoundMgr.playEffect("sound/ui/fubenpass.mp3")
	local function leaveCopy(data)
		-- LogMgr.debug("complete .......")
        if data.winName == self.winName then
            -- if isClick == false then
            if true == self.isClose and false == isClick then
                isClick = true
    		    EventMgr.removeListener(EventType.CloseWindow, leaveCopy)
                local function callfunc()
                    if CopyData.isSendMsg == false then
                        Command.run("scene leave")
                    else
                        TimerMgr.callLater(function() 
                           if CopyData.isSendMsg == true then
                                Command.run("loading wait show", "CopySearchCompleteUI")
                                local function callback()
                                    EventMgr.removeListener(EventType.UpdateCopyLog, callback)
                                    Command.run("loading wait hide", "CopySearchCompleteUI")
                                    Command.run( 'scene leave' )
                                end
                                EventMgr.addListener(EventType.UpdateCopyLog, callback)
                            else
                                Command.run("scene leave")
                            end
                        end, 1)
                    end
                end
                -- callfunc()
                if nil ~= self.fbtg then
                    self.fbtg:play()
                    self.fbtg:onPlayComplete(function()
                       TimerMgr.runNextFrame(callfunc)
                       self.fbtg:stop()
                       self.fbtg:removeNextFrame()
                       self.fbtg = nil
                    end)
                end
                self.fbtg_bg:runAction(cc.FadeOut:create(0.13))
                for _, v in pairs(self.star_list) do
                    v:runAction(cc.FadeOut:create(0.13))
                end
	        end
	    end
	end
	-- UIMgr.addTouchEnded(ui, leaveCopy)
    EventMgr.addListener(EventType.WindowOutClick, leaveCopy)
end

function CopySearchCompleteUI:onShow()
    self.isClose = false
end

function CopySearchCompleteUI:onBeforeClose()
    return not self.isClose
end

function  CopySearchCompleteUI:onClose()
    Command.run("loading wait hide", "CopySearchCompleteUI")
    EventMgr.dispatch( EventType.CopySearchCompleteUIHide )
    self.star_list = {}
end

Command.bind("show copyComplete", function()
    local win = PopMgr.popUpWindow("CopySearchCompleteUI", true, PopUpType.MODEL, true)
end)