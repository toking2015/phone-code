--TipsString = createLayoutClass("TipsString", TipsBase)
TipsString = createUIClassEx("TipsString", TipsBase, PopWayMgr.SMALLTOBIG)
--注册
TipsMgr.registerTipsRender(TipsMgr.TYPE_STRING, TipsString)

function TipsString:render()
    local str = self.data
    local color1 = cc.c3b(0xff, 0xda, 0x00)
    local list = string.split(str, "[br]")
    for i = 1, #list do
        self:addTextBr(list[i], color1, 18)
    end
end
