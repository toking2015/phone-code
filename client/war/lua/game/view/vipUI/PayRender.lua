local prePath = "image/ui/VipUI/"
local TestRender = nil
local MONTHCOIN = 25 -- 购买月卡费用
-- 创建类
PayRender = class("PayRender", function()
	if not TestRender then
		TestRender = getLayout(prePath .. "PayRender.ExportJson")
		TestRender:retain()
	end
	local view = TestRender:clone()
	initLayout(view)
	return view
end)

function PayRender:ctor()
	createScaleButton(self)
	self.con_dia:setTouchEnabled(false)
end

function PayRender:dispose()
	if TestRender ~= nil then
		TestRender:release()
		TestRender = nil
	end
end

-- 创建PayRender对象
function PayRender:create()
	return PayRender.new()
end

function PayRender:showGiveQuota(data)
	local txt_give = self.txt_give -- 赠送
	if 25 == data.pay then
		-- 月卡
		txt_give:setString("每天赠送120钻石")
	else
		-- 普通钻石购买
		local present = PayData.getGivePresent(data)
		if 0 == present then
			-- 没有额外赠送
			txt_give:setVisible(false)
		else
			txt_give:setVisible(true)
			txt_give:setString("额外赠送" .. present .. "钻石")
		end
	end
end

function PayRender:showPayTitle(data)
	local txt_title = self.txt_title -- 标题
	if 25 == data.pay then
		-- 月卡
		local time, isValid = PayData.checkCardValid()
		if true == isValid then
			-- 月卡有效
			txt_title:setString("月卡（剩余" .. DateTools.getDay(time) .. "天")
		else
			txt_title:setString("月卡（未购买）")
		end
	else
		txt_title:setString(data.pay * 10 .. '钻石')
	end
end

function PayRender:showPayCost(data)
	local txt_cost = self.txt_cost -- 花费
	if 25 == data.pay then
		-- 月卡
		local time, isValid = PayData.checkCardValid()
		if true == isValid then
			-- 月卡有效
			txt_cost:setString("已购买") -- 已购买月卡且月卡未失效
		else
			txt_cost:setString("￥" .. data.pay) -- 未购买月卡或月卡失效
		end
	else
		txt_cost:setString("￥" .. data.pay)
	end
end

local function payInfoUpdate(data) -- 请求购买返回信息
	EventMgr.removeListener(EventType.UserPayUpdate, payInfoUpdate)
	if msg.coin == MONTHCOIN then
		LogMgr.log( 'debug',"购买月卡")
		local curTime = gameData.getServerTime()
		local payInfo = PayData.getInfo()
		local expireTime = payInfo.month_time
		local surplusTime = (expireTime - curTime)/(3600*24)
		if surplusTime > 0 then
			if surplusTime <= 3 then
				showMsgBox("[image=alert.png][font=ZH_9]月卡还有"..surplusTime.."天将到期[br][font=ZH_10]是否继续续费[btn=two]cancel.png:renew.png")
			end
			local function receiveMonthReward()
				-- 领取月卡每日奖励
				local str = "[image=diamond.png][font=ZH_9]领取每日"..payInfo.month_reward.."钻石的月卡奖励"
				local function confirmTouchFunc()
					Command.run('month reward', {})
				end
				showMsgBox(str, confirmTouchFunc)
			end
			receiveMonthReward()
		end
	end
	showMsgBox('[font=ZH_5]购买成功')
end

local function itemClickHandler(self, eventType)
    ActionMgr.save( 'UI', 'PayRender click PayRender' )
    --屏蔽充值
    if not Config.login_data or Config.login_data.pay ~= 1 then
	    TipsMgr.showError('该功能尚未开启')
    	return
    end
    local data = self.data
    local function confirmHandler()
        -- 监听是否支付成功
        -- EventMgr.addListener(EventType.CheckPayOK, payInfoUpdate)
        local str = ""
        if data.pay == MONTHCOIN then
        	str = "月卡"
        else
        	str = data.pay .. "钻石"
        end
        local url = 'http://' .. Config.data.host .. '/platform/' .. Config.platform.name .. '/pay_callback.php';
        -- local callBackInfo_table = { rid = gameData.id, server_id = Config.server.id, group = Config.data.group, pay_id = data.pay }
        local callBackInfo_table = { rid = gameData.id, name = str }
        local callBackInfo_context = Json.encode(callBackInfo_table) 
        PayData.payTime = DateTools.getTime()
        inf.pay( data.pay, str, url, callBackInfo_context )
        ---- 调用外部充值接口，充值成功后，服务器返回给客户端充值成功，增加钻石
    end
    local function cancelHandler()
    end
    local str = nil
    if MONTHCOIN == data.pay then
    	local time, isValid = PayData.checkCardValid()
    	if time < 6 * 24 * 60 * 60 then
    		str = '[image=diamond.png][font=ZH_5]花费[font=ZH_3]' .. self.data.pay .. '[font=ZH_5]元购买月卡'
    	else
    		str = '[image=alert.png][font=ZH_5]您购买的月卡还有'..DateTools.secondToString(time)..'天到期'
    	end
    else
    	str = '[image=diamond.png][font=ZH_5]花费[font=ZH_3]' .. self.data.pay .. '[font=ZH_5]元购买钻石'
    end
    showMsgBox(str, confirmHandler, cancelHandler)
end

function PayRender:setRender(data)
	-- 从data 获取数据 并修改
	self.data = data

	local pay_bg = self.pay_bg
	local pay_icon = self.pay_icon -- 钻石图片
	local txt_dia = self.con_dia.txt_dia -- 得到
	local img_dia = self.con_dia.img_dia

	pay_bg:loadTexture(prePath .. 'vip_gift_bg.png', ccui.TextureResType.localType)

	self:showGiveQuota(data)
	self:showPayTitle(data)
	self:showPayCost(data)

	-- 显示购买不同额度背景
	data.icon = data.icon or 2
	pay_icon:loadTexture(prePath .. data.icon .. ".png", ccui.TextureResType.localType)
	-- 显示购买到钻石
	txt_dia:setString("" .. data.pay * 10)
	local size = txt_dia:getContentSize().width + img_dia:getSize().width
	local viewSize = self:getContentSize().width
	self.con_dia:setPositionX((viewSize - size)/2)
	
    self:addTouchEnded(itemClickHandler)
end
