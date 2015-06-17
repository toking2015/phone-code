-- @@合成
Command.bind( 'equip merge',
	function( _id )
    	trans.send_msg( 'PQEquipMerge', { id = _id } )
	end 
)

-- @@装备替换
Command.bind( 'equip replace',
	function( _is_replace, _equip_guid )-- [0:保留,1:替换] -- 新装备的guid
    	trans.send_msg( 'PQEquipReplace', { is_replace = _is_replace, equip_guid = _equip_guid } )
	end 
)

-- @@选择套装生效等级
Command.bind( 'equip selectSuit',
	function( _equip_type, _select_level )
    	trans.send_msg( 'PQEquipSelectSuit', { equip_type = _equip_type, select_level = _select_level  } )
	end 
)