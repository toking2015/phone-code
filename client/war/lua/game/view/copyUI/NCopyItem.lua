-- Create By Hujingjiang

local prePath = "image/ui/NCopyUI/"


-- 区域名称显示对象
CopyAreaName = class("CopyAreaName", function()
	return getLayout(prePath .. "CopyAreaName.ExportJson")
end)
function CopyAreaName:ctor()
    local image = ccui.ImageView:create()
    image:setPosition(self:getSize().width / 2, self:getSize().height / 2 - 2)
    self:addChild(image)
    self.image = image
end
function CopyAreaName:setData(area_id)
    self.image:loadTexture("image/ui/NCopyUI/areaName/" .. area_id .. ".png")
end
function CopyAreaName:setImage(img)
    self.image:loadTexture("image/ui/NCopyUI/areaName/" .. img)
end

------------------- 模块分割线 -------------------
-- 副本星星
CopyStar = class("CopyStar", function()
    return getLayout(prePath .. "CopyStar.ExportJson")
end)
function CopyStar:ctor()
    self.effect = nil
    self.area_id, self.type = 0    -- 区域id，副本类型
    self.curr, self.max = 0, 0     -- 当前获得星数，最大星数
    self.pro_bg.text:setString("0/0")
--  self.canGetColor = cc.c3b(0xff, 0xfc, 0x00)
--  self.hadGetColor = cc.c3b(0xa8, 0xdd, 0x5d)
    self.canGetColor = cc.c3b(0xff, 0xff, 0xff)
    self.hadGetColor = cc.c3b(0xff, 0xff, 0xff)
    -- 默认普通副本类型
    -- self:setType(const.kCopyMopupTypeNormal)
    self:showBoxType(false)
    
    createScaleButton(self.image)
    local function onClick()
        LogMgr.debug(">>>>>>>>>>>>> Click the box ...")
        ActionMgr.save( 'UI', 'CopyStar click btn_star showType:' .. self.type .. "  area_id:" .. self.area_id )
        Command.run("CopyPresentUI show", {showType = self.type, area_id = self.area_id, area_attr=self.attr})
    end
    self.image:addTouchEnded(onClick) 
end
function CopyStar:setAreaStar(area_id, showType)
    self.area_id, self.type = area_id, showType
    
    self.curr, self.max = CopyData.getAreaGetStar(area_id, showType), CopyData.getAreaAllStars(area_id)
    self.pro_bg.text:setString(self.curr .. "/" .. self.max)
    self.pro_bg.pro:setPercent(100 * self.curr / self.max)
    
    local isGet = CopyData.getPresentType(area_id, showType, self.curr, self.max)
    
    self:setPresent(isGet)
end
-- 显示宝箱状态，是否已领取
function CopyStar:showBoxType(isOpen)
    local url = "copy_newstar_star_normal_image2.png"
    if const.kCopyMopupTypeNormal == self.type then
        if not isOpen then
            if const.kCopyAreaAttrPass == self.attr then
                url = "copy_newstar_star_normal_image2.png"
                -- self.image:setPositionX(55)
            else
                url = "copy_newstar_star_normal_image1.png"
            end
        else
            if const.kCopyAreaAttrPass == self.attr then
                url = "copy_newstar_star_normal_image20.png"
                -- self.image:setPositionX(48)
            else
                url = "copy_newstar_star_normal_image10.png"
            end
        end
    else
        if not isOpen then
            if const.kCopyAreaAttrPass == self.attr then
                url = "copy_newstar_star_elite_image2.png"
            else
                url = "copy_newstar_star_elite_image1.png"
            end
        else
            if const.kCopyAreaAttrPass == self.attr then
                url = "copy_newstar_star_elite_image20.png"
            else
                url = "copy_newstar_star_elite_image10.png"
            end
        end
    end
    self.image:loadTexture(url, ccui.TextureResType.plistType)
        
    if isOpen then
        self.tips:loadTexture("copy_newstar_star_image3.png", ccui.TextureResType.plistType)
    else
        if const.kCopyAreaAttrPass == self.attr then
            self.tips:loadTexture("copy_newstar_star_image2.png", ccui.TextureResType.plistType)
        else
            self.tips:loadTexture("copy_newstar_star_image1.png", ccui.TextureResType.plistType)
        end
    end
