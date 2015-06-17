local __this = {}
MailBoxMgr = __this

-- local isRecMail = false

__this.prePath = "image/ui/NMailBoxUI/"

function __this.judgeMailType(data)
	-- 判断邮件是否是附件类型
	data = data or {}
	if 0 == #(data.coins) then
		return false
	else
		return true
	end
end

function __this.isReaded(data)
	-- 判断邮件是否已阅读
	data = data or {}
	if state.has(data.flag, const.kMailFlagReaded) then
		return true
	else
		return false
	end
end

function __this.isAnnexTake(data)
	-- 判断附件是否领取
	data = data or {}
	if state.has(data.flag, const.kMailFlagTake) then
		-- 已领取
		return true
	else
		-- 没有领取
		return false
	end
end

-- 判断是否有未领取附件
function __this.isAnnexNotTake()
	-- list是先有附件和没有附件顺序排序
	local list = MailBoxData.getMailList()
	if not list or table.empty(list) then return false end
	-- 判断第一个邮件是否有附件未领取
	-- return __this.judgeMailShowType(list[1])
	local hasAnnex = false
	for _, v in pairs(list) do
		if __this.judgeMailShowType(v) then
			hasAnnex = true
			break
		end
	end
	return hasAnnex
end

function __this.isSysMail(data)
	-- 判断是否是系统邮件
	data = data or {}
	if state.has(data.flag, const.kMailFlagSystem) then
		return true
	else
		return false
	end
end

function __this.isMailExist(id)
	id = id or 0
	local isExist = false
	local list = MailBoxData.getMailList()
	if list == nil then list = {} end
	for _, v in pairs(list) do
		if v.mail_id == id then
			isExist = true
			break
		end
	end
	return isExist
end

-- mailItem 可读标示是否显示
function __this.isReadSignShow(data)
	data = data or {}
	if __this.isReaded(data) then
		return
	end
	if __this.isAnnexTake(data) then
		return
	end
	return true
end
-- 判断是否有未阅读邮件
function __this.hasNewMail()
	-- local list = {}
	-- local isNew = false
	-- list = MailBoxData.getMailList()
	-- for _, v in pairs(list) do
	-- 	isNew = __this.isReadSignShow(v)
	-- 	if true == isNew then
	-- 		break
	-- 	end
	-- end
	local count = MailBoxData.countUnReadMail()
	return count > 0
end

function __this.judgeMailShowType(data)
	data = data or {}
	local isAnnex = __this.judgeMailType(data)
	if true == isAnnex then
		if false == __this.isAnnexTake(data) then
			-- 显示附件
			return true
		else
			-- 显示文本
			return false
		end
	else
		-- 显示文本
		return false
	end
end

---------------------------
-- 显示收邮件附件特效
function __this.showGetAnnexEffect(data)
	-- local annex = data.coins
	-- showGetEffect(annex, {const.kCoinMoney,const.kCoinStrength,const.kCoinWater, const.kCoinGold, const.kCoinItem} )
	-- TipsMgr.showItemObtained( annex )
end

---------------------------

function __this.checkReceiveMail(msg)
	if trans.const.kObjectAdd == msg.set_type then
		-- 新邮件
		NMailEffect.isRecMail = true
		NMailEffect.checkShowEffect()
		EventMgr.dispatch(EventType.addNewMail, msg.data)
	elseif trans.const.kObjectUpdate == msg.set_type then
		EventMgr.dispatch(EventType.updateMail, msg.data)
	else
		EventMgr.dispatch(EventType.deleteMail, msg.data)
	end
end

