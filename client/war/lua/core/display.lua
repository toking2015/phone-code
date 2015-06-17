
display = {}

local sharedDirector         = cc.Director:getInstance()
local sharedTextureCache     = cc.Director:getInstance():getTextureCache()
local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local sharedAnimationCache   = cc.AnimationCache:getInstance()

-- check device screen size
local glview = sharedDirector:getOpenGLView()
local size = glview:getFrameSize()
display.sizeInPixels = {width = size.width, height = size.height}

local w = display.sizeInPixels.width
local h = display.sizeInPixels.height

if CONFIG_SCREEN_WIDTH == nil or CONFIG_SCREEN_HEIGHT == nil then
    CONFIG_SCREEN_WIDTH = w
    CONFIG_SCREEN_HEIGHT = h
end

local function checkScale(w, h)
    local scale = 1
    local wscale, hscale = w / CONFIG_SCREEN_WIDTH, h / CONFIG_SCREEN_HEIGHT
    if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
        scale = wscale
    elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH_PRIOR" then
        if wscale > hscale then
            scale = wscale
        else
            scale = hscale
        end
    elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
        scale = hscale
    elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT_PRIOR" then
        if wscale < hscale then
            scale = wscale
        else
            scale = hscale
        end
    end
    return scale, wscale, hscale
end

local scale, wscale, hscale = 1, 1, 1
if type(CONFIG_SCREEN_AUTOSCALE) == "function" then
    CONFIG_SCREEN_AUTOSCALE(w, h)
    glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, kResolutionNoBorder)
elseif CONFIG_SCREEN_AUTOSCALE then
    scale, wscale, hscale = checkScale(w, h)

    if type(CONFIG_RESOURCE_SIZE) == "table" then
        local selectedSize, lastSize
        for i, size in ipairs(CONFIG_RESOURCE_SIZE) do
            local maxContentScale = size.scale or 99999
            if scale <= maxContentScale then
                selectedSize = size
                break
            end
            lastSize = size
        end

        if not selectedSize and lastSize then selectedSize = lastSize end
        CCFileUtils:sharedFileUtils():addSearchPath(selectedSize.path)

        w = w / scale * selectedSize.scale
        h = h / scale * selectedSize.scale
        scale, wscale, hscale = checkScale(w, h)
    end

    CONFIG_SCREEN_AUTOSCALE = string.upper(CONFIG_SCREEN_AUTOSCALE)
    if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
        CONFIG_SCREEN_HEIGHT = h / scale
    elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH_PRIOR" then
        if wscale > hscale then
            CONFIG_SCREEN_HEIGHT = h / scale
        else
            CONFIG_SCREEN_WIDTH = w / scale
        end
    elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
        CONFIG_SCREEN_WIDTH = w / scale
    elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT_PRIOR" then
        if wscale < hscale then
            CONFIG_SCREEN_HEIGHT = h / scale
        else
            CONFIG_SCREEN_WIDTH = w / scale
        end
    else
        echoError(string.format("display - invalid CONFIG_SCREEN_AUTOSCALE \"%s\"", CONFIG_SCREEN_AUTOSCALE))
    end

    glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, kResolutionNoBorder)
end

local winSize = sharedDirector:getWinSize()
display.contentScaleFactor = scale
display.size               = {width = winSize.width, height = winSize.height}
display.width              = display.size.width
display.height             = display.size.height
display.cx                 = display.width / 2
display.cy                 = display.height / 2
display.c_left             = -display.width / 2
display.c_right            = display.width / 2
display.c_top              = display.height / 2
display.c_bottom           = -display.height / 2
display.left               = 0
display.right              = display.width
display.top                = display.height
display.bottom             = 0
display.widthInPixels      = display.sizeInPixels.width
display.heightInPixels     = display.sizeInPixels.height
display.COLOR_WHITE = cc.c3b(255, 255, 255)
display.COLOR_BLACK = cc.c3b(0, 0, 0)
display.COLOR_RED   = cc.c3b(255, 0, 0)
display.COLOR_GREEN = cc.c3b(0, 255, 0)
display.COLOR_BLUE  = cc.c3b(0, 0, 255)

