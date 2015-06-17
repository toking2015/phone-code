TipsMgr = {}
TipsMgr.obtainedList = {}

local function addOutline(item, rgb, px)
    if item == nil then return end
    local txt = item:getVirtualRenderer()
    txt:enableOutline(rgb, px)
end

local function wordAction(word, func1, func2)
    local move = cc.MoveBy:create(0.6, cc.p(0, 100))
    -- local shadow = cc.FadeTo:create(2, 120)
    local big = cc.ScaleTo:create(0.15, 1.3)
    local small = cc.ScaleTo:create(0.06, 1.2)
    local delay = cc.DelayTime:create(0.05)
    local callback = cc.CallFunc:create(function() word:removeFromParent(true)
                                                   func1() 
                                                   if func2 ~= nil then func2() end end)

    -- local action = cc.Sequence:create(cc.Spawn:create(move, shadow), callback)
    local action = cc.Sequence:create(move, big, small, delay, callback)

    return action
end

local function createTxt(txt, x, y, rgb, fontSize)
    local lbl = ccui.Text:create()
    x = x or visibleSize.width/2
    y = y or visibleSize.height/2
    FontStyle.setFontNameAndSize(lbl, FontNames.HEITI, fontSize)
    addOutline(lbl,cc.c4b(30,12,0,255),2)
    lbl:setColor(rgb)
    lbl:setString(txt)
    lbl:setPosition(cc.p(x, y))
    lbl:setTouchEnabled(false)

    return lbl
end

local function showFloatingWord(item, func)
    local view = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    local function removeItem()
        -- local objList = view:getObjList()
        -- table.remove(objList, 1)
    end
    local action = wordAction(item, removeItem, func)
    -- if nil ~= func then
    --     item:runAction(cc.Sequence:create(action, cc.CallFunc:create(function() func()
    --                                                 view:removeObjList() end)))
    -- else
    --     item:runAction(cc.Sequence:create(action, cc.CallFunc:create(function() view:removeObjList() end)))
    -- end
    item:runAction(action)

    view:addChild(item, 500)
    -- view:addObjList(item)
end

---------------------------
--@node:漂浮对象所要添加的node
--@x, y:坐标
--@callfunc:动作成功回调
function TipsMgr.floatingNode(node, x, y, callfunc)
    x = x or visibleSize.width/2
    y = y or visibleSize.height/2
    node:setPosition(cc.p(x, y))
    showFloatingWord(node, callfunc)
end

---------------------------
--@view:漂浮文字所要添加的view
--@txt:动作成功名称
--@x, y:坐标
function TipsMgr.showSuccess(txt, x, y, callfunc)
    local lbl = createTxt(txt, x, y, cc.c3b(255,240,0), 32)
    showFloatingWord(lbl, callfunc)
end

---------------------------
--飘绿色字
--@view:漂浮文字所要添加的view
--@txt:动作成功名称
--@x, y:坐标
function TipsMgr.showGreen(txt, x, y, callfunc)
    local lbl = createTxt(txt, x, y, cc.c3b(0, 255, 0), 32)
    showFloatingWord(lbl, callfunc)
end

---------------------------
--@view:漂浮文字所要添加的view
--@txt:改变的属性名称
--@x, y:坐标
function TipsMgr.showAttrChanged(txt, x, y, callfunc)
    local lbl = createTxt(txt, x, y, cc.c3b(30,12,0), 32)
    showFloatingWord(lbl, callfunc)
end

---------------------------
--@view:漂浮文字所要添加的view
--@txt:错误信息名称
--@x, y:坐标
function TipsMgr.showError(txt, x, y, callfunc)
    local lbl = createTxt(txt, x, y, cc.c3b(255,0,0), 32)
    showFloatingWord(lbl, callfunc)
end

local ignoreCoinMap = {}
ignoreCoinMap[const.kCoinSoldier] = true
ignoreCoinMap[const.kCoinTotem] = true

