--战斗特效显示对象
UIFightEffect = class("UIFightEffect",function()
    local node = cc.Node:create()
    node:retain()
    node:setCascadeOpacityEnabled(true)

    node.sprite = cc.Node:create()
    node.sprite:retain()
    node.sprite:setCascadeOpacityEnabled(true)
    node:addChild(node.sprite)
    
    node.view = nil
    node.effect = nil
    node.effectItem = nil
    node.use = false
    
    node.mirror = false
    node.type = ''
    node.frame = 0
    node.lastTime = 0
    node.totalFrames = 0
    node.frameRate = 0
    
    return node
end)

function UIFightEffect:create()
    return UIFightEffect.new()
end

local function getUrl(attr, style, name, type)
    return "image/armature/fight/" .. attr .. "/" .. style .. '/' .. name .. '.' .. type
end

function UIFightEffect:init(effect)
    self.effect = effect
    self.effectItem = effect:getEffectNormal()
    
    if not self.view then
        FightEffectMgr:loadResouce(effect.style)
        
        xpcall(
            function ( ... )
                self.view = ArmatureSprite:create(effect.style, self.effectItem.flag)
                self.view:retain()
                self.sprite:addChild(self.view)
            end,
            function ( ... )
                LogMgr.error("资源加载失败，特效：" .. effect.style)
            end)
    end
end

function UIFightEffect:chnAction(type, data)
    if type == self.type or not self.view then
        return
    end
    
    local effectItem = self.effect:getEffectByFlag(type)
    self.effectItem = effectItem
    self.totalFrames = self.effectItem.count
    self.frameRate = 25

    self.view:chnAction(type)
    self.view:setScale(self.effectItem.scale / 100)
    if self.mirror then
        self.sprite:setScaleX(-1)
    else
        self.sprite:setScaleX(1)
    end

    self.type = type
    local frames = self.view:getCurrentFrames()
    local rate = self.view:getCurrentRate()
    self.totalFrames = frames
    self.frameRate = math.ceil(1000 / rate)
    self.frame = 0
    self.lastTime = 0

    if data and 0 ~= data.endTime then
        data.endTime = data.startTime + self.totalFrames * self.frameRate
    end
end

function UIFightEffect:attack(frame, data)
    if not self.view then
        return
    end
    self.view:gotoAndStop(frame)
    
    local frames = self.view:getCurrentFrames()
    local rate = self.view:getCurrentRate()
    self.totalFrames = frames
    self.frameRate = math.ceil(1000 / rate)

    if data and 0 ~= data.endTime then 
        data.endTime = data.startTime + self.totalFrames * self.frameRate
    end
end

function UIFightEffect:onPlayComplete(fun)
    if not self.view then
        return
    end
    self.view:onPlayComplete(fun)
end

function UIFightEffect:gotoAndPlay()
    if not self.view then
        return
    end
    self.view:gotoAndPlay(1)
end

function UIFightEffect:setMirror(isMirror)
    self.mirror = isMirror
    if isMirror then
        self.sprite:setScaleX(-1)
    else
        self.sprite:setScaleX(1)
    end
end

function UIFightEffect:getItemX()
    if not self.effectItem then
        return 0
    end
    
    local item = self.effectItem
    return item.coordX
end

function UIFightEffect:getItemY()
    if not self.effectItem then
        return 0
    end

    return self.effectItem.coordY
end

function UIFightEffect:releaseAll()
	if self.view then
		self.view:removeFromParent()
		self.view:release()
	end
    self.view = nil
    
	if self.sprite then
        self.sprite:removeFromParent()
		self.sprite:release()
	end
    self.sprite = nil
    
    FightEffectMgr:removeResource(self.effect.style)
    self.effect = nil
    self.effectItem = nil

    self:removeFromParent()
	self:release()
end

local __this = 
{
    list = {},

    --资源对象管理
    map = {},
    --资源预热管理
    async = {},
}
__this.__index = __this

function __this.changeLayer(data, layer)
    if not data.uiEffect then
        return false
    end

    xpcall(
        function ()
            if layer ~= data.uiEffect:getParent() then
                data.uiEffect:removeFromParent()
                layer:addChild(data.uiEffect)
            end
        end,
        function ()
            LogMgr.log('FightDataMgr', "%s", "FightEffectMgr.changeLayer 特效图层切换出错，特效文件：" .. data.effect.style .. " 标签名：" .. data.effectType)
            data.uiEffect = nil
        end)

    return true