end
-- 设置领取状态 -- 0:未开放  1:未通关  2:通关未领取    3:未满星   4:满星未领取 5:满星已领取
function CopyStar:setPresent(isGet)
    -- local txt_desc = self.img_box.txt_desc
    if 0 == isGet or 1 == isGet then
        if self.effect ~= nil then
            self.effect:removeFromParent()
            self.effect = nil
        end
        self.attr = const.kCopyAreaAttrPass
        self:showBoxType(false)
        self.pro_bg:setVisible(false)
    elseif 2 == isGet then
        if self.effect == nil then
            local effPath = "image/armature/ui/NCopyUI/fblq-tx-01/fblq-tx-01.ExportJson"
            self.effect = ArmatureSprite:addArmatureTo(self.image, effPath, "fblq-tx-01", 50, 54, nil, 2, "copyUI")
        end
        self.attr = const.kCopyAreaAttrPass
        self:showBoxType(false)
        self.pro_bg:setVisible(false)
    elseif 3 == isGet then
        if self.effect ~= nil then
            self.effect:removeFromParent()
            self.effect = nil
        end
        self.attr = const.kCopyAreaAttrFullStar
        self:showBoxType(false)
        self.pro_bg:setVisible(true)
    elseif 4 == isGet then
        if self.effect == nil then
            local effPath = "image/armature/ui/NCopyUI/fblq-tx-01/fblq-tx-01.ExportJson"
            self.effect = ArmatureSprite:addArmatureTo(self.image, effPath, "fblq-tx-01", 50, 54, nil, 2, "copyUI")
        end
        self.attr = const.kCopyAreaAttrFullStar
        self:showBoxType(false)
        self.pro_bg:setVisible(true)
    else
        if self.effect ~= nil then
            self.effect:removeFromParent()
            self.effect = nil
        end
        self.attr = const.kCopyAreaAttrFullStar
        self:showBoxType(true)
        self.pro_bg:setVisible(true)
    end
end
function CopyStar:removeEffect()
    if self.effect ~= nil then
        self.effect:removeFromParent()
        self.effect = nil
    end
end


------------------- 模块分割线 -------------------
-- 副本点，显示普通/精英副本，还有获得星数
NCopyPoint = class("NCopyPoint", function()
    return getLayout(prePath .. "NCopyPoint.ExportJson")
end)
function NCopyPoint:ctor()
    self.data = nil

    self.isShowIcon = false
    self.icon = ccui.ImageView:create()
    self.icon:setTouchEnabled(false)
    self.icon:setPosition(46, 70)
    self.icon:setVisible(false)
    self.img_copy_name_bg:addChild(self.icon)
    self.img_copy_name_bg:setPositionY(150)
    self.txt_copy_name:setString("")
end
function NCopyPoint:create(data)
    local cp = NCopyPoint:new()
    
    cp:setData(data)
    
    return cp
