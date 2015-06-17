-----------------------------------------------------------------------

-- 创建郵件附件icon
-- MailAnnex = class("MailAnnex", function()
--     local annex = getLayout(MailBoxMgr.prePath .. "NMailAnnex.ExportJson")
--     return annex
-- end)


-- function MailAnnex:ctor()
--     self:setTouchEnabled(false)
--     local function showAnnexTips()
--         if self.data then
--             local postion = self:getParent():convertToWorldSpace( cc.p(self:getPositionX(), self:getPositionY() - 100) )
--             if self.data.cate == const.kCoinItem then
--                 local item = findItem( self.data.objid )
--                 TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, item )
--             else
--                 local info = CoinData.getCoinName( self.data.cate, self.data.objid )
--                 TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, info .. '*' ..self.data.val )
--             end
--         end
--     end
--     -- UIMgr.addTouchBegin(self, showAnnexTips)
--     UIMgr.registerScriptHandler(self, showAnnexTips, cc.Handler.EVENT_TOUCH_BEGAN, true)
-- end

-- function MailAnnex:createAnnexItem()
-- -- 创建附件图标

--     local view = MailAnnex.new()
    
--     function view:setAnnexItem(data)
--         view.data = data
--         local icon = view.annex_bg.annex_icon
--         local txt = view.annex_bg.annex_num
--         local iconUrl = CoinData.getCoinUrl(data.cate, data.objid)
        
--         icon:loadTexture(iconUrl, ccui.TextureResType.localType)
--         local iconSize = icon:getSize()
--         icon:setScale(57/(iconSize.width+2))
--         txt:setString("" .. data.val)
--     end
    
--     return view
-- end

-------------------------------------------------------------------------

local png_list = {["mail_list"] = "mail_item_box_samll.png", ["mail_content"] = "mail_item_box_big.png"}

MailAnnex = createLayoutClass("NMailBoxUI", ccui.Layout)

function MailAnnex:ctor(type, size)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0, 0))
    self:setSize(size)

    self:getAnnex(type, size)

    local function showAnnexTips(touch, event)
        local dw = event:getCurrentTarget()
        if dw then
            local point = touch:getLocation()
            if point.y < 83 then
                return
            end
        end
        ActionMgr.save( 'UI', 'NMailBoxAnnex click MailAnnex' )
        if self.data then
            local postion = self:getParent():convertToWorldSpace( cc.p(self:getPositionX(), self:getPositionY() - 100) )
            if self.data.cate == const.kCoinItem then
                local item = findItem( self.data.objid )
                TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, item )
            else
                local info = CoinData.getCoinName( self.data.cate, self.data.objid )
                TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, info .. '*' ..self.data.val )
            end
        end
    end
    UIMgr.registerScriptHandler(self, showAnnexTips, cc.Handler.EVENT_TOUCH_BEGAN, true)
end

function MailAnnex:getAnnex(type, size)
    local frameName = png_list[type] or ""
    self.bg = ccui.ImageView:create(frameName, ccui.TextureResType.plistType)
    self.icon = ccui.ImageView:create()
    self.bg:addChild(self.icon)
    self:addChild(self.bg)
    self.bg:setPosition(cc.p(size.width/2, size.height/2))
    self.num = UIFactory.getText("", self, size.width - 6, 2, 14)
    self.num:setAnchorPoint(cc.p(1, 0))
    self.icon:setPosition(cc.p(size.width/2, size.height/2))
    self.bg:setTouchEnabled(false)
    self.icon:setTouchEnabled(false)
    self.num:setTouchEnabled(false)
end

-- type: 邮件列表，邮件内容中显示的附件(item, content)
-- size: 大小
function MailAnnex:createAnnexItem(type, size)
    type = not type and "mail_content" or type
    size = not size and cc.size(70, 70) or size
    local view = MailAnnex.new(type, size)

    function view:setAnnexItem(data)
        view.data = data
        local icon = view.icon
        local txt = view.num
        local iconUrl = CoinData.getCoinUrl(data.cate, data.objid)
        
        icon:loadTexture(iconUrl, ccui.TextureResType.localType)
        local iconSize = icon:getSize()
        icon:setScale(size.width/(iconSize.width+2))
        txt:setString("" .. data.val)
    end

    return view
end