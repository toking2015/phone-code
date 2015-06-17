trans.call.PRTotemInfo = function(msg)
    local isAutoUp = #TotemData.getData() == 0 and #msg.info.totem_list == 1 
    gameData.user.totem_map[const.kTotemPacketNormal] = msg.info
    TotemData.updateIdMap() --先刷新索引，再派发事件
    EventMgr.dispatch(EventType.UserTotemUpdate)
    if isAutoUp then
        FormationData.upByGuid(const.kFormationTypeCommon, msg.info.totem_list[1].guid, const.kAttrTotem, true) --第一个图腾自动上阵
    end
end 

--返回对应的图腾信息
trans.call.PRTotemBless = function(msg)
    --模式处理（TotemData.virTotemData）
    if not TotemData.lockBless then
        return 
    end

    SoundMgr.playUI("ui_rolelevelup")
    TotemData.lockBless = false
    TotemData.bBlessTotem = msg.totem
    gameData.changeArray(TotemData.getData(), 'guid', const.kObjectUpdate, msg.totem)
    EventMgr.dispatch(EventType.UserTotemChange)
    EventMgr.dispatch(EventType.UserTotemBlessSuccess)
end 

trans.call.PRTotemAddEnergy = function(msg)
    gameData.changeArray(TotemData.getData(), 'guid', const.kObjectUpdate, msg.totem)
    EventMgr.dispatch(EventType.UserTotemChange)
end 

trans.call.PRTotemAccelerate = function(msg)
    gameData.changeArray(TotemData.getData(), 'guid', const.kObjectUpdate, msg.totem)
    if not TotemData.isAddEnergying(msg.totem) then
        TotemData.showTotemStarUpUI(msg.totem.id)
        EventMgr.dispatch(EventType.UserTotemLevelUp, msg.totem) --升级了
    else
        TipsMgr.showGreen("加速成功")
    end
    EventMgr.dispatch(EventType.UserTotemChange)
end 

trans.call.PRTotemGlyphMerge = function(msg)
    local sGlyph = TotemData.getGlyph(msg.deleted_guid)
    gameData.changeArray(TotemData.getGlyphList(), "guid", const.kObjectDel, sGlyph)
    gameData.changeArray(TotemData.getGlyphList(), "guid", const.kObjectUpdate, msg.result_glyph)
    TotemData.mergeData = msg.result_glyph
    EventMgr.dispatch(EventType.TotemMergeResult, msg)
end 

trans.call.PRTotemGlyphEmbed = function(msg)
    local sGlyph = TotemData.getGlyph(msg.glyph_guid)
    local jGlyph = findTempleGlyph(sGlyph.id)
    local tips = nil
    sGlyph.totem_guid = msg.totem_guid
    if msg.is_new == 0 then --替换
        local sGlyph = TotemData.getGlyph(msg.deleted_guid)
        gameData.changeArray(TotemData.getGlyphList(), "guid", const.kObjectDel, sGlyph)
    end
    EventMgr.dispatch(EventType.TotemSlotResult, msg)
end 

trans.call.PRTotemActivate = function(msg)
    if msg.totem_id == 80301 or msg.totem_id == 80201 then
        return 
    end
    if msg.is_success ==  1 then
        TotemData.showTotemGet( msg.totem_id )
    end
end