display.AUTO_SIZE      = 0
display.FIXED_SIZE     = 1
display.LEFT_TO_RIGHT  = 0
display.RIGHT_TO_LEFT  = 1
display.TOP_TO_BOTTOM  = 2
display.BOTTOM_TO_TOP  = 3

display.CENTER        = 1
display.LEFT_TOP      = 2; display.TOP_LEFT      = 2
display.CENTER_TOP    = 3; display.TOP_CENTER    = 3
display.RIGHT_TOP     = 4; display.TOP_RIGHT     = 4
display.CENTER_LEFT   = 5; display.LEFT_CENTER   = 5
display.CENTER_RIGHT  = 6; display.RIGHT_CENTER  = 6
display.BOTTOM_LEFT   = 7; display.LEFT_BOTTOM   = 7
display.BOTTOM_RIGHT  = 8; display.RIGHT_BOTTOM  = 8
display.BOTTOM_CENTER = 9; display.CENTER_BOTTOM = 9

display.ANCHOR_POINTS = {
    cc.p(0.5, 0.5),  -- CENTER
    cc.p(0, 1),      -- TOP_LEFT
    cc.p(0.5, 1),    -- TOP_CENTER
    cc.p(1, 1),      -- TOP_RIGHT
    cc.p(0, 0.5),    -- CENTER_LEFT
    cc.p(1, 0.5),    -- CENTER_RIGHT
    cc.p(0, 0),      -- BOTTOM_LEFT
    cc.p(1, 0),      -- BOTTOM_RIGHT
    cc.p(0.5, 0),    -- BOTTOM_CENTER
}

display.SCENE_TRANSITIONS = {
    CROSSFADE       = {cc.TransitionCrossFade, 2},
    FADE            = {cc.TransitionFade, 3, cc.c3b(0, 0, 0)},
    FADEBL          = {cc.TransitionFadeBL, 2},
    FADEDOWN        = {cc.TransitionFadeDown, 2},
    FADETR          = {cc.TransitionFadeTR, 2},
    FADEUP          = {cc.TransitionFadeUp, 2},
    FLIPANGULAR     = {cc.TransitionFlipAngular, 3, kCCTransitionOrientationLeftOver},
    FLIPX           = {cc.TransitionFlipX, 3, kCCTransitionOrientationLeftOver},
    FLIPY           = {cc.TransitionFlipY, 3, kCCTransitionOrientationUpOver},
    JUMPZOOM        = {cc.TransitionJumpZoom, 2},
    MOVEINB         = {cc.TransitionMoveInB, 2},
    MOVEINL         = {cc.TransitionMoveInL, 2},
    MOVEINR         = {cc.TransitionMoveInR, 2},
    MOVEINT         = {cc.TransitionMoveInT, 2},
    PAGETURN        = {cc.TransitionPageTurn, 3, false},
    ROTOZOOM        = {cc.TransitionRotoZoom, 2},
    SHRINKGROW      = {cc.TransitionShrinkGrow, 2},
    SLIDEINB        = {cc.TransitionSlideInB, 2},
    SLIDEINL        = {cc.TransitionSlideInL, 2},
    SLIDEINR        = {cc.TransitionSlideInR, 2},
    SLIDEINT        = {cc.TransitionSlideInT, 2},
    SPLITCOLS       = {cc.TransitionSplitCols, 2},
    SPLITROWS       = {cc.TransitionSplitRows, 2},
    TURNOFFTILES    = {cc.TransitionTurnOffTiles, 2},
    ZOOMFLIPANGULAR = {cc.TransitionZoomFlipAngular, 2},
    ZOOMFLIPX       = {cc.TransitionZoomFlipX, 3, kCCTransitionOrientationLeftOver},
    ZOOMFLIPY       = {cc.TransitionZoomFlipY, 3, kCCTransitionOrientationUpOver},
}

display.TEXTURES_PIXEL_FORMAT = {}

