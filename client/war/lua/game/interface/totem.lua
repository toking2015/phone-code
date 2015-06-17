--图腾协议发送
Command.bind("totem activate", function(totem_id)
	trans.sendNextFrame("PQTotemActivate", {totem_id=totem_id})
end)

Command.bind("totem bless", function(totem_guid, skill_type)
    trans.sendNextFrame("PQTotemBless", {totem_guid=totem_guid, skill_type=skill_type})
end)

Command.bind("totem addEnergy", function(totem_guid)
	trans.sendNextFrame("PQTotemAddEnergy", {totem_guid=totem_guid})
end)

Command.bind("totem accelerate", function(totem_guid, is_free)
	trans.sendNextFrame("PQTotemAccelerate", {totem_guid=totem_guid, is_free=is_free and 1 or 0})
end)

Command.bind("totem glyphmerge", function(guid1, guid2)
	local s2uint = {first=guid1, second=guid2}
	trans.sendNextFrame("PQTotemGlyphMerge", {guids=s2uint})
end)

Command.bind("totem glyphembed", function(totem_guid, glyph_guid)
    trans.sendNextFrame("PQTotemGlyphEmbed", {totem_guid=totem_guid, glyph_guid=glyph_guid})
end)