--@author zengxianrong
local instance = nil --单例
local FRAME_TIME = 1 / 30 --帧时间

--资源获取接口
local function getTexture(url)
    return url
end

local function getProperty(obj, key, default)
    local result
    if (obj[key] ~= nil) then
        result = obj[key]
    elseif (default ~= nil) then
        result = default
    else
        result = 0
    end
    return result
end

local function getFrameTime(startFrame, endFrame)
    if (endFrame <= startFrame) then
        return 0
    end
    return (endFrame - startFrame) * FRAME_TIME
end

local function getRandom(min, max)
    return MathUtil.random(min, max)
end

-- STATUS = {
--     NORMAL=1,
--     ATTACK=2,
--     BOSS_ATTACK=3,
--     BOSS_CHANGE=4,
--     SPECIAL=5,
--     SPECIAL_ATTACK=6,
--     SPECIAL_BOSS_ATTAK=7
-- }
local SCENE_NAME={
    normal="normal",
    special="special",
    change="change"
}
local LAYER = --层次对应的zIndex
    {
        BG2=1,
        BG_E2=2,
        BG1=3,
        BG_E1=4,
        FR1=5,
        FR1_E=6,
        FL1=7,
        FL1_E=8,
        FR2=9,
        FR2_E=10,
        FL2=11,
        FL2_E=12,
}
local ACTION_TYPE = { --动作枚举
    shake="shake",
    move="move",
    fadein="fadein",
    fadeout="fadeout",
    play="play",
    remove="remove",
    add="add"
}

local __this = FightBackground or class("FightBackground", function()
    return cc.Layer:create()
end)
FightBackground = __this
FightBackground.WAR_MAP = nil --初始地图

function __this:ctor()
    self.winName = 'FightBackground' --模块名字
    self.json = nil
    self.pool = Pool.new()
    self.layers = {}
    self.symbols = {}
    for key, var in pairs(LAYER) do
        self.layers[var] = self:createLayer(var);
    end
end

function __this:createLayer(tag)
    local layer = cc.Node:create()
    layer:setTag(tag)
    self:addChild(layer, tag, tag)
    return layer
end

function __this:clearLayer()
    for _,layer in pairs(self.layers) do
        local children = layer:getChildren()
        for _,child in ipairs(children) do
            local name = child:getSymbolName()
            if (child.resetSystem) then
                child:resetSystem()
            end
            self.pool:disposeObject(name, child)
            layer:removeChild(child)
        end
    end
end

function __this:getAction(actJson, pStart, callfunc, layer)
    pStart = pStart or 0
    local start = getProperty(actJson, "start")
    local stop = getProperty(actJson, "stop")
    local time = getFrameTime(start, stop)
    local action = nil
    if (actJson.type == ACTION_TYPE.shake) then
        local strength = getProperty(actJson, "strength", 5)
        local startAct = cc.CallFunc:create(function() ShakeMgr.startShake(layer, strength, self.winName) end)
        local delayAct = cc.DelayTime:create(getFrameTime(start, stop))
        local stopAct = cc.CallFunc:create(function() ShakeMgr.stopShake(layer) end)
        action = cc.Sequence:create(startAct, delayAct, stopAct)
    elseif (actJson.type == ACTION_TYPE.move) then
        action = cc.MoveTo:create(time, cc.p(getProperty(actJson, "tox"), -getProperty(actJson, "toy")))
    elseif (actJson.type == ACTION_TYPE.fadein) then
        action = cc.FadeIn:create(time)
        if (callfunc ~= nil) then
            action = cc.Sequence:create(cc.CallFunc:create(callfunc), action)
        end
    elseif (actJson.type == ACTION_TYPE.fadeout) then
        action = cc.FadeOut:create(time)
        if (callfunc ~= nil) then
            action = cc.Sequence:create(action, cc.CallFunc:create(callfunc))
        end
    elseif (actJson.type == ACTION_TYPE.play) then
        action = cc.CallFunc:create(callfunc)
    elseif (actJson.type == ACTION_TYPE.remove) then
        action = cc.CallFunc:create(callfunc)
    elseif (actJson.type == ACTION_TYPE.add) then
        action = cc.CallFunc:create(callfunc)
    end
    if (pStart ~= start) then
        action = cc.Sequence:create(cc.DelayTime:create(getFrameTime(pStart, start)), action)
    end
    return action