end
function NCopyPoint:setData(data)
    self.data = data
    if not data then
        return
    end

    local type = data.type
    local copy = data.copy
    local copy_id = copy.id
    local boss = data.boss
    local quality = boss.quality

    if stype == const.kCopyMopupTypeElite then
        self.img_copy:loadTexture("copy_icon_new_elite.png", ccui.TextureResType.plistType)
    else
        self.img_copy:loadTexture("copy_icon_new.png", ccui.TextureResType.plistType)
    end

    if const.kCopyMopupTypeElite == data.type then
        self.img_copy:loadTexture("copy_icon_new_elite.png", ccui.TextureResType.plistType)
    else
        self.img_copy:loadTexture("copy_icon_new.png", ccui.TextureResType.plistType)
    end

    -- 加载图标，普通副本有掉落装备加载装备图标，无装备则不加载，精英副本加载boss图标
    local preName = "copy_normal_"
    local isElite = type == const.kCopyMopupTypeElite
    local drop_item = copy.drop_item
    if true == isElite then
        if copy.elitedrop_item ~= nil and copy.elitedrop_item ~= 0 then
            self.isShowIcon = true
            isElite = true
            preName = "copy_elite_"
            local iconPath = MonsterData.getAvatarUrl(boss)
            self.icon:loadTexture(iconPath, ccui.TextureResType.localType)
            self.icon:setScale(0.9)
            self.icon:setPosition(41, 75)

            setButtonPoint(self.icon, false)
        else
            self.isShowIcon = false
            isElite = false
        end
    else
        if drop_item ~= nil and drop_item ~= 0 then
            self.isShowIcon = true
            preName = "copy_elite_"
            local iconPath = ItemData.getItemUrl(drop_item)
            self.icon:loadTexture(iconPath, ccui.TextureResType.localType)
            self.icon:setScale(0.6)
            self.icon:setPosition(42, 58)

            local size = self.icon:getSize()
            local off = cc.p(size.width - 8, size.height - 80)
            setButtonPoint(self.icon, SoldierData.checkSoldiersBooks(drop_item), off, nil, prePath .. "title/copy_tips.png")
        else
            self.isShowIcon = false
            isElite = false
        end
    end
    self:setStars(copy, type, self.isShowIcon)
    self.icon:setVisible(self.isShowIcon)
    self.txt_copy_name:setString(copy.name)
    self.img_copy_name_bg:loadTexture(prePath .. "title/" .. preName .. boss.quality .. ".png", ccui.TextureResType.localType)

    -- 显示进度条
    -- self.con_percent:setVisible(not isElite)
    self:setProgress(copy_id, type, copy)
end
function NCopyPoint:setProgress(copy_id, type, copy)
    if type ~= const.kCopyMopupTypeElite then
        local cur, max = CopyData.getCopyGuage(copy_id)
        
        local percent = math.min(100, math.floor( cur * 100 / max ))
        self.con_percent.copy_progress:setPercent(percent)
        self.con_percent.txt_percent:setString( tostring(percent) .. '%' )

        if not copy.chunk or 0 == #copy.chunk or cur == max then
            self.con_percent:setVisible(false)
        else
            self.con_percent:setVisible(true)
        end
    else
        self.con_percent:setVisible(false)
    end
end
function NCopyPoint:setStars(copy, stype, icon)
    local cur= CopyData.getCopyStars(copy.id, stype)
    local s = 0
    local con_stars = self.img_copy_name_bg.con_stars
    for i = 1, cur do
        local star = con_stars["img_star" .. i]
        if 2 ~= i or not icon then
            star:loadTexture("copy_star_light_small.png", ccui.TextureResType.plistType)
        else
            star:loadTexture("copy_star_light.png", ccui.TextureResType.plistType)
        end
        s = s + 1
    end
    for i = s + 1, 3 do
        local star = con_stars["img_star" .. i]
        if 2 ~= i or not icon then
            star:loadTexture("copy_star_dark_small.png", ccui.TextureResType.plistType)
        else
            star:loadTexture("copy_star_dark.png", ccui.TextureResType.plistType)
        end
    end

    for i = 1, 3 do
        local star = con_stars["img_star" .. i]
        if icon then
            if 1 == i then
                star:setPosition(32, 27)
            elseif 2 == i then
                star:setPosition(60, 16)
            else
                star:setPosition(89, 27)
            end
        else
            if 1 == i then
                star:setPosition(21, 27)
            elseif 2 == i then
                star:setPosition(44, 16)
            else
                star:setPosition(66, 27)
            end
        end
    end
end
function NCopyPoint:resetNameBgPt()
    self.img_copy_name_bg:setPositionY(150)
end
-- 组合数据，data = {type, copy}
local function getCopyData(data)
    local copyData = nil
    if nil ~= data then
        local type = data.type
        local copy = data.copy
        local copy_id = data.copy.id
    
        local bossData = CopyData.getCopyBoss(copy_id, type)
        local boss = nil
        if nil ~= bossData then
            boss = findMonster(bossData.boss_id)
        end
        copyData = {type = data.type, copy = copy, boss = boss}
    end
    return copyData