function display.wrapSceneWithTransition(scene, transitionType, time, more)
    local key = string.upper(tostring(transitionType))
    if string.sub(key, 1, 12) == "CCTRANSITION" then
        key = string.sub(key, 13)
    end

    if key == "RANDOM" then
        local keys = table.keys(display.SCENE_TRANSITIONS)
        key = keys[math.random(1, #keys)]
    end

    if display.SCENE_TRANSITIONS[key] then
        local cls, count, default = unpack(display.SCENE_TRANSITIONS[key])
        time = time or 0.2

        if count == 3 then
            scene = cls:create(time, scene, more or default)
        else
            scene = cls:create(time, scene)
        end
    else
        echoError("display.wrapSceneWithTransition() - invalid transitionType %s", tostring(transitionType))
    end
    return scene
end

function display.replaceScene(newScene, transitionType, time, more)
    if sharedDirector:getRunningScene() then
        if transitionType then
            newScene = display.wrapSceneWithTransition(newScene, transitionType, time, more)
        end
        sharedDirector:replaceScene(newScene)
    else
        sharedDirector:runWithScene(newScene)
    end
end

function display.getRunningScene()
    return sharedDirector:getRunningScene()
end

function display.pause()
    sharedDirector:pause()
end

function display.resume()
    sharedDirector:resume()
end

function display.newLayer()
    return cc.Layer:create()
end

function display.newColorLayer(color)
    return cc.LayerColor:create(color)
end

function display.newNode()
    return cc.Node:create()
end

function display.newClippingRegionNode(rect)
    return cc.ClippingRegionNode:create(rect)
end

function display.newSprite(filename, x, y)
    local t = type(filename)
    if t == "userdata" then t = tolua.type(filename) end
    local sprite

    if not filename then
        sprite = cc.Sprite:create()
    elseif t == "string" then
        if string.byte(filename) == 35 then -- first char is #
            local frame = display.newSpriteFrame(string.sub(filename, 2))
            if frame then
                sprite = cc.Sprite:createWithSpriteFrame(frame)
            end
        else
            if display.TEXTURES_PIXEL_FORMAT[filename] then
                cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[filename])
                sprite = cc.Sprite:create(filename)
                cc.Texture2D:setDefaultAlphaPixelFormat(kcc.Texture2DPixelFormat_RGBA8888)
            else
                sprite = cc.Sprite:create(filename)
            end
        end
    elseif t == "cc.SpriteFrame" then
        sprite = cc.Sprite:createWithSpriteFrame(filename)
    else
        echoError("display.newSprite() - invalid filename value type")
        sprite = cc.Sprite:create()
    end

    if sprite then
        cc.SpriteExtend.extend(sprite)
        if x and y then sprite:setPosition(x, y) end
    else
        echoError("display.newSprite() - create sprite failure, filename %s", tostring(filename))
        sprite = cc.Sprite:create()
    end

    return sprite
end

function display.newScale9Sprite(filename, x, y, size)
    local t = type(filename)
    if t ~= "string" then
        echoError("display.newScale9Sprite() - invalid filename type")
        return
    end

    local sprite
    if string.byte(filename) == 35 then -- first char is #
        local frame = display.newSpriteFrame(string.sub(filename, 2))
        if frame then
            sprite = cc.Scale9Sprite:createWithSpriteFrame(frame)
        end
    else
        if display.TEXTURES_PIXEL_FORMAT[filename] then
            cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[filename])
            sprite = cc.Scale9Sprite:create(filename)
            cc.Texture2D:setDefaultAlphaPixelFormat(kcc.Texture2DPixelFormat_RGBA8888)
        else
            sprite = cc.Scale9Sprite:create(RES_PATH .. filename)
        end
    end

    if sprite then
        if x and y then sprite:setPosition(x, y) end
        if size then sprite:setContentSize(size) end
    else
        echoError("display.newScale9Sprite() - create sprite failure, filename %s", tostring(filename))
    end

    return sprite
end

function display.newTilesSprite(filename, rect)
    if not rect then
        rect = CCRect(0, 0, display.width, display.height)
    end
    local sprite = cc.Sprite:create(filename, rect)
    if not sprite then
        echoError("display.newTilesSprite() - create sprite failure, filename %s", tostring(filename))
        return
    end

    local tp = ccTexParams()
    tp.minFilter = 9729
    tp.magFilter = 9729
    tp.wrapS = 10497
    tp.wrapT = 10497
    sprite:getTexture():setTexParameters(tp)
    cc.SpriteExtend.extend(sprite)

    display.align(sprite, display.LEFT_BOTTOM, 0, 0)

    return sprite
