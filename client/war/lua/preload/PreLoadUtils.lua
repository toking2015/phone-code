visibleSize = cc.Director:getInstance():getVisibleSize()

PreLoadUtils = {ArmatureMap={}}
--递归获取UI子元件对象
function initLayout( root )
	local childrens = root:getChildren()
	for k,v in pairs(childrens) do
		local name = v:getName()
		if name ~= "" and name ~= nil then
			root[ name ] = v
			initLayout( v )
		end
	end
end

--- 生成组件对象，fileName 为文件路径
--@param fileName 文件路径
---
function getLayout(fileName)
	local skin = ccs.GUIReader:getInstance():widgetFromJsonFile(fileName)
	initLayout( skin )
	return skin
end

local function addToParent(child, parent, x, y, depth)
	if parent then
		parent:addChild(child, depth or 0)
	end
	child:setPosition(x or 0, y or 0)
end

function PreLoadUtils.removeSelf(child)
	if child and child:getParent() then
		child:removeFromParent()
	end
end

function PreLoadUtils.removeSelfLater(child)
	if child and child:getParent() then
		child:runAction(cc.RemoveSelf:create())
	end
end

function PreLoadUtils.getSprite(file, parent, x, y, depth)
	local sp = cc.Sprite:create(file)
	addToParent(sp, parent, x, y, depth)
	return sp
end

function PreLoadUtils.getLayerColor(c4b, width, height, parent, x, y, depth)
	local ly = cc.LayerColor:create(c4b, width, height)
	addToParent(ly, parent, x, y, depth)
	return ly
end

function PreLoadUtils.getParticle(plist, x, y, posType, parent, depth)
	local prePath = "image/particle/"
	local part = cc.ParticleSystemQuad:create(prePath..plist)
	part:setPositionType(posType or cc.POSITION_TYPE_GROUPED)
	addToParent(part, parent, x, y, depth)
	return part
end

--简单骨骼动画播放器
function PreLoadUtils.getArmature(prePath, name, winName, parent, x, y, complete, depth, times)
	local path = string.format(prePath.."%s/%s.ExportJson", name, name)
	local infoMap = PreLoadUtils.ArmatureMap[winName]
	if not infoMap then
		infoMap = {}
		PreLoadUtils.ArmatureMap[winName] = infoMap
	end
	table.insert(infoMap, path)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    local armature = ccs.Armature:create(name)
    addToParent(armature, parent, x, y, depth)
	local animation = armature:getAnimation()
	animation:playWithIndex(0, -1, times or -1)
	if complete then
        local function movementHandler(ref, eventType)
            if (ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType) then
                complete(armature)
            end
        end
        animation:setMovementEventCallFunc(movementHandler)
    end
	return armature
end

function PreLoadUtils.removeArmatureInfo(winName)
	local infoMap = PreLoadUtils.ArmatureMap[winName]
	if infoMap then
		-- 底层自动释放，不需要上层去控制
		-- for _,v in ipairs(infoMap) do
		-- 	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v)
		-- end
	end
	PreLoadUtils.ArmatureMap[winName] = nil
end

function PreLoadUtils.startTimer(fun, interval, paused)
	return cc.Director:getInstance():getScheduler():scheduleScriptFunc(fun, interval, paused)
end

function PreLoadUtils.killTimer(timer_id)
	if timer_id then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer_id)
	end
end