---------------------------
--@view
--@list:获得物品列表
    --@type:物品类型，如金币，图腾等
    --@id:物品id
    --@num:物品数量
    --@如：list = {S3Uint32, S3Uint32, ...}
--@x, y:坐标
function TipsMgr.showItemObtained(list, x, y, callfunc)
    do
        return -- TASK #7858::【手游】取消获得物品时的飘字提示
    end
    local isStart = false
    if #TipsMgr.obtainedList > 0 then
        isStart = true
    end
    table.insertTo( TipsMgr.obtainedList, list )
    x = x or visibleSize.width/2
    y = y or visibleSize.height/2
    local index = 0
    local id = nil
    
    local function createItemLayout()
        index = index + 1
        if index >#TipsMgr.obtainedList then
            -- TimerMgr.removeTimeFun("FloatingWord")
            TimerMgr.killTimer(id)
            if callfunc ~= nil then
                callfunc()
            end
            TipsMgr.obtainedList = {}
            index = 0
            return true
        end
        local data = TipsMgr.obtainedList[index]
        if ignoreCoinMap[data.cate] then
            return false
        end
        local name = CoinData.getCoinName(data.cate, data.objid)
        if not name then
            return false
        end
        local node = cc.Node:create()

        local text1 = createTxt("获得 ", 0, 0, cc.c3b(255,250,172), 32)
        text1:setAnchorPoint(cc.p(0, 0))
        local size1 = text1:getContentSize()
        node:addChild(text1)

        
        local color = CoinData.getCoinC3B(data.cate, data.objid)
        local text2 = createTxt(name, size1.width+5, 0, color, 32)
        text2:setAnchorPoint(cc.p(0, 0))
        local size2 = text2:getContentSize()
        node:addChild(text2)

        local text3 = createTxt(" X" .. data.val, size1.width+size2.width+10, 0, cc.c3b(255,250,172), 28)
        text3:setAnchorPoint(cc.p(0, 0))
        local size3 = text3:getContentSize()
        node:addChild(text3)

        local width = size1.width+size2.width+size3.width+15
        local height = size1.height+size2.height+size3.height+15
        text1:setPosition(cc.p(-width/2, -height/2))
        text2:setPosition(cc.p(-width/2+size1.width+5, -height/2))
        text3:setPosition(cc.p(-width/2+size1.width+size2.width+10, -height/2))

        local action = wordAction(node)
        -- setUIFade(node,cc.FadeTo, 2, 120)
        showFloatingWord(node)
        node:setPosition(cc.p(x, y))
        return true
    end
    local function createLayer()
        if not createItemLayout() then
            createLayer()
        end
    end

    if isStart == false then
        id = TimerMgr.startTimer(createLayer, 0.5, false)
    end
end

TipsMgr.TYPE_COIN = 0
TipsMgr.TYPE_SOLDIER = 1
TipsMgr.TYPE_TOTEM = 2
TipsMgr.TYPE_SKILL = 3
TipsMgr.TYPE_ODD = 4
TipsMgr.TYPE_ITEM = 5
TipsMgr.TYPE_STRING = 6
TipsMgr.TYPE_EQUIP = 7
TipsMgr.TYPE_GLYPH = 8 -- 雕文
TipsMgr.TYPE_RUNE = 9 -- 神符
TipsMgr.TYPE_RUNE_TOTAL_ATTR = 10 -- 神符属性
TipsMgr.TYPE_TOTEM_WIN = 11 --英雄Tip(聊天)
TipsMgr.TYPE_SOLDIER_WIN = 12 --图腾Tip(聊天)

local renderMap =  {}
local curTips = nil
local tips_timer = nil

function TipsMgr.getCurrTips()
    return curTips
end

function TipsMgr.registerTipsRender(type, renderCls)
    renderMap[type] = renderCls
end

