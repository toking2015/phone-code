------------------------------------------------------------------

MailItem = createUILayout("MailItem", MailBoxMgr.prePath .. "NMailItem.ExportJson", "NMailBoxUI")

function MailItem:ctor()
    self.oneKeyTouch = false
    self.mail_del = false
end

function MailItem:dispose()
end

function MailItem:createMailItem(data)
    local mailItem = MailItem.new()
    initLayout(mailItem)

    mailItem.data = data

    local con_annex = mailItem.mail_annex_con
    local btn_mail = createScaleButton(mailItem.btn_mail)
    -- createScaleButton(mailItem, false)

    con_annex:setTouchEnabled(false)

    mailItem:configureListener()
    mailItem:updateItemData(data)

    -- mailItem.item_bg:loadTexture(MailBoxMgr.prePath .. "mail_info_item.png", ccui.TextureResType.localType)

    return mailItem
end

function MailItem:configureListener()
    local function btnTouchHandler(touch, event)
        -- 点击一键收取或删除按钮
        local pos = touch:getTouchStartPos()
        -- LogMgr.debug('pos.y = ', pos.y)
        if pos.y < 83 then
            return
        end
        ActionMgr.save( 'UI', 'NMailBoxItem click btn_mail' )
        local isAnnex = MailBoxMgr.judgeMailShowType(self.data)
        if false == isAnnex then
            --删除邮件
            if true == MailBoxMgr.isMailExist(self.data.mail_id) and true == MailBoxData.touchEnabled then
                LogMgr.debug("删除邮件 >>>>>>MailBoxMgr.mail_del>>>>>>", MailBoxData.touchEnabled)
                MailBoxData.touchEnabled = false
                MailBoxData.mailOperate = "delMail"
                Command.run( 'mail del', self.data.mail_id)
            else
                LogMgr.debug("邮件已经删除，更新列表 >>>>>>>>>>>>>>" .. self.data.mail_id)
            end
        else
            -- 收取附件
            if false == MailBoxMgr.isAnnexTake(self.data) and true == MailBoxData.touchEnabled then
                LogMgr.debug("一键收取附件 >>>>>>>>>>>>" .. self.data.mail_id)   
                MailBoxData.touchEnabled = false
                MailBoxData.mailOperate = "takeMail"
                Command.run( 'mail take', self.data.mail_id)
            else
                LogMgr.debug("邮件已经领取，等待服务器返回 >>>>>>>>>>>>>>")
            end
        end
    end
    self.btn_mail:addTouchEnded(btnTouchHandler)
end

function MailItem:updateItemData(data)
    self.data = data
    local isShow = MailBoxMgr.isReadSignShow(data)
    local size = self:getSize()
    setButtonPoint(self, isShow, cc.p(size.width - 20, size.height - 20))
    local isAnnex = MailBoxMgr.judgeMailShowType(data)
    if false == isAnnex then
        self:createItemText(data)
    else
        -- 附件
        self:createItemAnnex(data)
    end
end

function MailItem:createItemText(data)
    self.mail_sign:loadTexture("mail_reel.png", ccui.TextureResType.plistType)
    self.btn_mail:loadTexture("mail_btn_del_small.png", ccui.TextureResType.plistType)
    self.btn_mail.mail_btn_img:loadTexture("mail_del.png", ccui.TextureResType.plistType)
    self.mail_annex_con:setVisible(false)
    self.mail_brief:setVisible(true)

    local title = TextParse.custom_parse( data.subject )
    self.mail_title:setString(title)
    local body =  TextParse.custom_parse( data.body )
    local len = StringTools.len(body)
    if len > 19 then
        body = StringTools.subUtf8String(body, 19) .. "...."
    end
    self.mail_brief:setString(body)
end

function MailItem:createItemAnnex(data)
    local annexList = data.coins
    self.mail_sign:loadTexture("mail_chest.png", ccui.TextureResType.plistType)
    self.btn_mail:loadTexture("mail_btn_receive_small.png", ccui.TextureResType.plistType)
    self.btn_mail.mail_btn_img:loadTexture("mail_receive.png", ccui.TextureResType.plistType)
    self.mail_annex_con:setVisible(true)
    self.mail_brief:setVisible(false)

    local title = TextParse.custom_parse( data.subject )
    self.mail_title:setString(title)
    local index = math.min(3, #(annexList))
    for i = 1, index do
        local annex = MailAnnex:createAnnexItem("mail_list", cc.size(49, 49))
        -- annex:setTouchEnabled(false)
        annex:setAnnexItem(annexList[i])
        self.mail_annex_con:addChild(annex)
        annex:setPositionX((i-1)*(annex:getSize().width+30))
    end
end
