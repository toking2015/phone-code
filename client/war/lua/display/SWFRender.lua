local TYPE = 
    {
        ARMATURE=1,
        IMAGE=2,
        NODE=3,
    }

local frameValue = 
    {
        startFrame= 0,
        duration= 1,
        tweenType= "none",
        motionTweenRotateTimes= 0,
        x= 0,
        y= 0,
        scaleX= 1,
        scaleY= 1,
        depth= 0,
        rotation= 0,
        libraryItem= "",
        alpha= 1,
        green= 0,
        shakeRotation= 0,
    }

local function expandJson(json, preJson)
    preJson = preJson or frameValue
    for k,v in pairs(preJson) do
        if json[k] == nil then
            json[k] = v
        end
    end
    if json.scale then
        json.scaleX = json.scale
        json.scaleY = json.scale
    end
end

local function repairJson(json)
    for _,arr in pairs(json.children) do
        for i = 1, #arr do
            expandJson(arr[i], arr[i - 1])
        end
    end
    for _,arr in pairs(json.children) do
        for i = 1, #arr do
            if i + 1 <= #arr then
                arr[i].duration = arr[i + 1].startFrame - arr[i].startFrame
            end
        end
    end
end

local function turnGreen(self)
    local children = self:getChildren()
    for _,v in ipairs(children) do
        ProgramMgr.setGray(v)
    end
end

local ArmatureSymbol = createLayoutClass("ArmatureSymbol", cc.Node)
function ArmatureSymbol:ctor(path, name, winName, sx, sy, completeStop, scale)
    self.armature = ArmatureSprite:addArmature(path, name, winName, self, sx, sy)
    self.armature:setScale(scale or 1)
    if completeStop == 1 then
        local function completeHandler()
            self.armature:stop()
        end
        self.armature:onPlayComplete(completeHandler)
    end
end

function ArmatureSymbol:stop()
	self.armature:stop()
end

local SpriteSymbol = createLayoutClass("SpriteSymbol", cc.Node)
function SpriteSymbol:ctor(path, sx, sy, scale)
    self.image = UIFactory.getSprite(path, self, sx, sy)
    self.image:setScale(scale or 1)
end

local NodeSymbol = createLayoutClass("NodeSymbol", cc.Node)
function NodeSymbol:ctor()
end

--SWF动画播放组件
local __this = SWFRender or createLayoutClass("SWFRender", cc.Node)
SWFRender = __this

function __this:ctor(json, winName)
    self.winName = winName
    self.json = json
    self.frame = 0
    self.count = 0
    repairJson(json)
    self.symbolMap = {}
    self:setPosition(0, json.height)
end

--播放
--@param completeHandler 播放完成回调
function __this:play(completeHandler)
    self.completeHandler = completeHandler
    if self.isPlaying then
        return
    end
    self.isPlaying = true
    function self.updateHandler()
        local clock = DateTools.getMiliSecond()
        local frame = math.floor((clock - self.clockTime) / 25)
        if frame > self.frame then
            for i = self.frame + 1, frame do
                if not self:gotoFrame(i) then
                    break
                end
            end
            self.frame = frame
        end
    end
    self.clockTime = DateTools.getMiliSecond()
    self.timer_id = TimerMgr.startTimer(self.updateHandler, 0)
end

function __this:stop()
    if self.isPlaying then
        self.isPlaying = nil
        ShakeMgr.stopAllShake(self.winName)
        self.timer_id =  TimerMgr.killTimer(self.timer_id)
        LoadMgr.releaseWindow(self.winName) -- 释放资源
    end
end

function __this:removeSymbol(name)
    local symbol = self.symbolMap[name]
    if symbol then
        ShakeMgr.stopShake(symbol)
        symbol:removeFromParent()
        self.symbolMap[name] = nil
    end
end

function __this:getIndex(arr, frame)
    for i = 1, #arr do
        if arr[i].startFrame <= frame and frame < arr[i].startFrame + arr[i].duration then
            return i
        end
    end
    return nil
end

function __this:getSymbol(name)
    if self.symbolMap[name] then
        return self.symbolMap[name]
    end
    local json = self.json.symbol[name]
    local symbol = nil
    if json then
        if json.type == TYPE.ARMATURE then
            local path = self.json.armaturePath .. json.name .. "/" .. json.name .. ".ExportJson"
            symbol = ArmatureSymbol.new(path, json.name, self.winName, json.x, json.y, json.completeStop, json.scale)
        elseif json.type == TYPE.IMAGE then
            symbol = SpriteSymbol.new(self.json.imagePath .. json.name, json.x, json.y, json.scale)
        elseif json.type == TYPE.NODE then
            symbol = cc.Node:create()
        end
    end
    symbol.json = json
    symbol:setLocalZOrder(json.depth)
    symbol:setCascadeOpacityEnabled(true)
    self.symbolMap[name] = symbol
    return symbol
end

function __this:setProperties(symbol, json, nextJson, frame)
    local x, y, scaleX, scaleY, rotation, alpha = json.x, json.y, json.scaleX, json.scaleY, json.rotation, json.alpha
    if json.tweenType == "motion" and nextJson then --动画
        local percent = (frame - json.startFrame) / json.duration
        x = json.x + (nextJson.x - json.x) * percent
        y = json.y + (nextJson.y - json.y) * percent
        scaleX = json.scaleX + (nextJson.scaleX - json.scaleX) * percent
        scaleY = json.scaleY + (nextJson.scaleY - json.scaleY) * percent
        rotation = json.rotation + (nextJson.rotation - json.rotation) * percent
        alpha = json.alpha + (nextJson.alpha - json.alpha) * percent
    end
    symbol:setPosition(x, -y)
    symbol:setScale(scaleX, scaleY)
    symbol:setOpacity(math.floor(alpha * 0xFF))
    if json.shakeRotation == 0 then
        symbol:setRotation(rotation)
    end
    if json.startFrame == frame then
    	if json.stop == 1 then
    		symbol:stop()
    	end
        if json.green == 1 then
            turnGreen(symbol)
        end
        if json.shakeRotation == 1 then
            ShakeMgr.startRotation(symbol, json.rotationVar or 3, self.winName)
        else
            ShakeMgr.stopShake(symbol)
        end
    end
end

function __this:gotoFrame(frame)
    local hasNoParents = {}
    local addCount = 0
    for k,v in pairs(self.json.children) do
        local index = self:getIndex(v, frame)
        if not index then
            self:removeSymbol(k)
        else
            addCount = addCount + 1
            local symbol = self:getSymbol(k)
            if symbol then
                if not symbol:getParent() then
                    if symbol.json.parent then
                        hasNoParents[k] = symbol
                    else
                        self:addChild(symbol)
                    end
                end
                self:setProperties(symbol, v[index], v[index + 1], frame)
            end
        end
    end
    --子集添加
    for k,v in pairs(hasNoParents) do
        local parent = self:getSymbol(v.json.parent)
        if parent then
            parent:addChild(v)
        end
    end
    if addCount == 0 then
        local callback = self.completeHandler
        self.completeHandler = nil
        if callback ~= nil then
            self:stop()
            callback()
            return false
        end
    end
    return true
end