end

function display.newCircle(radius)
    return cc.CircleShape:create(radius)
end

function display.newRect(width, height)
    local x, y = 0, 0
    if type(width) == "userdata" then
        local t = tolua.type(width)
        if t == "CCRect" then
            x = width.origin.x
            y = width.origin.y
            height = width.size.height
            width = width.size.width
        elseif t == "CCSize" then
            height = width.height
            width = width.width
        else
            echoError("display.newRect() - invalid parameters")
            return
        end
    end

    local rect = cc.RectShape:create(cc.Size(width, height))
    rect:setPosition(x, y)
    return rect
end

function display.newPolygon(points, scale)
    if type(scale) ~= "number" then scale = 1 end
    local arr = cc.PointArray:create(#points)
    for i, p in ipairs(points) do
        p = cc.p(p[1] * scale, p[2] * scale)
        arr:add(p)
    end

    return cc.PolygonShape:create(arr)
end

function display.align(target, anchorPoint, x, y)
    target:setAnchorPoint(display.ANCHOR_POINTS[anchorPoint])
    if x and y then target:setPosition(x, y) end
end

function display.addImageAsync(imagePath, callback)
    sharedTextureCache:addImageAsync(imagePath, callback)
end

function display.addSpriteFramesWithFile(plistFilename, image)
    if display.TEXTURES_PIXEL_FORMAT[image] then
        cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[image])
        sharedSpriteFrameCache:addSpriteFramesWithFile(plistFilename)
        cc.Texture2D:setDefaultAlphaPixelFormat(kcc.Texture2DPixelFormat_RGBA8888)
    else
        sharedSpriteFrameCache:addSpriteFramesWithFile(plistFilename)
    end
end

function display.removeSpriteFramesWithFile(plistFilename, imageName)
    sharedSpriteFrameCache:removeSpriteFramesFromFile(plistFilename)
    if imageName then
        display.removeSpriteFrameByImageName(imageName)
    end
end

function display.setTexturePixelFormat(filename, format)
    display.TEXTURES_PIXEL_FORMAT[filename] = format
end

function display.removeSpriteFrameByImageName(imageName)
    sharedSpriteFrameCache:removeSpriteFrameByName(imageName)
    CCTextureCache:sharedTextureCache():removeTextureForKey(imageName)
end

function display.newBatchNode(image, capacity)
    return CCNodeExtend.extend(cc.SpriteBatchNode:create(image, capacity or 100))
end

function display.newSpriteFrame(frameName)
    local frame = sharedSpriteFrameCache:spriteFrameByName(frameName)
    if not frame then
        echoError("display.newSpriteFrame() - invalid frameName %s", tostring(frameName))
    end
    return frame
end

