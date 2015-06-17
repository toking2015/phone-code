-- require("lua/game/view/gutUI/OpeningGut.lua")
local __this = OpeningMgr or { data = {}, needShowB = nil, viewB = nil}
OpeningMgr = __this

function __this.initialize()
    --测试用, 直接跳过前面开始步骤
    -- VarData.setVar( 'user_step', 0 )
    if VarData.getVar( 'user_step' ) < 2 then
        --显示装逼提示
        __this.needShowB = true
        VarData.setVar( 'user_step', 2 ) --TASK #7316::【手游3月版】开场战斗与开场剧情去掉
    end
    Command.run("opening hide preload", true)
    __this.doInitialize()
end

function __this.showB()
    local viewBg = UIFactory.getLayerColor(cc.c4b(0, 0, 0, 0xff), visibleSize.width, visibleSize.height)
    local view = UIFactory.getLayerColor(cc.c4b(0xff, 0xff, 0xff, 0xff), visibleSize.width, visibleSize.height)
    local rect = cc.rect(1, 1, 1, 32)
    UIFactory.getScale9SpriteFile("image/ui/Opening/zhuang/title.png", rect, cc.size(visibleSize.width, 64), view, 0, 485)
    UIFactory.getSprite("image/ui/Opening/zhuang/icon.png", view, 382, 517, 1)
    local txt = "独创内容　仿冒必究"
    local cctext = UIFactory.getText(txt, view, 635, 516, 38, cc.c3b(0xff, 0xff, 0xff))
    txt = "警告："
    cctext:setCascadeOpacityEnabled(true)
    cctext = UIFactory.getText(txt, view, 183, 411, 35, cc.c3b(0xbf, 0x00, 0x06))
    cctext:setCascadeOpacityEnabled(true)
    txt = "[style=00,00,00,27]　　　　　本游戏独创回合制MOBA，图腾觉醒、出装补刀、精准操作、火爆对抗等游戏内容，均受相关法律法规及适用之国际公约中有关著作权、专利权及其它财产所有权法律的保护。未经本游戏的明确书面许可，任何单位或个人不得以任何方式，对游戏内的任何内容进行全部或局部变更、发行、复制、下载、传播、重制、改动等，否则将被视作侵权，必将以法律手段追诉到底。"
    -- local text = UIFactory.getText("", view, 550, 310, 27, cc.c3b(0x00, 0x00, 0x00))
    local text = UIFactory.getNode(view, 100, 444)
    RichTextUtil:DisposeRichText(txt, text, nil, 0, 920, 23, 0, 100, 0)
    local btn = UIFactory.getButton("image/ui/Opening/zhuang/btn.png", view, visibleSize.width / 2 - 93, 88 - 20, 3, ccui.TextureResType.localType)
    btn:setCascadeOpacityEnabled(true)
    btn:addTouchEnded(function()
        if btn.hasClick then
            return
        end
        btn.hasClick = true
        ActionMgr.save( 'UI', '[独创内容] click [btn]' )
        local function endHandler()
            viewBg:removeFromParent()
            view:removeFromParent()
            __this.viewB = nil
            __this.checkShowPreload()
        end
        view:runAction(cc.Sequence:create(cc.FadeOut:create(1.5), cc.CallFunc:create(endHandler)))
    end)
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_DEBUG)
    layer:addChild(viewBg)
    layer:addChild(view)
    view:setCascadeOpacityEnabled(true)
    view:setOpacity(0)
    view:runAction(cc.Sequence:create(cc.FadeIn:create(1.5), cc.CallFunc:create(__this.preLoad)))
    __this.viewB = view
    local function nilHandler()
    end
    UIMgr.addTouchBegin(viewBg, nilHandler)
end

function __this.doInitialize()
    LogMgr.log( 'login', '进入引导场景' )
    SceneMgr.enterScene('opening')
    -- Command.run('loading show loading')
    
    LogMgr.log( 'login', '延后处理引导步骤' )
    TimerMgr.callLater(__this.continue, 0.1)
    
    commit_device_log(19)
end

function __this.preLoad()
    if __this.hasPreLoad then
        return
    end
    ActionMgr.save('loading', 'preload start')
    __this.hasPreLoad = true
    Command.run("loading fake percent")
    --预加载静态数据
    local static_list = 
    {
        'Monster',
        'SoldierEquip',
        'Odd',
        'Skill',
        'Item',
        'TotemAttr'
    }
    local index = 1
    local function loadPerFrame()
        Command.run("system ping")
        
        if index > #static_list then
            TimerMgr.killPerFrame(loadPerFrame)
            __this.preLoadModel()
        else
            Command.run("loading fake percent")
            GetDataList(static_list[index]) --预加载json
            index = index + 1
        end
    end
    TimerMgr.callPerFrame(loadPerFrame)
end

function __this:preLoadModel()
    Command.run("loading fake percent")
    ModelMgr:loadFormationModel()
    ActionMgr.save('loading', 'preload end')
    __this.enterMainScene()
end

function __this.continue()
    local user_step = VarData.getVar( 'user_step' )
    
    local method = __this.data[ user_step ]
    if method == nil then
        LogMgr.log( 'login', '旧号进入主场景' )
        __this.preLoad()
        return
    end
    
    LogMgr.log( 'login', '引导步骤: ' .. user_step )
    
    --累加步骤
    VarData.setVar( 'user_step', user_step + 1 )
    
    TimerMgr.runNextFrame( method )