end
-- 副本view，由一个NCopyInfo和一个NCopyPoint组成
NCopyView = class("NCopyView", function()
    return Node:create()
end)
function NCopyView:ctor()
    self.data = nil
    self.effect = nil
    
    local cp = NCopyPoint:create()
    local size = cp:getSize()
    local cpp = cc.p(-size.width / 2, -size.height / 2)
    cp:setPosition(-50, -35)
    self:addChild(cp, 11)
    self.cp = cp
    
    createScaleButton(cp)
    local function clickHandler(ref)
        if nil ~= self.data then
            local data = cp.data
            --点击 100001 副本图标
            if CopyData.checkOpenCopy( data.copy.id ) then
                ActionMgr.save( 'copy', 'click ' .. data.copy.id )
                Command.run("BossInfoUI show", {type = data.type, copy_id = data.copy.id, boss_id = data.boss.id})
            end
        else
            LogMgr.debug(">>>>>>>>>> 木有副本点数据")
        end
    end
    cp:addTouchEnded(clickHandler)
end

--设置未开启图标
function NCopyView:setOpenView(visible, stype)
    self.cp.img_copy_name_bg.con_stars:setVisible(not visible)
    if not visible then
        if self.openEffect then
            self.openEffect:setVisible(visible)
        end

        self.cp.img_copy_name_bg:setVisible(true)
        self.cp:setTouchEnabled(true)
        return
    end

    if not self.openEffect then
        local name = nil
        if const.kCopyMopupTypeElite == stype then
            name = "fblg-tx-04"
        else
            name = "fblg-tx-02"
        end

        local function onComplete( ... )
            Command.run("loading wait hide", 'copy_newbuilding')
            self.openEffect:removeNextFrame()
            self.openEffect = nil

            self:showOpenReadyView(stype, true)
            self.cp.img_copy_name_bg:setVisible(true)
            self.cp:setTouchEnabled(true)
            EventMgr.dispatch(EventType.CopyNewBuilding)

            SoundMgr.playEffect("sound/ui/UI_open.mp3")
        end
        local url = "image/armature/ui/NCopyUI/" .. name .. "/" .. name .. ".ExportJson"
        self.openEffect = ArmatureSprite:addArmatureTo(self, url, name, 5, 40, onComplete, 100, "copyUI")
    end

    self.openEffect:setVisible(true)
    self.openEffect:gotoAndStop(0)
    self.cp.img_copy_name_bg:setVisible(false)
    self.cp:setTouchEnabled(false)
end

function NCopyView:isTouchEnabled()
    return self.cp:isTouchEnabled()
end

function NCopyView:openEffectPlay(stype)
    self:setOpenView(true, stype)
    self.openEffect:gotoAndPlay(1)
end

function NCopyView:showOpenReadyView(stype, visible)
    if not visible then
        if self.openReadyEffect then
            self.openReadyEffect:removeFromParent()
            self.openReadyEffect = nil
        end

        return
    end

    if not self.openReadyEffect then
        local name = nil
        if const.kCopyMopupTypeElite == stype then
            name = "fblg-tx-03"
        else
            name = "fblg-tx-01"
        end
        local url = "image/armature/ui/NCopyUI/" .. name .. "/" .. name .. ".ExportJson"
        self.openReadyEffect = ArmatureSprite:addArmatureTo(self, url, name, 0, 28, fun, 0, "copyUI")
    end
    self.openReadyEffect:gotoAndPlay(0)
end

-- 当前木有作用
function NCopyView:setSelected(effect)
    if effect ~= nil then
        self.effect = effect
        if effect:getParent() ~= nil then effect:removeFromParent() end
        self.cp:addChild(effect, 0)
        effect:setPosition(25, 55)
    else
        self.effect = nil
    end
end
function NCopyView:setData(data)
    self.data = data
    if nil ~= data then
        local copyData = getCopyData(data)
        self.cp:setData(copyData)
    end
    self:updateMaterial()