--不需要手动调用
function TipsMgr.hideTips()
    tips_timer = TimerMgr.killTimer(tips_timer)
    if curTips then
        curTips:removeFromParent()
        curTips = nil
    end
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
    UIMgr.removeScriptHandler(layer)
end

local function doShowTips(gp, type, data, exData)
    if not data then
        return
    end
    if type == TipsMgr.TYPE_COIN then
        if not data.cate then
            return
        end
        if data.cate == const.kCoinItem then
            type = TipsMgr.TYPE_ITEM
            data = findItem(data.objid)
        else
            type = TipsMgr.TYPE_STRING
            data = string.format("%s*%s", CoinData.getCoinName(data.cate), data.val)
        end
        if not data then
            return
        end
    end
    local viewCls = renderMap[type]
    if not viewCls then
        LogMgr.error("没有对应的Tips显示对象")
        return
    end

    local winName = viewCls.winName
    PopMgr.setWinNameLayer(winName, SceneMgr.LAYER_TIPS)
    --Command.run("ui show", winName, PopUpType.SPECIAL,true,1,)
    PopMgr.popUpWindow(winName, true, PopUpType.SPECIAL, true, nil, false, cc.c4b(0xff, 0xff, 0xff, 1))
    local win = PopMgr.getWindow(winName)
    if win then
        win:setData(data, exData)
    end                                                                                                                                        

    --[[
    local view = viewCls.new()
    view:setData(data, exData)
    local size = view:getContentSize()

    --TASK #6831::【手游12月版】tips出现位置规则(谭)
    local pos = cc.p( gp.x + 75 , gp.y + 20 ) 
    --大于中心点，显示左，否则显示右
    if gp.x > visibleSize.width/2 then
        pos.x = gp.x - size.width - 75
        if pos.x < 0 then
            pos.x = 0
        end
    end
    
    if pos.y + size.height > visibleSize.height then
        pos.y = gp.y - 20 - size.height
        if pos.y < 0 then
            pos.y = visibleSize.height/2 - size.height/2
            --pos.y = 0
        end
    end

    local layer = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
    addToParent(view, layer, pos.x, pos.y, 10000)
    curTips = view
    local function onTouchEnd(touch, event)
        TipsMgr.hideTips()
    end
    UIMgr.registerScriptHandler(layer, onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED, false)
    TipsMgr.time = DateTools.getTime()
    ]]
end

function TipsMgr.coinTipsHandler(target)
    if target.tipsData then
        TipsMgr.showTips(target:getTouchStartPos(), TipsMgr.TYPE_COIN, target.tipsData, target.tipsDataEx)
    end
end

function TipsMgr.addCoinTipsHandler(target)
    if string.find(tolua.type(btn), "ccui.") == 1 then
        target:addTouchBegin(target, TipsMgr.coinTipsHandler)
    else
        local function handler(touch, event)
            if target.tipsData then
                TipsMgr.showTips(touch:getLocation(), TipsMgr.TYPE_COIN, target.tipsData, target.tipsDataEx)
            end
        end
        UIMgr.registerScriptHandler(target, handler, cc.Handler.EVENT_TOUCH_BEGAN, true)
    end
end

function TipsMgr.showTips(gp, type, data, exData, exData2, exData3 )
    --TipsMgr.hideTips()
    local function showHandler()
        doShowTips(gp, type, data, exData, exData2, exData3 )
    end
    tips_timer = TimerMgr.callLater(showHandler, 0.05)
end

--显示规则
--@param rules 规则，可以为字符串数组或者单个字符串，富文本格式
--@param title 标题，字符串
--@param title 标题是否为图片
function TipsMgr.showRules(rules, title, isImage)
    local win = PopMgr.popUpWindow("CommonRuleUI", true, PopUpType.SPECIAL)
    if win then
        win:setData(rules, title, isImage)
    end
end

require("lua/game/view/tips/TipsMain.lua")

