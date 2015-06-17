-- create by Live --

-- 物品列表
Command.bind( 'item list', 
	function(index)
   	 trans.send_msg( 'PQItemList', {bag_index = index} )
	end 
)

-- 增加物品
Command.bind( 'item add', 
	function(id, count)
    	trans.send_msg( 'PQItemAdd', {item_id = id, item_count = count} )
	end
)

-- 物品整理
Command.bind( 'item sort', 
	function()
    	trans.send_msg( 'PQItemSort', {} )
	end 
)

-- 物品出售
Command.bind( 'item sell', 
	function(type,list)
    	trans.send_msg( 'PQItemSell', { bag_type = type, item_list = list } )
	end 
)

-- 物品赎回
Command.bind( 'item redeem', 
	function(guid)
    	trans.send_msg( 'PQItemRedeem', { item_guid = guid } )
	end 
)

-- 物品合成
Command.bind( 'item merge',
	function( _id, _count )
    	trans.send_msg( 'PQItemMerge', { id = _id, count = _count } )
	end 
)

-- 物品穿戴
Command.bind( 'item Equip',
	function( src ) -- 装备物品[first:bag_index, second:item_guid]
    	trans.send_msg( 'PQItemEquip', { src = src } )
	end 
)

-- 物品使用
Command.bind( 'item use',
	function( item_index, guid, count, index ) -- 装备物品[first:bag_index, second:item_guid]
    	trans.send_msg( 'PQItemUse', {item={ first=item_index, second=guid }, count=count, index=index } )
	end 
)

-- 技能书穿戴
Command.bind( 'item equipskill',
	function (bag_index, item_guid, soldier_guid)
		trans.send_msg('PQItemEquipSkill', { src = {first = bag_index, second = item_guid}, soldier_guid = soldier_guid})
	end
)