end

function __this:dispose()
    ShakeMgr.stopAllShake(self.winName)
    for _,v in ipairs(self.symbols) do
        v:release()
    end
    self.symbols = {}
    self:removeAllChildren(true)
    self.pool:clear()
    LoadMgr.releaseWindow(self.winName) --释放资源
    instance:release() --释放单例
    instance = nil --释放单例
end

function __this:setData(json)
    self.json = json
    self:changeScene(SCENE_NAME.normal)
end

function __this:loadImage(symbolName)
    local data = self.json.symbol[symbolName]
    if not data then
        return
    end
    local url = getTexture(self.json.folder..data.name)
    if (data.type) then
        if (data.type == "AnimateSprite") then
            local png = getTexture(self.json.folder..data.texture)
            LoadMgr.loadPlist(url, png, LoadMgr.WINDOW, self.winName)
        elseif (data.type == "Particle") then
            local png = getTexture(self.json.folder..data.texture)
            LoadMgr.loadImage(png, LoadMgr.WINDOW, self.winName)
        end
    else
        LoadMgr.loadImage(url, LoadMgr.WINDOW, self.winName)
    end
end

function __this:shakeLeft(time)
    if (self.currentScene == SCENE_NAME.special) then
        self:shakeLayer(LAYER.FL2, time, 7)
    else
        self:shakeLayer(LAYER.FL1, time, 7)
    end
end

function __this:shakeRight(time)
	if (self.currentScene == SCENE_NAME.special) then
        self:shakeLayer(LAYER.FR2, time, 7)
    else
        self:shakeLayer(LAYER.FL1, time, 7)
    end
end

function __this:shakeLeftThenBack(time, delay, strength1, strength2)
    if (self.currentScene == SCENE_NAME.normal) then
        self:shakeOneByOne(LAYER.FL1, LAYER.BG1, time, delay, strength1, strength2)
    else
        self:shakeOneByOne(LAYER.FL2, LAYER.BG2, time, delay, strength1, strength2)
    end
end

function __this:shakeRightThenBack(time, delay, strength1, strength2)
    if (self.currentScene == SCENE_NAME.normal) then
        self:shakeOneByOne(LAYER.FR1, LAYER.BG1, time, delay, strength1, strength2)
    else
        self:shakeOneByOne(LAYER.FR2, LAYER.BG2, time, delay, strength1, strength2)
    end
end

function __this:shakeOneByOne(tag1, tag2, time, delay, strength1, strength2)
    self:shakeLayer(tag1, time, 8)
    local shakeBack = function ()
        self:shakeLayer(tag2, time - delay + 0.1, 4, strength2)
    end
    performWithDelay(self, shakeBack, delay, strength1)
end

function __this:changeToNormal()
    self:changeScene(SCENE_NAME.normal)
end

function __this:changeToSpecial()
    self:changeScene(SCENE_NAME.special)
end

function __this:playChange()
    self:changeScene(SCENE_NAME.change)
end

function __this:getScene()
    return self.currentScene
end

function __this:getChangeTime(sceneName)
    sceneName = sceneName or SCENE_NAME.change
    local sceneJson = self.json[sceneName]
    local start = getProperty(sceneJson, "start");
    local stop = getProperty(sceneJson, "stop");
    local time = getFrameTime(start, stop)
    return time
end