function display.newFrames(pattern, begin, length, isReversed)
    local frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end

    for index = begin, last, step do
        local frameName = string.format(pattern, index)
        local frame = sharedSpriteFrameCache:spriteFrameByName(frameName)
        if not frame then
            echoError("display.newFrames() - invalid frame, name %s", tostring(frameName))
            return
        end

        frames[#frames + 1] = frame
    end
    return frames
end

function display.newAnimation(frames, time)
    local count = #frames
    local array = {}
    for i = 1, count do
        table.insert(array, frames[i])
    end
    time = time or 1.0 / count
    return cc.Animation:createWithSpriteFrames(array, time)
end

function display.setAnimationCache(name, animation)
    sharedAnimationCache:addAnimation(animation, name)
end

function display.getAnimationCache(name)
    return sharedAnimationCache:animationByName(name)
end

function display.removeAnimationCache(name)
    sharedAnimationCache:removeAnimationByName(name)
end

function display.removeUnusedSpriteFrames()
    sharedSpriteFrameCache:removeUnusedSpriteFrames()
    sharedTextureCache:removeUnusedTextures()
end

display.PROGRESS_TIMER_BAR = kCCProgressTimerTypeBar
display.PROGRESS_TIMER_RADIAL = kCCProgressTimerTypeRadial

function display.newProgressTimer(image, progresssType)
    if type(image) == "string" then
        image = display.newSprite(image)
    end

    local progress = cc.ProgressTimer:create(image)
    progress:setType(progresssType)
    return progress
end

function extRemoveChild( child)
    if child == nil then
        return
    end
    child:removeFromParent()
end

function extAddChild( parent,child ,depth)
    if parent == nil or child == nil then
        return
    end

    if child:getParent() ~= nil then
        return
    end
    if depth then
        parent:addChild(child,depth)
    else
        parent:addChild(child)
    end
end

function display.newStudioItem( parent,itemJson,offX,offY )
    local obj = {}
    local children = itemJson:getChildren()
    if children == nil then
        LogMgr.log( 'debug',"newStudioItem:::::children is nil")
        return nil
    end

    local i = 1
    local child = nil
    local len = table.getn(children)
    for i = 1, len, 1 do
        child = children[i]:clone()
        if( child == nil ) then
            return nil
        end
        --if child:getParent() then
        --parent:removeChild(child)
        --end
        local ptx = child:getPositionX()
        local pty = child:getPositionY()
        child:setPosition( offX + ptx, offY + pty)
        parent:addChild(child)
        local name = child:getName()
        obj[name] = child
    end

    return obj
end

function display.showStudioItem(obj,show)
    obj.textnum = 1
    for key, var in pairs(obj) do
        if var ~= nil and type(var) == 'userdata' and var.setVisible ~= nil then
            var:setVisible(show)
        end
    end
end

function getInstance()
	return display
end


-- for short
display.x = display.c_right
display.y = display.c_top
display.sx = display.width
display.sy = display.height
display.rx = display.sx/1920
display.ry = display.sy/1080
--return display

function createTexture(p1)
    local t = cc.Image:new()
    t:initWithImageFile( p1, 2 )
    --渲染
    local texture = cc.Texture2D:new()
    -- texture:retain()
    texture:initWithImage(t)

    local st = cc.Image:new()
    st:initWithAlpha(PageInfo.piece_width, PageInfo.piece_height, 255)

    local shadow = cc.Texture2D:new()
    shadow:initWithImage(st, cc.TEXTURE2_D_PIXEL_FORMAT_A8)
    shadow:retain()

    return texture, shadow
end
-- p1->原始图片路径 p2->透明图片路径 tr1->原始图片中与透明图片交集部分 tr2->透明图片中与原始图片交集部分
-- function createMixTexture(p1, p2, tr1, ar1)
--     --创建两个 Image 原始对象
--     local t1 = cc.Image:new()

--     --Alpha通道对象
--     local a1 = cc.Image:new()

--     --第一张图片与Alpha交集
--     -- local tr1 = cc.rect( 256, 0, 256, 512 )
--     -- local ar1 = cc.rect( 0, 0, 256, 512 )

--     --加载图片
--     t1:initWithImageFile( p1, 2 )
--     a1:initWithImageFile( p2 )

--     --追加透明通道
--     t1:appendAlpha( a1, ar1, tr1)

--     --渲染
--     local texture1 = cc.Texture2D:new()

--     texture1:retain()
--     texture1:initWithImage( t1 )

--     return texture1
-- end

local tmpImgList = {}
function createMixTexture(p, list)
    local gt = cc.Image:new()
    gt:initWithImageFile(p, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)

    local st = cc.Image:new()
    st:initWithAlpha(PageInfo.piece_width, PageInfo.piece_height, 255)

    local at = nil--= cc.Image:new()
    for k, v in pairs(list) do
        -- at = cc.Image:new()
        if nil == tmpImgList[v.alpha] then
            at = cc.Image:new()
            at:initWithImageFile(v.alpha, cc.TEXTURE2_D_PIXEL_FORMAT_A8 )
            at:retain()
            tmpImgList[v.alpha] = at
        else
            at = tmpImgList[v.alpha]
        end

        -- gt:appendAlpha(at, v.aRect, v.gRect)
        st:appendAlpha(at, v.aRect, v.gRect)
    end

    local texture = cc.Texture2D:new()
    texture:initWithImage(gt)

    local shadow = cc.Texture2D:new()
    shadow:retain()
    shadow:initWithImage(st, cc.TEXTURE2_D_PIXEL_FORMAT_A8)

    return texture, shadow
end

function removeTmpImgList()
    for _, v in pairs(tmpImgList) do
        v:release()
    end
    tmpImgList = {}
end

