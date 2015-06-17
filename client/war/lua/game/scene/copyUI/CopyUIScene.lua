-- Create By Hujingjiang --
require "lua/game/view/copyUI/NCopyUI.lua"

CopyUIScene = Scene:create()

function CopyUIScene:initScene()
    debug.showTime("copy_ui_scene_1_")
    if self.mainUI == nil then
        self.mainUI = NCopyUI:new()
        self:addChild(self.mainUI)
        LoadMgr.addPlistPool("image/ui/NCopyUI/NCopyUI0.plist", "image/ui/NCopyUI/NCopyUI0.png", LoadMgr.SCENE, self.name)
--        LoadMgr.addPlistPool("image/ui/NCopyUI/CopyIcon.plist", "image/ui/NCopyUI/CopyIcon.png", LoadMgr.SCENE, self.name)
    end
    debug.showTime("copy_ui_scene_1_")
    -- 以下移动到NCopyUI的firstShow()执行
    -- 判断是否有得到星星
    -- self.mainUI.starReward = CopyData.starReward
    debug.showTime("copy_ui_scene_2_")
    self.mainUI:firstShow()
    debug.showTime("copy_ui_scene_2_")
    
    local prev_scene_name = SceneMgr.prev_scene_name
    -- 上一个场景是副本时，清空缓存
    debug.showTime("copy_ui_scene_3_")
    if prev_scene_name == "copy" then
        LoadMgr.clearAsyncCache()
    end
    -- 上一个场景是战斗时，清空缓存，并解除锁定协议回调
    if prev_scene_name == "fight" then
        LoadMgr.clearAsyncCache()
        trans.lock_queue( false )
    end
    debug.showTime("copy_ui_scene_3_")
    
    debug.showTime("copy_ui_scene_4_")
    CopyData.clearCopyParam()
    -- CopyMgr.doFunciton(CopyData.getNextFight())
    debug.showTime("copy_ui_scene_4_")
end
function CopyUIScene:resetScene()
    if self.mainUI ~= nil then
        self.mainUI:onClose()
    end
end

function CopyUIScene:onShow()
    self:initScene()
    ChatData.loadYuyin()
    debug.showTime("copy_ui_scene_x_")
    if self.mainUI then
        local copyId = CopyData.getNextCopyId(const.kCopyMopupTypeNormal)
        if CopyData.new_copy_id ~= copyId then
            local building = self.mainUI:getBuilding(copyId)
            if building then
                self.mainUI:ReplayNewCopy(building, const.kCopyMopupTypeNormal)
                CopyData.new_copy_id = copyId
            end
        end    
    end
    debug.showTime("copy_ui_scene_x_")
    if CopyData.wait_close then
        Command.run("loading wait show", 'copy')
    end
    self:checkPushBack()
end

function CopyUIScene:checkPushBack()
    if self.hasBack ~= nil then
        return
    end
    if gameData.user.copy.copy_id < 2000 then
        if not CopyData.checkClearance( 1021 ) then
            return
        end
    end
    self.hasBack = true
    local function callback()
        Command.run( 'scene leave' )
    end
    BackButton:pushBack(self, callback, 2)
end

function CopyUIScene:onClose()
    self:resetScene()
    if self.hasBack then
        BackButton:pop(self)
        self.hasBack = nil
    end
    -- if not SceneMgr.hasScene("copyUI") then --退出副本UI场景，释放预加载的战斗资源
    --     ModelMgr:releaseUnFormationModel()
    -- end
end

function CopyUIScene:dispose()
    if self.mainUI ~= nil then
        self.mainUI:dispose()
        self.mainUI:removeFromParent()
        self.mainUI = nil
    end
end

-- 打开副本UI场景，area_id为区域id，stype为副本类型（普通，精英），boss为需要打开boss的数据（默认不填）
Command.bind( 'NCopyUI show', function(area_id, stype, boss, isNotShow)
    local cid = (area_id * 100 + 1) * 10 + 1
    local copy = findCopy(cid)
    if true == CopyData.checkOpenAreaBy(cid) then
        CopyData.setCurrAreaInfo(area_id, stype, boss)
        if isNotShow then
            SceneMgr.pushScene('copyUI')
        else
            Command.run( 'scene enter', 'copyUI' )
        end
    else
        TipsMgr.showError(copy.level .. "级开通此副本区域")
    end
end )
-- 打开副本UI场景中的copy_id副本，stype为副本类型，copy_id为副本id
Command.bind("NCopyUI show copy", function(stype, copy_id)
    if copy_id == nil or copy_id == 0 then
        copy_id = CopyData.getNextCopyId()
        if false == CopyData.checkOpenAreaBy(copy_id) then
            copy_id =CopyData.getMaxPassCopy(stype)
        end
    end
    
    local copy = findCopy(copy_id)
    local area_id = math.floor(copy_id / 1000)
    if true == CopyData.checkOpenAreaBy(copy_id) then
--    if copy.level <= gameData.user.simple.team_level then
        CopyData.setCurrAreaInfo(area_id, stype, 0, copy_id)
        
        if SceneMgr.isSceneName("copyUI") then
            SceneMgr.getCurrentScene().mainUI:showUI()
        else        
            Command.run( 'scene enter', 'copyUI' )
        end
    else
        TipsMgr.showError(copy.level .. "级开通此副本区域")
    end
end)
-- 打开默认副本UI场景
Command.bind("NCopyUI show default", function(isNotShow)
    local copy_id = CopyData.getNextCopyId()
    local area_id = math.floor(copy_id / 1000)
    if CopyData.checkOpenArea(area_id) == false then area_id = area_id - 1 end
    Command.run( 'NCopyUI show', area_id, const.kCopyMopupTypeNormal, nil, isNotShow)
end)

function CopyUIScene:getBuild( copyId, buildingId )
    if self.mainUI then
        -- if CopyData.user.copy then
        --     if CopyData.user.copy.copy_id == copyId then
        --         return self.mainUI['building'..buildingId]
        --     end
        -- end            
        return self.mainUI:getBuilding( copyId )
    end
    return nil
end

SceneMgr.insertScene( 'copyUI', CopyUIScene )