end

function __this.abort()
    -- local user_step = VarData.getVar( 'user_step' )
    -- if user_step < 2 then
    --     VarData.setVar( 'user_step', 2 )
    -- end
end

local __step = 0
local function asc_step()
    __step = __step + 1
    return __step - 1
end

--播放第一个剧情
__this.data[ asc_step() ] = function()
    SceneMgr.enterScene( 'opening' )
    local gut = PopMgr.popUpWindow("OpeningGut", false, nil, true)
    local function callback()
        PopMgr.removeWindowByName('OpeningGut')
        Command.run( 'opening continue' )
    end
    gut:start( "正在播放第一个开场剧情……", callback )
    
    commit_device_log(20)
end

--这里应该是触发假战斗
__this.data[ asc_step() ] = function()
    FightBackground.setWarMap(1112) --第一场战斗的背景
    FightDataMgr:firstShow()
    local function onSceneShow(name)
        if name ~= 'fight' then
            EventMgr.removeListener(EventType.SceneShow, onSceneShow)
            __this.continue()
        end
    end
    EventMgr.addListener(EventType.SceneShow, onSceneShow)
    
    commit_device_log(21)
end

--第二段剧情播放
__this.data[ asc_step() ] = function()
    Command.run( 'opening continue' )
    -- SceneMgr.enterScene( 'opening' )
    -- local gut = PopMgr.popUpWindow('OpeningGut', false, nil, true)
    -- gut:start("正在播放第二个开场剧情……", function()
    --     PopMgr.removeWindowByName('OpeningGut')
    --     Command.run( 'opening continue' )   
    -- end)
    
    commit_device_log(22)
end

--第一次进入场景
__this.data[ asc_step() ] = function()
    EventMgr.dispatch( EventType.FirstEnterScene )
    LogMgr.log( 'login', '新手第一次进入主场景' )
    commit_device_log(23)
    __this.enterMainScene()
end

function __this.enterMainScene()
    __this.hasPreLoad = nil --清除预加载记录
    Command.run("loading fake percent")
    Command.run("loading close")
    if __this.needShowB then
        __this.needShowB = nil
        __this.showB()
        return
    end
    ActionMgr.save('loading', 'wait copydata start')
    __this.shouldShowPreload = true
     local function checkCopyDataBack()
        if not __this.viewB then
            Command.run("loading wait show", "opening")
        end
        local curCopyId = CopyData.getMaxCopyId() --当前通关副本ID
        if curCopyId == 0 then
            __this.checkShowPreload() --显示loading
            TimerMgr.runNextFrame(checkCopyDataBack)
        else
            __this.checkEnterCopyScene(curCopyId)
        end
    end
    checkCopyDataBack()
end

function __this.checkEnterCopyScene(curCopyId)
    ActionMgr.save('loading', 'wait copydata end')
    SceneMgr.pushScene( 'main' )
    if curCopyId <= 1011 then --新手进入游戏后，直接进入到第1-1的副本（直接进战斗，布阵过程省略）
        ActionMgr.save('loading', 'wait formationdata start')
        __this.checkShowPreload() --显示loading
        local function enterCopy() --确保阵型上面有武将
            ActionMgr.save('loading', 'wait formationdata end')
            Command.run("NCopyUI show default", true)
            TimerMgr.runNextFrame(__this.firstFight)
        end
        FormationData.setRecommendFormation(enterCopy) --设置推荐布阵
        return
    end
    Command.run("opening hide preload") --清除loading条
    Command.run("loading wait hide", "opening")
    Command.run("loading can frog", true)
    if curCopyId < 3000 then
        Command.run("NCopyUI show default")
        return
    end
    SceneMgr.showCurrentScene() --显示主场景
end

function __this.checkShowPreload()
    if __this.shouldShowPreload and not __this.viewB and not __this.perload_percent then
        Command.run("loading show preload")
        __this.perload_percent = 0
        TimerMgr.killTimer(__this.preload_timer)
        __this.preload_timer =  TimerMgr.startTimer(function()
            Command.run("loading fake percent", __this.perload_percent)
            if __this.perload_percent < 95 then
                __this.perload_percent = __this.perload_percent + 0.2
            end
        end, 0.2)
    end
end

Command.bind("opening hide preload", function(noclose)
    TimerMgr.killTimer(__this.preload_timer)
    __this.perload_percent = nil
    __this.shouldShowPreload = nil --清除loading条
    if not noclose then
        Command.run("loading close")
    end
end)

function __this.firstFight()
    EventMgr.removeListener(EventType.GutEnd, __this.firstFight)
    Command.run("loading wait show", "firstFight")
    local function doFight()
        local u_copy = CopyData.user.copy
        if not u_copy or #u_copy.chunk == 0 then --黑屏问题罪魁祸首
            ActionMgr.save('loading', 'copy chunk == 0')
            TimerMgr.runNextFrame(doFight)
            return
        end
        Command.run("loading wait hide", "firstFight")
        CopyMgr.isChange = true
        Command.run("CopyMgr directFight", true)
    end
    doFight()
end

Command.bind( 'opening continue', __this.continue )
