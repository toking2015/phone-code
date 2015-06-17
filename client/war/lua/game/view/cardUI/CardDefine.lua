CardDefine = {}

--两种模式
CardDefine.TYPE_NOR = 1 --普通模式
CardDefine.TYPE_DIM = 2 --钻石模式
CardDefine.size = nil
CardDefine.center = nil
CardDefine.cdInterval = tonumber( findGlobal("altar_lottery_free_interval").data )
CardDefine.cdDimInterval = tonumber( findGlobal("altar_lottery_gold_free_interval").data )
CardDefine.qInfo = {type =0,times = 0,need = 0}
--CardDefine.showStepItem = false