end
function NCopyView:updateMaterial()
    -- local material = nil
    -- if nil ~= self.data then
    --     local copy_id = self.data.copy.id
    --     material = CopyData.getCopyMaterial(copy_id)
    --     if nil ~= material then
    --         local url = ItemData.getItemUrl(material.material_id)
    --         a:loadTexture(url, ccui.TextureResType.localType)
    --     end
    -- end
    -- self.btn_icon:setVisible(nil ~= material)
end
function NCopyView:create(data)
    local cv = NCopyView:new()
    cv:setData(data)
    return cv
end

------------------- 模块分割线 -------------------

NCopySelect = class("NCopySelect", function()
    return getLayout(prePath .. "NCopySelect.ExportJson")
end)
function NCopySelect:ctor()
    self.index = const.kCopyMopupTypeNormal
    local btnList = {
        {btn_selected = self.btn_normal_select, btn_unselected = self.btn_normal},
        {btn_selected = self.btn_elite_select, btn_unselected = self.btn_elite},
        {btn_selected = self.btn_material_select, btn_unselected = self.btn_material}
    }
    local dataList = {const.kCopyMopupTypeNormal, const.kCopyMopupTypeElite, const.kCopyMaterial}
    local tab = createTab(btnList, dataList)

    ------- 测试代码，战队等级20级才开放资源标签，未学习手工技能前不允许点击 ---------
    if gameData.user.simple.team_level < 20 then
        self.btn_material:setVisible(false)
        self.btn_material_select:setVisible(false)
    end
    
    self.tab = tab
   
end
function NCopySelect:setSelect(index)
    self.index = index
    if index == const.kCopyMopupTypeElite then
        ActionMgr.save( 'UI', 'NCopySelect click kCopyMopupTypeElite' )
        self.tab:setSelectedIndex(const.kCopyMopupTypeElite)
    elseif index == const.kCopyMaterial then
        ActionMgr.save( 'UI', 'NCopySelect click kCopyMaterial' )
        self.tab:setSelectedIndex(const.kCopyMaterial)
    else
        ActionMgr.save( 'UI', 'NCopySelect click kCopyMopupTypeNormal' )
        self.tab:setSelectedIndex(const.kCopyMopupTypeNormal)
    end
    EventMgr.dispatch( EventType.CopySelect )
    EventMgr.dispatch( EventType.CopySelects )
end
function NCopySelect:addEventListener(handler)
    local tab = self.tab
    local function callback(data)
        if nil ~= handler then
            handler(data)
        end
    end
    tab:addEventListener(self.tab, callback)
end
function NCopySelect:create()
    local ns = NCopySelect:new()
    
    return ns
end
------------------- 模块分割线 -------------------

local PI = 3.1415926
local linePath = "copy_line_pass_normal.png"
local function getLineUrl(lineType)
	if lineType ~= const.kCopyMopupTypeElite then
		return "copy_line_pass_normal.png"
	end
	return "copy_line_pass_elite.png"
end
local function getTurnAngel(startPT, endPT)
	local fix = math.abs(startPT.x - endPT.x)
	local angle = 0
    if startPT.y == endPT.y then
        angle = 0
    else
        angle = math.deg(math.atan((startPT.y - endPT.y)/fix))
    end
    return angle
end
CopyLine = class("CopyLine", function ()
	local line = Sprite:create()
	return line
end)
function CopyLine:create(lineType, startPoint, endPoint)
	local line = CopyLine:new()

	line:changeLine(lineType)
	line:setAnchorPoint(0, 0.5)
	local w = cc.pGetDistance(startPoint, endPoint)
	line:setScaleX(w / line:getContentSize().width)
	local angel = getTurnAngel(startPoint, endPoint)
	if startPoint.x > endPoint.x then
	   angel = -angel - 180
	end
	line:setRotation(angel)
	line:setPosition(startPoint.x, startPoint.y)

	return line
end
function CopyLine:changeLine(lineType)
    -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(linePath)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(getLineUrl(lineType))
	self:setSpriteFrame(frame)
end

