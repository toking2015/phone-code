local prePath = "image/ui/LoadingUI/"

LoginUI = createUIClass("LoginUI", prePath.."LoginUI.ExportJson")

RegisterUI = createUIClass("RegisterUI", prePath.."RegisterUI.ExportJson")

ServerUI = createUIClass("ServerUI", prePath.."ServerUI.ExportJson")

local function getCommandFun(cmd, winName, btnName)
	local function fun()
		ActionMgr.save( 'UI', string.format('[%s] click [%s]',  winName, btnName) )
		Command.run(cmd)
	end
	return fun
end

function LoginUI:ctor()
	self.logo:setPosition(255, 512)
	createScaleButton(self.con_normal.btn_switch)
	createScaleButton(self.con_special.btn_switch)
	self.con_normal.btn_switch:addTouchEnded(getCommandFun("loading show switch", self.winName, 'con_normal.btn_switch'))
	self.con_special.btn_switch:addTouchEnded(getCommandFun("loading show switch", self.winName, 'con_special.btn_switch'))
	createScaleButton(self.con_normal.btn_register)
	self.con_normal.btn_register:addTouchEnded(getCommandFun("loading show register", self.winName, 'con_normal.btn_register'))
	createScaleButton(self.con_normal.btn_login)
	createScaleButton(self.con_special.btn_login)
	createScaleButton(self.btn_logout)
	createScaleButton(self.btn_change)
	self.btn_logout:addTouchEnded(function()
		ActionMgr.save( 'UI', '[LoginUI] click [btn_logout]' )
		
		if inf.onExit then
			inf.onExit()
		else
			system.exit()
		end
	end)
	if not inf.user_change then
		self.btn_change:setVisible(false)
	else
		self.btn_change:setVisible(true)
		local function changeCountHandler()
			ActionMgr.save( 'UI', '[LoginUI] click [btn_change]' )
			inf.user_change()
		end
		self.btn_change:addTouchEnded(changeCountHandler)
	end
	createScaleButton(self.btn_notice)
	self.btn_notice:addTouchEnded(function ( ... )
		ActionMgr.save( 'UI', '[LoginUI] click [btn_notice]' )
		Command.run( 'ui show', 'NoticeUI', PopUpType.SPECIAL )
	end)
	function self.setLoginEnable(value)
		self.con_normal.btn_login:setEnabled(value)
		self.con_special.btn_login:setEnabled(value)
	end
	function self.setConnectTips( key )
		if key and type(key) == "string" then
            if self.con_special and self.con_special.txt_tips then
                self.con_special.txt_tips:setString(key)
            end
        end
	end
    local function loginHandler(channel)
		ActionMgr.save( 'UI', '[LoginUI] click [btn_login]' )
		LoadingData.account.name = self.con_normal.txt_account:getText()
		LoadingData.account.id = self.con_normal.txt_account:getText()
		LoadingData.account.pwd = self.con_normal.txt_password:getText()
		self.setLoginEnable(false)
        Command.run("loading login", channel)
	end
	self.con_normal.btn_login:addTouchEnded(loginHandler)
	self.con_special.btn_login:addTouchEnded(loginHandler)
	TextInput:replace(self.con_normal.txt_account, 50)
	TextInput:replace(self.con_normal.txt_password, 50, true)
	if state.has( inf.platform_flags(), inf.f_login_custom ) then
		self.con_normal:setVisible(false)
		self.con_special:setVisible(true)
	elseif state.has( inf.platform_flags(), inf.f_login_multi ) then
	    self.con_normal:setVisible(false)
        self.con_special:setVisible(true)
        
        self.con_special.btn_login:setVisible(false)
        local info = inf.get_login_multi_info()
        self.multi_json = Json.decode( info )
        
        if #self.multi_json.data <= 0 then
            return
        end
        
        local space = 40
        local height = 0
        local width = ( #self.multi_json.data - 1 ) * space
        for key, var in ipairs(self.multi_json.data) do
            var.btn = cc.Sprite:create(var.image)
            var.btn:setAnchorPoint(cc.p(0, 0))
            
            local size = var.btn:getContentSize()
            width = width + size.width
            if size.height > height then
                height = size.height
            end
        end
        
        local last_click_time = 0
        local pos_x = ( 1136 - width ) / 2
        for key, var in ipairs(self.multi_json.data) do
            self.con_special:addChild( var.btn )
            
            var.btn:setPosition( pos_x, 120 )
            var.btn = createScaleButton( var.btn )

            var.btn:addTouchEnded(function ( ... )
                local time_now = system.time_sec()
                if time_now > last_click_time + 3 then
                    last_click_time = time_now
                    
                    loginHandler( var.channel )
                else
                    showMsgBox("登录技能在冷却中!")
                end
            end)
            
            pos_x = pos_x + space + var.btn:getContentSize().width
        end
	else
		self.con_normal:setVisible(true)
		self.con_special:setVisible(false)
	end

	-- local function editBoxTextEventHandler(strEventName, pSender)
	-- 	LogMgr.info(strEventName, pSender)
	-- end
	-- self.con_normal.txt_account:registerScriptEditBoxHandler(editBoxTextEventHandler)
end

function LoginUI:onShow()
	Command.bind('set loading tips', self.setConnectTips)
	Command.bind("loading login enable", self.setLoginEnable)
	self.server = LoadingData.lastServer
	self.con_normal.txt_server:setString(self.server.name)
	self.con_special.txt_server:setString(self.server.name)
	local account = LoadingData.account
	self.con_normal.txt_account:setText(account.name)
	self.con_normal.txt_password:setText(account.pwd)
	self.con_normal.txt_account:setPlaceHolder("input 1-999") --测试用
	if not NoticeData.getNoticeStr() or NoticeData.getNoticeStr() ==""then
		self.btn_notice:setVisible(false)
	else
		self.btn_notice:setVisible(true)
	end
end

function LoginUI:onClose()
	Command.unbind("loading login enable")
	Command.unbind('set loading tips')
	LoadingData.lastServer = self.server
	LoadingData.account.name = self.con_normal.txt_account:getText()
	LoadingData.account.password = self.con_normal.txt_password:getText()
end

function RegisterUI:ctor()
	self.btn_back:setPosition(25, 25)
	createScaleButton(self.btn_back)
	self.btn_back:addTouchEnded(getCommandFun("loading show login", self.winName, 'btn_back'))
	createScaleButton(self.btn_register)
	self.btn_register:addTouchEnded(getCommandFun("loading register", self.winName, 'btn_register'))
	TextInput:replace(self.txt_account, 50)
	TextInput:replace(self.txt_password1, 50, true)
	TextInput:replace(self.txt_password2, 50, true)
end

function RegisterUI:onShow()
	self.txt_account:setText("")
	self.txt_password1:setText("")
	self.txt_password2:setText("")
end

function ServerUI:ctor()
	self.pool = {}
	self.page = 1
	self.column = 3 -- 列数
	self.row = 4 --行数
	self.pageSize = self.row * self.column
	self.btn_back:setPosition(25, 25)
	createScaleButton(self.btn_back)
	self.btn_back:addTouchEnded(getCommandFun("loading show login", self.winName, 'btn_back'))
	createScaleButton(self.btn_pre)
	local function trunPre()
		ActionMgr.save( 'UI', '[LoginUI] click [btn_pre]' )
		if self.page > 1 then
			self.page = self.page - 1
			self:updateData()
		end
	end
	self.btn_pre:addTouchEnded(trunPre)
	createScaleButton(self.btn_next)
	local function turnNext()
		ActionMgr.save( 'UI', '[LoginUI] click [btn_next]' )
		if self.page < math.ceil(#LoadingData.serverList / self.pageSize) then
			self.page = self.page + 1
			self:updateData()
		end
	end
	self.btn_next:addTouchEnded(turnNext)
	local function serverClickHandler(obj, evt)
		ActionMgr.save( 'UI', '[LoginUI] click [serverClickHandler]' )
		if obj.json then
			LoadingData.lastServer = obj.json
			Command.run("loading show login")
		end
	end
	self.serverClickHandler = serverClickHandler
	createScaleButton(self.con_cur.svr)
	self.con_cur.svr:addTouchEnded(serverClickHandler)
	self.page1 = ccui.Layout:create()
	self.page1:setSize(self.con_all:getSize())
	self.con_all:addPage(self.page1)
end

function ServerUI:onShow()
	self.page = 1
	performNextFrame(self, self.updateData, self)
end

function ServerUI:onClose()
	for _,v in ipairs(self.pool) do
		v:release()
	end
	self.pool = {}
end

function ServerUI:createSvrItem()
	local sp = self.con_cur.svr:clone()
	initLayout(sp)
	sp:loadTexture("loading_svr_other.png", ccui.TextureResType.plistType)
	FontStyle.applyStyle(sp.txt_name, FontStyle.get(0x3c, 0x1c, 0x0, 24))
	createScaleButton(sp)
	sp:addTouchEnded(self.serverClickHandler)
	return sp
end

function ServerUI:updateData()
	self.con_cur.svr.json = LoadingData.lastServer
	self.con_cur.svr.txt_name:setString(LoadingData.lastServer.name)
	for _,v in ipairs(self.page1:getChildren()) do
		v:retain()
		table.insert(self.pool, v)
	end
	self.page1:removeAllChildren()

	local serverList = LoadingData.serverList
	local pageCount = math.ceil(#serverList / self.pageSize)

	self.btn_pre:setVisible(self.page > 1)
	self.btn_next:setVisible(self.page < pageCount)

	local startIndex = #serverList - (self.page - 1) * self.pageSize
	local endIndex = math.max(1, #serverList - self.page * self.pageSize + 1)

	local count = 0
	for i = startIndex, endIndex, -1 do
		local item
		if #self.pool > 0 then
			item = table.remove(self.pool)
			self.page1:addChild(item)
			item:release()
		else
			item = self:createSvrItem()
			self.page1:addChild(item)
		end
		item.json = serverList[i]
		item.txt_name:setString(item.json.name)
		local x = 312 * (count % self.column)
		local y = 300 - 100 * math.floor(count / self.column)
		item:setPosition(x, y)
		count = count + 1
	end
end