------------------ 获得物品后，显示icon飞行效果  ------------------
--- 获取 目的点的view ---
local function getTargetView(iconName)
    local item = nil
    if iconName == "bag" then
        local bottom = MainUIMgr.getRoleBottom()
        item = bottom.con_bottom.btn_bag
    elseif iconName and iconName ~= "" then
        local top = MainUIMgr.getRoleTop()
        if nil ~= top then
            item = top:getIconView(iconName)
        end
    end
    return item
end
--- 显示物品动作 ---
local function showItemTo(item, pos, target, layer)
    local url = CopyRewardData.getRewardIconUrl(item)
    if nil == url then url = "" end
    if url == "" then LogMgr.debug("路径不存在：" .. debug.dump(item)) end
    local rType = ccui.TextureResType.plistType
    if item.cate == 4 or item.cate == 13 then
        rType = ccui.TextureResType.localType
    end
    local icon = ccui.ImageView:create(url, rType)
    icon:setTouchEnabled(false)
    
    local dx = math.random(-100, 100)
    local dy = math.random(-100, 100)
    local px, py = visibleSize.width / 2 + dx, visibleSize.height / 2 + dy
    icon:setPosition(px, py)
    layer:addChild(icon, 1000)

    local dy = math.random(-50, 50)
    local h = math.random(80, 150)
    local jump1 = cc.JumpBy:create(0.4, cc.p(80, 0), h, 1)
    local jump2 = cc.JumpBy:create(0.3, cc.p(50, 0), h - 30, 1)
    local stop = cc.DelayTime:create(0.2)
    local move = cc.MoveTo:create(0.5, pos)
    local function callback()
        layer:removeChild(icon, true)
        icon = nil
        if rType == ccui.TextureResType.localType then
            textureCache:removeTextureForKey(url)
        end
        showScaleEffect(target)
    end
    local func = cc.CallFunc:create(callback, {})
    local seq = cc.Sequence:create(jump1, jump2, stop, move, func)
    icon:runAction(seq)
end
--- 显示飞向view的物品
local function showEffectTo(itemList, layer)
    if layer == nil then 
        layer = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
    end
    local iconName = ""
    local j = 0
    local bag_count = 0
    local playItemSound = false
    local playMoneySound = false
    for k, list in pairs(itemList) do
        if k == const.kCoinMoney then
            iconName = "con_gold"
            playMoneySound = true
        elseif k == const.kCoinStrength then
            iconName = "con_strength"
        elseif k == const.kCoinWater then
            iconName = "con_solution"
        elseif k == const.kCoinGold then
            iconName = "con_diamond"
        elseif k == const.kCoinItem then
            iconName = "bag"
            playItemSound = true
        end
        local item = getTargetView(iconName)
        if nil ~= item then
            local pos = item:getParent():convertToWorldSpace( cc.p(item:getPositionX(), item:getPositionY()) )
            if iconName == "bag" then
                pos.x = pos.x + item:getSize().width / 2
                pos.y = item:getSize().height / 2
                -- 屏蔽获取物品时，点击背包放大
                item:switchTypeStatus(false)
            end
            for k, v in pairs(list) do
                local num = 1
                if v.cate == const.kCoinItem then
                    num = v.val
                    bag_count = bag_count + num
                end
                for i = 1, num do
                    local url = CopyRewardData.getRewardIconUrl(v)
                    if nil == url or url == "" then
                        LogMgr.debug("路径不存在：" .. debug.dump(item))
                    end
                    local function callback()
                        if playItemSound and v.cate == const.kCoinItem then
                            playItemSound = false
                            SoundMgr.playUI("UI_getmaterial")
                        end
                        if playMoneySound and v.cate == const.kCoinMoney then
                            playMoneySound = false
                            SoundMgr.playUI("UI_getgold")
                        end
                        showItemTo(v, pos, item, layer)
                    end
                    if j == 0 then 
                        callback() 
                    else
                        performWithDelay(layer, callback, 0.1 * j)
                    end
                    j = j + 1
                end
            end
        end
    end
    -- 恢复背包点击放大
    local function callfunc()
        if bag_count > 0 then
            EventMgr.removeListener(EventType.SceneClose, callfunc)
            local btn_bag = getTargetView("bag")
            if nil ~= btn_bag then
                btn_bag:switchTypeStatus(true)
                bag_count = 0
            end
        end
    end
    performWithDelay(layer, callfunc, 0.5 * bag_count + 1)
    EventMgr.addListener(EventType.SceneClose, callfunc)