CopyLineElite0 = createUILayout('CopyLineElite0', "image/ui/NCopyUI/copyBg/CopyArea_Elite_0/CopyArea_Elite_0.ExportJson", "copyUI", true)
CopyLineElite1 = createUILayout('CopyLineElite1', "image/ui/NCopyUI/copyBg/CopyArea_Elite_1/CopyArea_Elite_1.ExportJson", "copyUI", true)
CopyLineElite2 = createUILayout('CopyLineElite2', "image/ui/NCopyUI/copyBg/CopyArea_Elite_2/CopyArea_Elite_2.ExportJson", "copyUI", true)
CopyLineElite3 = createUILayout('CopyLineElite3', "image/ui/NCopyUI/copyBg/CopyArea_Elite_3/CopyArea_Elite_3.ExportJson", "copyUI", true)
CopyLineElite4 = createUILayout('CopyLineElite4', "image/ui/NCopyUI/copyBg/CopyArea_Elite_4/CopyArea_Elite_4.ExportJson", "copyUI", true)
CopyLineElite5 = createUILayout('CopyLineElite5', "image/ui/NCopyUI/copyBg/CopyArea_Elite_5/CopyArea_Elite_5.ExportJson", "copyUI", true)
CopyLineElite6 = createUILayout('CopyLineElite6', "image/ui/NCopyUI/copyBg/CopyArea_Elite_6/CopyArea_Elite_6.ExportJson", "copyUI", true)
CopyLineElite7 = createUILayout('CopyLineElite7', "image/ui/NCopyUI/copyBg/CopyArea_Elite_7/CopyArea_Elite_7.ExportJson", "copyUI", true)
CopyLineElite8 = createUILayout('CopyLineElite8', "image/ui/NCopyUI/copyBg/CopyArea_Elite_8/CopyArea_Elite_8.ExportJson", "copyUI", true)
CopyLineElite9 = createUILayout('CopyLineElite9', "image/ui/NCopyUI/copyBg/CopyArea_Elite_9/CopyArea_Elite_9.ExportJson", "copyUI", true)
CopyLineElite10 = createUILayout('CopyLineElite10', "image/ui/NCopyUI/copyBg/CopyArea_Elite_10/CopyArea_Elite_10.ExportJson", "copyUI", true)
CopyLineElite11 = createUILayout('CopyLineElite11', "image/ui/NCopyUI/copyBg/CopyArea_Elite_11/CopyArea_Elite_11.ExportJson", "copyUI", true)
CopyLineElite12 = createUILayout('CopyLineElite12', "image/ui/NCopyUI/copyBg/CopyArea_Elite_12/CopyArea_Elite_12.ExportJson", "copyUI", true)

CopyLineNormal0 = createUILayout('CopyLineNormal0', "image/ui/NCopyUI/copyBg/CopyArea_Normal_0/CopyArea_Normal_0.ExportJson", "copyUI", true)
CopyLineNormal1 = createUILayout('CopyLineNormal1', "image/ui/NCopyUI/copyBg/CopyArea_Normal_1/CopyArea_Normal_1.ExportJson", "copyUI", true)
CopyLineNormal2 = createUILayout('CopyLineNormal2', "image/ui/NCopyUI/copyBg/CopyArea_Normal_2/CopyArea_Normal_2.ExportJson", "copyUI", true)
CopyLineNormal3 = createUILayout('CopyLineNormal3', "image/ui/NCopyUI/copyBg/CopyArea_Normal_3/CopyArea_Normal_3.ExportJson", "copyUI", true)
CopyLineNormal4 = createUILayout('CopyLineNormal4', "image/ui/NCopyUI/copyBg/CopyArea_Normal_4/CopyArea_Normal_4.ExportJson", "copyUI", true)
CopyLineNormal5 = createUILayout('CopyLineNormal5', "image/ui/NCopyUI/copyBg/CopyArea_Normal_5/CopyArea_Normal_5.ExportJson", "copyUI", true)
CopyLineNormal6 = createUILayout('CopyLineNormal6', "image/ui/NCopyUI/copyBg/CopyArea_Normal_6/CopyArea_Normal_6.ExportJson", "copyUI", true)
CopyLineNormal7 = createUILayout('CopyLineNormal7', "image/ui/NCopyUI/copyBg/CopyArea_Normal_7/CopyArea_Normal_7.ExportJson", "copyUI", true)
CopyLineNormal8 = createUILayout('CopyLineNormal8', "image/ui/NCopyUI/copyBg/CopyArea_Normal_8/CopyArea_Normal_8.ExportJson", "copyUI", true)
CopyLineNormal9 = createUILayout('CopyLineNormal9', "image/ui/NCopyUI/copyBg/CopyArea_Normal_9/CopyArea_Normal_9.ExportJson", "copyUI", true)
CopyLineNormal10 = createUILayout('CopyLineNormal10', "image/ui/NCopyUI/copyBg/CopyArea_Normal_10/CopyArea_Normal_10.ExportJson", "copyUI", true)
CopyLineNormal11 = createUILayout('CopyLineNormal11', "image/ui/NCopyUI/copyBg/CopyArea_Normal_11/CopyArea_Normal_11.ExportJson", "copyUI", true)
CopyLineNormal12 = createUILayout('CopyLineNormal12', "image/ui/NCopyUI/copyBg/CopyArea_Normal_12/CopyArea_Normal_12.ExportJson", "copyUI", true)