end

function __this:useEffect(data, layer, role)
    if not data.effect then
        return
    end

    if not layer then
        layer = role.playerView.sprite
    end
    if self.changeLayer(data, layer) then
        return
    end

    --特殊特效使用重用机制
    if 
        "tx-shouji" == data.effect.style 
        or FightAnimationMgr.const.POWER_EFFECTID == data.effect.style 
    then
        for __, uiEffect in pairs(self.list) do
            if data.effect.style == uiEffect.effect.style and not uiEffect.use then
                uiEffect.use = true
                data.uiEffect = uiEffect
                layer:addChild(data.uiEffect)
                uiEffect:chnAction(data.effectType, data)
                return
            end
        end
    end
    
    data.uiEffect = UIFightEffect:create()
    data.uiEffect:init(data.effect)
    data.uiEffect.use = true
    
    layer:addChild(data.uiEffect)
    data.uiEffect:chnAction(data.effectType, data)
    table.insert(self.list, data.uiEffect)
end

function __this:unEffect(data)
    if not data.uiEffect or not data.uiEffect.view then
        data.uiEffect = nil
        return
    end

    if 
        "tx-shouji" == data.effect.style 
        or FightAnimationMgr.const.POWER_EFFECTID == data.effect.style 
    then
        data.uiEffect:removeFromParent()
        data.uiEffect.effectItem = nil
        data.uiEffect.type = nil
        data.uiEffect.sprite:setScaleX(1)
        data.uiEffect.view:setScale(1)
        data.uiEffect.use = false
    else
        for i, uiEffect in pairs(self.list) do
            if uiEffect == data.uiEffect then
                table.remove(self.list, i)
                break
            end
        end

        data.uiEffect:releaseAll()
    end
    
    data.uiEffect = nil
end

function __this:releaseAll()
    -- LogMgr.log( 'debug',"*****************FightEffectMgr:releaseAll*****************")
    for __, effect in pairs(self.list) do
        effect:releaseAll()
    end
    self.list = {}

    for key, value in pairs(self.map) do
        if value > 0 then
            LoadMgr.removeArmature(getUrl("effect", key, key, "ExportJson"))
        end
    end
    self.map = {}
    self.async = {}
end

function __this:loadAsync(style)
    LoadMgr.loadArmatureFileInfoAsync(
        getUrl("effect", style, style, "ExportJson"),
        LoadMgr.SCENE,
        'fight')
    self.async[style] = true
end

function __this:loadResouce(style)
    self.map[style] = self.map[style] or 0
    self.map[style] = self.map[style] + 1

    --没预热的情况下
    if not self.async[style] then
        self:loadAsync(style)
    end

    local url = getUrl("effect", style, style, "ExportJson")
    -- LogMgr.log("UIFightEffect", "%s", "UIFightEffect loadResource url:" .. url)
    LoadMgr.loadArmatureFileInfo(url, LoadMgr.SCENE, "fight")
end

function __this:removeResource(style)
    if not self.map[style] or 0 == self.map[style] then
        return
    end

    self.map[style] = self.map[style] - 1
    if 0 == self.map[style] then
        LoadMgr.removeArmature(getUrl("effect", style, style, "ExportJson"))
        self.async[style] = false
    end
end

function __this:releaseByBody(style)
    local del = {}
    for i, effect in pairs(self.list) do
        if style == effect.effect.style and not effect.use then
            table.insert(del, i)
        end
    end

    for i = #del, 1, -1 do
        local effect = self.list[del[i]]
        table.remove(self.list, del[i])

        effect:releaseAll()
    end
end

--针对角色模型释放特效[释放规则：释放不使用]
function __this:parseBody(body)
    for __, action in pairs(body.list) do
        for __, ae in pairs(action.listEffect) do
            if "" ~= ae.ackEffect then
                local list = string.split(ae.ackEffect, '%')
                if 2 == #list then
                    self:releaseByBody(list[1])
                end
            end
            if "" ~= ae.fireEffect then
                local list = string.split(ae.fireEffect, '%')
                if 2 == #list then
                    self:releaseByBody(list[1])
                end
            end
            if "" ~= ae.targetEffect then
                local list = string.split(ae.targetEffect, '%')
                if 2 == #list then
                    self:releaseByBody(list[1])
                end
            end
        end
    end
end

FightEffectMgr = __this