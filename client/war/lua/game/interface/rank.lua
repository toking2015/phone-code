
-- 将记录排行榜数据进行保存
Command.bind( 'ranksave', 
    function(rank_type , set_type,list)
        trans.send_msg( 'PQRankCopySave', { rank_type = rank_type ,set_type = set_type, list = list} )
    end 
)

-- 请求读取记录排行榜数据
Command.bind( 'rankload', 
    function(rank_type , rank_attr)
        trans.send_msg( 'PQRankLoad', { rank_type = rank_type ,rank_attr = rank_attr} )
    end 
)

-- 请求指定id在指定排行榜中的索引位置(从0开始)
Command.bind( 'rankindex', 
    function(limit , rank_type,rank_attr,target_id)
        trans.send_msg( 'PQRankIndex', { limit = 10 ,rank_type = rank_type,rank_attr = rank_attr ,target_id = target_id} )
    end 
)

-- 请求排行榜列表
Command.bind( 'ranklist', 
    function(limit , rank_type ,index,count)
        trans.send_msg( 'PQRankList', { limit = 10 ,rank_type = rank_type,index = index,count = count} )
    end 
)

-- 请求排行榜列表
Command.bind( 'ranklisttype', 
    function(limit , rank_type,data_type,index,count)
        trans.send_msg( 'PQRankListType', { limit = 10 ,rank_type = rank_type,data_type = data_type ,index = index,count = count} )
    end 
)