------------------- 模块分割线 -------------------
NCopyMaterial = class("NCopyMaterial", function()
    return getLayout(prePath .. "NCopyMaterial.ExportJson")
end)

function NCopyMaterial:ctor()
    self.able = true
    function self.onTouchBegin()
        SoundMgr.playEffect("sound/ui/holy.mp3")
        if self.able then
            local function completeHandler()
                -- 次数
                if self.left_collect_times <= 0 then
                    TipsMgr.showError("采集次数不足")
                    self:setTouchEnabled(true)
                    return
                end
                -- 手工活力
                local need_score = PaperSkillData.getCollectCost(self.level)
                if CoinData.checkLackCoin(const.kCoinActiveScore, need_score, 0) then
                    self:setTouchEnabled(true)
                    return
                end
                -- 因为要显示动画，让父层显示似乎比较方便
                if self.callback then
                    self.callback(self.level)
                end
                -- 客户端自己先把次数减一
                self.left_collect_times = self.left_collect_times - 1
            end

            self:setTouchEnabled(false)
            local duration = 0.1
            local scaleAct_1 = cc.ScaleTo:create(duration, 1)
            local scaleAct_2 = cc.ScaleTo:create(duration, 0.75)
            self.item_icon:runAction(cc.Sequence:create(scaleAct_1, scaleAct_2, cc.CallFunc:create(completeHandler)))
        else
            self:setAble()
            self.countdown_txt:setColor(cc.c3b(0xff, 0x00, 0x00))
            local paper_level = (self.level - 2) * 20 + 10
            self.countdown_txt:setString(string.format("手工技能达到%d级开启", paper_level))
        end
    end

    local function onTouchEnd()
        if self.level > #gameData.user.copy_material_list then
            self:setUnable()
        end
    end

    self:setTouchEnabled(true)
    UIMgr.addTouchBegin(self, function ()
        ActionMgr.save('UI', 'NCopyUI down collect')
        self.onTouchBegin()
    end)
    UIMgr.addTouchEnded(self, function ()
        ActionMgr.save('UI', 'NCopyUI up collect')
        onTouchEnd()
    end)
    UIMgr.addTouchCancel(self, onTouchEnd)
end

function NCopyMaterial:setLevel(level, cb)
    self.level = level
    self.callback = cb
end

function NCopyMaterial:init()
    local jData = findCopyMaterial(self.level)
    if not jData then return end
    local skill_type = PaperSkillData.getPaperSkillType()
    if skill_type == 0 then return end
    local item_id = jData.materials[skill_type] or 0
    self.item_icon:loadTexture(ItemData.getItemUrl(item_id), ccui.TextureResType.localType)
    self.item_icon:setScale(0.75)
    
    self.tipbox:loadTexture(prePath .. string.format("icon/material_lv%d.png", self.level < 6 and self.level or 5), ccui.TextureResType.localType)
    local x, y = self.pedestal:getPosition()
    local size = self:getSize()
    self:setAnchorPoint(x / size.width, y / size.height)

    local item = findItem(item_id)
    self.item_name:setString(item and item.name or "")
    self.left_time_txt:setString("")
    self.countdown_txt:setString("")
    self.timer = 0
    self.left_collect_times = 0
