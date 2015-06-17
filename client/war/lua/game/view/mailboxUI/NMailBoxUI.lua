require "lua/game/view/mailboxUI/MailBoxMgr.lua"
require "lua/game/view/mailboxUI/NMailBoxAnnex.lua"
require "lua/game/view/mailboxUI/NMailBoxItem.lua"
-- require "lua/game/view/mailboxUI/NMailBoxContent.lua"
require "lua/utils/TextParse.lua"
-----------------------------------------

NMailBoxUI = createUILayout("NMailBoxUI", MailBoxMgr.prePath .. "NMailList.ExportJson", "ChatUI")

function NMailBoxUI:ctor()
    LogMgr.debug("MailBox ctor ....")
    PopMgr.addWinPlist("NMailBoxUI", "NMailBoxUI0.plist", "NMailBoxUI0.png")

    self:setTouchEnabled(false)
    -- self:setSize(cc.size(481, 488))

    createScaleButton(self.btn_one_key)

    MailBoxData.touchEnabled = true
    self.item_index = 0
    self.list_len = 0
    self.mail_item = nil

    self.tableView = UIFactory.getTableView(self, 470, 482, 21, 83)
    self.tableView:setAnchorPoint(cc.p(0, 0))
    self:registerScriptFunc()
    self.tableView:retain()

    self.one_key_touch_enabled = true
    local function oneKeyTouchFunc()
        -- 邮件一键操作
        ActionMgr.save( 'UI', 'NMailBoxUI click btn_one_key' )
        if MailBoxData.touchEnabled then
            MailBoxData.touchEnabled = false
            local flag = MailBoxMgr.isAnnexNotTake()
            if flag then
                -- 有附件可领取
                Command.run('mail take', 0)
                LogMgr.debug("一键收取所有邮件附件")
            else
                Command.run( 'mail del', 0)
                LogMgr.debug("一键删除所有邮件")
            end
        end
    end
    self.btn_one_key:addTouchEnded(oneKeyTouchFunc)

    self.tid = nil

    self:configureListener()
end

function NMailBoxUI:configureListener()
    self.event_list = {}
    self.event_list[EventType.deleteMail] = function()
        LogMgr.debug("邮件协议返回，操作类型", MailBoxData.mailOperate, MailBoxData.touchEnabled)
        self:updateMailItemList()
        self.tid = TimerMgr.startTimer(function()
            TimerMgr.killTimer(self.tid)
            self.tid = nil
            MailBoxData.touchEnabled = true end, 0.3)
    end
    self.event_list[EventType.updateMail] = function() 
        LogMgr.debug("邮件协议返回，操作类型", MailBoxData.mailOperate, MailBoxData.touchEnabled)
        if 'readMail' == MailBoxData.mailOperate then
            if self.item_index then
                LogMgr.debug('item_index - ', self.item_index)
                self.list = MailBoxData.getMailList() -- 更新邮件列表
                self.tableView:updateCellAtIndex(self.item_index - 1)
            end
        else
            self:updateMailItemList()
        end
        self.tid = TimerMgr.startTimer(function()
            TimerMgr.killTimer(self.tid)
            self.tid = nil
            MailBoxData.touchEnabled = true end, 0.3)
    end
    self.event_list[EventType.delAllMail] = function()
        LogMgr.debug("一键删除所有邮件返回")
        self:updateMailItemList()
        MailBoxData.touchEnabled = true
    end
    self.event_list[EventType.recvAllMail] = function()
        LogMgr.debug("一键领取所有邮件返回")
        self:updateMailItemList()
        MailBoxData.touchEnabled = true
    end
    EventMgr.addList(self.event_list)
end

function NMailBoxUI:initOneKeyBtn()
    local flag = MailBoxMgr.isAnnexNotTake() -- 判断是一键删除还是一键收取

    local png_bg = flag and "mail_btn_receive_big.png" or "mail_btn_del_big.png" 
    local png_txt = flag and "mail_one_key_recv.png" or "mail_one_key_del.png"

    self.btn_one_key:loadTexture(png_bg, ccui.TextureResType.plistType)
    self.btn_one_key.img_one_key:loadTexture(png_txt, ccui.TextureResType.plistType)
end

function NMailBoxUI:create()
    local view = NMailBoxUI.new()

    view:updateMailItemList()

    return view
