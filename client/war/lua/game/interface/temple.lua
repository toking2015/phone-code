Command.bind("temple info",
	function ()
		trans.send_msg("PQTempleInfo", {})
	end
)

Command.bind("temple lvup",
	function (group_id)
		trans.send_msg("PQTempleGroupLevelUp", {group_id = group_id})
	end
)

Command.bind("temple openhole",
	function (hole_type,is_use_item)
		trans.send_msg("PQTempleOpenHole", {hole_type = hole_type,is_use_item = is_use_item})
	end
)


Command.bind("temple embed",
	function (hole_type,hole_index,glyph_guid)
		trans.send_msg("PQTempleEmbedGlyph", {hole_type=hole_type,hole_index = hole_index,glyph_guid = glyph_guid})
	end
)

Command.bind("temple train",
	function (main_guid,eated_guid)
		trans.send_msg("PQTempleGlyphTrain", {main_guid=main_guid,eated_guid=eated_guid})
	end
)

Command.bind("temple takereward",
	function (reward_id)
		trans.send_msg("PQTempleTakeScoreReward", {reward_id = reward_id})
	end
)