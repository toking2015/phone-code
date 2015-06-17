-------------------------------------------------
MailContent = createUIClass("MailContent", MailBoxMgr.prePath .. "NMailContent.ExportJson")
-- MailContent = createUILayout("MailContent", MailBoxMgr.prePath .. "NMailContent.ExportJson", "ChatUI")

local function getLabel(txt, parent, w, fontSize, c3b, font)
    local lbl = cc.Label:createWithTTF(txt, FontNames.HEITI, fontSize)
    lbl:setAnchorPoint(cc.p(0,1))
    if w then lbl:setWidth(w) end
    if c3b then lbl:setColor(c3b) end
    if parent then parent:addChild(lbl) end

    return lbl
end

function MailContent:ctor()
    self:configureListener()

    createScaleButton(self.btn_content)

    self.content_txt = getLabel("", self.mail_slider_content, 380, 18, cc.c3b(255,221,179), FontNames.HEITI)

    self.img_recv = ccui.ImageView:create("mail_rec.png", ccui.TextureResType.plistType)
    self.img_recv:setPosition(cc.p(218, 151))
    self.img_recv:retain()
    -- self.txt_recv = UIFactory.getText("已领取", nil, nil, nil, 18, cc.c3b(255,221,179), FontNames.HEITI)
    -- self.txt_recv:setRotation(45)
    -- self.txt_recv:setPosition(cc.p(65, 65))
    -- self.txt_recv:retain()

    local function closeMailContent()
        local view = PopMgr.getWindow("MailContent")
        if view and view:isShow() then
            PopMgr.removeWindowByName("MailContent")
        end
    end
    Command.bind("mailContent close", closeMailContent)

    local function btnTouchFunc()
        ActionMgr.save( 'UI', 'NMailBoxContent click btn_content' )
        local data = self.data
        local isAnnex = MailBoxMgr.judgeMailShowType(data)
        if false == isAnnex then
            -- 文字
            Command.run("mailContent close")
        elseif MailBoxData.touchEnabled then
            -- 附件
            LogMgr.debug("内容中收取附件 >>>>>>>>>>>>")
            MailBoxData.mailOperate = "takeMail"
            MailBoxData.touchEnabled = false
            Command.run('mail take', MailBoxData.reading_mail_id)
        end
    end
    self.btn_content:addTouchEnded(btnTouchFunc)

end

function MailContent:onShow()
    self:updateContent(MailBoxData.reading_mail_id)
    self:styleShow()
end

function MailContent:styleShow()
    local size = self:getSize()

    self:setPosition(cc.p(646, 1))
end

function MailContent:onClose()
    LogMgr.debug("MailContent Close ....")
    if self.img_recv then
        self.img_recv:release()
    end
    MailBoxData.reading_mail_id = nil
    EventMgr.removeList(self.event_list)
end

function MailContent:createMailContent(id)
    local view = MailContent.new()
    view.reading_mail_id = id

    local btn_content = createScaleButton(view.btn_content)

    view:configureListener()
    -- view:updateContent()

    return view
end

function MailContent:configureListener()
    self.event_list = {}
    self.event_list[EventType.deleteMail] = function(data)
        if data.mail_id == MailBoxData.reading_mail_id then
            Command.run("mailContent close")
        end
    end
    self.event_list[EventType.updateMail] = function(data) 
        if data.mail_id == MailBoxData.reading_mail_id then
            -- take和read属于同一邮件
            self:updateContent(MailBoxData.reading_mail_id)
        end
    end
    self.event_list[EventType.delAllMail] = function()
        Command.run('mailContent close')
    end
    self.event_list[EventType.recvAllMail] = function()
        self:updateContent(MailBoxData.reading_mail_id)
    end
    EventMgr.addList(self.event_list)
end

function MailContent:updateContent(id)
    local mail_title = self.mail_title_bg.mail_title
    local content_txt = self.mail_slider_content.content_txt
    local btn_img = self.btn_content.btn_con_img

    content_txt:setVisible(false)

    self.data = MailBoxData.getMailById(id)
    if not self.data then 
        TipsMgr.showError("mail_id对应的邮件不存在")
        return
    end

    local title = TextParse.custom_parse( self.data.subject )
    local body =  TextParse.custom_parse( self.data.body )
    mail_title:setString(title)

    -- local isAnnex = MailBoxMgr.judgeMailShowType(self.data)
    local isAnnex = MailBoxMgr.judgeMailType(self.data)
    if false == isAnnex then
        self.mail_slider_content:setSize(cc.size(389, 355))
        self.mail_slider_content:setPositionY(116)
        btn_img:loadTexture("mail_close.png", ccui.TextureResType.plistType)
        self.mail_slider_annex:setVisible(false)
        self.content_bg.bg.divide_line:setVisible(false)
        self.content_bg.bg.txt_annex:setVisible(false)
    else
        -- 附件
        self.mail_slider_content:setSize(cc.size(389, 181))
        self.mail_slider_content:setPositionY(290)
        if MailBoxMgr.isAnnexTake(self.data) then
            btn_img:loadTexture("mail_close.png", ccui.TextureResType.plistType)
            -- self.txt_recv:setVisible(true)
            if self.img_recv and self.img_recv:getParent() then self.img_recv:removeFromParent() end
            self:addChild(self.img_recv)
            self.mail_slider_annex:setVisible(false)
        else
            btn_img:loadTexture("mail_recv_big.png", ccui.TextureResType.plistType)
            -- self.txt_recv:setVisible(false)
            if self.img_recv and self.img_recv:getParent() then self.img_recv:removeFromParent() end
            self.mail_slider_annex:setVisible(true)
            local annexList = {}
            for k, v in pairs(self.data.coins) do
                local annex = MailAnnex:createAnnexItem()
                -- annex:addChild(self.txt_recv:clone())
                annex:setAnnexItem(v)
                table.insert(annexList, annex)
            end
            initScrollviewWith(self.mail_slider_annex, annexList, 4, 0, 0, 60, 0)
            self.mail_slider_annex:jumpToTop()
        end
        -- self.mail_slider_annex:setVisible(true)
        self.content_bg.bg.divide_line:setVisible(true)
        self.content_bg.bg.txt_annex:setVisible(true)

    end

    -- content_txt:setString(body)
    -- 邮件内容
    if not self.content_txt then
        self.content_txt = getLabel("", self.mail_slider_content, 380, 18, cc.c3b(255,221,179), FontNames.HEITI)
    end
    self.content_txt:setString(body)
    local size = self.content_txt:getContentSize()
    local h = math.max(size.height - 3, self.mail_slider_content:getSize().height - 3)
    self.content_txt:setPosition(cc.p(4, h))
    self.mail_slider_content:setInnerContainerSize(cc.size(389, size.height))
    self.mail_slider_content:jumpToTop()
end

local function showMailContent(id)
    MailBoxData.reading_mail_id = id
    local view = PopMgr.getWindow("MailContent")
    if view ~= nil and view:isShow() then
        view:updateContent(MailBoxData.reading_mail_id)
        return
    end
    Command.run("ui show", "MailContent", PopUpType.NORMAL, false)
end
EventMgr.addListener(EventType.showMailContent, showMailContent)