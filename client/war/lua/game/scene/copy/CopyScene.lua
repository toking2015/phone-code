require "lua/game/scene/copy/CopySceneUI.lua"
require "lua/game/scene/copy/CopySceneBG.lua"
require "lua/game/view/copyUI/CopySearchCompleteUI.lua"
-- require "lua/game/view/copyUI/CopyPrizeItem.lua"
require "lua/game/view/copyUI/CopyBossMet.lua"

require "lua/game/scene/copy/CopyMgr.lua"

local preMapPath = "image/map/"
local sceneMap = ""

local __scene = Scene:create()
__scene.isInit = false
__scene.bg = nil
__scene.mainUI = nil

local function initLoadList()
    LoadMgr.loadPlist("image/ui/CopyUI/CopyUI0.plist", "image/ui/CopyUI/CopyUI0.png", LoadMgr.SCENE, "copy")
    if false == __scene.isInit then
        __scene:addRelease(sceneMap)
    end
end


local function initScene()
    debug.showTime("copy_scene_1_")
    LogMgr.log( 'debug',"当前游戏进度:" .. CopyData.user.copy.posi)
    sceneMap = preMapPath .. CopyData.getCopyMap() .. ".jpg"
    -- 初始化加载列表
    initLoadList()
    debug.showTime("copy_scene_1_")
    -- 设置进入副本id
    CopyData.into_copy_id = CopyData.user.copy.copy_id
    -- 获取副本内脚步声音
    local copy = findCopy(CopyData.into_copy_id)
    CopyData.stepSound = copy.foot_sound
    -- 添加副本背景
    debug.showTime("copy_scene_2_")
    if nil == __scene.bg then
        __scene.bg = CopySceneBG:create(sceneMap)
        __scene:addChild(__scene.bg, 0)
        __scene.bg:setAnchorPoint( cc.p( 0, 0 ) )
    end
    debug.showTime("copy_scene_2_")
    -- 添加副本场景主UI
    debug.showTime("copy_scene_3_")
    if false == __scene.isInit then
        __scene.isInit = true
        
        __scene.mainUI = CopySceneUI:create()
        __scene:addChild(__scene.mainUI)
        __scene.mainUI:onShow()
    end
    debug.showTime("copy_scene_3_")
    -- 添加副本场景事件
    __scene.event_list = {}
    __scene.event_list[EventType.GutEnd] = function(data)
        LogMgr.log( 'debug',"----- 副本剧情结束 -----")
        if data.type == GutType.GutCopyInfo then
            Command.run( 'copy search' , data.logList)
        end
    end
    local winNameList = "SoldierUI_BagMain_TotemUI_StoreUI"
    __scene.event_list[EventType.ShowWindow] = function(data)
        local winName = data.winName
--        LogMgr.debug(">>>>>>>>>>>>>>>>> winName = " .. winName)
        local index = string.find(winNameList, winName)
        if index ~= nil then
            Command.run("copy commit")
            CopyData.isNeedRefurish = true
--            Command.run("copy refurbish")
        end
    end
    EventMgr.addList(__scene.event_list)
    -- 监听探索事件
    debug.showTime("copy_scene_4_")
    CopyMgr.start()
    debug.showTime("copy_scene_4_")
    -- 如果上一个是副本UI场景，则执行refurbish请求，获取玩家fight数据
    debug.showTime("copy_scene_5_")
    if SceneMgr.prev_scene_name == "copyUI" then
        CopyData.strength = 0
        CopyData.isFirstInto = true
        Command.run("copy refurbish", 'enter_copy')
    end
    debug.showTime("copy_scene_5_")
    -- 如果当前chunk是战斗 , 并且上一场景是战斗场景 , 则表示战斗剧情已完成
    debug.showTime("copy_scene_6_")
    local chunk = CopyData.getCurrChunk()
    LogMgr.log( 'debug',"get chunk type = " .. chunk.cate)
    if chunk.cate == const.kCopyEventTypeFight or chunk.cate == const.kCopyEventTypeFightMeet then 
        LogMgr.log( 'debug',"判断是否从战斗场景出来")
        local prev_scene_name = SceneMgr.prev_scene_name
        if prev_scene_name == "fight" and nil ~= CopyData.fightData then
            if CopyData.fightData.isWin == true then
                LogMgr.log( 'debug',"战胜，不值一提……")
                CopyData.useChunkStrength() -- 战胜了必须扣体力
                LogMgr.log( 'debug',">>>>>>>>>>>>战斗剧情完成，执行下一事件")
                Command.run( 'copy search' )
            else
                LogMgr.log( 'debug',"嘿嘿，居然败了……")
                Command.run( 'copy commit' ) -- 提交之前的副本事件
                Command.run("CopySceneBG doSpecialSearch")
            end
        else
            -- 执行chunk事件
            CopyMgr.delayDoChunk()
        end
        if prev_scene_name == "fight" then
            LoadMgr.clearAsyncCache()
            -- 预加载下一场战斗
            local fight = CopyData.getNextFight()
            CopyMgr.doFunciton(fight)
        end
    else
        -- 执行chunk事件
        CopyMgr.delayDoChunk()
    end
    debug.showTime("copy_scene_6_")
end
-- 副本场景初始化
function __scene:onShow()
    initScene()
    
    --解锁协议处理
    trans.lock_queue( false )
end
-- 场景退出
function __scene:onClose()
    CopyMgr.stop()
    EventMgr.removeList(__scene.event_list)
    __scene.isInit = false
    if nil ~= __scene.bg then
        __scene.bg:dispose()
        self:removeChild(__scene.bg)
        __scene.bg = nil
    end
    if nil ~= __scene.mainUI then
        __scene.mainUI:onClose()
        self:removeChild(__scene.mainUI)
        __scene.mainUI = nil
    end
    LoadMgr.removePlist("image/ui/CopyUI/CopyUI0.plist", "image/ui/CopyUI/CopyUI0.png")
end


SceneMgr.insertScene( 'copy', __scene )