end
-- 执行获得物品的显示效果， list 物品列表数据 ，typeList 就是物品的静态type数据 ，layer 容器[可选] 默认为effectLayer层
-- list={S3Uint32,...}
function TipsMgr.showGetEffect(list, typeList, layer)
    if SceneMgr.isSceneName("fight") then
        local function laterHandler()
            EventMgr.removeListener(EventType.SceneShow, laterHandler)
            TipsMgr.showGetEffect(list, typeList, layer)
        end
        EventMgr.addListener(EventType.SceneShow, laterHandler)
        return
    end
    TipsMgr.showItemObtained(list) --飘文字
    LogMgr.debug(">>>>>>> showGetEffect: \n" .. debug.dump(list))
    local itemList = {}
    for k, v in pairs(list) do
        if v.cate~= const.kCoinTotem then
            if typeList == nil or table.find(typeList, v.cate) then
                if nil == itemList[v.cate] then
                    itemList[v.cate] = {}
                end
                table.insert(itemList[v.cate], v)
            end
        end
    end
    showEffectTo(itemList, layer)
end

--centerPos位置，_parent,转换容器，addIncrement战力增值
local  fightAddEffect = nil
function TipsMgr.showFightAdd( centerPos,_parent,addIncrement )
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
    if not fightAddEffect then
        fightAddEffect = cc.Node:create()
        fightAddEffect:setAnchorPoint(0,0)
        fightAddEffect:retain()
    end

    if fightAddEffect:getParent() == nil then
        layer:addChild(fightAddEffect)
    end

    local fCon = cc.Node:create()
    fCon:setAnchorPoint(0,0)
    layer:addChild(fCon)

    UIFactory.setSpriteChild(fCon, "fLabel", true, "fightadd_label.png", 0, 0)
    fCon.fLabel:setAnchorPoint(0,0)
    local lSize = fCon.fLabel:getContentSize()
    local url ="image/share/fightadd_num.png"
    local fNum = UIFactory.getTextAtlas(fCon, "0123456789", url, 26, 38, "0", addIncrement )
    fNum:setAnchorPoint(0,0)
    fNum:setPosition(lSize.width,0)
    local nSize = fNum:getContentSize()
    local pos = cc.p( centerPos.x - (lSize.width + nSize.width)/2, centerPos.y )
    pos = _parent:convertToWorldSpace(pos)
    fCon:setPosition(pos)

    local jumpBy = cc.JumpBy:create(1, cc.p(0, 70), -40, 1)
    local delay = cc.DelayTime:create(0.5)
    local fadeOut = cc.FadeOut:create(0.5)
    local seq = cc.Sequence:create(delay, fadeOut)
    local spawn = cc.Spawn:create(jumpBy, seq)
    fCon:runAction(cc.Sequence:create(spawn, cc.RemoveSelf:create()))
end 

function TipsMgr.hideFightAdd()
    if fightAddEffect then
        local layer = SceneMgr.getLayer(SceneMgr.LAYER_TIPS)
        if fightAddEffect:getParent() then
            fightAddEffect:removeFromParent()
        end
        fightAddEffect:release()
        fightAddEffect = nil
    end
end
EventMgr.addListener(EventType.CloseWindow, TipsMgr.hideFightAdd)
