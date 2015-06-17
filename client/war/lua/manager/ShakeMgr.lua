local __this = ShakeMgr or {}
ShakeMgr = __this

local shakeMap = {}
local winNameMap = {}
local shakeCount = 0

local function shakeHandler()
    for _,vo in pairs(shakeMap) do
        if vo.strength then
            vo.target:setPosition(MathUtil.random(-vo.strength, vo.strength), MathUtil.random(-vo.strength, vo.strength))
        end
        if vo.rotationVar then
            vo.target:setRotation(vo.rotation + MathUtil.random(-vo.rotationVar, vo.rotationVar))
        end
    end
end

function __this.stopAllShake(winName)
    local shakeMap = winNameMap[winName]
    if shakeMap then
        for k,_ in pairs(shakeMap) do
            __this.stopShake(k)
        end
    end
end

function __this.stopShake(target)
    local vo = shakeMap[target]
    if vo then
        target:setPosition(vo.x, vo.y)
        target:setRotation(vo.rotation)
        shakeMap[target] = nil
        shakeCount = shakeCount - 1
        if shakeCount == 0 then
            TimerMgr.killPerFrame(shakeHandler)
        end
    end
end

--开始震动
--target
--strength
--winName 可选，用于stopAllShake接口
function __this.startShake(target, strength, winName)
    __this.shake(target, strength, nil, winName)
end

--开始来回旋转
--target
--rotationVar
--winName 可选，用于stopAllShake接口
function __this.startRotation(target, rotationVar, winName)
    __this.shake(target, nil, rotationVar, winName)
end

--winName 可选，用于stopAllShake接口
function __this.shake(target, strength, rotationVar, winName)
    if winName then
        if not winNameMap[winName] then
            winNameMap[winName] = {}
        end
        winNameMap[winName][target] = true
    end
    __this.stopShake(target)
    local vo = {}
    vo.target = target
    vo.strength = strength
    vo.x = target:getPositionX()
    vo.y = target:getPositionY()
    vo.rotation = target:getRotation()
    vo.rotationVar = rotationVar
    shakeMap[target] = vo
    shakeCount = shakeCount + 1
    if shakeCount == 1 then
        TimerMgr.callPerFrame(shakeHandler)
    end
end