end

function NCopyMaterial:destroy()
    if self.timer and self.timer > 0 then
        TimerMgr.killTimer(self.timer)
    end
end

function NCopyMaterial:update(data)
    local function updateCountdown()
        local time_now = gameData.getServerTime()
        if not self.timer_end_time then
            LogMgr.error("updateCountdown failed!")
            return
        end

        if time_now >= self.timer_end_time then
            self.countdown_txt:setString("")
            TimerMgr.killTimer(self.timer)
            self.left_collect_times = self.left_collect_times + 1
            self.left_time_txt:setString(string.format("%d/%d", self.left_collect_times, const.kMaterialCollectMaxTime))
            self.timer = 0

            if self.left_collect_times < const.kMaterialCollectMaxTime then
                self.timer_end_time = time_now + const.kMaterialRefreshInterval
                self.timer = TimerMgr.startTimer(updateCountdown, 1)
            end
        else
            local left_sec = self.timer_end_time - time_now
            local sec = math.fmod(left_sec, 60)
            local min = (left_sec - sec) / 60
            self.countdown_txt:setString(string.format("(%02d:%02d后次数+1)", min, sec))
        end
    end

    if not data then
        self:setUnable()
    else
        self.left_collect_times = data.left_collect_times
        self.left_time_txt:setString(string.format("%d/%d", data.left_collect_times, const.kMaterialCollectMaxTime))
        local c4b = cc.c4b(0, 0, 0, 0xff)
        addOutline(self.left_time_txt, c4b, 1)
        local time_now = gameData.getServerTime()
        local next_add_time = data.del_timestamp > 0 and data.del_timestamp + const.kMaterialRefreshInterval or 0
        if next_add_time > 0 and time_now < next_add_time and self.timer == 0 then
            self.timer_end_time = next_add_time
            self.timer = TimerMgr.startTimer(updateCountdown, 1)
        elseif next_add_time == 0 then
            self.countdown_txt:setString("")
            self.countdown_txt:setColor(cc.c3b(0xd2, 0xff, 0x00))
        end

        if not self.able then
            self:setAble()
        end
    end
end

function NCopyMaterial:setUnable()
    self.able = false 
    ProgramMgr.setGray(self.tipbox)
    ProgramMgr.setGray(self.item_icon)
    ProgramMgr.setGray(self.pedestal)
    self.left_time_txt:setVisible(false)
    self.item_name:setVisible(false)
    self.countdown_txt:setVisible(false)
end

function NCopyMaterial:setAble()
    self.able = true
    ProgramMgr.setNormal(self.tipbox)
    ProgramMgr.setNormal(self.item_icon)
    ProgramMgr.setNormal(self.pedestal)
    self.left_time_txt:setVisible(true)
    self.item_name:setVisible(true)
    self.countdown_txt:setVisible(true)
end

------------------- 模块分割线 -------------------
NCopyActiveScore = class("NCopyActiveScore", function ()
    return getLayout(prePath .. "NCopyActiveScore.ExportJson")
end)

function NCopyActiveScore:ctor()
    local function showSkillUI()
        ActionMgr.save('UI', 'NCopyUI click paper_skill_icon')
        Command.run('ui show', 'PaperCreateUI', PopUpType.SPECIAL)
    end
    createScaleButton(self.paper_skill_icon)
    self.paper_skill_icon:addTouchEnded(showSkillUI)
    EventMgr.addListener(EventType.UserCoinUpdate, self.updateScore, self)
end

function NCopyActiveScore:destroy()
    EventMgr.removeListener(EventType.UserCoinUpdate, self.updateScore)
end

function NCopyActiveScore:updateScore()
    local left_score = CoinData.getCoinByCate(const.kCoinActiveScore)
    local jSkill = PaperSkillData.getJSkill()
    local limit_score = jSkill and jSkill.active_score_limit or 500
    self.left_active_score:setString(string.format("%d/%d", left_score, limit_score))
end