end

function NMailBoxUI:updateMailItemList()
    self.list = MailBoxData.getMailList()
    if 0 == #(self.list) then
        self.btn_one_key:setVisible(false) --隐藏一键操作按钮
        local txt = UIFactory.getText("还没有收到邮件", self.bg, self.bg:getSize().width/2, self.bg:getSize().height/2)
    else
        self:initOneKeyBtn()
    end
    self.tableView:reloadData()
end

function NMailBoxUI:cellTouchHandler(item)
    -- 阅读邮件
    local data = item.data
    local index = item.index
    self.item_index = index
    if MailBoxData.touchEnabled == true and nil ~= data then
        MailBoxData.mailOperate = "readMail"
        if true == MailBoxMgr.isReadSignShow(data) then
            LogMgr.debug("阅读邮件..", data.mail_id, MailBoxData.touchEnabled)
            MailBoxData.touchEnabled = false
            Command.run('mail read', data.mail_id)
        end
        EventMgr.dispatch(EventType.showMailContent, data.mail_id)
        -- 以Layout创建
        -- if not self.mail_id and not self.mail_id:getParent() then
        --     self.mail_con = MailContent:createMailContent(data.mail_id)
        -- end
        -- self.mail_con:updateContent(data.mail_id)
        -- self:addChild(self.mail_con)
        -- self.mail_con:setPositionX(cc.p(self:getSize().width))
    end
end

function NMailBoxUI:registerScriptFunc()
    local function scrollViewDidScroll()
    end
    local function scrollViewDidZoom()
    end
    -- 触摸每一个cell事件处理
    local function tableCellTouched(tableView, cell)
        ActionMgr.save( 'UI', 'NMailBoxUI click tableCell' )
        LogMgr.debug("<<<<<table cell触摸事件>>>>>")
        if tableView:isTouchMoved() then
            return
        end
        local mailItem = cell:getChildByTag(123)
        if mailItem then
            self:cellTouchHandler(mailItem)
        end
    end
    -- 定制每一个cell大小
    local function cellSizeForTable(tableView, idx)
        return 108 + 3, 470
    end
    -- 定制每一个tableView中cell个数
    local function numberOfCellsInTableView(tableView)
        local list = MailBoxData.getMailList()
        self.list_len = #list
        return #(list)
    end
    -- 定制每一个cell内容
    local function tableSizeAtIndex(tableView, idx)
        local cell = tableView:dequeueCell()
        local index = idx + 1
        LogMgr.debug("index = " .. idx, index)
        -- local list = MailBoxData.getMailList()
        local mailData = self.list[index]
        if not cell then
            LogMgr.debug("tableview cell new >>>>>>>>")
            cell = cc.TableViewCell:new()
            
            local mailItem = MailItem:createMailItem(mailData)
            mailItem:setTouchEnabled(false)
            cell:addChild(mailItem, 10, 123)

            mailItem.index = index
            mailItem.data = mailData
            self.mail_item = mailItem
        else
            LogMgr.debug("tableview cell update >>>>>>>>")
            local mailItem = cell:getChildByTag(123)
            mailItem:updateItemData(mailData)

            mailItem.index = index
            mailItem.data = mailData
        end
        
        return cell
    end
    local function cellHighLight()
    end
    local function cellUnHighLight()
    end
    -- tableCellHighlight->tableCellUnhighlight->tableCellTouched 三个执行顺序
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellHighLight, cc.TABLECELL_HIGH_LIGHT)
    self.tableView:registerScriptHandler(cellUnHighLight, cc.TABLECELL_UNHIGH_LIGHT)
    self.tableView:registerScriptHandler(tableSizeAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
end

function NMailBoxUI:releaseAll()
    LogMgr.debug("MailBox Close ....")
    MailBoxData.touchEnabled = true
    EventMgr.removeList(self.event_list)
    if nil ~= self.tableView then
        self.tableView:release()
    end
    -- 当关闭ChatUI时关闭邮件内容窗口
    local view = PopMgr.getWindow("MailContent")
    if view and view:isShow() then
        Command.run("mailContent close")
    end
    -- if nil ~= self.mail_con then
    --     self.mail_con:release()
    -- end
    if nil ~= self.tid then
        TimerMgr.killTimer(self.tid)
    end
end


