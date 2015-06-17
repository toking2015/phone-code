local prePath = "image/ui/HolyUI/"

CritWord = createUILayout("BuildingCritWord", prePath .. "BuildingCritWord.ExportJson", "BuildingSpeedStyle")

function CritWord:ctor(type)
    self.type = type -- 建筑类型
    local img_list = {[2] = "building_coin.png", "building_holy.png"}
    local frameName = img_list[self.type]
    self.holy:loadTexture(frameName, ccui.TextureResType.plistType)
end

function CritWord:createCritWord(type)
    local view = CritWord.new(type)
    
    local item = {view.critNum, view.crit, view.multiSign, view.holy, view.holyNum}
    function setTouch( )
        for i = 1, #item do
            item[i]:setTouchEnabled(false)
        end
    end
    view:setTouchEnabled(false)
--    critWord:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
    
    return view
end

function CritWord:updateCritWord(times, count)
    if times >= 2 then
        self.critNum:setString(times)
    else
        self.crit:setVisible(false)
        self.multiSign:setVisible(false)
        self.critNum:setVisible(false)
    end
    self.holyNum:setString(count)
end