local __this = MailBoxData or {}
MailBoxData = __this

function __this.clear()
	__this.reading_mail_id = nil  -- 正在阅读邮件id
	__this.touchEnabled = true
	__this.mailOperate = ""
end
__this.clear()
EventMgr.addListener(EventType.UserLogout, __this.clear)

-- local mailDataList = {}
local mailItemList = {} 

function __this.getMailMap()
     return gameData.user.mail_map
end

function __this.getMailById(id)
	local list = __this.getMailMap()
	local data = list[id]
	return data
end

-- 统计未读邮件数量
function __this.countUnReadMail()
	local count = 0
	local list = __this.getMailList()
	if not list then list = {} end
	for _, v in pairs(list) do
		if MailBoxMgr.isReadSignShow(v) then
			count = count + 1
		end
	end
	return count
end

local function sortByCoins(data)
	local flag = MailBoxMgr.isAnnexTake(data)
	if false == flag then
		return 0
	else
		return 1
	end
end

local function sortMailData()
	local unReadList, readList = {}, {}
	local mailDataList = table.values(__this.getMailMap())
	for _, v in pairs(mailDataList) do
		-- if false == MailBoxMgr.isAnnexTake(v) then
		if MailBoxMgr.judgeMailShowType(v) then
			table.insert(unReadList, v)
		else
			table.insert(readList, v)
		end
	end
	table.sort(unReadList, function(a, b) return a.deliver_time > b.deliver_time end)
	table.sort(readList, function(a, b) return a.deliver_time > b.deliver_time end)
	for _, v in pairs(readList) do
		table.insert(unReadList, v)
	end

	return unReadList
end

-- 获取经过排序的邮件列表（附件未领取在前）
function __this.getMailList()
	local mailDataList = sortMailData()
	return mailDataList
end

function __this.addMailItemToList(item, mail_id)
	if nil ~= item and nil == mailItemList[mail_id] then
		mailItemList[mail_id] = item
	end
end

function __this.getMailItemList()
	return mailItemList
end

-- 根据id找对应的邮件
function __this.findMailIndex(list, id)
	local index = 0
	for k, v in pairs(list) do
        if v.mail_id == id then
            index = k
            break
        end
    end
    return index
end