function __this:changeScene(sceneName)
    if (sceneName == self.currentScene) then
        return 0
    end
    local sceneJson = self.json[sceneName]
    local start = getProperty(sceneJson, "start");
    local stop = getProperty(sceneJson, "stop");
    local time = getFrameTime(start, stop)
    self.currentScene = sceneName
    self:clearLayer()
    if (stop ~= 0) then
        local changeEnd = function()
            self:changeScene(sceneJson.targetScene)
        end
        local sq = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(changeEnd))
        self:runAction(sq)
    end
    for i,v in ipairs(sceneJson) do
        if v.start and v.start > start then --延迟处理
            local function dealOne()
                self:dealOneNode(sceneJson, i, v, start, stop)
            end
            performWithDelay(self, dealOne, getFrameTime(start, v.start))
        else
            self:dealOneNode(sceneJson, i, v, start, stop)
        end
    end
    return time
end

function __this:dealOneNode(sceneJson, i, v, start, stop)
    self:loadImage(v.symbolName) --预加载资源
    local symbol = self:getSymbol(v.symbolName)
    if (symbol == nil) then
        return
    end
    if v.start then
        start = v.start
    end
    if (symbol.gotoAndStop) then
        symbol:gotoAndStop(1)
    end
    if (symbol.resetSystem) then
        symbol:resetSystem()
    end
    symbol:setScale(getProperty(v, "scale", 1))
    local px = getProperty(v, "x");
    local py = getProperty(v, "y");
    if (v.positionVarX) then
        px = px + getRandom(-v.positionVarX, v.positionVarX);
    end
    if (v.positionVarY) then
        py = py + getRandom(-v.positionVarY, v.positionVarY);
    end
    symbol:setPosition(px, -py)
    symbol:setVisible(v.visible ~= false)
    symbol:setCascadeOpacityEnabled(true)
    local alpha = v.alpha and math.round(0xff * v.alpha) or 0xff
    symbol:setOpacity(alpha)
    local layer = self.layers[LAYER[v.layer]]
    layer:addChild(symbol, i, i)
    if (v.action and #v.action > 0) then
        local shakeList = {}
        local otherList = {}
        for j,k in ipairs(v.action) do --动作
            --对应回调函数动作
            local func = nil
            if (k.type == ACTION_TYPE.play) then
                func = function() symbol:play() end
            elseif (k.type == ACTION_TYPE.fadeout or k.type == ACTION_TYPE.remove) then
                func = function()
                    if (symbol:getParent() == layer) then
                        layer:removeChild(symbol)
                    end
                    if (symbol.resetSystem) then
                        symbol:resetSystem()
                    end
                end
            elseif (k.type == ACTION_TYPE.fadein or k.type == ACTION_TYPE.add) then
                --没有加到舞台的对象，动作不会执行，因此只是设置visible
                symbol:setVisible(false)
                func = function() symbol:setVisible(true) end
            end
            --动作
            local action = self:getAction(k, start, func, layer)
            if (k.type == ACTION_TYPE.shake) then
                shakeList[#shakeList + 1] = action
            else
                otherList[#otherList + 1] = action
            end
        end
        if (#otherList == 1) then
            symbol:runAction(otherList[1])
        elseif (#otherList > 1) then
            local spawn = cc.Spawn:create(otherList)
            symbol:runAction(spawn)
        end
        if (#shakeList == 1) then
            layer:runAction(shakeList[1])
        elseif (#shakeList > 1) then
            local spawn = cc.Spawn:create(shakeList)
            layer:runAction(spawn)
        end
    end
end

function __this:shakeLayer(tag, second, strength)
    local stop = math.round(second/FRAME_TIME)
    local layer = self.layers[tag]
    --构造震动的动作
    local action = self:getAction({type=ACTION_TYPE.shake, stop=stop, strength=strength}, 0, nil, layer)
    layer:runAction(action)
end

function __this:getSymbol(name)
    local result = self.pool:getObject(name)
    if (result == nil) then
        local json = self.json
        local symbol = json.symbol
        local data = symbol[name]
        if (data == nil) then
            return nil
        end
        if (data.type == "AnimateSprite") then
            local startFrame = getProperty(data, "start", 1)
            local frames = createSpriteFrames(data.pattern, startFrame, data.frame)
            local frameTime = FRAME_TIME * getProperty(data, "interval", 1)
            local as = MovieSprite.new(frames, false, 1, frameTime, getProperty(data, "loop", false))
            as:setPosition(getProperty(data, "x"), -getProperty(data, "y"))
            result = as
        elseif (data.type == "Particle") then
            local url = getTexture(self.json.folder..data.name);
            local emitter = ParticleSprite.new(url);
            if (data.emissionRate) then
                emitter:setEmissionRate(data.emissionRate);
            end
            result = emitter
        else
            local s = FlashSprite:new()
            local url = getTexture(self.json.folder..data.name)
            s:setUrl(url)
            if (data.scale) then s:setSymbolScale(data.scale) end
            s:setOffset(getProperty(data, "x"), -getProperty(data, "y"))
            result = s
        end
        result:setSymbolName(name)
        result:retain()
        self.symbols[#self.symbols + 1] = result
    end
    return result
end

ParticleSprite = class("ParticleSprite", function(url)
    return cc.ParticleSystemQuad:create(url)
end)

function ParticleSprite:ctor()
    self.symbolName = nil
end

function ParticleSprite:setSymbolName(name)
    self.symbolName = name
end

function ParticleSprite:getSymbolName()
    return self.symbolName
end

MovieSprite = class("MovieSprite", function(_list, _isPlay, _startFrame, _delay, _isLoop)
    return AnimateSprite:create(_list, _isPlay, _startFrame, _delay, _isLoop)
end)

function MovieSprite:ctor()
    self.symbolName = nil
end

function MovieSprite:setSymbolName(name)
    self.symbolName = name
end

function MovieSprite:getSymbolName()
    return self.symbolName
end

FlashSprite = class("FlashSprite", function()
    return cc.Sprite:create()
end)

function FlashSprite:ctor()
    self.symbolName = nil
    self.shape = cc.Sprite:create()
    self.shape:setAnchorPoint(0, 1)
    self:addChild(self.shape)
end

function FlashSprite:setSymbolScale(scale)
    self.shape:setScale(scale)
end

function FlashSprite:setOffset(x, y)
    self.shape:setPosition(x, y)
end

function FlashSprite:setUrl(url)
    if (self.url ~= url) then
        self.url = url
        self.shape:setTexture(url)
    end
end

function FlashSprite:setSymbolName(name)
    self.symbolName = name
end

function FlashSprite:getSymbolName()
    return self.symbolName
end

local DEFAULT_JSON = {
    folder="image/map/",
    size={width=1136,height=768},
    symbol={
        img1={
            name="xxx.jpg",
            x=0,
            y=0,
        }
    },
    normal={
        {
            layer="FL1",
            symbolName="img1",
            x=0,
            y=0
        },
    },
    special={
        {
            layer="FL2",
            symbolName="img1",
            x=0,
            y=0
        },
    },
    change={
        {
            layer="FL1",
            symbolName="img1",
            x=0,
            y=0
        },
    },
}

--禁止
local function create(index)
    local json = nil
    json = DEFAULT_JSON
    json.symbol.img1.name = string.format("%d.jpg", index)
    local background = FightBackground.new()
    background:setData(json)
    background:setPosition((visibleSize.width - json.size.width) / 2, (visibleSize.height + json.size.height) / 2)
    return background
end

--获取单例
function __this:getInstance()
	if not instance then
        local index
        if FightBackground.WAR_MAP then
            index = FightBackground.WAR_MAP
            FightBackground.WAR_MAP = nil
        elseif FormationData.type == const.kFormationTypeCommon then
            local copyId = FormationData.oppExData
            index = CopyData.getWarMap(copyId) or ArenaData.FIGHT_MAP
        else
            index = ArenaData.FIGHT_MAP
        end
		instance = create(index)
        instance:retain()
    end
	return instance
end

--设置战斗背景，当次有效
function FightBackground.setWarMap(index)
    FightBackground.WAR_MAP = index
end